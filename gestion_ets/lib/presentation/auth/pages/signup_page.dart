import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _SignUpPageView(),
    );
  }
}

class _SignUpPageView extends StatefulWidget {
  const _SignUpPageView();

  @override
  State<_SignUpPageView> createState() => _SignUpPageViewState();
}

class _SignUpPageViewState extends State<_SignUpPageView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _ocultarPassword = true;
  bool _ocultarConfirmPassword = true;
  String _selectedRole = 'alumno';

  final List<String> _roles = [
    'alumno',
    'profesor_coordinador',
    'administrador',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Las contraseñas no coinciden'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      context.read<AuthBloc>().add(
        SignUpRequestedEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          role: _selectedRole,
        ),
      );
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'alumno':
        return 'Alumno';
      case 'profesor_coordinador':
        return 'Profesor Coordinador';
      case 'administrador':
        return 'Administrador';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Cuenta creada exitosamente!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      size: 80,
                      color: cs.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Crear Nueva Cuenta',
                      textAlign: TextAlign.center,
                      style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa los datos para registrarte',
                      textAlign: TextAlign.center,
                      style: tt.bodyLarge?.copyWith(color: cs.secondary),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre completo';
                        }
                        if (value.length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }
                        if (!value.contains('@')) {
                          return 'Por favor ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _ocultarPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _ocultarPassword = !_ocultarPassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _ocultarConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _ocultarConfirmPassword = !_ocultarConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor confirma tu contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _roles.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(_getRoleLabel(role)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedRole = newValue);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nota: Solo administradores pueden crear usuarios con otros roles',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: state is AuthLoading ? null : _handleSignUp,
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Crear Cuenta',
                                style: tt.labelLarge?.copyWith(color: cs.onPrimary),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión aquí'),
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
