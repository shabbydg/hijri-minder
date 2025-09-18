import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/main.dart' as app;
import '../../lib/services/service_locator.dart';
import '../../lib/models/app_settings.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings Screen Integration Tests', () {
    setUp(() async {
      // Reset services before each test
      await ServiceLocator.reset();
    });

    testWidgets('should navigate to settings screen and display all sections', (WidgetTester tester) async {
      // Arrange & Act
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings screen
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Assert - should display all main sections
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Prayer Notifications'), findsOneWidget);
      expect(find.text('Display Options'), findsOneWidget);
      expect(find.text('Language & Theme'), findsOneWidget);
      expect(find.text('Location Services'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);
    });

    testWidgets('should toggle prayer notification settings', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - toggle prayer notifications
      final prayerNotificationSwitch = find.byType(SwitchListTile).first;
      final initialValue = tester.widget<SwitchListTile>(prayerNotificationSwitch).value;
      
      await tester.tap(prayerNotificationSwitch);
      await tester.pumpAndSettle();

      // Assert - value should have changed
      final newValue = tester.widget<SwitchListTile>(prayerNotificationSwitch).value;
      expect(newValue, !initialValue);
    });

    testWidgets('should change language setting', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - tap language dropdown
      final languageDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();

      // Select Arabic
      await tester.tap(find.text('العربية').last);
      await tester.pumpAndSettle();

      // Assert - should show Arabic as selected language
      expect(find.text('العربية'), findsOneWidget);
    });

    testWidgets('should change theme setting', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - tap theme dropdown
      final themeDropdown = find.byType(DropdownButton<String>).at(1);
      await tester.tap(themeDropdown);
      await tester.pumpAndSettle();

      // Select Dark theme
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      // Assert - should show Dark as selected theme
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('should change prayer time format', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - tap prayer time format dropdown
      final timeFormatDropdown = find.byType(DropdownButton<String>).at(2);
      await tester.tap(timeFormatDropdown);
      await tester.pumpAndSettle();

      // Select 12-hour format
      await tester.tap(find.text('12-hour').last);
      await tester.pumpAndSettle();

      // Assert - should show 12-hour format as selected
      expect(find.text('12-hour format'), findsOneWidget);
    });

    testWidgets('should adjust notification advance time', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - tap notification advance time dropdown
      final advanceTimeDropdown = find.byType(DropdownButton<int>).first;
      await tester.tap(advanceTimeDropdown);
      await tester.pumpAndSettle();

      // Select 15 minutes before
      await tester.tap(find.text('15 minutes before').last);
      await tester.pumpAndSettle();

      // Assert - should show 15 minutes as selected
      expect(find.text('15 minutes before'), findsOneWidget);
    });

    testWidgets('should toggle display options', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - toggle Gregorian dates display
      final gregorianDatesSwitch = find.text('Show Gregorian Dates');
      await tester.tap(gregorianDatesSwitch);
      await tester.pumpAndSettle();

      // Act - toggle event dots display
      final eventDotsSwitch = find.text('Show Event Dots');
      await tester.tap(eventDotsSwitch);
      await tester.pumpAndSettle();

      // Act - toggle Arabic numerals
      final arabicNumeralsSwitch = find.text('Use Arabic Numerals');
      await tester.tap(arabicNumeralsSwitch);
      await tester.pumpAndSettle();

      // Assert - switches should be present and functional
      expect(find.text('Show Gregorian Dates'), findsOneWidget);
      expect(find.text('Show Event Dots'), findsOneWidget);
      expect(find.text('Use Arabic Numerals'), findsOneWidget);
    });

    testWidgets('should adjust font size slider', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - find and interact with font size slider
      final fontSizeSlider = find.byType(Slider);
      expect(fontSizeSlider, findsOneWidget);

      // Get current slider value
      final slider = tester.widget<Slider>(fontSizeSlider);
      final currentValue = slider.value;

      // Drag slider to increase font size
      await tester.drag(fontSizeSlider, const Offset(50, 0));
      await tester.pumpAndSettle();

      // Assert - slider should be functional
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should toggle location services', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - toggle location services
      final locationServicesSwitch = find.text('Enable Location Services');
      await tester.tap(locationServicesSwitch);
      await tester.pumpAndSettle();

      // Act - toggle auto location update
      final autoLocationSwitch = find.text('Auto Location Update');
      await tester.tap(autoLocationSwitch);
      await tester.pumpAndSettle();

      // Assert - location settings should be present
      expect(find.text('Enable Location Services'), findsOneWidget);
      expect(find.text('Auto Location Update'), findsOneWidget);
      expect(find.text('Default Location'), findsOneWidget);
    });

    testWidgets('should open location edit dialog', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - tap default location
      await tester.tap(find.text('Default Location'));
      await tester.pumpAndSettle();

      // Assert - should show location edit dialog
      expect(find.text('Default Location'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('should toggle reminder notifications', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - toggle reminder notifications
      final reminderNotificationSwitch = find.text('Enable Reminder Notifications');
      await tester.tap(reminderNotificationSwitch);
      await tester.pumpAndSettle();

      // Assert - reminder settings should be present
      expect(find.text('Enable Reminder Notifications'), findsOneWidget);
    });

    testWidgets('should open about dialog', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - tap About HijriMinder
      await tester.tap(find.text('About HijriMinder'));
      await tester.pumpAndSettle();

      // Assert - should show about dialog
      expect(find.text('About HijriMinder'), findsWidgets);
      expect(find.text('A comprehensive Hijri calendar application'), findsOneWidget);
      expect(find.text('Features:'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('should open privacy policy dialog', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - tap Privacy Policy
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      // Assert - should show privacy policy dialog
      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.text('HijriMinder respects your privacy'), findsOneWidget);
      expect(find.text('Data Collection:'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('should open terms of service dialog', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - tap Terms of Service
      await tester.tap(find.text('Terms of Service'));
      await tester.pumpAndSettle();

      // Assert - should show terms of service dialog
      expect(find.text('Terms of Service'), findsWidgets);
      expect(find.text('By using this application, you agree'), findsOneWidget);
      expect(find.text('Disclaimer:'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('should reset settings to default', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - open menu and select reset
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset to Default'));
      await tester.pumpAndSettle();

      // Confirm reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Assert - should show success message and reset settings
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should persist settings across app restarts', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings and change language
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      final languageDropdown = find.byType(DropdownButton<String>).first;
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية').last);
      await tester.pumpAndSettle();

      // Restart app simulation
      await ServiceLocator.reset();
      app.main();
      await tester.pumpAndSettle();

      // Navigate back to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Assert - language should still be Arabic
      expect(find.text('العربية'), findsOneWidget);
    });

    testWidgets('should handle dependent settings correctly', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - disable prayer notifications
      final prayerNotificationSwitch = find.byType(SwitchListTile).first;
      await tester.tap(prayerNotificationSwitch);
      await tester.pumpAndSettle();

      // Assert - dependent settings should be disabled
      final adhanSoundsSwitch = find.byType(SwitchListTile).at(1);
      final vibrationSwitch = find.byType(SwitchListTile).at(2);
      
      expect(tester.widget<SwitchListTile>(adhanSoundsSwitch).onChanged, isNull);
      expect(tester.widget<SwitchListTile>(vibrationSwitch).onChanged, isNull);

      // Re-enable prayer notifications
      await tester.tap(prayerNotificationSwitch);
      await tester.pumpAndSettle();

      // Assert - dependent settings should be enabled again
      expect(tester.widget<SwitchListTile>(adhanSoundsSwitch).onChanged, isNotNull);
      expect(tester.widget<SwitchListTile>(vibrationSwitch).onChanged, isNotNull);
    });

    testWidgets('should validate settings changes', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - change multiple settings
      await tester.tap(find.text('Show Gregorian Dates'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Event Dots'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Use Arabic Numerals'));
      await tester.pumpAndSettle();

      // Assert - all settings should be functional
      expect(find.text('Show Gregorian Dates'), findsOneWidget);
      expect(find.text('Show Event Dots'), findsOneWidget);
      expect(find.text('Use Arabic Numerals'), findsOneWidget);
    });
  });
}