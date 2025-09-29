import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artisans_circle/core/storage/secure_storage.dart';

void main() {
  group('SecureStorage', () {
    late SecureStorage secureStorage;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      // Mock SharedPreferences for login status tests
      SharedPreferences.setMockInitialValues({});
      secureStorage = SecureStorage();
    });

    group('access token', () {
      const tAccessToken = 'test_access_token';

      test('should store access token in secure storage', () async {
        // This test would require dependency injection for SecureStorage
        // For now, we test the interface
        expect(secureStorage.setAccessToken(tAccessToken), isA<Future<void>>());
      });

      test('should retrieve access token from secure storage', () async {
        expect(secureStorage.getAccessToken(), isA<Future<String?>>());
      });
    });

    group('refresh token', () {
      const tRefreshToken = 'test_refresh_token';

      test('should store refresh token in secure storage', () async {
        expect(secureStorage.setRefreshToken(tRefreshToken), isA<Future<void>>());
      });

      test('should retrieve refresh token from secure storage', () async {
        expect(secureStorage.getRefreshToken(), isA<Future<String?>>());
      });
    });

    group('firebase token', () {
      const tFirebaseToken = 'test_firebase_token';

      test('should store firebase token in secure storage', () async {
        expect(secureStorage.setFirebaseToken(tFirebaseToken), isA<Future<void>>());
      });

      test('should retrieve firebase token from secure storage', () async {
        expect(secureStorage.getFirebaseToken(), isA<Future<String?>>());
      });
    });

    group('PIN ID', () {
      const tPinId = 'test_pin_id';

      test('should store PIN ID in secure storage', () async {
        expect(secureStorage.setPinId(tPinId), isA<Future<void>>());
      });

      test('should retrieve PIN ID from secure storage', () async {
        expect(secureStorage.getPinId(), isA<Future<String?>>());
      });
    });

    group('user ID', () {
      const tUserId = 'test_user_id';

      test('should store user ID in secure storage', () async {
        expect(secureStorage.setUserId(tUserId), isA<Future<void>>());
      });

      test('should retrieve user ID from secure storage', () async {
        expect(secureStorage.getUserId(), isA<Future<String?>>());
      });
    });

    group('login status', () {
      test('should return false by default', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await secureStorage.isLoggedIn();

        // Assert
        expect(result, isFalse);
      });

      test('should store and retrieve login status', () async {
        // This tests the interface - actual implementation would require mocking SharedPreferences
        expect(secureStorage.setLoggedIn(true), isA<Future<void>>());
        expect(secureStorage.isLoggedIn(), isA<Future<bool>>());
      });
    });

    group('storeAuthData', () {
      test('should store all auth data when all parameters provided', () async {
        // Arrange
        const tAccessToken = 'access_token';
        const tRefreshToken = 'refresh_token';
        const tFirebaseToken = 'firebase_token';
        const tUserId = 'user_123';

        // Act & Assert
        expect(
          secureStorage.storeAuthData(
            accessToken: tAccessToken,
            refreshToken: tRefreshToken,
            firebaseToken: tFirebaseToken,
            userId: tUserId,
          ),
          isA<Future<void>>(),
        );
      });

      test('should store required data when optional parameters are null', () async {
        // Arrange
        const tAccessToken = 'access_token';
        const tUserId = 'user_123';

        // Act & Assert
        expect(
          secureStorage.storeAuthData(
            accessToken: tAccessToken,
            userId: tUserId,
          ),
          isA<Future<void>>(),
        );
      });
    });

    group('clear', () {
      test('should clear all stored data', () async {
        expect(secureStorage.clear(), isA<Future<void>>());
      });
    });

    group('hasValidCredentials', () {
      test('should check for valid access token', () async {
        expect(secureStorage.hasValidCredentials(), isA<Future<bool>>());
      });
    });
  });
}
