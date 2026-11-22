import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/local/database_provider.dart';

/// Live list of all exercises, sorted by name.
/// It is a stream, so the screen updates automatically when data changes.
final exercisesProvider = StreamProvider<List<Exercise>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.exercises)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();
});