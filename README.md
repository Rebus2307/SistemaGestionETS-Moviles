# 📚 Sistema de Gestión ETS (Exámenes a Título de Suficiencia)

Una aplicación móvil desarrollada en **Flutter** para la gestión administrativa de Exámenes a Título de Suficiencia (ETS). Este proyecto implementa **Clean Architecture** (Arquitectura Limpia) y **BLoC** para garantizar un código escalable, mantenible y testeable.

---

## ✨ Características Principales

* **🔐 Autenticación Administrativa:** Acceso seguro al panel de control.
* **📊 Dashboard Interactivo:** Visualización de estadísticas en tiempo real y distribución de exámenes por carrera (ISC, LCD, IIA).
* **📝 CRUD Completo:** Creación, lectura y eliminación de exámenes con validación de reglas de negocio (ej. prevención de fechas pasadas).
* **📡 Offline-First:** Persistencia de datos en caché local para funcionar incluso sin conexión a internet.
* **🎨 Material Design 3:** Interfaz de usuario moderna, fluida y responsiva.

---

## 🛠️ Tecnologías y Arquitectura

Este proyecto está construido bajo los principios de **Clean Architecture**, dividiendo el código en 3 capas principales: `Dominio`, `Datos` y `Presentación`.

* **Framework:** [Flutter](https://flutter.dev/)
* **Lenguaje:** Dart
* **Gestor de Estado:** [flutter_bloc](https://pub.dev/packages/flutter_bloc)
* **Inyección de Dependencias:** [get_it](https://pub.dev/packages/get_it)
* **Manejo de Fechas:** [intl](https://pub.dev/packages/intl)
* **Persistencia Local:** [shared_preferences](https://pub.dev/packages/shared_preferences)

---

## 🚀 Requisitos Previos

Asegúrate de tener instalado lo siguiente en tu entorno de desarrollo antes de comenzar:

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versión 3.x o superior recomendada).
* Dart SDK.
* Un IDE compatible (VS Code, Android Studio, o IntelliJ).
* Un emulador (Android/iOS) configurado o un dispositivo físico conectado.

---

## ⚙️ Instalación y Ejecución

Sigue estos pasos para probar la aplicación en tu máquina local:

**1. Clonar el repositorio**
```bash
git clone <clonar este repositorio>
```

**2. Navegar al directorio del proyecto**
```bash
cd gestion_ets
```

**3. Instalar las dependencias**
```bash
flutter pub get
```

**4. Ejecutar la aplicación**
```bash
flutter run
```

> **Nota de pruebas:** Para probar el acceso administrativo, puedes utilizar las siguientes credenciales simuladas:
> * **Usuario:** `admin`
> * **Contraseña:** `123456`

---

## 📂 Estructura del Proyecto

El código fuente se encuentra dentro de la carpeta `lib/` y sigue esta estructura de Arquitectura Limpia:

```text
lib/
 ┣ core/              # Errores, utilidades y configuraciones globales
 ┣ data/              # Modelos, Data Sources (Local/Remoto) y Repositorios
 ┣ domain/            # Entidades, Contratos (Repositorios) y Casos de Uso
 ┣ presentation/      # BLoCs (Gestión de estado), Páginas y Widgets visuales
 ┣ injection_container.dart # Configuración central de GetIt
 ┗ main.dart          # Punto de entrada de la aplicación
```

---

## 🤝 Contribuciones

Si deseas contribuir a este proyecto, ¡eres bienvenido! Por favor, abre un *Issue* para discutir el cambio que deseas realizar o envía un *Pull Request* directamente.

1. Haz un Fork del proyecto
2. Crea tu rama de características (`git checkout -b feature/NuevaCaracteristica`)
3. Haz commit de tus cambios (`git commit -m 'Añade una nueva característica'`)
4. Haz push a la rama (`git push origin feature/NuevaCaracteristica`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto es de uso académico/demostrativo.