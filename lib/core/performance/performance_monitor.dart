import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// import 'package:artisans_circle/core/analytics/firebase_analytics_service.dart';

/// Performance monitoring utility following SOLID principles
/// Single Responsibility: Only handles performance monitoring and metrics
/// Open/Closed: Extensible for different monitoring strategies
/// Interface Segregation: Provides focused monitoring interface
abstract class PerformanceMonitor {
  void startTimer(String name);
  void endTimer(String name);
  void trackMemoryUsage(String context);
  void trackWidgetRebuild(String widgetName);
  void trackNetworkRequest(String endpoint, Duration duration, bool success);
  void trackFrameRate();
  void generateReport();
}

/// Default implementation of performance monitoring
class DefaultPerformanceMonitor implements PerformanceMonitor {
  static final DefaultPerformanceMonitor _instance = DefaultPerformanceMonitor._internal();
  factory DefaultPerformanceMonitor() => _instance;
  DefaultPerformanceMonitor._internal();

  final Map<String, DateTime> _timers = {};
  final Map<String, Duration> _completedTimers = {};
  final Map<String, int> _widgetRebuildCounts = {};
  final List<NetworkMetric> _networkMetrics = [];
  final List<FrameMetric> _frameMetrics = [];

  bool _isMonitoring = false;
  // AnalyticsService? _analyticsService;

  /// Set analytics service for enhanced monitoring
  // void setAnalyticsService(AnalyticsService analyticsService) {
  //   _analyticsService = analyticsService;
  // }

  /// Enable performance monitoring (only in debug mode)
  void enable() {
    if (kDebugMode) {
      _isMonitoring = true;
      _startFrameRateMonitoring();
      // _analyticsService?.logEvent('performance_monitoring_enabled', {
      //   'timestamp': DateTime.now().toIso8601String(),
      // });
    }
  }

  void disable() {
    _isMonitoring = false;
  }

  @override
  void startTimer(String name) {
    if (!_isMonitoring) return;
    _timers[name] = DateTime.now();
  }

  @override
  void endTimer(String name) {
    if (!_isMonitoring) return;
    final startTime = _timers.remove(name);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _completedTimers[name] = duration;

      // Log slow operations (>100ms)
      if (duration.inMilliseconds > 100) {
        log('⚠️ Slow operation detected: $name took ${duration.inMilliseconds}ms');
        // _analyticsService?.logSlowOperation(name, duration);
      }
    }
  }

  @override
  void trackMemoryUsage(String context) {
    if (!_isMonitoring) return;
    // Note: Flutter doesn't provide direct memory API
    // This is a placeholder for custom memory tracking
    log('Memory usage tracked for: $context');
  }

  @override
  void trackWidgetRebuild(String widgetName) {
    if (!_isMonitoring) return;
    _widgetRebuildCounts[widgetName] = (_widgetRebuildCounts[widgetName] ?? 0) + 1;

    // Log excessive rebuilds
    final rebuildCount = _widgetRebuildCounts[widgetName]!;
    if (rebuildCount > 50 && rebuildCount % 25 == 0) {
      log('⚠️ Excessive rebuilds detected: $widgetName rebuilt $rebuildCount times');
      // _analyticsService?.logPerformanceEvent('excessive_widget_rebuilds', {
      //   'widget_name': widgetName,
      //   'rebuild_count': rebuildCount,
      // });
    }
  }

  @override
  void trackNetworkRequest(String endpoint, Duration duration, bool success) {
    if (!_isMonitoring) return;
    _networkMetrics.add(NetworkMetric(
      endpoint: endpoint,
      duration: duration,
      success: success,
      timestamp: DateTime.now(),
    ));

    // Log slow network requests (>2s)
    if (duration.inMilliseconds > 2000) {
      log('⚠️ Slow network request: $endpoint took ${duration.inMilliseconds}ms');
    }
  }

  @override
  void trackFrameRate() {
    if (!_isMonitoring) return;
    // This is called automatically when monitoring is enabled
  }

  void _startFrameRateMonitoring() {
    SchedulerBinding.instance.addTimingsCallback(_onFrameCallback);
  }

  void _onFrameCallback(List<FrameTiming> timings) {
    if (!_isMonitoring) return;

    for (final timing in timings) {
      final frameDuration = timing.totalSpan;
      _frameMetrics.add(FrameMetric(
        duration: frameDuration,
        timestamp: DateTime.now(),
      ));

      // Log dropped frames (>16.67ms for 60fps)
      if (frameDuration.inMilliseconds > 17) {
        log('⚠️ Dropped frame detected: ${frameDuration.inMilliseconds}ms');
      }
    }

    // Keep only recent metrics (last 1000 frames)
    if (_frameMetrics.length > 1000) {
      _frameMetrics.removeRange(0, _frameMetrics.length - 1000);
    }
  }

  @override
  void generateReport() {
    if (!_isMonitoring && kDebugMode) return;

    log('📊 Performance Report:');
    log('==================');

    // Timer report
    if (_completedTimers.isNotEmpty) {
      log('⏱️ Operation Timings:');
      _completedTimers.forEach((name, duration) {
        log('  $name: ${duration.inMilliseconds}ms');
      });
    }

    // Widget rebuild report
    if (_widgetRebuildCounts.isNotEmpty) {
      log('🔄 Widget Rebuilds:');
      final sortedRebuilds = _widgetRebuildCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedRebuilds.take(10)) {
        log('  ${entry.key}: ${entry.value} rebuilds');
      }
    }

    // Network report
    if (_networkMetrics.isNotEmpty) {
      log('🌐 Network Metrics:');
      final successRate =
          _networkMetrics.where((m) => m.success).length / _networkMetrics.length * 100;
      final avgDuration =
          _networkMetrics.map((m) => m.duration.inMilliseconds).reduce((a, b) => a + b) /
              _networkMetrics.length;
      log('  Success rate: ${successRate.toStringAsFixed(1)}%');
      log('  Average duration: ${avgDuration.toStringAsFixed(0)}ms');
      log('  Total requests: ${_networkMetrics.length}');
    }

    // Frame rate report
    if (_frameMetrics.isNotEmpty) {
      log('🎬 Frame Metrics:');
      final recentFrames =
          _frameMetrics.where((f) => DateTime.now().difference(f.timestamp).inMinutes < 5).toList();

      if (recentFrames.isNotEmpty) {
        final droppedFrames = recentFrames.where((f) => f.duration.inMilliseconds > 17).length;
        final avgFrameTime =
            recentFrames.map((f) => f.duration.inMilliseconds).reduce((a, b) => a + b) /
                recentFrames.length;
        log('  Recent frames: ${recentFrames.length}');
        log('  Dropped frames: $droppedFrames (${(droppedFrames / recentFrames.length * 100).toStringAsFixed(1)}%)');
        log('  Average frame time: ${avgFrameTime.toStringAsFixed(1)}ms');
      }
    }
  }
}

/// Network performance metric data class
class NetworkMetric {
  final String endpoint;
  final Duration duration;
  final bool success;
  final DateTime timestamp;

  NetworkMetric({
    required this.endpoint,
    required this.duration,
    required this.success,
    required this.timestamp,
  });
}

/// Frame performance metric data class
class FrameMetric {
  final Duration duration;
  final DateTime timestamp;

  FrameMetric({
    required this.duration,
    required this.timestamp,
  });
}

/// Performance mixin for widgets to easily track rebuilds
/// Follows Single Responsibility Principle
mixin PerformanceTrackingMixin<T extends StatefulWidget> on State<T> {
  final PerformanceMonitor _monitor = DefaultPerformanceMonitor();

  @override
  void initState() {
    super.initState();
    _monitor.trackWidgetRebuild('${widget.runtimeType}_initState');
  }

  @override
  Widget build(BuildContext context) {
    _monitor.trackWidgetRebuild('${widget.runtimeType}_build');
    return buildWithTracking(context);
  }

  /// Override this instead of build() to get automatic performance tracking
  Widget buildWithTracking(BuildContext context);
}

/// Performance wrapper widget for tracking custom widgets
class PerformanceTracker extends StatefulWidget {
  const PerformanceTracker({
    super.key,
    required this.name,
    required this.child,
  });

  final String name;
  final Widget child;

  @override
  State<PerformanceTracker> createState() => _PerformanceTrackerState();
}

class _PerformanceTrackerState extends State<PerformanceTracker> {
  final PerformanceMonitor _monitor = DefaultPerformanceMonitor();

  @override
  Widget build(BuildContext context) {
    _monitor.trackWidgetRebuild(widget.name);
    return widget.child;
  }
}

/// Utility functions for easy performance monitoring
class Performance {
  static final PerformanceMonitor _monitor = DefaultPerformanceMonitor();

  static void enable() => (_monitor as DefaultPerformanceMonitor).enable();
  static void disable() => (_monitor as DefaultPerformanceMonitor).disable();

  static void time(String name, Future<void> Function() operation) async {
    _monitor.startTimer(name);
    try {
      await operation();
    } finally {
      _monitor.endTimer(name);
    }
  }

  static T timeSync<T>(String name, T Function() operation) {
    _monitor.startTimer(name);
    try {
      return operation();
    } finally {
      _monitor.endTimer(name);
    }
  }

  static void trackRebuild(String widgetName) {
    _monitor.trackWidgetRebuild(widgetName);
  }

  static void trackNetwork(String endpoint, Duration duration, bool success) {
    _monitor.trackNetworkRequest(endpoint, duration, success);
  }

  static void generateReport() {
    _monitor.generateReport();
  }
}
