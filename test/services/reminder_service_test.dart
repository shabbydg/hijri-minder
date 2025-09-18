import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/reminder_service.dart';
import 'package:hijri_minder/models/reminder.dart';
import 'package:hijri_minder/models/hijri_date.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ReminderService Tests', () {
    late ReminderService reminderService;

    setUp(() {
      reminderService = ReminderService();
    });

    test('should validate reminder data correctly', () {
      final validReminder = Reminder(
        id: 'valid',
        title: 'Valid Title',
        description: 'Valid description',
        hijriDate: HijriDate(1445, 6, 15),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.birthday,
        createdAt: DateTime.now(),
      );

      final validationError = reminderService.validateReminder(validReminder);
      expect(validationError, isNull);
    });

    test('should reject empty title', () {
      final invalidReminder = Reminder(
        id: 'invalid',
        title: '', // Empty title
        description: 'Invalid reminder',
        hijriDate: HijriDate(1445, 6, 15),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.birthday,
        createdAt: DateTime.now(),
      );

      final invalidError = reminderService.validateReminder(invalidReminder);
      expect(invalidError, equals('Title is required'));
    });

    test('should reject invalid Hijri year', () {
      final invalidReminder = Reminder(
        id: 'invalid_year',
        title: 'Valid Title',
        description: 'Invalid year',
        hijriDate: HijriDate(999, 6, 15), // Invalid year
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.birthday,
        createdAt: DateTime.now(),
      );

      final invalidError = reminderService.validateReminder(invalidReminder);
      expect(invalidError, equals('Invalid Hijri year'));
    });

    test('should reject invalid Hijri month', () {
      final invalidReminder = Reminder(
        id: 'invalid_month',
        title: 'Valid Title',
        description: 'Invalid month',
        hijriDate: HijriDate(1445, 15, 15), // Invalid month
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.birthday,
        createdAt: DateTime.now(),
      );

      final invalidError = reminderService.validateReminder(invalidReminder);
      expect(invalidError, equals('Invalid Hijri month'));
    });

    test('should generate unique reminder ID', () async {
      final id1 = reminderService.generateReminderId();
      
      // Wait a millisecond to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 1));
      
      final id2 = reminderService.generateReminderId();
      
      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
      expect(id1, startsWith('reminder_'));
      expect(id2, startsWith('reminder_'));
    });
  });
}