import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';

/// Abstract HTTP service interface following Dependency Inversion Principle
/// This allows easy mocking and different implementations
abstract class HttpService {
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });
}

/// Performance-optimized HTTP service implementation
/// Follows Single Responsibility Principle - only handles HTTP operations
/// Follows Open/Closed Principle - extensible through composition
class OptimizedHttpService implements HttpService {
  final Dio _dio;
  final HttpCacheManager _cacheManager;
  final RequestDeduplicator _deduplicator;

  OptimizedHttpService({
    required Dio dio,
    Duration cacheDuration = const Duration(minutes: 5),
    int maxCacheSize = 100,
  })  : _dio = dio,
        _cacheManager = HttpCacheManager(
          maxSize: maxCacheSize,
          defaultTtl: cacheDuration,
        ),
        _deduplicator = RequestDeduplicator();

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final cacheKey = _buildCacheKey(path, queryParameters);

    // Check cache first for GET requests
    if (_shouldUseCache(options)) {
      final cached = _cacheManager.get<T>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    // Deduplicate identical requests
    return _deduplicator.execute<T>(
      cacheKey,
      () => _performRequest<T>(
        () => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ),
        cacheKey,
        options,
      ),
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _performRequest<T>(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      null, // POST requests are not cached
      options,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _performRequest<T>(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      null, // PUT requests are not cached
      options,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _performRequest<T>(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      null, // DELETE requests are not cached
      options,
    );
  }

  /// Performance: Wraps request execution with error handling and caching
  Future<Response<T>> _performRequest<T>(
    Future<Response<T>> Function() request,
    String? cacheKey,
    Options? options,
  ) async {
    try {
      final response = await request();

      // Cache successful GET responses
      if (cacheKey != null &&
          _shouldUseCache(options) &&
          response.statusCode == 200) {
        _cacheManager.set(cacheKey, response);
      }

      return response;
    } catch (e) {
      // Handle specific HTTP errors for better user experience
      if (e is DioException) {
        throw _mapDioException(e);
      }
      rethrow;
    }
  }

  /// Maps Dio exceptions to more meaningful errors
  Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const HttpException(
            'Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return const HttpException('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return const HttpException('Receive timeout. Please try again.');
      case DioExceptionType.badResponse:
        return HttpException('Server error: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return const HttpException('Request was cancelled.');
      case DioExceptionType.connectionError:
        return const HttpException(
            'Connection error. Please check your internet connection.');
      case DioExceptionType.unknown:
        return HttpException('Unknown error occurred: ${e.message}');
      case DioExceptionType.badCertificate:
        return const HttpException('SSL certificate error.');
    }
  }

  String _buildCacheKey(String path, Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return path;
    }
    final sortedParams = Map.fromEntries(queryParameters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)));
    return '$path?${Uri(queryParameters: sortedParams).query}';
  }

  bool _shouldUseCache(Options? options) {
    return options?.extra?['cache'] != false; // Cache by default, opt-out
  }
}

/// In-memory cache manager for HTTP responses
/// Follows Single Responsibility Principle - only handles caching logic
class HttpCacheManager {
  final int maxSize;
  final Duration defaultTtl;
  final Map<String, _CacheEntry> _cache = {};
  final Queue<String> _accessOrder = Queue<String>();

  HttpCacheManager({
    required this.maxSize,
    required this.defaultTtl,
  });

  Response<T>? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      _accessOrder.remove(key);
      return null;
    }

    // Update access order for LRU eviction
    _accessOrder.remove(key);
    _accessOrder.addLast(key);

    return entry.response as Response<T>;
  }

  void set<T>(String key, Response<T> response, [Duration? ttl]) {
    // Remove existing entry if present
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
    }

    // Evict least recently used item if cache is full
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      final oldestKey = _accessOrder.removeFirst();
      _cache.remove(oldestKey);
    }

    // Add new entry
    _cache[key] = _CacheEntry(
      response: response,
      expiryTime: DateTime.now().add(ttl ?? defaultTtl),
    );
    _accessOrder.addLast(key);
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  void remove(String key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }
}

/// Cache entry with TTL support
class _CacheEntry {
  final Response response;
  final DateTime expiryTime;

  _CacheEntry({
    required this.response,
    required this.expiryTime,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

/// Request deduplicator to prevent multiple identical requests
/// Follows Single Responsibility Principle - only handles request deduplication
class RequestDeduplicator {
  final Map<String, Future> _pendingRequests = {};

  Future<Response<T>> execute<T>(
    String key,
    Future<Response<T>> Function() request,
  ) async {
    // If identical request is already pending, return that future
    if (_pendingRequests.containsKey(key)) {
      return _pendingRequests[key]! as Future<Response<T>>;
    }

    // Execute new request
    final future = request();
    _pendingRequests[key] = future;

    try {
      final result = await future;
      _pendingRequests.remove(key);
      return result;
    } catch (e) {
      _pendingRequests.remove(key);
      rethrow;
    }
  }
}

/// Custom exception for HTTP-related errors
class HttpException implements Exception {
  final String message;

  const HttpException(this.message);

  @override
  String toString() => 'HttpException: $message';
}

/// HTTP service factory following Factory Pattern
/// Allows easy configuration and testing
class HttpServiceFactory {
  static HttpService create({
    required String baseUrl,
    Duration cacheDuration = const Duration(minutes: 5),
    int maxCacheSize = 100,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
    Map<String, String>? defaultHeaders,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: defaultHeaders,
    ));

    return OptimizedHttpService(
      dio: dio,
      cacheDuration: cacheDuration,
      maxCacheSize: maxCacheSize,
    );
  }
}
