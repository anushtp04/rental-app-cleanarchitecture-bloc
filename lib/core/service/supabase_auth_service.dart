import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Handle Supabase Auth exceptions
  String _handleAuthException(AuthException e) {
    switch (e.message.toLowerCase()) {
      case String msg when msg.contains('invalid login credentials'):
        return 'Invalid email or password.';
      case String msg when msg.contains('email not confirmed'):
        return 'Please verify your email address.';
      case String msg when msg.contains('user not found'):
        return 'No user found with this email.';
      case String msg when msg.contains('invalid email'):
        return 'Invalid email address.';
      case String msg when msg.contains('weak password'):
        return 'Password is too weak. Please use a stronger password.';
      case String msg when msg.contains('email already registered'):
        return 'An account with this email already exists.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
