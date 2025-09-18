import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hijri_minder/main.dart' as app;
import 'package:hijri_minder/models/reminder.dart';
import 'package:hijri_minder/models/hijri_date.dart';
import 'package:hijri_minder/services/reminder_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Task 8 - Reminder Management System Integration Tests', () {
    late ReminderService reminderService;

    setUpAll(() async {
      reminderService = ReminderService();
      await reminderService.initialize();
    });

    setUp(() async {
      // Clear any existing reminders before each test
      await reminderService.clearAllReminders();
    });

    testWidgets('Complete reminder creation flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No reminders yet'), findsOneWidget);
      expect(find.text('Tap the + button to create your first reminder'), findsOneWidget);

      // Tap the FAB to create a new reminder
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should open the reminder dialog
      expect(find.text('Add Reminder'), findsOneWidget);

      // Fill in the form
      await tester.enterText(find.widgetWithText(TextFormField, 'Title *'), 'Ahmad\'s Birthday');
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'My brother\'s birthday celebration');
      await tester.enterText(find.widgetWithText(TextFormField, 'Recipient Name'), 'Ahmad');
      await tester.enterText(find.widgetWithText(TextFormField, 'Relationship'), 'Brother');

      // Select reminder type (Birthday should be default)
      expect(find.text('BIRTHDAY'), findsOneWidget);

      // Test night sensitivity toggle
      final nightSensitiveCheckbox = find.widgetWithText(CheckboxListTile, 'Night Sensitive');
      await tester.tap(nightSensitiveCheckbox);
      await tester.pumpAndSettle();

      // Test date selection - tap on Gregorian date
      await tester.tap(find.text('Gregorian Date'));
      await tester.pumpAndSettle();

      // Should open date picker (we'll just close it for this test)
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Test Hijri date picker
      await tester.tap(find.text('Hijri Date'));
      await tester.pumpAndSettle();

      // Should open Hijri date picker
      expect(find.text('Select Hijri Date'), findsOneWidget);
      
      // Close the Hijri date picker
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Save the reminder
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should return to reminder list and show the new reminder
      expect(find.text('Ahmad\'s Birthday'), findsOneWidget);
      expect(find.text('My brother\'s birthday celebration'), findsOneWidget);
      expect(find.byIcon(Icons.cake), findsOneWidget); // Birthday icon
    });

    testWidgets('Reminder editing flow', (WidgetTester tester) async {
      // Create a test reminder first
      final testReminder = Reminder(
        id: 'test_edit',
        title: 'Original Title',
        description: 'Original description',
        hijriDate: HijriDate(1445, 6, 15),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.anniversary,
        createdAt: DateTime.now(),
      );

      await reminderService.saveReminder(testReminder);

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Should show the test reminder
      expect(find.text('Original Title'), findsOneWidget);

      // Tap the popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap Edit
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Should open edit dialog
      expect(find.text('Edit Reminder'), findsOneWidget);
      expect(find.text('Original Title'), findsOneWidget);

      // Edit the title
      await tester.enterText(find.widgetWithText(TextFormField, 'Title *'), 'Updated Title');

      // Save changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show updated reminder
      expect(find.text('Updated Title'), findsOneWidget);
      expect(find.text('Original Title'), findsNothing);
    });

    testWidgets('Reminder deletion flow', (WidgetTester tester) async {
      // Create a test reminder first
      final testReminder = Reminder(
        id: 'test_delete',
        title: 'To Be Deleted',
        description: 'This will be deleted',
        hijriDate: HijriDate(1445, 6, 15),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.personal,
        createdAt: DateTime.now(),
      );

      await reminderService.saveReminder(testReminder);

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Should show the test reminder
      expect(find.text('To Be Deleted'), findsOneWidget);

      // Tap the popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Delete Reminder'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "To Be Deleted"?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should return to empty state
      expect(find.text('No reminders yet'), findsOneWidget);
      expect(find.text('To Be Deleted'), findsNothing);
    });

    testWidgets('Reminder toggle enable/disable flow', (WidgetTester tester) async {
      // Create a test reminder first
      final testReminder = Reminder(
        id: 'test_toggle',
        title: 'Toggle Test',
        description: 'Test toggling',
        hijriDate: HijriDate(1445, 6, 15),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.family,
        isEnabled: true,
        createdAt: DateTime.now(),
      );

      await reminderService.saveReminder(testReminder);

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Should show the test reminder with enabled styling
      expect(find.text('Toggle Test'), findsOneWidget);

      // Tap the popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Should show "Disable" option since reminder is enabled
      expect(find.text('Disable'), findsOneWidget);

      // Tap Disable
      await tester.tap(find.text('Disable'));
      await tester.pumpAndSettle();

      // Reminder should still be visible but with disabled styling
      expect(find.text('Toggle Test'), findsOneWidget);

      // Tap the popup menu again
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Should now show "Enable" option
      expect(find.text('Enable'), findsOneWidget);
    });

    testWidgets('Different reminder types display correctly', (WidgetTester tester) async {
      // Create reminders of different types
      final reminders = [
        Reminder(
          id: 'birthday_test',
          title: 'Birthday Reminder',
          description: 'Birthday test',
          hijriDate: HijriDate(1445, 6, 15),
          gregorianDate: DateTime(2024, 1, 1),
          type: ReminderType.birthday,
          createdAt: DateTime.now(),
        ),
        Reminder(
          id: 'anniversary_test',
          title: 'Anniversary Reminder',
          description: 'Anniversary test',
          hijriDate: HijriDate(1445, 7, 20),
          gregorianDate: DateTime(2024, 2, 1),
          type: ReminderType.anniversary,
          createdAt: DateTime.now(),
        ),
        Reminder(
          id: 'religious_test',
          title: 'Religious Reminder',
          description: 'Religious test',
          hijriDate: HijriDate(1445, 8, 10),
          gregorianDate: DateTime(2024, 3, 1),
          type: ReminderType.religious,
          createdAt: DateTime.now(),
        ),
      ];

      for (final reminder in reminders) {
        await reminderService.saveReminder(reminder);
      }

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Should show all reminders with correct icons
      expect(find.text('Birthday Reminder'), findsOneWidget);
      expect(find.text('Anniversary Reminder'), findsOneWidget);
      expect(find.text('Religious Reminder'), findsOneWidget);

      expect(find.byIcon(Icons.cake), findsOneWidget); // Birthday
      expect(find.byIcon(Icons.favorite), findsOneWidget); // Anniversary
      expect(find.byIcon(Icons.mosque), findsOneWidget); // Religious
    });

    testWidgets('Hijri date picker functionality', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Tap FAB to create reminder
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter required title
      await tester.enterText(find.widgetWithText(TextFormField, 'Title *'), 'Date Test');

      // Tap Hijri date picker
      await tester.tap(find.text('Hijri Date'));
      await tester.pumpAndSettle();

      // Should show Hijri date picker
      expect(find.text('Select Hijri Date'), findsOneWidget);
      expect(find.text('Year (AH)'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);

      // Test year selection
      await tester.tap(find.text('1445 AH').first);
      await tester.pumpAndSettle();

      // Should show year dropdown options
      expect(find.text('1446 AH'), findsOneWidget);

      // Select a different year
      await tester.tap(find.text('1446 AH'));
      await tester.pumpAndSettle();

      // Test month selection
      final currentMonthName = HijriDate.getMonthName(HijriDate.fromGregorian(DateTime.now()).month);
      await tester.tap(find.text(currentMonthName).first);
      await tester.pumpAndSettle();

      // Should show month options
      expect(find.text('Moharram'), findsOneWidget);

      // Select Moharram
      await tester.tap(find.text('Moharram'));
      await tester.pumpAndSettle();

      // Confirm date selection
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Should return to reminder dialog with updated date
      expect(find.text('1 Moharram 1446 AH'), findsOneWidget);
    });

    testWidgets('Reminder validation works correctly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Reminders tab
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      // Tap FAB to create reminder
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to save without title
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Title is required'), findsOneWidget);

      // Enter title
      await tester.enterText(find.widgetWithText(TextFormField, 'Title *'), 'Valid Title');

      // Now save should work
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should create the reminder successfully
      expect(find.text('Valid Title'), findsOneWidget);
    });

    tearDown(() async {
      // Clean up after each test
      await reminderService.clearAllReminders();
    });
  });
}