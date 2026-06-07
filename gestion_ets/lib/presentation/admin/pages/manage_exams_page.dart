import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../domain/entities/ets_entity.dart';
import '../../../domain/repositories/ets_repository.dart';
import '../../../injection_container.dart';
import '../../manage_ets/pages/crear_examen_page.dart';

class ManageExamsPage extends StatefulWidget {
  const ManageExamsPage({super.key});

  @override
  State<ManageExamsPage> createState() => _ManageExamsPageState();
}

class _ManageExamsPageState extends State<ManageExamsPage> {
  late EtsRepository _etsRepository;
  List<EtsEntity> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _etsRepository = sl<EtsRepository>();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    try {
      final list = await _etsRepository.getExamenes();
      setState(() { _exams = list; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar exámenes: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteExam(EtsEntity ets) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar examen?'),
        content: Text('¿Estás seguro de que deseas eliminar el ETS de "${ets.materia}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _etsRepository.eliminarExamen(ets.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Examen eliminado correctamente'), backgroundColor: AppColors.success),
          );
        }
        _loadExams();
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar examen: $e'), backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Exámenes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadExams),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: cs.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('No hay exámenes registrados', style: tt.titleMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final ets = _exams[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: cs.primaryContainer,
                                    child: const Icon(Icons.menu_book, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ets.materia, style: tt.titleMedium),
                                        const SizedBox(height: 4),
                                        Text('Fecha: ${DateFormat('dd/MM/yyyy').format(ets.fecha)} | Turno: ${ets.turno}', style: tt.bodySmall),
                                        Text('Carrera: ${ets.carrera} | Semestre: ${ets.semestre} | Salón: ${ets.salon}', style: tt.bodySmall),
                                        Text('Profesor: ${ets.profesorNombre}', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                                        if (ets.pdfUrl != null && ets.pdfUrl!.trim().isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.attachment, size: 16, color: AppColors.success),
                                              const SizedBox(width: 4),
                                              Text('Tiene PDF adjunto', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.picture_as_pdf, color: cs.error),
                                        tooltip: 'Ver PDF combinado',
                                        onPressed: () async => await PdfGenerator.exportarEts(ets),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Editar examen',
                                        onPressed: () async {
                                          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => CrearExamenPage(etsParaEditar: ets)));
                                          if (result == true) _loadExams();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, color: cs.error),
                                        tooltip: 'Eliminar examen',
                                        onPressed: () => _deleteExam(ets),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearExamenPage()));
          if (result == true) _loadExams();
        },
        label: const Text('Nuevo Examen'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
