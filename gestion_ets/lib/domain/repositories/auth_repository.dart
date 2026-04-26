abstract class AuthRepository {
  /// Intenta iniciar sesión con un usuario y contraseña.
  Future<bool> login({required String username, required String password});

  /// Cierra la sesión del usuario actual.
  Future<void> logout();

  /// Verifica si hay una sesión activa guardada en el dispositivo.
  Future<bool> checkSession();
}
