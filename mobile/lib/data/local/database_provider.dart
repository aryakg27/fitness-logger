import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Gives the whole app one shared AppDatabase (via Riverpod).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Close the database cleanly when this provider is disposed.
  ref.onDispose(db.close);
  return db;
});