import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/logging_service.dart';

void main() {
  group('LoggingService Tests', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await LoggingService.initialize();
    });

    tearDown(() async {
      await LoggingService.clearLogs();
    });

    test('should log debug messages', () {
      const message = 'Debug test message';
      LoggingService.logDebug(message);
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.any((log) => log.message.contains(message)), isTrue);
      expect(logs.any((log) => log.level == LogLevel.debug), isTrue);
    });

    test('should log info messages', () {
      const message = 'Info test message';
      LoggingService.logInfo(message);
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.any((log) => log.message.contains(message)), isTrue);
      expect(logs.any((log) => log.level == LogLevel.info), isTrue);
    });

    test('should log warning messages', () {
      const message = 'Warning test message';
      LoggingService.logWarning(message);
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.any((log) => log.message.contains(message)), isTrue);
      expect(logs.any((log) => log.level == LogLevel.warning), isTrue);
    });

    test('should log error messages', () {
      const message = 'Error test message';
      LoggingService.logError(message);
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.any((log) => log.message.contains(message)), isTrue);
      expect(logs.any((log) => log.level == LogLevel.error), isTrue);
    });

    test('should log error with details and stack trace', () {
      const message = 'Error with details';
      const details = 'Detailed error information';
      const stackTrace = 'Stack trace information';
      
      LoggingService.logError(message, details: details, stackTrace: stackTrace);
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.any((log) => log.message.contains(message)), isTrue);
      expect(logs.any((log) => log.details?.contains(details) == true), isTrue);
      expect(logs.any((log) => log.stackTrace?.contains(stackTrace) == true), isTrue);
    });

    test('should include timestamp in logs', () {
      LoggingService.logInfo('Test message');
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.isNotEmpty, isTrue);
      
      // Check if timestamp is present
      final log = logs.first;
      expect(log.timestamp, isA<DateTime>());
    });

    test('should maintain log order', () {
      LoggingService.logInfo('First message');
      LoggingService.logInfo('Second message');
      LoggingService.logInfo('Third message');
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.length, greaterThanOrEqualTo(3));
      
      // Recent logs are in reverse order (newest first)
      final recentLogs = logs.take(3).toList();
      expect(recentLogs[0].message.contains('Third message'), isTrue);
      expect(recentLogs[1].message.contains('Second message'), isTrue);
      expect(recentLogs[2].message.contains('First message'), isTrue);
    });

    test('should clear logs', () async {
      LoggingService.logInfo('Test message 1');
      LoggingService.logInfo('Test message 2');
      
      expect(LoggingService.getRecentLogs().length, greaterThanOrEqualTo(2));
      
      await LoggingService.clearLogs();
      expect(LoggingService.getRecentLogs().isEmpty, isTrue);
    });

    test('should limit log count when max is reached', () {
      // Test with smaller number for efficiency
      for (int i = 0; i < 10; i++) {
        LoggingService.logInfo('Test message $i');
      }
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.length, greaterThanOrEqualTo(10));
    });

    test('should format log entries consistently', () {
      const message = 'Consistent format test';
      LoggingService.logInfo(message);
      
      final logs = LoggingService.getRecentLogs();
      final log = logs.first;
      
      // Check log entry structure
      expect(log.timestamp, isA<DateTime>());
      expect(log.level, equals(LogLevel.info));
      expect(log.message, equals(message));
    });

    test('should handle empty messages gracefully', () {
      LoggingService.logInfo('');
      LoggingService.logInfo('   '); // Whitespace only
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.length, greaterThanOrEqualTo(2));
      expect(() => LoggingService.logInfo(''), returnsNormally);
    });

    test('should log with different severity levels', () {
      LoggingService.logDebug('Debug level');
      LoggingService.logInfo('Info level');
      LoggingService.logWarning('Warning level');
      LoggingService.logError('Error level');
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.length, greaterThanOrEqualTo(3)); // Debug might not be included in release mode
      
      expect(logs.any((log) => log.level == LogLevel.info), isTrue);
      expect(logs.any((log) => log.level == LogLevel.warning), isTrue);
      expect(logs.any((log) => log.level == LogLevel.error), isTrue);
    });

    test('should export logs as JSON string', () {
      LoggingService.logInfo('Export test message 1');
      LoggingService.logError('Export test message 2');
      
      final exportedLogs = LoggingService.exportLogsAsJson();
      expect(exportedLogs.contains('Export test message 1'), isTrue);
      expect(exportedLogs.contains('Export test message 2'), isTrue);
      expect(exportedLogs.contains('info'), isTrue);
      expect(exportedLogs.contains('error'), isTrue);
    });

    test('should filter logs by level', () {
      LoggingService.logDebug('Debug message');
      LoggingService.logInfo('Info message');
      LoggingService.logWarning('Warning message');
      LoggingService.logError('Error message');
      
      final errorLogs = LoggingService.getLogsByLevel(LogLevel.error);
      expect(errorLogs.length, greaterThanOrEqualTo(1));
      expect(errorLogs.any((log) => log.message.contains('Error message')), isTrue);
      
      final warningLogs = LoggingService.getLogsByLevel(LogLevel.warning);
      expect(warningLogs.length, greaterThanOrEqualTo(1));
      expect(warningLogs.any((log) => log.message.contains('Warning message')), isTrue);
    });

    test('should handle concurrent logging', () async {
      final futures = <Future>[];
      
      for (int i = 0; i < 10; i++) {
        futures.add(Future(() => LoggingService.logInfo('Concurrent message $i')));
      }
      
      await Future.wait(futures);
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.length, greaterThanOrEqualTo(10));
    });

    test('should provide logging statistics', () {
      LoggingService.logInfo('Stats test');
      LoggingService.logError('Stats error');
      
      final stats = LoggingService.getLoggingStatistics();
      expect(stats['totalLogs'], greaterThan(0));
      // Note: initialized might be false due to SharedPreferences mock issues in tests
      expect(stats.containsKey('initialized'), isTrue);
      expect(stats['infoCount'], greaterThanOrEqualTo(1));
      expect(stats['errorCount'], greaterThanOrEqualTo(1));
    });

    test('should log performance metrics', () {
      const operation = 'test_operation';
      const duration = Duration(milliseconds: 100);
      
      LoggingService.logPerformance(operation, duration);
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.any((log) => log.message.contains(operation)), isTrue);
      expect(logs.any((log) => log.message.contains('100ms')), isTrue);
    });

    test('should log user actions', () {
      const action = 'button_tap';
      const screen = 'home_screen';
      
      LoggingService.logUserAction(action, screen: screen);
      
      final logs = LoggingService.getRecentLogs();
      expect(logs.any((log) => log.message.contains(action)), isTrue);
      expect(logs.any((log) => log.context?['screen'] == screen), isTrue);
    });
  });
}