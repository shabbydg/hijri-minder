import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/widgets/offline_indicator.dart';

void main() {
  group('OfflineIndicator Widget Tests', () {
    testWidgets('should display offline message when offline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(
              isOnline: false,
            ),
          ),
        ),
      );

      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('should not display anything when online', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(
              isOnline: true,
            ),
          ),
        ),
      );

      expect(find.text('No internet connection'), findsNothing);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
    });

    testWidgets('should display custom message when provided', (WidgetTester tester) async {
      const customMessage = 'Custom offline message';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(
              isOnline: false,
              message: customMessage,
            ),
          ),
        ),
      );

      expect(find.text(customMessage), findsOneWidget);
      expect(find.text('No internet connection'), findsNothing);
    });

    testWidgets('should apply custom background color when provided', (WidgetTester tester) async {
      const customColor = Colors.red;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(
              isOnline: false,
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
    });

    testWidgets('should handle state changes correctly', (WidgetTester tester) async {
      bool isOnline = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    OfflineIndicator(isOnline: isOnline),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isOnline = !isOnline;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially offline
      expect(find.text('No internet connection'), findsOneWidget);
      
      // Toggle to online
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      
      expect(find.text('No internet connection'), findsNothing);
      
      // Toggle back to offline
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      
      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('should display with proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(
              isOnline: false,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, isNotNull);
      expect(container.decoration, isNotNull);
    });
  });
}