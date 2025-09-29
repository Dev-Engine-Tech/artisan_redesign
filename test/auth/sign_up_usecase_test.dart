import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_up.dart';
import 'package:artisans_circle/features/auth/domain/repositories/auth_repository.dart';
import 'package:artisans_circle/features/auth/domain/entities/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUp usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignUp(mockRepository);
  });

  group('SignUp', () {
    const tIdentifier = 'newuser@example.com';
    const tPassword = 'password123';
    const tName = 'New User';

    final tUser = User(
      id: 1,
      phone: tIdentifier,
      firstName: 'New',
      lastName: 'User',
      email: tIdentifier,
      isArtisan: true,
      isVerified: false,
    );

    test('should return user when repository sign up succeeds', () async {
      // Arrange
      when(() => mockRepository.signUp(
            identifier: any(named: 'identifier'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tUser);

      // Act
      final result = await usecase.call(
        identifier: tIdentifier,
        password: tPassword,
        name: tName,
      );

      // Assert
      expect(result, isNotNull);
      expect(result!.firstName, equals('New'));
      expect(result.lastName, equals('User'));
      verify(() => mockRepository.signUp(
            identifier: tIdentifier,
            password: tPassword,
            name: tName,
          )).called(1);
    });

    test('should return null when repository sign up fails', () async {
      // Arrange
      when(() => mockRepository.signUp(
            identifier: any(named: 'identifier'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => null);

      // Act
      final result = await usecase.call(
        identifier: tIdentifier,
        password: tPassword,
        name: tName,
      );

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.signUp(
            identifier: tIdentifier,
            password: tPassword,
            name: tName,
          )).called(1);
    });

    test('should handle repository exceptions', () async {
      // Arrange
      when(() => mockRepository.signUp(
            identifier: any(named: 'identifier'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => usecase.call(
          identifier: tIdentifier,
          password: tPassword,
          name: tName,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle empty name parameter', () async {
      // Arrange
      when(() => mockRepository.signUp(
            identifier: any(named: 'identifier'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tUser);

      // Act
      final result = await usecase.call(
        identifier: tIdentifier,
        password: tPassword,
      );

      // Assert
      expect(result, isNotNull);
      verify(() => mockRepository.signUp(
            identifier: tIdentifier,
            password: tPassword,
            name: null,
          )).called(1);
    });
  });
}
