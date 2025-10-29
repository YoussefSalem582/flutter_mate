import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/constants/app_assets.dart';
import '../../data/onboarding_item.dart';

/// Main content card for each onboarding slide with icon, text, and features.
class OnboardingContentCard extends StatelessWidget {
  const OnboardingContentCard({
    super.key,
    required this.item,
    required this.isWide,
    required this.availableHeight,
  });

  final OnboardingItem item;
  final bool isWide;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo at the top
            Image.asset(
              AppAssets.appLogo,
              width: isWide ? 100 : 80,
              height: isWide ? 100 : 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300))
                .slideY(
                    begin: -0.2, duration: const Duration(milliseconds: 400)),
            const SizedBox(height: 24),
            _buildIllustration(theme),
            const SizedBox(height: 48),
            _buildTitle(theme, onSurface),
            const SizedBox(height: 16),
            _buildDescription(theme, onSurface),
            if (item.highlights.isNotEmpty) ...[
              const SizedBox(height: 32),
              ..._buildHighlights(theme, onSurface),
            ],
            if (item.badges.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildBadges(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withOpacity(0.1),
      ),
      child: Icon(item.icon, size: 64, color: theme.colorScheme.primary),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400)).scale(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
  }

  Widget _buildTitle(ThemeData theme, Color onSurface) {
    return Text(
      item.title,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme, Color onSurface) {
    return Text(
      item.description,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: onSurface.withOpacity(0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _buildHighlights(ThemeData theme, Color onSurface) {
    return item.highlights.asMap().entries.map((entry) {
      final index = entry.key;
      final highlight = entry.value;

      return Padding(
        padding: EdgeInsets.only(
          bottom: index == item.highlights.length - 1 ? 0 : 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.check,
                color: theme.colorScheme.primary,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                highlight,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onSurface.withOpacity(0.75),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildBadges(ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: item.badges
          .map(
            (badge) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                badge,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
