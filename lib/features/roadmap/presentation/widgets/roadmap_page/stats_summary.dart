import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/stat_card.dart';

/// Stats summary widget showing lesson counts by difficulty.
///
/// Features:
/// - 3 stat cards in a row (Beginner, Intermediate, Advanced)
/// - Equal width distribution (Expanded widgets)
/// - Spacing between cards (12px)
/// - Icons and colors per difficulty level
/// - Scale animation on entrance (200ms delay)
///
/// Stats Display:
/// - Beginner: 8 Lessons (green, school icon)
/// - Intermediate: 9 Lessons (blue, trending_up icon)
/// - Advanced: 5 Lessons (purple, military_tech icon)
///
/// Layout:
/// - Horizontal row with equal spacing
/// - Responsive to screen width
/// - Maintains proportions across devices
class StatsSummary extends StatelessWidget {
  final bool isDark;

  const StatsSummary({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Beginner',
            value: '8 Lessons',
            icon: Icons.school,
            color: AppColors.success,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Intermediate',
            value: '9 Lessons',
            icon: Icons.trending_up,
            color: AppColors.info,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Advanced',
            value: '5 Lessons',
            icon: Icons.military_tech,
            color: Colors.purple,
            isDark: isDark,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).scale();
  }
}
