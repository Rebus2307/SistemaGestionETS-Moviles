import 'package:equatable/equatable.dart';
import '../../../domain/entities/ets_entity.dart';

abstract class ManageEtsEvent extends Equatable {
  const ManageEtsEvent();
  @override
  List<Object> get props => [];
}

class SaveEtsEvent extends ManageEtsEvent {
  final EtsEntity ets;
  const SaveEtsEvent(this.ets);
  @override
  List<Object> get props => [ets];
}

class DeleteEtsEvent extends ManageEtsEvent {
  final String id;
  const DeleteEtsEvent(this.id);
  @override
  List<Object> get props => [id];
}
