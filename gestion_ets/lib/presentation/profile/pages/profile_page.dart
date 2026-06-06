import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isEditing = false;
  Map<String, dynamic>? _userData;

  final _supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();

  // Control local para el switch visual del modo oscuro
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- Regla de Negocio: Solo Admin y Profesor pueden editar ---
  bool get _canEditProfile {
    final role = _userData?['role'];
    return role == 'administrador' || role == 'profesor_coordinador';
  }

  Future<void> _loadProfileData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final data = await _supabase
            .from('users')
            .select()
            .eq('id', userId)
            .single();
        if (mounted) {
          setState(() {
            _userData = data;
            _nameController.text = data['full_name'] ?? '';
            _isLoading = false;
            // Aquí puedes leer si el sistema está en modo oscuro (ej: Theme.of(context).brightness == Brightness.dark)
            _isDarkMode = Theme.of(context).brightness == Brightness.dark;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _guardarCambios() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      // Actualizamos solo el nombre en la tabla pública
      await _supabase
          .from('users')
          .update({'full_name': _nameController.text.trim()})
          .eq('id', userId);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _userData?['full_name'] = _nameController.text.trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _actualizarFotoPerfil() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;
    setState(() => _isUploading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      await _supabase
          .from('users')
          .update({'avatar_url': imageUrl})
          .eq('id', userId);
      await _loadProfileData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto actualizada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        actions: [
          if (_canEditProfile && !_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar Perfil',
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Guardar Cambios',
              onPressed: _guardarCambios,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: double.infinity),

                  // --- FOTO DE PERFIL ---
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        backgroundImage: _userData?['avatar_url'] != null
                            ? NetworkImage(_userData!['avatar_url'])
                            : null,
                        child: _userData?['avatar_url'] == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                      if (_isUploading)
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircularProgressIndicator(),
                        )
                      else
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _actualizarFotoPerfil,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- INFORMACIÓN DEL USUARIO ---
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // NOMBRE (Editable)
                          ListTile(
                            leading: const Icon(Icons.badge),
                            title: const Text('Nombre Completo'),
                            subtitle: _isEditing
                                ? TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _userData?['full_name'] ??
                                        'No especificado',
                                  ),
                          ),
                          const Divider(),
                          // CORREO (Solo lectura por seguridad de Auth)
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('Correo Electrónico'),
                            subtitle: Text(
                              _userData?['email'] ?? 'No especificado',
                            ),
                            trailing: _isEditing
                                ? const Icon(
                                    Icons.lock_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          const Divider(),
                          // ROL (Solo lectura)
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings),
                            title: const Text('Rol en el Sistema'),
                            subtitle: Text(
                              (_userData?['role'] ?? 'Desconocido')
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: _isEditing
                                ? const Icon(
                                    Icons.lock_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- CONFIGURACIÓN DE LA APLICACIÓN ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Configuración',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    child: SwitchListTile(
                      title: const Text('Modo Oscuro'),
                      subtitle: const Text(
                        'Cambiar la apariencia de la aplicación',
                      ),
                      secondary: Icon(
                        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      ),
                      value: _isDarkMode,
                      onChanged: (bool value) {
                        setState(() => _isDarkMode = value);
                        // Le avisamos al Cubit que cambie el tema globalmente
                        context.read<ThemeCubit>().toggleTheme(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
