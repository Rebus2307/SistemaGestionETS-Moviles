import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/save_ets_usecase.dart';
import '../../../domain/usecases/delete_ets_usecase.dart';
import 'manage_ets_event.dart';
import 'manage_ets_state.dart';

class ManageEtsBloc extends Bloc<ManageEtsEvent, ManageEtsState> {
  final SaveEtsUseCase saveEtsUseCase;
  final DeleteEtsUseCase deleteEtsUseCase;

  ManageEtsBloc({required this.saveEtsUseCase, required this.deleteEtsUseCase})
    : super(ManageEtsInitial()) {
    // Escuchar cuando el admin guarda un examen
    on<SaveEtsEvent>((event, emit) async {
      emit(ManageEtsLoading());
      try {
        await saveEtsUseCase(event.ets);
        emit(const ManageEtsSuccess('El ETS se guardó correctamente.'));
      } catch (e) {
        emit(ManageEtsError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    // Escuchar cuando el admin borra un examen
    on<DeleteEtsEvent>((event, emit) async {
      emit(ManageEtsLoading());
      try {
        await deleteEtsUseCase(event.id);
        emit(const ManageEtsSuccess('El ETS fue eliminado del sistema.'));
      } catch (e) {
        emit(ManageEtsError('Error al eliminar: $e'));
      }
    });
  }
}
