import 'dart:typed_data';
import '../entities/ets_entity.dart';
import '../repositories/ets_repository.dart';

/// Caso de uso para que profesores actualicen sus exámenes
/// Solo el profesor que creó el examen puede actualizarlo
class ActualizarExamenUseCase {
  final EtsRepository repository;

  ActualizarExamenUseCase(this.repository);

  Future<EtsEntity> call({
    required EtsEntity examen,
    required String profesorIdActual,
    bool isAdmin = false,
    Uint8List? pdfBytes,
    String? pdfFileName,
  }) async {
    // Validar que solo el profesor creador pueda actualizar, a menos que sea administrador
    if (!isAdmin && examen.profesorId != profesorIdActual) {
      throw Exception(
        'No tienes permisos para actualizar este examen. '
        'Solo el profesor que lo creó puede modificarlo.',
      );
    }

    // Validar que los datos básicos no estén vacíos
    if (examen.materia.trim().isEmpty) {
      throw Exception('La materia es requerida');
    }

    if (examen.salon.trim().isEmpty) {
      throw Exception('El salón es requerido');
    }

    if (examen.carrera.trim().isEmpty) {
      throw Exception('La carrera es requerida');
    }

    // Validar turno
    final turnosValidos = ['Mañana', 'Tarde', 'Noche'];
    if (!turnosValidos.contains(examen.turno)) {
      throw Exception('Turno inválido');
    }

    // Validar semestre
    if (examen.semestre < 1 || examen.semestre > 8) {
      throw Exception('Semestre debe estar entre 1 y 8');
    }

    // Actualizar el examen
    return await repository.actualizarExamen(
      examen,
      pdfBytes: pdfBytes,
      pdfFileName: pdfFileName,
    );
  }
}
