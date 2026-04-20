import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/ets_entity.dart';
import '../../../injection_container.dart';
import '../bloc/ets_search_bloc.dart';
import '../bloc/ets_search_event.dart';
import '../bloc/ets_search_state.dart';

// --- WIDGET PRINCIPAL ---
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

// --- VISTA REACTIVA ---
class _SearchPageView extends StatelessWidget {
  const _SearchPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de ETS - ESCOM'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const _SearchFiltersWidget(),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<EtsSearchBloc, EtsSearchState>(
                builder: (context, state) {
                  if (state is EtsSearchInitial) {
                    return const Center(
                      child: Text(
                        'Ingresa tus criterios de búsqueda para comenzar.',
                      ),
                    );
                  } else if (state is EtsSearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is EtsSearchLoaded) {
                    return _ResultsTableWidget(examenes: state.examenes);
                  } else if (state is EtsSearchError) {
                    return Center(
                      child: Text(
                        'Ups: ${state.message}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
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

// --- WIDGET DE FILTROS ---
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtros de Búsqueda',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Selector de Carrera
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Carrera',
                border: OutlineInputBorder(),
              ),
              initialValue: _carreraSeleccionada,
              items: _carreras.map((carrera) {
                return DropdownMenuItem(value: carrera, child: Text(carrera));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _carreraSeleccionada = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Fila con el Semestre y la Materia
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Semestre',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _semestreSeleccionado,
                    items: _semestres.map((semestre) {
                      return DropdownMenuItem(
                        value: semestre,
                        child: Text(semestre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _semestreSeleccionado = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _materiaController,
                    decoration: const InputDecoration(
                      labelText: 'Materia (Opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón de Búsqueda
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

// --- WIDGET DE TABLA DE RESULTADOS ---
class _ResultsTableWidget extends StatelessWidget {
  final List<EtsEntity> examenes;

  const _ResultsTableWidget({required this.examenes});

  @override
  Widget build(BuildContext context) {
    if (examenes.isEmpty) {
      return const Center(
        child: Text('No se encontraron exámenes para esta búsqueda.'),
      );
    }

    return ListView.builder(
      itemCount: examenes.length,
      itemBuilder: (context, index) {
        final ets = examenes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.menu_book)),
            title: Text(
              ets.materia,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${ets.fecha.toLocal().toString().split(' ')[0]} - Turno ${ets.turno}\nSalón: ${ets.salon}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                // Pendiente: Aquí implementaremos la exportación a PDF
              },
            ),
          ),
        );
      },
    );
  }
}
