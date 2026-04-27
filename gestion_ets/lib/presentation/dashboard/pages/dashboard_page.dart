import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/ets_entity.dart';
import '../../../injection_container.dart';
import '../../manage_ets/bloc/manage_ets_bloc.dart';
import '../../manage_ets/bloc/manage_ets_event.dart';
import '../../manage_ets/bloc/manage_ets_state.dart';
import '../../manage_ets/pages/ets_form_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos MultiBlocProvider porque esta pantalla ahora escuchará al Dashboard (datos)
    // y al ManageEts (para cuando borremos algo).
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageEtsBloc, ManageEtsState>(
      listener: (context, state) {
        if (state is ManageEtsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Si borramos algo con éxito, refrescamos las estadísticas del dashboard
          context.read<DashboardBloc>().add(LoadDashboardStatsEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Control'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.of(context).pop(),
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
              return _buildDashboardContent(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
        // --- BOTÓN PARA AGREGAR NUEVO ETS (CORREGIDO) ---
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // Esperamos a que el usuario regrese de la pantalla del formulario
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EtsFormPage()),
            );

            // Verificamos si la pantalla sigue viva antes de usar el context
            if (!context.mounted) return;

            // Refrescamos el Dashboard de forma segura
            context.read<DashboardBloc>().add(LoadDashboardStatsEvent());
          },
          label: const Text('Nuevo ETS'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Tarjeta de Total
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Total de ETS Programados',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${state.totalExamenes}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 2. Gráficas de Carrera
          const Text(
            'Distribución por Carrera',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...state.statsPorCarrera.entries.map((entry) {
            final porcentaje = state.totalExamenes > 0
                ? entry.value / state.totalExamenes
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key}: ${entry.value}'),
                  LinearProgressIndicator(
                    value: porcentaje,
                    color: _getColorForCarrera(entry.key),
                    minHeight: 8,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          // 3. LISTA DE GESTIÓN
          const Text(
            'Lista de Exámenes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (state.listaExamenes.isEmpty)
            const Text(
              'No hay exámenes registrados.',
              textAlign: TextAlign.center,
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.listaExamenes.length,
              itemBuilder: (context, index) {
                final ets = state.listaExamenes[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(ets.turno)),
                    title: Text(ets.materia),
                    subtitle: Text(
                      'Salón: ${ets.salon} | Prof: ${ets.profesor}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmarEliminacion(context, ets),
                    ),
                  ),
                );
              },
            ),
        ],
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Disparamos el evento al BLoC
              context.read<ManageEtsBloc>().add(DeleteEtsEvent(ets.id));
              // Cerramos el diálogo
              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _getColorForCarrera(String carrera) {
    if (carrera == 'ISC') return Colors.blue;
    if (carrera == 'LCD') return Colors.green;
    return Colors.orange;
  }
}
