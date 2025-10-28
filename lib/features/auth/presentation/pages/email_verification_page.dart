import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../controller/auth_controller.dart';

/// Email verification page
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final AuthController authController = Get.find<AuthController>();
  Timer? _timer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startAutoCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Auto-check email verification every 3 seconds
  void _startAutoCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      authController.checkEmailVerification();
    });
  }

  /// Resend verification email with cooldown
  void _resendEmail() {
    if (_resendCooldown > 0) return;

    authController.resendVerificationEmail();

    setState(() {
      _resendCooldown = 60; // 60 seconds cooldown
    });

    // Start countdown
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Verify Email'),
        actions: [
          TextButton(
            onPressed: () => authController.signOut(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email Icon Animation
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lightPrimary,
                      AppColors.lightPrimary.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2000.ms)
                  .then()
                  .shake(duration: 500.ms, delay: 1000.ms),
              const SizedBox(height: 32),

              // Title
              Text(
                'Check Your Email',
                style: AppTextStyles.h1.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),

              // Description
              Text(
                'We\'ve sent a verification link to your email address. Please click the link to verify your account.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Checking automatically...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),

              // Resend Button
              Obx(() => ElevatedButton.icon(
                    onPressed:
                        authController.isLoading.value || _resendCooldown > 0
                            ? null
                            : _resendEmail,
                    icon: authController.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _resendCooldown > 0
                          ? 'Resend in $_resendCooldown seconds'
                          : 'Resend Verification Email',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),

              // Manual Check Button
              OutlinedButton(
                onPressed: () => authController.checkEmailVerification(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.lightPrimary),
                ),
                child: const Text(
                  'I\'ve Verified - Check Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 24),

              // Help Text
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Not Receiving Email?'),
                      content: const Text(
                        '• Check your spam/junk folder\n'
                        '• Make sure the email address is correct\n'
                        '• Wait a few minutes for the email to arrive\n'
                        '• Try resending the verification email',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Got It'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Not receiving the email?',
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
