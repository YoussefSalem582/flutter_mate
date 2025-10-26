import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper utility functions
class Helpers {
  Helpers._();

  /// Show a success snackbar
  static void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show an error snackbar
  static void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show an info snackbar
  static void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Calculate percentage
  static double calculatePercentage(int completed, int total) {
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return '$hours:$minutes';
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Validate if string is empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
