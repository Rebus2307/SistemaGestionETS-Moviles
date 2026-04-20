import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ets_model.dart';

abstract class EtsLocalDataSource {
  Future<void> cacheExamenes(List<EtsModel> examenes);
  Future<List<EtsModel>> getCachedExamenes();
  Future<void> guardarEtsFavorito(EtsModel ets);
}

const cachedExamenesKey = 'CACHED_EXAMENES';
const favoritosKey = 'FAVORITOS_EXAMENES';

class EtsLocalDataSourceImpl implements EtsLocalDataSource {
  final SharedPreferences sharedPreferences;

  EtsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheExamenes(List<EtsModel> examenes) {
    // Convertimos la lista de modelos a una lista de mapas JSON, y luego a un String
    final jsonList = examenes.map((ets) => ets.toJson()).toList();
    return sharedPreferences.setString(
      cachedExamenesKey,
      json.encode(jsonList),
    );
  }

  @override
  Future<List<EtsModel>> getCachedExamenes() {
    final jsonString = sharedPreferences.getString(cachedExamenesKey);
    if (jsonString != null) {
      final List<dynamic> decodedJson = json.decode(jsonString);
      final examenes = decodedJson
          .map((json) => EtsModel.fromJson(json))
          .toList();
      return Future.value(examenes);
    } else {
      // Si no hay caché, lanzamos una excepción que capturaremos en el repositorio
      throw Exception('No hay datos en caché');
    }
  }

  @override
  Future<void> guardarEtsFavorito(EtsModel ets) {
    // Aquí podrías leer los favoritos actuales, agregar el nuevo y volver a guardar.
    // Por simplicidad en este paso, guardaremos uno solo.
    return sharedPreferences.setString(favoritosKey, json.encode(ets.toJson()));
  }
}
