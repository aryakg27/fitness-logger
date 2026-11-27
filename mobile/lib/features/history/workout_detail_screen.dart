import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/workout_repository.dart';
import '../../utils/format_helpers.dart';
import '../workout/workout_providers.dart';

/// Shows one finished workout: date, duration, exercises and sets.
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.workoutId});

  final int workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutProvider(workoutId)).value;
    final items = ref.watch(workoutExercisesProvider(workoutId));

    return Scaffold(
      appBar: AppBar(title: Text(workout?.name ?? 'Workout')),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (list) => ListView(
          children: [
            // Summary line: date and duration
            if (workout != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${formatDate(workout.date)}  |  '
                  '${formatDuration(workout.durationSeconds)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            // One card per exercise
            for (final item in list) _ExerciseSummary(item: item),
          ],
        ),
      ),
    );
  }
}

/// Read-only card: exercise name and its sets.
class _ExerciseSummary extends ConsumerWidget {
  const _ExerciseSummary({required this.item});

  final WorkoutExerciseItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(setsProvider(item.workoutExerciseId));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.exercise.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            sets.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
              data: (list) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < list.length; i++)
                    Text('Set ${i + 1}:  ${list[i].weight} kg x ${list[i].reps}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}