import 'package:flutter/material.dart';

/// History screen. Later it will list past workouts grouped by date.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(child: Text('History')),
    );
  }
}