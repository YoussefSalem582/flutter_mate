import 'package:flutter/material.dart';

/// Progress indicator and status pills for splash screen.
class SplashLoadingSection extends StatelessWidget {
  const SplashLoadingSection({
    super.key,
    required this.theme,
    required this.primary,
  });

  final ThemeData theme;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 2400),
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Setting up your workspace...',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.65),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PreparationPill(icon: Icons.school_rounded, label: 'Lessons'),
            SizedBox(width: 8),
            PreparationPill(icon: Icons.auto_graph_rounded, label: 'Progress'),
            SizedBox(width: 8),
            PreparationPill(icon: Icons.smart_toy_rounded, label: 'Assistant'),
          ],
        ),
      ],
    );
  }
}

/// Pill-shaped status indicator showing preparation stages.
class PreparationPill extends StatelessWidget {
  const PreparationPill({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withOpacity(0.65);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
