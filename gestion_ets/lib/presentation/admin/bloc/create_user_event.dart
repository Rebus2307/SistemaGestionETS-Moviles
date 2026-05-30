import 'package:equatable/equatable.dart';

abstract class CreateUserEvent extends Equatable {
  const CreateUserEvent();

  @override
  List<Object> get props => [];
}

class CreateUserRequested extends CreateUserEvent {
  final String email;
  final String password;
  final String fullName;
  final String role;

  const CreateUserRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, fullName, role];
}

class ResetCreateUserForm extends CreateUserEvent {
  const ResetCreateUserForm();
}
