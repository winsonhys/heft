import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Navigation item indices
class NavIndex {
  static const home = 0;
  static const history = 1;
  static const progress = 2;
  static const calendar = 3;
  static const profile = 4;
}

/// Shared bottom navigation bar widget using ForUI
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FBottomNavigationBar(
      index: selectedIndex,
      onChange: onTap,
      children: [
        FBottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          label: const Text('Home'),
        ),
        FBottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: const Text('History'),
        ),
        FBottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart_outlined),
          label: const Text('Progress'),
        ),
        FBottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined),
          label: const Text('Calendar'),
        ),
        FBottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          label: const Text('Profile'),
        ),
      ],
    );
  }
}
