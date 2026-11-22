import 'app_database.dart';

/// Starter exercises as (name, muscle group).
const _starterExercises = <(String, String)>[
  ('Bench Press', 'Chest'),
  ('Incline Dumbbell Press', 'Chest'),
  ('Push-Up', 'Chest'),
  ('Chest Fly', 'Chest'),
  ('Deadlift', 'Back'),
  ('Pull-Up', 'Back'),
  ('Barbell Row', 'Back'),
  ('Lat Pulldown', 'Back'),
  ('Squat', 'Legs'),
  ('Leg Press', 'Legs'),
  ('Lunges', 'Legs'),
  ('Romanian Deadlift', 'Legs'),
  ('Calf Raise', 'Legs'),
  ('Overhead Press', 'Shoulders'),
  ('Lateral Raise', 'Shoulders'),
  ('Face Pull', 'Shoulders'),
  ('Barbell Curl', 'Arms'),
  ('Hammer Curl', 'Arms'),
  ('Tricep Pushdown', 'Arms'),
  ('Skull Crusher', 'Arms'),
  ('Plank', 'Core'),
  ('Crunch', 'Core'),
  ('Hanging Leg Raise', 'Core'),
];

/// Inserts the starter exercises. Runs only once, when the database is created.
Future<void> seedExercises(AppDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(db.exercises, [
      for (final e in _starterExercises)
        ExercisesCompanion.insert(name: e.$1, muscleGroup: e.$2),
    ]);
  });
}