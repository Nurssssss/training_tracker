import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/entities/workout.dart';
import '../domain/workouts_repository.dart';

class WorkoutsRepositoryImpl implements WorkoutsRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  static const _table = 'workouts';

  Workout _fromMap(Map<String, dynamic> m) => Workout(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        title: m['title'] as String,
        note: m['note'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  String get _uid {
    final u = _client.auth.currentUser;
    if (u == null) throw const Failure('Не авторизован');
    return u.id;
  }

  @override
  Future<List<Workout>> fetchAll() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((e) => _fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось загрузить тренировки');
    }
  }

  @override
  Future<Workout> create({required String title, String? note}) async {
    try {
      final row = await _client
          .from(_table)
          .insert({
            'user_id': _uid,
            'title': title,
            'note': note,
          })
          .select()
          .single();
      return _fromMap(row);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось создать тренировку');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось удалить тренировку');
    }
  }

  @override
  Future<ProfileStats> fetchStats() async {
    try {
      final wIds = await _client.from('workouts').select('id').eq('user_id', _uid);
      final workoutIds = (wIds as List).map((e) => e['id']).toList();
      if (workoutIds.isEmpty) {
        return const ProfileStats(workouts: 0, exercises: 0, sets: 0);
      }
      final eIds = await _client
          .from('exercises')
          .select('id')
          .inFilter('workout_id', workoutIds);
      final exerciseIds = (eIds as List).map((e) => e['id']).toList();
      int setsCount = 0;
      if (exerciseIds.isNotEmpty) {
        final sRows = await _client
            .from('sets')
            .select('id')
            .inFilter('exercise_id', exerciseIds);
        setsCount = (sRows as List).length;
      }
      return ProfileStats(
        workouts: workoutIds.length,
        exercises: exerciseIds.length,
        sets: setsCount,
      );
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось загрузить статистику');
    }
  }
}
