import 'module.dart';
import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String level; // beginner, intermediate, advanced
  final int estimatedHours;
  final String language;
  final List<CourseModule> modules;
  final List<String> tags;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.estimatedHours,
    this.language = 'English',
    required this.modules,
    this.tags = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Course.fromJson(Map<String, dynamic> rawJson) {
    // Support either wrapped {"course": {...}} or direct object
    final json = rawJson.containsKey('course') && rawJson['course'] is Map<String, dynamic>
        ? rawJson['course'] as Map<String, dynamic>
        : rawJson;

    return Course(
      id: json['id'] as String? ?? 'course-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Untitled Course',
      description: json['description'] as String? ?? '',
      level: (json['level'] as String? ?? 'beginner').toLowerCase(),
      estimatedHours: json['estimated_hours'] as int? ?? 10,
      language: json['language'] as String? ?? 'English',
      modules: (json['modules'] as List<dynamic>?)
              ?.map((m) => CourseModule.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool wrapCourse = false}) {
    final data = {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'estimated_hours': estimatedHours,
      'language': language,
      'modules': modules.map((m) => m.toJson()).toList(),
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
    if (wrapCourse) {
      return {'course': data};
    }
    return data;
  }

  int get totalLessons {
    int count = 0;
    for (final m in modules) {
      count += m.lessons.length;
    }
    return count;
  }

  int get totalChallenges {
    int count = 0;
    for (final m in modules) {
      for (final l in m.lessons) {
        if (l.challenge != null) count++;
      }
    }
    return count;
  }

  int get totalPoints {
    int total = 0;
    for (final m in modules) {
      total += m.totalPoints;
    }
    return total;
  }

  Lesson? findLesson(String lessonId) {
    for (final m in modules) {
      for (final l in m.lessons) {
        if (l.id == lessonId) return l;
      }
    }
    return null;
  }

  CourseModule? findModuleForLesson(String lessonId) {
    for (final m in modules) {
      for (final l in m.lessons) {
        if (l.id == lessonId) return m;
      }
    }
    return null;
  }
}
