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
}
