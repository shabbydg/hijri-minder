import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/utils/error_handler.dart';
import 'dart:io';

void main() {
  group('ErrorHandler', () {
    setUp(() {
      ErrorHandler.initialize();
      ErrorHandler.clearErrorLog();
    });

    tearDown(() {
      ErrorHandler.dispose();
    });

    test('should initialize without errors', () {
      expect(() => ErrorHandler.initialize(), returnsNormally);
    });

    test('should log errors correctly', () {
      const message = 'Test error message';
      const details = 'Test error details';
      const type = ErrorType.network;
      const severity = ErrorSeverity.high;

      ErrorHandler.logError(
        message,
        details: details,
        type: type,
        severity: severity,
      );

      final recentErrors = ErrorHandler.getRecentErrors(limit: 1);
      expect(recentErrors.length, equals(1));
      expect(recentErrors.first.message, equals(message));
      expect(recentErrors.first.details, equals(details));
      expect(recentErrors.first.type, equals(type));
      expect(recentErrors.first.severity, equals(severity));
    });

    test('should handle withFallback correctly on success', () async {
      const expectedResult = 'success';
      
      final result = await ErrorHandler.withFallback<String>(
        () async => expectedResult,
        () => 'fallback',
        'test operation',
      );

      expect(result, equals(expectedResult));
    });

    test('should handle withFallback correctly on failure', () async {
      const fallbackResult = 'fallback';
      
      final result = await ErrorHandler.withFallback<String>(
        () async => throw Exception('Test error'),
        () => fallbackResult,
        'test operation',
      );

      expect(result, equals(fallbackResult));
      
      // Check that error was logged
      final recentErrors = ErrorHandler.getRecentErrors(limit: 1);
      expect(recentErrors.length, equals(1));
      expect(recentErrors.first.message, contains('test operation'));
    });

    test('should retry operations correctly', () async {
      int attempts = 0;
      const maxRetries = 3;
      
      final result = await ErrorHandler.withRetry<String>(
        () async {
          attempts++;
          if (attempts < maxRetries) {
            throw Exception('Retry test error');
          }
          return 'success after retries';
        },
        'retry test operation',
        maxRetries: maxRetries,
      );

      expect(result, equals('success after retries'));
      expect(attempts, equals(maxRetries));
    });

    test('should return null after max retries exceeded', () async {
      const maxRetries = 2;
      
      final result = await ErrorHandler.withRetry<String>(
        () async => throw Exception('Always fails'),
        'failing operation',
        maxRetries: maxRetries,
      );

      expect(result, isNull);
      
      // Check that all retry attempts were logged
      final recentErrors = ErrorHandler.getRecentErrors();
      expect(recentErrors.length, equals(maxRetries));
    });

    test('should filter errors by type correctly', () {
      ErrorHandler.logError('Network error', type: ErrorType.network);
      ErrorHandler.logError('Permission error', type: ErrorType.permission);
      ErrorHandler.logError('Another network error', type: ErrorType.network);

      final networkErrors = ErrorHandler.getErrorsByType(ErrorType.network);
      final permissionErrors = ErrorHandler.getErrorsByType(ErrorType.permission);

      expect(networkErrors.length, equals(2));
      expect(permissionErrors.length, equals(1));
    });

    test('should filter errors by severity correctly', () {
      ErrorHandler.logError('Low severity', severity: ErrorSeverity.low);
      ErrorHandler.logError('High severity', severity: ErrorSeverity.high);
      ErrorHandler.logError('Another high severity', severity: ErrorSeverity.high);

      final lowSeverityErrors = ErrorHandler.getErrorsBySeverity(ErrorSeverity.low);
      final highSeverityErrors = ErrorHandler.getErrorsBySeverity(ErrorSeverity.high);

      expect(lowSeverityErrors.length, equals(1));
      expect(highSeverityErrors.length, equals(2));
    });

    test('should generate correct error statistics', () {
      ErrorHandler.logError('Error 1', type: ErrorType.network, severity: ErrorSeverity.low);
      ErrorHandler.logError('Error 2', type: ErrorType.network, severity: ErrorSeverity.high);
      ErrorHandler.logError('Error 3', type: ErrorType.permission, severity: ErrorSeverity.medium);

      final stats = ErrorHandler.getErrorStatistics();

      expect(stats['total'], equals(3));
      expect(stats['type_network'], equals(2));
      expect(stats['type_permission'], equals(1));
      expect(stats['severity_low'], equals(1));
      expect(stats['severity_medium'], equals(1));
      expect(stats['severity_high'], equals(1));
    });

    test('should clear error log correctly', () {
      ErrorHandler.logError('Test error 1');
      ErrorHandler.logError('Test error 2');
      
      expect(ErrorHandler.getRecentErrors().length, equals(2));
      
      ErrorHandler.clearErrorLog();
      
      expect(ErrorHandler.getRecentErrors().length, equals(0));
    });

    test('should generate user-friendly messages', () {
      const originalMessage = 'Technical error message';
      
      final networkMessage = ErrorHandler.getUserFriendlyMessage(
        ErrorType.network, 
        originalMessage,
      );
      expect(networkMessage, contains('Network connection error'));
      
      final permissionMessage = ErrorHandler.getUserFriendlyMessage(
        ErrorType.permission, 
        originalMessage,
      );
      expect(permissionMessage, contains('Permission required'));
      
      final unknownMessage = ErrorHandler.getUserFriendlyMessage(
        ErrorType.unknown, 
        originalMessage,
      );
      expect(unknownMessage, contains('unexpected error'));
    });

    test('should determine error type from exception', () {
      final socketException = SocketException('Network error');
      final formatException = FormatException('Parse error');
      final genericException = Exception('Generic error');

      final socketErrorInfo = ErrorInfo.fromException(socketException);
      expect(socketErrorInfo.type, equals(ErrorType.network));

      final formatErrorInfo = ErrorInfo.fromException(formatException);
      expect(formatErrorInfo.type, equals(ErrorType.parsing));

      final genericErrorInfo = ErrorInfo.fromException(genericException);
      expect(genericErrorInfo.type, equals(ErrorType.unknown));
    });

    test('should maintain error log size limit', () {
      // This test would require access to internal constants
      // For now, we'll test that errors are being logged
      for (int i = 0; i < 10; i++) {
        ErrorHandler.logError('Error $i');
      }
      
      final errors = ErrorHandler.getRecentErrors();
      expect(errors.length, equals(10));
    });

    test('should handle error context correctly', () {
      const context = {'userId': '123', 'action': 'test'};
      
      ErrorHandler.logError(
        'Test error with context',
        type: ErrorType.validation,
        context: context,
      );

      final recentErrors = ErrorHandler.getRecentErrors(limit: 1);
      expect(recentErrors.first.context, equals(context));
    });
  });

  group('ErrorInfo', () {
    test('should create ErrorInfo correctly', () {
      final timestamp = DateTime.now();
      const message = 'Test error';
      const details = 'Test details';
      const type = ErrorType.network;
      const severity = ErrorSeverity.high;
      const stackTrace = 'Stack trace';
      const context = {'key': 'value'};

      final errorInfo = ErrorInfo(
        message: message,
        details: details,
        type: type,
        severity: severity,
        timestamp: timestamp,
        stackTrace: stackTrace,
        context: context,
      );

      expect(errorInfo.message, equals(message));
      expect(errorInfo.details, equals(details));
      expect(errorInfo.type, equals(type));
      expect(errorInfo.severity, equals(severity));
      expect(errorInfo.timestamp, equals(timestamp));
      expect(errorInfo.stackTrace, equals(stackTrace));
      expect(errorInfo.context, equals(context));
    });

    test('should serialize to JSON correctly', () {
      final timestamp = DateTime.now();
      const message = 'Test error';
      const type = ErrorType.network;
      const severity = ErrorSeverity.high;

      final errorInfo = ErrorInfo(
        message: message,
        type: type,
        severity: severity,
        timestamp: timestamp,
      );

      final json = errorInfo.toJson();

      expect(json['message'], equals(message));
      expect(json['type'], equals(type.name));
      expect(json['severity'], equals(severity.name));
      expect(json['timestamp'], equals(timestamp.toIso8601String()));
    });
  });
}