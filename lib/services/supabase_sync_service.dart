import 'package:flutter/foundation.dart';
import '../core/constants/supabase_constants.dart';
import '../data/models/progress.dart';
import 'storage_service.dart';
import 'auth_service.dart';

class SupabaseSyncService {
  static final SupabaseSyncService _instance = SupabaseSyncService._internal();
  factory SupabaseSyncService() => _instance;
  SupabaseSyncService._internal();

  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  /// Sync local storage data up to Supabase cloud
  Future<void> syncLocalToCloud() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final localProgress = _storageService.getProgress();

      // 1. Update Profile summary metrics
      await supabase.from(SupabaseConstants.tableProfiles).upsert({
        'id': user.id,
        'total_xp': localProgress.totalXp,
        'streak_days': localProgress.streakDays,
        'last_active_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Sync Completed Lessons
      for (final lessonId in localProgress.completedLessonIds) {
        await supabase.from(SupabaseConstants.tableCompletedLessons).upsert({
          'user_id': user.id,
          'lesson_id': lessonId,
          'completed_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,lesson_id');
      }

      // 3. Sync Completed Quizzes
      for (final quizId in localProgress.completedQuizIds) {
        await supabase.from(SupabaseConstants.tableCompletedQuizzes).upsert({
          'user_id': user.id,
          'quiz_id': quizId,
          'completed_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,quiz_id');
      }

      // 4. Sync Completed Challenges
      for (final challengeId in localProgress.completedChallengeIds) {
        await supabase.from(SupabaseConstants.tableCompletedChallenges).upsert({
          'user_id': user.id,
          'challenge_id': challengeId,
          'completed_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,challenge_id');
      }

      debugPrint('Successfully synced local data to Supabase cloud!');
    } catch (e) {
      debugPrint('Error syncing local data to cloud: $e');
    }
  }

  /// Sync cloud data down to local storage upon login
  Future<UserProgress> syncCloudToLocal() async {
    final user = _authService.currentUser;
    if (user == null) return _storageService.getProgress();

    try {
      // 1. Fetch Profile
      final profileRes = await supabase
          .from(SupabaseConstants.tableProfiles)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      int cloudXp = 0;
      int cloudStreak = 1;

      if (profileRes != null) {
        cloudXp = (profileRes['total_xp'] as int?) ?? 0;
        cloudStreak = (profileRes['streak_days'] as int?) ?? 1;
      }

      // 2. Fetch Completed Lessons
      final lessonsRes = await supabase
          .from(SupabaseConstants.tableCompletedLessons)
          .select('lesson_id')
          .eq('user_id', user.id);

      final cloudLessonIds = (lessonsRes as List)
          .map((row) => row['lesson_id'].toString())
          .toSet();

      // 3. Fetch Completed Quizzes
      final quizzesRes = await supabase
          .from(SupabaseConstants.tableCompletedQuizzes)
          .select('quiz_id')
          .eq('user_id', user.id);

      final cloudQuizIds = (quizzesRes as List)
          .map((row) => row['quiz_id'].toString())
          .toSet();

      // 4. Fetch Completed Challenges
      final challengesRes = await supabase
          .from(SupabaseConstants.tableCompletedChallenges)
          .select('challenge_id')
          .eq('user_id', user.id);

      final cloudChallengeIds = (challengesRes as List)
          .map((row) => row['challenge_id'].toString())
          .toSet();

      // Merge local & cloud
      final localProgress = _storageService.getProgress();
      final mergedLessonIds = Set<String>.from(localProgress.completedLessonIds)
        ..addAll(cloudLessonIds);
      final mergedQuizIds = Set<String>.from(localProgress.completedQuizIds)
        ..addAll(cloudQuizIds);
      final mergedChallengeIds = Set<String>.from(localProgress.completedChallengeIds)
        ..addAll(cloudChallengeIds);

      final mergedProgress = UserProgress(
        completedLessonIds: mergedLessonIds,
        completedQuizIds: mergedQuizIds,
        completedChallengeIds: mergedChallengeIds,
        totalXp: localProgress.totalXp > cloudXp ? localProgress.totalXp : cloudXp,
        streakDays: localProgress.streakDays > cloudStreak ? localProgress.streakDays : cloudStreak,
        lastActiveDate: DateTime.now(),
      );

      await _storageService.saveProgress(mergedProgress);
      return mergedProgress;
    } catch (e) {
      debugPrint('Error syncing cloud to local: $e');
      return _storageService.getProgress();
    }
  }

  /// Record completed lesson in real time to Supabase
  Future<void> recordLessonCompletion(String lessonId, int xp) async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      await supabase.from(SupabaseConstants.tableCompletedLessons).upsert({
        'user_id': user.id,
        'lesson_id': lessonId,
        'xp_earned': xp,
        'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,lesson_id');

      // Update XP in profile
      final currentProgress = _storageService.getProgress();
      await supabase.from(SupabaseConstants.tableProfiles).upsert({
        'id': user.id,
        'total_xp': currentProgress.totalXp,
        'last_active_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error recording lesson completion on Supabase: $e');
    }
  }

  /// Save code snippet to Supabase cloud
  Future<bool> saveSnippet({
    required String title,
    required String language,
    required String code,
  }) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      await supabase.from(SupabaseConstants.tableSavedSnippets).insert({
        'user_id': user.id,
        'title': title,
        'language': language,
        'code': code,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving snippet to Supabase: $e');
      return false;
    }
  }
}
