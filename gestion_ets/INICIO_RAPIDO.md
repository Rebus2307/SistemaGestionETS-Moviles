# ✅ CHECKLIST - QUÉ HACER AHORA

## 🔥 PASOS INMEDIATOS (5 minutos)

### Paso 1: Crear Usuario Admin en Supabase
- [ ] Abre https://supabase.com y accede a tu proyecto
- [ ] Ve a **Authentication** → **Users**
- [ ] Haz clic en **Invite** (o busca botón de crear usuario)
- [ ] Ingresa:
  - Email: `admin@escom.edu.mx`
  - Password: `Admin123!@` (puedes cambiarla)
- [ ] Haz clic en **Send invitation** (o Create user)

### Paso 2: Crear Perfil de Admin en Database
- [ ] En Supabase Dashboard, ve a **SQL Editor**
- [ ] Haz clic en **New Query**
- [ ] Copia y pega esto:

```sql
INSERT INTO users (id, email, full_name, role) 
VALUES (
  (SELECT id FROM auth.users WHERE email = 'admin@escom.edu.mx'),
  'admin@escom.edu.mx',
  'Administrador del Sistema',
  'administrador'
);
```

- [ ] Haz clic en **Run** (o Ctrl+Enter)
- [ ] Espera a que termine (muestra "Success" o similar)

### Paso 3: Ejecutar la App
- [ ] En VS Code, abre una Terminal (Ctrl+`)
- [ ] Asegúrate de estar en la carpeta correcta: `gestion_ets`
- [ ] Ejecuta:
```bash
flutter run
```

- [ ] Espera a que compile y abra el emulador
- [ ] Deberías ver la pantalla de **LoginPage**

---

## 🧪 PRUEBAS RÁPIDAS (5 minutos)

### Test 1: Registrarse como Alumno
- [ ] En LoginPage, toca: **"¿No tienes cuenta? Regístrate aquí"**
- [ ] Rellena:
  - Nombre: `Juan Pérez`
  - Email: `juan@escom.edu.mx`
  - Contraseña: `Test123!`
  - Confirma: `Test123!`
  - Rol: `Alumno`
- [ ] Toca **"Crear Cuenta"**
- [ ] ✅ Deberías volver a LoginPage
- [ ] Inicia sesión con tu nuevo usuario
- [ ] ✅ Deberías ver **SearchPage** (lista de exámenes)

### Test 2: Acceder como Admin
- [ ] Vuelve a LoginPage (busca botón de logout si estás dentro)
- [ ] Ingresa:
  - Email: `admin@escom.edu.mx`
  - Contraseña: `Admin123!@`
- [ ] Toca **"Iniciar Sesión"**
- [ ] ✅ Deberías ver **AdminPage** (Panel de Administrador)
- [ ] Verifica:
  - [ ] Muestra tu email
  - [ ] Muestra 4 opciones (Usuarios, Exámenes, Reportes, Configuración)
  - [ ] Botón de logout arriba a la derecha
- [ ] Toca logout
- [ ] ✅ Vuelves a LoginPage

### Test 3: Verificar Validaciones
- [ ] En LoginPage, intenta:
  - [ ] Dejar email vacío → Debe mostrar error
  - [ ] Dejar contraseña vacío → Debe mostrar error
  - [ ] Ingresar email sin @ → Debe mostrar error
  - [ ] Ingresar contraseña < 6 caracteres → Debe mostrar error
- [ ] En SignUpPage, intenta:
  - [ ] Contraseñas que no coincidan → Debe mostrar error
  - [ ] Nombre < 3 caracteres → Debe mostrar error

---

## 📁 ARCHIVOS IMPORTANTES

Revisa estos documentos para más información:

1. **RESUMEN_PAGINAS_AUTENTICACION.md** (Este archivo)
   - Flujos visuales
   - Casos de prueba
   - Instrucciones completas

2. **CAMBIOS_AUTENTICACION.md**
   - Detalles técnicos
   - Qué archivos fueron modificados
   - Explicación de cada cambio

3. **AUTENTICACION_Y_ROLES.md**
   - Uso de AuthRepository
   - Matriz de permisos
   - Ejemplos de código

---

## 🆘 SI ALGO NO FUNCIONA

### Error: "Credenciales inválidas"
- ✅ Verifica que el usuario admin exista en Supabase
- ✅ Asegúrate de que la contraseña sea exactamente: `Admin123!@`
- ✅ Verifica que el perfil esté en la tabla `users` (ejecuta el SQL nuevamente)

### Error: "Error al obtener datos del usuario"
- ✅ Revisa que el usuario esté en ambas tablas:
  - `auth.users` (Authentication)
  - `public.users` (Database)

### Error: "No se puede conectar a Supabase"
- ✅ Verifica que el emulador tenga internet
- ✅ Verifica que las credenciales de Supabase en `main.dart` sean correctas
- ✅ Prueba: `flutter clean` y luego `flutter run` nuevamente

### LoginPage muestra SearchPage en lugar de AdminPage
- ✅ Verifica que el usuario sea admin en la tabla `users`
- ✅ El rol debe ser exactamente: `'administrador'` (sin mayúsculas)

### SignUpPage no registra usuarios
- ✅ Verifica que el email no esté ya registrado
- ✅ Verifica que la contraseña tenga ≥ 6 caracteres
- ✅ Revisa la consola para ver mensajes de error

---

## 🎯 RESUMEN DE CAMBIOS

| Que Se Cambió | Antes | Después |
|--------------|-------|---------|
| Campo de Login | Usuario (username) | Email |
| Validación | Hardcodeada | Real (Supabase) |
| Registro | No había | Existe SignUpPage |
| Panel Admin | No había | AdminPage creado |
| Navegación | A una sola página | Por rol (admin/profesor/alumno) |
| BLoC | Usaba LoginUseCase | Usa AuthRepository |
| Main | Siempre SearchPage | Verifica autenticación |

---

## ✨ SIGUIENTE: OPCIONAL

Si todo funciona, puedes explorar:

1. **Crear más usuarios** con diferentes roles
2. **Agregar funcionalidad** a las opciones de AdminPage
3. **Implementar logout** en otras páginas
4. **Agregar recuperación de contraseña**
5. **Agregar validación de email**

---

## 📞 RECORDATORIO

- **Usuario Admin de Prueba:**
  - Email: `admin@escom.edu.mx`
  - Contraseña: `Admin123!@`

- **Credenciales de Supabase:**
  - URL: `https://xlqzkhdlwwulbdbkrssv.supabase.co`
  - Clave: `sb_publishable_hLEgW-Fb2FMELpyCNEzXrw_2Z6I6z7O`

---

✅ **¡Listo! Ahora sigue los 3 pasos inmediatos de arriba.**
