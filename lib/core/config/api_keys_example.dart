/// API Keys and sensitive configuration - EXAMPLE FILE
///
/// 📋 SETUP INSTRUCTIONS:
/// 1. Copy this file and rename it to 'api_keys.dart'
/// 2. Replace all placeholder values with your actual API keys
/// 3. The real 'api_keys.dart' is in .gitignore and won't be committed
///
/// 🔐 WHERE TO GET YOUR KEYS:
/// - Firebase: https://console.firebase.google.com/ → Project Settings
/// - Google Sign-In: Firebase Console → Authentication → Sign-in method
/// - OpenAI: https://platform.openai.com/api-keys
/// - Stripe: https://dashboard.stripe.com/apikeys
class ApiKeys {
  ApiKeys._();

  // ========================================
  // FIREBASE CONFIGURATION
  // ========================================
  // Get these from: Firebase Console → Project Settings → General

  // Project Information
  static const String firebaseProjectId = 'your-project-id';
  static const String firebaseProjectNumber = '123456789';
  static const String firebaseStorageBucket =
      'your-project-id.firebasestorage.app';
  static const String firebaseAuthDomain = 'your-project-id.firebaseapp.com';

  // Web Platform Configuration
  static const String firebaseApiKeyWeb =
      'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  static const String firebaseAppIdWeb = '1:123456789:web:abcdef123456789';
  static const String firebaseMessagingSenderIdWeb = '123456789';
  static const String firebaseMeasurementIdWeb = 'G-XXXXXXXXXX';

  // Android Platform Configuration
  static const String firebaseApiKeyAndroid =
      'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  static const String firebaseAppIdAndroid =
      '1:123456789:android:abcdef123456789';
  static const String firebaseMessagingSenderIdAndroid = '123456789';
  static const String androidPackageName = 'com.example.your_app';

  // iOS Platform Configuration
  static const String firebaseApiKeyIos =
      'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  static const String firebaseAppIdIos = '1:123456789:ios:abcdef123456789';
  static const String firebaseMessagingSenderIdIos = '123456789';
  static const String iosBundleId = 'com.example.yourApp';

  // ========================================
  // GOOGLE SIGN-IN
  // ========================================
  // Get from: Firebase Console → Authentication → Sign-in method → Google
  static const String googleClientIdWeb =
      '123456789-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com';
  static const String googleClientIdAndroid =
      '123456789-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com';
  static const String googleClientIdIos =
      '123456789-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com';

  // ========================================
  // ANALYTICS & MONITORING
  // ========================================
  static const String googleAnalyticsId = 'G-XXXXXXXXXX';
  static const String firebaseAnalyticsAppId =
      '1:123456789:web:abcdef123456789';

  // ========================================
  // OPTIONAL: THIRD-PARTY SERVICES
  // ========================================

  // OpenAI (for AI-powered features like assistant)
  static const String openAiApiKey =
      'sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

  // Stripe (for payment processing)
  static const String stripePublishableKey =
      'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

  // Razorpay (alternative payment gateway)
  static const String razorpayKey = 'rzp_test_xxxxxxxxxxxxxxxx';

  // ========================================
  // ENVIRONMENT CONFIGURATION
  // ========================================
  static const bool isProduction = false; // Set to true for production builds
  static const String environment = isProduction ? 'production' : 'development';

  // ========================================
  // VALIDATION
  // ========================================
  /// Checks if API keys have been configured
  static bool get isConfigured {
    return firebaseApiKeyWeb != 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' &&
        firebaseProjectId != 'your-project-id';
  }

  /// Validates that API keys are configured
  /// Throws an exception if keys are not set
  static void validate() {
    if (!isConfigured) {
      throw Exception(
        '❌ API Keys not configured!\n\n'
        'Please follow these steps:\n'
        '1. Copy lib/core/config/api_keys_example.dart\n'
        '2. Rename it to lib/core/config/api_keys.dart\n'
        '3. Replace placeholder values with your actual API keys\n'
        '4. Save the file\n\n'
        'See docs/API_KEYS_SETUP.md for detailed instructions.',
      );
    }
  }
}
