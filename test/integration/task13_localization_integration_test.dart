import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hijri_minder/main.dart' as app;
import 'package:hijri_minder/services/service_locator.dart';
import 'package:hijri_minder/services/localization_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Task 13: Multi-language Support and Localization Integration Tests', () {
    setUpAll(() async {
      // Initialize services before tests
      await ServiceLocator.setupServices();
    });

    tearDownAll(() async {
      // Clean up after tests
      await ServiceLocator.reset();
    });

    testWidgets('should display app in default English language', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify English labels are displayed
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Prayer Times'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should change language to Arabic and display RTL layout', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find and tap language dropdown
      final languageDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();

      // Select Arabic
      await tester.tap(find.text('العربية').last);
      await tester.pumpAndSettle();

      // Verify Arabic labels are displayed
      expect(find.text('التقويم'), findsOneWidget);
      expect(find.text('أوقات الصلاة'), findsOneWidget);
      expect(find.text('التذكيرات'), findsOneWidget);
      expect(find.text('الأحداث'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);

      // Verify RTL text direction
      final localizationService = ServiceLocator.localizationService;
      expect(localizationService.isRTL, isTrue);
      expect(localizationService.textDirection, TextDirection.rtl);
    });

    testWidgets('should change language to Indonesian', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find and tap language dropdown
      final languageDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();

      // Select Indonesian
      await tester.tap(find.text('Bahasa Indonesia').last);
      await tester.pumpAndSettle();

      // Verify Indonesian labels are displayed
      expect(find.text('Kalender'), findsOneWidget);
      expect(find.text('Waktu Sholat'), findsOneWidget);
      expect(find.text('Pengingat'), findsOneWidget);
      expect(find.text('Acara'), findsOneWidget);
      expect(find.text('Pengaturan'), findsOneWidget);

      // Verify LTR text direction for Indonesian
      final localizationService = ServiceLocator.localizationService;
      expect(localizationService.isRTL, isFalse);
      expect(localizationService.textDirection, TextDirection.ltr);
    });

    testWidgets('should toggle Arabic numerals setting', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find Arabic numerals switch
      final arabicNumeralsSwitch = find.byType(SwitchListTile).last;
      
      // Get initial state
      final localizationService = ServiceLocator.localizationService;
      final initialState = localizationService.useArabicNumerals;

      // Toggle the switch
      await tester.tap(arabicNumeralsSwitch);
      await tester.pumpAndSettle();

      // Verify state changed
      expect(localizationService.useArabicNumerals, !initialState);
    });

    testWidgets('should format numbers correctly based on locale and settings', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      final localizationService = ServiceLocator.localizationService;

      // Test English numerals
      await localizationService.changeLanguage('en');
      expect(localizationService.formatNumber(123), '123');

      // Test Arabic numerals when enabled
      await localizationService.changeLanguage('ar');
      // Arabic language should auto-enable Arabic numerals
      expect(localizationService.useArabicNumerals, isTrue);
      expect(localizationService.formatNumber(123), '١٢٣');

      // Test time formatting
      expect(localizationService.formatTime('12:30'), '١٢:٣٠');
    });

    testWidgets('should maintain language preference across app restarts', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Change to Arabic
      final localizationService = ServiceLocator.localizationService;
      await localizationService.changeLanguage('ar');
      await tester.pumpAndSettle();

      // Verify Arabic is set
      expect(localizationService.currentLocale.languageCode, 'ar');

      // Simulate app restart by reinitializing services
      await ServiceLocator.reset();
      await ServiceLocator.setupServices();
      await tester.pumpAndSettle();

      // Verify language preference is maintained
      final newLocalizationService = ServiceLocator.localizationService;
      expect(newLocalizationService.currentLocale.languageCode, 'ar');
    });

    testWidgets('should support all required languages', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      final localizationService = ServiceLocator.localizationService;
      
      // Test all supported languages
      final supportedLanguages = ['en', 'ar', 'id', 'ur', 'ms', 'tr', 'fa', 'bn'];
      
      for (final languageCode in supportedLanguages) {
        await localizationService.changeLanguage(languageCode);
        await tester.pumpAndSettle();
        
        expect(localizationService.currentLocale.languageCode, languageCode);
        
        // Verify RTL detection works correctly
        final expectedRTL = ['ar', 'ur', 'fa'].contains(languageCode);
        expect(localizationService.isRTL, expectedRTL);
      }
    });

    testWidgets('should handle Islamic terminology correctly in different languages', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times screen
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      final localizationService = ServiceLocator.localizationService;

      // Test Arabic
      await localizationService.changeLanguage('ar');
      await tester.pumpAndSettle();
      
      // Should display Arabic prayer names
      expect(find.textContaining('الفجر'), findsWidgets);
      expect(find.textContaining('المغرب'), findsWidgets);

      // Test Indonesian
      await localizationService.changeLanguage('id');
      await tester.pumpAndSettle();
      
      // Should display Indonesian prayer names
      expect(find.textContaining('Subuh'), findsWidgets);
      expect(find.textContaining('Maghrib'), findsWidgets);
    });
  });
}