import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.createdAt,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Si el id o el correo vienen nulos (imposible, pero por seguridad), ponemos ''
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',

      // Si no tiene nombre, ponemos 'Usuario' por defecto
      fullName: json['full_name'] as String? ?? 'Usuario',

      role: _parseRole(json['role'] as String? ?? 'alumno'),

      // Evitamos el crasheo de created_at poniéndole la fecha actual si viene nulo
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),

      // Aceptamos el nulo de la foto sin explotar
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': _roleToString(role),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }

  static UserRole _parseRole(String roleString) {
    switch (roleString) {
      case 'alumno':
        return UserRole.alumno;
      case 'profesor_coordinador':
      case 'profesor': // Agregado por si guardaste el rol solo como 'profesor'
        return UserRole.profesorCoordinador;
      case 'administrador':
        return UserRole.administrador;
      default:
        return UserRole.alumno;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.alumno:
        return 'alumno';
      case UserRole.profesorCoordinador:
        return 'profesor_coordinador';
      case UserRole.administrador:
        return 'administrador';
    }
  }
}
