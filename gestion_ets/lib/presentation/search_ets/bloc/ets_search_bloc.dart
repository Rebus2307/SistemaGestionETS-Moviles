import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_examenes_usecase.dart';
import 'ets_search_event.dart';
import 'ets_search_state.dart';

class EtsSearchBloc extends Bloc<EtsSearchEvent, EtsSearchState> {
  final GetExamenesUseCase getExamenesUseCase;

  EtsSearchBloc({required this.getExamenesUseCase})
    : super(EtsSearchInitial()) {
    // Aquí registramos qué hacer cuando llegue el evento BuscarExamenesEvent
    on<BuscarExamenesEvent>((event, emit) async {
      // 1. Avisamos a la UI que muestre un círculo de carga
      emit(EtsSearchLoading());

      try {
        // 2. Ejecutamos nuestra capa de dominio (que a su vez habla con la API/Caché)
        final examenes = await getExamenesUseCase(
          carrera: event.carrera,
          semestre: event.semestre,
          materia: event.materia,
        );

        // 3. Si todo sale bien, mandamos la lista de ETS a la pantalla
        emit(EtsSearchLoaded(examenes));
      } catch (e) {
        // 4. Si falla (sin internet y sin caché), mandamos el error para mostrar un Snackbar
        emit(EtsSearchError(e.toString()));
      }
    });
  }
}
