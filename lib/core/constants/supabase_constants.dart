import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConstants {
  static const String supabaseUrl = 'https://bcyhuhnnokmssvcjibwd.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjeWh1aG5ub2ttc3N2Y2ppYndkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA0OTY3MDcsImV4cCI6MjEwNjA3MjcwN30.WNFJQSjy1TjA_7rkY_OL0AZCQ0K4RptDIia4AkYdS_Y';

  // Table names
  static const String tableProfiles = 'profiles';
  static const String tableCompletedLessons = 'completed_lessons';
  static const String tableCompletedQuizzes = 'completed_quizzes';
  static const String tableCompletedChallenges = 'completed_challenges';
  static const String tableSavedSnippets = 'saved_snippets';
}

/// Global shortcut getter for Supabase Client
SupabaseClient get supabase => Supabase.instance.client;
