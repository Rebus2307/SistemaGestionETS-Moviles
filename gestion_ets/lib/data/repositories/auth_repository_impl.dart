import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signup({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    return await remoteDataSource.signup(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }

  @override
  Future<bool> isAuthenticated() async {
    final user = await remoteDataSource.getCurrentUser();
    return user != null;
  }
}
