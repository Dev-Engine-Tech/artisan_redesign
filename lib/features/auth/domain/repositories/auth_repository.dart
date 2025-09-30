import '../entities/user.dart';

abstract class AuthRepository {
  /// Attempts to sign in using email/phone + password.
  /// Returns the authenticated User on success, or null on failure.
  Future<User?> signIn({required String identifier, required String password});

  /// Attempts to create a new account using email/phone + password.
  /// Returns the created User on success, or null on failure.
  Future<User?> signUp(
      {required String identifier, required String password, String? name});

  /// Returns whether a user is currently signed in.
  Future<bool> isSignedIn();

  /// Returns the currently signed in user, if any.
  Future<User?> getCurrentUser();

  /// Signs out the current user.
  Future<void> signOut();

  /// Sign in with Google (returns User on success).
  Future<User?> signInWithGoogle();

  /// Sign in with Apple (returns User on success). May be a no-op on non-iOS.
  Future<User?> signInWithApple();

  /// Persist an updated current user (e.g., mark verified) in the repository.
  /// Implementations may persist to memory or a local store.
  Future<void> persistCurrentUser(User user);

  /// Verify OTP for phone number verification
  Future<User?> verifyOtp({required String otp, String? pinId});

  /// Resend OTP for phone number verification
  Future<bool> resendOtp({String? phone});

  /// Request password reset via email
  Future<void> forgotPassword({required String email});

  /// Reset password using token
  Future<bool> resetPassword(
      {required String token, required String newPassword});

  /// Change password for authenticated user
  Future<bool> changePassword(
      {required String currentPassword, required String newPassword});
}
