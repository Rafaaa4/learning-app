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

  /// Sync local storage data up to Supabase cloud (Now purely network initialization)
  Future<void> syncLocalToCloud() async {
    // We no longer sync local data up. We just fetch from cloud.
    // This is called on signup usually.
    await _storageService.fetchProgressFromCloud();
  }

  /// Sync cloud data down to local storage upon login
  Future<UserProgress> syncCloudToLocal() async {
    await _storageService.fetchProgressFromCloud();
    return _storageService.getProgress();
  }

  /// Record completed lesson in real time to Supabase
  Future<void> recordLessonCompletion(String lessonId, int xp) async {
    await _storageService.completeLesson(lessonId: lessonId, xpEarned: xp);
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
