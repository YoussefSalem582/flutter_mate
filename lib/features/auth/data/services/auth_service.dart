import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_result.dart';
import '../models/app_user.dart'
    show AppUser, AuthProvider, UserPreferences, SubscriptionTier;

/// Authentication service handling all auth operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google Sign-In singleton instance
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // Track if Google Sign-In has been initialized
  bool _googleSignInInitialized = false;

  /// Get current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _createUserProfile(
        uid: credential.user!.uid,
        email: email,
        username: username,
        provider: AuthProvider.email,
      );

      // Send verification email
      await credential.user!.sendEmailVerification();

      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure user profile exists (in case it was created before this logic)
      await _ensureUserProfile(
        user: credential.user!,
        provider: AuthProvider.email,
      );

      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In if not already done
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize();
        _googleSignInInitialized = true;
      }

      // Authenticate the user
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) {
        return AuthResult.cancelled();
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Get authorization for Firebase scopes if needed
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);

      if (authorization == null) {
        return AuthResult.failure('Failed to get authorization');
      }

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user profile
      await _ensureUserProfile(
        user: userCredential.user!,
        provider: AuthProvider.google,
      );

      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Google sign-in failed: $e');
    }
  }

  /// Sign in anonymously (for offline mode)
  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      // Create minimal user profile
      await _createUserProfile(
        uid: credential.user!.uid,
        email: 'anonymous@fluttermate.com',
        username: 'Guest_${credential.user!.uid.substring(0, 8)}',
        provider: AuthProvider.anonymous,
      );

      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Anonymous sign-in failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    // Sign out from Google if initialized
    if (_googleSignInInitialized) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to send reset email: $e');
    }
  }

  /// Resend email verification
  Future<AuthResult> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      await user.sendEmailVerification();
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to send verification email: $e');
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      final isVerified = _auth.currentUser?.emailVerified ?? false;
      // ignore: avoid_print
      print('Email verification status: $isVerified');
      return isVerified;
    } catch (e) {
      // ignore: avoid_print
      print('Error checking email verification: $e');
      return false;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(displayName);
    await user.updatePhotoURL(photoURL);

    // Update Firestore
    await _firestore.collection('users').doc(user.uid).update({
      if (displayName != null) 'displayName': displayName,
      if (photoURL != null) 'photoURL': photoURL,
    });
  }

  /// Get user profile from Firestore
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      return AppUser.fromFirebase(
        uid,
        doc.data()!['email'] as String,
        doc.data()!,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Create user profile in Firestore
  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String username,
    required AuthProvider provider,
  }) async {
    final userData = {
      'id': uid,
      'email': email,
      'username': username,
      'displayName': username,
      'photoURL': null,
      'emailVerified': false,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
      'provider': provider.name,
      'preferences': UserPreferences().toMap(),
      'tier': SubscriptionTier.free.name,
      'lessonsCompleted': 0,
      'totalXP': 0,
      'currentStreak': 0,
      'categoryProgress': {},
      'reputationPoints': 0,
      'questionsAsked': 0,
      'answersGiven': 0,
      'badges': [],
    };

    await _firestore.collection('users').doc(uid).set(userData);
  }

  /// Ensure user profile exists (for social logins)
  Future<void> _ensureUserProfile({
    required User user,
    required AuthProvider provider,
  }) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        // Create new profile
        await _createUserProfile(
          uid: user.uid,
          email: user.email ?? 'no-email@fluttermate.com',
          username: user.displayName ?? 'User_${user.uid.substring(0, 8)}',
          provider: provider,
        );
      } else {
        // Update last login
        await _updateLastLogin(user.uid);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error ensuring user profile: $e');
      // Still try to update last login even if check fails
      await _updateLastLogin(user.uid);
    }
  }

  /// Update last login time
  Future<void> _updateLastLogin(String uid) async {
    // Use set with merge to avoid error if document doesn't exist
    await _firestore.collection('users').doc(uid).set({
      'lastLoginAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  /// Get user-friendly error message
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
