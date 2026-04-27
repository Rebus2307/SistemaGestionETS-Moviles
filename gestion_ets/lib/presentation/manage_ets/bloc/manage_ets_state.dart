import 'package:equatable/equatable.dart';

abstract class ManageEtsState extends Equatable {
  const ManageEtsState();
  @override
  List<Object> get props => [];
}

class ManageEtsInitial extends ManageEtsState {}

class ManageEtsLoading extends ManageEtsState {}

class ManageEtsSuccess extends ManageEtsState {
  final String message;
  const ManageEtsSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class ManageEtsError extends ManageEtsState {
  final String message;
  const ManageEtsError(this.message);
  @override
  List<Object> get props => [message];
}
