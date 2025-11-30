part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String email;

  const AuthOtpSent({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String name;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.name,
  });

  @override
  List<Object> get props => [userId, email, name];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

