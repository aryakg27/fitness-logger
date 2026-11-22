import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The frame around every main screen: the current tab's screen on top
/// and the bottom navigation bar below.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  /// Provided by go_router. Knows which tab is selected and can switch tabs.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The screen of the currently selected tab.
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // When a tab is tapped, switch to it. Tapping the already selected
        // tab returns to that tab's first screen.
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}