import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course.dart';

class StaticCoursesDataSource {
  static final StaticCoursesDataSource _instance = StaticCoursesDataSource._internal();
  factory StaticCoursesDataSource() => _instance;
  StaticCoursesDataSource._internal();

  List<Course>? _cachedCourses;

  /// Loads all courses from assets/data/courses.json with graceful in-memory fallback
  Future<List<Course>> getAllCourses() async {
    if (_cachedCourses != null && _cachedCourses!.isNotEmpty) {
      return _cachedCourses!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/courses.json');
      final decoded = jsonDecode(jsonString);

      // Support both: a JSON array [...] or a single course object {...}
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        list = [decoded]; // single course → wrap in list
      } else {
        throw FormatException('Unexpected JSON format');
      }

      _cachedCourses = list
          .map((item) => Course.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cachedCourses!;
    } catch (_) {
      // Fallback in-memory definition to guarantee 100% zero-crash operation
      _cachedCourses = _buildDefaultCourses();
      return _cachedCourses!;
    }
  }

  Course? getCourseById(String id) {
    if (_cachedCourses == null) return null;
    try {
      return _cachedCourses!.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Course> _buildDefaultCourses() {
    // In-memory fallback dataset
    return [
      Course.fromJson({
        "id": "html-css-js-complete",
        "title": "HTML, CSS & JavaScript",
        "description": "Master modern web development from zero. Build layouts, style pages, and write interactive JavaScript code.",
        "level": "beginner",
        "estimated_hours": 25,
        "language": "English",
        "tags": ["Web", "Frontend", "HTML", "CSS", "JavaScript"],
        "modules": [
          {
            "id": "html-foundations",
            "title": "HTML Foundations & Structure",
            "description": "Learn the essential tags and layout building blocks of web pages",
            "order": 1,
            "lessons": [
              {
                "id": "html-headings",
                "title": "Introduction & Headings",
                "order": 1,
                "content": {
                  "explanation": "HTML (HyperText Markup Language) defines the structure of every webpage. Headings range from <h1> to <h6>, with <h1> being the most important heading on a page.",
                  "examples": [
                    {
                      "title": "Primary Heading",
                      "code": "<h1>Welcome to Web Development</h1>",
                      "explanation": "Defines the main title of your web page."
                    }
                  ],
                  "key_points": [
                    "HTML elements are defined using tags with opening <tag> and closing </tag>",
                    "<h1> is used for the main topic of the document",
                    "Keep only one <h1> per page for optimal structure and SEO"
                  ]
                },
                "challenge": {
                  "title": "Create your first <h1> heading",
                  "description": "Create an <h1> heading tag containing the text 'Hello World'.",
                  "starter_code": "<!-- Write your HTML code below -->\n",
                  "validation": {
                    "type": "html",
                    "rules": [
                      {
                        "type": "element_exists",
                        "element": "h1",
                        "description": "Must have an <h1> element"
                      },
                      {
                        "type": "text_contains",
                        "value": "Hello World",
                        "description": "Must contain text 'Hello World'"
                      }
                    ]
                  },
                  "solution": "<h1>Hello World</h1>",
                  "hints": ["Start with <h1> and close with </h1>"],
                  "points": 15
                },
                "quiz": [
                  {
                    "question": "What does HTML stand for?",
                    "options": [
                      "HyperText Markup Language",
                      "HighText Machine Language",
                      "Hyper Tool Multi Language",
                      "Home Terminal Markup Logic"
                    ],
                    "correct_answer": 0,
                    "explanation": "HTML stands for HyperText Markup Language.",
                    "points": 5
                  }
                ]
              }
            ]
          }
        ]
      })
    ];
  }
}
