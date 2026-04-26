import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    // Simulamos un retraso de red de 2 segundos para que puedas ver
    // la animación de carga (el circulito) en tu botón de Login.
    await Future.delayed(const Duration(seconds: 2));

    // Validación "quemada" (hardcoded) para nuestra simulación
    // Solo dejaremos pasar a este usuario
    if (username == 'admin' && password == '123456') {
      return true; // Login exitoso
    } else {
      return false; // Credenciales incorrectas
    }
  }

  @override
  Future<void> logout() async {
    // Pendiente: Lógica para borrar la sesión del caché cuando hagamos el botón de salir
  }

  @override
  Future<bool> checkSession() async {
    // Pendiente: Lógica para leer si el usuario ya había entrado antes
    return false;
  }
}
