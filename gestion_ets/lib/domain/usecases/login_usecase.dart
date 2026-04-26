import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  // Inyectamos el repositorio
  LoginUseCase(this.repository);

  Future<bool> call({
    required String username,
    required String password,
  }) async {
    // Aquí podríamos agregar lógica pura de negocio, por ejemplo:
    // Validar que la contraseña tenga al menos 6 caracteres antes de siquiera
    // intentar gastar datos de internet haciendo la petición.
    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres.');
    }

    return await repository.login(username: username, password: password);
  }
}
