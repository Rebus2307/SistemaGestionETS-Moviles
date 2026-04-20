import 'package:flutter/material.dart';
import 'injection_container.dart' as di;
import 'presentation/search_ets/pages/search_page.dart'; // Importa la nueva página

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const GestionEtsApp());
}

class GestionEtsApp extends StatelessWidget {
  const GestionEtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión ETS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
        ), // Un color morado institucional
        useMaterial3: true,
      ),
      home:
          const SearchPage(), // Reemplazamos el Scaffold anterior por nuestra página
    );
  }
}
