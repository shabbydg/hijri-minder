import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/model_validation.dart';

void main() {
  group('ModelValidation Tests', () {
    group('ValidationResult Tests', () {
      test('should create valid result correctly', () {
        final result = ValidationResult.valid();
        
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
        expect(result.warnings, isEmpty);
      });

      test('should create invalid result correctly', () {
        final errors = ['Error 1', 'Error 2'];
        final warnings = ['Warning 1'];
        final result = ValidationResult.invalid(errors, warnings);
        
        expect(result.isValid, false);
        expect(result.errors, equals(errors));
        expect(result.warnings, equals(warnings));
      });

      test('should create invalid result without warnings', () {
        final errors = ['Error 1', 'Error 2'];
        final result = ValidationResult.invalid(errors);
        
        expect(result.isValid, false);
        expect(result.errors, equals(errors));
        expect(result.warnings, isEmpty);
      });
    });

    group('PrayerTimes Validation Tests', () {
      test('should validate correct prayer times JSON', () {
        final json = {
          'sihori': '04:30',
          'fajr': '05:15',
          'sunrise': '06:45',
          'zawaal': '12:15',
          'zohrEnd': '16:30',
          'asrEnd': '17:45',
          'maghrib': '18:30',
          'maghribEnd': '19:45',
          'nisfulLayl': '23:30',
          'nisfulLaylEnd': '00:15',
          'date': '2024-01-15T00:00:00.000',
        };

        final result = ModelValidation.validatePrayerTimes(json);
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should detect missing required fields', () {
        final json = {
          'sihori': '04:30',
          'fajr': '05:15',
          // Missing other required fields
        };

        final result = ModelValidation.validatePrayerTimes(json);
        expect(result.isValid, false);
        expect(result.errors.length, greaterThan(0));
        expect(result.errors.any((e) => e.contains('Missing required field')), true);
      });

      test('should detect invalid time format', () {
        final json = {
          'sihori': '25:70', // Invalid time
          'fajr': '05:15',
          'sunrise': '06:45',
          'zawaal': '12:15',
          'zohrEnd': '16:30',
          'asrEnd': '17:45',
          'maghrib': '18:30',
          'maghribEnd': '19:45',
          'nisfulLayl': '23:30',
          'nisfulLaylEnd': '00:15',
          'date': '2024-01-15T00:00:00.000',
        };

        final result = ModelValidation.validatePrayerTimes(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid time format')), true);
      });

      test('should detect invalid date format', () {
        final json = {
          'sihori': '04:30',
          'fajr': '05:15',
          'sunrise': '06:45',
          'zawaal': '12:15',
          'zohrEnd': '16:30',
          'asrEnd': '17:45',
          'maghrib': '18:30',
          'maghribEnd': '19:45',
          'nisfulLayl': '23:30',
          'nisfulLaylEnd': '00:15',
          'date': 'invalid-date',
        };

        final result = ModelValidation.validatePrayerTimes(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid date format')), true);
      });
    });

    group('IslamicEvent Validation Tests', () {
      test('should validate correct Islamic event JSON', () {
        final json = {
          'id': 'eid_fitr_2024',
          'title': 'Eid al-Fitr',
          'description': 'Festival of Breaking the Fast',
          'category': 'eid',
          'hijriDay': 1,
          'hijriMonth': 9,
          'hijriYear': 1445,
          'isImportant': true,
        };

        final result = ModelValidation.validateIslamicEvent(json);
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should detect missing required fields', () {
        final json = {
          // Missing id and title
          'description': 'Test description',
          'category': 'eid',
        };

        final result = ModelValidation.validateIslamicEvent(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Missing or empty required field: id')), true);
        expect(result.errors.any((e) => e.contains('Missing or empty required field: title')), true);
      });

      test('should detect invalid category', () {
        final json = {
          'id': 'test_event',
          'title': 'Test Event',
          'category': 'invalid_category',
        };

        final result = ModelValidation.validateIslamicEvent(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid category')), true);
      });

      test('should detect invalid Hijri date values', () {
        final json = {
          'id': 'test_event',
          'title': 'Test Event',
          'hijriDay': 35, // Invalid day
          'hijriMonth': 15, // Invalid month
          'hijriYear': 500, // Invalid year
        };

        final result = ModelValidation.validateIslamicEvent(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid hijriDay')), true);
        expect(result.errors.any((e) => e.contains('Invalid hijriMonth')), true);
        expect(result.errors.any((e) => e.contains('Invalid hijriYear')), true);
      });
    });

    group('AppSettings Validation Tests', () {
      test('should validate correct app settings JSON', () {
        final json = {
          'language': 'en',
          'theme': 'light',
          'prayerTimeFormat': '24h',
          'fontSize': 16.0,
          'prayerNotificationAdvanceMinutes': 15,
        };

        final result = ModelValidation.validateAppSettings(json);
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should detect invalid language', () {
        final json = {
          'language': 'invalid_language',
        };

        final result = ModelValidation.validateAppSettings(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid language')), true);
      });

      test('should detect invalid theme', () {
        final json = {
          'theme': 'invalid_theme',
        };

        final result = ModelValidation.validateAppSettings(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid theme')), true);
      });

      test('should detect invalid prayer time format', () {
        final json = {
          'prayerTimeFormat': 'invalid_format',
        };

        final result = ModelValidation.validateAppSettings(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid prayerTimeFormat')), true);
      });

      test('should detect invalid font size', () {
        final json = {
          'fontSize': 5.0, // Too small
        };

        final result = ModelValidation.validateAppSettings(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid fontSize')), true);
      });

      test('should detect invalid notification advance time', () {
        final json = {
          'prayerNotificationAdvanceMinutes': 70, // Too large
        };

        final result = ModelValidation.validateAppSettings(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid prayerNotificationAdvanceMinutes')), true);
      });
    });

    group('Reminder Validation Tests', () {
      test('should validate correct reminder JSON', () {
        final json = {
          'id': 'reminder_001',
          'title': 'Birthday Reminder',
          'hijriYear': 1445,
          'hijriMonth': 6,
          'hijriDay': 15,
          'gregorianDate': '2024-01-15T00:00:00.000',
          'type': 'birthday',
          'createdAt': '2024-01-01T00:00:00.000',
        };

        final result = ModelValidation.validateReminder(json);
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should detect missing required fields', () {
        final json = {
          // Missing required fields
          'title': 'Test Reminder',
        };

        final result = ModelValidation.validateReminder(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Missing required field')), true);
      });

      test('should detect invalid reminder type', () {
        final json = {
          'id': 'reminder_001',
          'title': 'Test Reminder',
          'hijriYear': 1445,
          'hijriMonth': 6,
          'hijriDay': 15,
          'gregorianDate': '2024-01-15T00:00:00.000',
          'type': 'invalid_type',
          'createdAt': '2024-01-01T00:00:00.000',
        };

        final result = ModelValidation.validateReminder(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid reminder type')), true);
      });

      test('should detect invalid Hijri date values', () {
        final json = {
          'id': 'reminder_001',
          'title': 'Test Reminder',
          'hijriYear': 500, // Invalid year
          'hijriMonth': 15, // Invalid month
          'hijriDay': 35, // Invalid day
          'gregorianDate': '2024-01-15T00:00:00.000',
          'createdAt': '2024-01-01T00:00:00.000',
        };

        final result = ModelValidation.validateReminder(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid hijriYear')), true);
        expect(result.errors.any((e) => e.contains('Invalid hijriMonth')), true);
        expect(result.errors.any((e) => e.contains('Invalid hijriDay')), true);
      });

      test('should detect invalid date formats', () {
        final json = {
          'id': 'reminder_001',
          'title': 'Test Reminder',
          'hijriYear': 1445,
          'hijriMonth': 6,
          'hijriDay': 15,
          'gregorianDate': 'invalid-date',
          'createdAt': 'invalid-date',
          'lastNotified': 'invalid-date',
        };

        final result = ModelValidation.validateReminder(json);
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.contains('Invalid gregorianDate format')), true);
        expect(result.errors.any((e) => e.contains('Invalid createdAt format')), true);
        expect(result.errors.any((e) => e.contains('Invalid lastNotified format')), true);
      });
    });

    group('Utility Methods Tests', () {
      test('should sanitize string input correctly', () {
        expect(ModelValidation.sanitizeString('  Hello World!  '), 'Hello World!');
        expect(ModelValidation.sanitizeString('Test<script>alert()</script>'), 'Testscriptalert()script');
        expect(ModelValidation.sanitizeString(null), '');
        expect(ModelValidation.sanitizeString(''), '');
      });

      test('should validate ID correctly', () {
        expect(ModelValidation.validateId('valid_id_123'), 'valid_id_123');
        expect(ModelValidation.validateId('valid-id-123'), 'valid-id-123');
        expect(ModelValidation.validateId('  valid_id  '), 'valid_id');
        expect(ModelValidation.validateId('ab'), isNull); // Too short
        expect(ModelValidation.validateId('a' * 51), isNull); // Too long
        expect(ModelValidation.validateId('invalid@id'), isNull); // Invalid characters
        expect(ModelValidation.validateId(null), isNull);
        expect(ModelValidation.validateId(''), isNull);
      });

      test('should validate email correctly', () {
        expect(ModelValidation.isValidEmail('test@example.com'), true);
        expect(ModelValidation.isValidEmail('user.name+tag@domain.co.uk'), true);
        expect(ModelValidation.isValidEmail('invalid-email'), false);
        expect(ModelValidation.isValidEmail('test@'), false);
        expect(ModelValidation.isValidEmail('@example.com'), false);
        expect(ModelValidation.isValidEmail(''), false);
      });

      test('should validate phone number correctly', () {
        expect(ModelValidation.isValidPhoneNumber('+1234567890'), true);
        expect(ModelValidation.isValidPhoneNumber('(123) 456-7890'), true);
        expect(ModelValidation.isValidPhoneNumber('123-456-7890'), true);
        expect(ModelValidation.isValidPhoneNumber('1234567890'), true);
        expect(ModelValidation.isValidPhoneNumber('123456789'), false); // Too short
        expect(ModelValidation.isValidPhoneNumber('12345678901234567890'), false); // Too long
        expect(ModelValidation.isValidPhoneNumber('abc123'), false); // Invalid format
      });
    });

    group('ModelValidationException Tests', () {
      test('should create exception correctly', () {
        final errors = ['Error 1', 'Error 2'];
        final exception = ModelValidationException('Test message', errors);
        
        expect(exception.message, 'Test message');
        expect(exception.errors, equals(errors));
      });

      test('should have proper toString representation', () {
        final errors = ['Error 1', 'Error 2'];
        final exception = ModelValidationException('Test message', errors);
        final string = exception.toString();
        
        expect(string, contains('ModelValidationException'));
        expect(string, contains('Test message'));
        expect(string, contains('Error 1'));
        expect(string, contains('Error 2'));
      });
    });
  });
}