import 'package:equatable/equatable.dart';

abstract class CreateUserState extends Equatable {
  const CreateUserState();

  @override
  List<Object> get props => [];
}

class CreateUserInitial extends CreateUserState {
  const CreateUserInitial();
}

class CreateUserLoading extends CreateUserState {
  const CreateUserLoading();
}

class CreateUserSuccess extends CreateUserState {
  final String message;
  final String userEmail;

  const CreateUserSuccess({required this.message, required this.userEmail});

  @override
  List<Object> get props => [message, userEmail];
}

class CreateUserError extends CreateUserState {
  final String message;

  const CreateUserError({required this.message});

  @override
  List<Object> get props => [message];
}

class CreateUserFormReset extends CreateUserState {
  const CreateUserFormReset();
}
