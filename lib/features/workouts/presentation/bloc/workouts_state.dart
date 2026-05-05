part of 'workouts_bloc.dart';

enum WorkoutsStatus { initial, loading, success, failure }

class WorkoutsState extends Equatable {
  const WorkoutsState({
    this.status = WorkoutsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final WorkoutsStatus status;
  final List<Workout> items;
  final String? errorMessage;

  WorkoutsState copyWith({
    WorkoutsStatus? status,
    List<Workout>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkoutsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
