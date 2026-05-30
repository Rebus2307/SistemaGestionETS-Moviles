import 'package:flutter/material.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../injection_container.dart';
import '../../../domain/entities/user_entity.dart';
import '../../auth/pages/login_page.dart';
import '../../manage_ets/pages/crear_examen_page.dart';
import './create_user_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late AuthRepository _authRepository;
  UserEntity? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authRepository = sl<AuthRepository>();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null && user.isAdmin) {
        setState(() => _currentUser = user);
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authRepository.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _currentUser?.fullName ?? 'Administrador',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAdminDashboard(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar a la página de crear examen
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CrearExamenPage()),
          );
        },
        tooltip: 'Crear Examen',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAdminDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjeta de bienvenida
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Bienvenido, Administrador!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usuario: ${_currentUser?.email ?? 'Desconocido'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Opciones del administrador
          const Text(
            'Opciones de Administración',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Botón: Gestionar usuarios
          _buildAdminOption(
            icon: Icons.people,
            title: 'Gestionar Usuarios',
            subtitle: 'Ver, crear y editar usuarios del sistema',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateUserPage()),
              );
            },
          ),
          const SizedBox(height: 12),

          // Botón: Ver exámenes
          _buildAdminOption(
            icon: Icons.assignment,
            title: 'Gestionar Exámenes',
            subtitle: 'Ver, crear, editar o eliminar exámenes del sistema',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CrearExamenPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Botón: Ver reportes
          _buildAdminOption(
            icon: Icons.bar_chart,
            title: 'Ver Reportes',
            subtitle: 'Reportes de actividad y estadísticas del sistema',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ver reportes: Próximamente')),
              );
            },
          ),
          const SizedBox(height: 12),

          // Botón: Configuración
          _buildAdminOption(
            icon: Icons.settings,
            title: 'Configuración',
            subtitle: 'Configurar parámetros del sistema',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración: Próximamente')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
