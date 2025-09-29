import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:artisans_circle/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:artisans_circle/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:artisans_circle/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remote: mockRemoteDataSource);
  });

  group('AuthRepositoryImpl', () {
    final tUser = User(
      id: 1,
      phone: '+1234567890',
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      isArtisan: true,
      isVerified: true,
    );

    group('signIn', () {
      const tIdentifier = 'test@example.com';
      const tPassword = 'password123';

      test('should return user when remote data source returns user', () async {
        // Arrange
        when(() => mockRemoteDataSource.signIn(
              identifier: any(named: 'identifier'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => tUser);

        // Act
        final result = await repository.signIn(
          identifier: tIdentifier,
          password: tPassword,
        );

        // Assert
        expect(result, equals(tUser));
        verify(() => mockRemoteDataSource.signIn(
              identifier: tIdentifier,
              password: tPassword,
            )).called(1);
      });

      test('should return null when remote data source returns null', () async {
        // Arrange
        when(() => mockRemoteDataSource.signIn(
              identifier: any(named: 'identifier'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => null);

        // Act
        final result = await repository.signIn(
          identifier: tIdentifier,
          password: tPassword,
        );

        // Assert
        expect(result, isNull);
      });

      test('should cache current user when sign in succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.signIn(
              identifier: any(named: 'identifier'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => tUser);

        // Act
        await repository.signIn(identifier: tIdentifier, password: tPassword);
        final cachedUser = await repository.getCurrentUser();

        // Assert
        expect(cachedUser, equals(tUser));
      });
    });

    group('signUp', () {
      const tIdentifier = 'newuser@example.com';
      const tPassword = 'password123';
      const tName = 'New User';

      test('should return user when remote data source returns user', () async {
        // Arrange
        when(() => mockRemoteDataSource.signUp(
              identifier: any(named: 'identifier'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => tUser);

        // Act
        final result = await repository.signUp(
          identifier: tIdentifier,
          password: tPassword,
          name: tName,
        );

        // Assert
        expect(result, equals(tUser));
        verify(() => mockRemoteDataSource.signUp(
              identifier: tIdentifier,
              password: tPassword,
              name: tName,
            )).called(1);
      });

      test('should cache current user when sign up succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.signUp(
              identifier: any(named: 'identifier'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => tUser);

        // Act
        await repository.signUp(
          identifier: tIdentifier,
          password: tPassword,
          name: tName,
        );
        final cachedUser = await repository.getCurrentUser();

        // Assert
        expect(cachedUser, equals(tUser));
      });
    });

    group('isSignedIn', () {
      test('should return true when user is cached', () async {
        // Arrange
        when(() => mockRemoteDataSource.signIn(
              identifier: any(named: 'identifier'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => tUser);

        await repository.signIn(identifier: 'test', password: 'test');

        // Act
        final result = await repository.isSignedIn();

        // Assert
        expect(result, isTrue);
      });

      test('should delegate to remote when no cached user', () async {
        // Arrange
        when(() => mockRemoteDataSource.requestIsSignedIn()).thenAnswer((_) async => true);

        // Act
        final result = await repository.isSignedIn();

        // Assert
        expect(result, isTrue);
        verify(() => mockRemoteDataSource.requestIsSignedIn()).called(1);
      });
    });

    group('signOut', () {
      test('should clear cached user and call remote sign out', () async {
        // Arrange
        when(() => mockRemoteDataSource.signIn(
              identifier: any(named: 'identifier'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => tUser);
        when(() => mockRemoteDataSource.signOut()).thenAnswer((_) async {});

        // Cache a user first
        await repository.signIn(identifier: 'test', password: 'test');
        expect(await repository.getCurrentUser(), equals(tUser));

        // Act
        await repository.signOut();

        // Assert
        expect(await repository.getCurrentUser(), isNull);
        verify(() => mockRemoteDataSource.signOut()).called(1);
      });
    });

    group('verifyOtp', () {
      const tOtp = '123456';
      const tPinId = 'pin123';

      test('should return user and cache it when verification succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.verifyOtp(
              otp: any(named: 'otp'),
              pinId: any(named: 'pinId'),
            )).thenAnswer((_) async => tUser);

        // Act
        final result = await repository.verifyOtp(otp: tOtp, pinId: tPinId);

        // Assert
        expect(result, equals(tUser));
        expect(await repository.getCurrentUser(), equals(tUser));
        verify(() => mockRemoteDataSource.verifyOtp(otp: tOtp, pinId: tPinId)).called(1);
      });

      test('should return null when verification fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.verifyOtp(
              otp: any(named: 'otp'),
              pinId: any(named: 'pinId'),
            )).thenThrow(Exception('Invalid OTP'));

        // Act
        final result = await repository.verifyOtp(otp: tOtp, pinId: tPinId);

        // Assert
        expect(result, isNull);
      });
    });

    group('resendOtp', () {
      const tPhone = '+1234567890';

      test('should return true when remote returns true', () async {
        // Arrange
        when(() => mockRemoteDataSource.resendOtp(phone: any(named: 'phone')))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.resendOtp(phone: tPhone);

        // Assert
        expect(result, isTrue);
        verify(() => mockRemoteDataSource.resendOtp(phone: tPhone)).called(1);
      });

      test('should return false when remote throws exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.resendOtp(phone: any(named: 'phone')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.resendOtp(phone: tPhone);

        // Assert
        expect(result, isFalse);
      });
    });

    group('forgotPassword', () {
      const tEmail = 'test@example.com';

      test('should call remote forgotPassword', () async {
        // Arrange
        when(() => mockRemoteDataSource.forgotPassword(email: any(named: 'email')))
            .thenAnswer((_) async {});

        // Act
        await repository.forgotPassword(email: tEmail);

        // Assert
        verify(() => mockRemoteDataSource.forgotPassword(email: tEmail)).called(1);
      });

      test('should throw exception when remote throws', () async {
        // Arrange
        when(() => mockRemoteDataSource.forgotPassword(email: any(named: 'email')))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.forgotPassword(email: tEmail),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('resetPassword', () {
      const tToken = 'reset_token_123';
      const tNewPassword = 'newPassword123';

      test('should return true when remote returns true', () async {
        // Arrange
        when(() => mockRemoteDataSource.resetPassword(
              token: any(named: 'token'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async => true);

        // Act
        final result = await repository.resetPassword(
          token: tToken,
          newPassword: tNewPassword,
        );

        // Assert
        expect(result, isTrue);
        verify(() => mockRemoteDataSource.resetPassword(
              token: tToken,
              newPassword: tNewPassword,
            )).called(1);
      });

      test('should return false when remote throws exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.resetPassword(
              token: any(named: 'token'),
              newPassword: any(named: 'newPassword'),
            )).thenThrow(Exception('Invalid token'));

        // Act
        final result = await repository.resetPassword(
          token: tToken,
          newPassword: tNewPassword,
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('changePassword', () {
      const tCurrentPassword = 'currentPass123';
      const tNewPassword = 'newPass123';

      test('should return true when remote returns true', () async {
        // Arrange
        when(() => mockRemoteDataSource.changePassword(
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async => true);

        // Act
        final result = await repository.changePassword(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        );

        // Assert
        expect(result, isTrue);
        verify(() => mockRemoteDataSource.changePassword(
              currentPassword: tCurrentPassword,
              newPassword: tNewPassword,
            )).called(1);
      });

      test('should return false when remote throws exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.changePassword(
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenThrow(Exception('Wrong current password'));

        // Act
        final result = await repository.changePassword(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('persistCurrentUser', () {
      test('should update cached user', () async {
        // Arrange
        final updatedUser = User(
          id: 1,
          phone: '+1234567890',
          firstName: 'Updated',
          lastName: 'User',
          email: 'updated@example.com',
          isArtisan: true,
          isVerified: true,
        );

        // Act
        await repository.persistCurrentUser(updatedUser);

        // Assert
        final cachedUser = await repository.getCurrentUser();
        expect(cachedUser, equals(updatedUser));
      });
    });

    group('OAuth sign-in', () {
      group('signInWithGoogle', () {
        test('should return user and cache it when Google sign-in succeeds', () async {
          // Arrange
          when(() => mockRemoteDataSource.signInWithGoogle()).thenAnswer((_) async => tUser);

          // Act
          final result = await repository.signInWithGoogle();

          // Assert
          expect(result, equals(tUser));
          expect(await repository.getCurrentUser(), equals(tUser));
          verify(() => mockRemoteDataSource.signInWithGoogle()).called(1);
        });
      });

      group('signInWithApple', () {
        test('should return user and cache it when Apple sign-in succeeds', () async {
          // Arrange
          when(() => mockRemoteDataSource.signInWithApple()).thenAnswer((_) async => tUser);

          // Act
          final result = await repository.signInWithApple();

          // Assert
          expect(result, equals(tUser));
          expect(await repository.getCurrentUser(), equals(tUser));
          verify(() => mockRemoteDataSource.signInWithApple()).called(1);
        });
      });
    });
  });
}
