import 'package:dio/dio.dart';

/// Base class for all remote data sources to reduce HTTP boilerplate
///
/// Provides common HTTP operations (GET, POST, PUT, DELETE, PATCH) with:
/// - Automatic response validation
/// - Consistent error handling
/// - Data normalization (handles `Map<String, dynamic>` vs `Map`)
/// - List response parsing (handles paginated responses)
abstract class BaseRemoteDataSource {
  final Dio dio;

  BaseRemoteDataSource(this.dio);

  /// Generic GET request
  ///
  /// Example:
  /// ```dart
  /// Future<UserModel> getUser() => get(
  ///   '/users/me',
  ///   fromJson: UserModel.fromJson,
  /// );
  /// ```
  Future<T> get<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.get(endpoint, queryParameters: queryParams);
    return _handleResponse(response, fromJson);
  }

  /// Generic GET request for list responses
  ///
  /// Handles paginated responses with keys: results, data, items, records
  ///
  /// Example:
  /// ```dart
  /// Future<List<JobModel>> getJobs() => getList(
  ///   '/jobs',
  ///   fromJson: JobModel.fromJson,
  /// );
  /// ```
  Future<List<T>> getList<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.get(endpoint, queryParameters: queryParams);
    return _handleListResponse(response, fromJson);
  }

  /// Generic POST request
  ///
  /// Example:
  /// ```dart
  /// Future<UserModel> createUser(Map<String, dynamic> data) => post(
  ///   '/users',
  ///   data: data,
  ///   fromJson: UserModel.fromJson,
  /// );
  /// ```
  Future<T> post<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.post(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return _handleResponse(response, fromJson);
  }

  /// POST request that returns a list
  Future<List<T>> postList<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.post(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return _handleListResponse(response, fromJson);
  }

  /// Generic PUT request
  Future<T> put<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.put(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return _handleResponse(response, fromJson);
  }

  /// Generic PATCH request
  Future<T> patch<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.patch(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return _handleResponse(response, fromJson);
  }

  /// Generic DELETE request
  Future<T> delete<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) fromJson,
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.delete(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return _handleResponse(response, fromJson);
  }

  /// DELETE request that returns void/success status
  Future<bool> deleteVoid(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.delete(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return _isSuccessResponse(response);
  }

  /// POST request that returns void/success status
  Future<bool> postVoid(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.post(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return _isSuccessResponse(response);
  }

  /// PUT request that returns void/success status
  Future<bool> putVoid(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await dio.put(
      endpoint,
      data: data,
      queryParameters: queryParams,
    );
    return _isSuccessResponse(response);
  }

  /// Handles single object responses
  T _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (_isSuccessResponse(response)) {
      final data = _normalizeData(response.data);
      return fromJson(data);
    }
    final message = _extractErrorMessage(response);
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: message,
    );
  }

  /// Handles list responses with pagination support
  List<T> _handleListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (_isSuccessResponse(response)) {
      final list = _extractList(response.data);
      return list
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    final message = _extractErrorMessage(response);
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: message,
    );
  }

  /// Extracts list from various response structures
  /// Handles: direct list, paginated responses (results, data, items, records)
  List _extractList(dynamic data) {
    // Direct list response
    if (data is List) return data;

    // Not a map, return empty
    if (data is! Map) return [];

    // Check common pagination keys
    const paginationKeys = [
      'results',
      'data',
      'items',
      'records',
      'jobs',
      'applications',
      'catalogs',
      'catalog_products',
    ];
    for (final key in paginationKeys) {
      final value = data[key];
      if (value is List) return value;
      // Recursively check nested maps
      if (value is Map) {
        final nested = _extractList(value);
        if (nested.isNotEmpty) return nested;
      }
    }

    // If no pagination key found, return empty list
    return [];
  }

  /// Normalizes response data to `Map<String, dynamic>`
  Map<String, dynamic> _normalizeData(dynamic data) {
    // Already a strongly typed map
    if (data is Map<String, dynamic>) {
      // Unwrap common envelope keys if present
      for (final key in const ['data', 'result', 'record']) {
        final value = data[key];
        if (value is Map) return Map<String, dynamic>.from(value);
      }
      return data;
    }

    // Loosely typed map
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in const ['data', 'result', 'record']) {
        final value = map[key];
        if (value is Map) return Map<String, dynamic>.from(value);
      }
      return map;
    }

    // If data is not a map, wrap it so downstream can access under 'data'
    return <String, dynamic>{'data': data};
  }

  /// Checks if response status code indicates success
  bool _isSuccessResponse(Response response) {
    final statusCode = response.statusCode;
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  /// Extract a helpful error message from the server response.
  String _extractErrorMessage(Response response) {
    final code = response.statusCode;
    final data = response.data;
    String? detail;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['detail'] != null) detail = map['detail'].toString();
      if (detail == null && map['message'] != null)
        detail = map['message'].toString();
      if (detail == null && map['error'] != null)
        detail = map['error'].toString();
      if (detail == null && map['errors'] != null) {
        // Flatten common error object structures
        final errs = map['errors'];
        if (errs is Map) {
          detail = errs.entries.map((e) => '${e.key}: ${e.value}').join('; ');
        } else if (errs is List) {
          detail = errs.join('; ');
        }
      }
    } else if (data is String && data.isNotEmpty) {
      detail = data;
    }
    return detail != null
        ? 'Request failed (${code}): $detail'
        : 'Request failed with status: $code';
  }
}
