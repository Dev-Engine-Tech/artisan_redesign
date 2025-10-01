import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Abstract analytics service interface following Dependency Inversion Principle
/// This allows easy mocking and different analytics implementations
abstract class AnalyticsService {
  // User Analytics
  Future<void> setUserId(String userId);
  Future<void> setUserProperty(String name, String value);
  Future<void> logLogin(String method);
  Future<void> logSignUp(String method);

  // Screen Analytics
  Future<void> logScreenView(String screenName, String screenClass);
  Future<void> setCurrentScreen(String screenName, String screenClass);

  // Security Analytics
  Future<void> logSecurityEvent(String eventName, Map<String, dynamic> parameters);
  Future<void> logAuthenticationFailure(String method, String reason);
  Future<void> logSuspiciousActivity(String activity, Map<String, dynamic> context);

  // Performance Analytics
  Future<void> logPerformanceEvent(String eventName, Map<String, dynamic> metrics);
  Future<void> logSlowOperation(String operation, Duration duration);
  Future<void> logMemoryWarning(int memoryUsage);

  // Business Analytics
  Future<void> logJobApplication(String jobId, String category);
  Future<void> logJobAcceptance(String jobId, double amount);
  Future<void> logWithdrawal(double amount, String method);
  Future<void> logError(String error, Map<String, dynamic> context);

  // Custom Events
  Future<void> logEvent(String name, Map<String, dynamic> parameters);

  // Performance Monitoring
  Trace? startTrace(String name);
}

/// Comprehensive Firebase Analytics service implementation
/// Follows Single Responsibility Principle - handles all analytics and monitoring
/// Follows Open/Closed Principle - extensible through composition
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;

  static final FirebaseAnalyticsService _instance = FirebaseAnalyticsService._internal();
  factory FirebaseAnalyticsService() => _instance;
  FirebaseAnalyticsService._internal();

  bool _available = false;
  bool _warned = false;

  /// Initialize Firebase Analytics with enhanced configuration
  Future<void> initialize() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      await _crashlytics.setCustomKey('flutter_channel', 'stable');
      await _crashlytics.setCustomKey('app_version', '1.0.0');
      await _performance.setPerformanceCollectionEnabled(true);

      await logEvent('analytics_initialized', {
        'timestamp': DateTime.now().toIso8601String(),
        'debug_mode': kDebugMode,
      });
      _available = true;
    } catch (_) {
      _available = false;
      // Do not fail app startup
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!_available) return;
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      _handleError('set_user_id_failed', e);
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (!_available) return;
    try {
      await _analytics.setUserProperty(name: name, value: value);
      await _crashlytics.setCustomKey(name, value);
    } catch (e) {
      _handleError('set_user_property_failed', e);
    }
  }

  @override
  Future<void> logLogin(String method) async {
    if (!_available) return;
    try {
      await _analytics.logLogin(loginMethod: method);
      await logSecurityEvent('user_login_success', {
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _handleError('log_login_failed', e);
    }
  }

  @override
  Future<void> logSignUp(String method) async {
    if (!_available) return;
    try {
      await _analytics.logSignUp(signUpMethod: method);
      await logEvent('user_registration', {
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': defaultTargetPlatform.name,
      });
    } catch (e) {
      _handleError('log_signup_failed', e);
    }
  }

  @override
  Future<void> logScreenView(String screenName, String screenClass) async {
    if (!_available) return;
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      await logEvent('screen_view_enhanced', {
        'screen_name': screenName,
        'screen_class': screenClass,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _handleError('log_screen_view_failed', e);
    }
  }

  @override
  Future<void> setCurrentScreen(String screenName, String screenClass) async {
    if (!_available) return;
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      _handleError('set_current_screen_failed', e);
    }
  }

  @override
  Future<void> logSecurityEvent(String eventName, Map<String, dynamic> parameters) async {
    if (!_available) return;
    try {
      final securityParams = {
        ...parameters,
        'security_event': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _analytics.logEvent(name: eventName, parameters: Map<String, Object>.from(securityParams));
      await _crashlytics.log('Security Event: $eventName');
      await _crashlytics.setCustomKey('last_security_event', eventName);
    } catch (e) {
      _handleError('log_security_event_failed', e);
    }
  }

  @override
  Future<void> logAuthenticationFailure(String method, String reason) async {
    if (!_available) return;
    try {
      await logSecurityEvent('authentication_failure', {
        'method': method,
        'failure_reason': reason,
      });
      await _crashlytics.recordError(
        'Authentication Failure: $method - $reason',
        null,
        fatal: false,
      );
    } catch (e) {
      _handleError('log_auth_failure_failed', e);
    }
  }

  @override
  Future<void> logSuspiciousActivity(String activity, Map<String, dynamic> context) async {
    if (!_available) return;
    try {
      await logSecurityEvent('suspicious_activity_detected', {
        'activity_type': activity,
        'context': context,
      });
    } catch (e) {
      _handleError('log_suspicious_activity_failed', e);
    }
  }

  @override
  Future<void> logPerformanceEvent(String eventName, Map<String, dynamic> metrics) async {
    if (!_available) return;
    try {
      final performanceParams = {
        ...metrics,
        'performance_event': true,
      };
      await _analytics.logEvent(name: eventName, parameters: Map<String, Object>.from(performanceParams));
    } catch (e) {
      _handleError('log_performance_event_failed', e);
    }
  }

  @override
  Future<void> logSlowOperation(String operation, Duration duration) async {
    if (!_available) return;
    try {
      await logPerformanceEvent('slow_operation_detected', {
        'operation_name': operation,
        'duration_ms': duration.inMilliseconds,
        'threshold_exceeded': duration.inMilliseconds > 1000,
      });
    } catch (e) {
      _handleError('log_slow_operation_failed', e);
    }
  }

  @override
  Future<void> logMemoryWarning(int memoryUsage) async {
    if (!_available) return;
    try {
      await logPerformanceEvent('memory_warning', {
        'memory_usage_mb': memoryUsage,
      });
    } catch (e) {
      _handleError('log_memory_warning_failed', e);
    }
  }

  @override
  Future<void> logJobApplication(String jobId, String category) async {
    if (!_available) return;
    try {
      await _analytics.logEvent(name: 'job_application', parameters: {
        'job_id': jobId,
        'job_category': category,
        'application_source': 'mobile_app',
      });
    } catch (e) {
      _handleError('log_job_application_failed', e);
    }
  }

  @override
  Future<void> logJobAcceptance(String jobId, double amount) async {
    if (!_available) return;
    try {
      await _analytics.logEvent(name: 'job_acceptance', parameters: {
        'job_id': jobId,
        'job_value': amount,
        'currency': 'NGN',
        'acceptance_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _handleError('log_job_acceptance_failed', e);
    }
  }

  @override
  Future<void> logWithdrawal(double amount, String method) async {
    if (!_available) return;
    try {
      await _analytics.logEvent(name: 'withdrawal_request', parameters: {
        'amount': amount,
        'currency': 'NGN',
        'withdrawal_method': method,
      });
    } catch (e) {
      _handleError('log_withdrawal_failed', e);
    }
  }

  @override
  Future<void> logError(String error, Map<String, dynamic> context) async {
    if (!_available) return;
    try {
      await _crashlytics.recordError(
        error,
        StackTrace.current,
        fatal: false,
        information: context.entries.map((e) => '${e.key}: ${e.value}').toList(),
      );

      await logEvent('app_error', {
        'error_message': error,
        'error_context': context,
      });
    } catch (e) {
      // Last resort logging
    }
  }

  @override
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    if (!_available) return;
    try {
      final sanitizedParams = _sanitizeParameters(parameters);
      await _analytics.logEvent(name: name, parameters: Map<String, Object>.from(sanitizedParams));
    } catch (e) {
      _handleError('log_event_failed', e);
    }
  }

  @override
  Trace? startTrace(String name) {
    try {
      return _performance.newTrace(name);
    } catch (e) {
      _handleError('start_trace_failed', e);
      return null;
    }
  }

  void _handleError(String event, dynamic error) {
    if (!_warned && kDebugMode) {
      _warned = true;
      // ignore: avoid_print
      print('Firebase Analytics Error ($event): $error');
    }
  }

  Map<String, dynamic> _sanitizeParameters(Map<String, dynamic> parameters) {
    final sanitized = <String, dynamic>{};
    for (final entry in parameters.entries) {
      final key = entry.key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final value = entry.value;
      if (value is String || value is num || value is bool) {
        sanitized[key] = value;
      } else {
        sanitized[key] = value.toString();
      }
    }
    return sanitized;
  }
}

/// Firebase Analytics observer for route tracking
class FirebaseAnalyticsRouteObserver extends RouteObserver<ModalRoute> {
  final AnalyticsService _analyticsService;

  FirebaseAnalyticsRouteObserver(this._analyticsService);

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _logRouteChange(previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logRouteChange(newRoute);
    }
  }

  void _logRouteChange(Route route) {
    final routeName = route.settings.name ?? 'unnamed_route';
    final routeClass = route.runtimeType.toString();
    _analyticsService.logScreenView(routeName, routeClass);
    _analyticsService.setCurrentScreen(routeName, routeClass);
  }
}
