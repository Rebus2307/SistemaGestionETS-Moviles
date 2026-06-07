import 'dart:typed_data';
import '../entities/ets_entity.dart';

abstract class EtsRepository {
  /// Obtener todos los exámenes (pueden verlos alumnos y profesores)
  /// Soporta filtros opcionales por carrera, semestre y materia
  Future<List<EtsEntity>> getExamenes({
    String? carrera,
    String? semestre,
    String? materia,
  });

  /// Obtener solo los exámenes creados por un profesor específico
  Future<List<EtsEntity>> getExamenesByProfesor(String profesorId);

  /// Crear un nuevo examen (solo profesores)
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
  });

  /// Actualizar un examen existente (solo el profesor creador)
  Future<EtsEntity> actualizarExamen(
    EtsEntity examen, {
    Uint8List? pdfBytes,
    String? pdfFileName,
  });

  /// Eliminar un examen (solo el profesor creador)
  Future<void> eliminarExamen(String id);

  /// Regla para el módulo administrativo / caché local
  Future<void> guardarEtsFavorito(EtsEntity ets);

  /// Guarda un nuevo ETS o actualiza uno existente (deprecated - usar crearExamen)
  Future<void> saveEts(EtsEntity ets);

  /// Elimina un ETS usando su identificador único (ID) (deprecated - usar eliminarExamen)
  Future<void> deleteEts(String id);
}
