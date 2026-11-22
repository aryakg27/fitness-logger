import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exercise_providers.dart';

/// Library screen: shows all exercises with a search box.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  // Text the user typed in the search box.
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // Watch the exercise stream. The screen rebuilds when the data changes.
    final exercises = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search exercises',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          // Exercise list (handles the loading, error and data states)
          Expanded(
            child: exercises.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (list) {
                // Keep only exercises whose name or muscle group matches.
                final q = _query.toLowerCase();
                final filtered = list
                    .where((e) =>
                        e.name.toLowerCase().contains(q) ||
                        e.muscleGroup.toLowerCase().contains(q))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No exercises found'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final e = filtered[index];
                    return ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(e.name),
                      subtitle: Text(e.muscleGroup),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}