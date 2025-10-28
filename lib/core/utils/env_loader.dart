import 'dart:io';

/// Loads environment variables from .env file
/// This is used for local development only
class EnvLoader {
  static Map<String, String> _envVars = {};

  /// Load environment variables from .env file
  static Future<void> load() async {
    try {
      final file = File('.env');
      if (await file.exists()) {
        final lines = await file.readAsLines();
        for (var line in lines) {
          line = line.trim();
          // Skip empty lines and comments
          if (line.isEmpty || line.startsWith('#')) continue;

          // Parse KEY=VALUE format
          final separatorIndex = line.indexOf('=');
          if (separatorIndex > 0) {
            final key = line.substring(0, separatorIndex).trim();
            final value = line.substring(separatorIndex + 1).trim();
            _envVars[key] = value;
          }
        }
        print('✅ Environment variables loaded from .env file');
      } else {
        print('⚠️ No .env file found - using default values');
      }
    } catch (e) {
      print('⚠️ Error loading .env file: $e');
    }
  }

  /// Get environment variable value
  static String? get(String key) {
    // First try to get from system environment
    final systemValue = Platform.environment[key];
    if (systemValue != null && systemValue.isNotEmpty) {
      return systemValue;
    }

    // Then try from loaded .env file
    return _envVars[key];
  }

  /// Get environment variable with default value
  static String getOrDefault(String key, String defaultValue) {
    return get(key) ?? defaultValue;
  }
}
