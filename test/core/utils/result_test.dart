import 'package:flutter_test/flutter_test.dart';
import 'package:artisans_circle/core/utils/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      const testData = 'test data';
      final success = Success(testData);

      test('should be recognized as success', () {
        expect(success.isSuccess, isTrue);
        expect(success.isFailure, isFalse);
      });

      test('should return data when accessed', () {
        expect(success.data, equals(testData));
      });

      test('should throw when trying to access failure', () {
        expect(() => success.failure, throwsA(isA<Exception>()));
      });

      test('should return data with getOrElse', () {
        expect(success.getOrElse('default'), equals(testData));
      });

      test('should transform data with map', () {
        final mapped = success.map<int>((data) => data.length);
        expect(mapped.isSuccess, isTrue);
        expect(mapped.data, equals(9));
      });

      test('should handle map transformation that throws', () {
        final mapped = success.map<int>((data) => throw Exception('error'));
        expect(mapped.isFailure, isTrue);
        expect(mapped.failure.code, equals('UNEXPECTED_ERROR'));
      });

      test('should chain with flatMap when successful', () {
        final chained = success.flatMap<int>((data) => Success(data.length));
        expect(chained.isSuccess, isTrue);
        expect(chained.data, equals(9));
      });

      test('should handle flatMap that throws', () {
        final chained =
            success.flatMap<int>((data) => throw Exception('error'));
        expect(chained.isFailure, isTrue);
      });

      test('should execute success callback in fold', () {
        final result = success.fold<String>(
          (failure) => 'failed: ${failure.message}',
          (data) => 'success: $data',
        );
        expect(result, equals('success: test data'));
      });
    });

    group('Failure', () {
      final failure = AppFailure.network('Network error');
      final failureResult = Failure<String>(failure);

      test('should be recognized as failure', () {
        expect(failureResult.isFailure, isTrue);
        expect(failureResult.isSuccess, isFalse);
      });

      test('should return failure when accessed', () {
        expect(failureResult.failure, equals(failure));
      });

      test('should throw when trying to access data', () {
        expect(() => failureResult.data, throwsA(isA<Exception>()));
      });

      test('should return default with getOrElse', () {
        expect(failureResult.getOrElse('default'), equals('default'));
      });

      test('should preserve failure with map', () {
        final mapped = failureResult.map<int>((data) => data.length);
        expect(mapped.isFailure, isTrue);
        expect(mapped.failure, equals(failure));
      });

      test('should preserve failure with flatMap', () {
        final chained =
            failureResult.flatMap<int>((data) => Success(data.length));
        expect(chained.isFailure, isTrue);
        expect(chained.failure, equals(failure));
      });

      test('should execute failure callback in fold', () {
        final result = failureResult.fold<String>(
          (failure) => 'failed: ${failure.message}',
          (data) => 'success: $data',
        );
        expect(result, equals('failed: Network error'));
      });
    });

    group('AppFailure', () {
      test('should create network failure', () {
        final failure = AppFailure.network('Connection timeout');
        expect(failure.message, equals('Connection timeout'));
        expect(failure.code, equals('NETWORK_ERROR'));
      });

      test('should create authentication failure', () {
        final failure = AppFailure.authentication('Invalid credentials');
        expect(failure.message, equals('Invalid credentials'));
        expect(failure.code, equals('AUTH_ERROR'));
      });

      test('should create validation failure', () {
        final failure = AppFailure.validation('Email is required');
        expect(failure.message, equals('Email is required'));
        expect(failure.code, equals('VALIDATION_ERROR'));
      });

      test('should create server failure', () {
        final failure = AppFailure.server('Internal server error');
        expect(failure.message, equals('Internal server error'));
        expect(failure.code, equals('SERVER_ERROR'));
      });

      test('should create server failure with status code', () {
        final failure = AppFailure.server('Not found', statusCode: 404);
        expect(failure.message, equals('Not found'));
        expect(failure.code, equals('SERVER_ERROR_404'));
      });

      test('should create not found failure', () {
        final failure = AppFailure.notFound('User not found');
        expect(failure.message, equals('User not found'));
        expect(failure.code, equals('NOT_FOUND'));
      });

      test('should create permission denied failure', () {
        final failure = AppFailure.permissionDenied('Access denied');
        expect(failure.message, equals('Access denied'));
        expect(failure.code, equals('PERMISSION_DENIED'));
      });

      test('should create unexpected failure', () {
        final exception = Exception('Unexpected error');
        final failure =
            AppFailure.unexpected('Something went wrong', exception: exception);
        expect(failure.message, equals('Something went wrong'));
        expect(failure.code, equals('UNEXPECTED_ERROR'));
        expect(failure.exception, equals(exception));
      });

      test('should have proper equality', () {
        final failure1 = AppFailure.network('Network error');
        final failure2 = AppFailure.network('Network error');
        final failure3 = AppFailure.network('Different error');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('Extensions', () {
      test('should create success result with extension', () {
        const data = 'test';
        final result = data.success;

        expect(result.isSuccess, isTrue);
        expect(result.data, equals(data));
      });

      test('should create failure result with extension', () {
        final failure = AppFailure.network('Error');
        final result = failure.failure<String>();

        expect(result.isFailure, isTrue);
        expect(result.failure, equals(failure));
      });
    });

    group('safeCall', () {
      test('should return success when operation succeeds', () async {
        final result = await safeCall(() async => 'success');

        expect(result.isSuccess, isTrue);
        expect(result.data, equals('success'));
      });

      test('should return failure when operation throws Exception', () async {
        final result =
            await safeCall(() async => throw Exception('test error'));

        expect(result.isFailure, isTrue);
        expect(result.failure.code, equals('UNEXPECTED_ERROR'));
        expect(result.failure.message, contains('test error'));
      });

      test('should return failure when operation throws non-Exception',
          () async {
        final result = await safeCall(() async => throw 'string error');

        expect(result.isFailure, isTrue);
        expect(result.failure.code, equals('UNEXPECTED_ERROR'));
        expect(result.failure.message, equals('string error'));
      });

      test('should handle complex async operations', () async {
        final result = await safeCall(() async {
          await Future.delayed(const Duration(milliseconds: 1));
          return 42;
        });

        expect(result.isSuccess, isTrue);
        expect(result.data, equals(42));
      });
    });

    group('Result chaining', () {
      test('should chain multiple successful operations', () {
        final result = Success('hello')
            .map<String>((data) => data.toUpperCase())
            .map<int>((data) => data.length)
            .map<String>((data) => 'Length: $data');

        expect(result.isSuccess, isTrue);
        expect(result.data, equals('Length: 5'));
      });

      test('should stop chaining on first failure', () {
        final result = Success('hello')
            .map<String>((data) => data.toUpperCase())
            .map<int>((data) => throw Exception('error'))
            .map<String>((data) => 'Length: $data');

        expect(result.isFailure, isTrue);
        expect(result.failure.code, equals('UNEXPECTED_ERROR'));
      });

      test('should chain with flatMap', () {
        final result = Success(5)
            .flatMap<String>((data) => Success('Number: $data'))
            .flatMap<int>((data) => Success(data.length));

        expect(result.isSuccess, isTrue);
        expect(result.data, equals(9));
      });

      test('should handle failure in flatMap chain', () {
        final result = Success(5)
            .flatMap<String>((data) => Success('Number: $data'))
            .flatMap<int>((data) => Failure(AppFailure.validation('Invalid')));

        expect(result.isFailure, isTrue);
        expect(result.failure.code, equals('VALIDATION_ERROR'));
      });
    });
  });
}
