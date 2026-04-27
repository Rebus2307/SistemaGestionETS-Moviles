import '../../domain/entities/ets_entity.dart';
import '../../domain/repositories/ets_repository.dart';
import '../datasources/ets_remote_data_source.dart';
import '../datasources/ets_local_data_source.dart';
import '../models/ets_model.dart';

class EtsRepositoryImpl implements EtsRepository {
  final EtsRemoteDataSource remoteDataSource;
  final EtsLocalDataSource localDataSource;

  EtsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<EtsEntity>> getExamenes({
    String? carrera,
    String? semestre,
    String? materia,
  }) async {
    try {
      // 1. Intentamos obtener datos frescos de la API
      final modelos = await remoteDataSource.getExamenesDesdeApi(
        carrera: carrera,
        semestre: semestre,
        materia: materia,
      );

      // 2. Si es exitoso, actualizamos la caché local
      await localDataSource.cacheExamenes(modelos);
      return modelos;
    } catch (e) {
      // 3. Si falla (no hay internet o error 500), recurrimos a la caché "Offline-first"
      try {
        final localModelos = await localDataSource.getCachedExamenes();
        return localModelos;
      } catch (cacheError) {
        throw Exception('Error de red y no hay datos guardados localmente.');
      }
    }
  }

  @override
  Future<void> guardarEtsFavorito(EtsEntity ets) async {
    // Convertimos la entidad a modelo para poder guardarla
    final modelo = EtsModel(
      id: ets.id,
      materia: ets.materia,
      fecha: ets.fecha,
      turno: ets.turno,
      salon: ets.salon,
      profesor: ets.profesor,
    );
    await localDataSource.guardarEtsFavorito(modelo);
  }

  // --- NUEVOS MÉTODOS DEL CRUD ADMINISTRATIVO ---

  @override
  Future<void> saveEts(EtsEntity ets) async {
    // Simulamos un tiempo de espera de red (como si guardáramos en una API)
    await Future.delayed(const Duration(seconds: 1));

    // Aquí es donde en el futuro llamarías a tu Data Source:
    // await remoteDataSource.saveEts(modelo);
  }

  @override
  Future<void> deleteEts(String id) async {
    // Simulamos un tiempo de espera de red
    await Future.delayed(const Duration(seconds: 1));

    // Aquí es donde en el futuro llamarías a tu Data Source:
    // await remoteDataSource.deleteEts(id);
  }
}
