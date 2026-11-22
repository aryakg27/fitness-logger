import 'package:flutter/material.dart';

/// Library screen. Later it will list exercises with search,
/// a muscle-group filter, and a form to add custom exercises.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: const Center(child: Text('Library')),
    );
  }
}