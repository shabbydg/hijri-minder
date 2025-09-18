import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logging_service.dart';

/// Performance monitoring and optimization service
/// Provides methods for tracking performance metrics and optimizing app performance
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();


  final Map<String, Stopwatch> _activeTimers = {};
  final Queue<PerformanceMetric> _metrics = Queue();
  static const int _maxMetrics = 1000;
  
  Timer? _memoryCleanupTimer;
  Timer? _performanceReportTimer;
  
  /// Initialize performance monitoring
  Future<void> initialize() async {
    debugPrint('PerformanceService: Initializing performance monitoring...');
    
    // Start periodic memory cleanup
    _memoryCleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performMemoryCleanup(),
    );
    
    // Start periodic performance reporting
    _performanceReportTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _generatePerformanceReport(),
    );
    
    // Monitor app lifecycle for performance tracking
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));
    
    debugPrint('PerformanceService: Performance monitoring initialized');
  }

  /// Start timing an operation
  void startTimer(String operationName) {
    _activeTimers[operationName] = Stopwatch()..start();
  }

  /// Stop timing an operation and record the metric
  void stopTimer(String operationName, {Map<String, dynamic>? metadata}) {
    final stopwatch = _activeTimers.remove(operationName);
    if (stopwatch != null) {
      stopwatch.stop();
      _recordMetric(PerformanceMetric(
        operationName: operationName,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      ));
    }
  }

  /// Time an async operation
  Future<T> timeOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      _recordMetric(PerformanceMetric(
        operationName: operationName,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
        success: true,
      ));
      return result;
    } catch (e) {
      stopwatch.stop();
      _recordMetric(PerformanceMetric(
        operationName: operationName,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        metadata: {...(metadata ?? {}), 'error': e.toString()},
        success: false,
      ));
      rethrow;
    }
  }

  /// Time a synchronous operation
  T timeSync<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = operation();
      stopwatch.stop();
      _recordMetric(PerformanceMetric(
        operationName: operationName,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
        success: true,
      ));
      return result;
    } catch (e) {
      stopwatch.stop();
      _recordMetric(PerformanceMetric(
        operationName: operationName,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        metadata: {...(metadata ?? {}), 'error': e.toString()},
        success: false,
      ));
      rethrow;
    }
  }

  /// Record a performance metric
  void _recordMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    
    // Keep only the most recent metrics
    while (_metrics.length > _maxMetrics) {
      _metrics.removeFirst();
    }
    
    // Log slow operations
    if (metric.duration.inMilliseconds > 1000) {
      LoggingService.logWarning(
        'Slow operation detected: ${metric.operationName}',
        details: 'Duration: ${metric.duration.inMilliseconds}ms',
        context: metric.metadata,
      );
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    if (_metrics.isEmpty) {
      return {'message': 'No performance data available'};
    }

    final operationStats = <String, List<PerformanceMetric>>{};
    for (final metric in _metrics) {
      operationStats.putIfAbsent(metric.operationName, () => []).add(metric);
    }

    final stats = <String, dynamic>{};
    for (final entry in operationStats.entries) {
      final metrics = entry.value;
      final durations = metrics.map((m) => m.duration.inMilliseconds).toList();
      durations.sort();

      stats[entry.key] = {
        'count': metrics.length,
        'avgDuration': durations.isEmpty ? 0 : durations.reduce((a, b) => a + b) / durations.length,
        'minDuration': durations.isEmpty ? 0 : durations.first,
        'maxDuration': durations.isEmpty ? 0 : durations.last,
        'medianDuration': durations.isEmpty ? 0 : durations[durations.length ~/ 2],
        'successRate': metrics.where((m) => m.success).length / metrics.length * 100,
      };
    }

    return stats;
  }

  /// Get slow operations (operations taking more than threshold)
  List<PerformanceMetric> getSlowOperations({int thresholdMs = 1000}) {
    return _metrics
        .where((metric) => metric.duration.inMilliseconds > thresholdMs)
        .toList()
      ..sort((a, b) => b.duration.compareTo(a.duration));
  }

  /// Get failed operations
  List<PerformanceMetric> getFailedOperations() {
    return _metrics.where((metric) => !metric.success).toList();
  }

  /// Perform memory cleanup
  void _performMemoryCleanup() {
    debugPrint('PerformanceService: Performing memory cleanup...');
    
    // Clear old metrics (keep only last hour)
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 1));
    _metrics.removeWhere((metric) => metric.timestamp.isBefore(cutoffTime));
    
    // Clear inactive timers
    _activeTimers.removeWhere((key, stopwatch) => !stopwatch.isRunning);
    
    // Trigger garbage collection in debug mode
    if (kDebugMode) {
      SystemChannels.platform.invokeMethod('System.gc');
    }
    
    debugPrint('PerformanceService: Memory cleanup completed');
  }

  /// Generate performance report
  void _generatePerformanceReport() {
    final stats = getPerformanceStats();
    final slowOps = getSlowOperations();
    final failedOps = getFailedOperations();
    
    LoggingService.logInfo(
      'Performance Report',
      details: 'Operations: ${stats.keys.length}, Slow: ${slowOps.length}, Failed: ${failedOps.length}',
      context: {
        'stats': stats,
        'slowOperations': slowOps.take(5).map((op) => {
          'operation': op.operationName,
          'duration': op.duration.inMilliseconds,
        }).toList(),
      },
    );
  }

  /// Optimize widget rebuilds by providing a performance-aware builder
  Widget optimizedBuilder({
    required String operationName,
    required Widget Function() builder,
    Duration? cacheFor,
  }) {
    return _OptimizedWidget(
      operationName: operationName,
      builder: builder,
      cacheFor: cacheFor,
      performanceService: this,
    );
  }

  /// Batch multiple operations for better performance
  Future<List<T>> batchOperations<T>(
    String batchName,
    List<Future<T> Function()> operations, {
    int? concurrency,
  }) async {
    return await timeOperation(
      'batch_$batchName',
      () async {
        if (concurrency != null && concurrency > 0) {
          // Limit concurrency
          final results = <T>[];
          for (int i = 0; i < operations.length; i += concurrency) {
            final batch = operations.skip(i).take(concurrency);
            final batchResults = await Future.wait(batch.map((op) => op()));
            results.addAll(batchResults);
          }
          return results;
        } else {
          // Run all operations concurrently
          return await Future.wait(operations.map((op) => op()));
        }
      },
      metadata: {
        'operationCount': operations.length,
        'concurrency': concurrency,
      },
    );
  }

  /// Debounce function calls to improve performance
  Timer? _debounceTimer;
  void debounce(String operationName, VoidCallback callback, Duration delay) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      timeSync(operationName, callback);
    });
  }

  /// Throttle function calls to limit execution frequency
  final Map<String, DateTime> _lastThrottleExecution = {};
  void throttle(String operationName, VoidCallback callback, Duration interval) {
    final now = DateTime.now();
    final lastExecution = _lastThrottleExecution[operationName];
    
    if (lastExecution == null || now.difference(lastExecution) >= interval) {
      _lastThrottleExecution[operationName] = now;
      timeSync(operationName, callback);
    }
  }

  /// Clear all performance data
  void clearMetrics() {
    _metrics.clear();
    _activeTimers.clear();
    _lastThrottleExecution.clear();
    debugPrint('PerformanceService: All performance metrics cleared');
  }

  /// Dispose of the service
  void dispose() {
    _memoryCleanupTimer?.cancel();
    _performanceReportTimer?.cancel();
    _debounceTimer?.cancel();
    clearMetrics();
  }
}

/// Performance metric data class
class PerformanceMetric {
  final String operationName;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final bool success;

  const PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    required this.metadata,
    this.success = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'operationName': operationName,
      'duration': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'success': success,
    };
  }
}

/// App lifecycle observer for performance tracking
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final PerformanceService _performanceService;

  _AppLifecycleObserver(this._performanceService);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _performanceService.startTimer('app_foreground_time');
        break;
      case AppLifecycleState.paused:
        _performanceService.stopTimer('app_foreground_time');
        break;
      case AppLifecycleState.detached:
        _performanceService.dispose();
        break;
      default:
        break;
    }
  }
}

/// Optimized widget that caches its build result
class _OptimizedWidget extends StatefulWidget {
  final String operationName;
  final Widget Function() builder;
  final Duration? cacheFor;
  final PerformanceService performanceService;

  const _OptimizedWidget({
    required this.operationName,
    required this.builder,
    this.cacheFor,
    required this.performanceService,
  });

  @override
  State<_OptimizedWidget> createState() => _OptimizedWidgetState();
}

class _OptimizedWidgetState extends State<_OptimizedWidget> {
  Widget? _cachedWidget;
  DateTime? _cacheTime;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    // Check if we can use cached widget
    if (_cachedWidget != null && 
        _cacheTime != null && 
        widget.cacheFor != null &&
        now.difference(_cacheTime!) < widget.cacheFor!) {
      return _cachedWidget!;
    }

    // Build new widget with performance tracking
    final newWidget = widget.performanceService.timeSync(
      'widget_build_${widget.operationName}',
      widget.builder,
    );

    // Cache the widget if caching is enabled
    if (widget.cacheFor != null) {
      _cachedWidget = newWidget;
      _cacheTime = now;
    }

    return newWidget;
  }
}