import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signup({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  Future<UserModel> login({required String email, required String password});

  Future<UserModel?> getCurrentUser();

  Future<void> logout();

  Future<UserModel> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String role,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      // Crear usuario en auth de Supabase
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario');
      }

      // Crear perfil de usuario en tabla
      final userProfile = await createUserProfile(
        userId: authResponse.user!.id,
        email: email,
        fullName: fullName,
        role: role,
      );

      return userProfile;
    } on AuthException catch (e) {
      throw Exception('Error en registro: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Autenticar usuario
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Credenciales inválidas');
      }

      // Obtener perfil del usuario
      final userProfile = await _getUserProfile(authResponse.user!.id);

      return userProfile;
    } on AuthException catch (e) {
      throw Exception('Error en login: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      return await _getUserProfile(user.id);
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await supabase
          .from('users')
          .insert({
            'id': userId,
            'email': email,
            'full_name': fullName,
            'role': role,
          })
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('No se pudo crear el perfil de usuario');
      }

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al crear perfil: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<UserModel> _getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        throw Exception(
          'No se encontró un perfil para este usuario. Contacta al administrador.',
        );
      }

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener perfil: ${e.message}');
    }
  }
}
