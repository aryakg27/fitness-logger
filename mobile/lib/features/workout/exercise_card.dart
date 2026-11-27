import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/workout_repository.dart';
import '../../utils/workout_stats.dart';
import 'workout_providers.dart';

/// Card for one exercise in the workout: its name, the logged sets,
/// and inputs to add a new set. A set that beats your best gets a PR badge.
class ExerciseCard extends ConsumerStatefulWidget {
  const ExerciseCard({super.key, required this.item});

  final WorkoutExerciseItem item;

  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  // Controllers read what the user typed in the two input boxes.
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  /// Validates the input and saves a new set.
  Future<void> _addSet() async {
    final weight = double.tryParse(_weightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());

    // Weight can be 0 (bodyweight exercises) but reps must be at least 1.
    if (weight == null || weight < 0 || reps == null || reps < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid weight and reps')),
      );
      return;
    }

    await ref.read(workoutRepositoryProvider).addSet(
          workoutExerciseId: widget.item.workoutExerciseId,
          weight: weight,
          reps: reps,
        );
    // Keep the weight for the next set, clear only the reps.
    _repsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final sets = ref.watch(setsProvider(widget.item.workoutExerciseId));

    // Sets of this exercise from earlier, finished workouts.
    final history =
        ref.watch(exerciseHistoryProvider(widget.item.exercise.id)).value ?? [];
    final historySets = history.map((r) => SetData(r.weight, r.reps)).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name and muscle group
            Text(
              widget.item.exercise.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.item.exercise.muscleGroup),
            const SizedBox(height: 8),

            // List of sets already logged
            sets.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
              data: (list) => Column(
                children: [
                  for (var i = 0; i < list.length; i++)
                    _buildSetRow(list, i, historySets),
                ],
              ),
            ),

            // Row to add a new set
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _addSet, child: const Text('Add set')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// One row for set number [i], with a PR badge when it beats the best so far.
  Widget _buildSetRow(List<dynamic> list, int i, List<SetData> historySets) {
    final set = list[i];

    // Everything this set has to beat: old workouts + earlier sets today.
    final previous = [
      ...historySets,
      for (var j = 0; j < i; j++) SetData(list[j].weight, list[j].reps),
    ];
    // Only show PRs once there is history, so the first workout stays clean.
    final isPr = historySets.isNotEmpty &&
        isNewPr(
          candidate: SetData(set.weight, set.reps),
          previousSets: previous,
        );

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      // Number by position so it stays correct after deleting.
      leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
      title: Text('${set.weight} kg x ${set.reps} reps'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPr)
            const Chip(
              label: Text('PR'),
              visualDensity: VisualDensity.compact,
              avatar: Icon(Icons.emoji_events, size: 16),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                ref.read(workoutRepositoryProvider).deleteSet(set.id),
          ),
        ],
      ),
    );
  }
}