import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/widgets/error_display.dart';
import 'package:hijri_minder/utils/error_handler.dart';

void main() {
  group('ErrorDisplay Widget Tests', () {
    testWidgets('should display error message correctly', (WidgetTester tester) async {
      const testError = 'Test error message';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: testError,
            ),
          ),
        ),
      );

      expect(find.text(testError), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided', (WidgetTester tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Test error',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      
      await tester.tap(find.text('Retry'));
      await tester.pump();
      
      expect(retryPressed, isTrue);
    });

    testWidgets('should not display retry button when onRetry is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Test error',
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('should display network error icon for network errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Network error',
              errorType: ErrorType.network,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('should display permission error icon for permission errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Permission error',
              errorType: ErrorType.permission,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should display details when showDetails is true', (WidgetTester tester) async {
      const message = 'Test error';
      const details = 'Detailed error information';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: message,
              details: details,
              showDetails: true,
            ),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(find.textContaining(details), findsOneWidget);
    });

    testWidgets('should display dismiss button when onDismiss is provided', (WidgetTester tester) async {
      bool dismissPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Test error',
              onDismiss: () {
                dismissPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Dismiss'), findsOneWidget);
      
      await tester.tap(find.text('Dismiss'));
      await tester.pump();
      
      expect(dismissPressed, isTrue);
    });

    testWidgets('should handle long error messages', (WidgetTester tester) async {
      const longError = 'This is a very long error message that should wrap properly and not overflow the widget boundaries when displayed to the user';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: longError,
            ),
          ),
        ),
      );

      expect(find.text(longError), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display user-friendly message for error types', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Raw API error',
              errorType: ErrorType.api,
            ),
          ),
        ),
      );

      // Should display user-friendly message instead of raw error
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}