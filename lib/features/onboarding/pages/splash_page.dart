import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';

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

    // Check if user has seen onboarding
    final prefs = Get.find<SharedPreferences>();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Check authentication status
    final authController = Get.find<AuthController>();

    if (!hasSeenOnboarding) {
      // First time user - show onboarding
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (authController.isAuthenticated.value) {
      // User is logged in - go to roadmap (home)
      Get.offAllNamed(AppRoutes.roadmap);
    } else {
      // User has seen onboarding but not logged in - go to login
      Get.offAllNamed(AppRoutes.login);
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
                              Container(
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
                              ),
                              SizedBox(height: isDesktop ? 48 : 40),
                              Text(
                                'FlutterMate',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                  letterSpacing: 0.5,
                                  fontSize: isDesktop ? 48 : null,
                                ),
                              ),
                              const SizedBox(height: 12),
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
