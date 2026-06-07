import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
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
            _isDarkMode = Theme.of(context).brightness == Brightness.dark;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: $e'),
            backgroundColor: AppColors.error,
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
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
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
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      await _supabase.storage
          .from('avatars')
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));
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
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir foto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  iconTheme: IconThemeData(color: cs.onPrimary),
                  title: Text(
                    _userData?['full_name'] ?? 'Mi Perfil',
                    style: tt.titleMedium?.copyWith(color: cs.onPrimary),
                  ),
                  actions: [
                    if (_canEditProfile && !_isEditing && !_isLoading)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar Perfil',
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                    if (_isEditing && !_isLoading)
                      IconButton(
                        icon: const Icon(Icons.save_outlined),
                        tooltip: 'Guardar Cambios',
                        onPressed: _guardarCambios,
                      ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            cs.primary,
                            cs.primary.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 40),
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor: cs.onPrimary.withValues(alpha: 0.2),
                                  backgroundImage: _userData?['avatar_url'] != null
                                      ? NetworkImage(_userData!['avatar_url'])
                                      : null,
                                  child: _userData?['avatar_url'] == null
                                      ? Text(
                                          (_userData?['full_name'] ?? '?')
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: tt.displaySmall?.copyWith(color: cs.onPrimary),
                                        )
                                      : null,
                                ),
                                if (_isUploading)
                                  const Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: SizedBox(
                                      height: 28,
                                      width: 28,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                else
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: CircleAvatar(
                                      backgroundColor: cs.onPrimary,
                                      radius: 16,
                                      child: IconButton(
                                        icon: Icon(Icons.camera_alt_outlined, color: cs.primary, size: 16),
                                        onPressed: _actualizarFotoPerfil,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _userData?['full_name'] ?? 'Sin nombre',
                              style: tt.titleLarge?.copyWith(color: cs.onPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData?['email'] ?? '',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onPrimary.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SectionCard(
                        title: 'Información Personal',
                        children: [
                          ListTile(
                            leading: Icon(Icons.badge_outlined, color: cs.primary),
                            title: const Text('Nombre Completo'),
                            subtitle: _isEditing
                                ? TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  )
                                : Text(_userData?['full_name'] ?? 'No especificado'),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.email_outlined, color: cs.primary),
                            title: const Text('Correo Electrónico'),
                            subtitle: Text(_userData?['email'] ?? 'No especificado'),
                            trailing: _isEditing
                                ? Icon(Icons.lock_outlined, size: 16, color: cs.onSurface.withValues(alpha: 0.5))
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Académico',
                        children: [
                          ListTile(
                            leading: Icon(Icons.admin_panel_settings_outlined, color: cs.secondary),
                            title: const Text('Rol en el Sistema'),
                            subtitle: Text(
                              (_userData?['role'] ?? 'Desconocido').toString().toUpperCase(),
                              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            trailing: _isEditing
                                ? Icon(Icons.lock_outlined, size: 16, color: cs.onSurface.withValues(alpha: 0.5))
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Configuración',
                        children: [
                          SwitchListTile(
                            title: const Text('Modo Oscuro'),
                            subtitle: const Text('Cambiar la apariencia de la aplicación'),
                            secondary: Icon(_isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                            value: _isDarkMode,
                            onChanged: (bool value) {
                              setState(() => _isDarkMode = value);
                              context.read<ThemeCubit>().toggleTheme(value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Cerrar Sesión'),
                                content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.read<ThemeCubit>().toggleTheme(false);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (_) => const _LogoutRedirect()),
                                        (route) => false,
                                      );
                                    },
                                    style: FilledButton.styleFrom(backgroundColor: cs.error),
                                    child: const Text('Cerrar Sesión'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Cerrar Sesión'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _LogoutRedirect extends StatefulWidget {
  const _LogoutRedirect();

  @override
  State<_LogoutRedirect> createState() => _LogoutRedirectState();
}

class _LogoutRedirectState extends State<_LogoutRedirect> {
  @override
  void initState() {
    super.initState();
    _logout();
  }

  Future<void> _logout() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Scaffold(
        body: Center(child: Text('Sesión cerrada')),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: tt.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          )),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}
