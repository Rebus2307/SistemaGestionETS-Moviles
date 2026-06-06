import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  // Iniciamos la app en modo claro por defecto
  ThemeCubit() : super(ThemeMode.light);

  // Función para alternar entre claro y oscuro
  void toggleTheme(bool isDark) {
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
