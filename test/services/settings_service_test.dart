import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('SettingsService Tests', () {
    late SettingsService settingsService;

    setUp(() {
      settingsService = SettingsService();
    });

    test('should return default settings initially', () async {
      final settings = await settingsService.getSettings();
      
      expect(settings.enablePrayerNotifications, isTrue);
      expect(settings.enableAdhanSounds, isFalse);
      expect(settings.enableLocationServices, isTrue);
      expect(settings.language, equals('en'));
      expect(settings.theme, equals('light'));
      expect(settings.showGregorianDates, isTrue);
      expect(settings.showEventDots, isTrue);
      expect(settings.prayerTimeFormat, equals('12h'));
      expect(settings.prayerNotificationAdvanceMinutes, equals(10));
    });

    test('should create AppSettings from map', () {
      final map = {
        'enablePrayerNotifications': false,
        'language': 'ar',
        'theme': 'dark',
        'prayerNotificationAdvanceMinutes': 15,
      };

      final settings = AppSettings.fromMap(map);
      
      expect(settings.enablePrayerNotifications, isFalse);
      expect(settings.language, equals('ar'));
      expect(settings.theme, equals('dark'));
      expect(settings.prayerNotificationAdvanceMinutes, equals(15));
      // Should use defaults for missing values
      expect(settings.enableAdhanSounds, isFalse);
      expect(settings.showGregorianDates, isTrue);
    });

    test('should convert AppSettings to map', () {
      const settings = AppSettings(
        enablePrayerNotifications: false,
        enableAdhanSounds: true,
        enableLocationServices: false,
        language: 'ar',
        theme: 'dark',
        showGregorianDates: false,
        showEventDots: false,
        prayerTimeFormat: '24h',
        prayerNotificationAdvanceMinutes: 5,
      );

      final map = settings.toMap();
      
      expect(map['enablePrayerNotifications'], isFalse);
      expect(map['enableAdhanSounds'], isTrue);
      expect(map['enableLocationServices'], isFalse);
      expect(map['language'], equals('ar'));
      expect(map['theme'], equals('dark'));
      expect(map['showGregorianDates'], isFalse);
      expect(map['showEventDots'], isFalse);
      expect(map['prayerTimeFormat'], equals('24h'));
      expect(map['prayerNotificationAdvanceMinutes'], equals(5));
    });

    test('should create copy with updated values', () {
      const originalSettings = AppSettings.defaultSettings;
      
      final updatedSettings = originalSettings.copyWith(
        language: 'ar',
        theme: 'dark',
        enablePrayerNotifications: false,
      );
      
      expect(updatedSettings.language, equals('ar'));
      expect(updatedSettings.theme, equals('dark'));
      expect(updatedSettings.enablePrayerNotifications, isFalse);
      // Other values should remain the same
      expect(updatedSettings.enableAdhanSounds, equals(originalSettings.enableAdhanSounds));
      expect(updatedSettings.prayerTimeFormat, equals(originalSettings.prayerTimeFormat));
    });
  });
}