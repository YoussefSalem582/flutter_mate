import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Theme manager to handle theme switching and persistence
class ThemeManager extends GetxController {
  static const String _themeKey = 'theme_mode';

  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;

  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  // Hive box getter for settings
  Box get _settingsBox =>
      Hive.box('progress'); // Reuse progress box for settings

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  /// Load saved theme mode from Hive
  Future<void> _loadThemeMode() async {
    final savedThemeIndex = _settingsBox.get(_themeKey,
        defaultValue: ThemeMode.system.index) as int;
    _themeMode.value = ThemeMode.values[savedThemeIndex];
    Get.changeThemeMode(_themeMode.value);
  }

  /// Save theme mode to Hive
  Future<void> _saveThemeMode(ThemeMode mode) async {
    await _settingsBox.put(_themeKey, mode.index);
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
