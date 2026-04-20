import 'package:equatable/equatable.dart';

abstract class EtsSearchEvent extends Equatable {
  const EtsSearchEvent();

  @override
  List<Object?> get props => [];
}

class BuscarExamenesEvent extends EtsSearchEvent {
  final String? carrera;
  final String? semestre;
  final String? materia;

  const BuscarExamenesEvent({this.carrera, this.semestre, this.materia});

  @override
  List<Object?> get props => [carrera, semestre, materia];
}
