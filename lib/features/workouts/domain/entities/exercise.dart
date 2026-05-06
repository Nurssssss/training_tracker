import 'package:equatable/equatable.dart';

import 'exercise_set.dart';

class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.workoutId,
    required this.name,
    this.muscleGroup,
    this.sets = const [],
  });

  final String id;
  final String workoutId;
  final String name;
  final String? muscleGroup;
  final List<ExerciseSet> sets;

  Exercise copyWith({
    String? name,
    String? muscleGroup,
    List<ExerciseSet>? sets,
  }) {
    return Exercise(
      id: id,
      workoutId: workoutId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
    );
  }

  @override
  List<Object?> get props => [id, workoutId, name, muscleGroup, sets];
}
