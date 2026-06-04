import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/ets_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../injection_container.dart';
import '../bloc/manage_ets_bloc.dart';
import '../bloc/manage_ets_event.dart';
import '../bloc/manage_ets_state.dart';

class EtsFormPage extends StatefulWidget {
  final EtsEntity? etsParaEditar;

  const EtsFormPage({super.key, this.etsParaEditar});

  @override
  State<EtsFormPage> createState() => _EtsFormPageState();
}

class _EtsFormPageState extends State<EtsFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _materiaController;
  late TextEditingController _salonController;
  late TextEditingController _profesorNombreController;

  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 7));
  String _turnoSeleccionado = 'Mañana';
  String? _carreraSeleccionada;
  int? _semestreSeleccionado;

  final List<String> _carreras = [
    'Ingeniería en Sistemas',
    'Ingeniería Civil',
    'Administración',
    'Contabilidad',
  ];
  final List<int> _semestres = [1, 2, 3, 4, 5, 6, 7, 8];
  final List<String> _turnos = ['Mañana', 'Tarde', 'Noche'];

  @override
  void initState() {
    super.initState();
    _materiaController = TextEditingController(
      text: widget.etsParaEditar?.materia ?? '',
    );
    _salonController = TextEditingController(
      text: widget.etsParaEditar?.salon ?? '',
    );
    _profesorNombreController = TextEditingController(
      text: widget.etsParaEditar?.profesorNombre ?? '',
    );

    if (widget.etsParaEditar != null) {
      _fechaSeleccionada = widget.etsParaEditar!.fecha;
      _turnoSeleccionado = widget.etsParaEditar!.turno;
      _carreraSeleccionada = widget.etsParaEditar!.carrera;
      _semestreSeleccionado = widget.etsParaEditar!.semestre;
    } else {
      _carreraSeleccionada = 'Ingeniería en Sistemas';
      _semestreSeleccionado = 6;
    }
  }

  @override
  void dispose() {
    _materiaController.dispose();
    _salonController.dispose();
    _profesorNombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ManageEtsBloc>(),
      child: BlocConsumer<ManageEtsBloc, ManageEtsState>(
        listener: (context, state) {
          if (state is ManageEtsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is ManageEtsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.etsParaEditar == null ? 'Nuevo ETS' : 'Editar ETS',
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _materiaController,
                      decoration: const InputDecoration(
                        labelText: 'Materia',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _carreraSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Carrera',
                        border: OutlineInputBorder(),
                      ),
                      items: _carreras.map((carrera) {
                        return DropdownMenuItem(
                          value: carrera,
                          child: Text(carrera),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _carreraSeleccionada = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      initialValue: _semestreSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Semestre',
                        border: OutlineInputBorder(),
                      ),
                      items: _semestres.map((semestre) {
                        return DropdownMenuItem(
                          value: semestre,
                          child: Text('Semestre $semestre'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _semestreSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    ListTile(
                      title: const Text('Fecha del Examen'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaSeleccionada,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2027),
                        );
                        if (picked != null) {
                          setState(() {
                            _fechaSeleccionada = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _turnoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Turno',
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
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _turnoSeleccionado = v;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _salonController,
                      decoration: const InputDecoration(
                        labelText: 'Salón',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _profesorNombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Profesor',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: state is ManageEtsLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final authRepository = sl<AuthRepository>();
                                    final user = await authRepository
                                        .getCurrentUser();

                                    // --- CORRECCIÓN: Validación en el context del Builder ---
                                    if (!context.mounted) return;

                                    if (user != null) {
                                      final nuevoEts = EtsEntity(
                                        id:
                                            widget.etsParaEditar?.id ??
                                            DateTime.now().toIso8601String(),
                                        materia: _materiaController.text,
                                        fecha: _fechaSeleccionada,
                                        turno: _turnoSeleccionado,
                                        salon: _salonController.text,
                                        profesorId: user.id,
                                        profesorNombre: user.fullName,
                                        carrera: _carreraSeleccionada ?? 'ISC',
                                        semestre: _semestreSeleccionado ?? 6,
                                        createdAt:
                                            widget.etsParaEditar?.createdAt ??
                                            DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      );

                                      context.read<ManageEtsBloc>().add(
                                        SaveEtsEvent(nuevoEts),
                                      );
                                    }
                                  } catch (e) {
                                    // --- CORRECCIÓN: Validación en el context del Builder ---
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: state is ManageEtsLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Guardar Examen'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
