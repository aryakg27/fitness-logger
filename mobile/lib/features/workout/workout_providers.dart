import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';
import '../../data/repositories/workout_repository.dart';

/// Gives screens access to the WorkoutRepository.
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(ref.watch(databaseProvider));
});

/// Live list of exercises in one workout. The parameter is the workout id.
final workoutExercisesProvider =
    StreamProvider.family<List<WorkoutExerciseItem>, int>((ref, workoutId) {
  return ref.watch(workoutRepositoryProvider).watchWorkoutExercises(workoutId);
});

/// Live list of sets for one exercise in a workout.
/// The parameter is the workoutExerciseId.
final setsProvider =
    StreamProvider.family<List<SetEntry>, int>((ref, workoutExerciseId) {
  return ref.watch(workoutRepositoryProvider).watchSets(workoutExerciseId);
});
/// Live list of finished workouts for the History screen.
final workoutHistoryProvider = StreamProvider<List<Workout>>((ref) {
  return ref.watch(workoutRepositoryProvider).watchWorkouts();
});

/// Live data of one workout. The parameter is the workout id.
final workoutProvider = StreamProvider.family<Workout, int>((ref, workoutId) {
  return ref.watch(workoutRepositoryProvider).watchWorkout(workoutId);
});
/// Live list of every logged set for one exercise (the parameter is the exercise id).
final exerciseHistoryProvider =
    StreamProvider.family<List<ExerciseSetRecord>, int>((ref, exerciseId) {
  return ref.watch(workoutRepositoryProvider).watchExerciseHistory(exerciseId);
});