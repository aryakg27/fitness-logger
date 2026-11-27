import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../library/exercise_providers.dart';
import 'exercise_card.dart';
import 'rest_timer.dart';
import 'workout_providers.dart';

/// Screen shown while a workout is in progress.
class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key, required this.workoutId});

  final int workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Live list of exercises added to this workout so far.
    final items = ref.watch(workoutExercisesProvider(workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          TextButton(
            onPressed: () async {
              // Save the duration (or delete the workout if it is empty).
              await ref.read(workoutRepositoryProvider).finishWorkout(workoutId);
              if (context.mounted) context.go('/home');
            },
            child: const Text('Finish'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Rest timer bar at the top.
          const RestTimer(),
          // Exercise cards fill the rest of the screen.
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text('Tap "Add exercise" to begin'),
                  );
                }
                return ListView.builder(
                  // Extra space so the button doesn't cover the last card.
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: list.length,
                  itemBuilder: (context, index) =>
                      ExerciseCard(item: list[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExercisePicker(context),
        icon: const Icon(Icons.add),
        label: const Text('Add exercise'),
      ),
    );
  }

  /// Opens a bottom sheet listing all exercises. Tapping one adds it.
  void _showExercisePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ExercisePickerSheet(workoutId: workoutId),
    );
  }
}

/// Bottom sheet with the exercise list.
class _ExercisePickerSheet extends ConsumerWidget {
  const _ExercisePickerSheet({required this.workoutId});

  final int workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final e = list[index];
            return ListTile(
              title: Text(e.name),
              subtitle: Text(e.muscleGroup),
              onTap: () async {
                await ref
                    .read(workoutRepositoryProvider)
                    .addExerciseToWorkout(workoutId, e.id);
                // Close the sheet after adding.
                if (context.mounted) Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}