import 'challenge.dart';
import 'quiz.dart';

class CodeExample {
  final String title;
  final String code;
  final String? explanation;

  CodeExample({
    required this.title,
    required this.code,
    this.explanation,
  });

  factory CodeExample.fromJson(Map<String, dynamic> json) {
    return CodeExample(
      title: json['title'] as String? ?? 'Example',
      code: json['code'] as String? ?? '',
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'code': code,
      if (explanation != null) 'explanation': explanation,
    };
  }
}

class LessonContent {
  final String explanation;
  final List<CodeExample> examples;
  final List<String> keyPoints;

  LessonContent({
    required this.explanation,
    required this.examples,
    this.keyPoints = const [],
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      explanation: json['explanation'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => CodeExample.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      keyPoints: (json['key_points'] as List<dynamic>?)
              ?.map((k) => k.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'explanation': explanation,
      'examples': examples.map((e) => e.toJson()).toList(),
      'key_points': keyPoints,
    };
  }
}

class Lesson {
  final String id;
  final String title;
  final int order;
  final LessonContent content;
  final Challenge? challenge;
  final List<QuizQuestion> quiz;

  Lesson({
    required this.id,
    required this.title,
    required this.order,
    required this.content,
    this.challenge,
    this.quiz = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String? ?? 'lesson-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Untitled Lesson',
      order: json['order'] as int? ?? 1,
      content: json['content'] != null
          ? LessonContent.fromJson(json['content'] as Map<String, dynamic>)
          : LessonContent(explanation: '', examples: []),
      challenge: json['challenge'] != null
          ? Challenge.fromJson(json['challenge'] as Map<String, dynamic>)
          : null,
      quiz: (json['quiz'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'order': order,
      'content': content.toJson(),
      if (challenge != null) 'challenge': challenge!.toJson(),
      'quiz': quiz.map((q) => q.toJson()).toList(),
    };
  }
}
