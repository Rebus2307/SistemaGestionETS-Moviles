import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'injection_container.dart' as di;
import 'presentation/auth/pages/login_page.dart';
import 'presentation/search_ets/pages/search_page.dart';
import 'core/theme/theme_cubit.dart'; // <-- NUEVO IMPORT DEL TEMA

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
      await Future.delayed(const Duration(milliseconds: 500));
      final user = Supabase.instance.client.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- ENVOLVEMOS LA APP PARA ESCUCHAR EL TEMA ---
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Gestión ETS',
            debugShowCheckedModeBanner: false,

            // TEMA CLARO
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6200EE),
              ),
              useMaterial3: true,
            ),

            // TEMA OSCURO
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6200EE),
                brightness: Brightness.dark,
              ),
            ),

            // MODO ACTUAL (Controlado por el switch)
            themeMode: themeMode,

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
        },
      ),
    );
  }
}
