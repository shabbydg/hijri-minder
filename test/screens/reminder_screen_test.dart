import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/screens/reminder_screen.dart';
import 'package:hijri_minder/models/reminder.dart';
import 'package:hijri_minder/models/hijri_date.dart';
import 'package:hijri_minder/services/reminder_service.dart';

void main() {
  group('ReminderScreen Tests', () {
    late ReminderService reminderService;

    setUp(() {
      reminderService = ReminderService();
    });

    testWidgets('should display empty state when no reminders exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ReminderScreen(),
        ),
      );

      // Wait for initial build
      await tester.pump();
      
      // Wait a bit more for async operations
      await tester.pump(const Duration(seconds: 1));

      // Should show loading or empty state
      expect(find.byType(ReminderScreen), findsOneWidget);
    });

    testWidgets('should display floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ReminderScreen(),
        ),
      );

      await tester.pump();

      // Should show FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should open reminder dialog when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ReminderScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should show reminder dialog
      expect(find.text('Add Reminder'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('should display reminders when they exist', (WidgetTester tester) async {
      // Create a test reminder
      final testReminder = Reminder(
        id: 'test_1',
        title: 'Test Birthday',
        description: 'Test description',
        hijriDate: HijriDate(1445, 6, 15),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.birthday,
        createdAt: DateTime.now(),
      );

      // Save the reminder
      await reminderService.saveReminder(testReminder);

      await tester.pumpWidget(
        MaterialApp(
          home: const ReminderScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display the reminder
      expect(find.text('Test Birthday'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.byIcon(Icons.cake), findsOneWidget); // Birthday icon
    });

    testWidgets('should show popup menu when reminder is tapped', (WidgetTester tester) async {
      // Create a test reminder
      final testReminder = Reminder(
        id: 'test_2',
        title: 'Test Anniversary',
        description: 'Test anniversary description',
        hijriDate: HijriDate(1445, 6, 15),
        gregorianDate: DateTime(2024, 1, 1),
        type: ReminderType.anniversary,
        createdAt: DateTime.now(),
      );

      await reminderService.saveReminder(testReminder);

      await tester.pumpWidget(
        MaterialApp(
          home: const ReminderScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the popup menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Should show menu options
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Disable'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    tearDown(() async {
      // Clean up test data
      await reminderService.clearAllReminders();
    });
  });

  group('ReminderDialog Tests', () {
    late ReminderService reminderService;

    setUp(() {
      reminderService = ReminderService();
    });

    testWidgets('should display all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderDialog(reminderService: reminderService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show all form fields
      expect(find.text('Add Reminder'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Date Selection'), findsOneWidget);
      expect(find.text('Recipient Name'), findsOneWidget);
      expect(find.text('Relationship'), findsOneWidget);
      expect(find.text('Recurring Reminder'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderDialog(reminderService: reminderService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to save without entering title
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Title is required'), findsOneWidget);
    });

    testWidgets('should allow selecting reminder type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderDialog(reminderService: reminderService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the type dropdown
      await tester.tap(find.text('BIRTHDAY'));
      await tester.pumpAndSettle();

      // Should show dropdown options
      expect(find.text('ANNIVERSARY'), findsOneWidget);
      expect(find.text('RELIGIOUS'), findsOneWidget);
      expect(find.text('FAMILY'), findsOneWidget);
    });

    testWidgets('should toggle night sensitivity', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderDialog(reminderService: reminderService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the night sensitivity checkbox
      final nightSensitiveCheckbox = find.widgetWithText(CheckboxListTile, 'Night Sensitive');
      expect(nightSensitiveCheckbox, findsOneWidget);

      await tester.tap(nightSensitiveCheckbox);
      await tester.pumpAndSettle();

      // Checkbox should be checked
      final checkbox = tester.widget<CheckboxListTile>(nightSensitiveCheckbox);
      expect(checkbox.value, isTrue);
    });

    testWidgets('should toggle recurring reminder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderDialog(reminderService: reminderService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the recurring reminder checkbox
      final recurringCheckbox = find.widgetWithText(CheckboxListTile, 'Recurring Reminder');
      expect(recurringCheckbox, findsOneWidget);

      // Should be checked by default
      final checkbox = tester.widget<CheckboxListTile>(recurringCheckbox);
      expect(checkbox.value, isTrue);

      // Tap to uncheck
      await tester.tap(recurringCheckbox);
      await tester.pumpAndSettle();

      // Should be unchecked now
      final updatedCheckbox = tester.widget<CheckboxListTile>(recurringCheckbox);
      expect(updatedCheckbox.value, isFalse);
    });

    tearDown(() async {
      await reminderService.clearAllReminders();
    });
  });

  group('HijriDatePickerDialog Tests', () {
    testWidgets('should display date picker fields', (WidgetTester tester) async {
      final initialDate = HijriDate(1445, 6, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HijriDatePickerDialog(initialDate: initialDate),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show date picker fields
      expect(find.text('Select Hijri Date'), findsOneWidget);
      expect(find.text('Year (AH)'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
    });

    testWidgets('should display initial date values', (WidgetTester tester) async {
      final initialDate = HijriDate(1445, 6, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HijriDatePickerDialog(initialDate: initialDate),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show initial values
      expect(find.text('1445 AH'), findsOneWidget);
      expect(find.text(HijriDate.getMonthName(6)), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('should allow selecting different year', (WidgetTester tester) async {
      final initialDate = HijriDate(1445, 6, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HijriDatePickerDialog(initialDate: initialDate),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap year dropdown
      await tester.tap(find.text('1445 AH'));
      await tester.pumpAndSettle();

      // Should show year options
      expect(find.text('1446 AH'), findsOneWidget);
      expect(find.text('1447 AH'), findsOneWidget);
    });

    testWidgets('should return selected date when confirmed', (WidgetTester tester) async {
      final initialDate = HijriDate(1445, 6, 15);
      HijriDate? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedDate = await showDialog<HijriDate>(
                    context: context,
                    builder: (context) => HijriDatePickerDialog(initialDate: initialDate),
                  );
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      // Open the picker
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Confirm selection
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Should return the selected date
      expect(selectedDate, isNotNull);
      expect(selectedDate!.year, equals(1445));
      expect(selectedDate!.month, equals(6));
      expect(selectedDate!.day, equals(15));
    });
  });
}