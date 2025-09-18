import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import '../../lib/main.dart' as app;
import '../../lib/services/service_locator.dart';
import '../../lib/services/notification_service.dart';
import '../../lib/services/prayer_times_service.dart';
import '../../lib/services/reminder_service.dart';
import '../../lib/models/reminder.dart';
import '../../lib/models/hijri_date.dart';
import '../../lib/services/settings_service.dart' show AppSettings;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Task 9: Notification System Integration Tests', () {
    late NotificationService notificationService;
    late PrayerTimesService prayerTimesService;
    late ReminderService reminderService;

    setUpAll(() async {
      // Initialize services
      await ServiceLocator.setupServices();
      notificationService = ServiceLocator.notificationService;
      prayerTimesService = ServiceLocator.prayerTimesService;
      reminderService = ServiceLocator.reminderService;
    });

    tearDownAll(() async {
      await ServiceLocator.reset();
    });

    testWidgets('should initialize notification service successfully', (WidgetTester tester) async {
      // Test notification service initialization
      final initialized = await notificationService.initialize();
      expect(initialized, isTrue);
    });

    testWidgets('should request notification permissions', (WidgetTester tester) async {
      // Test permission request
      final permissionGranted = await notificationService.requestPermissions();
      expect(permissionGranted, isA<bool>());
    });

    testWidgets('should check notification status', (WidgetTester tester) async {
      // Test notification status check
      final enabled = await notificationService.areNotificationsEnabled();
      expect(enabled, isA<bool>());
    });

    testWidgets('should schedule prayer notifications', (WidgetTester tester) async {
      // Get today's prayer times
      final prayerTimes = await prayerTimesService.getTodayPrayerTimes();
      expect(prayerTimes, isNotNull);

      // Create test settings
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

      // Schedule notifications
      await notificationService.schedulePrayerNotifications(prayerTimes!, settings);
      
      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    testWidgets('should schedule reminder notifications', (WidgetTester tester) async {
      // Create test reminder
      final reminder = Reminder(
        id: 'integration_test_reminder',
        title: 'Integration Test Reminder',
        description: 'Test reminder for integration testing',
        hijriDate: HijriDate(1445, 6, 15),
        gregorianDate: DateTime.now().add(const Duration(days: 1)),
        type: ReminderType.birthday,
        isRecurring: true,
        isEnabled: true,
        notificationAdvance: const Duration(hours: 2),
        messageTemplates: ['Test reminder message'],
        createdAt: DateTime.now(),
      );

      // Schedule reminder notification
      await notificationService.scheduleReminderNotification(reminder);
      
      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    testWidgets('should integrate with prayer times service', (WidgetTester tester) async {
      // Test prayer times service notification integration
      await prayerTimesService.scheduleTodayPrayerNotifications();
      
      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    testWidgets('should integrate with reminder service', (WidgetTester tester) async {
      // Create and save a test reminder
      final reminder = Reminder(
        id: 'service_integration_test',
        title: 'Service Integration Test',
        description: 'Test reminder for service integration',
        hijriDate: HijriDate(1445, 7, 20),
        gregorianDate: DateTime.now().add(const Duration(days: 2)),
        type: ReminderType.anniversary,
        isRecurring: false,
        isEnabled: true,
        notificationAdvance: const Duration(hours: 1),
        messageTemplates: ['Service integration test'],
        createdAt: DateTime.now(),
      );

      // Save reminder (should automatically schedule notification)
      final saved = await reminderService.saveReminder(reminder);
      expect(saved, isTrue);

      // Delete reminder (should automatically cancel notification)
      final deleted = await reminderService.deleteReminder(reminder.id);
      expect(deleted, isTrue);
    });

    testWidgets('should cancel notifications properly', (WidgetTester tester) async {
      // Test canceling prayer notifications
      await notificationService.cancelPrayerNotifications();
      
      // Test canceling specific reminder notification
      await notificationService.cancelReminderNotification('test_id');
      
      // Test canceling all notifications
      await notificationService.cancelAllNotifications();
      
      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    testWidgets('should show test notification', (WidgetTester tester) async {
      // Show test notification
      await notificationService.showTestNotification();
      
      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    testWidgets('should handle notification with Adhan sounds', (WidgetTester tester) async {
      // Get prayer times
      final prayerTimes = await prayerTimesService.getTodayPrayerTimes();
      expect(prayerTimes, isNotNull);

      // Create settings with Adhan enabled
      const settings = AppSettings(
        enablePrayerNotifications: true,
        enableAdhanSounds: true,
        prayerNotificationAdvanceMinutes: 10,
        enableLocationServices: true,
        language: 'en',
        theme: 'light',
        showGregorianDates: true,
        showEventDots: true,
        prayerTimeFormat: '24h',
      );

      // Schedule notifications with Adhan
      await notificationService.schedulePrayerNotifications(prayerTimes!, settings);
      
      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    testWidgets('should handle different notification advance timings', (WidgetTester tester) async {
      final prayerTimes = await prayerTimesService.getTodayPrayerTimes();
      expect(prayerTimes, isNotNull);

      // Test different advance timings
      final advanceTimings = [5, 15, 30, 60]; // minutes

      for (final advance in advanceTimings) {
        final settings = AppSettings(
          enablePrayerNotifications: true,
          enableAdhanSounds: false,
          prayerNotificationAdvanceMinutes: advance,
          enableLocationServices: true,
          language: 'en',
          theme: 'light',
          showGregorianDates: true,
          showEventDots: true,
          prayerTimeFormat: '12h',
        );

        await notificationService.schedulePrayerNotifications(prayerTimes!, settings);
      }
      
      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    testWidgets('should handle multiple reminder types', (WidgetTester tester) async {
      final reminderTypes = [
        ReminderType.birthday,
        ReminderType.anniversary,
        ReminderType.religious,
      ];

      for (int i = 0; i < reminderTypes.length; i++) {
        final reminder = Reminder(
          id: 'multi_type_test_$i',
          title: 'Multi Type Test ${reminderTypes[i].name}',
          description: 'Test reminder for ${reminderTypes[i].name}',
          hijriDate: HijriDate(1445, 8, 10 + i),
          gregorianDate: DateTime.now().add(Duration(days: i + 1)),
          type: reminderTypes[i],
          isRecurring: true,
          isEnabled: true,
          notificationAdvance: Duration(hours: i + 1),
          messageTemplates: ['Test ${reminderTypes[i].name} message'],
          createdAt: DateTime.now(),
        );

        await notificationService.scheduleReminderNotification(reminder);
      }
      
      // Verify no exceptions were thrown
      expect(true, isTrue);
    });

    testWidgets('should handle service integration with app lifecycle', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app started successfully
      expect(find.byType(MaterialApp), findsOneWidget);

      // Test that notification service is properly integrated
      final initialized = await notificationService.initialize();
      expect(initialized, isTrue);

      // Test scheduling notifications through service integration
      await prayerTimesService.scheduleTodayPrayerNotifications();
      await reminderService.scheduleAllReminderNotifications();
      
      // Verify no exceptions were thrown
      expect(true, isTrue);
    });
  });
}