import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/supabase_constants.dart';
import '../data/models/course.dart';
import '../data/models/progress.dart';
import '../data/datasources/supabase_courses_datasource.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyOnboarded = 'has_seen_onboarding_v2';

  SharedPreferences? _prefs;
  final SupabaseCoursesDataSource _coursesDataSource = SupabaseCoursesDataSource();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Preload courses into memory
    await _coursesDataSource.getCourses();
  }

  // --- Onboarding status ---
  bool hasSeenOnboarding() {
    return _prefs?.getBool(_keyOnboarded) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool seen) async {
    await _prefs?.setBool(_keyOnboarded, seen);
  }

  // --- Courses Management ---
  Future<List<Course>> getCourses() async {
    return await _coursesDataSource.getCourses();
  }

  Course? getCourseById(String id) {
    return _coursesDataSource.getCourseById(id);
  }

  // --- Network Only User Progress Management ---
  UserProgress? _inMemoryProgress;

  Future<void> fetchProgressFromCloud() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _inMemoryProgress = UserProgress(totalXp: 0, streakDays: 1);
      return;
    }

    try {
      // 1. Fetch Profile
      final profileRes = await supabase
          .from(SupabaseConstants.tableProfiles)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      int xp = (profileRes?['total_xp'] as int?) ?? 0;
      int streak = (profileRes?['streak_days'] as int?) ?? 1;

      // 2. Fetch Completed Lessons
      final lessonsRes = await supabase
          .from(SupabaseConstants.tableCompletedLessons)
          .select('lesson_id')
          .eq('user_id', user.id);
      final lessonIds = (lessonsRes as List).map((r) => r['lesson_id'].toString()).toSet();

      // 3. Fetch Completed Quizzes
      final quizzesRes = await supabase
          .from(SupabaseConstants.tableCompletedQuizzes)
          .select('quiz_id')
          .eq('user_id', user.id);
      final quizIds = (quizzesRes as List).map((r) => r['quiz_id'].toString()).toSet();

      // 4. Fetch Completed Challenges
      final challengesRes = await supabase
          .from(SupabaseConstants.tableCompletedChallenges)
          .select('challenge_id')
          .eq('user_id', user.id);
      final challengeIds = (challengesRes as List).map((r) => r['challenge_id'].toString()).toSet();

      _inMemoryProgress = UserProgress(
        completedLessonIds: lessonIds,
        completedQuizIds: quizIds,
        completedChallengeIds: challengeIds,
        totalXp: xp,
        streakDays: streak,
        lastActiveDate: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Network error fetching progress: $e');
      throw Exception('Network error: Could not load your progress. Please check your internet connection.');
    }
  }

  UserProgress getProgress() {
    return _inMemoryProgress ?? UserProgress(totalXp: 0, streakDays: 1);
  }

  Future<UserProgress> completeLesson({
    required String lessonId,
    int? xpEarned,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final current = getProgress();
    final earned = xpEarned ?? 10;
    final newXp = current.totalXp + earned;

    try {
      // Network call
      await supabase.from(SupabaseConstants.tableCompletedLessons).upsert({
        'user_id': user.id,
        'lesson_id': lessonId,
        'xp_earned': earned,
        'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,lesson_id');

      await supabase.from(SupabaseConstants.tableProfiles).upsert({
        'id': user.id,
        'total_xp': newXp,
        'last_active_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update memory only if network succeeds
      final updatedLessonIds = Set<String>.from(current.completedLessonIds)..add(lessonId);
      _inMemoryProgress = current.copyWith(
        completedLessonIds: updatedLessonIds,
        totalXp: newXp,
        lastActiveDate: DateTime.now(),
      );
      return _inMemoryProgress!;
    } catch (e) {
      debugPrint('Network error completing lesson: $e');
      throw Exception('Network error: Action not saved. Check internet connection.');
    }
  }

  Future<UserProgress> completeChallenge({
    required String challengeId,
    required int points,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final current = getProgress();
    if (current.completedChallengeIds.contains(challengeId)) return current;
    final newXp = current.totalXp + points;

    try {
      await supabase.from(SupabaseConstants.tableCompletedChallenges).upsert({
        'user_id': user.id,
        'challenge_id': challengeId,
        'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,challenge_id');

      await supabase.from(SupabaseConstants.tableProfiles).upsert({
        'id': user.id,
        'total_xp': newXp,
        'last_active_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final updatedChallengeIds = Set<String>.from(current.completedChallengeIds)..add(challengeId);
      _inMemoryProgress = current.copyWith(
        completedChallengeIds: updatedChallengeIds,
        totalXp: newXp,
        lastActiveDate: DateTime.now(),
      );
      return _inMemoryProgress!;
    } catch (e) {
      throw Exception('Network error: Action not saved. Check internet connection.');
    }
  }

  Future<UserProgress> recordQuizCompletion({
    required String quizId,
    required int score,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final current = getProgress();
    final newXp = current.totalXp + score;

    try {
      await supabase.from(SupabaseConstants.tableCompletedQuizzes).upsert({
        'user_id': user.id,
        'quiz_id': quizId,
        'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,quiz_id');

      await supabase.from(SupabaseConstants.tableProfiles).upsert({
        'id': user.id,
        'total_xp': newXp,
        'last_active_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final updatedQuizIds = Set<String>.from(current.completedQuizIds)..add(quizId);
      _inMemoryProgress = current.copyWith(
        completedQuizIds: updatedQuizIds,
        totalXp: newXp,
        lastActiveDate: DateTime.now(),
      );
      return _inMemoryProgress!;
    } catch (e) {
      throw Exception('Network error: Action not saved. Check internet connection.');
    }
  }

  Future<void> resetProgress() async {
    _inMemoryProgress = null;
  }
}

