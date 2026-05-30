import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'create_user_event.dart';
import 'create_user_state.dart';

class CreateUserBloc extends Bloc<CreateUserEvent, CreateUserState> {
  final AuthRepository _authRepository;

  CreateUserBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const CreateUserInitial()) {
    on<CreateUserRequested>(_onCreateUserRequested);
    on<ResetCreateUserForm>(_onResetCreateUserForm);
  }

  Future<void> _onCreateUserRequested(
    CreateUserRequested event,
    Emitter<CreateUserState> emit,
  ) async {
    emit(const CreateUserLoading());

    try {
      // Validaciones
      if (event.email.isEmpty) {
        emit(const CreateUserError(message: 'El email es obligatorio'));
        return;
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(event.email)) {
        emit(const CreateUserError(message: 'Email inválido'));
        return;
      }

      if (event.password.length < 6) {
        emit(
          const CreateUserError(
            message: 'La contraseña debe tener al menos 6 caracteres',
          ),
        );
        return;
      }

      if (event.fullName.isEmpty) {
        emit(
          const CreateUserError(message: 'El nombre completo es obligatorio'),
        );
        return;
      }

      if (event.role.isEmpty) {
        emit(const CreateUserError(message: 'Debe seleccionar un rol'));
        return;
      }

      // Crear usuario
      await _authRepository.signup(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        role: event.role,
      );

      emit(
        CreateUserSuccess(
          message: 'Usuario creado exitosamente',
          userEmail: event.email,
        ),
      );
    } catch (e) {
      emit(CreateUserError(message: 'Error al crear usuario: $e'));
    }
  }

  Future<void> _onResetCreateUserForm(
    ResetCreateUserForm event,
    Emitter<CreateUserState> emit,
  ) async {
    emit(const CreateUserFormReset());
    emit(const CreateUserInitial());
  }
}
