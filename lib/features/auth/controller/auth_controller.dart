import 'package:get/get.dart';
import '../data/services/auth_service.dart';
import '../data/models/app_user.dart';

/// Authentication controller managing auth state
class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Observable state
  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxBool isEmailVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAuthListener();
  }

  /// Initialize auth state listener
  void _initAuthListener() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
        isEmailVerified.value = firebaseUser.emailVerified;

        // Sync progress when user logs in
        await _syncUserProgress();
      } else {
        currentUser.value = null;
        isAuthenticated.value = false;
        isEmailVerified.value = false;
      }
    });
  }

  /// Sync user progress after login
  Future<void> _syncUserProgress() async {
    try {
      // Import ProgressSyncService dynamically to avoid circular dependency
      if (Get.isRegistered<dynamic>()) {
        final syncService = Get.find<dynamic>();
        if (syncService.runtimeType.toString() == 'ProgressSyncService') {
          await syncService.migrateGuestProgress();
          await syncService.autoSync();
        }
      }
    } catch (e) {
      print('❌ Error syncing user progress: $e');
    }
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String uid) async {
    try {
      final profile = await _authService.getUserProfile(uid);
      if (profile != null) {
        currentUser.value = profile;
        isAuthenticated.value = true;
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    if (!_validateSignUp(email, password, username)) return;

    isLoading.value = true;

    final result = await _authService.signUpWithEmail(
      email: email.trim(),
      password: password,
      username: username.trim(),
    );

    isLoading.value = false;

    if (result.isSuccess) {
      Get.snackbar(
        'Success',
        'Account created! Please verify your email.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/email-verification');
    } else {
      Get.snackbar(
        'Error',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (!_validateSignIn(email, password)) return;

    isLoading.value = true;

    final result = await _authService.signInWithEmail(
      email: email.trim(),
      password: password,
    );

    isLoading.value = false;

    if (result.isSuccess) {
      // Check if email is verified
      final verified = await _authService.isEmailVerified();
      if (!verified) {
        Get.snackbar(
          'Email Not Verified',
          'Please verify your email before continuing.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/email-verification');
      } else {
        Get.offAllNamed('/roadmap');
      }
    } else {
      Get.snackbar(
        'Error',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    isLoading.value = true;

    final result = await _authService.signInWithGoogle();

    isLoading.value = false;

    if (result.isSuccess) {
      Get.offAllNamed('/roadmap');
    } else if (!result.isCancelled) {
      Get.snackbar(
        'Error',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Sign in anonymously (guest mode)
  Future<void> signInAsGuest() async {
    isLoading.value = true;

    final result = await _authService.signInAnonymously();

    isLoading.value = false;

    if (result.isSuccess) {
      Get.snackbar(
        'Guest Mode',
        'You\'re signed in as a guest. Sign up to save your progress!',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/roadmap');
    } else {
      Get.snackbar(
        'Error',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    // Clear local progress data
    try {
      if (Get.isRegistered<dynamic>()) {
        final syncService = Get.find<dynamic>();
        if (syncService.runtimeType.toString() == 'ProgressSyncService') {
          await syncService.clearLocalData();
        }
      }
    } catch (e) {
      print('❌ Error clearing local data: $e');
    }

    await _authService.signOut();
    Get.offAllNamed('/login');
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email');
      return;
    }

    isLoading.value = true;

    final result = await _authService.sendPasswordResetEmail(email.trim());

    isLoading.value = false;

    if (result.isSuccess) {
      Get.snackbar(
        'Success',
        'Password reset email sent! Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } else {
      Get.snackbar(
        'Error',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Resend email verification
  Future<void> resendVerificationEmail() async {
    isLoading.value = true;

    final result = await _authService.resendVerificationEmail();

    isLoading.value = false;

    if (result.isSuccess) {
      Get.snackbar(
        'Success',
        'Verification email sent! Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Check email verification status
  Future<void> checkEmailVerification() async {
    try {
      final verified = await _authService.isEmailVerified();
      isEmailVerified.value = verified;

      print('Verification check: $verified'); // Debug log

      if (verified) {
        Get.snackbar(
          'Success',
          'Email verified! Redirecting...',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Navigate to roadmap (main app page)
        Get.offAllNamed('/roadmap');
      } else {
        print('Email not yet verified'); // Debug log
      }
    } catch (e) {
      print('Error checking verification: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await _authService.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    // Reload user profile
    if (currentUser.value != null) {
      await _loadUserProfile(currentUser.value!.id);
    }
  }

  /// Validation helpers
  bool _validateSignUp(String email, String password, String username) {
    if (username.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a username');
      return false;
    }

    if (username.trim().length < 3) {
      Get.snackbar('Error', 'Username must be at least 3 characters');
      return false;
    }

    return _validateSignIn(email, password);
  }

  bool _validateSignIn(String email, String password) {
    if (email.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email');
      return false;
    }

    if (!GetUtils.isEmail(email.trim())) {
      Get.snackbar('Error', 'Please enter a valid email');
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar('Error', 'Please enter your password');
      return false;
    }

    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  /// Check if user is guest
  bool get isGuest => currentUser.value?.provider == AuthProvider.anonymous;

  /// Check if user has premium
  bool get isPremium =>
      currentUser.value?.tier == SubscriptionTier.premium ||
      currentUser.value?.tier == SubscriptionTier.pro;
}
