import 'package:equatable/equatable.dart';

enum UserRole { alumno, profesorCoordinador, administrador }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final DateTime? createdAt; // Lo hacemos opcional por si la BD no lo envía
  final String? avatarUrl; // NUEVO: Campo opcional para la foto de perfil

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.createdAt,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, createdAt, avatarUrl];

  // Métodos de ayuda para verificar rol
  bool get isAdmin => role == UserRole.administrador;
  bool get isProfesorCoordinador => role == UserRole.profesorCoordinador;
  bool get isAlumno => role == UserRole.alumno;
}
