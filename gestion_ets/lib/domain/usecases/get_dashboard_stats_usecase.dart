import '../repositories/ets_repository.dart';

class GetDashboardStatsUseCase {
  final EtsRepository repository;

  GetDashboardStatsUseCase(this.repository);

  // Devolveremos un mapa con el total, el desglose por carrera y la lista completa
  Future<Map<String, dynamic>> call() async {
    // 1. Pedimos TODOS los exámenes
    final examenes = await repository.getExamenes(
      carrera: null,
      semestre: null,
      materia: null,
    );

    // 2. Inicializamos nuestros contadores
    int total = examenes.length;

    Map<String, int> porCarrera = {'ISC': 0, 'LCD': 0, 'IIA': 0};

    // 3. Contamos los exámenes
    for (var ets in examenes) {
      // Lógica de simulación para las barras del dashboard
      if (ets.materia.contains('Móviles') || ets.materia.contains('Redes')) {
        porCarrera['ISC'] = porCarrera['ISC']! + 1;
      } else if (ets.materia.contains('Datos')) {
        porCarrera['LCD'] = porCarrera['LCD']! + 1;
      } else {
        porCarrera['IIA'] = porCarrera['IIA']! + 1;
      }
    }

    // AHORA retornamos también la lista de examenes para poder mostrarla en el dashboard
    return {
      'total': total,
      'porCarrera': porCarrera,
      'listaExamenes': examenes, // <-- NUEVO
    };
  }
}
