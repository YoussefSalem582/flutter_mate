import 'package:flutter/material.dart';

/// Animated page indicator dots showing current page position.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.activeIndex,
    required this.itemCount,
    required this.accent,
  });

  final int activeIndex;
  final int itemCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 32 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
