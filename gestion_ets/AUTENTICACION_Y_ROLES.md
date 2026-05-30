# 🔐 Sistema de Autenticación y Roles - Gestión ETS

## 📋 Estructura de Roles

```
├── Alumno
│   └── Puede ver exámenes disponibles
│       Puede descargar PDFs de exámenes
│
├── Profesor Coordinador
│   └── Puede ver exámenes disponibles
│       Puede agregar nuevos exámenes (suficiencia)
│       Puede editar/eliminar sus propios exámenes
│
└── Administrador
    └── Acceso total al sistema
        Puede crear nuevos usuarios
        Puede asignar roles a usuarios
        Puede gestionar todos los exámenes
        Puede ver reportes
```

---

## 🔧 Configuración Inicial en Supabase

### 1. Crear Tabla de Usuarios

Ya ejecutaste el SQL que crea:
- Tabla `users` con roles
- Políticas RLS de seguridad
- Índices para performance

### 2. Crear Usuario Administrador Inicial

En Supabase **SQL Editor** o en **Authentication** → **Users**, crea un usuario con:
- Email: `admin@escom.edu.mx`
- Password: (contraseña segura)

Luego en Supabase **SQL Editor** → **New Query**:

```sql
-- Insertar el perfil de administrador
INSERT INTO users (id, email, full_name, role) 
VALUES (
  (SELECT id FROM auth.users WHERE email = 'admin@escom.edu.mx'),
  'admin@escom.edu.mx',
  'Administrador del Sistema',
  'administrador'
);
```

---

## 📱 Uso en la App

### Registrarse

```dart
// El usuario se registra como Alumno por defecto
// Solo el Administrador puede crear otros roles desde la sección de gestión de usuarios

final userRepository = sl<AuthRepository>();

try {
  final user = await userRepository.signup(
    email: 'alumno@escom.edu.mx',
    password: 'password123',
    fullName: 'Juan Pérez',
    role: 'alumno', // Se puede cambiar a 'profesor_coordinador'
  );
  print('Usuario registrado: ${user.fullName}');
} catch (e) {
  print('Error: $e');
}
```

### Iniciar Sesión

```dart
final userRepository = sl<AuthRepository>();

try {
  final user = await userRepository.login(
    email: 'alumno@escom.edu.mx',
    password: 'password123',
  );
  
  // Verificar rol
  if (user.isAdmin) {
    // Ir a panel de administrador
  } else if (user.isProfesorCoordinador) {
    // Ir a panel de profesor coordinador
  } else {
    // Ir a búsqueda de exámenes
  }
} catch (e) {
  print('Error: $e');
}
```

### Obtener Usuario Actual

```dart
final userRepository = sl<AuthRepository>();

final currentUser = await userRepository.getCurrentUser();

if (currentUser != null) {
  print('Usuario: ${currentUser.fullName}');
  print('Rol: ${currentUser.role}');
} else {
  print('No hay usuario autenticado');
}
```

### Verificar Autenticación

```dart
final userRepository = sl<AuthRepository>();

final isAuth = await userRepository.isAuthenticated();

if (isAuth) {
  // Mostrar app
} else {
  // Mostrar login
}
```

### Cerrar Sesión

```dart
final userRepository = sl<AuthRepository>();

await userRepository.logout();
// Redirigir a login
```

---

## 🎯 Flujo de Navegación Recomendado

### En main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xlqzkhdlwwulbdbkrssv.supabase.co',
    anonKey: 'sb_publishable_hLEgW-Fb2FMELpyCNEzXrw_2Z6I6z7O',
  );

  await di.init();

  final userRepository = sl<AuthRepository>();
  final isAuthenticated = await userRepository.isAuthenticated();

  runApp(
    GestionEtsApp(isAuthenticated: isAuthenticated),
  );
}
```

### En GestionEtsApp

```dart
class GestionEtsApp extends StatefulWidget {
  final bool isAuthenticated;

  const GestionEtsApp({required this.isAuthenticated});

  @override
  State<GestionEtsApp> createState() => _GestionEtsAppState();
}

class _GestionEtsAppState extends State<GestionEtsApp> {
  late bool _isAuth;

  @override
  void initState() {
    super.initState();
    _isAuth = widget.isAuthenticated;
    _checkAuth();
  }

  void _checkAuth() {
    // Escuchar cambios de autenticación
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        setState(() => _isAuth = true);
      } else if (event == AuthChangeEvent.signedOut) {
        setState(() => _isAuth = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión ETS',
      home: _isAuth ? const SearchPage() : const LoginPage(),
    );
  }
}
```

---

## 🔒 Proteger Rutas por Rol

### Middleware de Rol

```dart
class RoleGuard {
  static Future<bool> canAccess(UserRole requiredRole) async {
    final userRepository = sl<AuthRepository>();
    final user = await userRepository.getCurrentUser();
    
    if (user == null) return false;
    
    return user.role == requiredRole;
  }
}
```

### Usar en Páginas

```dart
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  void _checkPermission() async {
    final hasAccess = await RoleGuard.canAccess(UserRole.administrador);
    
    if (!hasAccess) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes permiso para acceder')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administrador')),
      body: const Center(
        child: Text('Contenido exclusivo para administradores'),
      ),
    );
  }
}
```

---

## 📊 Permisos por Rol

| Acción | Alumno | Prof. Coordinador | Admin |
|--------|--------|-------------------|-------|
| Ver exámenes | ✅ | ✅ | ✅ |
| Descargar PDF | ✅ | ✅ | ✅ |
| Crear examen | ❌ | ✅ | ✅ |
| Editar examen | ❌ | Solo suyos | ✅ |
| Eliminar examen | ❌ | Solo suyos | ✅ |
| Crear usuarios | ❌ | ❌ | ✅ |
| Asignar roles | ❌ | ❌ | ✅ |
| Ver reportes | ❌ | ❌ | ✅ |

---

## 🔐 Seguridad

### Row Level Security (RLS) ya está activa

Las políticas en Supabase garantizan:
- Cada usuario solo ve su propio perfil
- Solo administradores pueden crear usuarios
- Datos sensibles están protegidos

### Cambios Recomendados para Producción

1. **Fortalecer contraseñas**: Usar validación de contraseña fuerte
2. **Verificación de email**: Requerir verificación antes de activar cuenta
3. **2FA (Two-Factor Authentication)**: Implementar para administradores
4. **Auditoría**: Guardar logs de cambios críticos
5. **HTTPS**: Asegurar conexión en producción

---

## � Actualización de Páginas

### Cambios Realizados ✅

#### 1. **LoginPage** (`lib/presentation/auth/pages/login_page.dart`)
- ✅ Cambié campo de "usuario" a "email"
- ✅ Ahora usa `AuthRepository` en lugar de hardcoded validation
- ✅ Implementé navegación por rol (`isAdmin`, `isProfesorCoordinador`, `isAlumno`)
- ✅ Agregué botón para ir a SignUp

#### 2. **SignUpPage** (`lib/presentation/auth/pages/signup_page.dart`) - NUEVA
- ✅ Formulario completo con: email, contraseña, nombre, rol
- ✅ Validaciones robustas (email, contraseña, coincidencia)
- ✅ Selector de rol (Alumno, Profesor Coordinador, Administrador)
- ✅ Conexión con AuthRepository para registro real

#### 3. **AdminPage** (`lib/presentation/admin/pages/admin_page.dart`) - NUEVA
- ✅ Panel dedicado solo para administradores
- ✅ Opciones para: Gestionar usuarios, Gestionar exámenes, Ver reportes, Configuración
- ✅ Botón de cerrar sesión
- ✅ Validación: Solo admin puede acceder

#### 4. **main.dart**
- ✅ Agrego verificación de autenticación al iniciar la app
- ✅ Muestra LoginPage si no está autenticado, SearchPage si está

#### 5. **AuthBloc** (`lib/presentation/auth/bloc/auth_bloc.dart`)
- ✅ Ahora usa `AuthRepository` directamente
- ✅ Cambié eventos para usar `email` en lugar de `username`
- ✅ Implementé handlers para: login, signup, logout, check session

#### 6. **Auth Events** (`lib/presentation/auth/bloc/auth_event.dart`)
- ✅ Cambié `LoginRequestedEvent` para usar `email` en lugar de `username`
- ✅ Agregué `SignUpRequestedEvent` con todos los campos necesarios

#### 7. **Dependency Injection** (`lib/injection_container.dart`)
- ✅ Removí `LoginUseCase` innecesario
- ✅ Actualicé `AuthBloc` para inyectar `AuthRepository` en lugar de `LoginUseCase`

#### 8. **Navigation Helpers** (`lib/core/navigation_helpers.dart`) - NUEVO
- ✅ Función `navigateByRole()` para navegar según el rol
- ✅ Función `canAccessRoute()` para verificar permisos
- ✅ Función `hasPermission()` para validar acciones específicas

---

## 🚀 Siguiente Paso: Crear Usuario Administrador

Para poder probar el login, necesitas crear un usuario administrador en Supabase:

### En Supabase Dashboard:

1. Ve a **Authentication** → **Users**
2. Haz clic en **Invite**
3. Ingresa:
   - Email: `admin@escom.edu.mx`
   - Password: `Admin123!@` (o tu contraseña segura)
4. Haz clic en **Send invitation**

### Luego ejecuta este SQL en Supabase → **SQL Editor**:

```sql
-- Crear el perfil de administrador
INSERT INTO users (id, email, full_name, role) 
VALUES (
  (SELECT id FROM auth.users WHERE email = 'admin@escom.edu.mx'),
  'admin@escom.edu.mx',
  'Administrador del Sistema',
  'administrador'
);
```

---

## ✅ Lo que Puedes Probar Ahora

1. **Ejecutar la app**: `flutter run`
2. **Registrarse como Alumno**: Clic en "¿No tienes cuenta? Regístrate aquí"
3. **Iniciar sesión como Admin**: 
   - Email: `admin@escom.edu.mx`
   - Password: `Admin123!@`
4. **Ver navegación por roles**:
   - Admin → Panel de Administrador
   - Profesor Coordinador → Dashboard
   - Alumno → Búsqueda de exámenes

---

## �📌 Próximos Pasos

1. ✅ Crear usuario administrador en Supabase
2. ⏳ Actualizar páginas de login/signup para usar el nuevo sistema
3. ⏳ Implementar BLoC de autenticación actualizado
4. ⏳ Agregar pantalla de gestión de usuarios (solo admin)
5. ⏳ Agregar página de administrador con opciones de crear usuarios

¿Necesitas que continúe con las páginas y BLoCs? 🚀
