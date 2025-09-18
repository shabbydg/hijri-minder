import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/screens/calendar_screen.dart';
import 'package:hijri_minder/services/service_locator.dart';
import 'package:hijri_minder/models/hijri_date.dart';
import 'package:hijri_minder/models/hijri_calendar.dart';

void main() {
  group('CalendarScreen Integration Tests', () {
    setUpAll(() async {
      // Initialize services for testing
      await ServiceLocator.setupServices();
    });

    tearDownAll(() async {
      // Clean up services after testing
      await ServiceLocator.reset();
    });

    testWidgets('Calendar screen integrates correctly with HijriCalendar model', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the calendar displays current Hijri month
      final now = DateTime.now();
      final currentHijriDate = HijriDate.fromGregorian(now);
      final expectedMonthName = HijriDate.getMonthName(currentHijriDate.getMonth());
      
      // Check if the month name appears somewhere in the widget tree
      expect(find.textContaining(expectedMonthName), findsOneWidget);
      
      // Verify year is displayed
      expect(find.textContaining('${currentHijriDate.getYear()} AH'), findsOneWidget);
    });

    testWidgets('Calendar navigation updates month correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Get current month
      final now = DateTime.now();
      final currentHijriDate = HijriDate.fromGregorian(now);
      final currentCalendar = HijriCalendar(
        currentHijriDate.getYear(),
        currentHijriDate.getMonth(),
      );

      // Navigate to next month
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Verify next month is displayed
      final nextMonth = currentCalendar.nextMonth();
      final nextMonthName = HijriDate.getMonthName(nextMonth.getMonth());
      expect(find.textContaining(nextMonthName), findsOneWidget);

      // Navigate back to previous month
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Should be back to current month
      final currentMonthName = HijriDate.getMonthName(currentHijriDate.getMonth());
      expect(find.textContaining(currentMonthName), findsOneWidget);
    });

    testWidgets('Calendar integrates with EventsService for event indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // The calendar should display without errors even if events are present
      expect(find.text('Hijri Calendar'), findsOneWidget);
      
      // Verify that the calendar grid is displayed
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Today highlighting works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to today using the today button
      await tester.tap(find.byIcon(Icons.today));
      await tester.pumpAndSettle();

      // Verify we're on the current month
      final now = DateTime.now();
      final currentHijriDate = HijriDate.fromGregorian(now);
      final currentMonthName = HijriDate.getMonthName(currentHijriDate.getMonth());
      
      expect(find.textContaining(currentMonthName), findsOneWidget);
      expect(find.textContaining('${currentHijriDate.getYear()} AH'), findsOneWidget);
    });

    testWidgets('Calendar displays both Hijri and Gregorian dates', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that both Hijri and Gregorian date numbers are displayed
      // This is a basic check that the calendar is showing date information
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);
      
      // The calendar should have multiple text widgets for dates
      expect(textWidgets.evaluate().length, greaterThan(10));
    });

    testWidgets('Calendar handles month boundaries correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate through several months to test boundary handling
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
        
        // Verify calendar is still functional
        expect(find.text('Hijri Calendar'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      }

      // Navigate back
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
        
        // Verify calendar is still functional
        expect(find.text('Hijri Calendar'), findsOneWidget);
      }
    });
  });
}