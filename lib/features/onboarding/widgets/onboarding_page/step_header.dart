import 'package:flutter/material.dart';

/// Progress indicator showing current step with a linear progress bar.
class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.step,
    required this.total,
    required this.accent,
  });

  final int step;
  final int total;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = step / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 4,
        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
      ),
    );
  }
}
