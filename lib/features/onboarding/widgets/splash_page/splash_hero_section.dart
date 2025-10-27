import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated hero section with app icon and messaging for splash screen.
class SplashHeroSection extends StatelessWidget {
  const SplashHeroSection({
    super.key,
    required this.theme,
    required this.primary,
    required this.isWide,
  });

  final ThemeData theme;
  final Color primary;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedIcon(),
        const SizedBox(height: 32),
        _buildHeadline(),
        const SizedBox(height: 16),
        _buildSubtitle(),
      ],
    );
  }

  Widget _buildAnimatedIcon() {
    return Container(
          width: isWide ? 160 : 140,
          height: isWide ? 160 : 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [primary.withOpacity(0.18), primary.withOpacity(0.05)],
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.25),
                blurRadius: 40,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Icon(
            Icons.flutter_dash,
            size: isWide ? 96 : 88,
            color: primary,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 0.96,
          end: 1.04,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
        )
        .then(delay: const Duration(milliseconds: 200))
        .shimmer(duration: const Duration(milliseconds: 900));
  }

  Widget _buildHeadline() {
    return Text(
          "Let's build something brilliant",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 500),
        )
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 16),
      child:
          Text(
                'Personalizing your learning path, syncing progress, and warming up the assistant.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 350),
                duration: const Duration(milliseconds: 520),
              )
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
    );
  }
}
