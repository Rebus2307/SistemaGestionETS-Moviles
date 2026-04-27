import '../../domain/entities/ets_entity.dart';
import '../../domain/repositories/ets_repository.dart';
import '../datasources/ets_remote_data_source.dart';
import '../datasources/ets_local_data_source.dart';
import '../models/ets_model.dart';

class EtsRepositoryImpl implements EtsRepository {
  final EtsRemoteDataSource remoteDataSource;
  final EtsLocalDataSource localDataSource;

  // --- PERSISTENCIA EN MEMORIA ---
  // Esta lista actuará como nuestra base de datos temporal durante la sesión.
  final List<EtsEntity> _sessionExamenes = [];
  bool _datosCargados = false;

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
    // Si es la primera vez que entramos, llenamos la lista con datos de la API/Caché
    if (!_datosCargados) {
      try {
        final modelos = await remoteDataSource.getExamenesDesdeApi(
          carrera: carrera,
          semestre: semestre,
          materia: materia,
        );
        _sessionExamenes.addAll(modelos);
        _datosCargados = true;
      } catch (e) {
        try {
          final localModelos = await localDataSource.getCachedExamenes();
          _sessionExamenes.addAll(localModelos);
          _datosCargados = true;
        } catch (cacheError) {
          // Si todo falla, empezamos con una lista vacía para no romper el flujo
          _datosCargados = true;
        }
      }
    }

    // Retornamos nuestra lista de sesión filtrada según lo que pida la UI
    return _sessionExamenes.where((ets) {
      bool coincide = true;
      if (materia != null && materia.isNotEmpty) {
        coincide = ets.materia.toLowerCase().contains(materia.toLowerCase());
      }
      return coincide;
    }).toList();
  }

  @override
  Future<void> saveEts(EtsEntity ets) async {
    // Simulamos latencia de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Buscamos si el examen ya existe para actualizarlo (Edit) o agregarlo (Create)
    final index = _sessionExamenes.indexWhere((e) => e.id == ets.id);

    if (index != -1) {
      _sessionExamenes[index] = ets;
    } else {
      _sessionExamenes.add(ets);
    }
  }

  @override
  Future<void> deleteEts(String id) async {
    // Simulamos latencia de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Eliminamos el elemento de nuestra lista local por su ID
    _sessionExamenes.removeWhere((ets) => ets.id == id);
  }

  @override
  Future<void> guardarEtsFavorito(EtsEntity ets) async {
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
}
