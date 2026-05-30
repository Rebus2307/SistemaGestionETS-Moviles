import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: _parseRole(json['role'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': _roleToString(role),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static UserRole _parseRole(String roleString) {
    switch (roleString) {
      case 'alumno':
        return UserRole.alumno;
      case 'profesor_coordinador':
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
