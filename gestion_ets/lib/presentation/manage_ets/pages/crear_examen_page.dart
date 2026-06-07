import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../../../domain/entities/ets_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../bloc/crear_examen_bloc.dart';
import '../bloc/crear_examen_event.dart';
import '../bloc/crear_examen_state.dart';

class CrearExamenPage extends StatelessWidget {
  final EtsEntity? etsParaEditar;
  const CrearExamenPage({super.key, this.etsParaEditar});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CrearExamenBloc>(),
      child: _CrearExamenPageView(etsParaEditar: etsParaEditar),
    );
  }
}

class _CrearExamenPageView extends StatefulWidget {
  final EtsEntity? etsParaEditar;
  const _CrearExamenPageView({this.etsParaEditar});

  @override
  State<_CrearExamenPageView> createState() => _CrearExamenPageViewState();
}

class _CrearExamenPageViewState extends State<_CrearExamenPageView> {
  final _formKey = GlobalKey<FormState>();
  final _materiaController = TextEditingController();

  DateTime? _fechaSeleccionada;
  String? _turnoSeleccionado;
  int? _semestreSeleccionado;
  String? _carreraSeleccionada;
  String? _salonSeleccionado;

  Uint8List? _pdfBytes;
  String? _pdfFileName;

  bool _isLoadingCatalogos = true;
  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _salones = [];

  final List<String> _turnos = ['Mañana', 'Tarde', 'Noche'];
  final List<int> _semestres = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
    if (widget.etsParaEditar != null) {
      _materiaController.text = widget.etsParaEditar!.materia;
      _fechaSeleccionada = widget.etsParaEditar!.fecha;
      _turnoSeleccionado = widget.etsParaEditar!.turno;
      _semestreSeleccionado = widget.etsParaEditar!.semestre;
      _carreraSeleccionada = widget.etsParaEditar!.carrera;
      _salonSeleccionado = widget.etsParaEditar!.salon;
      if (widget.etsParaEditar!.pdfUrl != null && widget.etsParaEditar!.pdfUrl!.trim().isNotEmpty) {
        _pdfFileName = 'PDF adjunto actual';
      }
    }
  }

  @override
  void dispose() {
    _materiaController.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogos() async {
    try {
      final supabase = Supabase.instance.client;
      final responses = await Future.wait([
        supabase.from('carreras').select().order('siglas'),
        supabase.from('salones').select().order('id_salon'),
      ]);
      if (mounted) {
        setState(() {
          _carreras = List<Map<String, dynamic>>.from(responses[0]);
          _salones = List<Map<String, dynamic>>.from(responses[1]);
          _isLoadingCatalogos = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar catálogos: $e'), backgroundColor: AppColors.error),
      );
      if (mounted) setState(() => _isLoadingCatalogos = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null && mounted) setState(() => _fechaSeleccionada = fecha);
  }

  Future<void> _seleccionarPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf'], withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) setState(() { _pdfBytes = file.bytes; _pdfFileName = file.name; });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al seleccionar PDF: $e')));
    }
  }

  void _removerPDF() => setState(() { _pdfBytes = null; _pdfFileName = null; });

  void _crearOEditarExamen() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
        return;
      }
      try {
        final authRepository = sl<AuthRepository>();
        final user = await authRepository.getCurrentUser();
        if (!mounted) return;
        if (user != null) {
          if (widget.etsParaEditar != null) {
            context.read<CrearExamenBloc>().add(ActualizarExamenRequested(
              examenId: widget.etsParaEditar!.id,
              materia: _materiaController.text.trim(), fecha: _fechaSeleccionada!,
              turno: _turnoSeleccionado!, salon: _salonSeleccionado!,
              carrera: _carreraSeleccionada!, semestre: _semestreSeleccionado!,
              profesorId: widget.etsParaEditar!.profesorId,
              profesorNombre: widget.etsParaEditar!.profesorNombre,
              profesorIdActual: user.id, isAdmin: user.isAdmin,
              pdfBytes: _pdfBytes, pdfFileName: _pdfFileName,
            ));
          } else {
            context.read<CrearExamenBloc>().add(CrearExamenRequested(
              materia: _materiaController.text.trim(), fecha: _fechaSeleccionada!,
              turno: _turnoSeleccionado!, salon: _salonSeleccionado!,
              carrera: _carreraSeleccionada!, semestre: _semestreSeleccionado!,
              profesorId: user.id, profesorNombre: user.fullName,
              pdfBytes: _pdfBytes, pdfFileName: _pdfFileName,
            ));
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final esEdicion = widget.etsParaEditar != null;

    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar Examen' : 'Crear Examen')),
      body: _isLoadingCatalogos
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando catálogos de ESCOM...'),
                ],
              ),
            )
          : BlocConsumer<CrearExamenBloc, CrearExamenState>(
              listener: (context, state) {
                if (state is CrearExamenSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.esActualizacion ? 'Examen actualizado exitosamente' : 'Examen creado exitosamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) Navigator.pop(context, true);
                  });
                } else if (state is CrearExamenError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                  );
                }
              },
              builder: (context, state) {
                final carreraValida = _carreras.any((c) => c['siglas'] == _carreraSeleccionada);
                final salonValido = _salones.any((s) => s['id_salon'] == _salonSeleccionado);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _materiaController,
                          decoration: const InputDecoration(
                            labelText: 'Materia',
                            prefixIcon: Icon(Icons.book_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'La materia es requerida' : null,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _seleccionarFecha,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha del Examen',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              _fechaSeleccionada != null
                                  ? DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)
                                  : 'Selecciona una fecha',
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
                          items: _turnos.map((turno) => DropdownMenuItem(value: turno, child: Text(turno))).toList(),
                          onChanged: (value) => setState(() => _turnoSeleccionado = value),
                          validator: (value) => value == null ? 'Selecciona un turno' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: carreraValida ? _carreraSeleccionada : null,
                          decoration: const InputDecoration(
                            labelText: 'Carrera',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          items: _carreras.map((c) => DropdownMenuItem<String>(value: c['siglas'], child: Text('${c['siglas']} - ${c['nombre_completo']}'))).toList(),
                          onChanged: (value) => setState(() => _carreraSeleccionada = value),
                          validator: (value) => value == null ? 'Selecciona una carrera' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: _semestreSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Semestre',
                            prefixIcon: Icon(Icons.layers_outlined),
                          ),
                          items: _semestres.map((s) => DropdownMenuItem(value: s, child: Text('Semestre $s'))).toList(),
                          onChanged: (value) => setState(() => _semestreSeleccionado = value),
                          validator: (value) => value == null ? 'Selecciona un semestre' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: salonValido ? _salonSeleccionado : null,
                          decoration: const InputDecoration(
                            labelText: 'Salón',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          items: _salones.map((s) => DropdownMenuItem<String>(value: s['id_salon'], child: Text('Salón ${s['id_salon']} (${s['edificio']})'))).toList(),
                          onChanged: (value) => setState(() => _salonSeleccionado = value),
                          validator: (value) => value == null ? 'Selecciona un salón' : null,
                        ),
                        const SizedBox(height: 24),
                        Text('Archivo PDF Opcional', style: tt.labelLarge),
                        const SizedBox(height: 8),
                        if (_pdfFileName != null)
                          Card(
                            color: AppColors.success.withValues(alpha: 0.1),
                            child: ListTile(
                              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
                              title: Text(_pdfFileName!, style: const TextStyle(fontWeight: FontWeight.w500)),
                              trailing: IconButton(
                                icon: Icon(Icons.close, color: cs.onSurface.withValues(alpha: 0.5)),
                                onPressed: _removerPDF,
                              ),
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: _seleccionarPDF,
                            icon: const Icon(Icons.attach_file_outlined),
                            label: const Text('Adjuntar archivo PDF'),
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: state is CrearExamenLoading ? null : _crearOEditarExamen,
                            child: state is CrearExamenLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(esEdicion ? 'Guardar Cambios' : 'Crear Examen', style: tt.labelLarge?.copyWith(color: cs.onPrimary)),
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
