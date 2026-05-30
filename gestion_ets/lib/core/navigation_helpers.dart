import 'package:flutter/material.dart';
import '../domain/entities/user_entity.dart';
import '../presentation/auth/pages/login_page.dart';
import '../presentation/dashboard/pages/dashboard_page.dart';
import '../presentation/search_ets/pages/search_page.dart';

/// Navega a la página apropiada según el rol del usuario
void navigateByRole(BuildContext context, UserEntity user) {
  Widget targetPage;

  if (user.isAdmin) {
    // Administrador → Panel de Admin
    targetPage = const DashboardPage();
  } else if (user.isProfesorCoordinador) {
    // Profesor Coordinador → Dashboard
    targetPage = const DashboardPage();
  } else {
    // Alumno → Búsqueda de exámenes
    targetPage = const SearchPage();
  }

  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (context) => targetPage));
}

/// Obtiene la página inicial según el rol del usuario
Widget getHomePageByRole(UserEntity user) {
  if (user.isAdmin) {
    return const DashboardPage();
  } else if (user.isProfesorCoordinador) {
    return const DashboardPage();
  } else {
    return const SearchPage();
  }
}

/// Verifica si el usuario tiene permisos para acceder a una ruta
bool canAccessRoute(UserEntity user, String routeName) {
  const adminOnlyRoutes = ['admin', 'dashboard', 'users', 'reports'];
  const profesorOnlyRoutes = ['dashboard', 'manage_ets'];
  const alumnoOnlyRoutes = ['search'];

  if (user.isAdmin) {
    return true; // Admin tiene acceso a todo
  }

  if (user.isProfesorCoordinador) {
    return profesorOnlyRoutes.contains(routeName);
  }

  if (user.isAlumno) {
    return alumnoOnlyRoutes.contains(routeName);
  }

  return false;
}

/// Verifica si un usuario tiene acceso a una funcionalidad específica
bool hasPermission(UserEntity user, String permission) {
  const permissions = {
    'view_exams': ['alumno', 'profesor_coordinador', 'administrador'],
    'create_exam': ['profesor_coordinador', 'administrador'],
    'edit_exam': ['profesor_coordinador', 'administrador'],
    'delete_exam': ['profesor_coordinador', 'administrador'],
    'create_user': ['administrador'],
    'manage_users': ['administrador'],
    'view_reports': ['administrador'],
  };

  final allowedRoles = permissions[permission] ?? [];
  return allowedRoles.contains(user.role.toString().split('.').last);
}
