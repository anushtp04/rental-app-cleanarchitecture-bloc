part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSendOtpRequested extends AuthEvent {
  final String email;

  const AuthSendOtpRequested({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String token;

  const AuthVerifyOtpRequested({
    required this.email,
    required this.token,
  });

  @override
  List<Object> get props => [email, token];
}

class AuthLogoutRequested extends AuthEvent {}

