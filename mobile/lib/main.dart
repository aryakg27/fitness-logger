import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';

/// Entry point of the app. Flutter starts running here.
void main() {
  // ProviderScope enables Riverpod (state management) for the whole app.
  runApp(const ProviderScope(child: FitnessLoggerApp()));
}

/// Root widget of the app: sets the title, theme and navigation.
class FitnessLoggerApp extends StatelessWidget {
  const FitnessLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router connects the app to go_router for navigation.
    return MaterialApp.router(
      title: 'Fitness Logger',
      // Material 3 theme generated from a single seed color.
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      routerConfig: appRouter,
    );
  }
}