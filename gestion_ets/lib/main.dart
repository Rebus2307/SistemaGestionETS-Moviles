import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'domain/repositories/auth_repository.dart';
import 'injection_container.dart' as di;
import 'presentation/auth/pages/login_page.dart';
import 'presentation/search_ets/pages/search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xlqzkhdlwwulbdbkrssv.supabase.co',
    anonKey: 'sb_publishable_hLEgW-Fb2FMELpyCNEzXrw_2Z6I6z7O',
  );

  await di.init();

  runApp(const GestionEtsApp());
}

class GestionEtsApp extends StatefulWidget {
  const GestionEtsApp({super.key});

  @override
  State<GestionEtsApp> createState() => _GestionEtsAppState();
}

class _GestionEtsAppState extends State<GestionEtsApp> {
  late Future<bool> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = _checkAuthentication();
  }

  Future<bool> _checkAuthentication() async {
    try {
      // Espera a que Supabase restaure la sesión automáticamente
      // Supabase obtiene la sesión guardada de SharedPreferences
      await Future.delayed(const Duration(milliseconds: 500));

      final user = Supabase.instance.client.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión ETS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6200EE)),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _authFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return const SearchPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
