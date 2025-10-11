import 'dart:async';
import 'package:flutter/foundation.dart';

/// Manages API requests to prevent bottlenecks and crashes
/// Features:
/// - Request throttling
/// - Concurrent request limiting
/// - Automatic retry with exponential backoff
/// - Request cancellation
class ApiRequestManager {
  static final ApiRequestManager _instance = ApiRequestManager._internal();
  factory ApiRequestManager() => _instance;
  ApiRequestManager._internal();

  // Track active requests
  final Map<String, Completer<void>> _activeRequests = {};
  final Map<String, int> _retryCount = {};
  final Map<String, DateTime> _lastRequestTime = {};

  // Configuration
  static const int maxConcurrentRequests = 3;
  static const int maxRetries = 3;
  static const Duration minRequestInterval = Duration(milliseconds: 300);
  static const Duration requestTimeout = Duration(seconds: 30);

  int get activeRequestCount => _activeRequests.length;

  /// Execute a request with throttling and retry logic
  Future<T> execute<T>({
    required String requestId,
    required Future<T> Function() request,
    bool allowRetry = true,
    Duration? customTimeout,
  }) async {
    // Check if request is already in progress
    if (_activeRequests.containsKey(requestId)) {
      debugPrint('⚠️ Request $requestId already in progress, waiting...');
      await _activeRequests[requestId]!.future;
      // Request completed by another caller, return cached or re-execute
    }

    // Throttle requests - prevent rapid-fire calls
    if (_lastRequestTime.containsKey(requestId)) {
      final timeSinceLastRequest =
          DateTime.now().difference(_lastRequestTime[requestId]!);
      if (timeSinceLastRequest < minRequestInterval) {
        final waitTime = minRequestInterval - timeSinceLastRequest;
        debugPrint(
            '⏳ Throttling request $requestId for ${waitTime.inMilliseconds}ms');
        await Future.delayed(waitTime);
      }
    }

    // Limit concurrent requests to prevent overwhelming the server
    while (_activeRequests.length >= maxConcurrentRequests) {
      debugPrint(
          '🚦 Max concurrent requests reached (${_activeRequests.length}/$maxConcurrentRequests), waiting...');
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final completer = Completer<void>();
    _activeRequests[requestId] = completer;
    _lastRequestTime[requestId] = DateTime.now();

    try {
      debugPrint(
          '🚀 Executing request: $requestId (${_activeRequests.length} active)');

      // Execute with timeout
      final result = await request().timeout(customTimeout ?? requestTimeout,
          onTimeout: () {
        throw TimeoutException(
            'Request $requestId timed out after ${(customTimeout ?? requestTimeout).inSeconds}s');
      });

      // Reset retry count on success
      _retryCount.remove(requestId);
      debugPrint('✅ Request completed: $requestId');

      return result;
    } catch (e) {
      debugPrint('❌ Request failed: $requestId - $e');

      // Retry logic with exponential backoff
      if (allowRetry) {
        final retries = _retryCount[requestId] ?? 0;
        if (retries < maxRetries) {
          _retryCount[requestId] = retries + 1;
          final backoffDelay = Duration(milliseconds: 300 * (1 << retries));
          debugPrint(
              '🔄 Retrying request $requestId (attempt ${retries + 1}/$maxRetries) after ${backoffDelay.inMilliseconds}ms');

          await Future.delayed(backoffDelay);

          // Recursive retry
          _activeRequests.remove(requestId);
          completer.complete();
          return execute(
            requestId: requestId,
            request: request,
            allowRetry: allowRetry,
            customTimeout: customTimeout,
          );
        }
      }

      rethrow;
    } finally {
      _activeRequests.remove(requestId);
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  /// Cancel a specific request
  void cancel(String requestId) {
    if (_activeRequests.containsKey(requestId)) {
      _activeRequests[requestId]!.complete();
      _activeRequests.remove(requestId);
      debugPrint('🛑 Cancelled request: $requestId');
    }
  }

  /// Cancel all active requests (useful for widget disposal)
  void cancelAll() {
    for (final completer in _activeRequests.values) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _activeRequests.clear();
    debugPrint('🛑 Cancelled all ${_activeRequests.length} active requests');
  }

  /// Clear retry counts (useful for testing or manual retry)
  void clearRetries() {
    _retryCount.clear();
  }

  /// Get statistics for monitoring
  Map<String, dynamic> getStats() {
    return {
      'activeRequests': _activeRequests.length,
      'retryingRequests': _retryCount.length,
      'totalTrackedRequests': _lastRequestTime.length,
    };
  }
}

/// Extension to simplify usage with Futures
extension ApiRequestManagerExtension on Future {
  Future<T> withRequestManager<T>(String requestId) {
    return ApiRequestManager().execute(
      requestId: requestId,
      request: () => this as Future<T>,
    );
  }
}
