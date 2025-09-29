import 'dart:async';

import '../../domain/entities/user.dart';

/// Fake remote data source for auth flows. Keeps an in-memory map of users
/// keyed by identifier (email/phone). This is suitable for local dev and tests.
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceFake implements AuthRemoteDataSource {
  final Map<String, String> _credentials = {}; // identifier -> password
  final Map<String, User> _users = {}; // identifier -> User

  String _nextId() => DateTime.now().millisecondsSinceEpoch.toString();

  /// Simulate network latency
  Future<T> _withDelay<T>(T result) =>
      Future.delayed(const Duration(milliseconds: 250), () => result);

  @override
  Future<User?> signIn(
      {required String identifier, required String password}) async {
    if (!_credentials.containsKey(identifier)) {
      return _withDelay(null);
    }
    final stored = _credentials[identifier]!;
    if (stored != password) {
      return _withDelay(null);
    }
    return _withDelay(_users[identifier]);
  }

  @override
  Future<User?> signUp(
      {required String identifier,
      required String password,
      String? name}) async {
    if (_credentials.containsKey(identifier)) {
      return _withDelay(null); // already exists
    }
    final id = int.parse(_nextId());
    final nameParts = name?.split(' ') ?? ['', ''];
    final firstName = nameParts.isNotEmpty ? nameParts[0] : 'User';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final user = User(
      id: id,
      phone: identifier.contains('@') ? '+1234567890' : identifier,
      firstName: firstName,
      lastName: lastName,
      email: identifier.contains('@') ? identifier : null,
      isArtisan: true,
      // new users are unverified by default
      isVerified: false,
      isPhoneVerified: false,
      isEmailVerified: false,
      idDocumentUrl: null,
      selfieUrl: null,
    );
    _credentials[identifier] = password;
    _users[identifier] = user;
    return _withDelay(user);
  }

  @override
  Future<bool> requestIsSignedIn() async {
    // Fake remote doesn't track sessions; return true to indicate remote ok.
    return _withDelay(true);
  }

  @override
  Future<User?> fetchUser(String identifier) async {
    return _withDelay(_users[identifier]);
  }

  @override
  Future<void> signOut() async {
    // No-op for fake remote
    return _withDelay(null);
  }

  @override
  Future<User?> signInWithGoogle() async {
    // Create or return a demo Google user
    const identifier = 'google_demo_user';
    if (!_users.containsKey(identifier)) {
      final id = int.parse(_nextId());
      final user = User(
        id: id,
        phone: '+1234567890',
        firstName: 'Google',
        lastName: 'User',
        email: 'google@example.com',
        isArtisan: true,
        isVerified: false,
        isPhoneVerified: true,
        isEmailVerified: true,
      );
      _users[identifier] = user;
      _credentials[identifier] = 'oauth_google';
    }
    return _withDelay(_users[identifier]);
  }

  @override
  Future<User?> signInWithApple() async {
    const identifier = 'apple_demo_user';
    if (!_users.containsKey(identifier)) {
      final id = int.parse(_nextId());
      final user = User(
        id: id,
        phone: '+1234567891',
        firstName: 'Apple',
        lastName: 'User',
        email: 'apple@example.com',
        isArtisan: true,
        isVerified: false,
        isPhoneVerified: true,
        isEmailVerified: true,
      );
      _users[identifier] = user;
      _credentials[identifier] = 'oauth_apple';
    }
    return _withDelay(_users[identifier]);
  }

  @override
  Future<User?> verifyOtp({required String otp, String? pinId}) async {
    // For fake implementation, always succeed with a simple check
    if (otp == '123456' || otp == '000000') {
      // Return a verified fake user
      final user = User(
        id: int.parse(_nextId()),
        phone: '+1234567890',
        firstName: 'Verified',
        lastName: 'User',
        email: 'verified@example.com',
        isArtisan: true,
        isVerified: true,
        isPhoneVerified: true,
        isEmailVerified: true,
      );
      return _withDelay(user);
    }
    return _withDelay(null);
  }

  @override
  Future<bool> resendOtp({String? phone}) async {
    // For fake implementation, always succeed
    return _withDelay(true);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    // For fake implementation, just simulate delay
    await _withDelay(null);
  }

  @override
  Future<bool> resetPassword({required String token, required String newPassword}) async {
    // For fake implementation, always succeed
    return _withDelay(true);
  }

  @override
  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    // For fake implementation, always succeed
    return _withDelay(true);
  }
}
