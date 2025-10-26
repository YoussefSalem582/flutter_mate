import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme manager to handle theme switching and persistence
class ThemeManager extends GetxController {
  static const String _themeKey = 'theme_mode';

  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;

  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  /// Load saved theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode.value = ThemeMode.values[savedThemeIndex];
    Get.changeThemeMode(_themeMode.value);
  }

  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode.value == ThemeMode.light) {
      _themeMode.value = ThemeMode.dark;
    } else {
      _themeMode.value = ThemeMode.light;
    }
    Get.changeThemeMode(_themeMode.value);
    await _saveThemeMode(_themeMode.value);
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    await _saveThemeMode(mode);
  }
}
