# 📚 Ejemplos de Código - Supabase + Flutter

## 1. Agregar Autenticación (Opcional pero Recomendado)

### Paso 1: Actualizar Dependencias
Agregar a `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
  flutter_secure_storage: ^9.0.0
```

### Paso 2: Crear Auth Service

Crea `lib/data/datasources/auth_data_source.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signUp(String email, String password);
  Future<AuthResponse> signIn(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      return await supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  User? getCurrentUser() => supabase.auth.currentUser;
}
```

---

## 2. Consultas Complejas en Supabase

### Obtener Exámenes Próximos
```dart
Future<List<EtsModel>> getExamenesPorVenir() async {
  try {
    final ahora = DateTime.now();
    final response = await supabase
        .from('examenes')
        .select()
        .gte('fecha', ahora.toIso8601String())
        .order('fecha', ascending: true)
        .limit(10);

    return (response as List)
        .map((json) => EtsModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Error: $e');
  }
}
```

### Búsqueda con Múltiples Filtros
```dart
Future<List<EtsModel>> buscarExamenes({
  String? materia,
  String? turno,
  DateTime? fechaDesde,
}) async {
  try {
    var query = supabase.from('examenes').select();

    if (materia != null && materia.isNotEmpty) {
      query = query.ilike('materia', '%$materia%');
    }

    if (turno != null && turno.isNotEmpty) {
      query = query.eq('turno', turno);
    }

    if (fechaDesde != null) {
      query = query.gte('fecha', fechaDesde.toIso8601String());
    }

    final response = await query.order('fecha', ascending: true);

    return (response as List)
        .map((json) => EtsModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Error: $e');
  }
}
```

---

## 3. Real-Time Updates (Escuchar Cambios)

```dart
class ExamenesRealtimeListener {
  final SupabaseClient supabase = Supabase.instance.client;

  void escucharCambios(Function(List<EtsModel>) onUpdate) {
    supabase
        .from('examenes')
        .on(RealtimeListenEvent.all, (payload) {
          print('Cambio detectado: ${payload.eventType}');
          
          // Aquí puedes recargar los datos
          if (payload.eventType == 'INSERT') {
            print('Nuevo examen insertado');
          } else if (payload.eventType == 'UPDATE') {
            print('Examen actualizado');
          } else if (payload.eventType == 'DELETE') {
            print('Examen eliminado');
          }
        })
        .subscribe((status, err) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('Escuchando cambios en examenes...');
          }
          if (err != null) {
            print('Error: $err');
          }
        });
  }

  void dejarDeEscuchar() {
    supabase.realtime.removeAllChannels();
  }
}
```

---

## 4. Manejo de Errores Personalizado

```dart
class SupabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  SupabaseException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'SupabaseException: $message (Code: $code)';
}

Future<List<EtsModel>> getExamenesSafeHard() async {
  try {
    final response = await supabase
        .from('examenes')
        .select()
        .limit(100);

    return (response as List)
        .map((json) => EtsModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } on PostgrestException catch (e) {
    throw SupabaseException(
      message: 'Error en la base de datos',
      code: e.code,
      originalError: e,
    );
  } on SocketException {
    throw SupabaseException(
      message: 'Sin conexión a internet',
      code: 'NO_CONNECTION',
    );
  } catch (e) {
    throw SupabaseException(
      message: 'Error desconocido',
      originalError: e,
    );
  }
}
```

---

## 5. Sincronización de Datos (Offline-First)

```dart
class OfflineDataSync {
  final SharedPreferences prefs;
  final EtsRemoteDataSource remoteDataSource;
  final SupabaseClient supabase = Supabase.instance.client;

  OfflineDataSync({
    required this.prefs,
    required this.remoteDataSource,
  });

  // Guardar cambios pendientes localmente
  Future<void> guardarCambioPendiente(EtsModel examen) async {
    List<String> pendientes = prefs.getStringList('pendientes') ?? [];
    pendientes.add(jsonEncode(examen.toJson()));
    await prefs.setStringList('pendientes', pendientes);
  }

  // Sincronizar cambios cuando hay conexión
  Future<void> sincronizarCambios() async {
    List<String> pendientes = prefs.getStringList('pendientes') ?? [];
    
    for (String item in pendientes) {
      try {
        final examen = EtsModel.fromJson(jsonDecode(item));
        await remoteDataSource.crearExamen(examen);
      } catch (e) {
        print('Error al sincronizar: $e');
      }
    }

    // Limpiar pendientes
    await prefs.remove('pendientes');
  }

  // Verificar conexión y sincronizar
  void iniciarSincronizacion() {
    // Usar un paquete como connectivity_plus
    // para detectar cuando hay conexión
  }
}
```

---

## 6. Batch Operations (Operaciones en Lote)

```dart
Future<void> crearMultiplesExamenes(List<EtsModel> examenes) async {
  try {
    final batch = <Map<String, dynamic>>[];
    
    for (var examen in examenes) {
      batch.add(examen.toJson(excludeId: true));
    }

    final response = await supabase
        .from('examenes')
        .insert(batch)
        .select();

    print('${response.length} exámenes creados exitosamente');
  } on PostgrestException catch (e) {
    throw Exception('Error al crear exámenes: ${e.message}');
  }
}
```

---

## 7. Subir Archivos a Supabase Storage

```dart
Future<String> subirArchivoExamen(File archivo, String examenId) async {
  try {
    final fileName = 'examen_$examenId/${DateTime.now().millisecondsSinceEpoch}';
    
    await supabase.storage.from('examenes').upload(
      fileName,
      archivo,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    final publicUrl = supabase.storage
        .from('examenes')
        .getPublicUrl(fileName);

    return publicUrl;
  } catch (e) {
    throw Exception('Error al subir archivo: $e');
  }
}
```

---

## 8. Configurar Headers Personalizados

```dart
class CustomSupabaseClient {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'YOUR_URL',
      publishableKey: 'YOUR_KEY',
      headers: {
        'X-Client-Info': 'gestion_ets/1.0.0',
        'X-Platform': 'flutter',
      },
    );
  }
}
```

---

## 📝 Notas Importantes

- Siempre maneja excepciones con `try-catch`
- Usa `excludeId: true` solo al crear nuevos registros
- Los Datos se cachean automáticamente en SharedPreferences
- Implementa autenticación para producción
- Usa RLS (Row Level Security) para proteger datos

¡Usa estos ejemplos como base para casos más complejos! 🚀
