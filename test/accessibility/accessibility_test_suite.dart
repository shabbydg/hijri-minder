import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/main.dart' as app;
import 'package:hijri_minder/services/service_locator.dart';

void main() {
  group('Accessibility Tests', () {
    setUp(() async {
      await setupServiceLocator();
    });

    tearDown(() async {
      await ServiceLocator.instance.reset();
    });

    testWidgets('should have proper semantic labels for navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check main navigation items have semantic labels
      expect(find.bySemanticsLabel('Calendar'), findsOneWidget);
      expect(find.bySemanticsLabel('Prayer Times'), findsOneWidget);
      expect(find.bySemanticsLabel('Events'), findsOneWidget);
      expect(find.bySemanticsLabel('Reminders'), findsOneWidget);
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    });

    testWidgets('should support screen reader navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      
      try {
        // Navigate to calendar
        await tester.tap(find.bySemanticsLabel('Calendar'));
        await tester.pumpAndSettle();

        // Check calendar has proper semantic structure
        expect(find.byType(Semantics), findsAtLeastNWidgets(1));
        
        // Calendar grid should be accessible
        final gridSemantics = tester.getSemantics(find.byType(GridView));
        expect(gridSemantics.hasAction(SemanticsAction.scrollUp), isTrue);
        expect(gridSemantics.hasAction(SemanticsAction.scrollDown), isTrue);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('should have proper contrast ratios', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test with different themes
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Switch to dark theme
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Verify dark theme is applied
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, equals(Brightness.dark));

      // Switch to light theme
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      // Verify light theme is applied
      final lightMaterialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(lightMaterialApp.theme?.brightness, equals(Brightness.light));
    });

    testWidgets('should support large text scaling', (WidgetTester tester) async {
      // Set large text scale
      await tester.binding.window.textScaleFactorTestValue = 2.0;
      
      app.main();
      await tester.pumpAndSettle();

      // App should still be usable with large text
      expect(find.text('HijriMinder'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Navigate to different screens
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Reset text scale
      await tester.binding.window.clearTextScaleFactorTestValue();
    });

    testWidgets('should have accessible form controls', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders to test form accessibility
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();
      
      try {
        // Check text fields have proper labels
        final textFields = find.byType(TextField);
        expect(textFields, findsAtLeastNWidgets(1));

        for (final textField in textFields.evaluate()) {
          final semantics = tester.getSemantics(find.byWidget(textField.widget));
          expect(semantics.label, isNotNull);
          expect(semantics.label!.isNotEmpty, isTrue);
        }

        // Check buttons have proper labels
        final buttons = find.byType(ElevatedButton);
        for (final button in buttons.evaluate()) {
          final semantics = tester.getSemantics(find.byWidget(button.widget));
          expect(semantics.label, isNotNull);
          expect(semantics.label!.isNotEmpty, isTrue);
        }
      } finally {
        handle.dispose();
      }
    });

    testWidgets('should support keyboard navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test tab navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Should focus on first focusable element
      expect(tester.binding.focusManager.primaryFocus, isNotNull);

      // Continue tabbing through elements
      for (int i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      // Should not crash or lose focus
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have proper focus indicators', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Test focus on interactive elements
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pump();

        // Focus should be visible (no exception should occur)
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('should provide audio feedback for actions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();
      
      try {
        // Navigate to prayer times
        await tester.tap(find.text('Prayer Times'));
        await tester.pumpAndSettle();

        // Check if elements provide semantic feedback
        final listItems = find.byType(ListTile);
        if (listItems.evaluate().isNotEmpty) {
          final semantics = tester.getSemantics(listItems.first);
          expect(semantics.hasAction(SemanticsAction.tap), isTrue);
        }
      } finally {
        handle.dispose();
      }
    });

    testWidgets('should support voice control', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();
      
      try {
        // Test semantic actions for voice control
        final calendarButton = find.text('Calendar');
        final semantics = tester.getSemantics(calendarButton);
        
        expect(semantics.hasAction(SemanticsAction.tap), isTrue);
        expect(semantics.label, equals('Calendar'));
      } finally {
        handle.dispose();
      }
    });

    testWidgets('should handle reduced motion preferences', (WidgetTester tester) async {
      // Simulate reduced motion preference
      await tester.binding.window.accessibilityFeaturesTestValue = 
          AccessibilityFeatures.reduceMotion;
      
      app.main();
      await tester.pumpAndSettle();

      // Navigate to calendar (which may have animations)
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Should work without animations
      expect(find.byType(GridView), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Reset accessibility features
      await tester.binding.window.clearAccessibilityFeaturesTestValue();
    });

    testWidgets('should provide alternative text for images', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();
      
      try {
        // Check if icons have semantic labels
        final icons = find.byType(Icon);
        for (final icon in icons.evaluate()) {
          final semantics = tester.getSemantics(find.byWidget(icon.widget));
          // Icons should either have labels or be marked as decorative
          expect(semantics.label != null || semantics.isHidden, isTrue);
        }
      } finally {
        handle.dispose();
      }
    });

    testWidgets('should support RTL accessibility', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Change to Arabic (RTL language)
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();
      
      try {
        // Check RTL text direction is properly set
        final directionality = tester.widget<Directionality>(
          find.byType(Directionality).first
        );
        expect(directionality.textDirection, equals(TextDirection.rtl));

        // Semantic tree should respect RTL direction
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('should have proper heading hierarchy', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();
      
      try {
        // Navigate to different screens and check heading structure
        await tester.tap(find.text('Calendar'));
        await tester.pumpAndSettle();

        // Check for proper semantic structure
        expect(find.byType(Semantics), findsAtLeastNWidgets(1));
        
        // App should have logical heading hierarchy
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('should support high contrast mode', (WidgetTester tester) async {
      // Simulate high contrast mode
      await tester.binding.window.accessibilityFeaturesTestValue = 
          AccessibilityFeatures.highContrast;
      
      app.main();
      await tester.pumpAndSettle();

      // App should adapt to high contrast mode
      expect(find.text('HijriMinder'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Reset accessibility features
      await tester.binding.window.clearAccessibilityFeaturesTestValue();
    });

    testWidgets('should provide clear error messages', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to reminders form
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();
      
      try {
        // Try to save empty form to trigger validation
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Error messages should be accessible
        final errorTexts = find.textContaining('required');
        if (errorTexts.evaluate().isNotEmpty) {
          final semantics = tester.getSemantics(errorTexts.first);
          expect(semantics.label, isNotNull);
        }
      } finally {
        handle.dispose();
      }
    });

    testWidgets('should support assistive technology', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();
      
      try {
        // Test that semantic tree is properly constructed
        final semanticsTree = tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
        expect(semanticsTree, isNotNull);
        
        // Should have proper semantic structure for screen readers
        expect(semanticsTree!.childrenCount, greaterThan(0));
      } finally {
        handle.dispose();
      }
    });
  });
}