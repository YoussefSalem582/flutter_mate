import 'package:flutter/material.dart';

/// Navigation buttons for onboarding flow (Previous/Next or Start Learning).
class OnboardingNavigationButtons extends StatelessWidget {
  const OnboardingNavigationButtons({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.accentColor,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final Color accentColor;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = currentPage == totalPages - 1;

    return Row(
      children: [
        if (currentPage > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: onPrevious,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
        if (currentPage > 0) const SizedBox(width: 12),
        Expanded(
          flex: currentPage == 0 ? 1 : 1,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(isLastPage ? 'Get Started' : 'Next'),
          ),
        ),
      ],
    );
  }
}
