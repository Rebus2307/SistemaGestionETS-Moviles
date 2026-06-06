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

    // 3. Contamos los exámenes usando el dato REAL de la base de datos
    for (var ets in examenes) {
      final carreraGuardada = ets.carrera.toUpperCase();

      if (porCarrera.containsKey(carreraGuardada)) {
        porCarrera[carreraGuardada] = porCarrera[carreraGuardada]! + 1;
      } else {
        // En caso de que se agregue una nueva carrera en el futuro
        porCarrera[carreraGuardada] = 1;
      }
    }

    // Retornamos también la lista de examenes para mostrarla en el dashboard
    return {
      'total': total,
      'porCarrera': porCarrera,
      'listaExamenes': examenes,
    };
  }
}
