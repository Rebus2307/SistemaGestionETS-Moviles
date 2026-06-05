import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isUploading = false;
  Map<String, dynamic>? _userData;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // --- Cargar datos del usuario desde la tabla 'users' ---
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
            _isLoading = false;
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

  // --- Seleccionar imagen y subirla a Supabase Storage ---
  Future<void> _actualizarFotoPerfil() async {
    final picker = ImagePicker();
    // Abrimos la galería
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return; // El usuario canceló

    setState(() => _isUploading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;

      // LA MAGIA PARA WEB: Leer como Bytes y usar image.name
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;

      // Creamos un nombre único para la imagen
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 1. Subir al bucket 'avatars' usando uploadBinary
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
            ), // Sobrescribe si existe
          );

      // 2. Obtener la URL pública de la imagen
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      // 3. Actualizar el campo 'avatar_url' en nuestra tabla 'users'
      await _supabase
          .from('users')
          .update({'avatar_url': imageUrl})
          .eq('id', userId);

      // 4. Refrescar la pantalla
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
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: double.infinity), // Centrar contenido
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

                      // Botón para editar
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
                          ListTile(
                            leading: const Icon(Icons.badge),
                            title: const Text('Nombre Completo'),
                            subtitle: Text(
                              _userData?['full_name'] ?? 'No especificado',
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('Correo Electrónico'),
                            subtitle: Text(
                              _userData?['email'] ?? 'No especificado',
                            ),
                          ),
                          const Divider(),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
