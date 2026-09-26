import 'package:flutter_test/flutter_test.dart';
import 'package:login/data/models/course.dart';
import 'package:login/data/models/challenge.dart';
import 'package:login/services/validation_service.dart';
import 'package:login/data/datasources/static_courses.dart';

void main() {
  group('Static Courses & Validation Engine Tests', () {
    test('JSON Schema Parsing works correctly', () {
      final sampleJson = {
        "course": {
          "id": "html-test",
          "title": "HTML Basics",
          "description": "Learn HTML",
          "level": "beginner",
          "estimated_hours": 10,
          "modules": [
            {
              "id": "mod-1",
              "title": "Module 1",
              "description": "Intro",
              "order": 1,
              "lessons": [
                {
                  "id": "les-1",
                  "title": "Lesson 1",
                  "order": 1,
                  "content": {
                    "explanation": "HTML is markup",
                    "examples": [
                      {"title": "Heading", "code": "<h1>Hello</h1>"}
                    ],
                    "key_points": ["h1 is heading"]
                  },
                  "challenge": {
                    "title": "First heading",
                    "description": "Create an h1",
                    "starter_code": "<!-- code -->",
                    "validation": {
                      "type": "html",
                      "rules": [
                        {"type": "element_exists", "element": "h1"},
                        {"type": "text_contains", "value": "Hello"}
                      ]
                    },
                    "solution": "<h1>Hello</h1>",
                    "hints": ["Use <h1>"],
                    "points": 10
                  },
                  "quiz": [
                    {
                      "question": "What is HTML?",
                      "options": ["Markup", "DB", "OS"],
                      "correct_answer": 0,
                      "points": 5
                    }
                  ]
                }
              ]
            }
          ]
        }
      };

      final course = Course.fromJson(sampleJson);
      expect(course.title, 'HTML Basics');
      expect(course.modules.length, 1);
      expect(course.totalLessons, 1);
      expect(course.totalChallenges, 1);
      expect(course.totalPoints, 15);
    });

    test('ValidationService verifies rules locally without network call', () {
      final challenge = Challenge(
        title: 'Heading Test',
        description: 'Test heading',
        starterCode: '',
        validation: ChallengeValidation(
          type: 'html',
          rules: [
            ValidationRule(type: 'element_exists', element: 'h1'),
            ValidationRule(type: 'text_contains', value: 'Hello'),
          ],
        ),
        solution: '<h1>Hello World</h1>',
        hints: ['Hint 1'],
        points: 10,
      );

      final service = ValidationService();

      // Passing case
      final passResult = service.validateChallenge(
        code: '<h1>Hello Flutter</h1>',
        challenge: challenge,
      );
      expect(passResult.isPassed, true);
      expect(passResult.ruleResults.length, 2);

      // Failing case
      final failResult = service.validateChallenge(
        code: '<p>Only a paragraph</p>',
        challenge: challenge,
      );
      expect(failResult.isPassed, false);
      expect(failResult.ruleResults.any((r) => !r.passed), true);
    });

    test('StaticCoursesDataSource loads real assets/data/courses.json', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final dataSource = StaticCoursesDataSource();
      final courses = await dataSource.getAllCourses();
      print('Loaded courses count: ${courses.length}');
      for (final c in courses) {
        print('Course: ${c.id} - ${c.title} (${c.modules.length} modules)');
      }
      expect(courses.length, greaterThanOrEqualTo(6));
    });
  });
}
