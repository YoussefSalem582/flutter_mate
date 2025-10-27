import 'package:flutter/material.dart';

/// Data model representing an onboarding slide.
class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String callout;
  final List<String> highlights;
  final List<String> badges;

  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.callout,
    this.highlights = const [],
    this.badges = const [],
  });
}
