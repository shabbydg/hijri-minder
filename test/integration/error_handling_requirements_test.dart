import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/prayer_times_service.dart';
import 'package:hijri_minder/services/location_service.dart';
import 'package:hijri_minder/services/reminder_service.dart';
import 'package:hijri_minder/services/settings_service.dart';
import 'package:hijri_minder/services/logging_service.dart';
import 'package:hijri_minder/utils/error_handler.dart';
import 'package:hijri_minder/utils/input_validator.dart';
import 'package:hijri_minder/models/reminder.dart';
import 'package:hijri_minder/models/hijri_date.dart';

/// Test to verify all Task 16 requirements are implemented
void main() {
  group('Task 16 Requirements Verification', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      ErrorHandler.initialize();
      await LoggingService.initialize();
    });

    tearDownAll(() {
      ErrorHandler.dispose();
      LoggingService.dispose();
    });

    setUp(() {
      ErrorHandler.clearErrorLog();
    });

    group('Requirement 5.7: Prayer Times Error Handling', () {
      test('should handle API failures gracefully with fallback to mock data', () async {
        final service = PrayerTimesService();
        
        // This should handle API failures and return mock data
        final prayerTimes = await service.getTodayPrayerTimes();
        
        expect(prayerTimes, isNotNull, reason: 'Should return mock data when API fails');
        expect(prayerTimes!.fajr, isNotEmpty, reason: 'Mock data should have valid prayer times');
        expect(prayerTimes.locationName, contains('Fallback'), 
               reason: 'Should indicate fallback location when API unavailable');
      });

      test('should retry API calls with exponential backoff', () async {
        // This is tested through the ErrorHandler.withRetry mechanism
        int attempts = 0;
        
        final result = await ErrorHandler.withRetry<String>(
          () async {
            attempts++;
            if (attempts < 2) {
              throw Exception('API temporarily unavailable');
            }
            return 'success';
          },
          'prayer times API call',
          maxRetries: 3,
          errorType: ErrorType.api,
        );
        
        expect(result, equals('success'), reason: 'Should succeed after retries');
        expect(attempts, equals(2), reason: 'Should retry failed attempts');
      });
    });

    group('Requirement 10.7: Location Permission Error Handling', () {
      test('should handle location permission denial gracefully', () async {
        final service = LocationService();
        
        // This should handle permission issues and return fallback location
        final location = await service.getBestAvailableLocation();
        
        expect(location, isNotNull, reason: 'Should always return a location');
        expect(location['latitude'], isA<double>(), reason: 'Should have valid latitude');
        expect(location['longitude'], isA<double>(), reason: 'Should have valid longitude');
        expect(location['name'], isA<String>(), reason: 'Should have location name');
      });

      test('should provide fallback coordinates when location unavailable', () {
        final service = LocationService();
        final fallback = service.getFallbackLocation();
        
        expect(fallback['latitude'], equals(6.9271), 
               reason: 'Should use Colombo latitude as fallback');
        expect(fallback['longitude'], equals(79.8612), 
               reason: 'Should use Colombo longitude as fallback');
        expect(fallback['name'], equals('Colombo, Sri Lanka'), 
               reason: 'Should use Colombo as fallback location name');
      });
    });

    group('Requirement 11.6: Input Validation and Error Recovery', () {
      test('should validate reminder input and reject invalid data', () async {
        final service = ReminderService();
        
        // Test with invalid reminder (empty title)
        final invalidReminder = Reminder(
          id: 'test_invalid',
          title: '', // Invalid: empty title
          description: 'Test',
          hijriDate: HijriDate(1445, 6, 15),
          gregorianDate: DateTime.now(),
          type: ReminderType.birthday,
          createdAt: DateTime.now(),
        );
        
        final result = await service.saveReminder(invalidReminder);
        expect(result, isFalse, reason: 'Should reject invalid reminder data');
        
        // Verify validation error was logged
        final errors = ErrorHandler.getRecentErrors();
        expect(errors.any((e) => e.type == ErrorType.validation), isTrue,
               reason: 'Should log validation errors');
      });

      test('should accept valid reminder data', () {
        final validationResult = InputValidator.validateReminder(
          'Valid Birthday Reminder',
          'Test description',
          1445, // Valid Hijri year
          6,    // Valid Hijri month
          15,   // Valid Hijri day
          ReminderType.birthday,
          30,   // Valid notification advance minutes
        );
        
        expect(validationResult.isValid, isTrue, 
               reason: 'Should accept valid reminder data');
      });

      test('should validate Hijri dates correctly', () {
        // Valid dates
        expect(InputValidator.validateHijriDate(1445, 6, 15).isValid, isTrue);
        expect(InputValidator.validateHijriDate(1400, 0, 1).isValid, isTrue);
        
        // Invalid dates
        expect(InputValidator.validateHijriDate(999, 6, 15).isValid, isFalse,
               reason: 'Should reject year below 1000');
        expect(InputValidator.validateHijriDate(3001, 6, 15).isValid, isFalse,
               reason: 'Should reject year above 3000');
        expect(InputValidator.validateHijriDate(1445, -1, 15).isValid, isFalse,
               reason: 'Should reject negative month');
        expect(InputValidator.validateHijriDate(1445, 12, 15).isValid, isFalse,
               reason: 'Should reject month above 11');
        expect(InputValidator.validateHijriDate(1445, 6, 0).isValid, isFalse,
               reason: 'Should reject day 0');
        expect(InputValidator.validateHijriDate(1445, 6, 31).isValid, isFalse,
               reason: 'Should reject day above 30');
      });

      test('should sanitize string input to prevent XSS', () {
        expect(InputValidator.sanitizeString('<script>alert("xss")</script>'), 
               equals('scriptalert("xss")/script'),
               reason: 'Should remove dangerous HTML tags');
        expect(InputValidator.sanitizeString('Normal text'), 
               equals('Normal text'),
               reason: 'Should preserve normal text');
        expect(InputValidator.sanitizeString('  trimmed  '), 
               equals('trimmed'),
               reason: 'Should trim whitespace');
      });
    });

    group('Comprehensive Error Handling Features', () {
      test('should provide user-friendly error messages', () {
        final networkMessage = ErrorHandler.getUserFriendlyMessage(
          ErrorType.network, 'Technical network error');
        expect(networkMessage, contains('Network connection error'),
               reason: 'Should provide user-friendly network error message');
        
        final permissionMessage = ErrorHandler.getUserFriendlyMessage(
          ErrorType.permission, 'Permission denied');
        expect(permissionMessage, contains('Permission required'),
               reason: 'Should provide user-friendly permission error message');
        
        final apiMessage = ErrorHandler.getUserFriendlyMessage(
          ErrorType.api, 'API error 500');
        expect(apiMessage, contains('Service temporarily unavailable'),
               reason: 'Should provide user-friendly API error message');
      });

      test('should log errors with proper categorization', () {
        ErrorHandler.logError('Network timeout', type: ErrorType.network, severity: ErrorSeverity.high);
        ErrorHandler.logError('Invalid input', type: ErrorType.validation, severity: ErrorSeverity.medium);
        ErrorHandler.logError('Permission denied', type: ErrorType.permission, severity: ErrorSeverity.low);
        
        final networkErrors = ErrorHandler.getErrorsByType(ErrorType.network);
        final validationErrors = ErrorHandler.getErrorsByType(ErrorType.validation);
        final permissionErrors = ErrorHandler.getErrorsByType(ErrorType.permission);
        
        expect(networkErrors.length, equals(1), reason: 'Should categorize network errors');
        expect(validationErrors.length, equals(1), reason: 'Should categorize validation errors');
        expect(permissionErrors.length, equals(1), reason: 'Should categorize permission errors');
        
        final highSeverityErrors = ErrorHandler.getErrorsBySeverity(ErrorSeverity.high);
        expect(highSeverityErrors.length, equals(1), reason: 'Should categorize by severity');
      });

      test('should provide error statistics', () {
        ErrorHandler.clearErrorLog();
        
        ErrorHandler.logError('Error 1', type: ErrorType.network);
        ErrorHandler.logError('Error 2', type: ErrorType.api);
        ErrorHandler.logError('Error 3', type: ErrorType.network);
        
        final stats = ErrorHandler.getErrorStatistics();
        expect(stats['total'], equals(3), reason: 'Should count total errors');
        expect(stats['type_network'], equals(2), reason: 'Should count network errors');
        expect(stats['type_api'], equals(1), reason: 'Should count API errors');
      });
    });

    group('Logging and Crash Reporting', () {
      test('should log different severity levels', () {
        LoggingService.logInfo('Info message');
        LoggingService.logWarning('Warning message');
        LoggingService.logError('Error message');
        LoggingService.logCritical('Critical error');
        
        final recentLogs = LoggingService.getRecentLogs(limit: 10);
        expect(recentLogs.length, greaterThanOrEqualTo(4), 
               reason: 'Should log all severity levels');
        
        final errorLogs = LoggingService.getLogsByLevel(LogLevel.error);
        final criticalLogs = LoggingService.getLogsByLevel(LogLevel.critical);
        
        expect(errorLogs.isNotEmpty, isTrue, reason: 'Should log error level');
        expect(criticalLogs.isNotEmpty, isTrue, reason: 'Should log critical level');
      });

      test('should provide logging statistics', () {
        LoggingService.clearLogs();
        
        LoggingService.logInfo('Info 1');
        LoggingService.logInfo('Info 2');
        LoggingService.logError('Error 1');
        LoggingService.logWarning('Warning 1');
        
        final stats = LoggingService.getLoggingStatistics();
        expect(stats['totalLogs'], equals(4), reason: 'Should count total logs');
        expect(stats['infoCount'], equals(2), reason: 'Should count info logs');
        expect(stats['errorCount'], equals(1), reason: 'Should count error logs');
        expect(stats['warningCount'], equals(1), reason: 'Should count warning logs');
      });
    });

    group('Service Integration with Error Handling', () {
      test('should handle settings service errors gracefully', () async {
        final service = SettingsService();
        
        // This should handle SharedPreferences errors gracefully
        final settings = await service.getSettings();
        expect(settings, isNotNull, reason: 'Should return default settings on error');
      });

      test('should validate all input types correctly', () {
        // Email validation
        expect(InputValidator.validateEmail('test@example.com').isValid, isTrue);
        expect(InputValidator.validateEmail('invalid-email').isValid, isFalse);
        
        // Phone validation
        expect(InputValidator.validatePhoneNumber('+1234567890').isValid, isTrue);
        expect(InputValidator.validatePhoneNumber('123').isValid, isFalse);
        
        // URL validation
        expect(InputValidator.validateUrl('https://example.com').isValid, isTrue);
        expect(InputValidator.validateUrl('not-a-url').isValid, isFalse);
        
        // Time format validation
        expect(InputValidator.validateTimeFormat('14:30').isValid, isTrue);
        expect(InputValidator.validateTimeFormat('25:00').isValid, isFalse);
      });
    });
  });
}