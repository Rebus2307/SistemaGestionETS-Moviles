import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart';
import '../../dashboard/pages/dashboard_page.dart'; // <-- NUEVO IMPORT AL DASHBOARD
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// --- WIDGET PRINCIPAL ---
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginPageView(),
    );
  }
}

// --- VISTA REACTIVA ---
class _LoginPageView extends StatefulWidget {
  const _LoginPageView();

  @override
  State<_LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<_LoginPageView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variable pura de UI para mostrar/ocultar la contraseña
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Administrativo'),
        centerTitle: true,
      ),
      // BlocConsumer reacciona a los cambios de estado de nuestro AuthBloc
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Si hay error, mostramos un Snackbar rojo
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          // Si el login es exitoso, navegamos al Dashboard
          else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Bienvenido Administrador!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navegación hacia el Dashboard reemplazando la pantalla de Login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícono representativo
                    Icon(
                      Icons.admin_panel_settings,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 32),

                    // Campo de Usuario
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu usuario';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _ocultarPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            // Usamos setState solo para esto, ya que es lógica pura de la vista (UI), no de negocio
                            setState(() {
                              _ocultarPassword = !_ocultarPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botón de Inicio de Sesión
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: state is AuthLoading
                            ? null // Deshabilita el botón si está cargando
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  // Disparamos el evento al BLoC
                                  context.read<AuthBloc>().add(
                                    LoginRequestedEvent(
                                      username: _usernameController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                                }
                              },
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
