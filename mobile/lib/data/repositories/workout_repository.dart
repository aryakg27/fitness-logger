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

/// One logged set of an exercise, with the workout it belongs to.
/// Used for the progress chart and PR on the exercise detail screen.
class ExerciseSetRecord {
  const ExerciseSetRecord({
    required this.workoutId,
    required this.date,
    required this.weight,
    required this.reps,
  });

  final int workoutId;
  final DateTime date;
  final double weight;
  final int reps;
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

  /// Finishes a workout by saving how long it took.
  /// An empty workout (no exercises) is deleted instead of saved.
  Future<void> finishWorkout(int workoutId) async {
    final exercises = await (_db.select(_db.workoutExercises)
          ..where((t) => t.workoutId.equals(workoutId)))
        .get();

    if (exercises.isEmpty) {
      await (_db.delete(_db.workouts)..where((t) => t.id.equals(workoutId)))
          .go();
      return;
    }

    // The workout's date is when it started, so duration = now - start.
    final workout = await (_db.select(_db.workouts)
          ..where((t) => t.id.equals(workoutId)))
        .getSingle();
    final elapsed = DateTime.now().difference(workout.date).inSeconds;
    // Store at least 1 second so a finished workout is never hidden.
    final seconds = elapsed < 1 ? 1 : elapsed;

    await (_db.update(_db.workouts)..where((t) => t.id.equals(workoutId)))
        .write(WorkoutsCompanion(durationSeconds: Value(seconds)));
  }

  /// Live list of finished workouts, newest first.
  /// Unfinished workouts (duration 0) are hidden.
  Stream<List<Workout>> watchWorkouts() {
    return (_db.select(_db.workouts)
          ..where((t) => t.durationSeconds.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Live data of one workout (name, date, duration).
  Stream<Workout> watchWorkout(int workoutId) {
    return (_db.select(_db.workouts)..where((t) => t.id.equals(workoutId)))
        .watchSingle();
  }

  /// Live list of every set ever logged for one exercise, oldest first.
  /// Only finished workouts count. Three tables are joined:
  /// set_entries -> workout_exercises -> workouts.
  Stream<List<ExerciseSetRecord>> watchExerciseHistory(int exerciseId) {
    final query = _db.select(_db.setEntries).join([
      innerJoin(
        _db.workoutExercises,
        _db.workoutExercises.id.equalsExp(_db.setEntries.workoutExerciseId),
      ),
      innerJoin(
        _db.workouts,
        _db.workouts.id.equalsExp(_db.workoutExercises.workoutId),
      ),
    ])
      ..where(
        _db.workoutExercises.exerciseId.equals(exerciseId) &
            _db.workouts.durationSeconds.isBiggerThanValue(0),
      )
      ..orderBy([
        OrderingTerm.asc(_db.workouts.date),
        OrderingTerm.asc(_db.setEntries.setNumber),
      ]);

    return query.watch().map(
          (rows) => rows.map((row) {
            final set = row.readTable(_db.setEntries);
            final workout = row.readTable(_db.workouts);
            return ExerciseSetRecord(
              workoutId: workout.id,
              date: workout.date,
              weight: set.weight,
              reps: set.reps,
            );
          }).toList(),
        );
  }
}