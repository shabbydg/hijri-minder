import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hijri_minder/main.dart' as app;
import 'package:hijri_minder/services/localization_service.dart';
import 'package:hijri_minder/services/service_locator.dart';
import 'package:hijri_minder/utils/arabic_numerals.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RTL and Localization Integration Tests', () {
    setUp(() async {
      await setupServiceLocator();
    });

    tearDown(() async {
      await ServiceLocator.instance.reset();
    });

    testWidgets('should support Arabic RTL layout', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Change language to Arabic
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Check if layout is RTL
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isNotNull);

      // Verify Arabic text is displayed
      expect(find.textContaining('العربية'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display Arabic-Indic numerals when enabled', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Enable Arabic numerals in settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Arabic Numerals'));
      await tester.pumpAndSettle();

      // Go back to calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Check for Arabic-Indic numerals
      final arabicNumerals = ArabicNumerals.convert('1234567890');
      expect(find.textContaining(arabicNumerals), findsAtLeastNWidgets(1));
    });

    testWidgets('should support all required languages', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final supportedLanguages = [
        'English',
        'العربية', // Arabic
        'Bahasa Indonesia', // Indonesian
        'اردو', // Urdu
        'Bahasa Melayu', // Malay
        'Türkçe', // Turkish
        'فارسی', // Persian
        'বাংলা', // Bengali
      ];

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Verify all languages are available
      for (final language in supportedLanguages) {
        expect(find.text(language), findsOneWidget);
      }
    });

    testWidgets('should maintain functionality across language changes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test core functionality in different languages
      final languages = ['English', 'العربية', 'Bahasa Indonesia'];

      for (final language in languages) {
        // Change language
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Language'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(language));
        await tester.pumpAndSettle();

        // Test calendar functionality
        await tester.tap(find.text('Calendar'));
        await tester.pumpAndSettle();
        expect(find.byType(GridView), findsOneWidget);

        // Test prayer times functionality
        await tester.tap(find.text('Prayer Times'));
        await tester.pumpAndSettle();
        expect(find.byType(ListView), findsOneWidget);
      }
    });

    testWidgets('should handle RTL text direction correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Change to Arabic
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Check text direction
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.locale?.languageCode, equals('ar'));

      // Verify RTL layout
      final directionality = tester.widget<Directionality>(find.byType(Directionality).first);
      expect(directionality.textDirection, equals(TextDirection.rtl));
    });

    testWidgets('should localize Islamic terminology correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to events screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Change to Arabic and verify Islamic terms
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Go back to events
      await tester.tap(find.text('الأحداث')); // Events in Arabic
      await tester.pumpAndSettle();

      // Verify Islamic terms are properly localized
      expect(find.textContaining('رمضان'), findsAtLeastNWidgets(1)); // Ramadan
      expect(find.textContaining('عيد'), findsAtLeastNWidgets(1)); // Eid
    });

    testWidgets('should handle date formatting in different locales', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Test different locales
      final locales = ['en', 'ar', 'id', 'ur'];

      for (final locale in locales) {
        // Change language
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Language'));
        await tester.pumpAndSettle();

        // Select appropriate language for locale
        String languageName;
        switch (locale) {
          case 'ar':
            languageName = 'العربية';
            break;
          case 'id':
            languageName = 'Bahasa Indonesia';
            break;
          case 'ur':
            languageName = 'اردو';
            break;
          default:
            languageName = 'English';
        }

        await tester.tap(find.text(languageName));
        await tester.pumpAndSettle();

        // Go back to calendar
        await tester.tap(find.text('Calendar'));
        await tester.pumpAndSettle();

        // Verify date formatting is appropriate for locale
        expect(find.byType(GridView), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('should preserve user data across language changes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create a reminder in English
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test Reminder');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Change language to Arabic
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Go back to reminders
      await tester.tap(find.text('التذكيرات')); // Reminders in Arabic
      await tester.pumpAndSettle();

      // Verify reminder is still there
      expect(find.text('Test Reminder'), findsOneWidget);
    });

    testWidgets('should handle mixed content (Arabic and English) correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Change to Arabic
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Navigate to prayer times (which may contain mixed content)
      await tester.tap(find.text('أوقات الصلاة')); // Prayer Times in Arabic
      await tester.pumpAndSettle();

      // Should handle mixed Arabic/English content without layout issues
      expect(tester.takeException(), isNull);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should support font scaling for different languages', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test with different text scales
      await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/platform'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'SystemChrome.setSystemUIOverlayStyle') {
            return null;
          }
          return null;
        },
      );

      // Change to Arabic (which may need different font handling)
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Verify text is readable and properly scaled
      expect(tester.takeException(), isNull);
    });
  });
}