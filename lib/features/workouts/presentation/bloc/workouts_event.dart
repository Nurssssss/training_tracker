part of 'workouts_bloc.dart';

sealed class WorkoutsEvent extends Equatable {
  const WorkoutsEvent();

  @override
  List<Object?> get props => [];
}

class WorkoutsLoadRequested extends WorkoutsEvent {
  const WorkoutsLoadRequested();
}

class WorkoutCreateRequested extends WorkoutsEvent {
  const WorkoutCreateRequested({required this.title, this.note});

  final String title;
  final String? note;

  @override
  List<Object?> get props => [title, note];
}

class WorkoutDeleteRequested extends WorkoutsEvent {
  const WorkoutDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
