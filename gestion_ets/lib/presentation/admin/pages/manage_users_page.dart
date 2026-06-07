import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../injection_container.dart';
import 'create_user_page.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  late AuthRepository _authRepository;
  List<UserEntity> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authRepository = sl<AuthRepository>();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final list = await _authRepository.getAllUsers();
      setState(() { _users = list; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuarios: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Future<void> _deleteUser(UserEntity user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: Text('¿Estás seguro de que deseas eliminar a ${user.fullName}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _authRepository.deleteUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario eliminado correctamente'), backgroundColor: AppColors.success),
          );
        }
        _loadUsers();
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar usuario: $e'), backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      }
    }
  }

  Future<void> _editUser(UserEntity user) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    UserRole selectedRole = user.role;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar Usuario'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nombre Completo'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'El nombre es obligatorio' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'El correo es obligatorio';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Ingrese un correo válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<UserRole>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(labelText: 'Rol'),
                        items: const [
                          DropdownMenuItem(value: UserRole.alumno, child: Text('Estudiante (Alumno)')),
                          DropdownMenuItem(value: UserRole.profesorCoordinador, child: Text('Profesor Coordinador')),
                          DropdownMenuItem(value: UserRole.administrador, child: Text('Administrador')),
                        ],
                        onChanged: (value) { if (value != null) setDialogState(() => selectedRole = value); },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                FilledButton(
                  onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(context, true); },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() => _isLoading = true);
      try {
        String roleStr = 'alumno';
        if (selectedRole == UserRole.profesorCoordinador) {
          roleStr = 'profesor_coordinador';
        } else if (selectedRole == UserRole.administrador) {
          roleStr = 'administrador';
        }
        await _authRepository.updateUser(id: user.id, fullName: nameController.text.trim(), email: emailController.text.trim(), role: roleStr);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario actualizado correctamente'), backgroundColor: AppColors.success),
          );
        }
        _loadUsers();
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar usuario: $e'), backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      }
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.alumno: return 'Estudiante';
      case UserRole.profesorCoordinador: return 'Profesor';
      case UserRole.administrador: return 'Administrador';
    }
  }

  Color _getRoleColor(UserRole role, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (role) {
      case UserRole.alumno: return cs.secondary;
      case UserRole.profesorCoordinador: return AppColors.success;
      case UserRole.administrador: return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Usuarios'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: cs.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('No hay usuarios registrados', style: tt.titleMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final roleColor = _getRoleColor(user.role, context);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: cs.primaryContainer,
                            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                            child: user.avatarUrl == null
                                ? Text(user.fullName.substring(0, 1).toUpperCase(),
                                    style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold))
                                : null,
                          ),
                          title: Text(user.fullName, style: tt.titleMedium),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(user.email, style: tt.bodySmall),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: roleColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getRoleLabel(user.role).toUpperCase(),
                                  style: tt.labelSmall?.copyWith(color: roleColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editUser(user)),
                              IconButton(icon: Icon(Icons.delete_outline, color: cs.error), onPressed: () => _deleteUser(user)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUserPage()));
          _loadUsers();
        },
        label: const Text('Nuevo Usuario'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
