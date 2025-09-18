import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

/// Enum for different types of errors
enum ErrorType {
  network,
  permission,
  validation,
  storage,
  api,
  location,
  notification,
  parsing,
  unknown
}

/// Enum for error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical
}

/// Error information class
class ErrorInfo {
  final String message;
  final String? details;
  final ErrorType type;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String? stackTrace;
  final Map<String, dynamic>? context;

  const ErrorInfo({
    required this.message,
    this.details,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.stackTrace,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'details': details,
      'type': type.name,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'stackTrace': stackTrace,
      'context': context,
    };
  }

  factory ErrorInfo.fromException(
    Exception exception, {
    ErrorType? type,
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? context,
  }) {
    String message = exception.toString();
    ErrorType errorType = type ?? _determineErrorType(exception);
    
    return ErrorInfo(
      message: message,
      type: errorType,
      severity: severity,
      timestamp: DateTime.now(),
      stackTrace: kDebugMode ? StackTrace.current.toString() : null,
      context: context,
    );
  }

  static ErrorType _determineErrorType(Exception exception) {
    if (exception is SocketException || exception is TimeoutException) {
      return ErrorType.network;
    } else if (exception is FormatException) {
      return ErrorType.parsing;
    } else {
      return ErrorType.unknown;
    }
  }
}

/// Centralized error handler for the application
class ErrorHandler {
  static final List<ErrorInfo> _errorLog = [];
  static const int _maxLogSize = 100;
  static StreamController<ErrorInfo>? _errorStreamController;

  /// Initialize error handler
  static void initialize() {
    _errorStreamController = StreamController<ErrorInfo>.broadcast();
    
    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorInfo = ErrorInfo(
        message: details.exception.toString(),
        details: details.summary.toString(),
        type: ErrorType.unknown,
        severity: ErrorSeverity.high,
        timestamp: DateTime.now(),
        stackTrace: kDebugMode ? details.stack.toString() : null,
        context: {'library': details.library},
      );
      
      _logError(errorInfo);
    };
  }

  /// Handle error with fallback mechanism
  static Future<T> withFallback<T>(
    Future<T> Function() primary,
    T Function() fallback,
    String operation, {
    ErrorType errorType = ErrorType.unknown,
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? context,
  }) async {
    try {
      return await primary();
    } catch (e) {
      final errorInfo = ErrorInfo(
        message: 'Error in $operation: ${e.toString()}',
        type: errorType,
        severity: severity,
        timestamp: DateTime.now(),
        stackTrace: kDebugMode ? StackTrace.current.toString() : null,
        context: context,
      );
      
      _logError(errorInfo);
      return fallback();
    }
  }

  /// Handle error with retry mechanism
  static Future<T?> withRetry<T>(
    Future<T> Function() operation,
    String operationName, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    ErrorType errorType = ErrorType.unknown,
    Map<String, dynamic>? context,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        final errorInfo = ErrorInfo(
          message: 'Attempt $attempts/$maxRetries failed for $operationName: ${e.toString()}',
          type: errorType,
          severity: attempts == maxRetries ? ErrorSeverity.high : ErrorSeverity.low,
          timestamp: DateTime.now(),
          stackTrace: kDebugMode ? StackTrace.current.toString() : null,
          context: {...?context, 'attempt': attempts, 'maxRetries': maxRetries},
        );
        
        _logError(errorInfo);
        
        if (attempts < maxRetries) {
          await Future.delayed(delay * attempts); // Exponential backoff
        }
      }
    }
    
    return null;
  }

  /// Log error information
  static void logError(
    String message, {
    String? details,
    ErrorType type = ErrorType.unknown,
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? context,
  }) {
    final errorInfo = ErrorInfo(
      message: message,
      details: details,
      type: type,
      severity: severity,
      timestamp: DateTime.now(),
      stackTrace: kDebugMode ? StackTrace.current.toString() : null,
      context: context,
    );
    
    _logError(errorInfo);
  }

  /// Internal method to log error
  static void _logError(ErrorInfo errorInfo) {
    // Add to error log
    _errorLog.add(errorInfo);
    
    // Maintain log size
    if (_errorLog.length > _maxLogSize) {
      _errorLog.removeAt(0);
    }
    
    // Emit to stream
    _errorStreamController?.add(errorInfo);
    
    // Debug print in development
    if (kDebugMode) {
      debugPrint('ERROR [${errorInfo.type.name}]: ${errorInfo.message}');
      if (errorInfo.details != null) {
        debugPrint('DETAILS: ${errorInfo.details}');
      }
    }
  }

  /// Get error stream for listening to errors
  static Stream<ErrorInfo>? get errorStream => _errorStreamController?.stream;

  /// Get recent errors
  static List<ErrorInfo> getRecentErrors({int limit = 10}) {
    return _errorLog.reversed.take(limit).toList();
  }

  /// Get errors by type
  static List<ErrorInfo> getErrorsByType(ErrorType type) {
    return _errorLog.where((error) => error.type == type).toList();
  }

  /// Get errors by severity
  static List<ErrorInfo> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorLog.where((error) => error.severity == severity).toList();
  }

  /// Clear error log
  static void clearErrorLog() {
    _errorLog.clear();
  }

  /// Get error statistics
  static Map<String, int> getErrorStatistics() {
    final stats = <String, int>{};
    
    // Count by type
    for (final type in ErrorType.values) {
      stats['type_${type.name}'] = _errorLog.where((e) => e.type == type).length;
    }
    
    // Count by severity
    for (final severity in ErrorSeverity.values) {
      stats['severity_${severity.name}'] = _errorLog.where((e) => e.severity == severity).length;
    }
    
    stats['total'] = _errorLog.length;
    
    return stats;
  }

  /// Show user-friendly error message
  static void showUserError(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show user-friendly error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(ErrorType type, String originalMessage) {
    switch (type) {
      case ErrorType.network:
        return 'Network connection error. Please check your internet connection and try again.';
      case ErrorType.permission:
        return 'Permission required. Please grant the necessary permissions in your device settings.';
      case ErrorType.validation:
        return 'Invalid input. Please check your data and try again.';
      case ErrorType.storage:
        return 'Storage error. Please ensure you have enough storage space.';
      case ErrorType.api:
        return 'Service temporarily unavailable. Please try again later.';
      case ErrorType.location:
        return 'Location services error. Please enable location services and try again.';
      case ErrorType.notification:
        return 'Notification error. Please check your notification settings.';
      case ErrorType.parsing:
        return 'Data processing error. Please try again.';
      case ErrorType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Dispose resources
  static void dispose() {
    _errorStreamController?.close();
    _errorStreamController = null;
  }
}

/// Extension for easier error handling
extension ErrorHandlerExtension on Future {
  /// Add error handling with fallback
  Future<T> withErrorHandling<T>(
    T fallback,
    String operation, {
    ErrorType errorType = ErrorType.unknown,
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? context,
  }) {
    return ErrorHandler.withFallback<T>(
      () => this as Future<T>,
      () => fallback,
      operation,
      errorType: errorType,
      severity: severity,
      context: context,
    );
  }
}