import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/app_settings.dart';

void main() {
  group('AppSettings Model Tests', () {
    late AppSettings testSettings;

    setUp(() {
      testSettings = AppSettings(
        enablePrayerNotifications: true,
        enableAdhanSounds: false,
        enableLocationServices: true,
        language: 'en',
        theme: 'light',
        showGregorianDates: true,
        showEventDots: true,
        prayerTimeFormat: '24h',
        prayerNotificationAdvance: Duration(minutes: 15),
        enableReminderNotifications: true,
        enableVibration: true,
        fontSize: 16.0,
        useArabicNumerals: false,
        defaultLocation: 'Colombo, Sri Lanka',
        autoLocationUpdate: true,
      );
    });

    test('should create AppSettings with all fields', () {
      expect(testSettings.enablePrayerNotifications, true);
      expect(testSettings.enableAdhanSounds, false);
      expect(testSettings.enableLocationServices, true);
      expect(testSettings.language, 'en');
      expect(testSettings.theme, 'light');
      expect(testSettings.showGregorianDates, true);
      expect(testSettings.showEventDots, true);
      expect(testSettings.prayerTimeFormat, '24h');
      expect(testSettings.prayerNotificationAdvance, Duration(minutes: 15));
      expect(testSettings.enableReminderNotifications, true);
      expect(testSettings.enableVibration, true);
      expect(testSettings.fontSize, 16.0);
      expect(testSettings.useArabicNumerals, false);
      expect(testSettings.defaultLocation, 'Colombo, Sri Lanka');
      expect(testSettings.autoLocationUpdate, true);
    });

    test('should create default settings correctly', () {
      final defaultSettings = AppSettings.defaultSettings();
      
      expect(defaultSettings.enablePrayerNotifications, true);
      expect(defaultSettings.enableAdhanSounds, false);
      expect(defaultSettings.enableLocationServices, true);
      expect(defaultSettings.language, 'en');
      expect(defaultSettings.theme, 'light');
      expect(defaultSettings.showGregorianDates, true);
      expect(defaultSettings.showEventDots, true);
      expect(defaultSettings.prayerTimeFormat, '24h');
      expect(defaultSettings.prayerNotificationAdvance, Duration(minutes: 10));
      expect(defaultSettings.enableReminderNotifications, true);
      expect(defaultSettings.enableVibration, true);
      expect(defaultSettings.fontSize, 14.0);
      expect(defaultSettings.useArabicNumerals, false);
      expect(defaultSettings.defaultLocation, 'Colombo, Sri Lanka');
      expect(defaultSettings.autoLocationUpdate, true);
    });

    test('should serialize to JSON correctly', () {
      final json = testSettings.toJson();
      
      expect(json['enablePrayerNotifications'], true);
      expect(json['enableAdhanSounds'], false);
      expect(json['enableLocationServices'], true);
      expect(json['language'], 'en');
      expect(json['theme'], 'light');
      expect(json['showGregorianDates'], true);
      expect(json['showEventDots'], true);
      expect(json['prayerTimeFormat'], '24h');
      expect(json['prayerNotificationAdvanceMinutes'], 15);
      expect(json['enableReminderNotifications'], true);
      expect(json['enableVibration'], true);
      expect(json['fontSize'], 16.0);
      expect(json['useArabicNumerals'], false);
      expect(json['defaultLocation'], 'Colombo, Sri Lanka');
      expect(json['autoLocationUpdate'], true);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'enablePrayerNotifications': false,
        'enableAdhanSounds': true,
        'enableLocationServices': false,
        'language': 'ar',
        'theme': 'dark',
        'showGregorianDates': false,
        'showEventDots': false,
        'prayerTimeFormat': '12h',
        'prayerNotificationAdvanceMinutes': 30,
        'enableReminderNotifications': false,
        'enableVibration': false,
        'fontSize': 18.0,
        'useArabicNumerals': true,
        'defaultLocation': 'Mecca, Saudi Arabia',
        'autoLocationUpdate': false,
      };

      final settings = AppSettings.fromJson(json);
      
      expect(settings.enablePrayerNotifications, false);
      expect(settings.enableAdhanSounds, true);
      expect(settings.enableLocationServices, false);
      expect(settings.language, 'ar');
      expect(settings.theme, 'dark');
      expect(settings.showGregorianDates, false);
      expect(settings.showEventDots, false);
      expect(settings.prayerTimeFormat, '12h');
      expect(settings.prayerNotificationAdvance, Duration(minutes: 30));
      expect(settings.enableReminderNotifications, false);
      expect(settings.enableVibration, false);
      expect(settings.fontSize, 18.0);
      expect(settings.useArabicNumerals, true);
      expect(settings.defaultLocation, 'Mecca, Saudi Arabia');
      expect(settings.autoLocationUpdate, false);
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      final settings = AppSettings.fromJson(json);
      
      expect(settings.enablePrayerNotifications, true);
      expect(settings.enableAdhanSounds, false);
      expect(settings.language, 'en');
      expect(settings.theme, 'light');
      expect(settings.prayerTimeFormat, '24h');
      expect(settings.prayerNotificationAdvance, Duration(minutes: 10));
      expect(settings.fontSize, 14.0);
    });

    test('should get supported languages correctly', () {
      final languages = AppSettings.getSupportedLanguages();
      
      expect(languages, contains('en'));
      expect(languages, contains('ar'));
      expect(languages, contains('id'));
      expect(languages, contains('ur'));
      expect(languages, contains('ms'));
      expect(languages, contains('tr'));
      expect(languages, contains('fa'));
      expect(languages, contains('bn'));
      expect(languages.length, 8);
    });

    test('should get language display name correctly', () {
      expect(testSettings.getLanguageDisplayName(), 'English');
      
      final arabicSettings = testSettings.copyWith(language: 'ar');
      expect(arabicSettings.getLanguageDisplayName(), 'العربية');
      
      final indonesianSettings = testSettings.copyWith(language: 'id');
      expect(indonesianSettings.getLanguageDisplayName(), 'Bahasa Indonesia');
      
      final urduSettings = testSettings.copyWith(language: 'ur');
      expect(urduSettings.getLanguageDisplayName(), 'اردو');
      
      final malaySettings = testSettings.copyWith(language: 'ms');
      expect(malaySettings.getLanguageDisplayName(), 'Bahasa Melayu');
      
      final turkishSettings = testSettings.copyWith(language: 'tr');
      expect(turkishSettings.getLanguageDisplayName(), 'Türkçe');
      
      final persianSettings = testSettings.copyWith(language: 'fa');
      expect(persianSettings.getLanguageDisplayName(), 'فارسی');
      
      final bengaliSettings = testSettings.copyWith(language: 'bn');
      expect(bengaliSettings.getLanguageDisplayName(), 'বাংলা');
      
      final unknownSettings = testSettings.copyWith(language: 'unknown');
      expect(unknownSettings.getLanguageDisplayName(), 'English');
    });

    test('should get supported themes correctly', () {
      final themes = AppSettings.getSupportedThemes();
      
      expect(themes, contains('light'));
      expect(themes, contains('dark'));
      expect(themes, contains('system'));
      expect(themes.length, 3);
    });

    test('should get theme display name correctly', () {
      expect(testSettings.getThemeDisplayName(), 'Light');
      
      final darkSettings = testSettings.copyWith(theme: 'dark');
      expect(darkSettings.getThemeDisplayName(), 'Dark');
      
      final systemSettings = testSettings.copyWith(theme: 'system');
      expect(systemSettings.getThemeDisplayName(), 'System');
      
      final unknownSettings = testSettings.copyWith(theme: 'unknown');
      expect(unknownSettings.getThemeDisplayName(), 'Light');
    });

    test('should get supported time formats correctly', () {
      final formats = AppSettings.getSupportedTimeFormats();
      
      expect(formats, contains('12h'));
      expect(formats, contains('24h'));
      expect(formats.length, 2);
    });

    test('should check 24-hour format correctly', () {
      expect(testSettings.is24HourFormat(), true);
      
      final twelveHourSettings = testSettings.copyWith(prayerTimeFormat: '12h');
      expect(twelveHourSettings.is24HourFormat(), false);
    });

    test('should check RTL language correctly', () {
      expect(testSettings.isRTLLanguage(), false);
      
      final arabicSettings = testSettings.copyWith(language: 'ar');
      expect(arabicSettings.isRTLLanguage(), true);
      
      final urduSettings = testSettings.copyWith(language: 'ur');
      expect(urduSettings.isRTLLanguage(), true);
      
      final persianSettings = testSettings.copyWith(language: 'fa');
      expect(persianSettings.isRTLLanguage(), true);
      
      final indonesianSettings = testSettings.copyWith(language: 'id');
      expect(indonesianSettings.isRTLLanguage(), false);
    });

    test('should validate settings correctly', () {
      expect(testSettings.isValid(), true);
      
      // Invalid language
      final invalidLanguage = testSettings.copyWith(language: 'invalid');
      expect(invalidLanguage.isValid(), false);
      
      // Invalid theme
      final invalidTheme = testSettings.copyWith(theme: 'invalid');
      expect(invalidTheme.isValid(), false);
      
      // Invalid time format
      final invalidTimeFormat = testSettings.copyWith(prayerTimeFormat: 'invalid');
      expect(invalidTimeFormat.isValid(), false);
      
      // Invalid font size (too small)
      final invalidFontSizeSmall = testSettings.copyWith(fontSize: 5.0);
      expect(invalidFontSizeSmall.isValid(), false);
      
      // Invalid font size (too large)
      final invalidFontSizeLarge = testSettings.copyWith(fontSize: 30.0);
      expect(invalidFontSizeLarge.isValid(), false);
      
      // Invalid notification advance (negative)
      final invalidNotificationNegative = testSettings.copyWith(
        prayerNotificationAdvance: Duration(minutes: -5)
      );
      expect(invalidNotificationNegative.isValid(), false);
      
      // Invalid notification advance (too large)
      final invalidNotificationLarge = testSettings.copyWith(
        prayerNotificationAdvance: Duration(minutes: 70)
      );
      expect(invalidNotificationLarge.isValid(), false);
    });

    test('should create copy with updated fields correctly', () {
      final updatedSettings = testSettings.copyWith(
        language: 'ar',
        theme: 'dark',
        enablePrayerNotifications: false,
        fontSize: 18.0,
      );
      
      expect(updatedSettings.language, 'ar');
      expect(updatedSettings.theme, 'dark');
      expect(updatedSettings.enablePrayerNotifications, false);
      expect(updatedSettings.fontSize, 18.0);
      
      // Other fields should remain the same
      expect(updatedSettings.enableAdhanSounds, testSettings.enableAdhanSounds);
      expect(updatedSettings.enableLocationServices, testSettings.enableLocationServices);
      expect(updatedSettings.showGregorianDates, testSettings.showGregorianDates);
      expect(updatedSettings.prayerTimeFormat, testSettings.prayerTimeFormat);
    });

    test('should implement equality correctly', () {
      final settings1 = AppSettings(
        language: 'en',
        theme: 'light',
        enablePrayerNotifications: true,
        fontSize: 14.0,
      );

      final settings2 = AppSettings(
        language: 'en',
        theme: 'light',
        enablePrayerNotifications: true,
        fontSize: 14.0,
      );

      final settings3 = AppSettings(
        language: 'ar',
        theme: 'light',
        enablePrayerNotifications: true,
        fontSize: 14.0,
      );

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('should have proper toString representation', () {
      final string = testSettings.toString();
      expect(string, contains('AppSettings'));
      expect(string, contains('language: en'));
      expect(string, contains('theme: light'));
      expect(string, contains('prayerNotifications: true'));
    });
  });
}