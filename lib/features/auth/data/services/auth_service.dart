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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
      // Log error details for debugging
      // ignore: avoid_print
      print('Firebase Auth Error [Sign Up]: ${e.code} - ${e.message}');
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      // ignore: avoid_print
      print('Unexpected Error [Sign Up]: $e');
      return AuthResult.failure('Sign-up failed: $e');
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
      // Log error details for debugging
      // ignore: avoid_print
      print('Firebase Auth Error [Sign In]: ${e.code} - ${e.message}');
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      // ignore: avoid_print
      print('Unexpected Error [Sign In]: $e');
      return AuthResult.failure('Sign-in failed: $e');
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.cancelled();
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
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
      // ignore: avoid_print
      print('Firebase Auth Error [Google Sign In]: ${e.code} - ${e.message}');
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      // ignore: avoid_print
      print('Unexpected Error [Google Sign In]: $e');
      return AuthResult.failure('Google sign-in failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    // Sign out from Google and Firebase
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('Firebase Auth Error [Password Reset]: ${e.code} - ${e.message}');
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
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
      // ignore: avoid_print
      print(
          'Firebase Auth Error [Resend Verification]: ${e.code} - ${e.message}');
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
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

  /// Verify current password by re-authenticating
  Future<AuthResult> verifyCurrentPassword(String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      final email = user.email;
      if (email == null) {
        return AuthResult.failure('No email associated with this account');
      }

      // Re-authenticate with current password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      return AuthResult.failure('Password verification failed: $e');
    }
  }

  /// Send verification code to current email before allowing email change
  Future<AuthResult> sendEmailChangeVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      if (user.email == null) {
        return AuthResult.failure('No email associated with this account');
      }

      // Send verification email to current email
      await user.sendEmailVerification();
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      return AuthResult.failure('Failed to send verification: $e');
    }
  }

  /// Update user email with verification code (after verifying current email)
  Future<AuthResult> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      // Check if current email is verified
      await user.reload();
      final reloadedUser = _auth.currentUser;

      if (reloadedUser?.emailVerified == false) {
        return AuthResult.failure('Please verify your current email first');
      }

      // Send verification to new email
      await user.verifyBeforeUpdateEmail(newEmail);

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      return AuthResult.failure('Failed to send verification: $e');
    }
  }

  /// Complete email update after verification
  Future<AuthResult> completeEmailUpdate() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      // Reload user to get updated email
      await user.reload();
      final updatedUser = _auth.currentUser;

      if (updatedUser?.email != null) {
        // Update in Firestore
        await _firestore.collection('users').doc(updatedUser!.uid).update({
          'email': updatedUser.email,
        });
      }

      return AuthResult.success(updatedUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      return AuthResult.failure('Failed to complete email update: $e');
    }
  }

  /// Update user password with old password verification
  Future<AuthResult> updatePassword(
      String oldPassword, String newPassword) async {
    try {
      // First verify old password
      final verifyResult = await verifyCurrentPassword(oldPassword);
      if (!verifyResult.isSuccess) {
        return verifyResult;
      }

      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      await user.updatePassword(newPassword);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      return AuthResult.failure('Failed to update password: $e');
    }
  }

  /// Add phone number to account
  Future<AuthResult> addPhoneNumber(
      String phoneNumber, String verificationId, String smsCode) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      // Create phone credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Link phone to account
      await user.linkWithCredential(credential);

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'phoneNumber': phoneNumber,
      });

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      return AuthResult.failure('Failed to add phone number: $e');
    }
  }

  /// Verify phone number and send SMS code
  Future<String?> verifyPhoneNumber(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          final user = _auth.currentUser;
          if (user != null) {
            await user.linkWithCredential(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_getAuthErrorMessage(e.code, e.message));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout
        },
        timeout: const Duration(seconds: 60),
      );
      return null;
    } catch (e) {
      return 'Failed to verify phone number: $e';
    }
  }

  /// Delete user account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete progress subcollection if exists
      final progressDocs = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .get();

      for (var doc in progressDocs.docs) {
        await doc.reference.delete();
      }

      // Delete Firebase Auth account
      await user.delete();

      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code, e.message));
    } catch (e) {
      return AuthResult.failure('Failed to delete account: $e');
    }
  }

  /// Get user-friendly error message
  String _getAuthErrorMessage(String code, [String? originalMessage]) {
    // For debugging on deployed site, include the error code
    final debugSuffix = ' [Error: $code]';

    switch (code) {
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.$debugSuffix';
      case 'email-already-in-use':
        return 'An account already exists with this email.$debugSuffix';
      case 'invalid-email':
        return 'The email address is invalid.$debugSuffix';
      case 'user-not-found':
        return 'No account found with this email.$debugSuffix';
      case 'wrong-password':
        return 'Incorrect password. Please try again.$debugSuffix';
      case 'user-disabled':
        return 'This account has been disabled.$debugSuffix';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.$debugSuffix';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Console.$debugSuffix';
      case 'network-request-failed':
        return 'Network error. Please check your connection.$debugSuffix';
      case 'unauthorized-domain':
      case 'unauthorized-continue-uri':
        return 'This domain (youssefsalem582.github.io) needs to be added to Firebase Console > Authentication > Authorized domains.$debugSuffix';
      case 'invalid-api-key':
      case 'api-key-not-valid':
        return 'Invalid Firebase API key configuration.$debugSuffix';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication.$debugSuffix';
      case 'invalid-credential':
        return 'Invalid credentials provided.$debugSuffix';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.$debugSuffix';
      default:
        // Show the full error details for unknown errors
        if (originalMessage != null) {
          return 'Error: $originalMessage [Code: $code]';
        }
        return 'An error occurred. Please try again.$debugSuffix';
    }
  }
}
