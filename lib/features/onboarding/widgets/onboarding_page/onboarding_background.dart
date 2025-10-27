import 'package:flutter/material.dart';
import '../../data/onboarding_item.dart';

/// Animated gradient background that transitions based on the current page.
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({
    super.key,
    required this.item,
    required this.theme,
  });

  final OnboardingItem item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
    );
  }
}
