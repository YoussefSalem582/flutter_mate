import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/core/constants/app_assets.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import 'package:hive/hive.dart';

/// Splash screen shown on app launch.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    try {
      // Check authentication status first
      final authController = Get.find<AuthController>();

      // Wait a bit for auth state to be determined
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user has seen onboarding
      final progressBox = Hive.box('progress');
      final hasSeenOnboarding =
          progressBox.get('hasSeenOnboarding', defaultValue: false) as bool;

      if (authController.isAuthenticated.value) {
        // User is logged in - go straight to roadmap (home)
        Get.offAllNamed(AppRoutes.roadmap);
      } else if (!hasSeenOnboarding) {
        // First time user - show onboarding
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        // User has seen onboarding but not logged in - go to login
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      // If auth controller is not initialized, show onboarding
      final progressBox = Hive.box('progress');
      final hasSeenOnboarding =
          progressBox.get('hasSeenOnboarding', defaultValue: false) as bool;

      if (!hasSeenOnboarding) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 48 : 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Column(
                            children: [
                              // Logo Image
                              Image.asset(
                                AppAssets.appLogo,
                                width: isDesktop ? 320 : 260,
                                height: isDesktop ? 320 : 260,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to icon if image not found
                                  return Container(
                                    width: isDesktop ? 160 : 120,
                                    height: isDesktop ? 160 : 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primary.withOpacity(0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withOpacity(0.2),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.flutter_dash,
                                      size: isDesktop ? 80 : 64,
                                      color: primary,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: isDesktop ? 24 : 20),
                              Text(
                                'Your Flutter learning companion',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color:
                                      theme.colorScheme.onSurface.withOpacity(
                                    0.7,
                                  ),
                                  fontSize: isDesktop ? 20 : null,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 2000),
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              width: double.infinity,
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: isDesktop ? 6 : 4,
                                backgroundColor: theme.colorScheme.onSurface
                                    .withOpacity(0.1),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your learning journey...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                              fontSize: isDesktop ? 16 : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
