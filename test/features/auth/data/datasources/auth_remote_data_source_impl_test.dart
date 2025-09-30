import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artisans_circle/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:artisans_circle/core/storage/secure_storage.dart';
import 'package:artisans_circle/core/api/endpoints.dart';

class MockDio extends Mock implements Dio {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockResponse extends Mock implements Response {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockSharedPreferences mockSharedPreferences;
  late MockSecureStorage mockSecureStorage;
  late MockResponse mockResponse;

  setUp(() {
    mockDio = MockDio();
    mockSharedPreferences = MockSharedPreferences();
    mockSecureStorage = MockSecureStorage();
    mockResponse = MockResponse();
    dataSource = AuthRemoteDataSourceImpl(
      mockDio,
      mockSharedPreferences,
      mockSecureStorage,
    );
  });

  group('AuthRemoteDataSourceImpl', () {
    group('signIn', () {
      const tIdentifier = 'test@example.com';
      const tPassword = 'password123';
      const tAccessToken = 'access_token_123';
      const tFirebaseToken = 'firebase_token_123';

      final tLoginResponseData = {
        'access': tAccessToken,
        'expiry': '2024-12-31T23:59:59Z',
        'firebase_access_token': tFirebaseToken,
        'phone': '+1234567890',
      };

      final tUserProfileData = {
        'user': {
          'id': 1,
          'phone': '+1234567890',
          'first_name': 'Test',
          'last_name': 'User',
          'email': 'test@example.com',
          'is_verified': true,
        }
      };

      test('should return user when login is successful', () async {
        // Arrange
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(tLoginResponseData);

        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        // Mock the profile fetch that happens after login
        final mockProfileResponse = MockResponse();
        when(() => mockProfileResponse.statusCode).thenReturn(200);
        when(() => mockProfileResponse.data).thenReturn(tUserProfileData);

        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => tAccessToken);

        when(() => mockDio.get(
              any(),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockProfileResponse);

        when(() => mockSecureStorage.setAccessToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSecureStorage.setFirebaseToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await dataSource.signIn(
          identifier: tIdentifier,
          password: tPassword,
        );

        // Assert
        expect(result, isNotNull);
        expect(result?.phone, equals('+1234567890'));
        expect(result?.firstName, equals('Test'));
        expect(result?.lastName, equals('User'));

        verify(() => mockDio.post(
              '${ApiEndpoints.baseUrl}${ApiEndpoints.login}',
              data: {
                'phone': tIdentifier,
                'password': tPassword,
                'is_artisan': true,
              },
              options: any(named: 'options'),
            )).called(1);

        verify(() => mockSecureStorage.setAccessToken(tAccessToken)).called(1);
        verify(() => mockSecureStorage.setFirebaseToken(tFirebaseToken))
            .called(1);
      });

      test('should throw exception when login fails with error details',
          () async {
        // Arrange
        when(() => mockResponse.statusCode).thenReturn(401);
        when(() => mockResponse.data)
            .thenReturn({'detail': 'Invalid credentials'});

        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => dataSource.signIn(identifier: tIdentifier, password: tPassword),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid credentials'),
          )),
        );
      });

      test('should normalize phone number identifier', () async {
        // Arrange
        const tPhoneIdentifier = '08012345678';

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(tLoginResponseData);

        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final mockProfileResponse = MockResponse();
        when(() => mockProfileResponse.statusCode).thenReturn(200);
        when(() => mockProfileResponse.data).thenReturn(tUserProfileData);

        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => tAccessToken);
        when(() => mockDio.get(any(), options: any(named: 'options')))
            .thenAnswer((_) async => mockProfileResponse);
        when(() => mockSecureStorage.setAccessToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSecureStorage.setFirebaseToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.signIn(
            identifier: tPhoneIdentifier, password: tPassword);

        // Assert
        verify(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).called(1);
      });
    });

    group('signUp', () {
      const tIdentifier = 'newuser@example.com';
      const tPassword = 'password123';
      const tName = 'New User';

      final tRegisterResponseData = {
        'pin_id': 'pin_123',
        'message': 'User created successfully',
      };

      test('should return user when registration is successful', () async {
        // Arrange
        when(() => mockResponse.statusCode).thenReturn(201);
        when(() => mockResponse.data).thenReturn(tRegisterResponseData);

        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        when(() => mockSecureStorage.setPinId(any())).thenAnswer((_) async {});

        // Act
        final result = await dataSource.signUp(
          identifier: tIdentifier,
          password: tPassword,
          name: tName,
        );

        // Assert
        expect(result, isNotNull);
        expect(result?.phone, equals(tIdentifier));
        expect(result?.firstName, equals('New'));
        expect(result?.lastName, equals('User'));
        expect(result?.isArtisan, isTrue);
        expect(result?.isPhoneVerified, isFalse);

        verify(() => mockSecureStorage.setPinId('pin_123')).called(1);
        verify(() => mockDio.post(
              '${ApiEndpoints.baseUrl}${ApiEndpoints.register}',
              data: {
                'phone': tIdentifier,
                'first_name': 'New',
                'last_name': 'User',
                'password': tPassword,
                'is_artisan': true,
              },
              options: any(named: 'options'),
            )).called(1);
      });
    });

    group('verifyOtp', () {
      const tOtp = '123456';
      const tPinId = 'pin_123';
      const tAccessToken = 'verified_access_token';

      final tOtpResponseData = {
        'access': tAccessToken,
        'expiry': '2024-12-31T23:59:59Z',
        'firebase_access_token': 'firebase_token',
        'message': 'OTP verified successfully',
      };

      final tUserProfileData = {
        'user': {
          'id': 1,
          'phone': '+1234567890',
          'first_name': 'Verified',
          'last_name': 'User',
          'email': 'verified@example.com',
          'is_verified': true,
        }
      };

      test('should return verified user when OTP is correct', () async {
        // Arrange
        when(() => mockSecureStorage.getPinId())
            .thenAnswer((_) async => tPinId);
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(tOtpResponseData);

        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        // Mock profile fetch after OTP verification
        final mockProfileResponse = MockResponse();
        when(() => mockProfileResponse.statusCode).thenReturn(200);
        when(() => mockProfileResponse.data).thenReturn(tUserProfileData);

        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => tAccessToken);
        when(() => mockDio.get(any(), options: any(named: 'options')))
            .thenAnswer((_) async => mockProfileResponse);

        when(() => mockSecureStorage.setAccessToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSecureStorage.setFirebaseToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await dataSource.verifyOtp(otp: tOtp, pinId: tPinId);

        // Assert
        expect(result, isNotNull);
        verify(() => mockDio.post(
              '${ApiEndpoints.baseUrl}${ApiEndpoints.verifyOtp}',
              data: {
                'pin': tOtp,
                'pin_id': tPinId,
              },
              options: any(named: 'options'),
            )).called(1);
        verify(() => mockSecureStorage.setAccessToken(tAccessToken)).called(1);
      });

      test('should use cached pin_id when pinId parameter is null', () async {
        // Arrange
        const tCachedPinId = 'cached_pin_123';
        when(() => mockSecureStorage.getPinId())
            .thenAnswer((_) async => tCachedPinId);
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(tOtpResponseData);

        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        final mockProfileResponse = MockResponse();
        when(() => mockProfileResponse.statusCode).thenReturn(200);
        when(() => mockProfileResponse.data).thenReturn(tUserProfileData);
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => tAccessToken);
        when(() => mockDio.get(any(), options: any(named: 'options')))
            .thenAnswer((_) async => mockProfileResponse);
        when(() => mockSecureStorage.setAccessToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSecureStorage.setFirebaseToken(any()))
            .thenAnswer((_) async {});
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.verifyOtp(otp: tOtp);

        // Assert
        verify(() => mockDio.post(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).called(1);
      });
    });

    group('requestIsSignedIn', () {
      test('should return false when no token is stored', () async {
        // Arrange
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => null);

        // Act
        final result = await dataSource.requestIsSignedIn();

        // Assert
        expect(result, isFalse);
        verifyNever(() => mockDio.get(any(), options: any(named: 'options')));
      });

      test('should return true when token is valid', () async {
        // Arrange
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => 'valid_token');
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockDio.get(any(), options: any(named: 'options')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.requestIsSignedIn();

        // Assert
        expect(result, isTrue);
        verify(() => mockDio.get(
              '${ApiEndpoints.baseUrl}${ApiEndpoints.userProfile}',
              options: any(named: 'options'),
            )).called(1);
      });

      test('should return false when API call fails', () async {
        // Arrange
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => 'invalid_token');
        when(() => mockDio.get(any(), options: any(named: 'options')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.requestIsSignedIn();

        // Assert
        expect(result, isFalse);
      });
    });

    group('signOut', () {
      test('should clear auth data and call logout endpoint', () async {
        // Arrange
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => 'token');
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockDio.post(any(), options: any(named: 'options')))
            .thenAnswer((_) async => mockResponse);
        when(() => mockSecureStorage.clear()).thenAnswer((_) async {});
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.signOut();

        // Assert
        verify(() => mockDio.post(
              '${ApiEndpoints.baseUrl}/auth/logout/',
              options: any(named: 'options'),
            )).called(1);
        verify(() => mockSecureStorage.clear()).called(1);
      });

      test('should clear auth data even if logout endpoint fails', () async {
        // Arrange
        when(() => mockSecureStorage.getAccessToken())
            .thenAnswer((_) async => 'token');
        when(() => mockDio.post(any(), options: any(named: 'options')))
            .thenThrow(Exception('Network error'));
        when(() => mockSecureStorage.clear()).thenAnswer((_) async {});
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.signOut();

        // Assert
        verify(() => mockSecureStorage.clear()).called(1);
      });
    });

    group('OAuth methods', () {
      group('signInWithGoogle', () {
        test('should throw exception when CLIENT_ID is empty', () async {
          // Act & Assert
          expect(
            () => dataSource.signInWithGoogle(),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Google OAuth credentials not configured'),
            )),
          );
        });
      });

      group('signInWithApple', () {
        test('should throw exception when APPLE_CLIENT_ID is empty', () async {
          // Act & Assert
          expect(
            () => dataSource.signInWithApple(),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Apple OAuth client ID not configured'),
            )),
          );
        });
      });
    });

    group('password management', () {
      group('forgotPassword', () {
        const tEmail = 'test@example.com';

        test('should succeed when API returns 200', () async {
          // Arrange
          when(() => mockResponse.statusCode).thenReturn(200);
          when(() => mockDio.post(
                any(),
                data: any(named: 'data'),
                options: any(named: 'options'),
              )).thenAnswer((_) async => mockResponse);

          // Act
          await dataSource.forgotPassword(email: tEmail);

          // Assert
          verify(() => mockDio.post(
                '${ApiEndpoints.baseUrl}${ApiEndpoints.forgotPassword}',
                data: {'email': tEmail},
                options: any(named: 'options'),
              )).called(1);
        });

        test('should throw exception when API returns error', () async {
          // Arrange
          when(() => mockResponse.statusCode).thenReturn(400);
          when(() => mockDio.post(
                any(),
                data: any(named: 'data'),
                options: any(named: 'options'),
              )).thenAnswer((_) async => mockResponse);

          // Act & Assert
          expect(
            () => dataSource.forgotPassword(email: tEmail),
            throwsA(isA<Exception>()),
          );
        });
      });

      group('resetPassword', () {
        const tToken = 'reset_token';
        const tNewPassword = 'newPassword123';

        test('should return true when reset succeeds', () async {
          // Arrange
          when(() => mockResponse.statusCode).thenReturn(200);
          when(() => mockDio.post(
                any(),
                data: any(named: 'data'),
                options: any(named: 'options'),
              )).thenAnswer((_) async => mockResponse);

          // Act
          final result = await dataSource.resetPassword(
            token: tToken,
            newPassword: tNewPassword,
          );

          // Assert
          expect(result, isTrue);
          verify(() => mockDio.post(
                '${ApiEndpoints.baseUrl}${ApiEndpoints.resetPassword}',
                data: {'token': tToken, 'password': tNewPassword},
                options: any(named: 'options'),
              )).called(1);
        });

        test('should return false when API call fails', () async {
          // Arrange
          when(() => mockDio.post(
                any(),
                data: any(named: 'data'),
                options: any(named: 'options'),
              )).thenThrow(Exception('Network error'));

          // Act
          final result = await dataSource.resetPassword(
            token: tToken,
            newPassword: tNewPassword,
          );

          // Assert
          expect(result, isFalse);
        });
      });

      group('changePassword', () {
        const tCurrentPassword = 'current123';
        const tNewPassword = 'new123';

        test('should return true when change succeeds', () async {
          // Arrange
          when(() => mockSecureStorage.getAccessToken())
              .thenAnswer((_) async => 'token');
          when(() => mockResponse.statusCode).thenReturn(200);
          when(() => mockDio.post(
                any(),
                data: any(named: 'data'),
                options: any(named: 'options'),
              )).thenAnswer((_) async => mockResponse);

          // Act
          final result = await dataSource.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          );

          // Assert
          expect(result, isTrue);
          verify(() => mockDio.post(
                '${ApiEndpoints.baseUrl}${ApiEndpoints.changePassword}',
                data: {
                  'current_password': tCurrentPassword,
                  'new_password': tNewPassword,
                },
                options: any(named: 'options'),
              )).called(1);
        });
      });
    });
  });
}
