import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/ets_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../injection_container.dart';
import '../bloc/ets_search_bloc.dart';
import '../bloc/ets_search_event.dart';
import '../bloc/ets_search_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../auth/pages/login_page.dart';
import '../../profile/pages/profile_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EtsSearchBloc>(),
      child: const _SearchPageView(),
    );
  }
}

class _SearchPageView extends StatefulWidget {
  const _SearchPageView();

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView> {
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final authRepository = sl<AuthRepository>();
      await authRepository.logout();
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _colorForCarrera(String carrera) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de ETS'),
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
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const _SearchFiltersWidget(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<EtsSearchBloc, EtsSearchState>(
                builder: (context, state) {
                  if (state is EtsSearchInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: cs.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'Ingresa tus criterios de búsqueda\npara comenzar.',
                            textAlign: TextAlign.center,
                            style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    );
                  } else if (state is EtsSearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is EtsSearchLoaded) {
                    return _ResultsList(
                      examenes: state.examenes,
                      colorForCarrera: _colorForCarrera,
                    );
                  } else if (state is EtsSearchError) {
                    return Center(
                      child: Text(
                        'Ups: ${state.message}',
                        style: TextStyle(color: cs.error),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFiltersWidget extends StatefulWidget {
  const _SearchFiltersWidget();

  @override
  State<_SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<_SearchFiltersWidget> {
  String? _carreraSeleccionada;
  String? _semestreSeleccionado;
  final TextEditingController _materiaController = TextEditingController();

  final List<String> _carreras = ['ISC', 'LCD', 'IIA'];
  final List<String> _semestres = ['1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  void dispose() {
    _materiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt_outlined, size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text('Filtros de Búsqueda', style: tt.titleSmall?.copyWith(color: cs.primary)),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Carrera',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              initialValue: _carreraSeleccionada,
              items: _carreras.map((carrera) {
                return DropdownMenuItem(value: carrera, child: Text(carrera));
              }).toList(),
              onChanged: (value) => setState(() => _carreraSeleccionada = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Semestre',
                      prefixIcon: Icon(Icons.layers_outlined),
                    ),
                    initialValue: _semestreSeleccionado,
                    items: _semestres.map((semestre) {
                      return DropdownMenuItem(value: semestre, child: Text(semestre));
                    }).toList(),
                    onChanged: (value) => setState(() => _semestreSeleccionado = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _materiaController,
                    decoration: const InputDecoration(
                      labelText: 'Materia (Opcional)',
                      prefixIcon: Icon(Icons.book_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                context.read<EtsSearchBloc>().add(
                  BuscarExamenesEvent(
                    carrera: _carreraSeleccionada,
                    semestre: _semestreSeleccionado,
                    materia: _materiaController.text.isNotEmpty
                        ? _materiaController.text
                        : null,
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Buscar ETS'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<EtsEntity> examenes;
  final Color Function(String) colorForCarrera;

  const _ResultsList({
    required this.examenes,
    required this.colorForCarrera,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (examenes.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron exámenes para esta búsqueda.',
          style: tt.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: examenes.length,
      itemBuilder: (context, index) {
        final ets = examenes[index];
        final carreraColor = colorForCarrera(ets.carrera);
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
                      leading: CircleAvatar(
                        backgroundColor: carreraColor.withValues(alpha: 0.12),
                        child: Icon(Icons.menu_book, color: carreraColor, size: 20),
                      ),
                      title: Text(ets.materia, style: tt.titleMedium),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${ets.fecha.toLocal().toString().split(' ')[0]} - Turno ${ets.turno}',
                            style: tt.bodySmall,
                          ),
                          Text('Salón: ${ets.salon}', style: tt.bodySmall),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.error),
                        onPressed: () async {
                          await PdfGenerator.exportarEts(ets);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
