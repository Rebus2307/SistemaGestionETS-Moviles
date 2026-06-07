import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class CrearExamenEvent extends Equatable {
  const CrearExamenEvent();

  @override
  List<Object?> get props => [];
}

class CrearExamenRequested extends CrearExamenEvent {
  final String materia;
  final DateTime fecha;
  final String turno;
  final String salon;
  final String carrera;
  final int semestre;
  final String profesorId;
  final String profesorNombre;
  final Uint8List? pdfBytes;
  final String? pdfFileName;

  const CrearExamenRequested({
    required this.materia,
    required this.fecha,
    required this.turno,
    required this.salon,
    required this.carrera,
    required this.semestre,
    required this.profesorId,
    required this.profesorNombre,
    this.pdfBytes,
    this.pdfFileName,
  });

  @override
  List<Object?> get props => [
    materia,
    fecha,
    turno,
    salon,
    carrera,
    semestre,
    profesorId,
    profesorNombre,
    pdfBytes,
    pdfFileName,
  ];
}

class ActualizarExamenRequested extends CrearExamenEvent {
  final String examenId;
  final String materia;
  final DateTime fecha;
  final String turno;
  final String salon;
  final String carrera;
  final int semestre;
  final String profesorId;
  final String profesorNombre;
  final String profesorIdActual;
  final bool isAdmin;
  final Uint8List? pdfBytes;
  final String? pdfFileName;

  const ActualizarExamenRequested({
    required this.examenId,
    required this.materia,
    required this.fecha,
    required this.turno,
    required this.salon,
    required this.carrera,
    required this.semestre,
    required this.profesorId,
    required this.profesorNombre,
    required this.profesorIdActual,
    this.isAdmin = false,
    this.pdfBytes,
    this.pdfFileName,
  });

  @override
  List<Object?> get props => [
    examenId,
    materia,
    fecha,
    turno,
    salon,
    carrera,
    semestre,
    profesorId,
    profesorNombre,
    profesorIdActual,
    isAdmin,
    pdfBytes,
    pdfFileName,
  ];
}

class ResetearFormulario extends CrearExamenEvent {
  const ResetearFormulario();
}
