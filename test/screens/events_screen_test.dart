import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/screens/events_screen.dart';
import 'package:hijri_minder/services/service_locator.dart';
import 'package:hijri_minder/models/islamic_event.dart';

void main() {
  group('EventsScreen Tests', () {
    setUpAll(() async {
      await ServiceLocator.setupServices();
    });

    testWidgets('EventsScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      // Verify the app bar title
      expect(find.text('Islamic Events'), findsOneWidget);
      
      // Verify tabs are present
      expect(find.text('All Events'), findsOneWidget);
      expect(find.text('Important'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('EventsScreen shows important events by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show important events
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      expect(find.text('Eid al-Adha'), findsOneWidget);
      expect(find.text('Day of Ashura'), findsOneWidget);
    });

    testWidgets('EventsScreen search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Find search field and enter text
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Eid');
      await tester.pumpAndSettle();

      // Should show Eid events
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      expect(find.text('Eid al-Adha'), findsOneWidget);
    });

    testWidgets('EventsScreen category filtering works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show category filter chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Eid'), findsOneWidget);
      expect(find.text('Ramadan'), findsOneWidget);
    });

    testWidgets('EventsScreen event detail sheet opens', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on an event card
      await tester.tap(find.text('Eid al-Fitr').first);
      await tester.pumpAndSettle();

      // Should show event detail sheet
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Significance'), findsOneWidget);
      expect(find.text('Add to Calendar'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('EventsScreen important events tab works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on important tab
      await tester.tap(find.text('Important'));
      await tester.pumpAndSettle();

      // Should show important events header
      expect(find.text('Important Islamic Events'), findsOneWidget);
      
      // Should show important events only
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      expect(find.text('Day of Ashura'), findsOneWidget);
    });

    testWidgets('EventsScreen handles empty search results', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Enter search text that won't match anything
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'NonexistentEvent');
      await tester.pumpAndSettle();

      // Should show no events found message
      expect(find.text('No events found'), findsOneWidget);
      expect(find.text('Try adjusting your search or filters'), findsOneWidget);
    });

    testWidgets('EventsScreen clear search button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Enter search text
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Eid');
      await tester.pumpAndSettle();

      // Should show clear button
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);

      // Tap clear button
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Search field should be empty
      expect(find.text('Eid'), findsNothing);
    });

    testWidgets('EventsScreen event cards show correct information', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show event titles
      expect(find.text('Eid al-Fitr'), findsOneWidget);
      
      // Should show event dates
      expect(find.text('1 Shawwal'), findsOneWidget);
      
      // Should show event descriptions
      expect(find.text('Festival of Breaking the Fast'), findsOneWidget);
      
      // Should show category badges
      expect(find.text('Eid'), findsWidgets);
      
      // Should show importance stars
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('EventsScreen event detail sheet shows complete information', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Eid al-Fitr event
      await tester.tap(find.text('Eid al-Fitr').first);
      await tester.pumpAndSettle();

      // Should show event title
      expect(find.text('Eid al-Fitr'), findsWidgets);
      
      // Should show date with annual indicator
      expect(find.textContaining('1 Shawwal'), findsOneWidget);
      expect(find.textContaining('(Annual)'), findsOneWidget);
      
      // Should show category
      expect(find.text('Eid'), findsWidgets);
      
      // Should show description section
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Festival of Breaking the Fast'), findsOneWidget);
      
      // Should show significance section
      expect(find.text('Significance'), findsOneWidget);
      
      // Should show action buttons
      expect(find.text('Add to Calendar'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('EventsScreen action buttons show snackbar messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Open event detail sheet
      await tester.tap(find.text('Eid al-Fitr').first);
      await tester.pumpAndSettle();

      // Tap Add to Calendar button
      await tester.tap(find.text('Add to Calendar'));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('Add to calendar feature coming soon'), findsOneWidget);

      // Dismiss snackbar
      await tester.tap(find.byType(SnackBar));
      await tester.pumpAndSettle();

      // Tap Share button
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('Share feature coming soon'), findsOneWidget);
    });
  });

  group('EventDetailSheet Tests', () {
    testWidgets('EventDetailSheet displays event information correctly', (WidgetTester tester) async {
      const testEvent = IslamicEvent(
        id: 'test_event',
        title: 'Test Event',
        description: 'This is a test event description',
        category: EventCategory.eid,
        hijriDay: 15,
        hijriMonth: 6,
        isImportant: true,
        location: 'Test Location',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const EventDetailSheet(event: testEvent),
                  );
                },
                child: const Text('Show Detail'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show detail sheet
      await tester.tap(find.text('Show Detail'));
      await tester.pumpAndSettle();

      // Should show event title
      expect(find.text('Test Event'), findsOneWidget);
      
      // Should show date
      expect(find.textContaining('15 Jumada al-Thani'), findsOneWidget);
      
      // Should show category
      expect(find.text('Eid'), findsWidgets);
      
      // Should show location
      expect(find.text('Test Location'), findsOneWidget);
      
      // Should show description
      expect(find.text('This is a test event description'), findsOneWidget);
      
      // Should show importance star
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}