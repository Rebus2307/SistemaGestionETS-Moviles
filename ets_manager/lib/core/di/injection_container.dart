import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== CORE ====================
  // SharedPreferences (para almacenamiento simple)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Database (SQLite para caché local)
  final database = await _initDatabase();
  sl.registerLazySingleton<Database>(() => database);

  // ==================== SERVICES ====================
  // Aquí registraremos servicios como API client, notificaciones, etc.

  // ==================== REPOSITORIES ====================
  // Aquí registraremos los repositorios (los crearemos más adelante)

  // ==================== USECASES ====================
  // Aquí registraremos los casos de uso

  // ==================== PROVIDERS/VIEWMODELS ====================
  // Aquí registraremos los providers de Riverpod o ViewModels
}

Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'ets_manager.db');
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      // Crearemos las tablas más adelante
      return db.execute(
        '''
        CREATE TABLE IF NOT EXISTS examenes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          materia TEXT NOT NULL,
          fecha TEXT NOT NULL,
          turno TEXT NOT NULL,
          salon TEXT NOT NULL,
          profesor TEXT NOT NULL,
          carrera TEXT NOT NULL,
          semestre TEXT NOT NULL,
          isFavorito INTEGER DEFAULT 0
        )
        ''',
      );
    },
  );
}
