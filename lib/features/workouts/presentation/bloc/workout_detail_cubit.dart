import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/exercises_repository.dart';

part 'workout_detail_state.dart';

class WorkoutDetailCubit extends Cubit<WorkoutDetailState> {
  WorkoutDetailCubit(this._repo, this.workoutId)
      : super(const WorkoutDetailState());

  final ExercisesRepository _repo;
  final String workoutId;

  Future<void> load() async {
    emit(state.copyWith(status: DetailStatus.loading, clearError: true));
    try {
      final list = await _repo.fetchByWorkout(workoutId);
      emit(state.copyWith(status: DetailStatus.success, exercises: list));
    } on Failure catch (f) {
      emit(state.copyWith(status: DetailStatus.failure, errorMessage: f.message));
    }
  }

  Future<void> addExercise({required String name, String? muscleGroup}) async {
    try {
      final ex = await _repo.createExercise(
        workoutId: workoutId,
        name: name,
        muscleGroup: muscleGroup,
      );
      emit(state.copyWith(exercises: [...state.exercises, ex]));
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _repo.deleteExercise(exerciseId);
      emit(state.copyWith(
        exercises: state.exercises.where((e) => e.id != exerciseId).toList(),
      ));
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    }
  }

  Future<void> addSet({
    required String exerciseId,
    required int reps,
    required double weight,
  }) async {
    try {
      final ex = state.exercises.firstWhere((e) => e.id == exerciseId);
      final position = ex.sets.length + 1;
      final set = await _repo.addSet(
        exerciseId: exerciseId,
        reps: reps,
        weight: weight,
        position: position,
      );
      final updated = state.exercises.map((e) {
        if (e.id != exerciseId) return e;
        return e.copyWith(sets: [...e.sets, set]);
      }).toList();
      emit(state.copyWith(exercises: updated));
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    }
  }

  Future<void> deleteSet({
    required String exerciseId,
    required String setId,
  }) async {
    try {
      await _repo.deleteSet(setId);
      final updated = state.exercises.map((e) {
        if (e.id != exerciseId) return e;
        return e.copyWith(sets: e.sets.where((s) => s.id != setId).toList());
      }).toList();
      emit(state.copyWith(exercises: updated));
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    }
  }
}
