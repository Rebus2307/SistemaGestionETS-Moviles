import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequestedEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginRequestedEvent({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class LogoutRequestedEvent extends AuthEvent {}

class CheckSessionEvent extends AuthEvent {}
