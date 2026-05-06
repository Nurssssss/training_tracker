part of 'workout_detail_cubit.dart';

enum DetailStatus { initial, loading, success, failure }

class WorkoutDetailState extends Equatable {
  const WorkoutDetailState({
    this.status = DetailStatus.initial,
    this.exercises = const [],
    this.errorMessage,
  });

  final DetailStatus status;
  final List<Exercise> exercises;
  final String? errorMessage;

  WorkoutDetailState copyWith({
    DetailStatus? status,
    List<Exercise>? exercises,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkoutDetailState(
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, exercises, errorMessage];
}
