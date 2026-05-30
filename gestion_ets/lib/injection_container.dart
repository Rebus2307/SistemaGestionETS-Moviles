import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Imports de ETS ---
import 'data/datasources/ets_local_data_source.dart';
import 'data/datasources/ets_remote_data_source.dart';
import 'data/repositories/ets_repository_impl.dart';
import 'domain/repositories/ets_repository.dart';
import 'domain/usecases/get_examenes_usecase.dart';
import 'domain/usecases/crear_examen_usecase.dart';
import 'domain/usecases/actualizar_examen_usecase.dart';
import 'domain/usecases/eliminar_examen_usecase.dart';
import 'presentation/search_ets/bloc/ets_search_bloc.dart';

// --- Imports de Auth ---
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

// --- Imports de Dashboard ---
import 'domain/usecases/get_dashboard_stats_usecase.dart';
import 'presentation/dashboard/bloc/dashboard_bloc.dart';

// --- Imports de Manage ETS ---
import 'domain/usecases/save_ets_usecase.dart';
import 'domain/usecases/delete_ets_usecase.dart';
import 'presentation/manage_ets/bloc/manage_ets_bloc.dart';
import 'presentation/manage_ets/bloc/crear_examen_bloc.dart';

// --- Imports de Admin ---
import 'presentation/admin/bloc/create_user_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- 1. Casos de Uso (Capa de Dominio) ---
  // Casos de uso para visualizar exámenes
  sl.registerLazySingleton(() => GetExamenesUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));

  // Casos de uso para profesores crear/actualizar/eliminar exámenes
  sl.registerLazySingleton(() => CrearExamenUseCase(sl()));
  sl.registerLazySingleton(() => ActualizarExamenUseCase(sl()));
  sl.registerLazySingleton(() => EliminarExamenUseCase(sl()));

  // Casos de uso heredados
  sl.registerLazySingleton(() => SaveEtsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteEtsUseCase(sl()));

  // --- 2. Repositorios (Capa de Datos) ---
  sl.registerLazySingleton<EtsRepository>(
    () => EtsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // --- 3. Data Sources (Capa de Datos) ---
  sl.registerLazySingleton<EtsRemoteDataSource>(
    () => EtsRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<EtsLocalDataSource>(
    () => EtsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // --- 4. Dependencias Externas ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // --- 5. BLoCs (Capa de Presentación) ---
  sl.registerFactory(() => EtsSearchBloc(getExamenesUseCase: sl()));
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => DashboardBloc(getStatsUseCase: sl()));

  // BLoC para gestionar (Crear/Actualizar/Eliminar) ETS
  sl.registerFactory(
    () => ManageEtsBloc(saveEtsUseCase: sl(), deleteEtsUseCase: sl()),
  );

  // BLoC para crear y actualizar exámenes con validaciones
  sl.registerFactory(
    () => CrearExamenBloc(
      crearExamenUseCase: sl(),
      actualizarExamenUseCase: sl(),
    ),
  );

  // BLoC para crear usuarios (Admin)
  sl.registerFactory(() => CreateUserBloc(authRepository: sl()));
}
