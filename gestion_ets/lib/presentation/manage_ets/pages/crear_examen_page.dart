import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../injection_container.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../bloc/crear_examen_bloc.dart';
import '../bloc/crear_examen_event.dart';
import '../bloc/crear_examen_state.dart';

class CrearExamenPage extends StatelessWidget {
  const CrearExamenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CrearExamenBloc>(),
      child: const _CrearExamenPageView(),
    );
  }
}

class _CrearExamenPageView extends StatefulWidget {
  const _CrearExamenPageView();

  @override
  State<_CrearExamenPageView> createState() => _CrearExamenPageViewState();
}

class _CrearExamenPageViewState extends State<_CrearExamenPageView> {
  final _formKey = GlobalKey<FormState>();
  final _materiaController = TextEditingController();
  final _salonController = TextEditingController();
  final _carreraController = TextEditingController();
  DateTime? _fechaSeleccionada;
  String? _turnoSeleccionado;
  int? _semestreSeleccionado;

  final List<String> _turnos = ['Mañana', 'Tarde', 'Noche'];
  final List<int> _semestres = [1, 2, 3, 4, 5, 6, 7, 8];
  final List<String> _carreras = [
    'Ingeniería en Sistemas',
    'Ingeniería Civil',
    'Administración',
    'Contabilidad',
  ];

  @override
  void dispose() {
    _materiaController.dispose();
    _salonController.dispose();
    _carreraController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      if (mounted) {
        setState(() => _fechaSeleccionada = fecha);
      }
    }
  }

  void _crearExamen() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaSeleccionada == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
        return;
      }

      if (_turnoSeleccionado == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona un turno')));
        return;
      }

      if (_semestreSeleccionado == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona un semestre')));
        return;
      }

      // Obtener datos del usuario actual
      try {
        final authRepository = sl<AuthRepository>();
        final user = await authRepository.getCurrentUser();

        if (user != null && mounted) {
          context.read<CrearExamenBloc>().add(
            CrearExamenRequested(
              materia: _materiaController.text.trim(),
              fecha: _fechaSeleccionada!,
              turno: _turnoSeleccionado!,
              salon: _salonController.text.trim(),
              carrera: _carreraController.text.trim(),
              semestre: _semestreSeleccionado!,
              profesorId: user.id,
              profesorNombre: user.fullName,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Examen'), centerTitle: true),
      body: BlocConsumer<CrearExamenBloc, CrearExamenState>(
        listener: (context, state) {
          if (state is CrearExamenSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.esActualizacion
                      ? 'Examen actualizado exitosamente'
                      : 'Examen creado exitosamente',
                ),
                backgroundColor: Colors.green,
              ),
            );

            // Limpiar formulario y volver
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pop(context, true);
              }
            });
          } else if (state is CrearExamenError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- MATERIA ---
                  TextFormField(
                    controller: _materiaController,
                    decoration: const InputDecoration(
                      labelText: 'Materia',
                      prefixIcon: Icon(Icons.book),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La materia es requerida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- FECHA ---
                  GestureDetector(
                    onTap: _seleccionarFecha,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha del Examen',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _fechaSeleccionada != null
                            ? DateFormat(
                                'dd/MM/yyyy',
                              ).format(_fechaSeleccionada!)
                            : 'Selecciona una fecha',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- TURNO ---
                  DropdownButtonFormField<String>(
                    value: _turnoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Turno',
                      prefixIcon: Icon(Icons.schedule),
                      border: OutlineInputBorder(),
                    ),
                    items: _turnos
                        .map(
                          (turno) => DropdownMenuItem(
                            value: turno,
                            child: Text(turno),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _turnoSeleccionado = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecciona un turno';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- SALÓN ---
                  TextFormField(
                    controller: _salonController,
                    decoration: const InputDecoration(
                      labelText: 'Salón',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El salón es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- CARRERA ---
                  DropdownButtonFormField<String>(
                    value: _carreraController.text.isNotEmpty
                        ? _carreraController.text
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Carrera',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                    items: _carreras
                        .map(
                          (carrera) => DropdownMenuItem(
                            value: carrera,
                            child: Text(carrera),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _carreraController.text = value ?? '');
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona una carrera';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- SEMESTRE ---
                  DropdownButtonFormField<int>(
                    value: _semestreSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Semestre',
                      prefixIcon: Icon(Icons.layers),
                      border: OutlineInputBorder(),
                    ),
                    items: _semestres
                        .map(
                          (semestre) => DropdownMenuItem(
                            value: semestre,
                            child: Text('Semestre $semestre'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _semestreSeleccionado = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecciona un semestre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- BOTÓN CREAR ---
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: state is CrearExamenLoading
                          ? null
                          : _crearExamen,
                      child: state is CrearExamenLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Crear Examen',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
