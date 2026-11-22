import 'package:drift/drift.dart';

import '../local/app_database.dart';

/// One exercise inside a workout (used by the Active Workout screen).
class WorkoutExerciseItem {
  const WorkoutExerciseItem({
    required this.workoutExerciseId,
    required this.exercise,
  });

  final int workoutExerciseId;
  final Exercise exercise;
}

/// All database operations for workouts and sets.
class WorkoutRepository {
  WorkoutRepository(this._db);

  final AppDatabase _db;

  /// Creates a new empty workout dated now and returns its id.
  Future<int> startWorkout() {
    return _db
        .into(_db.workouts)
        .insert(WorkoutsCompanion.insert(date: DateTime.now()));
  }

  /// Adds an exercise to a workout, placed after the existing ones.
  Future<void> addExerciseToWorkout(int workoutId, int exerciseId) async {
    final existing = await (_db.select(_db.workoutExercises)
          ..where((t) => t.workoutId.equals(workoutId)))
        .get();
    await _db.into(_db.workoutExercises).insert(
          WorkoutExercisesCompanion.insert(
            workoutId: workoutId,
            exerciseId: exerciseId,
            orderIndex: existing.length,
          ),
        );
  }

  /// Live list of the exercises in a workout, in the order they were added.
  /// A join is used so each row also carries the exercise name.
  Stream<List<WorkoutExerciseItem>> watchWorkoutExercises(int workoutId) {
    final query = _db.select(_db.workoutExercises).join([
      innerJoin(
        _db.exercises,
        _db.exercises.id.equalsExp(_db.workoutExercises.exerciseId),
      ),
    ])
      ..where(_db.workoutExercises.workoutId.equals(workoutId))
      ..orderBy([OrderingTerm.asc(_db.workoutExercises.orderIndex)]);

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => WorkoutExerciseItem(
                  workoutExerciseId: row.readTable(_db.workoutExercises).id,
                  exercise: row.readTable(_db.exercises),
                ),
              )
              .toList(),
        );
  }

  /// Saves one set (weight and reps) for an exercise in a workout.
  /// The set number is the next number after the existing sets.
  Future<void> addSet({
    required int workoutExerciseId,
    required double weight,
    required int reps,
  }) async {
    final existing = await (_db.select(_db.setEntries)
          ..where((t) => t.workoutExerciseId.equals(workoutExerciseId)))
        .get();
    await _db.into(_db.setEntries).insert(
          SetEntriesCompanion.insert(
            workoutExerciseId: workoutExerciseId,
            setNumber: existing.length + 1,
            weight: weight,
            reps: reps,
          ),
        );
  }

  /// Live list of the sets of one exercise, in the order they were logged.
  Stream<List<SetEntry>> watchSets(int workoutExerciseId) {
    return (_db.select(_db.setEntries)
          ..where((t) => t.workoutExerciseId.equals(workoutExerciseId))
          ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
        .watch();
  }

  /// Deletes one set by its id.
  Future<void> deleteSet(int setId) {
    return (_db.delete(_db.setEntries)..where((t) => t.id.equals(setId))).go();
  }
}