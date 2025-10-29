import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage abstraction for storing sensitive data
/// Uses FlutterSecureStorage for sensitive data and SharedPreferences for non-sensitive data
class SecureStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  // Firebase custom auth token (used for FirebaseAuth sign-in)
  static const String _firebaseTokenKey = 'firebase_token';
  // FCM/APNs device token (used for push notifications)
  static const String _fcmTokenKey = 'fcm_token';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _pinIdKey = 'pin_id';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Store access token
  Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Store refresh token
  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Get stored Firebase token
  Future<String?> getFirebaseToken() async {
    return await _secureStorage.read(key: _firebaseTokenKey);
  }

  /// Store Firebase token
  Future<void> setFirebaseToken(String token) async {
    await _secureStorage.write(key: _firebaseTokenKey, value: token);
  }

  /// Get stored FCM device token
  Future<String?> getFcmToken() async {
    return await _secureStorage.read(key: _fcmTokenKey);
  }

  /// Store FCM device token
  Future<void> setFcmToken(String token) async {
    await _secureStorage.write(key: _fcmTokenKey, value: token);
  }

  /// Get stored PIN ID (for OTP verification)
  Future<String?> getPinId() async {
    return await _secureStorage.read(key: _pinIdKey);
  }

  /// Store PIN ID
  Future<void> setPinId(String pinId) async {
    await _secureStorage.write(key: _pinIdKey, value: pinId);
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Store user ID
  Future<void> setUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  /// Check if user is logged in (stored in SharedPreferences as it's not sensitive)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Set login status
  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// Clear all stored data (logout)
  Future<void> clear() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _firebaseTokenKey);
    await _secureStorage.delete(key: _fcmTokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _pinIdKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Store authentication data
  Future<void> storeAuthData({
    required String accessToken,
    String? refreshToken,
    String? firebaseToken,
    required String userId,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (firebaseToken != null) {
      await _secureStorage.write(key: _firebaseTokenKey, value: firebaseToken);
    }
    await _secureStorage.write(key: _userIdKey, value: userId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Check if secure storage contains valid credentials
  Future<bool> hasValidCredentials() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
