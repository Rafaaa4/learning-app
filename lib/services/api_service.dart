import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/course.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _customBaseUrl;

  void setBaseUrl(String url) {
    _customBaseUrl = url;
  }

  /// Optional backend API endpoint if connecting to remote server (Architecture Section 12)
  Future<Course?> fetchRemoteCourse(String courseId) async {
    if (_customBaseUrl == null) return null;
    try {
      final response = await http.get(Uri.parse('$_customBaseUrl/api/courses/$courseId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Course.fromJson(data);
      }
    } catch (_) {}
    return null;
  }
}
