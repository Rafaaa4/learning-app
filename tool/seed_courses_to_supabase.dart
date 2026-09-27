import 'dart:convert';
import 'dart:io';

/// Standalone Dart script to seed all courses from assets/data/courses.json
/// to a Supabase `courses_db` table via REST API.
///
/// Usage:
///   dart run tool/seed_courses_to_supabase.dart
///
/// Make sure to set your SUPABASE_URL and SUPABASE_ANON_KEY below (or env vars).

const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://bcyhuhnnokmssvcjibwd.supabase.co',
);

const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjeWh1aG5ub2ttc3N2Y2ppYndkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA0OTY3MDcsImV4cCI6MjEwNjA3MjcwN30.WNFJQSjy1TjA_7rkY_OL0AZCQ0K4RptDIia4AkYdS_Y',
);

Future<void> main() async {
  print('🚀 Learnpg — Supabase Course Seeder');
  print('=====================================');

  // 1. Validate credentials
  if (supabaseUrl.contains('YOUR_PROJECT') || supabaseAnonKey.contains('YOUR_ANON_KEY')) {
    print('\n❌ ERROR: Please set your Supabase credentials!');
    print('   Either:');
    print('   A) Edit this file and replace the defaultValue strings above.');
    print('   B) Run with env vars:');
    print('      SUPABASE_URL=https://xxx.supabase.co SUPABASE_ANON_KEY=eyJ... dart run tool/seed_courses_to_supabase.dart');
    exit(1);
  }

  // 2. Read local courses.json
  final jsonFile = File('assets/data/courses.json');
  if (!jsonFile.existsSync()) {
    print('\n❌ ERROR: assets/data/courses.json not found!');
    print('   Make sure you run this script from the project root directory.');
    exit(1);
  }

  print('\n📂 Reading assets/data/courses.json...');
  final rawJson = jsonFile.readAsStringSync();
  final decoded = jsonDecode(rawJson);

  final List<dynamic> coursesList;
  if (decoded is List) {
    coursesList = decoded;
  } else if (decoded is Map<String, dynamic>) {
    coursesList = [decoded];
  } else {
    print('❌ ERROR: Unexpected JSON format!');
    exit(1);
  }

  print('✅ Found ${coursesList.length} courses to seed.');

  // 3. Seed each course via Supabase REST API
  final httpClient = HttpClient();
  int seededCount = 0;
  int errorCount = 0;

  for (final course in coursesList) {
    final courseMap = course as Map<String, dynamic>;
    final courseId = courseMap['id'] as String;
    final courseTitle = courseMap['title'] as String;

    try {
      print('\n⬆️  Seeding: $courseTitle ($courseId)...');

      final payload = {
        'id': courseId,
        'title': courseTitle,
        'description': courseMap['description'],
        'level': courseMap['level'],
        'estimated_hours': courseMap['estimated_hours'],
        'language': courseMap['language'],
        'tags': courseMap['tags'],
        'modules': courseMap['modules'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      final uri = Uri.parse('$supabaseUrl/rest/v1/courses_db');
      final request = await httpClient.openUrl('POST', uri);

      request.headers.set('Content-Type', 'application/json');
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Authorization', 'Bearer $supabaseAnonKey');
      request.headers.set('Prefer', 'resolution=merge-duplicates,return=minimal');

      request.write(jsonEncode(payload));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        final modules = (courseMap['modules'] as List?)?.length ?? 0;
        final totalLessons = (courseMap['modules'] as List?)?.fold<int>(
          0, (sum, m) => sum + ((m as Map)['lessons'] as List?)!.length
        ) ?? 0;
        print('   ✅ Done! ($modules modules, $totalLessons lessons)');
        seededCount++;
      } else {
        print('   ⚠️  HTTP ${response.statusCode}: $responseBody');
        errorCount++;
      }
    } catch (e) {
      print('   ❌ Error seeding $courseId: $e');
      errorCount++;
    }
  }

  httpClient.close();

  print('\n=====================================');
  print('📊 Seeding Summary:');
  print('   ✅ Seeded: $seededCount / ${coursesList.length} courses');
  if (errorCount > 0) {
    print('   ❌ Errors: $errorCount courses failed');
  }
  print('\n🎉 All done! Your Supabase DB now has all Learnpg courses!');
}
