import '../entities/ets_entity.dart';

abstract class EtsRepository {
  // Definimos la regla: Cualquier clase que implemente esto DEBE poder devolver una lista de ETS
  // y permitir filtros opcionales (como pide el PDF).
  Future<List<EtsEntity>> getExamenes({
    String? carrera,
    String? semestre,
    String? materia,
  });

  // Regla para el módulo administrativo / caché local
  Future<void> guardarEtsFavorito(EtsEntity ets);

  /// Guarda un nuevo ETS o actualiza uno existente
  Future<void> saveEts(EtsEntity ets);

  /// Elimina un ETS usando su identificador único (ID)
  Future<void> deleteEts(String id);
}
