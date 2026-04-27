import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/ets_entity.dart';
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
  late TextEditingController _profesorController;

  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 7));
  String _turnoSeleccionado = 'M';

  @override
  void initState() {
    super.initState();
    _materiaController = TextEditingController(
      text: widget.etsParaEditar?.materia ?? '',
    );
    _salonController = TextEditingController(
      text: widget.etsParaEditar?.salon ?? '',
    );
    _profesorController = TextEditingController(
      text: widget.etsParaEditar?.profesor ?? '',
    );

    if (widget.etsParaEditar != null) {
      _fechaSeleccionada = widget.etsParaEditar!.fecha;
      _turnoSeleccionado = widget.etsParaEditar!.turno;
    }
  }

  @override
  void dispose() {
    _materiaController.dispose();
    _salonController.dispose();
    _profesorController.dispose();
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
                      initialValue:
                          _turnoSeleccionado, // Corregido de 'value' a 'initialValue'
                      decoration: const InputDecoration(
                        labelText: 'Turno',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'M', child: Text('Matutino')),
                        DropdownMenuItem(value: 'V', child: Text('Vespertino')),
                      ],
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
                      controller: _profesorController,
                      decoration: const InputDecoration(
                        labelText: 'Profesor',
                        border: OutlineInputBorder(),
                      ),
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
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  final nuevoEts = EtsEntity(
                                    id:
                                        widget.etsParaEditar?.id ??
                                        DateTime.now().toIso8601String(),
                                    materia: _materiaController.text,
                                    fecha: _fechaSeleccionada,
                                    turno: _turnoSeleccionado,
                                    salon: _salonController.text,
                                    profesor: _profesorController.text,
                                  );
                                  context.read<ManageEtsBloc>().add(
                                    SaveEtsEvent(nuevoEts),
                                  );
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
