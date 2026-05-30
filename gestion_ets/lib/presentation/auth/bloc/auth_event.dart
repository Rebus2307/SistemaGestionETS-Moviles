import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// --- EVENTOS DE LOGIN ---
class LoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginRequestedEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// --- EVENTOS DE SIGNUP ---
class SignUpRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String role;

  const SignUpRequestedEvent({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, fullName, role];
}

// --- EVENTOS DE LOGOUT ---
class LogoutRequestedEvent extends AuthEvent {}

// --- EVENTOS DE VERIFICACION DE SESION ---
class CheckSessionEvent extends AuthEvent {}
