import '../../domain/entities/ets_entity.dart';

class EtsModel extends EtsEntity {
  const EtsModel({
    required super.id,
    required super.materia,
    required super.fecha,
    required super.turno,
    required super.salon,
    required super.profesorId,
    required super.profesorNombre,
    required super.carrera,
    required super.semestre,
    required super.createdAt,
    required super.updatedAt,
  });

  // Método factory para crear un modelo a partir de la respuesta del Backend
  factory EtsModel.fromJson(Map<String, dynamic> json) {
    return EtsModel(
      id: json['id'] as String,
      materia: json['materia'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      turno: json['turno'] as String,
      salon: json['salon'] as String,
      profesorId: json['profesor_id'] as String,
      profesorNombre:
          json['profesor_nombre'] as String? ??
          'Profesor', // Fallback si no viene
      carrera: json['carrera'] as String,
      semestre: json['semestre'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Método para enviar datos al Backend
  // Usa excludeId=true cuando creas un nuevo examen (Supabase genera el id)
  Map<String, dynamic> toJson({bool excludeId = false}) {
    final data = {
      'materia': materia,
      'fecha': fecha.toIso8601String(),
      'turno': turno,
      'salon': salon,
      'profesor_id': profesorId,
      'profesor_nombre': profesorNombre,
      'carrera': carrera,
      'semestre': semestre,
    };

    // Solo incluir id cuando se actualiza o cuando no se especifique lo contrario
    if (!excludeId) {
      data['id'] = id;
    }

    return data;
  }
}
