import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';

/// Utility class for authentication-related checks and prompts
class AuthUtils {
  AuthUtils._();

  /// Check if user is authenticated (not a guest) without showing dialog
  /// Returns true if authenticated, false if guest
  static bool isAuthenticated() {
    try {
      final authController = Get.find<AuthController>();
      return !authController.isGuest;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is authenticated (not a guest)
  /// If guest, show dialog prompting to sign up
  /// Returns true if authenticated, false if guest
  static bool requireAuth({
    String title = 'Sign In Required',
    String message =
        'Please create an account or sign in to access this feature.',
  }) {
    try {
      final authController = Get.find<AuthController>();

      // If user is a guest, show auth prompt
      if (authController.isGuest) {
        _showAuthRequiredDialog(title: title, message: message);
        return false;
      }

      // User is authenticated
      return true;
    } catch (e) {
      // Auth controller not found, show auth prompt
      _showAuthRequiredDialog(title: title, message: message);
      return false;
    }
  }

  /// Check auth and show dialog after build completes
  /// Safe to call during build phase
  static bool requireAuthSafe({
    String title = 'Sign In Required',
    String message =
        'Please create an account or sign in to access this feature.',
  }) {
    try {
      final authController = Get.find<AuthController>();

      // If user is a guest, schedule dialog to show after build
      if (authController.isGuest) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAuthRequiredDialog(title: title, message: message);
        });
        return false;
      }

      // User is authenticated
      return true;
    } catch (e) {
      // Auth controller not found, schedule dialog to show after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthRequiredDialog(title: title, message: message);
      });
      return false;
    }
  }

  /// Show dialog prompting user to sign up or log in
  static void _showAuthRequiredDialog({
    required String title,
    required String message,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lock_outline,
                color: AppColors.info,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Create a free account to unlock all features',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.warning.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Maybe Later',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.onboarding);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Show a snackbar for features requiring authentication
  static void showAuthRequiredSnackbar({
    String message = 'Please sign in to access this feature',
  }) {
    Get.snackbar(
      'Sign In Required',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      icon: const Icon(Icons.lock_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          Get.offAllNamed(AppRoutes.onboarding);
        },
        child: const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
