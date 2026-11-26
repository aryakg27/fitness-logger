import 'package:go_router/go_router.dart';

import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/workout/active_workout_screen.dart';
import '../../widgets/main_shell.dart';

/// App-wide router. Defines which URL path opens which screen.
final GoRouter appRouter = GoRouter(
  // The app opens on the Home tab.
  initialLocation: '/home',
  routes: [
    // StatefulShellRoute keeps the bottom bar visible and remembers
    // each tab's state when the user switches between tabs.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        // Tab 1: Home
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        ]),
        // Tab 2: History
        StatefulShellBranch(routes: [
          GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
        ]),
        // Tab 3: Library
        StatefulShellBranch(routes: [
          GoRoute(path: '/library', builder: (context, state) => const LibraryScreen()),
        ]),
      ],
    ),
    // Full-screen workout page (outside the tabs, so there is no bottom bar).
    GoRoute(
      path: '/workout/:id',
      builder: (context, state) => ActiveWorkoutScreen(
        workoutId: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);