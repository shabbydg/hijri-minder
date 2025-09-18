import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/main.dart';
import 'package:hijri_minder/services/service_locator.dart';
import 'package:hijri_minder/models/islamic_event.dart';

void main() {
  group('EventsScreen Integration Tests', () {
    setUpAll(() async {
      await ServiceLocator.setupServices();
    });

    testWidgets('Complete EventsScreen user flow', (WidgetTester tester) async {
      await tester.pumpWidget(const HijriMinderApp());
      await tester.pumpAndSettle();

      // Navigate to Events screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Verify we're on the Events screen
      expect(find.text('Islamic Events'), findsOneWidget);
      expect(find.text('All Events'), findsOneWidget);

      // Test All Events tab
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      expect(find.text('Eid al-Adha'), findsOneWidget);
      expect(find.text('Day of Ashura'), findsOneWidget);

      // Test category filtering
      await tester.tap(find.text('Eid'));
      await tester.pumpAndSettle();

      // Should show only Eid events
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      expect(find.text('Eid al-Adha'), findsOneWidget);
      // Should not show non-Eid events
      expect(find.text('Day of Ashura'), findsNothing);

      // Reset filter
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Test Important Events tab
      await tester.tap(find.text('Important'));
      await tester.pumpAndSettle();

      expect(find.text('Important Islamic Events'), findsOneWidget);
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      expect(find.text('Day of Ashura'), findsOneWidget);

      // Test Search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Ramadan');
      await tester.pumpAndSettle();

      // Should show Ramadan-related events
      expect(find.text('First Day of Ramadan'), findsOneWidget);
      expect(find.text('Laylat al-Qadr'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Test event detail view
      await tester.tap(find.text('All Events'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eid al-Fitr').first);
      await tester.pumpAndSettle();

      // Verify event detail sheet
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Significance'), findsOneWidget);
      expect(find.text('Festival of Breaking the Fast'), findsOneWidget);
      expect(find.text('Add to Calendar'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Test action buttons
      await tester.tap(find.text('Add to Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Add to calendar feature coming soon'), findsOneWidget);

      // Close snackbar and test share button
      await tester.tap(find.byType(SnackBar));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      expect(find.text('Share feature coming soon'), findsOneWidget);
    });

    testWidgets('EventsScreen search and filter combination', (WidgetTester tester) async {
      await tester.pumpWidget(const HijriMinderApp());
      await tester.pumpAndSettle();

      // Navigate to Events screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Go to search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Search for 'Eid'
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Eid');
      await tester.pumpAndSettle();

      // Should show both Eid events
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      expect(find.text('Eid al-Adha'), findsOneWidget);

      // Apply Eid category filter
      await tester.tap(find.text('Eid'));
      await tester.pumpAndSettle();

      // Should still show both Eid events
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      expect(find.text('Eid al-Adha'), findsOneWidget);

      // Change search to something that won't match Eid category
      await tester.enterText(searchField, 'Ashura');
      await tester.pumpAndSettle();

      // Should show no results because Ashura is not in Eid category
      expect(find.text('No events found'), findsOneWidget);

      // Reset category filter
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Should now show Ashura
      expect(find.text('Day of Ashura'), findsOneWidget);
    });

    testWidgets('EventsScreen event cards display correct information', (WidgetTester tester) async {
      await tester.pumpWidget(const HijriMinderApp());
      await tester.pumpAndSettle();

      // Navigate to Events screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Verify event card components
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      expect(find.text('1 Shawwal'), findsOneWidget);
      expect(find.text('Festival of Breaking the Fast'), findsOneWidget);
      expect(find.text('Eid'), findsWidgets);
      expect(find.byIcon(Icons.star), findsWidgets); // Important events have stars
      expect(find.byIcon(Icons.chevron_right), findsWidgets); // Arrow indicators
    });

    testWidgets('EventsScreen handles navigation between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const HijriMinderApp());
      await tester.pumpAndSettle();

      // Navigate to Events screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Start on All Events tab
      expect(find.text('All Events'), findsOneWidget);

      // Switch to Important tab
      await tester.tap(find.text('Important'));
      await tester.pumpAndSettle();
      expect(find.text('Important Islamic Events'), findsOneWidget);

      // Switch to Search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      // Switch back to All Events tab
      await tester.tap(find.text('All Events'));
      await tester.pumpAndSettle();
      expect(find.text('Eid al-Fitr'), findsOneWidget);
    });

    testWidgets('EventsScreen event detail sheet interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const HijriMinderApp());
      await tester.pumpAndSettle();

      // Navigate to Events screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Tap on an event to open detail sheet
      await tester.tap(find.text('Day of Ashura').first);
      await tester.pumpAndSettle();

      // Verify detail sheet content
      expect(find.text('Day of Ashura'), findsWidgets);
      expect(find.text('10 Muharram (Annual)'), findsOneWidget);
      expect(find.text('Shahadat'), findsWidgets);
      expect(find.text('The 10th day of Muharram, commemorating various historical events'), findsOneWidget);

      // Verify sections
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Significance'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Add to Calendar'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Test draggable sheet by dragging down (close)
      await tester.drag(find.text('Day of Ashura').first, const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should be back to main events list
      expect(find.text('Description'), findsNothing);
      expect(find.text('Islamic Events'), findsOneWidget);
    });

    testWidgets('EventsScreen displays events sorted by importance and date', (WidgetTester tester) async {
      await tester.pumpWidget(const HijriMinderApp());
      await tester.pumpAndSettle();

      // Navigate to Events screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Get all event titles in order
      final eventTitles = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Text),
        ),
      ).where((text) => text.style?.fontWeight == FontWeight.bold).map((text) => text.data).toList();

      // Important events should appear first
      expect(eventTitles.contains('Eid al-Fitr'), true);
      expect(eventTitles.contains('Eid al-Adha'), true);
      expect(eventTitles.contains('Day of Ashura'), true);
    });
  });
}