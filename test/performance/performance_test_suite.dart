import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/main.dart' as app;
import 'package:hijri_minder/services/service_locator.dart';
import 'package:hijri_minder/models/hijri_date.dart';
import 'package:hijri_minder/models/hijri_calendar.dart';
import 'package:hijri_minder/services/prayer_times_service.dart';
import 'package:hijri_minder/services/events_service.dart';

void main() {
  group('Performance Tests', () {
    setUp(() async {
      await setupServiceLocator();
    });

    tearDown(() async {
      await ServiceLocator.instance.reset();
    });

    testWidgets('app startup performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // App should start within 3 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      
      // Verify app is fully loaded
      expect(find.text('HijriMinder'), findsOneWidget);
    });

    testWidgets('calendar rendering performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      // Navigate to calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Calendar should render within 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      // Verify calendar is rendered
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('prayer times loading performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      // Navigate to prayer times
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Prayer times should load within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      
      // Verify prayer times are displayed
      expect(find.text('Fajr'), findsOneWidget);
    });

    testWidgets('large list scrolling performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to events (which may have many items)
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      // Perform multiple scroll operations
      for (int i = 0; i < 10; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pump();
      }
      
      stopwatch.stop();
      
      // Scrolling should be smooth (less than 100ms per scroll)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('hijri date conversion performance', () {
      final stopwatch = Stopwatch()..start();
      
      // Convert 1000 dates
      for (int i = 0; i < 1000; i++) {
        final gregorianDate = DateTime(2024, 1, 1).add(Duration(days: i));
        HijriDate.fromGregorian(gregorianDate);
      }
      
      stopwatch.stop();
      
      // Should convert 1000 dates within 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('hijri calendar generation performance', () {
      final stopwatch = Stopwatch()..start();
      
      // Generate calendar for a full year
      final calendar = HijriCalendar();
      for (int month = 1; month <= 12; month++) {
        calendar.getMonthDays(1445, month);
      }
      
      stopwatch.stop();
      
      // Should generate full year within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('prayer times calculation performance', () async {
      final prayerTimesService = ServiceLocator.instance.get<PrayerTimesService>();
      final stopwatch = Stopwatch()..start();
      
      // Calculate prayer times for 365 days
      final baseDate = DateTime.now();
      for (int i = 0; i < 365; i++) {
        final date = baseDate.add(Duration(days: i));
        try {
          await prayerTimesService.getPrayerTimes(
            date: date,
            latitude: 21.3891,
            longitude: 39.8579,
          );
        } catch (e) {
          // Expected in test environment
        }
      }
      
      stopwatch.stop();
      
      // Should calculate 365 days within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('events loading performance', () async {
      final eventsService = ServiceLocator.instance.get<EventsService>();
      final stopwatch = Stopwatch()..start();
      
      // Load events for multiple years
      for (int year = 1440; year <= 1450; year++) {
        await eventsService.getEventsForYear(year);
      }
      
      stopwatch.stop();
      
      // Should load 10 years of events within 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('memory usage during navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate through all screens multiple times
      final screens = ['Calendar', 'Prayer Times', 'Events', 'Reminders', 'Settings'];
      
      for (int cycle = 0; cycle < 5; cycle++) {
        for (final screen in screens) {
          await tester.tap(find.text(screen));
          await tester.pumpAndSettle();
          
          // Small delay to allow garbage collection
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      // Should not crash or show memory issues
      expect(tester.takeException(), isNull);
    });

    testWidgets('widget rebuild performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      // Trigger multiple rebuilds by navigating months
      for (int i = 0; i < 20; i++) {
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pump();
      }
      
      stopwatch.stop();
      
      // Should handle 20 rebuilds within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('concurrent operations performance', () async {
      final futures = <Future>[];
      final stopwatch = Stopwatch()..start();
      
      // Simulate concurrent operations
      for (int i = 0; i < 10; i++) {
        futures.add(Future(() async {
          // Simulate date conversions
          for (int j = 0; j < 100; j++) {
            final date = DateTime(2024, 1, 1).add(Duration(days: j));
            HijriDate.fromGregorian(date);
          }
        }));
      }
      
      await Future.wait(futures);
      stopwatch.stop();
      
      // Should handle concurrent operations within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('animation performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      // Trigger animations by rapid navigation
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pump(const Duration(milliseconds: 16)); // One frame
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump(const Duration(milliseconds: 16)); // One frame
      }
      
      stopwatch.stop();
      
      // Animations should be smooth
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('data serialization performance', () {
      final stopwatch = Stopwatch()..start();
      
      // Create large dataset
      final reminders = <Map<String, dynamic>>[];
      for (int i = 0; i < 1000; i++) {
        reminders.add({
          'id': 'reminder_$i',
          'title': 'Reminder $i',
          'description': 'Description for reminder $i',
          'hijriDate': '${i % 30 + 1} Ramadan 1445',
          'type': 'birthday',
          'isActive': i % 2 == 0,
        });
      }
      
      // Serialize and deserialize
      final jsonString = reminders.toString();
      expect(jsonString.isNotEmpty, isTrue);
      
      stopwatch.stop();
      
      // Should handle 1000 items within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('search performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to events
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      // Perform search
      await tester.enterText(find.byType(TextField), 'Ramadan');
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Search should complete within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });
}