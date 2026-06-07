import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/crear_examen_usecase.dart';
import '../../../domain/usecases/actualizar_examen_usecase.dart';
import '../../../domain/entities/ets_entity.dart';
import 'crear_examen_event.dart';
import 'crear_examen_state.dart';

class CrearExamenBloc extends Bloc<CrearExamenEvent, CrearExamenState> {
  final CrearExamenUseCase crearExamenUseCase;
  final ActualizarExamenUseCase actualizarExamenUseCase;

  CrearExamenBloc({
    required this.crearExamenUseCase,
    required this.actualizarExamenUseCase,
  }) : super(const CrearExamenInitial()) {
    on<CrearExamenRequested>(_onCrearExamen);
    on<ActualizarExamenRequested>(_onActualizarExamen);
    on<ResetearFormulario>(_onResetearFormulario);
  }

  Future<void> _onCrearExamen(
    CrearExamenRequested event,
    Emitter<CrearExamenState> emit,
  ) async {
    emit(const CrearExamenLoading());
    try {
      final examen = await crearExamenUseCase.call(
        materia: event.materia,
        fecha: event.fecha,
        turno: event.turno,
        salon: event.salon,
        carrera: event.carrera,
        semestre: event.semestre,
        profesorId: event.profesorId,
        profesorNombre: event.profesorNombre,
        pdfBytes: event.pdfBytes,
        pdfFileName: event.pdfFileName,
      );

      emit(CrearExamenSuccess(examen: examen, esActualizacion: false));
    } catch (e) {
      emit(CrearExamenError(e.toString()));
    }
  }

  Future<void> _onActualizarExamen(
    ActualizarExamenRequested event,
    Emitter<CrearExamenState> emit,
  ) async {
    emit(const CrearExamenLoading());
    try {
      // Crear la entidad del examen actualizado
      final examenActualizado = EtsEntity(
        id: event.examenId,
        materia: event.materia,
        fecha: event.fecha,
        turno: event.turno,
        salon: event.salon,
        profesorId: event.profesorId,
        profesorNombre: event.profesorNombre,
        carrera: event.carrera,
        semestre: event.semestre,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final examen = await actualizarExamenUseCase.call(
        examen: examenActualizado,
        profesorIdActual: event.profesorIdActual,
        isAdmin: event.isAdmin,
        pdfBytes: event.pdfBytes,
        pdfFileName: event.pdfFileName,
      );

      emit(CrearExamenSuccess(examen: examen, esActualizacion: true));
    } catch (e) {
      emit(CrearExamenError(e.toString()));
    }
  }

  Future<void> _onResetearFormulario(
    ResetearFormulario event,
    Emitter<CrearExamenState> emit,
  ) async {
    emit(const FormularioResetado());
    emit(const CrearExamenInitial());
  }
}
