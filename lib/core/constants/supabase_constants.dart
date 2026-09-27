import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConstants {
  // Replace these credentials with your Supabase Project URL and Anon Key
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key',
  );

  // Table names
  static const String tableProfiles = 'profiles';
  static const String tableCompletedLessons = 'completed_lessons';
  static const String tableCompletedQuizzes = 'completed_quizzes';
  static const String tableCompletedChallenges = 'completed_challenges';
  static const String tableSavedSnippets = 'saved_snippets';
}

/// Global shortcut getter for Supabase Client
SupabaseClient get supabase => Supabase.instance.client;
