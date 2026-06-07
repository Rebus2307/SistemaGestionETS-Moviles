import 'package:equatable/equatable.dart';

class EtsEntity extends Equatable {
  final String id;
  final String materia;
  final DateTime fecha;
  final String turno;
  final String salon;
  final String profesorId; // UUID del profesor
  final String profesorNombre; // Nombre del profesor para mostrar en UI
  final String carrera;
  final int semestre;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pdfUrl; // URL del PDF opcional subido a Supabase

  const EtsEntity({
    required this.id,
    required this.materia,
    required this.fecha,
    required this.turno,
    required this.salon,
    required this.profesorId,
    required this.profesorNombre,
    required this.carrera,
    required this.semestre,
    required this.createdAt,
    required this.updatedAt,
    this.pdfUrl,
  });

  // Equatable nos ayuda a comparar objetos por sus valores y no por su espacio en memoria,
  // lo cual es vital para que BLoC sepa cuándo cambiar de estado.
  @override
  List<Object?> get props => [
    id,
    materia,
    fecha,
    turno,
    salon,
    profesorId,
    profesorNombre,
    carrera,
    semestre,
    createdAt,
    updatedAt,
    pdfUrl,
  ];
}
