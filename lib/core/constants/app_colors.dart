import 'package:flutter/material.dart';

/// App color constants for light and dark themes
class AppColors {
  AppColors._();

  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF2196F3);
  static const Color lightSecondary = Color(0xFF03DAC6);
  static const Color lightAccent = Color(0xFF00BCD4);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightOnSurface = Color(0xFF000000);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF00897B);
  static const Color darkSecondary = Color(0xFF03DAC6);
  static const Color darkAccent = Color(0xFF26A69A);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Progress Colors
  static const Color progressBeginnerStart = Color(0xFF4CAF50);
  static const Color progressBeginnerEnd = Color(0xFF8BC34A);
  static const Color progressIntermediateStart = Color(0xFF2196F3);
  static const Color progressIntermediateEnd = Color(0xFF00BCD4);
  static const Color progressAdvancedStart = Color(0xFF9C27B0);
  static const Color progressAdvancedEnd = Color(0xFFE91E63);
}
