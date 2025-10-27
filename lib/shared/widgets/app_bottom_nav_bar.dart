import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';

/// Shared bottom navigation bar for all main screens
///
/// This widget provides consistent navigation across the app.
/// It automatically highlights the current route.
class AppBottomNavBar extends StatelessWidget {
  /// The current active index (0: Roadmap, 1: Progress, 2: Assistant, 3: Profile)
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Roadmap'),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assistant),
          label: 'Assistant',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) => _onItemTapped(index),
    );
  }

  void _onItemTapped(int index) {
    // Don't navigate if already on the current page
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.roadmap);
        break;
      case 1:
        Get.offNamed(AppRoutes.progressTracker);
        break;
      case 2:
        Get.offNamed(AppRoutes.assistant);
        break;
      case 3:
        Get.offNamed(AppRoutes.profile);
        break;
    }
  }
}
