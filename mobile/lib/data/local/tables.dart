import 'package:drift/drift.dart';

/// Table of exercises (bench press, squat...). Includes built-in
/// exercises and custom ones created by the user.
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get muscleGroup => text()();
  // true when the user created this exercise themselves.
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

/// One row per workout session (for example "Push Day" on 12 Nov).
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant('Workout'))();
  DateTimeColumn get date => dateTime()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
}

/// Links an exercise to a workout (which exercises were done in a session).
/// orderIndex keeps the exercises in the order the user added them.
class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Deleting a workout also deletes its exercises (cascade).
  IntColumn get workoutId =>
      integer().references(Workouts, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();
}

/// One row per set (for example set 2: 60 kg x 8 reps).
class SetEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Deleting a workout exercise also deletes its sets (cascade).
  IntColumn get workoutExerciseId => integer()
      .references(WorkoutExercises, #id, onDelete: KeyAction.cascade)();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
}