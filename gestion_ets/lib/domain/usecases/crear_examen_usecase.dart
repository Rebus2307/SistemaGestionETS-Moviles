import 'dart:typed_data';
import '../entities/ets_entity.dart';
import '../repositories/ets_repository.dart';

/// Caso de uso para que profesores creen nuevos exámenes
/// Solo profesores coordinadores y administradores pueden crear exámenes
class CrearExamenUseCase {
  final EtsRepository repository;

  CrearExamenUseCase(this.repository);

  Future<EtsEntity> call({
    required String materia,
    required DateTime fecha,
    required String turno,
    required String salon,
    required String carrera,
    required int semestre,
    required String profesorId,
    required String profesorNombre,
    Uint8List? pdfBytes,
    String? pdfFileName,
  }) async {
    // Validar turno válido
    final turnosValidos = ['Mañana', 'Tarde', 'Noche'];
    if (!turnosValidos.contains(turno)) {
      throw Exception('Turno inválido. Debe ser: Mañana, Tarde o Noche');
    }

    // Validar semestre entre 1-8
    if (semestre < 1 || semestre > 8) {
      throw Exception('Semestre debe estar entre 1 y 8');
    }

    // Validar que no sea fecha anterior a hoy
    if (fecha.isBefore(DateTime.now().subtract(const Duration(hours: 1)))) {
      throw Exception('La fecha del examen no puede ser anterior a hoy');
    }

    // Validar que la materia no esté vacía
    if (materia.trim().isEmpty) {
      throw Exception('La materia es requerida');
    }

    // Validar que el salón no esté vacío
    if (salon.trim().isEmpty) {
      throw Exception('El salón es requerido');
    }

    // Validar que la carrera no esté vacía
    if (carrera.trim().isEmpty) {
      throw Exception('La carrera es requerida');
    }

    // Crear el examen
    return await repository.crearExamen(
      materia: materia,
      fecha: fecha,
      turno: turno,
      salon: salon,
      carrera: carrera,
      semestre: semestre,
      profesorId: profesorId,
      profesorNombre: profesorNombre,
      pdfBytes: pdfBytes,
      pdfFileName: pdfFileName,
    );
  }
}
