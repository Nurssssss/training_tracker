import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../workouts/domain/entities/workout.dart';
import '../../../workouts/presentation/bloc/workouts_bloc.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<WorkoutsBloc>();
    if (bloc.state.items.isEmpty) {
      bloc.add(const WorkoutsLoadRequested());
    }
  }

  String _monthKey(DateTime d) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _dayKey(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  Map<String, List<Workout>> _groupByMonth(List<Workout> list) {
    final map = <String, List<Workout>>{};
    for (final w in list) {
      final k = _monthKey(w.createdAt);
      map.putIfAbsent(k, () => []).add(w);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('История')),
      body: BlocBuilder<WorkoutsBloc, WorkoutsState>(
        builder: (context, state) {
          if (state.status == WorkoutsStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history,
                        size: 56, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('Нет тренировок', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Здесь появятся ваши прошедшие тренировки',
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

          final grouped = _groupByMonth(state.items);
          final sortedKeys = grouped.keys.toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _StatsCard(workouts: state.items)),
              for (final key in sortedKeys) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      key,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final w = grouped[key]![i];
                      return ListTile(
                        leading: const Icon(Icons.event_note),
                        title: Text(w.title),
                        subtitle: Text(_dayKey(w.createdAt)),
                      );
                    },
                    childCount: grouped[key]!.length,
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.workouts});

  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final now = DateTime.now();
    final last30 = workouts
        .where((w) => now.difference(w.createdAt).inDays <= 30)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Всего',
                  value: workouts.length.toString(),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              Expanded(
                child: _StatTile(
                  label: 'За 30 дней',
                  value: last30.toString(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
