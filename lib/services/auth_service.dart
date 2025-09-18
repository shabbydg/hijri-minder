import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../utils/platform_utils.dart';

String _generateNonce([int length = 32]) {
  const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

String _sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Custom authentication exceptions
class AuthException implements Exception {
  final String message;
  final String? code;
  
  AuthException(this.message, [this.code]);
  
  @override
  String toString() => 'AuthException: $message';
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // Temporarily commented out due to API changes
  User? _currentUser;
  StreamSubscription<User?>? _authStateSubscription;
  
  bool _googleAvailable = false;
  bool _appleAvailable = false;

  /// Initialize the authentication service
  Future<void> initialize() async {
    try {
      _currentUser = _auth.currentUser;
      
      // Compute availability during initialization
      _googleAvailable = PlatformUtils.isMobile || PlatformUtils.isWeb;
      _appleAvailable = await _isAppleSignInAvailableAsync();
      
      // Listen to auth state changes
      _authStateSubscription = _auth.authStateChanges().listen((User? user) {
        _currentUser = user;
        debugPrint('AuthService: Auth state changed - User: ${user?.uid ?? 'null'}');
      });
      
      debugPrint('AuthService: Initialized successfully');
    } catch (e) {
      debugPrint('AuthService: Initialization error: $e');
      throw AuthException('Failed to initialize authentication service');
    }
  }
  
  /// Sign up with email and password
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      _currentUser = result.user;
      debugPrint('AuthService: User signed up successfully - ${_currentUser?.uid}');
      return _currentUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Sign up error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected sign up error: $e');
      throw AuthException('An unexpected error occurred during sign up');
    }
  }
  
  /// Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      _currentUser = result.user;
      debugPrint('AuthService: User signed in successfully - ${_currentUser?.uid}');
      return _currentUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Sign in error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected sign in error: $e');
      throw AuthException('An unexpected error occurred during sign in');
    }
  }
  
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('AuthService: Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Password reset error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected password reset error: $e');
      throw AuthException('An unexpected error occurred while sending password reset email');
    }
  }
  
  /// Get the current user
  User? getCurrentUser() {
    return _currentUser ?? _auth.currentUser;
  }

  /// Expose currentUser as a getter for convenience in other services
  User? get currentUser => getCurrentUser();
  
  /// Check if user is signed in
  bool isUserSignedIn() {
    return getCurrentUser() != null;
  }
  
  /// Get authentication state changes stream
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
  
  /// Get current user ID
  String? getCurrentUserId() {
    return getCurrentUser()?.uid;
  }
  
  /// Get current user email
  String? getCurrentUserEmail() {
    return getCurrentUser()?.email;
  }
  
  /// Check if email is verified
  bool isEmailVerified() {
    return getCurrentUser()?.emailVerified ?? false;
  }
  
  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = getCurrentUser();
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('AuthService: Email verification sent');
      } else {
        throw AuthException('No user to verify or email already verified');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Email verification error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected email verification error: $e');
      throw AuthException('Failed to send email verification');
    }
  }
  
  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await user.updatePassword(newPassword);
        debugPrint('AuthService: Password updated successfully');
      } else {
        throw AuthException('No user to update password');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Update password error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected update password error: $e');
      throw AuthException('Failed to update password');
    }
  }
  
  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await user.updateEmail(newEmail.trim());
        debugPrint('AuthService: Email updated successfully');
      } else {
        throw AuthException('No user to update email');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Update email error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected update email error: $e');
      throw AuthException('Failed to update email');
    }
  }
  
  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await user.delete();
        _currentUser = null;
        debugPrint('AuthService: User account deleted successfully');
      } else {
        throw AuthException('No user to delete');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Delete account error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected delete account error: $e');
      throw AuthException('Failed to delete account');
    }
  }
  
  /// Handle Firebase authentication exceptions
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email address', e.code);
      case 'wrong-password':
        return AuthException('Incorrect password', e.code);
      case 'email-already-in-use':
        return AuthException('An account already exists with this email', e.code);
      case 'weak-password':
        return AuthException('Password is too weak. Please choose a stronger password', e.code);
      case 'invalid-email':
        return AuthException('Invalid email address', e.code);
      case 'user-disabled':
        return AuthException('This account has been disabled', e.code);
      case 'too-many-requests':
        return AuthException('Too many failed attempts. Please try again later', e.code);
      case 'operation-not-allowed':
        return AuthException('This operation is not allowed', e.code);
      case 'invalid-credential':
        return AuthException('Invalid credentials provided', e.code);
      case 'requires-recent-login':
        return AuthException('This operation requires recent authentication. Please sign in again', e.code);
      case 'network-request-failed':
        return AuthException('Network error. Please check your internet connection', e.code);
      case 'account-exists-with-different-credential':
        return AuthException('This account is already linked to another sign-in method', e.code);
      case 'credential-already-in-use':
        return AuthException('This account is already linked to another sign-in method', e.code);
      default:
        return AuthException(e.message ?? 'An authentication error occurred', e.code);
    }
  }
  
  /// Dispose resources
  void dispose() {
    _authStateSubscription?.cancel();
    debugPrint('AuthService: Disposed');
  }
  
  /// Get user display name
  String? getUserDisplayName() {
    return getCurrentUser()?.displayName;
  }
  
  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await user.updateDisplayName(displayName.trim());
        debugPrint('AuthService: Display name updated successfully');
      } else {
        throw AuthException('No user to update display name');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Update display name error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected update display name error: $e');
      throw AuthException('Failed to update display name');
    }
  }
  
  /// Check if user is anonymous
  bool isAnonymous() {
    return getCurrentUser()?.isAnonymous ?? false;
  }
  
  /// Get user creation time
  DateTime? getUserCreationTime() {
    return getCurrentUser()?.metadata.creationTime;
  }
  
  /// Get last sign in time
  DateTime? getLastSignInTime() {
    return getCurrentUser()?.metadata.lastSignInTime;
  }

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available on this platform
      if (!isGoogleSignInAvailable()) {
        throw AuthException('Google Sign-In is not available on this platform', 'google-not-available');
      }

      // TEMPORARILY DISABLED DUE TO API CHANGES
      throw AuthException('Google Sign-In temporarily disabled due to API changes', 'google-temporarily-disabled');
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Google sign-in error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected Google sign-in error: $e');
      if (e.toString().contains('cancelled')) {
        throw AuthException('Google sign-in was cancelled', 'google-cancelled');
      }
      throw AuthException('Google sign-in failed. Please try again.', 'google-failed');
    }
  }

  /// Sign in with Apple
  Future<User?> signInWithApple() async {
    try {
      // Check if Apple Sign-In is available on this platform
      if (!isAppleSignInAvailable()) {
        throw AuthException('Apple Sign-In is not available on this platform', 'apple-not-available');
      }

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create Firebase credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase with the Apple credential
      final userCred = await _auth.signInWithCredential(oauthCredential);
      
      _currentUser = userCred.user;
      debugPrint('AuthService: User signed in with Apple successfully - ${_currentUser?.uid}');
      
      // Optionally update display name if Apple provides it on first sign-in
      if (_currentUser != null && 
          _currentUser!.displayName == null && 
          (appleCredential.givenName != null || appleCredential.familyName != null)) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty) {
          await _currentUser!.updateDisplayName(displayName);
        }
      }
      
      return _currentUser;
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('AuthService: Apple sign-in error: ${e.code} - ${e.message}');
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw AuthException('Apple sign-in was cancelled', 'apple-cancelled');
        case AuthorizationErrorCode.failed:
          throw AuthException('Apple sign-in failed', 'apple-failed');
        case AuthorizationErrorCode.invalidResponse:
          throw AuthException('Invalid response from Apple', 'apple-invalid-response');
        case AuthorizationErrorCode.notHandled:
          throw AuthException('Apple sign-in not handled', 'apple-not-handled');
        case AuthorizationErrorCode.unknown:
          throw AuthException('Unknown Apple sign-in error', 'apple-unknown');
        default:
          throw AuthException('Apple sign-in failed. Please try again.', 'apple-failed');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService: Apple sign-in Firebase error: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected Apple sign-in error: $e');
      throw AuthException('Apple sign-in failed. Please try again.', 'apple-failed');
    }
  }

  /// Check if Apple Sign-In is available on the current platform (async)
  Future<bool> _isAppleSignInAvailableAsync() async {
    try {
      if (PlatformUtils.isWeb) return false; // unless you've configured web explicitly
      return await SignInWithApple.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Check if Google Sign-In is available (public method)
  bool isGoogleSignInAvailable() {
    return _googleAvailable;
  }

  /// Check if Apple Sign-In is available (public method)
  bool isAppleSignInAvailable() {
    return _appleAvailable;
  }

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();
      
      // Sign out from Google if user was signed in with Google - TEMPORARILY DISABLED
      // if (await _googleSignIn.isSignedIn) {
      //   await _googleSignIn.signOut();
      // }
      
      _currentUser = null;
      debugPrint('AuthService: User signed out successfully from all providers');
    } catch (e) {
      debugPrint('AuthService: Sign out error: $e');
      throw AuthException('Failed to sign out');
    }
  }
}
