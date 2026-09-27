import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/course.dart';
import '../data/models/progress.dart';
import '../data/datasources/static_courses.dart';
import 'supabase_sync_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyProgress = 'stored_user_progress_v2';
  static const String _keyOnboarded = 'has_seen_onboarding_v2';

  SharedPreferences? _prefs;
  final StaticCoursesDataSource _staticDataSource = StaticCoursesDataSource();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Preload courses into memory
    await _staticDataSource.getAllCourses();
  }

  // --- Onboarding status ---
  bool hasSeenOnboarding() {
    return _prefs?.getBool(_keyOnboarded) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool seen) async {
    await _prefs?.setBool(_keyOnboarded, seen);
  }

  // --- Static Courses Management ---
  Future<List<Course>> getCourses() async {
    return await _staticDataSource.getAllCourses();
  }

  Course? getCourseById(String id) {
    return _staticDataSource.getCourseById(id);
  }

  // --- User Progress Management ---
  UserProgress getProgress() {
    final rawJson = _prefs?.getString(_keyProgress);
    if (rawJson == null || rawJson.isEmpty) {
      return UserProgress(totalXp: 0, streakDays: 1);
    }
    try {
      return UserProgress.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
    } catch (_) {
      return UserProgress(totalXp: 0, streakDays: 1);
    }
  }

  Future<void> saveProgress(UserProgress progress) async {
    final encoded = jsonEncode(progress.toJson());
    await _prefs?.setString(_keyProgress, encoded);
  }

  Future<UserProgress> completeLesson({
    required String lessonId,
    int? xpEarned,
  }) async {
    final current = getProgress();
    final updatedLessonIds = Set<String>.from(current.completedLessonIds)..add(lessonId);
    final earned = xpEarned ?? 10;
    final newXp = current.totalXp + earned;

    final updated = current.copyWith(
      completedLessonIds: updatedLessonIds,
      totalXp: newXp,
      lastActiveDate: DateTime.now(),
    );
    await saveProgress(updated);
    
    // Sync to Supabase in real time
    SupabaseSyncService().recordLessonCompletion(lessonId, earned);
    return updated;
  }

  Future<UserProgress> completeChallenge({
    required String challengeId,
    required int points,
  }) async {
    final current = getProgress();
    if (current.completedChallengeIds.contains(challengeId)) {
      return current; // XP already awarded
    }

    final updatedChallengeIds = Set<String>.from(current.completedChallengeIds)..add(challengeId);
    final newXp = current.totalXp + points;

    final updated = current.copyWith(
      completedChallengeIds: updatedChallengeIds,
      totalXp: newXp,
      lastActiveDate: DateTime.now(),
    );
    await saveProgress(updated);

    // Sync to Supabase in real time
    SupabaseSyncService().syncLocalToCloud();
    return updated;
  }

  Future<UserProgress> recordQuizCompletion({
    required String quizId,
    required int score,
  }) async {
    final current = getProgress();
    final updatedQuizIds = Set<String>.from(current.completedQuizIds)..add(quizId);
    final newXp = current.totalXp + score;

    final updated = current.copyWith(
      completedQuizIds: updatedQuizIds,
      totalXp: newXp,
      lastActiveDate: DateTime.now(),
    );
    await saveProgress(updated);

    // Sync to Supabase in real time
    SupabaseSyncService().syncLocalToCloud();
    return updated;
  }

  Future<void> resetProgress() async {
    await _prefs?.remove(_keyProgress);
  }
}

