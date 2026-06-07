import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => sl<ManageEtsBloc>(),
      child: BlocConsumer<ManageEtsBloc, ManageEtsState>(
        listener: (context, state) {
          if (state is ManageEtsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is ManageEtsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _materiaController,
                      decoration: const InputDecoration(
                        labelText: 'Materia',
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _carreraSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Carrera',
                        prefixIcon: Icon(Icons.school_outlined),
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
                        prefixIcon: Icon(Icons.layers_outlined),
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
                    GestureDetector(
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
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha del Examen',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                          style: tt.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _turnoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Turno',
                        prefixIcon: Icon(Icons.schedule_outlined),
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
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _profesorNombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Profesor',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      readOnly: true,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: state is ManageEtsLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final authRepository = sl<AuthRepository>();
                                    final user = await authRepository
                                        .getCurrentUser();

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
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: AppColors.error,
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
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Guardar Examen', style: tt.labelLarge?.copyWith(color: cs.onPrimary)),
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
