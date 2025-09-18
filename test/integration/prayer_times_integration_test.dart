import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hijri_minder/main.dart' as app;
import 'package:hijri_minder/services/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prayer Times Integration Tests', () {
    setUpAll(() async {
      // Initialize services
      await ServiceLocator.setupServices();
    });

    testWidgets('Complete prayer times flow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should start on calendar screen (index 0)
      expect(find.text('Hijri Calendar'), findsOneWidget);

      // Navigate to prayer times screen
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Should display prayer times screen
      expect(find.text('Prayer Times'), findsOneWidget);

      // Wait for prayer times to load
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify all required components are present
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Next Prayer'), findsOneWidget);
      expect(find.text('Today\'s Prayer Times'), findsOneWidget);

      // Verify all prayer times are displayed
      final prayerNames = [
        'Sihori',
        'Fajr',
        'Sunrise',
        'Zawaal',
        'Zohr End',
        'Asr End',
        'Maghrib',
        'Maghrib End',
        'Nisful Layl',
        'Nisful Layl End',
      ];

      for (final prayerName in prayerNames) {
        expect(find.text(prayerName), findsOneWidget);
      }

      // Test refresh functionality
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for refresh to complete
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should still display all prayer times after refresh
      expect(find.text('Today\'s Prayer Times'), findsOneWidget);
      expect(find.text('Next Prayer'), findsOneWidget);
    });

    testWidgets('Prayer times countdown functionality test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times screen
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Wait for prayer times to load
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify countdown is displayed
      expect(find.text('Hours : Minutes : Seconds'), findsOneWidget);

      // Find countdown display
      final countdownFinder = find.byWidgetPredicate((widget) =>
          widget is Text &&
          widget.style?.fontFamily == 'monospace' &&
          RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(widget.data ?? ''));

      expect(countdownFinder, findsOneWidget);

      // Get initial countdown value
      final initialCountdown = tester.widget<Text>(countdownFinder).data;

      // Wait for 3 seconds
      await tester.pump(const Duration(seconds: 3));

      // Get updated countdown value
      final updatedCountdown = tester.widget<Text>(countdownFinder).data;

      // Countdown should have changed
      expect(initialCountdown != updatedCountdown, isTrue);
    });

    testWidgets('Location service integration test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times screen
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Wait for prayer times to load
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should display location information
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);

      // Should display either actual location or fallback location
      final locationDisplays = find.byWidgetPredicate((widget) =>
          widget is Text &&
          (widget.data?.contains('Colombo') == true ||
           widget.data?.contains('Sri Lanka') == true ||
           widget.data?.contains('Fallback') == true ||
           RegExp(r'\d+\.\d+').hasMatch(widget.data ?? ''))); // Coordinate format

      expect(locationDisplays, findsWidgets);
    });

    testWidgets('Prayer time formatting test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times screen
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Wait for prayer times to load
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should display formatted prayer times
      final timeDisplays = find.byWidgetPredicate((widget) =>
          widget is Text &&
          (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(widget.data ?? '') ||
           RegExp(r'^\d{1,2}:\d{2} (AM|PM)$').hasMatch(widget.data ?? '')));

      expect(timeDisplays, findsWidgets); // All prayer times
    });

    testWidgets('Pull to refresh functionality test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times screen
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Wait for prayer times to load
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Perform pull-to-refresh gesture
      await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 300), 1000);
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for refresh to complete
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should still display prayer times after refresh
      expect(find.text('Today\'s Prayer Times'), findsOneWidget);
    });

    testWidgets('Navigation between screens test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should start on calendar screen
      expect(find.text('Hijri Calendar'), findsOneWidget);

      // Navigate to prayer times
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Should be on prayer times screen
      expect(find.text('Prayer Times'), findsOneWidget);

      // Navigate back to calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Should be back on calendar screen
      expect(find.text('Hijri Calendar'), findsOneWidget);

      // Navigate to prayer times again
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Should maintain prayer times data
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.text('Today\'s Prayer Times'), findsOneWidget);
    });

    testWidgets('Error handling test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times screen
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Wait for potential error or success
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Should either show prayer times or error state with retry option
      final hasSuccessState = find.text('Today\'s Prayer Times').evaluate().isNotEmpty;
      final hasErrorState = find.byIcon(Icons.error_outline).evaluate().isNotEmpty;

      expect(hasSuccessState || hasErrorState, isTrue);

      // If error state, should have retry button
      if (hasErrorState) {
        expect(find.text('Retry'), findsOneWidget);
        
        // Test retry functionality
        await tester.tap(find.text('Retry'));
        await tester.pump();
        
        // Should show loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      }
    });
  });
}