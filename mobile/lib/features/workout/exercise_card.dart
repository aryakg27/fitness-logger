import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/workout_repository.dart';
import 'workout_providers.dart';

/// Card for one exercise in the workout: its name, the logged sets,
/// and inputs to add a new set.
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
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      // Number by position so it stays correct after deleting.
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text('${i + 1}'),
                      ),
                      title: Text('${list[i].weight} kg x ${list[i].reps} reps'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(workoutRepositoryProvider)
                            .deleteSet(list[i].id),
                      ),
                    ),
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
}