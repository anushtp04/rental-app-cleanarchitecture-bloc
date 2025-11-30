import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../core/service/supabase_auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseAuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSendOtpRequested>(_onAuthSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onAuthVerifyOtpRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    // Listen to auth state changes
    _authService.authStateChanges.listen((supabase.AuthState authState) {
      if (authState.event == supabase.AuthChangeEvent.signedIn) {
        add(AuthCheckRequested());
      } else if (authState.event == supabase.AuthChangeEvent.signedOut) {
        add(AuthCheckRequested());
      }
    });
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    final user = _authService.currentUser;
    if (user != null) {
      final name = user.userMetadata?['name'] as String? ?? 'User';
      emit(AuthAuthenticated(
        userId: user.id,
        email: user.email ?? '',
        name: name,
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithOtp(email: event.email);
      emit(AuthOtpSent(email: event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authService.verifyOtp(
        email: event.email,
        token: event.token,
      );
      
      if (response.user != null) {
        final name = response.user!.userMetadata?['name'] as String? ?? 'User';
        emit(AuthAuthenticated(
          userId: response.user!.id,
          email: response.user!.email ?? '',
          name: name,
        ));
      } else {
        emit(const AuthError('Verification failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

