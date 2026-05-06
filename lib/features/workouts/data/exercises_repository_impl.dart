import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/entities/exercise.dart';
import '../domain/entities/exercise_set.dart';
import '../domain/exercises_repository.dart';

class ExercisesRepositoryImpl implements ExercisesRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Exercise _exerciseFromMap(Map<String, dynamic> m, List<ExerciseSet> sets) {
    return Exercise(
      id: m['id'] as String,
      workoutId: m['workout_id'] as String,
      name: m['name'] as String,
      muscleGroup: m['muscle_group'] as String?,
      sets: sets,
    );
  }

  ExerciseSet _setFromMap(Map<String, dynamic> m) {
    return ExerciseSet(
      id: m['id'] as String,
      exerciseId: m['exercise_id'] as String,
      reps: (m['reps'] as num).toInt(),
      weight: (m['weight'] as num).toDouble(),
      position: (m['position'] as num).toInt(),
    );
  }

  @override
  Future<List<Exercise>> fetchByWorkout(String workoutId) async {
    try {
      final exRows = await _client
          .from('exercises')
          .select()
          .eq('workout_id', workoutId);
      final exercises = (exRows as List).cast<Map<String, dynamic>>();

      if (exercises.isEmpty) return const [];

      final ids = exercises.map((e) => e['id']).toList();
      final setRows = await _client
          .from('sets')
          .select()
          .inFilter('exercise_id', ids)
          .order('position');
      final allSets = (setRows as List)
          .cast<Map<String, dynamic>>()
          .map(_setFromMap)
          .toList();

      return exercises.map((m) {
        final mySets =
            allSets.where((s) => s.exerciseId == m['id']).toList();
        return _exerciseFromMap(m, mySets);
      }).toList();
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось загрузить упражнения');
    }
  }

  @override
  Future<Exercise> createExercise({
    required String workoutId,
    required String name,
    String? muscleGroup,
  }) async {
    try {
      final row = await _client
          .from('exercises')
          .insert({
            'workout_id': workoutId,
            'name': name,
            'muscle_group': muscleGroup,
          })
          .select()
          .single();
      return _exerciseFromMap(row, const []);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось создать упражнение');
    }
  }

  @override
  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _client.from('exercises').delete().eq('id', exerciseId);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось удалить упражнение');
    }
  }

  @override
  Future<ExerciseSet> addSet({
    required String exerciseId,
    required int reps,
    required double weight,
    required int position,
  }) async {
    try {
      final row = await _client
          .from('sets')
          .insert({
            'exercise_id': exerciseId,
            'reps': reps,
            'weight': weight,
            'position': position,
          })
          .select()
          .single();
      return _setFromMap(row);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось добавить подход');
    }
  }

  @override
  Future<void> deleteSet(String setId) async {
    try {
      await _client.from('sets').delete().eq('id', setId);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось удалить подход');
    }
  }
}
