import 'dart:convert';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  User? _currentUser;

  AuthRepositoryImpl({required this.remote});

  @override
  Future<User?> signIn(
      {required String identifier, required String password}) async {
    final user =
        await remote.signIn(identifier: identifier, password: password);
    _currentUser = user;
    return user;
  }

  @override
  Future<User?> signUp(
      {required String identifier,
      required String password,
      String? name}) async {
    final user = await remote.signUp(
        identifier: identifier, password: password, name: name);
    _currentUser = user;
    return user;
  }

  @override
  Future<bool> isSignedIn() async {
    // For the fake implementation we consider local _currentUser presence.
    if (_currentUser != null) return true;
    final ok = await remote.requestIsSignedIn();
    return ok;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    // Try to restore from SharedPreferences (persisted fake)
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('auth_current_user');
      if (raw == null) return null;
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      final user = User(
        id: data['id'] as int?,
        phone: data['phone'] as String,
        firstName: data['firstName'] as String,
        lastName: data['lastName'] as String,
        email: data['email'] as String?,
        isArtisan: data['isArtisan'] == true,
        isVerified: data['isVerified'] == true,
        idDocumentUrl: data['idDocumentUrl'] as String?,
        selfieUrl: data['selfieUrl'] as String?,
      );
      _currentUser = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await remote.signOut();
  }

  @override
  Future<User?> signInWithGoogle() async {
    final user = await remote.signInWithGoogle();
    _currentUser = user;
    return user;
  }

  @override
  Future<User?> signInWithApple() async {
    final user = await remote.signInWithApple();
    _currentUser = user;
    return user;
  }

  @override
  Future<void> persistCurrentUser(User user) async {
    // Update in-memory
    _currentUser = user;

    // Persist to SharedPreferences as a small JSON blob so verification status survives restarts.
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {
        'id': user.id,
        'phone': user.phone,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'isArtisan': user.isArtisan,
        'isVerified': user.isVerified,
        'idDocumentUrl': user.idDocumentUrl,
        'selfieUrl': user.selfieUrl,
      };
      await prefs.setString('auth_current_user', jsonEncode(data));
    } catch (_) {
      // ignore persistence failures for fake implementation
    }
    return;
  }

  @override
  Future<User?> verifyOtp({required String otp, String? pinId}) async {
    // For non-fake implementation, delegate to remote data source
    // Try to cast to implementation to access OTP methods
    try {
      final impl = remote as dynamic;
      final user = await impl.verifyOtp(otp: otp, pinId: pinId);
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> resendOtp({String? phone}) async {
    try {
      final impl = remote as dynamic;
      return await impl.resendOtp(phone: phone);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      final impl = remote as dynamic;
      await impl.forgotPassword(email: email);
    } catch (e) {
      // Ignore errors for now
    }
  }

  @override
  Future<bool> resetPassword(
      {required String token, required String newPassword}) async {
    try {
      final impl = remote as dynamic;
      return await impl.resetPassword(token: token, newPassword: newPassword);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      final impl = remote as dynamic;
      return await impl.changePassword(
          currentPassword: currentPassword, newPassword: newPassword);
    } catch (e) {
      return false;
    }
  }
}
