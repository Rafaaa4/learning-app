import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? get currentUser => supabase.auth.currentUser;
  Session? get currentSession => supabase.auth.currentSession;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  /// Sign Up a new user with Email, Password, and Full Name
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
        },
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('Supabase SignUp AuthException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected SignUp error: $e');
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign In an existing user with Email and Password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('Supabase SignIn AuthException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected SignIn error: $e');
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Send password reset link to user's email
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      debugPrint('Supabase ResetPassword AuthException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected ResetPassword error: $e');
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Sign Out current user session
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
