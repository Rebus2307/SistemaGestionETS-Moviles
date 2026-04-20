import '../entities/ets_entity.dart';
import '../repositories/ets_repository.dart';

class GetExamenesUseCase {
  final EtsRepository repository;

  // Inyectamos el repositorio por constructor
  GetExamenesUseCase(this.repository);

  // El método 'call' permite usar la clase como si fuera una función
  Future<List<EtsEntity>> call({
    String? carrera,
    String? semestre,
    String? materia,
  }) async {
    // Aquí iría lógica de negocio pura si fuera necesaria antes de pedir los datos.
    // Por ejemplo, validar que el semestre sea válido antes de consultar.
    return await repository.getExamenes(
      carrera: carrera,
      semestre: semestre,
      materia: materia,
    );
  }
}
