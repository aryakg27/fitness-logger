import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/workout_stats.dart';
import '../workout/workout_providers.dart';
import 'exercise_providers.dart';

/// Progress of one exercise: PR, total volume and a chart over time.
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the exercise name for the title bar.
    final exercises = ref.watch(exercisesProvider).value ?? [];
    final matches = exercises.where((e) => e.id == exerciseId);
    final name = matches.isEmpty ? 'Exercise' : matches.first.name;

    final history = ref.watch(exerciseHistoryProvider(exerciseId));

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No finished workouts with this exercise yet.\n'
                  'Finish a workout to see your progress.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Group the sets by workout. The map keeps the oldest workout first.
          final byWorkout = <int, List<SetData>>{};
          for (final r in records) {
            byWorkout
                .putIfAbsent(r.workoutId, () => [])
                .add(SetData(r.weight, r.reps));
          }

          // Best estimated 1-rep max of each workout = one chart point each.
          final sessionBest =
              byWorkout.values.map((sets) => bestOneRepMax(sets)!).toList();
          final pr = sessionBest.reduce((a, b) => a > b ? a : b);
          final volume =
              totalVolume(records.map((r) => SetData(r.weight, r.reps)));

          final spots = [
            for (var i = 0; i < sessionBest.length; i++)
              FlSpot(i.toDouble(), sessionBest[i]),
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Three summary cards
              Row(
                children: [
                  _StatCard(label: 'Best 1RM', value: '${pr.toStringAsFixed(1)} kg'),
                  _StatCard(label: 'Total volume', value: '${volume.toStringAsFixed(0)} kg'),
                  _StatCard(label: 'Workouts', value: '${byWorkout.length}'),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Estimated 1-rep max per workout (kg)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    // Hide the top, right and bottom labels to keep it clean.
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Left to right: oldest to newest workout'),
            ],
          );
        },
      ),
    );
  }
}

/// A small card showing one number with a label under it.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}