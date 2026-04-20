import 'package:equatable/equatable.dart';
import '../../../domain/entities/ets_entity.dart';

abstract class EtsSearchState extends Equatable {
  const EtsSearchState();

  @override
  List<Object> get props => [];
}

class EtsSearchInitial extends EtsSearchState {}

class EtsSearchLoading extends EtsSearchState {}

class EtsSearchLoaded extends EtsSearchState {
  final List<EtsEntity> examenes;

  const EtsSearchLoaded(this.examenes);

  // Pasamos la lista a props para que BLoC detecte cuando cambian los resultados
  @override
  List<Object> get props => [examenes];
}

class EtsSearchError extends EtsSearchState {
  final String message;

  const EtsSearchError(this.message);

  @override
  List<Object> get props => [message];
}
