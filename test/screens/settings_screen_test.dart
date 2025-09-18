import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/models/app_settings.dart';

void main() {
  group('AppSettings Model Tests', () {
    test('should create default settings', () {
      // Act
      final settings = AppSettings.defaultSettings();

      // Assert
      expect(settings.enablePrayerNotifications, true);
      expect(settings.enableAdhanSounds, false);
      expect(settings.enableLocationServices, true);
      expect(settings.language, 'en');
      expect(settings.theme, 'light');
      expect(settings.showGregorianDates, true);
      expect(settings.showEventDots, true);
      expect(settings.prayerTimeFormat, '24h');
      expect(settings.prayerNotificationAdvance.inMinutes, 10);
    });

    test('should create settings from JSON', () {
      // Arrange
      final json = {
        'enablePrayerNotifications': false,
        'enableAdhanSounds': true,
        'language': 'ar',
        'theme': 'dark',
        'prayerTimeFormat': '12h',
        'prayerNotificationAdvanceMinutes': 15,
      };

      // Act
      final settings = AppSettings.fromJson(json);

      // Assert
      expect(settings.enablePrayerNotifications, false);
      expect(settings.enableAdhanSounds, true);
      expect(settings.language, 'ar');
      expect(settings.theme, 'dark');
      expect(settings.prayerTimeFormat, '12h');
      expect(settings.prayerNotificationAdvance.inMinutes, 15);
    });

    test('should convert settings to JSON', () {
      // Arrange
      final settings = AppSettings.defaultSettings().copyWith(
        enablePrayerNotifications: false,
        language: 'ar',
        theme: 'dark',
      );

      // Act
      final json = settings.toJson();

      // Assert
      expect(json['enablePrayerNotifications'], false);
      expect(json['language'], 'ar');
      expect(json['theme'], 'dark');
      expect(json['prayerNotificationAdvanceMinutes'], 10);
    });

    test('should get supported languages', () {
      // Act
      final languages = AppSettings.getSupportedLanguages();

      // Assert
      expect(languages, contains('en'));
      expect(languages, contains('ar'));
      expect(languages, contains('id'));
      expect(languages, contains('ur'));
      expect(languages.length, greaterThan(5));
    });

    test('should get language display names', () {
      // Arrange
      final englishSettings = AppSettings.defaultSettings().copyWith(language: 'en');
      final arabicSettings = AppSettings.defaultSettings().copyWith(language: 'ar');

      // Act & Assert
      expect(englishSettings.getLanguageDisplayName(), 'English');
      expect(arabicSettings.getLanguageDisplayName(), 'العربية');
    });

    test('should get supported themes', () {
      // Act
      final themes = AppSettings.getSupportedThemes();

      // Assert
      expect(themes, contains('light'));
      expect(themes, contains('dark'));
      expect(themes, contains('system'));
    });

    test('should get theme display names', () {
      // Arrange
      final lightSettings = AppSettings.defaultSettings().copyWith(theme: 'light');
      final darkSettings = AppSettings.defaultSettings().copyWith(theme: 'dark');

      // Act & Assert
      expect(lightSettings.getThemeDisplayName(), 'Light');
      expect(darkSettings.getThemeDisplayName(), 'Dark');
    });

    test('should check if 24-hour format is enabled', () {
      // Arrange
      final format24h = AppSettings.defaultSettings().copyWith(prayerTimeFormat: '24h');
      final format12h = AppSettings.defaultSettings().copyWith(prayerTimeFormat: '12h');

      // Act & Assert
      expect(format24h.is24HourFormat(), true);
      expect(format12h.is24HourFormat(), false);
    });

    test('should check if language is RTL', () {
      // Arrange
      final arabicSettings = AppSettings.defaultSettings().copyWith(language: 'ar');
      final englishSettings = AppSettings.defaultSettings().copyWith(language: 'en');

      // Act & Assert
      expect(arabicSettings.isRTLLanguage(), true);
      expect(englishSettings.isRTLLanguage(), false);
    });

    test('should validate settings', () {
      // Arrange
      final validSettings = AppSettings.defaultSettings();
      final invalidSettings = AppSettings.defaultSettings().copyWith(
        language: 'invalid',
        fontSize: 5.0, // Too small
      );

      // Act & Assert
      expect(validSettings.isValid(), true);
      expect(invalidSettings.isValid(), false);
    });

    test('should create copy with updated fields', () {
      // Arrange
      final originalSettings = AppSettings.defaultSettings();

      // Act
      final updatedSettings = originalSettings.copyWith(
        enablePrayerNotifications: false,
        language: 'ar',
        theme: 'dark',
      );

      // Assert
      expect(updatedSettings.enablePrayerNotifications, false);
      expect(updatedSettings.language, 'ar');
      expect(updatedSettings.theme, 'dark');
      // Other fields should remain unchanged
      expect(updatedSettings.enableLocationServices, originalSettings.enableLocationServices);
      expect(updatedSettings.showGregorianDates, originalSettings.showGregorianDates);
    });

    test('should handle equality correctly', () {
      // Arrange
      final settings1 = AppSettings.defaultSettings();
      final settings2 = AppSettings.defaultSettings();
      final settings3 = AppSettings.defaultSettings().copyWith(language: 'ar');

      // Act & Assert
      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('should generate consistent hash codes', () {
      // Arrange
      final settings1 = AppSettings.defaultSettings();
      final settings2 = AppSettings.defaultSettings();

      // Act & Assert
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('should have meaningful toString representation', () {
      // Arrange
      final settings = AppSettings.defaultSettings();

      // Act
      final stringRepresentation = settings.toString();

      // Assert
      expect(stringRepresentation, contains('AppSettings'));
      expect(stringRepresentation, contains('language: en'));
      expect(stringRepresentation, contains('theme: light'));
    });
  });
}