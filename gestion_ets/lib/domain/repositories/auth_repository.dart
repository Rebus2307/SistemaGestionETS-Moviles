import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Registra un nuevo usuario
  Future<UserEntity> signup({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  /// Intenta iniciar sesión con email y contraseña
  Future<UserEntity> login({required String email, required String password});

  /// Obtiene el usuario actual autenticado
  Future<UserEntity?> getCurrentUser();

  /// Cierra la sesión del usuario actual
  Future<void> logout();

  /// Verifica si hay una sesión activa
  Future<bool> isAuthenticated();

  /// Obtiene la lista completa de usuarios
  Future<List<UserEntity>> getAllUsers();

  /// Actualiza la información de un usuario
  Future<UserEntity> updateUser({
    required String id,
    required String fullName,
    required String email,
    required String role,
  });

  /// Elimina un usuario por su ID
  Future<void> deleteUser(String userId);
}
