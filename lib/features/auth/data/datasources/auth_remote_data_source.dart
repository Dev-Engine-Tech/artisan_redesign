import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User?> signIn({required String identifier, required String password});
  Future<User?> signUp(
      {required String identifier, required String password, String? name});
  Future<bool> requestIsSignedIn();
  Future<User?> fetchUser(String identifier);
  Future<void> signOut();
  Future<User?> signInWithGoogle();
  Future<User?> signInWithApple();

  // OTP verification methods
  Future<User?> verifyOtp({required String otp, String? pinId});
  Future<bool> resendOtp({String? phone});

  // Password management methods
  Future<void> forgotPassword({required String email});
  Future<bool> resetPassword(
      {required String token, required String newPassword});
  Future<bool> changePassword(
      {required String currentPassword, required String newPassword});
}
