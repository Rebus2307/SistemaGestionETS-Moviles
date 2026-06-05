import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ets_model.dart';

abstract class EtsRemoteDataSource {
  /// Obtener todos los exámenes (para alumnos y profesores)
  /// Lanza una excepción para todos los códigos de error.
  Future<List<EtsModel>> getExamenes({
    String? carrera,
    String? semestre,
    String? materia,
  });

  /// Obtener solo los exámenes creados por un profesor específico
  Future<List<EtsModel>> getExamenesByProfesor(String profesorId);

  /// Crear un nuevo examen (solo profesores)
  /// Requiere profesorId y profesorNombre del usuario actual
  Future<EtsModel> crearExamen({
    required String materia,
    required DateTime fecha,
    required String turno,
    required String salon,
    required String carrera,
    required int semestre,
    required String profesorId,
    required String profesorNombre,
  });

  /// Actualizar un examen existente (solo el profesor creador)
  Future<EtsModel> actualizarExamen(EtsModel examen);

  /// Eliminar un examen (solo el profesor creador)
  Future<void> eliminarExamen(String id);
}

class EtsRemoteDataSourceImpl implements EtsRemoteDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<List<EtsModel>> getExamenes({
    String? carrera,
    String? semestre,
    String? materia,
  }) async {
    try {
      // Construir la consulta base
      var query = supabase.from('examenes').select();

      // Aplicar filtros si existen
      if (carrera != null && carrera.isNotEmpty) {
        query = query.eq('carrera', carrera);
      }

      if (semestre != null && semestre.isNotEmpty) {
        final semestreInt = int.tryParse(semestre);
        if (semestreInt != null) {
          query = query.eq('semestre', semestreInt);
        }
      }

      if (materia != null && materia.isNotEmpty) {
        query = query.ilike('materia', '%$materia%');
      }

      // Ejecutar la consulta y ordenar por fecha
      final response = await query.order('fecha', ascending: true);

      // Convertir la respuesta a lista de modelos
      final examenes = (response as List)
          .map((json) => EtsModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return examenes;
    } on PostgrestException catch (e) {
      throw Exception('Error en la base de datos: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener exámenes: $e');
    }
  }

  @override
  Future<List<EtsModel>> getExamenesByProfesor(String profesorId) async {
    try {
      final response = await supabase
          .from('examenes')
          .select()
          .eq('profesor_id', profesorId)
          .order('fecha', ascending: true);

      final examenes = (response as List)
          .map((json) => EtsModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return examenes;
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener exámenes del profesor: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<EtsModel> crearExamen({
    required String materia,
    required DateTime fecha,
    required String turno,
    required String salon,
    required String carrera,
    required int semestre,
    required String profesorId,
    required String profesorNombre,
  }) async {
    try {
      final examenData = {
        'materia': materia,
        'fecha': fecha.toIso8601String(),
        'turno': turno,
        'salon': salon,
        'carrera': carrera,
        'semestre': semestre,
        'profesor_id': profesorId,
        'profesor_nombre': profesorNombre,
      };

      final response = await supabase
          .from('examenes')
          .insert(examenData)
          .select()
          .single();

      return EtsModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al crear examen: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<EtsModel> actualizarExamen(EtsModel examen) async {
    try {
      final response = await supabase
          .from('examenes')
          .update(examen.toJson())
          .eq('id', examen.id)
          .select()
          .single();

      return EtsModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar examen: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<void> eliminarExamen(String id) async {
    try {
      await supabase.from('examenes').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar examen: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
