import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // --- Evento de Login ---
    on<LoginRequestedEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        // CORRECCIÓN: Quitamos el "final user =" porque no se utilizaba
        await authRepository.login(
          email: event.email,
          password: event.password,
        );

        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // --- Evento de Sign Up ---
    on<SignUpRequestedEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        await authRepository.signup(
          email: event.email,
          password: event.password,
          fullName: event.fullName,
          role: event.role,
        );

        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // --- Evento de Logout ---
    on<LogoutRequestedEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        await authRepository.logout();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // --- Evento de Verificar Sesión ---
    on<CheckSessionEvent>((event, emit) async {
      try {
        final isAuthenticated = await authRepository.isAuthenticated();

        if (isAuthenticated) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
