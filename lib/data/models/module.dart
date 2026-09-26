import 'lesson.dart';

class CourseModule {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] as String? ?? 'module-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Module',
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 1,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  int get totalPoints {
    int total = 0;
    for (final lesson in lessons) {
      if (lesson.challenge != null) {
        total += lesson.challenge!.points;
      }
      for (final q in lesson.quiz) {
        total += q.points;
      }
    }
    return total;
  }
}
