import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../auth/pages/login_page.dart';
import '../bloc/create_user_bloc.dart';
import '../bloc/create_user_event.dart';
import '../bloc/create_user_state.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _fullNameController;

  String _selectedRole = 'alumno';
  final List<String> _roles = ['alumno', 'profesor_coordinador'];
  final Map<String, String> _roleLabels = {
    'alumno': 'Estudiante',
    'profesor_coordinador': 'Profesor Coordinador',
  };

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _fullNameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<CreateUserBloc>().add(
        CreateUserRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          role: _selectedRole,
        ),
      );
    }
  }

  void _resetForm() {
    _emailController.clear();
    _passwordController.clear();
    _fullNameController.clear();
    setState(() => _selectedRole = 'alumno');
    context.read<CreateUserBloc>().add(const ResetCreateUserForm());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => CreateUserBloc(authRepository: sl<AuthRepository>()),
      child: BlocConsumer<CreateUserBloc, CreateUserState>(
        listener: (context, state) {
          if (state is CreateUserSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Usuario ${state.userEmail} creado. Por seguridad de sesión, se le redirigirá al Login.'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 4),
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
              }
            });
          } else if (state is CreateUserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Crear Nuevo Usuario')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: cs.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: cs.onSecondaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Complete el formulario para crear un nuevo usuario',
                                style: TextStyle(color: cs.onSecondaryContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'usuario@ejemplo.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El email es obligatorio';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Ingrese un email válido';
                        return null;
                      },
                      enabled: state is! CreateUserLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        hintText: 'Juan Pérez García',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El nombre completo es obligatorio';
                        if (value.length < 3) return 'El nombre debe tener al menos 3 caracteres';
                        return null;
                      },
                      enabled: state is! CreateUserLoading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Mínimo 6 caracteres',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      obscureText: !_showPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
                        if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                        return null;
                      },
                      enabled: state is! CreateUserLoading,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol de Usuario',
                        prefixIcon: Icon(Icons.security_outlined),
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem(value: role, child: Text(_roleLabels[role] ?? role));
                      }).toList(),
                      onChanged: (state is CreateUserLoading) ? null : (value) { if (value != null) setState(() => _selectedRole = value); },
                      validator: (value) { if (value == null || value.isEmpty) return 'Debe seleccionar un rol'; return null; },
                    ),
                    const SizedBox(height: 24),
                    Card(
                      color: cs.tertiaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rol seleccionado:', style: tt.labelLarge),
                            const SizedBox(height: 8),
                            Text(_getRolDescription(_selectedRole), style: tt.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: (state is CreateUserLoading) ? null : _resetForm,
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: (state is CreateUserLoading) ? null : () => _submitForm(context),
                            child: state is CreateUserLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Crear Usuario'),
                          ),
                        ),
                      ],
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

  String _getRolDescription(String role) {
    switch (role) {
      case 'alumno':
        return 'Estudiante: Puede ver los exámenes disponibles.';
      case 'profesor_coordinador':
        return 'Profesor Coordinador: Puede crear, editar y eliminar exámenes.';
      default:
        return 'Rol desconocido';
    }
  }
}
