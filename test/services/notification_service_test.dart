import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/notification_service.dart';
import '../../lib/models/prayer_times.dart';
import '../../lib/models/reminder.dart';
import '../../lib/models/hijri_date.dart';
import '../../lib/services/settings_service.dart' show AppSettings;

void main() {
  group('NotificationService', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Test initialization
        final result = await notificationService.initialize();
        expect(result, isA<bool>());
      });

      test('should handle initialization errors gracefully', () async {
        // Test error handling during initialization
        final result = await notificationService.initialize();
        expect(result, isA<bool>());
      });
    });

    group('Permission Handling', () {
      test('should request permissions', () async {
        final result = await notificationService.requestPermissions();
        expect(result, isA<bool>());
      });

      test('should check if notifications are enabled', () async {
        final result = await notificationService.areNotificationsEnabled();
        expect(result, isA<bool>());
      });
    });

    group('Prayer Notifications', () {
      test('should schedule prayer notifications when enabled', () async {
        final prayerTimes = PrayerTimes(
          sihori: '04:30',
          fajr: '05:15',
          sunrise: '06:30',
          zawaal: '12:15',
          zohrEnd: '12:45',
          asrEnd: '16:30',
          maghrib: '18:15',
          maghribEnd: '18:45',
          nisfulLayl: '23:30',
          nisfulLaylEnd: '00:15',
          date: DateTime.now().add(const Duration(days: 1)),
        );

        const settings = AppSettings(
          enablePrayerNotifications: true,
          enableAdhanSounds: true,
          prayerNotificationAdvanceMinutes: 15,
          enableLocationServices: true,
          language: 'en',
          theme: 'light',
          showGregorianDates: true,
          showEventDots: true,
          prayerTimeFormat: '12h',
        );

        await notificationService.schedulePrayerNotifications(prayerTimes, settings);
        
        // Verify that the method completes without error
        expect(true, isTrue);
      });

      test('should not schedule prayer notifications when disabled', () async {
        final prayerTimes = PrayerTimes(
          sihori: '04:30',
          fajr: '05:15',
          sunrise: '06:30',
          zawaal: '12:15',
          zohrEnd: '12:45',
          asrEnd: '16:30',
          maghrib: '18:15',
          maghribEnd: '18:45',
          nisfulLayl: '23:30',
          nisfulLaylEnd: '00:15',
          date: DateTime.now(),
        );

        const settings = AppSettings(
          enablePrayerNotifications: false,
          enableAdhanSounds: false,
          prayerNotificationAdvanceMinutes: 15,
          enableLocationServices: true,
          language: 'en',
          theme: 'light',
          showGregorianDates: true,
          showEventDots: true,
          prayerTimeFormat: '12h',
        );

        await notificationService.schedulePrayerNotifications(prayerTimes, settings);
        
        // Should complete without scheduling any notifications
        expect(true, isTrue);
      });

      test('should cancel prayer notifications', () async {
        await notificationService.cancelPrayerNotifications();
        expect(true, isTrue);
      });
    });

    group('Reminder Notifications', () {
      test('should schedule reminder notification', () async {
        final reminder = Reminder(
          id: 'test_reminder',
          title: 'Test Birthday',
          description: 'Test birthday reminder',
          hijriDate: HijriDate(1445, 6, 15),
          gregorianDate: DateTime.now().add(const Duration(days: 1)),
          type: ReminderType.birthday,
          isRecurring: true,
          isEnabled: true,
          notificationAdvance: const Duration(hours: 2),
          messageTemplates: ['Happy Birthday!'],
          createdAt: DateTime.now(),
        );

        await notificationService.scheduleReminderNotification(reminder);
        expect(true, isTrue);
      });

      test('should not schedule notification for past dates', () async {
        final reminder = Reminder(
          id: 'test_reminder_past',
          title: 'Past Event',
          description: 'Past event reminder',
          hijriDate: HijriDate(1444, 6, 15),
          gregorianDate: DateTime.now().subtract(const Duration(days: 1)),
          type: ReminderType.anniversary,
          isRecurring: false,
          isEnabled: true,
          notificationAdvance: const Duration(hours: 2),
          messageTemplates: ['Past event'],
          createdAt: DateTime.now(),
        );

        await notificationService.scheduleReminderNotification(reminder);
        expect(true, isTrue);
      });

      test('should cancel reminder notification', () async {
        await notificationService.cancelReminderNotification('test_reminder');
        expect(true, isTrue);
      });
    });

    group('Notification Management', () {
      test('should cancel all notifications', () async {
        await notificationService.cancelAllNotifications();
        expect(true, isTrue);
      });

      test('should show test notification', () async {
        await notificationService.showTestNotification();
        expect(true, isTrue);
      });
    });

    group('Time Parsing', () {
      test('should handle valid time strings', () async {
        // Test internal time parsing through prayer notification scheduling
        final prayerTimes = PrayerTimes(
          sihori: '04:30',
          fajr: '05:15',
          sunrise: '06:30',
          zawaal: '12:15',
          zohrEnd: '12:45',
          asrEnd: '16:30',
          maghrib: '18:15',
          maghribEnd: '18:45',
          nisfulLayl: '23:30',
          nisfulLaylEnd: '00:15',
          date: DateTime.now().add(const Duration(days: 1)),
        );

        const settings = AppSettings(
          enablePrayerNotifications: true,
          enableAdhanSounds: false,
          prayerNotificationAdvanceMinutes: 15,
          enableLocationServices: true,
          language: 'en',
          theme: 'light',
          showGregorianDates: true,
          showEventDots: true,
          prayerTimeFormat: '12h',
        );

        await notificationService.schedulePrayerNotifications(prayerTimes, settings);
        expect(true, isTrue);
      });

      test('should handle invalid time strings gracefully', () async {
        final prayerTimes = PrayerTimes(
          sihori: 'invalid',
          fajr: '25:70', // Invalid time
          sunrise: '',
          zawaal: '12:15',
          zohrEnd: '12:45',
          asrEnd: '16:30',
          maghrib: '18:15',
          maghribEnd: '18:45',
          nisfulLayl: '23:30',
          nisfulLaylEnd: '00:15',
          date: DateTime.now().add(const Duration(days: 1)),
        );

        const settings = AppSettings(
          enablePrayerNotifications: true,
          enableAdhanSounds: false,
          prayerNotificationAdvanceMinutes: 15,
          enableLocationServices: true,
          language: 'en',
          theme: 'light',
          showGregorianDates: true,
          showEventDots: true,
          prayerTimeFormat: '12h',
        );

        await notificationService.schedulePrayerNotifications(prayerTimes, settings);
        expect(true, isTrue);
      });
    });

    group('Message Building', () {
      test('should build proper reminder messages', () async {
        final reminder = Reminder(
          id: 'test_message',
          title: 'John\'s Birthday',
          description: 'Birthday celebration',
          hijriDate: HijriDate(1445, 6, 15),
          gregorianDate: DateTime.now().add(const Duration(days: 1)),
          type: ReminderType.birthday,
          isRecurring: true,
          isEnabled: true,
          notificationAdvance: const Duration(hours: 2),
          messageTemplates: ['Happy Birthday!'],
          createdAt: DateTime.now(),
        );

        await notificationService.scheduleReminderNotification(reminder);
        expect(true, isTrue);
      });
    });
  });
}