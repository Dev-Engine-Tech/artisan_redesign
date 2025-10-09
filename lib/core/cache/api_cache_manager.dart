import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive API response caching system
/// Features:
/// - In-memory caching (fast)
/// - Persistent caching (survives app restart)
/// - TTL (Time To Live) support
/// - Automatic staleness detection
/// - Cache invalidation
/// - Size management
class ApiCacheManager {
  static final ApiCacheManager _instance = ApiCacheManager._internal();
  factory ApiCacheManager() => _instance;
  ApiCacheManager._internal();

  // In-memory cache for fast access
  final Map<String, CachedResponse> _memoryCache = {};

  // Cache configuration
  static const Duration defaultTTL = Duration(minutes: 5);
  static const Duration shortTTL = Duration(minutes: 1);
  static const Duration longTTL = Duration(minutes: 30);
  static const int maxMemoryCacheSize = 50; // Max items in memory

  SharedPreferences? _prefs;

  /// Initialize cache (call once at app start)
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _cleanExpiredCache();
    debugPrint('✅ ApiCacheManager initialized');
  }

  /// Get cached data if available and not stale
  Future<T?> get<T>({
    required String key,
    required T Function(dynamic) fromJson,
    Duration? ttl,
  }) async {
    // Check memory cache first (fastest)
    if (_memoryCache.containsKey(key)) {
      final cached = _memoryCache[key]!;
      if (!cached.isExpired(ttl ?? defaultTTL)) {
        debugPrint('💾 Cache HIT (memory): $key');
        try {
          return fromJson(cached.data);
        } catch (e) {
          debugPrint('❌ Cache deserialization error: $e');
          _memoryCache.remove(key);
        }
      } else {
        debugPrint('⏰ Cache EXPIRED (memory): $key');
        _memoryCache.remove(key);
      }
    }

    // Check persistent cache (slower but survives app restart)
    if (_prefs != null) {
      final jsonString = _prefs!.getString(_cacheKey(key));
      if (jsonString != null) {
        try {
          final Map<String, dynamic> json = jsonDecode(jsonString);
          final cached = CachedResponse.fromJson(json);

          if (!cached.isExpired(ttl ?? defaultTTL)) {
            debugPrint('💾 Cache HIT (persistent): $key');
            // Restore to memory cache
            _memoryCache[key] = cached;
            return fromJson(cached.data);
          } else {
            debugPrint('⏰ Cache EXPIRED (persistent): $key');
            await _prefs!.remove(_cacheKey(key));
          }
        } catch (e) {
          debugPrint('❌ Cache read error: $e');
          await _prefs!.remove(_cacheKey(key));
        }
      }
    }

    debugPrint('❌ Cache MISS: $key');
    return null;
  }

  /// Cache data with optional TTL
  Future<void> set({
    required String key,
    required dynamic data,
    Duration? ttl,
    bool persistent = false,
  }) async {
    final cached = CachedResponse(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl ?? defaultTTL,
    );

    // Always cache in memory
    _memoryCache[key] = cached;
    _enforceMemoryCacheSize();

    // Optionally persist to disk
    if (persistent && _prefs != null) {
      try {
        final jsonString = jsonEncode(cached.toJson());
        await _prefs!.setString(_cacheKey(key), jsonString);
        debugPrint('💾 Cached (persistent): $key');
      } catch (e) {
        debugPrint('❌ Cache write error: $e');
      }
    } else {
      debugPrint('💾 Cached (memory): $key');
    }
  }

  /// Get data or fetch if not cached/stale
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetch,
    required T Function(dynamic) fromJson,
    required dynamic Function(T) toJson,
    Duration? ttl,
    bool persistent = false,
    bool forceRefresh = false,
  }) async {
    // Force refresh bypasses cache
    if (!forceRefresh) {
      final cached = await get<T>(
        key: key,
        fromJson: fromJson,
        ttl: ttl,
      );

      if (cached != null) {
        return cached;
      }
    }

    // Fetch fresh data
    debugPrint('🌐 Fetching fresh data: $key');
    final data = await fetch();

    // Cache the result
    await set(
      key: key,
      data: toJson(data),
      ttl: ttl,
      persistent: persistent,
    );

    return data;
  }

  /// Check if cache exists and is valid
  Future<bool> has(String key, {Duration? ttl}) async {
    final cached = await get<dynamic>(
      key: key,
      fromJson: (data) => data,
      ttl: ttl,
    );
    return cached != null;
  }

  /// Invalidate specific cache key
  Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    if (_prefs != null) {
      await _prefs!.remove(_cacheKey(key));
    }
    debugPrint('🗑️ Invalidated cache: $key');
  }

  /// Invalidate cache by pattern (e.g., all jobs-related cache)
  Future<void> invalidatePattern(String pattern) async {
    // Memory cache
    _memoryCache.removeWhere((key, _) => key.contains(pattern));

    // Persistent cache
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_') && key.contains(pattern)) {
          await _prefs!.remove(key);
        }
      }
    }
    debugPrint('🗑️ Invalidated pattern: $pattern');
  }

  /// Clear all cache
  Future<void> clearAll() async {
    _memoryCache.clear();
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await _prefs!.remove(key);
        }
      }
    }
    debugPrint('🗑️ Cleared all cache');
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memoryCacheSize': _memoryCache.length,
      'memoryKeys': _memoryCache.keys.toList(),
    };
  }

  // Private helpers

  String _cacheKey(String key) => 'cache_$key';

  void _enforceMemoryCacheSize() {
    if (_memoryCache.length > maxMemoryCacheSize) {
      // Remove oldest entries
      final sortedKeys = _memoryCache.keys.toList()
        ..sort((a, b) => _memoryCache[a]!
            .timestamp
            .compareTo(_memoryCache[b]!.timestamp));

      final toRemove = sortedKeys.take(_memoryCache.length - maxMemoryCacheSize);
      for (final key in toRemove) {
        _memoryCache.remove(key);
      }
      debugPrint('🧹 Cleaned ${toRemove.length} old cache entries');
    }
  }

  Future<void> _cleanExpiredCache() async {
    // Clean memory cache
    _memoryCache.removeWhere((key, cached) => cached.isExpired(defaultTTL));

    // Clean persistent cache
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      int cleaned = 0;

      for (final key in keys) {
        if (key.startsWith('cache_')) {
          try {
            final jsonString = _prefs!.getString(key);
            if (jsonString != null) {
              final json = jsonDecode(jsonString);
              final cached = CachedResponse.fromJson(json);

              if (cached.isExpired(defaultTTL)) {
                await _prefs!.remove(key);
                cleaned++;
              }
            }
          } catch (e) {
            // Remove corrupted cache
            await _prefs!.remove(key);
            cleaned++;
          }
        }
      }

      if (cleaned > 0) {
        debugPrint('🧹 Cleaned $cleaned expired/corrupted cache entries');
      }
    }
  }
}

/// Cached response wrapper
class CachedResponse {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;

  CachedResponse({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool isExpired(Duration customTTL) {
    final age = DateTime.now().difference(timestamp);
    return age > customTTL;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'ttl': ttl.inMilliseconds,
    };
  }

  factory CachedResponse.fromJson(Map<String, dynamic> json) {
    return CachedResponse(
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      ttl: Duration(milliseconds: json['ttl']),
    );
  }

  /// Get age of cached data
  Duration get age => DateTime.now().difference(timestamp);
}

/// Cache key builder for consistency
class CacheKeys {
  // Jobs
  static String jobs({int page = 1, String? search}) =>
      'jobs_p${page}_s${search ?? 'all'}';
  static String jobApplications({int page = 1}) => 'job_applications_p$page';
  static String jobDetails(String id) => 'job_$id';

  // Account
  static const String accountEarnings = 'account_earnings';
  static String accountTransactions({int page = 1}) =>
      'account_transactions_p$page';
  static const String accountProfile = 'account_profile';

  // Catalog
  static String catalogRequests({int page = 1}) => 'catalog_requests_p$page';
  static String catalogItems({int page = 1}) => 'catalog_items_p$page';

  // Messages
  static const String conversations = 'conversations';
  static String chatMessages(String conversationId) => 'chat_$conversationId';
}
