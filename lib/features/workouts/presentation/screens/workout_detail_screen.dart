import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import '../../domain/exercises_repository.dart';
import '../bloc/workout_detail_cubit.dart';
import '../widgets/add_exercise_sheet.dart';
import '../widgets/add_set_dialog.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WorkoutDetailCubit>(
      create: (context) =>
          WorkoutDetailCubit(context.read<ExercisesRepository>(), workout.id)
            ..load(),
      child: _DetailView(workout: workout),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.workout});

  final Workout workout;

  Future<void> _addExercise(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddExerciseSheet(),
    );
    if (result != null && context.mounted) {
      context.read<WorkoutDetailCubit>().addExercise(
            name: result['name']!,
            muscleGroup: result['muscleGroup'],
          );
    }
  }

  Future<void> _addSet(BuildContext context, String exerciseId) async {
    final result = await showDialog<Map<String, num>>(
      context: context,
      builder: (_) => const AddSetDialog(),
    );
    if (result != null && context.mounted) {
      context.read<WorkoutDetailCubit>().addSet(
            exerciseId: exerciseId,
            reps: result['reps']!.toInt(),
            weight: result['weight']!.toDouble(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExercise(context),
        icon: const Icon(Icons.add),
        label: const Text('Упражнение'),
      ),
      body: BlocConsumer<WorkoutDetailCubit, WorkoutDetailState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        builder: (context, state) {
          if (state.status == DetailStatus.loading && state.exercises.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.exercises.isEmpty) {
            return const _EmptyExercises();
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            itemCount: state.exercises.length,
            itemBuilder: (context, i) {
              final ex = state.exercises[i];
              return _ExerciseTile(
                exercise: ex,
                onAddSet: () => _addSet(context, ex.id),
                onDelete: () =>
                    context.read<WorkoutDetailCubit>().deleteExercise(ex.id),
                onDeleteSet: (setId) => context
                    .read<WorkoutDetailCubit>()
                    .deleteSet(exerciseId: ex.id, setId: setId),
              );
            },
          );
        },
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.onAddSet,
    required this.onDelete,
    required this.onDeleteSet,
  });

  final Exercise exercise;
  final VoidCallback onAddSet;
  final VoidCallback onDelete;
  final ValueChanged<String> onDeleteSet;

  String _fmtWeight(double w) {
    if (w == w.roundToDouble()) return w.toInt().toString();
    return w.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if ((exercise.muscleGroup ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            exercise.muscleGroup!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Удалить упражнение',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (exercise.sets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Подходов пока нет',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in exercise.sets)
                    InputChip(
                      label: Text('${s.reps} × ${_fmtWeight(s.weight)} кг'),
                      onDeleted: () => onDeleteSet(s.id),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add),
                label: const Text('Добавить подход'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.list_alt, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('Нет упражнений', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Нажмите «Упражнение», чтобы добавить',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
