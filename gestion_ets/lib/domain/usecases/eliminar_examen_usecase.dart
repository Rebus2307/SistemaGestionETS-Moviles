import '../repositories/ets_repository.dart';

/// Caso de uso para que profesores eliminen sus exámenes
/// Solo el profesor que creó el examen puede eliminarlo
class EliminarExamenUseCase {
  final EtsRepository repository;

  EliminarExamenUseCase(this.repository);

  Future<void> call({
    required String examenId,
    required String profesorIdActual,
    required String profesorIdDelExamen,
  }) async {
    // Validar que solo el profesor creador pueda eliminar
    if (profesorIdDelExamen != profesorIdActual) {
      throw Exception(
        'No tienes permisos para eliminar este examen. '
        'Solo el profesor que lo creó puede eliminarlo.',
      );
    }

    // Eliminar el examen
    await repository.eliminarExamen(examenId);
  }
}
