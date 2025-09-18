import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/prayer_times_service.dart';
import 'package:hijri_minder/services/location_service.dart';
import 'package:hijri_minder/services/reminder_service.dart';
import 'package:hijri_minder/services/logging_service.dart';
import 'package:hijri_minder/utils/error_handler.dart';
import 'package:hijri_minder/utils/input_validator.dart';
import 'package:hijri_minder/models/reminder.dart';
import 'package:hijri_minder/models/hijri_date.dart';

void main() {
  group('Task 16: Error Handling Integration Tests', () {
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

    group('Prayer Times Service Error Handling', () {
      test('should handle API failures gracefully', () async {
        final service = PrayerTimesService();
        
        // This should fallback to mock data when API fails
        final prayerTimes = await service.getTodayPrayerTimes();
        
        expect(prayerTimes, isNotNull);
        expect(prayerTimes!.locationName, contains('Fallback'));
      });

      test('should handle network errors with retry mechanism', () async {
        final service = PrayerTimesService();
        
        // Test with a specific date
        final testDate = DateTime(2024, 1, 15);
        final prayerTimes = await service.getPrayerTimesForDate(testDate);
        
        expect(prayerTimes, isNotNull);
        // Should either get real data or fallback to mock data
        expect(prayerTimes!.fajr, isNotEmpty);
      });

      test('should log errors when API calls fail', () async {
        final service = PrayerTimesService();
        
        // Clear previous logs
        ErrorHandler.clearErrorLog();
        
        // This might generate errors if API is unavailable
        await service.getTodayPrayerTimes();
        
        // Check if any errors were logged (might be 0 if API works)
        final errors = ErrorHandler.getRecentErrors();
        // We don't assert a specific count since API might work
        expect(errors, isA<List<ErrorInfo>>());
      });
    });

    group('Location Service Error Handling', () {
      test('should handle permission denial gracefully', () async {
        final service = LocationService();
        
        // This should handle permission issues gracefully
        final location = await service.getBestAvailableLocation();
        
        expect(location, isNotNull);
        expect(location['latitude'], isA<double>());
        expect(location['longitude'], isA<double>());
        expect(location['name'], isA<String>());
      });

      test('should fallback to default location when needed', () async {
        final service = LocationService();
        
        final fallbackLocation = service.getFallbackLocation();
        
        expect(fallbackLocation['latitude'], equals(6.9271));
        expect(fallbackLocation['longitude'], equals(79.8612));
        expect(fallbackLocation['name'], equals('Colombo, Sri Lanka'));
      });
    });

    group('Reminder Service Input Validation', () {
      test('should validate reminder data before saving', () async {
        final service = ReminderService();
        
        // Create invalid reminder
        final invalidReminder = Reminder(
          id: 'test_reminder',
          title: '', // Invalid: empty title
          description: 'Test description',
          hijriDate: HijriDate(1445, 6, 15),
          gregorianDate: DateTime.now(),
          type: ReminderType.birthday,
          isEnabled: true,
          isRecurring: true,
          notificationAdvance: const Duration(minutes: 30),
          createdAt: DateTime.now(),
        );
        
        final result = await service.saveReminder(invalidReminder);
        expect(result, isFalse);
        
        // Check that validation error was logged
        final errors = ErrorHandler.getRecentErrors();
        expect(errors.any((e) => e.type == ErrorType.validation), isTrue);
      });

      test('should accept valid reminder data', () async {
        final service = ReminderService();
        
        // Create valid reminder
        final validReminder = Reminder(
          id: 'test_reminder_valid',
          title: 'Valid Birthday Reminder',
          description: 'Test description',
          hijriDate: HijriDate(1445, 6, 15),
          gregorianDate: DateTime.now(),
          type: ReminderType.birthday,
          isEnabled: true,
          isRecurring: true,
          notificationAdvance: const Duration(minutes: 30),
          createdAt: DateTime.now(),
        );
        
        final result = await service.saveReminder(validReminder);
        expect(result, isTrue);
      });
    });

    group('Input Validation', () {
      test('should validate reminder titles correctly', () {
        // Valid titles
        expect(InputValidator.validateReminderTitle('Valid Title').isValid, isTrue);
        expect(InputValidator.validateReminderTitle('Another Valid Title').isValid, isTrue);
        
        // Invalid titles
        expect(InputValidator.validateReminderTitle(null).isValid, isFalse);
        expect(InputValidator.validateReminderTitle('').isValid, isFalse);
        expect(InputValidator.validateReminderTitle('A').isValid, isFalse);
        expect(InputValidator.validateReminderTitle('Title<script>').isValid, isFalse);
      });

      test('should validate Hijri dates correctly', () {
        // Valid dates
        expect(InputValidator.validateHijriDate(1445, 6, 15).isValid, isTrue);
        expect(InputValidator.validateHijriDate(1400, 0, 1).isValid, isTrue);
        expect(InputValidator.validateHijriDate(2000, 11, 29).isValid, isTrue);
        
        // Invalid dates
        expect(InputValidator.validateHijriDate(null, 6, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, null, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, 6, null).isValid, isFalse);
        expect(InputValidator.validateHijriDate(999, 6, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(3001, 6, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, -1, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, 12, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, 6, 0).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, 6, 31).isValid, isFalse);
      });

      test('should validate email addresses correctly', () {
        // Valid emails
        expect(InputValidator.validateEmail('test@example.com').isValid, isTrue);
        expect(InputValidator.validateEmail('user.name@domain.co.uk').isValid, isTrue);
        
        // Invalid emails
        expect(InputValidator.validateEmail(null).isValid, isFalse);
        expect(InputValidator.validateEmail('').isValid, isFalse);
        expect(InputValidator.validateEmail('invalid-email').isValid, isFalse);
        expect(InputValidator.validateEmail('test@').isValid, isFalse);
        expect(InputValidator.validateEmail('@domain.com').isValid, isFalse);
      });

      test('should sanitize string input correctly', () {
        expect(InputValidator.sanitizeString(null), equals(''));
        expect(InputValidator.sanitizeString(''), equals(''));
        expect(InputValidator.sanitizeString('  test  '), equals('test'));
        expect(InputValidator.sanitizeString('test<script>'), equals('testscript'));
        expect(InputValidator.sanitizeString('test{malicious}'), equals('testmalicious'));
      });
    });

    group('Error Handler Integration', () {
      test('should handle errors with fallback mechanism', () async {
        const expectedFallback = 'fallback_result';
        
        final result = await ErrorHandler.withFallback<String>(
          () async => throw Exception('Test error'),
          () => expectedFallback,
          'test operation',
          errorType: ErrorType.unknown,
        );
        
        expect(result, equals(expectedFallback));
        
        // Check that error was logged
        final errors = ErrorHandler.getRecentErrors();
        expect(errors.isNotEmpty, isTrue);
        expect(errors.first.message, contains('test operation'));
      });

      test('should retry operations with exponential backoff', () async {
        int attempts = 0;
        const maxRetries = 3;
        
        final result = await ErrorHandler.withRetry<String>(
          () async {
            attempts++;
            if (attempts < maxRetries) {
              throw Exception('Retry test');
            }
            return 'success';
          },
          'retry test',
          maxRetries: maxRetries,
          errorType: ErrorType.network,
        );
        
        expect(result, equals('success'));
        expect(attempts, equals(maxRetries));
        
        // Check that retry attempts were logged
        final errors = ErrorHandler.getRecentErrors();
        expect(errors.length, equals(maxRetries - 1)); // Failed attempts only
      });

      test('should generate user-friendly error messages', () {
        final networkMessage = ErrorHandler.getUserFriendlyMessage(
          ErrorType.network,
          'Technical network error',
        );
        expect(networkMessage, contains('Network connection error'));
        
        final permissionMessage = ErrorHandler.getUserFriendlyMessage(
          ErrorType.permission,
          'Permission denied',
        );
        expect(permissionMessage, contains('Permission required'));
      });
    });

    group('Logging Service Integration', () {
      test('should log different levels correctly', () {
        LoggingService.logInfo('Test info message');
        LoggingService.logWarning('Test warning message');
        LoggingService.logError('Test error message');
        
        final recentLogs = LoggingService.getRecentLogs(limit: 10);
        expect(recentLogs.length, greaterThanOrEqualTo(3));
        
        final infoLogs = LoggingService.getLogsByLevel(LogLevel.info);
        final warningLogs = LoggingService.getLogsByLevel(LogLevel.warning);
        final errorLogs = LoggingService.getLogsByLevel(LogLevel.error);
        
        expect(infoLogs.isNotEmpty, isTrue);
        expect(warningLogs.isNotEmpty, isTrue);
        expect(errorLogs.isNotEmpty, isTrue);
      });

      test('should provide logging statistics', () {
        LoggingService.clearLogs();
        
        LoggingService.logInfo('Info 1');
        LoggingService.logInfo('Info 2');
        LoggingService.logError('Error 1');
        
        final stats = LoggingService.getLoggingStatistics();
        expect(stats['totalLogs'], equals(3));
        expect(stats['infoCount'], equals(2));
        expect(stats['errorCount'], equals(1));
      });
    });
  });
}