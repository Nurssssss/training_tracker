import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/workout.dart';
import '../../domain/workouts_repository.dart';

part 'workouts_event.dart';
part 'workouts_state.dart';

class WorkoutsBloc extends Bloc<WorkoutsEvent, WorkoutsState> {
  WorkoutsBloc(this._repo) : super(const WorkoutsState()) {
    on<WorkoutsLoadRequested>(_onLoad);
    on<WorkoutCreateRequested>(_onCreate);
    on<WorkoutDeleteRequested>(_onDelete);
  }

  final WorkoutsRepository _repo;

  Future<void> _onLoad(
    WorkoutsLoadRequested e,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(state.copyWith(status: WorkoutsStatus.loading, clearError: true));
    try {
      final list = await _repo.fetchAll();
      emit(state.copyWith(status: WorkoutsStatus.success, items: list));
    } on Failure catch (f) {
      emit(state.copyWith(status: WorkoutsStatus.failure, errorMessage: f.message));
    }
  }

  Future<void> _onCreate(
    WorkoutCreateRequested e,
    Emitter<WorkoutsState> emit,
  ) async {
    try {
      final created = await _repo.create(title: e.title, note: e.note);
      emit(state.copyWith(items: [created, ...state.items]));
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    }
  }

  Future<void> _onDelete(
    WorkoutDeleteRequested e,
    Emitter<WorkoutsState> emit,
  ) async {
    try {
      await _repo.delete(e.id);
      emit(state.copyWith(
        items: state.items.where((w) => w.id != e.id).toList(),
      ));
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    }
  }
}
