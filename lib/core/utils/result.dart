import 'package:equatable/equatable.dart';

/// A Result type that represents either a success or failure state
/// This helps with better error handling and eliminates the need for throwing exceptions
abstract class Result<T> extends Equatable {
  const Result();

  /// Returns true if this is a success result
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure result
  bool get isFailure => this is Failure<T>;

  /// Gets the success data (throws if this is a failure)
  T get data {
    if (this is Success<T>) {
      return (this as Success<T>)._data;
    }
    throw Exception('Cannot get data from failure result');
  }

  /// Gets the failure (throws if this is a success)
  AppFailure get failure {
    if (this is Failure<T>) {
      return (this as Failure<T>)._failure;
    }
    throw Exception('Cannot get failure from success result');
  }

  /// Transform the data if this is a success, otherwise return the failure
  Result<U> map<U>(U Function(T data) transform) {
    if (this is Success<T>) {
      try {
        return Success(transform((this as Success<T>)._data));
      } catch (e) {
        return Failure(AppFailure.unexpected(e.toString()));
      }
    }
    return Failure((this as Failure<T>)._failure);
  }

  /// Execute a function if this is a success, otherwise return the failure
  Result<U> flatMap<U>(Result<U> Function(T data) transform) {
    if (this is Success<T>) {
      try {
        return transform((this as Success<T>)._data);
      } catch (e) {
        return Failure(AppFailure.unexpected(e.toString()));
      }
    }
    return Failure((this as Failure<T>)._failure);
  }

  /// Get the data if success, otherwise return the default value
  T getOrElse(T defaultValue) {
    return this is Success<T> ? (this as Success<T>)._data : defaultValue;
  }

  /// Execute callbacks based on success or failure
  R fold<R>(
    R Function(AppFailure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>)._data);
    }
    return onFailure((this as Failure<T>)._failure);
  }
}

/// Success result containing data
class Success<T> extends Result<T> {
  final T _data;

  const Success(this._data);

  @override
  List<Object?> get props => [_data];

  @override
  String toString() => 'Success($_data)';
}

/// Failure result containing error information
class Failure<T> extends Result<T> {
  final AppFailure _failure;

  const Failure(this._failure);

  @override
  List<Object?> get props => [_failure];

  @override
  String toString() => 'Failure($_failure)';
}

/// Application-specific failure types
class AppFailure extends Equatable {
  final String message;
  final String code;
  final Exception? exception;

  const AppFailure({
    required this.message,
    required this.code,
    this.exception,
  });

  /// Network-related failures
  factory AppFailure.network(String message) => AppFailure(
        message: message,
        code: 'NETWORK_ERROR',
      );

  /// Authentication failures
  factory AppFailure.authentication(String message) => AppFailure(
        message: message,
        code: 'AUTH_ERROR',
      );

  /// Validation failures
  factory AppFailure.validation(String message) => AppFailure(
        message: message,
        code: 'VALIDATION_ERROR',
      );

  /// Server errors
  factory AppFailure.server(String message, {int? statusCode}) => AppFailure(
        message: message,
        code: 'SERVER_ERROR${statusCode != null ? '_$statusCode' : ''}',
      );

  /// Not found errors
  factory AppFailure.notFound(String message) => AppFailure(
        message: message,
        code: 'NOT_FOUND',
      );

  /// Permission denied errors
  factory AppFailure.permissionDenied(String message) => AppFailure(
        message: message,
        code: 'PERMISSION_DENIED',
      );

  /// Unexpected errors
  factory AppFailure.unexpected(String message, {Exception? exception}) => AppFailure(
        message: message,
        code: 'UNEXPECTED_ERROR',
        exception: exception,
      );

  @override
  List<Object?> get props => [message, code, exception];

  @override
  String toString() => 'AppFailure(message: $message, code: $code)';
}

/// Extension methods for easier Result creation
extension ResultExtension<T> on T {
  /// Wrap a value in a Success result
  Result<T> get success => Success(this);
}

extension FailureExtension on AppFailure {
  /// Wrap a failure in a Failure result
  Result<T> failure<T>() => Failure<T>(this);
}

/// Helper function to handle async operations that might throw
Future<Result<T>> safeCall<T>(Future<T> Function() operation) async {
  try {
    final result = await operation();
    return Success(result);
  } catch (e) {
    if (e is Exception) {
      return Failure(AppFailure.unexpected(e.toString(), exception: e));
    }
    return Failure(AppFailure.unexpected(e.toString()));
  }
}
