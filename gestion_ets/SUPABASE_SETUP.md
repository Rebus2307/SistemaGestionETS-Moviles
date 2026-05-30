# 🚀 Guía de Integración Supabase - Gestión ETS

## ✅ Pasos Completados

Tu proyecto ya tiene:
- ✓ Dependencia `supabase_flutter: ^2.0.0` instalada
- ✓ Credenciales configuradas en `main.dart`
- ✓ Datasource remoto implementado con CRUD completo
- ✓ Repositorio actualizado para persistir en Supabase

## 📝 Pasos Finales

### 1️⃣ Crear Proyecto en Supabase

1. Ve a https://supabase.com
2. Haz clic en "New Project"
3. Configura:
   - **Nombre**: `gestion_ets`
   - **Password**: Contraseña segura (guárdala)
   - **Region**: La más cercana a ti

### 2️⃣ Crear Tabla SQL

En **Supabase Dashboard** → **SQL Editor** → **New Query**, ejecuta:

```sql
CREATE TABLE examenes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  materia TEXT NOT NULL,
  fecha TIMESTAMP NOT NULL,
  turno TEXT NOT NULL,
  salon TEXT NOT NULL,
  profesor TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- Habilitar seguridad
ALTER TABLE examenes ENABLE ROW LEVEL SECURITY;

-- Políticas de acceso
CREATE POLICY "Allow public read" ON examenes
  FOR SELECT USING (true);

CREATE POLICY "Allow insert for authenticated users" ON examenes
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow update for authenticated users" ON examenes
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow delete for authenticated users" ON examenes
  FOR DELETE USING (true);

-- Crear índices para mejor performance
CREATE INDEX idx_examenes_materia ON examenes(materia);
CREATE INDEX idx_examenes_fecha ON examenes(fecha);
```

### 3️⃣ Obtener Credenciales

En Supabase:
- **Settings** → **API**
- Copia `Project URL` y `Anon Key`
- Reemplaza en [main.dart](lib/main.dart):

```dart
await Supabase.initialize(
  url: 'TU_PROJECT_URL',
  publishableKey: 'TU_ANON_KEY',
);
```

### 4️⃣ Insertar Datos de Prueba

En Supabase **SQL Editor**:

```sql
INSERT INTO examenes (materia, fecha, turno, salon, profesor) VALUES
('Desarrollo de Aplicaciones Móviles', now() + interval '10 days', 'Matutino', 'Lab 4', 'Ing. José Antonio Ortiz Ramírez'),
('Bases de Datos', now() + interval '15 days', 'Vespertino', 'Sala 201', 'Dra. María García'),
('Algoritmos', now() + interval '20 days', 'Matutino', 'Lab 2', 'Ing. Carlos López');
```

## 🔧 Funcionalidades Implementadas

### Obtener Exámenes
```dart
// Desde tu BLoC o ViewModel
final examenes = await getExamenesUseCase();
```

### Crear Examen
```dart
final nuevoExamen = EtsEntity(
  id: '', // Se genera automáticamente
  materia: 'Física',
  fecha: DateTime.now().add(Duration(days: 30)),
  turno: 'Matutino',
  salon: 'Sala 102',
  profesor: 'Dr. Juan Pérez',
);

await saveEtsUseCase(nuevoExamen);
```

### Actualizar Examen
```dart
final examenActualizado = examenAnterior.copyWith(
  salon: 'Sala 105',
);
await saveEtsUseCase(examenActualizado);
```

### Eliminar Examen
```dart
await deleteEtsUseCase(examenId);
```

## 📱 Pruebas en tu App

### Con Datos Reales
1. Ejecuta: `flutter pub get`
2. Corre la app: `flutter run`
3. Verifica que los exámenes se cargan desde Supabase

### Modo Offline
- Los datos se cachean localmente en SharedPreferences
- Si no hay conexión, muestra datos del caché
- Se sincroniza cuando hay conexión

## 🔒 Seguridad Recomendada

### Para Producción

1. **Autenticación de Usuarios**:
```dart
// En tu datasource remoto, agregar:
final user = supabase.auth.currentUser;
if (user == null) throw Exception('Usuario no autenticado');
```

2. **Actualizar Políticas RLS**:
```sql
CREATE POLICY "Users can only read their own exams" ON examenes
  FOR SELECT USING (auth.uid() = user_id);
```

3. **Variables de Entorno**:
```dart
// Usa flutter_dotenv para credenciales
import 'package:flutter_dotenv/flutter_dotenv.dart';

await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  publishableKey: dotenv.env['SUPABASE_KEY']!,
);
```

## 📊 Consultas Avanzadas

Si necesitas filtrar datos más adelante:

```dart
// En tu datasource remoto
@override
Future<List<EtsModel>> getExamenesPorTurno(String turno) async {
  try {
    final response = await supabase
        .from('examenes')
        .select()
        .eq('turno', turno)
        .order('fecha', ascending: true);

    return (response as List)
        .map((json) => EtsModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Error: $e');
  }
}
```

## 🐛 Debugging

### Ver Logs de Supabase
```dart
// En main.dart, habilita logs
Supabase.initialize(
  url: '...',
  publishableKey: '...',
  debug: true, // Habilita logs en consola
);
```

### Verificar Datos en BD
En Supabase → **Table Editor** → `examenes` - ve todos los registros

### Errores Comunes

| Error | Solución |
|-------|----------|
| `PostgrestException: 401 Unauthorized` | Verifica la clave anon en main.dart |
| `RLS violation` | Asegúrate que las políticas permitan los accesos |
| `null` en campos | Verifica que los datos en Supabase coincidan con el modelo |

## 📦 Archivos Modificados

- `lib/main.dart` - Ya tiene credenciales
- `lib/data/datasources/ets_remote_data_source.dart` - ✅ Actualizado
- `lib/data/repositories/ets_repository_impl.dart` - ✅ Actualizado
- `lib/data/models/ets_model.dart` - ✅ Actualizado

## 🚀 Próximos Pasos

1. Crea el proyecto en Supabase
2. Ejecuta el SQL para crear tabla
3. Actualiza credenciales en `main.dart`
4. Prueba la app: `flutter run`
5. Verifica datos en Supabase Dashboard

¡Listo! Tu app ahora está conectada a Supabase. 🎉
