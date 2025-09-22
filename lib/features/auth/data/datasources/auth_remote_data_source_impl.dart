import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';
import '../../../../core/api/endpoints.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  AuthRemoteDataSourceImpl(this.dio, this.sharedPreferences);

  static const String _tokenKey = 'access_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userKey = 'logged_in_user';
  static const String _firebaseTokenKey = 'firebase_token';

  Map<String, String> get _authHeaders {
    final token = sharedPreferences.getString(_tokenKey);
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  String _normalizeIdentifier(String identifier) {
    final value = identifier.trim();
    if (value.contains('@')) return value; // email
    if (value.startsWith('+')) return value; // already in E.164
    final sanitized = value.replaceAll(RegExp(r'\s+'), '');
    if (sanitized.startsWith('0') && sanitized.length >= 10) {
      return '+234${sanitized.substring(1)}';
    }
    return sanitized;
  }

  Future<void> _saveTokens({
    required String accessToken,
    String? expiry,
    String? firebaseToken,
  }) async {
    await sharedPreferences.setString(_tokenKey, accessToken);
    if (expiry != null) {
      await sharedPreferences.setString(_tokenExpiryKey, expiry);
    }
    if (firebaseToken != null) {
      await sharedPreferences.setString(_firebaseTokenKey, firebaseToken);
    }
  }

  Future<void> _saveUser(User user) async {
    final userModel = UserModel.fromUser(user);
    await sharedPreferences.setString(_userKey, jsonEncode(userModel.toJson()));
  }

  Future<void> _clearAuthData() async {
    await sharedPreferences.remove(_tokenKey);
    await sharedPreferences.remove(_tokenExpiryKey);
    await sharedPreferences.remove(_userKey);
    await sharedPreferences.remove(_firebaseTokenKey);
  }

  @override
  Future<User?> signIn(
      {required String identifier, required String password}) async {
    final loginId = _normalizeIdentifier(identifier);
    final response = await dio.post(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.login}',
      data: {
        'phone': loginId,
        'password': password,
        'is_artisan': true,
      },
      options: Options(headers: _jsonHeaders, validateStatus: (_) => true),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final loginResponse = LoginResponse.fromJson(data);
      await _saveTokens(
        accessToken: loginResponse.accessToken,
        expiry: loginResponse.expiry,
        firebaseToken: loginResponse.firebaseAccessToken,
      );
      final user = await fetchUser(identifier);
      if (user != null) await _saveUser(user);
      return user;
    }
    final data = response.data;
    if (data is Map && data['detail'] != null) {
      throw Exception(data['detail'].toString());
    }
    throw Exception('Login failed with status ${response.statusCode}');
  }

  @override
  Future<User?> signUp(
      {required String identifier,
      required String password,
      String? name}) async {
    final loginId = _normalizeIdentifier(identifier);
    final nameParts = name?.split(' ') ?? ['', ''];
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final response = await dio.post(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.register}',
      data: {
        'phone': loginId,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'is_artisan': true,
      },
      options: Options(headers: _jsonHeaders, validateStatus: (_) => true),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final registerResponse = RegisterResponse.fromJson(data);
      if (registerResponse.pinId != null) {
        await sharedPreferences.setString('pin_id', registerResponse.pinId!);
      }
      return User(
        phone: loginId,
        firstName: firstName,
        lastName: lastName,
        isArtisan: true,
        isPhoneVerified: false,
      );
    }
    final data = response.data;
    if (data is Map && data['detail'] != null) {
      throw Exception(data['detail'].toString());
    }
    throw Exception('Registration failed with status ${response.statusCode}');
  }

  Future<User?> verifyOtp({required String otp, String? pinId}) async {
    final response = await dio.post(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.verifyOtp}',
      data: {
        'pin': otp,
        'pin_id': pinId ?? sharedPreferences.getString('pin_id'),
      },
      options: Options(headers: _jsonHeaders, validateStatus: (_) => true),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final otpResponse = OtpVerificationResponse.fromJson(data);
      if (otpResponse.accessToken != null) {
        await _saveTokens(
          accessToken: otpResponse.accessToken!,
          expiry: otpResponse.expiry,
          firebaseToken: otpResponse.firebaseAccessToken,
        );
        await sharedPreferences.remove('pin_id');
        final user = await fetchUser('');
        if (user != null) await _saveUser(user);
        return user;
      }
    }
    return null;
  }

  Future<bool> resendOtp({String? phone}) async {
    try {
      final normalized = phone != null ? _normalizeIdentifier(phone) : null;
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.resendOtp}',
        data: {
          if (normalized != null) 'phone': normalized,
        },
        options: Options(headers: _jsonHeaders, validateStatus: (_) => true),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestIsSignedIn() async {
    try {
      final token = sharedPreferences.getString(_tokenKey);
      if (token == null) return false;
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.userProfile}',
        options: Options(headers: _authHeaders),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<User?> fetchUser(String identifier) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.userProfile}',
        options: Options(headers: _authHeaders),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // The backend returns { "user": { ... }, ... } for profile.
          final u = (data['user'] is Map)
              ? Map<String, dynamic>.from(data['user'] as Map)
              : Map<String, dynamic>.from(data);

          return User(
            id: (u['id'] as num?)?.toInt(),
            phone: (u['phone'] ?? '').toString(),
            firstName: (u['first_name'] ?? '').toString(),
            lastName: (u['last_name'] ?? '').toString(),
            email: (u['email'] as String?),
            isArtisan: true,
            bio: (u['bio'] as String?),
            profilePictureUrl: (u['profile_pic'] as String?),
            state: u['state']?.toString(),
            lga: u['local_government']?.toString(),
            isVerified: (u['is_verified'] == true),
            isPhoneVerified: true,
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await dio.post(
        '${ApiEndpoints.baseUrl}/auth/logout/',
        options: Options(headers: _authHeaders, validateStatus: (_) => true),
      );
    } catch (_) {
    } finally {
      await _clearAuthData();
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final google = GoogleSignIn(scopes: ['email']);
      await google.signOut();
      final account = await google.signIn();
      if (account == null) return null; // canceled
      final auth = await account.authentication;
      final token = auth.accessToken ?? auth.idToken;
      if (token == null) throw Exception('Google sign-in failed: no token');

      final clientId =
          const String.fromEnvironment('CLIENT_ID', defaultValue: '');
      final clientSecret =
          const String.fromEnvironment('CLIENT_SECRET', defaultValue: '');
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.googleSignIn}',
        data: {
          if (clientId.isNotEmpty) 'client_id': clientId,
          if (clientSecret.isNotEmpty) 'client_secret': clientSecret,
          'grant_type': 'convert_token',
          'backend': 'google-oauth2',
          'token': token,
          'account_type': 'artisan',
        },
        options: Options(headers: _jsonHeaders, validateStatus: (_) => true),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(data);
        await _saveTokens(
          accessToken: loginResponse.accessToken,
          expiry: loginResponse.expiry,
          firebaseToken: loginResponse.firebaseAccessToken,
        );
        final user = await fetchUser('');
        if (user != null) await _saveUser(user);
        return user;
      }
      final data = response.data;
      if (data is Map && data['error_description'] != null) {
        throw Exception(data['error_description'].toString());
      }
      if (data is Map && data['detail'] != null) {
        throw Exception(data['detail'].toString());
      }
      throw Exception(
          'Google sign-in failed with status ${response.statusCode}');
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<User?> signInWithApple() async {
    try {
      final available = await SignInWithApple.isAvailable();
      if (!available) {
        throw Exception('Apple Sign In not available on this device');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );
      final idToken = credential.identityToken;
      final code = credential.authorizationCode;
      if (idToken == null || code.isEmpty) {
        throw Exception('Apple sign-in failed: missing token');
      }

      final clientId = const String.fromEnvironment('APPLE_CLIENT_ID',
          defaultValue: 'com.artisansbridge.artisanApp.sid');
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.appleSignIn}',
        data: {
          'client_id': clientId,
          'id_token': idToken,
          'firstName': credential.givenName,
          'lastName': credential.familyName,
          'access_token': code,
          'email': credential.email,
          'account_type': 'artisan',
        },
        options: Options(headers: _jsonHeaders, validateStatus: (_) => true),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(data);
        await _saveTokens(
          accessToken: loginResponse.accessToken,
          expiry: loginResponse.expiry,
          firebaseToken: loginResponse.firebaseAccessToken,
        );
        final user = await fetchUser('');
        if (user != null) await _saveUser(user);
        return user;
      }
      final data = response.data;
      if (data is Map && data['error_description'] != null) {
        throw Exception(data['error_description'].toString());
      }
      if (data is Map && data['detail'] != null) {
        throw Exception(data['detail'].toString());
      }
      throw Exception(
          'Apple sign-in failed with status ${response.statusCode}');
    } catch (e) {
      throw Exception('Apple sign-in failed: ${e.toString()}');
    }
  }

  Future<User?> forgotPassword({required String email}) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.forgotPassword}',
        data: {'email': email},
        options: Options(headers: _jsonHeaders, validateStatus: (_) => true),
      );
      return response.statusCode == 200
          ? User(phone: '', firstName: '', lastName: '', isArtisan: true)
          : null;
    } catch (e) {
      throw Exception('Forgot password failed: ${e.toString()}');
    }
  }

  Future<bool> resetPassword(
      {required String token, required String newPassword}) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.resetPassword}',
        data: {'token': token, 'password': newPassword},
        options: Options(headers: _jsonHeaders, validateStatus: (_) => true),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.changePassword}',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword
        },
        options: Options(headers: _authHeaders, validateStatus: (_) => true),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
