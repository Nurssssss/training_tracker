import 'package:flutter/material.dart';

import '../../domain/entities/workout.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      body: const Center(child: Text('Детали тренировки — в работе')),
    );
  }
}
