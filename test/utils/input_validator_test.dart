import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/utils/input_validator.dart';
import 'package:hijri_minder/models/reminder.dart';

void main() {
  group('InputValidator', () {
    group('validateReminderTitle', () {
      test('should accept valid titles', () {
        final result = InputValidator.validateReminderTitle('Valid Title');
        expect(result.isValid, isTrue);
      });

      test('should reject null or empty titles', () {
        expect(InputValidator.validateReminderTitle(null).isValid, isFalse);
        expect(InputValidator.validateReminderTitle('').isValid, isFalse);
        expect(InputValidator.validateReminderTitle('   ').isValid, isFalse);
      });

      test('should reject titles that are too short', () {
        final result = InputValidator.validateReminderTitle('A');
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('at least 2 characters'));
      });

      test('should reject titles that are too long', () {
        final longTitle = 'A' * 101;
        final result = InputValidator.validateReminderTitle(longTitle);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('less than 100 characters'));
      });

      test('should reject titles with invalid characters', () {
        final result = InputValidator.validateReminderTitle('Title<script>');
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('invalid characters'));
      });
    });

    group('validateHijriDate', () {
      test('should accept valid Hijri dates', () {
        final result = InputValidator.validateHijriDate(1445, 6, 15);
        expect(result.isValid, isTrue);
      });

      test('should reject null date components', () {
        expect(InputValidator.validateHijriDate(null, 6, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, null, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, 6, null).isValid, isFalse);
      });

      test('should reject invalid year range', () {
        expect(InputValidator.validateHijriDate(999, 6, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(3001, 6, 15).isValid, isFalse);
      });

      test('should reject invalid month range', () {
        expect(InputValidator.validateHijriDate(1445, -1, 15).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, 12, 15).isValid, isFalse);
      });

      test('should reject invalid day range', () {
        expect(InputValidator.validateHijriDate(1445, 6, 0).isValid, isFalse);
        expect(InputValidator.validateHijriDate(1445, 6, 31).isValid, isFalse);
      });
    });
  });
}