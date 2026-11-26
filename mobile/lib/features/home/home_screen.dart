import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../workout/workout_providers.dart';

/// Home screen. Later it will also show recent workouts.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: FilledButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start workout'),
          onPressed: () async {
            // Create a new workout in the database, then open its screen.
            final id = await ref.read(workoutRepositoryProvider).startWorkout();
            if (context.mounted) context.push('/workout/$id');
          },
        ),
      ),
    );
  }
}