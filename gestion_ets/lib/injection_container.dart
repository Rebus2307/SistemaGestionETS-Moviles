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
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

// --- Imports de Dashboard ---
import 'domain/usecases/get_dashboard_stats_usecase.dart';
import 'presentation/dashboard/bloc/dashboard_bloc.dart';

// --- NUEVOS IMPORTS DE MANAGE ETS (ESTO ES LO QUE FALTABA) ---
import 'domain/usecases/save_ets_usecase.dart';
import 'domain/usecases/delete_ets_usecase.dart';
import 'presentation/manage_ets/bloc/manage_ets_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- 1. Casos de Uso (Capa de Dominio) ---
  sl.registerLazySingleton(() => GetExamenesUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));

  // Inyectamos los Casos de Uso del CRUD
  sl.registerLazySingleton(() => SaveEtsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteEtsUseCase(sl()));

  // --- 2. Repositorios (Capa de Datos) ---
  sl.registerLazySingleton<EtsRepository>(
    () => EtsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

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
  sl.registerFactory(() => EtsSearchBloc(getExamenesUseCase: sl()));
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));
  sl.registerFactory(() => DashboardBloc(getStatsUseCase: sl()));

  // Inyectamos el BLoC para gestionar (Crear/Eliminar) ETS
  sl.registerFactory(
    () => ManageEtsBloc(saveEtsUseCase: sl(), deleteEtsUseCase: sl()),
  );
}
