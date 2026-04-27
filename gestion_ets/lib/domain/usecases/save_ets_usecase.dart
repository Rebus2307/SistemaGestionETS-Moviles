import '../entities/ets_entity.dart';
import '../repositories/ets_repository.dart';

class SaveEtsUseCase {
  final EtsRepository repository;

  SaveEtsUseCase(this.repository);

  Future<void> call(EtsEntity ets) async {
    // Regla de negocio pura: Validar que la fecha no sea en el pasado
    // (Le restamos un día para permitir agendar exámenes para "hoy")
    final hoy = DateTime.now().subtract(const Duration(days: 1));
    if (ets.fecha.isBefore(hoy)) {
      throw Exception('No puedes agendar un ETS en una fecha que ya pasó.');
    }

    // Regla de negocio: Validar campos vacíos
    if (ets.materia.isEmpty || ets.salon.isEmpty || ets.profesor.isEmpty) {
      throw Exception('Todos los campos de texto son obligatorios.');
    }

    await repository.saveEts(ets);
  }
}
