import 'dart:convert';
import 'package:flutter/foundation.dart';

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
    if (_currentUser != null) {
      debugPrint('🔄 Returning cached user from memory');
      return _currentUser;
    }

    // Try to restore from SharedPreferences (persisted fake)
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('logged_in_user');

      if (kDebugMode) {
        debugPrint(
            '📖 Reading user from SharedPreferences with key: logged_in_user');
        debugPrint('📖 Raw data found: ${raw != null ? "YES" : "NO"}');
      }

      if (raw == null) return null;
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint('📖 Parsed JSON keys: ${data.keys.toList()}');
        debugPrint('📖 User ID from storage: ${data['id']}');
        debugPrint('📖 User phone from storage: ${data['phone']}');
      }
      final user = User(
        id: data['id'] as int?,
        phone: (data['phone'] ?? '').toString(),
        firstName: (data['first_name'] ?? '').toString(),
        lastName: (data['last_name'] ?? '').toString(),
        email: data['email'] as String?,
        isArtisan: data['is_artisan'] == true,
        isVerified: data['is_verified'] == true,
        idDocumentUrl: data['id_document_url'] as String?,
        selfieUrl: data['selfie_url'] as String?,
      );

      // If user ID is null, the cached data is invalid/incomplete
      // Clear it and return null to force a fresh login/profile load
      if (user.id == null) {
        debugPrint('⚠️ Cached user has null ID - clearing invalid cache');
        await prefs.remove('logged_in_user');
        return null;
      }

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
        'first_name': user.firstName,
        'last_name': user.lastName,
        'email': user.email,
        'is_artisan': user.isArtisan,
        'is_verified': user.isVerified,
        'id_document_url': user.idDocumentUrl,
        'selfie_url': user.selfieUrl,
      };
      await prefs.setString('logged_in_user', jsonEncode(data));
    } catch (_) {
      // ignore persistence failures for fake implementation
    }
    return;
  }

  @override
  Future<User?> verifyOtp({required String otp, String? pinId}) async {
    try {
      final user = await remote.verifyOtp(otp: otp, pinId: pinId);
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> resendOtp({String? phone}) async {
    try {
      return await remote.resendOtp(phone: phone);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await remote.forgotPassword(email: email);
    } catch (e) {
      // Rethrow the exception to let the caller handle it
      throw Exception('Failed to initiate password reset: ${e.toString()}');
    }
  }

  @override
  Future<bool> resetPassword(
      {required String token, required String newPassword}) async {
    try {
      return await remote.resetPassword(token: token, newPassword: newPassword);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      return await remote.changePassword(
          currentPassword: currentPassword, newPassword: newPassword);
    } catch (e) {
      return false;
    }
  }
}
