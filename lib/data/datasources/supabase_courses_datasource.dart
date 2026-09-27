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

  /// Fetch courses from Supabase DB `courses_db` (Network Only)
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
      } else {
        throw Exception('No courses found in database.');
      }
    } catch (e) {
      debugPrint('Supabase courses fetch failed: $e');
      throw Exception('Network error: Could not fetch courses from Supabase. Please check your internet connection.');
    }
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

  /// Fetch video courses from Supabase `video_courses` table with static fallback
  Future<List<Map<String, dynamic>>> getVideoCourses() async {
    try {
      final response = await supabase
          .from('video_courses')
          .select()
          .order('id', ascending: true);

      if (response != null && (response as List).isNotEmpty) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      debugPrint('Supabase video courses fetch fallback to static: $e');
    }
    return defaultVideoCourses;
  }
}

final List<Map<String, dynamic>> defaultVideoCourses = [
  // ── HTML ──────────────────────────────────────────────────────────────
  {
    'title': 'HTML Full Course – Build a Website Tutorial',
    'duration': '2:02:30',
    'youtubeId': 'pQN-pnXPaVg',
    'author': 'freeCodeCamp.org',
    'category': 'HTML',
    'views': '6.5M',
  },
  {
    'title': 'HTML Crash Course For Absolute Beginners',
    'duration': '1:00:40',
    'youtubeId': 'UB1O30fR-EE',
    'author': 'Traversy Media',
    'category': 'HTML',
    'views': '4.1M',
  },
  {
    'title': 'Learn HTML – Full Tutorial for Beginners',
    'duration': '4:08:03',
    'youtubeId': 'kUMe1FH4CHE',
    'author': 'freeCodeCamp.org',
    'category': 'HTML',
    'views': '3.2M',
  },
  {
    'title': 'HTML Forms & Input Fields – Complete Guide',
    'duration': '31:14',
    'youtubeId': 'fNcJuPIZ2WE',
    'author': 'Traversy Media',
    'category': 'HTML',
    'views': '520K',
  },
  // ── CSS ──────────────────────────────────────────────────────────────
  {
    'title': 'CSS Full Course – Includes Flexbox and CSS Grid',
    'duration': '11:29:00',
    'youtubeId': 'ieTHC78giGQ',
    'author': 'freeCodeCamp.org',
    'category': 'CSS',
    'views': '2.8M',
  },
  {
    'title': 'CSS Crash Course For Absolute Beginners',
    'duration': '1:25:21',
    'youtubeId': 'yfoY53QXEnI',
    'author': 'Traversy Media',
    'category': 'CSS',
    'views': '3.6M',
  },
  {
    'title': 'Flexbox CSS In 20 Minutes',
    'duration': '20:05',
    'youtubeId': 'JJSoEo8JSnc',
    'author': 'Traversy Media',
    'category': 'CSS',
    'views': '2.3M',
  },
  {
    'title': 'CSS Grid Layout Crash Course',
    'duration': '28:03',
    'youtubeId': 'jV8B24rSN5o',
    'author': 'Traversy Media',
    'category': 'CSS',
    'views': '1.1M',
  },
  {
    'title': 'CSS Animation Tutorial',
    'duration': '51:30',
    'youtubeId': 'jgw82b5Y2MU',
    'author': 'Kevin Powell',
    'category': 'CSS',
    'views': '780K',
  },
  // ── JavaScript ────────────────────────────────────────────────────────
  {
    'title': 'JavaScript Full Course for Beginners',
    'duration': '7:04:13',
    'youtubeId': 'lfmg-EJ8gm4',
    'author': 'freeCodeCamp.org',
    'category': 'JavaScript',
    'views': '5.4M',
  },
  {
    'title': 'JavaScript Crash Course For Beginners',
    'duration': '1:40:30',
    'youtubeId': 'hdI2bqOjy3c',
    'author': 'Traversy Media',
    'category': 'JavaScript',
    'views': '5.1M',
  },
  {
    'title': 'JavaScript DOM Manipulation – Full Course',
    'duration': '5:07:01',
    'youtubeId': '5fb2aPlgoys',
    'author': 'freeCodeCamp.org',
    'category': 'JavaScript',
    'views': '1.2M',
  },
  {
    'title': 'Async JavaScript – From Callbacks to Async/Await',
    'duration': '24:31',
    'youtubeId': 'PoRJizFvM7s',
    'author': 'Traversy Media',
    'category': 'JavaScript',
    'views': '1.8M',
  },
  {
    'title': 'JavaScript ES6+ Modern Features',
    'duration': '30:27',
    'youtubeId': 'NCwa_xi0Uuc',
    'author': 'Traversy Media',
    'category': 'JavaScript',
    'views': '960K',
  },
  {
    'title': 'Fetch API & REST – JavaScript for Beginners',
    'duration': '21:15',
    'youtubeId': 'cuEtnrL9-H0',
    'author': 'Traversy Media',
    'category': 'JavaScript',
    'views': '740K',
  },
  // ── Python ───────────────────────────────────────────────────────────
  {
    'title': 'Python for Beginners – Full Course',
    'duration': '6:14:07',
    'youtubeId': 'eWRyvpTDRog',
    'author': 'freeCodeCamp.org',
    'category': 'Python',
    'views': '4.1M',
  },
  {
    'title': 'Python Crash Course For Beginners',
    'duration': '1:33:39',
    'youtubeId': 'JJmcL1N2KQs',
    'author': 'Traversy Media',
    'category': 'Python',
    'views': '2.7M',
  },
  {
    'title': 'Python OOP Tutorial – Classes and Objects',
    'duration': '1:06:25',
    'youtubeId': 'ZDa-Z5JzLYM',
    'author': 'Corey Schafer',
    'category': 'Python',
    'views': '3.5M',
  },
  {
    'title': 'Python Functions – Complete Guide',
    'duration': '42:30',
    'youtubeId': '9Os0o3wzS_I',
    'author': 'freeCodeCamp.org',
    'category': 'Python',
    'views': '1.2M',
  },
  // ── C ─────────────────────────────────────────────────────────────
  {
    'title': 'C Programming Full Course for Beginners',
    'duration': '3:46:13',
    'youtubeId': 'aZb0iu4uGwA',
    'author': 'freeCodeCamp.org',
    'category': 'C',
    'views': '2.9M',
  },
  {
    'title': 'C Programming Tutorial for Beginners',
    'duration': '3:46:13',
    'youtubeId': 'KJgsSFOSQv0',
    'author': 'Mike Dane',
    'category': 'C',
    'views': '4.3M',
  },
  {
    'title': 'Pointers in C – Full Guide',
    'duration': '1:02:32',
    'youtubeId': 'zuegQmMdy8M',
    'author': 'freeCodeCamp.org',
    'category': 'C',
    'views': '1.5M',
  },
  // ── C++ ─────────────────────────────────────────────────────────────
  {
    'title': 'C++ Programming Course – Beginner to Advanced',
    'duration': '31:36:32',
    'youtubeId': '8jLOx1hD3_o',
    'author': 'freeCodeCamp.org',
    'category': 'C++',
    'views': '4.2M',
  },
  {
    'title': 'C++ Tutorial for Beginners',
    'duration': '4:01:29',
    'youtubeId': 'vLnPwxZdW4Y',
    'author': 'Mike Dane',
    'category': 'C++',
    'views': '5.1M',
  },
  {
    'title': 'C++ OOP – Object Oriented Programming',
    'duration': '1:40:15',
    'youtubeId': 'wN0x9eZLix4',
    'author': 'freeCodeCamp.org',
    'category': 'C++',
    'views': '2.3M',
  },
  // ── C# ─────────────────────────────────────────────────────────────
  {
    'title': 'C# Tutorial – Full Course for Beginners',
    'duration': '4:31:09',
    'youtubeId': 'GhQdlIFylQ8',
    'author': 'freeCodeCamp.org',
    'category': 'C#',
    'views': '3.8M',
  },
  {
    'title': 'C# Basics for Beginners – Learn C# Fundamentals',
    'duration': '5:22:00',
    'youtubeId': 'gfkTfcpWqAY',
    'author': 'Programming with Mosh',
    'category': 'C#',
    'views': '4.1M',
  },
  {
    'title': 'C# Object Oriented Programming – Full Course',
    'duration': '3:18:00',
    'youtubeId': 'pMmPzuS4MxE',
    'author': 'freeCodeCamp.org',
    'category': 'C#',
    'views': '1.6M',
  },
  // ── MySQL ─────────────────────────────────────────────────────────────
  {
    'title': 'MySQL – The Full Course',
    'duration': '3:10:00',
    'youtubeId': 'HXV3zeQKqGY',
    'author': 'freeCodeCamp.org',
    'category': 'MySQL',
    'views': '1.7M',
  },
  {
    'title': 'MySQL Crash Course – Learn SQL in One Hour',
    'duration': '1:05:00',
    'youtubeId': 'p3qvj9hO_Bo',
    'author': 'Traversy Media',
    'category': 'MySQL',
    'views': '2.1M',
  },
  {
    'title': 'SQL Joins – Complete Guide',
    'duration': '27:00',
    'youtubeId': '9yeOJ0ZMUYw',
    'author': 'Caleb Curry',
    'category': 'MySQL',
    'views': '890K',
  },
  {
    'title': 'Database Design Course – Full Tutorial',
    'duration': '8:10:00',
    'youtubeId': 'ztHopE5Wnpc',
    'author': 'freeCodeCamp.org',
    'category': 'MySQL',
    'views': '1.3M',
  },
];
}
