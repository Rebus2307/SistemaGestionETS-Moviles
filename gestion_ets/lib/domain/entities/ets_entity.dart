import 'package:equatable/equatable.dart';

class EtsEntity extends Equatable {
  final String id;
  final String materia;
  final DateTime fecha;
  final String turno;
  final String salon;
  final String profesor;

  const EtsEntity({
    required this.id,
    required this.materia,
    required this.fecha,
    required this.turno,
    required this.salon,
    required this.profesor,
  });

  // Equatable nos ayuda a comparar objetos por sus valores y no por su espacio en memoria,
  // lo cual es vital para que BLoC sepa cuándo cambiar de estado.
  @override
  List<Object?> get props => [id, materia, fecha, turno, salon, profesor];
}
