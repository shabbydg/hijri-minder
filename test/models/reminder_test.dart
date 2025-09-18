import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/reminder.dart';
import 'package:hijri_minder/models/hijri_date.dart';

void main() {
  group('Reminder Model Tests', () {
    late Reminder testReminder;
    late HijriDate testHijriDate;
    late DateTime testGregorianDate;

    setUp(() {
      testHijriDate = HijriDate(1445, 6, 15);
      testGregorianDate = DateTime(2024, 1, 15);
      
      testReminder = Reminder(
        id: 'reminder_001',
        title: 'Birthday Reminder',
        description: 'Remember to wish happy birthday',
        hijriDate: testHijriDate,
        gregorianDate: testGregorianDate,
        type: ReminderType.birthday,
        messageTemplates: [
          'Happy Birthday [NAME]!',
          'Wishing you a blessed birthday!',
        ],
        isRecurring: true,
        notificationAdvance: Duration(hours: 2),
        isEnabled: true,
        recipientName: 'Ahmed',
        relationship: 'Brother',
        customFields: {'phone': '+1234567890'},
        createdAt: DateTime(2024, 1, 1),
      );
    });

    test('should create Reminder with all required fields', () {
      expect(testReminder.id, 'reminder_001');
      expect(testReminder.title, 'Birthday Reminder');
      expect(testReminder.description, 'Remember to wish happy birthday');
      expect(testReminder.hijriDate, testHijriDate);
      expect(testReminder.gregorianDate, testGregorianDate);
      expect(testReminder.type, ReminderType.birthday);
      expect(testReminder.messageTemplates.length, 2);
      expect(testReminder.isRecurring, true);
      expect(testReminder.notificationAdvance, Duration(hours: 2));
      expect(testReminder.isEnabled, true);
      expect(testReminder.recipientName, 'Ahmed');
      expect(testReminder.relationship, 'Brother');
      expect(testReminder.customFields['phone'], '+1234567890');
      expect(testReminder.createdAt, DateTime(2024, 1, 1));
      expect(testReminder.lastNotified, isNull);
    });

    test('should serialize to JSON correctly', () {
      final json = testReminder.toJson();
      
      expect(json['id'], 'reminder_001');
      expect(json['title'], 'Birthday Reminder');
      expect(json['description'], 'Remember to wish happy birthday');
      expect(json['hijriYear'], 1445);
      expect(json['hijriMonth'], 6);
      expect(json['hijriDay'], 15);
      expect(json['gregorianDate'], '2024-01-15T00:00:00.000');
      expect(json['type'], 'birthday');
      expect(json['messageTemplates'], isA<List<String>>());
      expect(json['isRecurring'], true);
      expect(json['notificationAdvanceMinutes'], 120);
      expect(json['isEnabled'], true);
      expect(json['recipientName'], 'Ahmed');
      expect(json['relationship'], 'Brother');
      expect(json['customFields'], isA<Map<String, String>>());
      expect(json['createdAt'], '2024-01-01T00:00:00.000');
      expect(json['lastNotified'], isNull);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'reminder_002',
        'title': 'Anniversary Reminder',
        'description': 'Wedding anniversary',
        'hijriYear': 1445,
        'hijriMonth': 8,
        'hijriDay': 20,
        'gregorianDate': '2024-03-20T00:00:00.000',
        'type': 'anniversary',
        'messageTemplates': ['Happy Anniversary!'],
        'isRecurring': false,
        'notificationAdvanceMinutes': 60,
        'isEnabled': true,
        'recipientName': 'Fatima',
        'relationship': 'Wife',
        'customFields': {'email': 'fatima@example.com'},
        'createdAt': '2024-01-01T00:00:00.000',
        'lastNotified': '2024-03-20T10:00:00.000',
      };

      final reminder = Reminder.fromJson(json);
      
      expect(reminder.id, 'reminder_002');
      expect(reminder.title, 'Anniversary Reminder');
      expect(reminder.description, 'Wedding anniversary');
      expect(reminder.hijriDate.year, 1445);
      expect(reminder.hijriDate.month, 8);
      expect(reminder.hijriDate.day, 20);
      expect(reminder.gregorianDate, DateTime(2024, 3, 20));
      expect(reminder.type, ReminderType.anniversary);
      expect(reminder.messageTemplates, ['Happy Anniversary!']);
      expect(reminder.isRecurring, false);
      expect(reminder.notificationAdvance, Duration(minutes: 60));
      expect(reminder.isEnabled, true);
      expect(reminder.recipientName, 'Fatima');
      expect(reminder.relationship, 'Wife');
      expect(reminder.customFields['email'], 'fatima@example.com');
      expect(reminder.createdAt, DateTime(2024, 1, 1));
      expect(reminder.lastNotified, DateTime(2024, 3, 20, 10, 0));
    });

    test('should get type display name correctly', () {
      expect(testReminder.getTypeDisplayName(), 'Birthday');
      
      final anniversaryReminder = testReminder.copyWith(type: ReminderType.anniversary);
      expect(anniversaryReminder.getTypeDisplayName(), 'Anniversary');
      
      final religiousReminder = testReminder.copyWith(type: ReminderType.religious);
      expect(religiousReminder.getTypeDisplayName(), 'Religious');
      
      final personalReminder = testReminder.copyWith(type: ReminderType.personal);
      expect(personalReminder.getTypeDisplayName(), 'Personal');
      
      final familyReminder = testReminder.copyWith(type: ReminderType.family);
      expect(familyReminder.getTypeDisplayName(), 'Family');
      
      final otherReminder = testReminder.copyWith(type: ReminderType.other);
      expect(otherReminder.getTypeDisplayName(), 'Other');
    });

    test('should get default message templates correctly', () {
      final birthdayTemplates = Reminder.getDefaultMessageTemplates(ReminderType.birthday, 'en');
      expect(birthdayTemplates.isNotEmpty, true);
      expect(birthdayTemplates.first, contains('[NAME]'));
      
      final anniversaryTemplates = Reminder.getDefaultMessageTemplates(ReminderType.anniversary, 'en');
      expect(anniversaryTemplates.isNotEmpty, true);
      
      final religiousTemplates = Reminder.getDefaultMessageTemplates(ReminderType.religious, 'en');
      expect(religiousTemplates.isNotEmpty, true);
      
      final arabicBirthdayTemplates = Reminder.getDefaultMessageTemplates(ReminderType.birthday, 'ar');
      expect(arabicBirthdayTemplates.isNotEmpty, true);
      expect(arabicBirthdayTemplates.first, contains('[NAME]'));
      
      final urduBirthdayTemplates = Reminder.getDefaultMessageTemplates(ReminderType.birthday, 'ur');
      expect(urduBirthdayTemplates.isNotEmpty, true);
    });

    test('should get personalized message correctly', () {
      final template = 'Happy Birthday [NAME]! Hope you have a great day, my dear [RELATIONSHIP].';
      final personalizedMessage = testReminder.getPersonalizedMessage(template);
      
      expect(personalizedMessage, contains('Ahmed'));
      expect(personalizedMessage, contains('Brother'));
      expect(personalizedMessage, isNot(contains('[NAME]')));
      expect(personalizedMessage, isNot(contains('[RELATIONSHIP]')));
    });

    test('should replace date placeholders in personalized message', () {
      final template = 'Today is [HIJRI_DATE] ([GREGORIAN_DATE])';
      final personalizedMessage = testReminder.getPersonalizedMessage(template);
      
      expect(personalizedMessage, contains('15'));
      expect(personalizedMessage, contains('1445'));
      expect(personalizedMessage, contains('15/1/2024'));
      expect(personalizedMessage, isNot(contains('[HIJRI_DATE]')));
      expect(personalizedMessage, isNot(contains('[GREGORIAN_DATE]')));
    });

    test('should check if reminder should trigger on date correctly', () {
      // Enabled recurring reminder
      expect(testReminder.shouldTriggerOnDate(DateTime(2024, 1, 15)), true);
      expect(testReminder.shouldTriggerOnDate(DateTime(2025, 1, 15)), true); // Next year
      expect(testReminder.shouldTriggerOnDate(DateTime(2024, 1, 16)), false); // Different day
      expect(testReminder.shouldTriggerOnDate(DateTime(2024, 2, 15)), false); // Different month
      
      // Disabled reminder
      final disabledReminder = testReminder.copyWith(isEnabled: false);
      expect(disabledReminder.shouldTriggerOnDate(DateTime(2024, 1, 15)), false);
      
      // Non-recurring reminder
      final nonRecurringReminder = testReminder.copyWith(isRecurring: false);
      expect(nonRecurringReminder.shouldTriggerOnDate(DateTime(2024, 1, 15)), true);
      expect(nonRecurringReminder.shouldTriggerOnDate(DateTime(2025, 1, 15)), false); // Different year
    });

    test('should get next occurrence correctly for recurring reminder', () {
      final currentYear = DateTime.now().year;
      final nextOccurrence = testReminder.getNextOccurrence();
      
      expect(nextOccurrence.month, 1);
      expect(nextOccurrence.day, 15);
      expect(nextOccurrence.year >= currentYear, true);
    });

    test('should get next occurrence correctly for non-recurring reminder', () {
      final futureDate = DateTime(2025, 6, 10);
      final nonRecurringReminder = testReminder.copyWith(
        isRecurring: false,
        gregorianDate: futureDate,
      );
      
      final nextOccurrence = nonRecurringReminder.getNextOccurrence();
      expect(nextOccurrence, futureDate);
    });

    test('should calculate years since correctly', () {
      final pastDate = DateTime(2020, 1, 15);
      final pastReminder = testReminder.copyWith(gregorianDate: pastDate);
      
      final yearsSince = pastReminder.calculateYearsSince();
      expect(yearsSince >= 4, true); // At least 4 years since 2020
    });

    test('should create copy with updated fields correctly', () {
      final updatedReminder = testReminder.copyWith(
        title: 'Updated Birthday Reminder',
        isEnabled: false,
        recipientName: 'Ali',
        notificationAdvance: Duration(hours: 1),
      );
      
      expect(updatedReminder.title, 'Updated Birthday Reminder');
      expect(updatedReminder.isEnabled, false);
      expect(updatedReminder.recipientName, 'Ali');
      expect(updatedReminder.notificationAdvance, Duration(hours: 1));
      
      // Other fields should remain the same
      expect(updatedReminder.id, testReminder.id);
      expect(updatedReminder.description, testReminder.description);
      expect(updatedReminder.hijriDate, testReminder.hijriDate);
      expect(updatedReminder.gregorianDate, testReminder.gregorianDate);
      expect(updatedReminder.type, testReminder.type);
    });

    test('should implement equality correctly', () {
      final reminder1 = Reminder(
        id: 'test_reminder',
        title: 'Test Reminder',
        description: 'Test Description',
        hijriDate: HijriDate(1445, 1, 1),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.birthday,
        createdAt: DateTime(2024, 1, 1),
      );

      final reminder2 = Reminder(
        id: 'test_reminder',
        title: 'Test Reminder',
        description: 'Test Description',
        hijriDate: HijriDate(1445, 1, 1),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.birthday,
        createdAt: DateTime(2024, 1, 1),
      );

      final reminder3 = Reminder(
        id: 'different_reminder',
        title: 'Test Reminder',
        description: 'Test Description',
        hijriDate: HijriDate(1445, 1, 1),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.birthday,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(reminder1, equals(reminder2));
      expect(reminder1, isNot(equals(reminder3)));
      expect(reminder1.hashCode, equals(reminder2.hashCode));
    });

    test('should have proper toString representation', () {
      final string = testReminder.toString();
      expect(string, contains('Reminder'));
      expect(string, contains('reminder_001'));
      expect(string, contains('Birthday Reminder'));
      expect(string, contains('birthday'));
      expect(string, contains('15/6/1445'));
    });
  });
}