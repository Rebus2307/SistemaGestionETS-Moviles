import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_dashboard_stats_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getStatsUseCase;

  DashboardBloc({required this.getStatsUseCase}) : super(DashboardInitial()) {
    on<LoadDashboardStatsEvent>((event, emit) async {
      emit(DashboardLoading());

      try {
        // Llamamos a nuestro caso de uso
        final stats = await getStatsUseCase();

        // Emitimos el estado de éxito con los 3 datos: total, stats y la LISTA
        emit(
          DashboardLoaded(
            totalExamenes: stats['total'],
            statsPorCarrera: stats['porCarrera'],
            listaExamenes: stats['listaExamenes'], // <-- MAREADO FINAL
          ),
        );
      } catch (e) {
        emit(DashboardError('No se pudieron cargar las estadísticas: $e'));
      }
    });
  }
}
