import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginRequestedEvent>((event, emit) async {
      // 1. Avisamos a la UI que muestre un indicador de carga
      emit(AuthLoading());

      try {
        // 2. Ejecutamos el caso de uso
        final isSuccess = await loginUseCase(
          username: event.username,
          password: event.password,
        );

        // 3. Emitimos el estado correspondiente según el resultado
        if (isSuccess) {
          emit(AuthAuthenticated());
        } else {
          emit(const AuthError('Credenciales incorrectas'));
        }
      } catch (e) {
        // En caso de que nuestra validación falle (ej. contraseña muy corta)
        // Limpiamos el texto de la excepción para que sea amigable en la UI
        emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // Pendiente: Implementar on<LogoutRequestedEvent> y on<CheckSessionEvent>
  }
}
