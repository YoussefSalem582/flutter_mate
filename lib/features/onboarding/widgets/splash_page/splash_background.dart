import 'package:flutter/material.dart';

/// Animated gradient background for splash screen.
class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    required this.theme,
    required this.primary,
  });

  final ThemeData theme;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final surface = theme.colorScheme.surface;

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  primary,
                  surface,
                  theme.brightness == Brightness.dark ? 0.4 : 0.15,
                )!,
                Color.lerp(
                  primary,
                  surface,
                  theme.brightness == Brightness.dark ? 0.75 : 0.5,
                )!,
                surface,
              ],
            ),
          ),
        ),
        Positioned(
          right: -140,
          top: -80,
          child: BackdropOrb(color: primary.withOpacity(0.18), size: 320),
        ),
        Positioned(
          left: -120,
          bottom: -100,
          child: BackdropOrb(color: primary.withOpacity(0.12), size: 280),
        ),
      ],
    );
  }
}

/// Decorative orb for splash background effects.
class BackdropOrb extends StatelessWidget {
  const BackdropOrb({super.key, required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 70,
            spreadRadius: 12,
          ),
        ],
      ),
    );
  }
}
