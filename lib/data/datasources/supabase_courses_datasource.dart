import 'package:flutter/foundation.dart';
import '../../core/constants/supabase_constants.dart';
import '../models/course.dart';
import 'static_courses.dart';

class SupabaseCoursesDataSource {
  static final SupabaseCoursesDataSource _instance = SupabaseCoursesDataSource._internal();
  factory SupabaseCoursesDataSource() => _instance;
  SupabaseCoursesDataSource._internal();

  final StaticCoursesDataSource _staticDataSource = StaticCoursesDataSource();
  List<Course>? _cache;

  /// Fetch courses from Supabase DB `courses_db` with seamless offline asset fallback
  Future<List<Course>> getCourses() async {
    if (_cache != null && _cache!.isNotEmpty) {
      return _cache!;
    }

    try {
      final response = await supabase
          .from('courses_db')
          .select()
          .order('id', ascending: true);

      if (response != null && (response as List).isNotEmpty) {
        _cache = (response as List)
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();
        debugPrint('Successfully loaded ${_cache!.length} courses from Supabase DB!');
        return _cache!;
      }
    } catch (e) {
      debugPrint('Supabase courses fetch failed or table empty, falling back to local asset JSON: $e');
    }

    // Fallback to local asset JSON
    _cache = await _staticDataSource.getAllCourses();
    return _cache!;
  }

  Course? getCourseById(String id) {
    if (_cache == null) return null;
    try {
      return _cache!.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Automatically Seed/Migrate all local courses from JSON assets to Supabase DB `courses_db`
  Future<int> seedLocalCoursesToSupabase() async {
    final localCourses = await _staticDataSource.getAllCourses();
    int seededCount = 0;

    for (final course in localCourses) {
      try {
        final courseJson = course.toJson();
        await supabase.from('courses_db').upsert({
          'id': course.id,
          'title': course.title,
          'description': course.description,
          'level': course.level,
          'estimated_hours': course.estimatedHours,
          'language': course.language,
          'tags': course.tags,
          'modules': courseJson['modules'],
          'updated_at': DateTime.now().toIso8601String(),
        });
        seededCount++;
      } catch (e) {
        debugPrint('Error seeding course ${course.id} to Supabase: $e');
      }
    }

    // Clear in-memory cache to force refresh
    _cache = null;
    return seededCount;
  }
}
