import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/error_handler.dart';

/// Log level enumeration
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical
}

/// Log entry class
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? details;
  final String? stackTrace;
  final Map<String, dynamic>? context;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.details,
    this.stackTrace,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'details': details,
      'stackTrace': stackTrace,
      'context': context,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp']),
      level: LogLevel.values.firstWhere((e) => e.name == json['level']),
      message: json['message'],
      details: json['details'],
      stackTrace: json['stackTrace'],
      context: json['context'],
    );
  }
}

/// Comprehensive logging service with crash reporting capabilities
class LoggingService {
  static const String _logsKey = 'app_logs';
  static const String _crashReportsKey = 'crash_reports';
  static const int _maxLogEntries = 500;
  static const int _maxCrashReports = 50;
  
  static SharedPreferences? _prefs;
  static final List<LogEntry> _memoryLogs = [];
  static bool _initialized = false;

  /// Initialize the logging service
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      
      // Load existing logs from storage
      await _loadLogsFromStorage();
      
      // Set up error handler integration
      ErrorHandler.errorStream?.listen((errorInfo) {
        logError(
          errorInfo.message,
          details: errorInfo.details,
          stackTrace: errorInfo.stackTrace,
          context: errorInfo.context,
        );
      });
      
      logInfo('LoggingService initialized successfully');
    } catch (e) {
      debugPrint('LoggingService: Failed to initialize: $e');
    }
  }

  /// Log debug message
  static void logDebug(
    String message, {
    String? details,
    Map<String, dynamic>? context,
  }) {
    if (kDebugMode) {
      _log(LogLevel.debug, message, details: details, context: context);
    }
  }

  /// Log info message
  static void logInfo(
    String message, {
    String? details,
    Map<String, dynamic>? context,
  }) {
    _log(LogLevel.info, message, details: details, context: context);
  }

  /// Log warning message
  static void logWarning(
    String message, {
    String? details,
    Map<String, dynamic>? context,
  }) {
    _log(LogLevel.warning, message, details: details, context: context);
  }

  /// Log error message
  static void logError(
    String message, {
    String? details,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _log(
      LogLevel.error,
      message,
      details: details,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Log critical error message
  static void logCritical(
    String message, {
    String? details,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _log(
      LogLevel.critical,
      message,
      details: details,
      stackTrace: stackTrace,
      context: context,
    );
    
    // Also save as crash report
    _saveCrashReport(message, details, stackTrace, context);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? details,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final logEntry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      details: details,
      stackTrace: stackTrace,
      context: context,
    );

    // Add to memory logs
    _memoryLogs.add(logEntry);
    
    // Maintain memory log size
    if (_memoryLogs.length > _maxLogEntries) {
      _memoryLogs.removeAt(0);
    }

    // Debug print in development
    if (kDebugMode) {
      debugPrint('[${level.name.toUpperCase()}] $message');
      if (details != null) {
        debugPrint('Details: $details');
      }
    }

    // Save to persistent storage periodically
    if (_memoryLogs.length % 10 == 0) {
      _saveLogsToDisk();
    }
  }

  /// Save logs to persistent storage
  static Future<void> _saveLogsToDisk() async {
    if (!_initialized || _prefs == null) return;

    try {
      final logsJson = _memoryLogs.map((log) => jsonEncode(log.toJson())).toList();
      await _prefs!.setStringList(_logsKey, logsJson);
    } catch (e) {
      debugPrint('LoggingService: Failed to save logs to disk: $e');
    }
  }

  /// Load logs from persistent storage
  static Future<void> _loadLogsFromStorage() async {
    if (!_initialized || _prefs == null) return;

    try {
      final logsJson = _prefs!.getStringList(_logsKey) ?? [];
      _memoryLogs.clear();
      
      for (final logJson in logsJson) {
        try {
          final logData = jsonDecode(logJson);
          final logEntry = LogEntry.fromJson(logData);
          _memoryLogs.add(logEntry);
        } catch (e) {
          debugPrint('LoggingService: Failed to parse log entry: $e');
        }
      }
    } catch (e) {
      debugPrint('LoggingService: Failed to load logs from storage: $e');
    }
  }

  /// Save crash report
  static Future<void> _saveCrashReport(
    String message,
    String? details,
    String? stackTrace,
    Map<String, dynamic>? context,
  ) async {
    if (!_initialized || _prefs == null) return;

    try {
      final crashReport = {
        'timestamp': DateTime.now().toIso8601String(),
        'message': message,
        'details': details,
        'stackTrace': stackTrace,
        'context': context,
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
      };

      final existingReports = _prefs!.getStringList(_crashReportsKey) ?? [];
      existingReports.add(jsonEncode(crashReport));

      // Maintain crash report limit
      if (existingReports.length > _maxCrashReports) {
        existingReports.removeAt(0);
      }

      await _prefs!.setStringList(_crashReportsKey, existingReports);
    } catch (e) {
      debugPrint('LoggingService: Failed to save crash report: $e');
    }
  }

  /// Get recent logs
  static List<LogEntry> getRecentLogs({int limit = 50}) {
    return _memoryLogs.reversed.take(limit).toList();
  }

  /// Get logs by level
  static List<LogEntry> getLogsByLevel(LogLevel level) {
    return _memoryLogs.where((log) => log.level == level).toList();
  }

  /// Get logs by date range
  static List<LogEntry> getLogsByDateRange(DateTime start, DateTime end) {
    return _memoryLogs.where((log) => 
        log.timestamp.isAfter(start) && log.timestamp.isBefore(end)).toList();
  }

  /// Get crash reports
  static Future<List<Map<String, dynamic>>> getCrashReports() async {
    if (!_initialized || _prefs == null) return [];

    try {
      final reportsJson = _prefs!.getStringList(_crashReportsKey) ?? [];
      return reportsJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('LoggingService: Failed to get crash reports: $e');
      return [];
    }
  }

  /// Clear all logs
  static Future<void> clearLogs() async {
    _memoryLogs.clear();
    
    if (_initialized && _prefs != null) {
      await _prefs!.remove(_logsKey);
    }
  }

  /// Clear crash reports
  static Future<void> clearCrashReports() async {
    if (_initialized && _prefs != null) {
      await _prefs!.remove(_crashReportsKey);
    }
  }

  /// Export logs as JSON string
  static String exportLogsAsJson() {
    final logsData = {
      'exportTimestamp': DateTime.now().toIso8601String(),
      'totalLogs': _memoryLogs.length,
      'logs': _memoryLogs.map((log) => log.toJson()).toList(),
    };
    
    return jsonEncode(logsData);
  }

  /// Get logging statistics
  static Map<String, dynamic> getLoggingStatistics() {
    final stats = <String, dynamic>{
      'totalLogs': _memoryLogs.length,
      'initialized': _initialized,
    };

    // Count by level
    for (final level in LogLevel.values) {
      stats['${level.name}Count'] = _memoryLogs.where((log) => log.level == level).length;
    }

    // Recent activity (last 24 hours)
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    stats['recentLogs'] = _memoryLogs.where((log) => log.timestamp.isAfter(yesterday)).length;

    return stats;
  }

  /// Force save logs to disk
  static Future<void> flushLogs() async {
    await _saveLogsToDisk();
  }

  /// Log app lifecycle events
  static void logAppLifecycle(String event, {Map<String, dynamic>? context}) {
    logInfo('App lifecycle: $event', context: context);
  }

  /// Log performance metrics
  static void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? context,
  }) {
    logInfo(
      'Performance: $operation completed in ${duration.inMilliseconds}ms',
      context: {...?context, 'duration_ms': duration.inMilliseconds},
    );
  }

  /// Log user actions
  static void logUserAction(
    String action, {
    String? screen,
    Map<String, dynamic>? context,
  }) {
    logInfo(
      'User action: $action',
      context: {...?context, 'screen': screen},
    );
  }

  /// Dispose resources
  static void dispose() {
    _saveLogsToDisk();
    _memoryLogs.clear();
    _initialized = false;
  }
}