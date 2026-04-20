import '../../domain/entities/ets_entity.dart';

class EtsModel extends EtsEntity {
  const EtsModel({
    required super.id,
    required super.materia,
    required super.fecha,
    required super.turno,
    required super.salon,
    required super.profesor,
  });

  // Método factory para crear un modelo a partir de la respuesta del Backend
  factory EtsModel.fromJson(Map<String, dynamic> json) {
    return EtsModel(
      id: json['id'] as String,
      materia: json['materia'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      turno: json['turno'] as String,
      salon: json['salon'] as String,
      profesor: json['profesor'] as String,
    );
  }

  // Método para enviar datos al Backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materia': materia,
      'fecha': fecha.toIso8601String(),
      'turno': turno,
      'salon': salon,
      'profesor': profesor,
    };
  }
}
