import 'entities/workout.dart';

abstract class WorkoutsRepository {
  Future<List<Workout>> fetchAll();

  Future<Workout> create({required String title, String? note});

  Future<void> delete(String id);
}
