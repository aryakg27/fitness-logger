import 'package:intl/intl.dart';

/// Turns seconds into text like "45 min" (or "<1 min").
String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  return minutes < 1 ? '<1 min' : '$minutes min';
}

/// Turns a date into text like "Fri, 27 Nov 2026".
String formatDate(DateTime date) => DateFormat('EEE, d MMM yyyy').format(date);