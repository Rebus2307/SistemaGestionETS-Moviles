import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/ets_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../injection_container.dart';
import '../../auth/pages/login_page.dart';
import '../../manage_ets/bloc/manage_ets_bloc.dart';
import '../../manage_ets/bloc/manage_ets_event.dart';
import '../../manage_ets/bloc/manage_ets_state.dart';
import '../../manage_ets/pages/crear_examen_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../profile/pages/profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<DashboardBloc>()..add(LoadDashboardStatsEvent()),
        ),
        BlocProvider(create: (_) => sl<ManageEtsBloc>()),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final authRepository = sl<AuthRepository>();
      await authRepository.logout();
      if (!context.mounted) return;
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageEtsBloc, ManageEtsState>(
      listener: (context, state) {
        if (state is ManageEtsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<DashboardBloc>().add(LoadDashboardStatsEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Control'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Mi Perfil',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardError) {
              return Center(child: Text(state.message));
            } else if (state is DashboardLoaded) {
              return _DashboardContent(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CrearExamenPage()),
            );
            if (!context.mounted) return;
            context.read<DashboardBloc>().add(LoadDashboardStatsEvent());
          },
          label: const Text('Nuevo Examen'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardLoaded state;

  const _DashboardContent({required this.state});

  Color _colorForCarrera(BuildContext context, String carrera) {
    switch (carrera.toUpperCase()) {
      case 'ISC':
        return Theme.of(context).colorScheme.secondary;
      case 'LCD':
        return AppColors.success;
      case 'IIA':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final totalCarreras = state.statsPorCarrera.length;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadDashboardStatsEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Resumen',
              style: tt.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.assignment_outlined,
                    value: '${state.totalExamenes}',
                    label: 'ETS Programados',
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.school_outlined,
                    value: '$totalCarreras',
                    label: 'Carreras',
                    color: cs.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.pending_actions_outlined,
                    value: '${state.listaExamenes.length}',
                    label: 'En lista',
                    color: cs.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Distribución por Carrera',
              style: tt.titleMedium,
            ),
            const SizedBox(height: 16),
            ...state.statsPorCarrera.entries.map((entry) {
              final porcentaje = state.totalExamenes > 0
                  ? entry.value / state.totalExamenes
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text('${entry.value}', style: tt.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: porcentaje,
                        color: _colorForCarrera(context, entry.key),
                        minHeight: 8,
                        backgroundColor: cs.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
            Text(
              'Lista de Exámenes',
              style: tt.titleMedium,
            ),
            const SizedBox(height: 16),
            if (state.listaExamenes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No hay exámenes registrados.',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
              )
            else
              ...state.listaExamenes.map((ets) {
                final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                final esMio = ets.profesorId == currentUserId;
                final carreraColor = _colorForCarrera(context, ets.carrera);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: carreraColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(ets.materia, style: tt.titleMedium),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Salón: ${ets.salon} | Prof: ${ets.profesorNombre}',
                                    style: tt.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      '${ets.carrera} - Sem ${ets.semestre}',
                                      style: tt.labelSmall?.copyWith(color: carreraColor),
                                    ),
                                    backgroundColor: carreraColor.withValues(alpha: 0.12),
                                    side: BorderSide.none,
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (esMio) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Editar examen',
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CrearExamenPage(etsParaEditar: ets),
                                          ),
                                        );
                                        if (result == true && context.mounted) {
                                          context.read<DashboardBloc>().add(LoadDashboardStatsEvent());
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: cs.error),
                                      tooltip: 'Eliminar examen',
                                      onPressed: () => _confirmarEliminacion(context, ets),
                                    ),
                                  ] else ...[
                                    IconButton(
                                      icon: Icon(Icons.picture_as_pdf, color: cs.error),
                                      tooltip: 'Exportar PDF',
                                      onPressed: () async {
                                        await PdfGenerator.exportarEts(ets);
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, EtsEntity ets) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar examen?'),
        content: Text(
          'Estás por borrar el ETS de ${ets.materia}. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              context.read<ManageEtsBloc>().add(DeleteEtsEvent(ets.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 12),
            Text(value, style: tt.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: tt.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
