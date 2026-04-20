import '../models/ets_model.dart';

abstract class EtsRemoteDataSource {
  /// Llama al endpoint de la API para obtener los exámenes.
  /// Lanza una [ServerException] para todos los códigos de error.
  Future<List<EtsModel>> getExamenesDesdeApi({
    String? carrera,
    String? semestre,
    String? materia,
  });
}

// Aquí es donde iría la implementación real con el paquete 'http' o 'dio'
class EtsRemoteDataSourceImpl implements EtsRemoteDataSource {
  // Aquí inyectarías el cliente HTTP (ej. final http.Client client;)

  @override
  Future<List<EtsModel>> getExamenesDesdeApi({
    String? carrera,
    String? semestre,
    String? materia,
  }) async {
    // Pendiente: Implementar la llamada real con http.get() cuando el backend esté listo.
    // Por ahora simularemos un retraso de red y devolveremos datos falsos para que puedas ir armando la UI.
    await Future.delayed(const Duration(seconds: 2));

    return [
      EtsModel(
        id: '1',
        materia: 'Desarrollo de Aplicaciones Móviles Nativas',
        fecha: DateTime.now().add(const Duration(days: 10)),
        turno: 'Matutino',
        salon: 'Lab 4',
        profesor: 'Ing. José Antonio Ortiz Ramírez',
      ),
    ];
  }
}
