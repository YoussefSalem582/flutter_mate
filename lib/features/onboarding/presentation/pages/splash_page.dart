import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';

/// Splash screen shown on app launch
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Icon(
                  Icons.flutter_dash,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                )
                .animate()
                .scale(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(duration: const Duration(milliseconds: 800)),
            const SizedBox(height: 24),
            // App Name
            Text(
                  'FlutterMate',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 600),
                )
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            // Tagline
            Text(
                  'Your Flutter Learning Companion',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 600),
                )
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 48),
            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 900),
              duration: const Duration(milliseconds: 600),
            ),
          ],
        ),
      ),
    );
  }
}
