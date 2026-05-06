import 'entities/exercise.dart';
import 'entities/exercise_set.dart';

abstract class ExercisesRepository {
  Future<List<Exercise>> fetchByWorkout(String workoutId);

  Future<Exercise> createExercise({
    required String workoutId,
    required String name,
    String? muscleGroup,
  });

  Future<void> deleteExercise(String exerciseId);

  Future<ExerciseSet> addSet({
    required String exerciseId,
    required int reps,
    required double weight,
    required int position,
  });

  Future<void> deleteSet(String setId);
}
