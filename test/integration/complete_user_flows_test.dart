import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hijri_minder/main.dart' as app;
import 'package:hijri_minder/services/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Flows Integration Tests', () {
    setUp(() async {
      await setupServiceLocator();
    });

    tearDown(() async {
      await ServiceLocator.instance.reset();
    });

    testWidgets('complete reminder creation and notification flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Create new reminder
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill reminder details
      await tester.enterText(find.byType(TextField).first, 'Birthday Reminder');
      await tester.enterText(find.byType(TextField).at(1), 'John Doe Birthday');

      // Select Hijri date
      await tester.tap(find.text('Select Hijri Date'));
      await tester.pumpAndSettle();

      // Select a date from calendar
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Select reminder type
      await tester.tap(find.text('Birthday'));
      await tester.pumpAndSettle();

      // Enable notifications
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Save reminder
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify reminder appears in list
      expect(find.text('Birthday Reminder'), findsOneWidget);
      expect(find.text('John Doe Birthday'), findsOneWidget);

      // Test editing reminder
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Updated Birthday Reminder');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Updated Birthday Reminder'), findsOneWidget);
    });

    testWidgets('complete prayer times display and notification setup flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Verify prayer times are displayed
      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('Zohr'), findsOneWidget);
      expect(find.text('Asr'), findsOneWidget);
      expect(find.text('Maghrib'), findsOneWidget);

      // Navigate to settings to configure notifications
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Enable prayer notifications
      await tester.tap(find.text('Prayer Notifications'));
      await tester.pumpAndSettle();

      // Configure notification advance time
      await tester.tap(find.text('Notification Advance'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('5 minutes'));
      await tester.pumpAndSettle();

      // Enable Adhan sounds
      await tester.tap(find.text('Adhan Sounds'));
      await tester.pumpAndSettle();

      // Go back to prayer times
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Verify settings are applied
      expect(find.textContaining('Next prayer'), findsOneWidget);
    });

    testWidgets('complete calendar navigation and event viewing flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Verify current month is displayed
      expect(find.byType(GridView), findsOneWidget);

      // Navigate to next month
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();

      // Navigate to previous month
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Tap on a date with events
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      // Should show events for that date
      expect(find.text('Events'), findsOneWidget);

      // Navigate to events screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Verify events are displayed
      expect(find.byType(ListView), findsOneWidget);

      // Search for specific event
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Ramadan');
      await tester.pumpAndSettle();

      // Should filter events
      expect(find.textContaining('Ramadan'), findsAtLeastNWidgets(1));
    });

    testWidgets('complete settings configuration flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Change language
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Change theme
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Configure display options
      await tester.tap(find.text('Show Gregorian Dates'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Event Dots'));
      await tester.pumpAndSettle();

      // Configure prayer time format
      await tester.tap(find.text('Prayer Time Format'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('24 Hour'));
      await tester.pumpAndSettle();

      // Verify settings are applied by navigating to other screens
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Should show Gregorian dates
      expect(find.textContaining('/'), findsAtLeastNWidgets(1));

      // Go to prayer times
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Should show 24-hour format
      expect(find.textContaining(':'), findsAtLeastNWidgets(1));
    });

    testWidgets('complete message template selection and sharing flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Create a reminder to trigger message templates
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test Birthday');
      await tester.tap(find.text('Birthday'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Tap on the reminder to view details
      await tester.tap(find.text('Test Birthday'));
      await tester.pumpAndSettle();

      // Access message templates
      await tester.tap(find.text('Send Message'));
      await tester.pumpAndSettle();

      // Select a message template
      await tester.tap(find.text('Birthday Template'));
      await tester.pumpAndSettle();

      // Customize message
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pumpAndSettle();

      // Share message
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      // Select sharing platform
      await tester.tap(find.text('WhatsApp'));
      await tester.pumpAndSettle();

      // Verify sharing flow completed
      expect(tester.takeException(), isNull);
    });

    testWidgets('complete offline to online synchronization flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate offline mode
      await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('connectivity_plus'),
        (methodCall) async {
          if (methodCall.method == 'check') {
            return 'none';
          }
          return null;
        },
      );

      // Navigate to prayer times (should work offline)
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Should show offline indicator
      expect(find.textContaining('offline'), findsAtLeastNWidgets(1));

      // Create reminder while offline
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Offline Reminder');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Simulate coming back online
      await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('connectivity_plus'),
        (methodCall) async {
          if (methodCall.method == 'check') {
            return 'wifi';
          }
          return null;
        },
      );

      // Trigger sync
      await tester.tap(find.text('Sync'));
      await tester.pumpAndSettle();

      // Verify data is still there
      expect(find.text('Offline Reminder'), findsOneWidget);
    });

    testWidgets('complete error recovery flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times (may fail due to API issues)
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // If error occurs, should show error message with retry option
      if (find.text('Error').evaluate().isNotEmpty) {
        expect(find.text('Retry'), findsOneWidget);
        
        // Tap retry
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
      }

      // Should fallback to mock data
      expect(find.text('Fajr'), findsOneWidget);
    });

    testWidgets('complete accessibility flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test semantic labels are present
      expect(find.bySemanticsLabel('Calendar'), findsOneWidget);
      expect(find.bySemanticsLabel('Prayer Times'), findsOneWidget);
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);

      // Navigate using semantics
      await tester.tap(find.bySemanticsLabel('Calendar'));
      await tester.pumpAndSettle();

      // Verify calendar is accessible
      expect(find.byType(GridView), findsOneWidget);

      // Test with large text scale
      await tester.binding.window.textScaleFactorTestValue = 2.0;
      await tester.pump();

      // Should still be usable
      expect(tester.takeException(), isNull);

      // Reset text scale
      await tester.binding.window.clearTextScaleFactorTestValue();
    });
  });
}