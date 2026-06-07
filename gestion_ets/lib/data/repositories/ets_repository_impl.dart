import 'dart:typed_data';
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
      // Hacer la consulta a Supabase con los filtros
      final modelos = await remoteDataSource.getExamenes(
        carrera: carrera,
        semestre: semestre,
        materia: materia,
      );

      // Cachear los resultados para uso offline
      await localDataSource.cacheExamenes(modelos);

      return modelos;
    } catch (e) {
      try {
        // Si falla la consulta remota, intenta usar el caché
        final localModelos = await localDataSource.getCachedExamenes();
        return localModelos;
      } catch (cacheError) {
        // Si todo falla, retorna lista vacía
        throw Exception('Error al obtener exámenes: $e');
      }
    }
  }

  @override
  Future<List<EtsEntity>> getExamenesByProfesor(String profesorId) async {
    try {
      final modelos = await remoteDataSource.getExamenesByProfesor(profesorId);
      return modelos;
    } catch (e) {
      throw Exception('Error al obtener exámenes del profesor: $e');
    }
  }

  @override
  Future<EtsEntity> crearExamen({
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
    try {
      final modelo = await remoteDataSource.crearExamen(
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

      return modelo;
    } catch (e) {
      throw Exception('Error al crear examen: $e');
    }
  }

  @override
  Future<EtsEntity> actualizarExamen(
    EtsEntity examen, {
    Uint8List? pdfBytes,
    String? pdfFileName,
  }) async {
    try {
      final modelo = EtsModel(
        id: examen.id,
        materia: examen.materia,
        fecha: examen.fecha,
        turno: examen.turno,
        salon: examen.salon,
        profesorId: examen.profesorId,
        profesorNombre: examen.profesorNombre,
        carrera: examen.carrera,
        semestre: examen.semestre,
        createdAt: examen.createdAt,
        updatedAt: examen.updatedAt,
        pdfUrl: examen.pdfUrl,
      );
      final resultado = await remoteDataSource.actualizarExamen(
        modelo,
        pdfBytes: pdfBytes,
        pdfFileName: pdfFileName,
      );
      return resultado;
    } catch (e) {
      throw Exception('Error al actualizar examen: $e');
    }
  }

  @override
  Future<void> eliminarExamen(String id) async {
    try {
      await remoteDataSource.eliminarExamen(id);
    } catch (e) {
      throw Exception('Error al eliminar examen: $e');
    }
  }

  @override
  Future<void> saveEts(EtsEntity ets) async {
    try {
      final modelo = EtsModel(
        id: ets.id,
        materia: ets.materia,
        fecha: ets.fecha,
        turno: ets.turno,
        salon: ets.salon,
        profesorId: ets.profesorId,
        profesorNombre: ets.profesorNombre,
        carrera: ets.carrera,
        semestre: ets.semestre,
        createdAt: ets.createdAt,
        updatedAt: ets.updatedAt,
      );

      // Verificar si es creación o actualización
      if (ets.id.isEmpty) {
        // Crear en Supabase
        await remoteDataSource.crearExamen(
          materia: modelo.materia,
          fecha: modelo.fecha,
          turno: modelo.turno,
          salon: modelo.salon,
          carrera: modelo.carrera,
          semestre: modelo.semestre,
          profesorId: modelo.profesorId,
          profesorNombre: modelo.profesorNombre,
        );
      } else {
        // Actualizar en Supabase
        await remoteDataSource.actualizarExamen(modelo);
      }
    } catch (e) {
      throw Exception('Error al guardar examen: $e');
    }
  }

  @override
  Future<void> deleteEts(String id) async {
    try {
      await remoteDataSource.eliminarExamen(id);
    } catch (e) {
      throw Exception('Error al eliminar examen: $e');
    }
  }

  @override
  Future<void> guardarEtsFavorito(EtsEntity ets) async {
    final modelo = EtsModel(
      id: ets.id,
      materia: ets.materia,
      fecha: ets.fecha,
      turno: ets.turno,
      salon: ets.salon,
      profesorId: ets.profesorId,
      profesorNombre: ets.profesorNombre,
      carrera: ets.carrera,
      semestre: ets.semestre,
      createdAt: ets.createdAt,
      updatedAt: ets.updatedAt,
    );
    await localDataSource.guardarEtsFavorito(modelo);
  }
}
