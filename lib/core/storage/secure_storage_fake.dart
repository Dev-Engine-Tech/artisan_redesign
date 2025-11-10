import 'secure_storage.dart';

/// In-memory SecureStorage used for tests and fake flows.
class SecureStorageFake extends SecureStorage {
  final Map<String, String> _store = {};
  bool _loggedIn = false;

  @override
  Future<String?> getAccessToken() async => _store['access_token'];

  @override
  Future<void> setAccessToken(String token) async {
    _store['access_token'] = token;
  }

  @override
  Future<String?> getRefreshToken() async => _store['refresh_token'];

  @override
  Future<void> setRefreshToken(String token) async {
    _store['refresh_token'] = token;
  }

  @override
  Future<String?> getFirebaseToken() async => _store['firebase_token'];

  @override
  Future<void> setFirebaseToken(String token) async {
    _store['firebase_token'] = token;
  }

  @override
  Future<String?> getFcmToken() async => _store['fcm_token'];

  @override
  Future<void> setFcmToken(String token) async {
    _store['fcm_token'] = token;
  }

  @override
  Future<String?> getPinId() async => _store['pin_id'];

  @override
  Future<void> setPinId(String pinId) async {
    _store['pin_id'] = pinId;
  }

  @override
  Future<String?> getUserId() async => _store['user_id'];

  @override
  Future<void> setUserId(String userId) async {
    _store['user_id'] = userId;
  }

  @override
  Future<bool> isLoggedIn() async => _loggedIn;

  @override
  Future<void> setLoggedIn(bool isLoggedIn) async {
    _loggedIn = isLoggedIn;
  }

  @override
  Future<void> clear() async {
    _store.clear();
    _loggedIn = false;
  }

  @override
  Future<void> storeAuthData({
    required String accessToken,
    required String userId,
    String? refreshToken,
    String? firebaseToken,
  }) async {
    _store['access_token'] = accessToken;
    if (refreshToken != null) _store['refresh_token'] = refreshToken;
    if (firebaseToken != null) _store['firebase_token'] = firebaseToken;
    _store['user_id'] = userId;
    _loggedIn = true;
  }

  @override
  Future<bool> hasValidCredentials() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
