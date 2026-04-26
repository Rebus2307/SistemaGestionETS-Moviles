import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Imports de ETS ---
import 'data/datasources/ets_local_data_source.dart';
import 'data/datasources/ets_remote_data_source.dart';
import 'data/repositories/ets_repository_impl.dart';
import 'domain/repositories/ets_repository.dart';
import 'domain/usecases/get_examenes_usecase.dart';
import 'presentation/search_ets/bloc/ets_search_bloc.dart';

// --- Imports de Auth ---
import 'data/repositories/auth_repository_impl.dart'; // <-- NUEVO IMPORT
import 'domain/repositories/auth_repository.dart'; // <-- NUEVO IMPORT
import 'domain/usecases/login_usecase.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- 1. Casos de Uso (Capa de Dominio) ---
  sl.registerLazySingleton(() => GetExamenesUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // --- 2. Repositorios (Capa de Datos) ---
  sl.registerLazySingleton<EtsRepository>(
    () => EtsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // <-- Inyectamos el AuthRepository (NUEVO) -->
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // --- 3. Data Sources (Capa de Datos) ---
  sl.registerLazySingleton<EtsRemoteDataSource>(
    () => EtsRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<EtsLocalDataSource>(
    () => EtsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // --- 4. Dependencias Externas ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // --- 5. BLoCs (Capa de Presentación) ---
  // IMPORTANTE: Los BLoCs se registran como Factory, NO como Singleton.
  sl.registerFactory(() => EtsSearchBloc(getExamenesUseCase: sl()));
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));
}
