import 'entities/workout.dart';

abstract class WorkoutsRepository {
  Future<List<Workout>> fetchAll();

  Future<Workout> create({required String title, String? note});

  Future<void> delete(String id);

  Future<ProfileStats> fetchStats();
}

class ProfileStats {
  const ProfileStats({
    required this.workouts,
    required this.exercises,
    required this.sets,
  });

  final int workouts;
  final int exercises;
  final int sets;
}
