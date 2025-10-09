import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/cache/api_cache_manager.dart';

/// Mixin to add automatic caching capabilities to any Bloc
/// Usage:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with CachedBlocMixin {
///   // Your bloc implementation
/// }
/// ```
mixin CachedBlocMixin<Event, State> on Bloc<Event, State> {
  final ApiCacheManager _cache = ApiCacheManager();

  /// Execute API call with automatic caching
  ///
  /// Example:
  /// ```dart
  /// final jobs = await executeWithCache(
  ///   cacheKey: CacheKeys.jobs(page: 1),
  ///   fetch: () => jobRepository.getJobs(page: 1),
  ///   fromJson: (json) => (json as List).map((e) => Job.fromJson(e)).toList(),
  ///   toJson: (jobs) => jobs.map((job) => job.toJson()).toList(),
  ///   ttl: Duration(minutes: 5),
  /// );
  /// ```
  Future<T> executeWithCache<T>({
    required String cacheKey,
    required Future<T> Function() fetch,
    required T Function(dynamic) fromJson,
    required dynamic Function(T) toJson,
    Duration? ttl,
    bool persistent = false,
    bool forceRefresh = false,
  }) async {
    return await _cache.getOrFetch<T>(
      key: cacheKey,
      fetch: fetch,
      fromJson: fromJson,
      toJson: toJson,
      ttl: ttl,
      persistent: persistent,
      forceRefresh: forceRefresh,
    );
  }

  /// Check if cache exists before making API call
  Future<bool> hasCachedData(String cacheKey, {Duration? ttl}) async {
    return await _cache.has(cacheKey, ttl: ttl);
  }

  /// Invalidate specific cache
  Future<void> invalidateCache(String cacheKey) async {
    await _cache.invalidate(cacheKey);
  }

  /// Invalidate all related cache (e.g., all job cache)
  Future<void> invalidatePatternCache(String pattern) async {
    await _cache.invalidatePattern(pattern);
  }

  /// Get cached data without fetching
  Future<T?> getCached<T>({
    required String cacheKey,
    required T Function(dynamic) fromJson,
    Duration? ttl,
  }) async {
    return await _cache.get<T>(
      key: cacheKey,
      fromJson: fromJson,
      ttl: ttl,
    );
  }
}

/// Extension to add reactive caching to existing blocs
extension BlocCacheExtension<Event, State> on Bloc<Event, State> {
  /// Execute with cache if bloc doesn't use CachedBlocMixin
  Future<T> withCache<T>({
    required String cacheKey,
    required Future<T> Function() fetch,
    required T Function(dynamic) fromJson,
    required dynamic Function(T) toJson,
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    return await ApiCacheManager().getOrFetch<T>(
      key: cacheKey,
      fetch: fetch,
      fromJson: fromJson,
      toJson: toJson,
      ttl: ttl,
      forceRefresh: forceRefresh,
    );
  }
}
