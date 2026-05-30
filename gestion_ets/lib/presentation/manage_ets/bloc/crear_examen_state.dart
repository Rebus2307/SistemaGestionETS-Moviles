import 'package:equatable/equatable.dart';
import '../../../domain/entities/ets_entity.dart';

abstract class CrearExamenState extends Equatable {
  const CrearExamenState();

  @override
  List<Object?> get props => [];
}

class CrearExamenInitial extends CrearExamenState {
  const CrearExamenInitial();
}

class CrearExamenLoading extends CrearExamenState {
  const CrearExamenLoading();
}

class CrearExamenSuccess extends CrearExamenState {
  final EtsEntity examen;
  final bool esActualizacion;

  const CrearExamenSuccess({
    required this.examen,
    required this.esActualizacion,
  });

  @override
  List<Object?> get props => [examen, esActualizacion];
}

class CrearExamenError extends CrearExamenState {
  final String message;

  const CrearExamenError(this.message);

  @override
  List<Object?> get props => [message];
}

class FormularioResetado extends CrearExamenState {
  const FormularioResetado();
}
