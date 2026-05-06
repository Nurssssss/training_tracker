import 'package:equatable/equatable.dart';

class ExerciseSet extends Equatable {
  const ExerciseSet({
    required this.id,
    required this.exerciseId,
    required this.reps,
    required this.weight,
    required this.position,
  });

  final String id;
  final String exerciseId;
  final int reps;
  final double weight;
  final int position;

  @override
  List<Object?> get props => [id, exerciseId, reps, weight, position];
}
