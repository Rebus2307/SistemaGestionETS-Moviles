class AppConstants {
  // API
  static const String baseUrl =
      'https://api.example.com'; // Cambiar por URL real
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Preferencias
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // Base de datos
  static const String databaseName = 'ets_manager.db';
  static const int databaseVersion = 1;

  // Tablas
  static const String tableExamenes = 'examenes';
  static const String tableCarreras = 'carreras';
  static const String tableSalones = 'salones';
  static const String tableUsuarios = 'usuarios';
}
