import 'package:equatable/equatable.dart';

enum UserRole { alumno, profesorCoordinador, administrador }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, createdAt];

  // Métodos de ayuda para verificar rol
  bool get isAdmin => role == UserRole.administrador;
  bool get isProfesorCoordinador => role == UserRole.profesorCoordinador;
  bool get isAlumno => role == UserRole.alumno;
}
