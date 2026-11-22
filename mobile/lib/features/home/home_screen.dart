import 'package:flutter/material.dart';

/// Home screen. Later it will show recent workouts and a
/// "Start workout" button. For now it is a placeholder.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home')),
    );
  }
}