import 'package:equatable/equatable.dart';
import '../../../domain/entities/ets_entity.dart'; // <-- IMPORTANTE

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalExamenes;
  final Map<String, int> statsPorCarrera;
  final List<EtsEntity> listaExamenes; // <-- NUEVO CAMPO

  const DashboardLoaded({
    required this.totalExamenes,
    required this.statsPorCarrera,
    required this.listaExamenes, // <-- AHORA ES REQUERIDO
  });

  @override
  // No olvides agregarlo a props para que Equatable sepa comparar este estado
  List<Object> get props => [totalExamenes, statsPorCarrera, listaExamenes];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
