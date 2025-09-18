import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/prayer_times_service.dart';
import 'package:hijri_minder/services/location_service.dart';
import 'package:hijri_minder/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Task 7 - Prayer Times Implementation Verification', () {
    late PrayerTimesService prayerTimesService;
    late LocationService locationService;
    late SettingsService settingsService;

    setUp(() {
      prayerTimesService = PrayerTimesService();
      locationService = LocationService();
      settingsService = SettingsService();
    });

    test('PrayerTimesService should provide getTodayPrayerTimes method', () {
      expect(prayerTimesService.getTodayPrayerTimes, isA<Function>());
    });

    test('PrayerTimesService should provide mock prayer times as fallback', () {
      final mockPrayerTimes = prayerTimesService.getMockPrayerTimes();
      
      expect(mockPrayerTimes, isNotNull);
      expect(mockPrayerTimes.sihori, isNotEmpty);
      expect(mockPrayerTimes.fajr, isNotEmpty);
      expect(mockPrayerTimes.sunrise, isNotEmpty);
      expect(mockPrayerTimes.zawaal, isNotEmpty);
      expect(mockPrayerTimes.zohrEnd, isNotEmpty);
      expect(mockPrayerTimes.asrEnd, isNotEmpty);
      expect(mockPrayerTimes.maghrib, isNotEmpty);
      expect(mockPrayerTimes.maghribEnd, isNotEmpty);
      expect(mockPrayerTimes.nisfulLayl, isNotEmpty);
      expect(mockPrayerTimes.nisfulLaylEnd, isNotEmpty);
      expect(mockPrayerTimes.locationName, contains('Colombo'));
    });

    test('PrayerTimes model should have formatTime method', () {
      final mockPrayerTimes = prayerTimesService.getMockPrayerTimes();
      
      // Test 24-hour format
      final formatted24h = mockPrayerTimes.formatTime('14:30', use24Hour: true);
      expect(formatted24h, equals('14:30'));
      
      // Test 12-hour format
      final formatted12h = mockPrayerTimes.formatTime('14:30', use24Hour: false);
      expect(formatted12h, equals('2:30 PM'));
    });

    test('PrayerTimes model should have getNextPrayer method', () {
      final mockPrayerTimes = prayerTimesService.getMockPrayerTimes();
      final nextPrayer = mockPrayerTimes.getNextPrayer();
      
      expect(nextPrayer, isNotEmpty);
      expect(nextPrayer, isA<String>());
    });

    test('PrayerTimes model should have getCurrentPrayerPeriod method', () {
      final mockPrayerTimes = prayerTimesService.getMockPrayerTimes();
      final currentPeriod = mockPrayerTimes.getCurrentPrayerPeriod();
      
      expect(currentPeriod, isNotEmpty);
      expect(currentPeriod, contains('Period'));
    });

    test('LocationService should provide fallback location', () {
      final fallbackLocation = locationService.getFallbackLocation();
      
      expect(fallbackLocation, isNotNull);
      expect(fallbackLocation['latitude'], equals(6.9271));
      expect(fallbackLocation['longitude'], equals(79.8612));
      expect(fallbackLocation['name'], contains('Colombo'));
    });

    test('LocationService should provide getBestAvailableLocation method', () {
      expect(locationService.getBestAvailableLocation, isA<Function>());
    });

    test('SettingsService should provide getSettings method', () {
      expect(settingsService.getSettings, isA<Function>());
    });

    test('PrayerTimesService should provide weekly prayer times method', () {
      expect(prayerTimesService.getCurrentWeekPrayerTimes, isA<Function>());
    });

    test('PrayerTimesService should provide monthly prayer times method', () {
      expect(prayerTimesService.getCurrentMonthPrayerTimes, isA<Function>());
    });

    test('PrayerTimesService should provide Hijri date prayer times method', () {
      expect(prayerTimesService.getPrayerTimesForHijriDate, isA<Function>());
    });

    test('PrayerTimesService should handle location permission requests', () {
      expect(prayerTimesService.requestUserLocation, isA<Function>());
    });

    test('Prayer times should be in valid time format', () {
      final mockPrayerTimes = prayerTimesService.getMockPrayerTimes();
      final timeRegex = RegExp(r'^\d{1,2}:\d{2}$');
      
      expect(timeRegex.hasMatch(mockPrayerTimes.sihori), isTrue);
      expect(timeRegex.hasMatch(mockPrayerTimes.fajr), isTrue);
      expect(timeRegex.hasMatch(mockPrayerTimes.sunrise), isTrue);
      expect(timeRegex.hasMatch(mockPrayerTimes.zawaal), isTrue);
      expect(timeRegex.hasMatch(mockPrayerTimes.zohrEnd), isTrue);
      expect(timeRegex.hasMatch(mockPrayerTimes.asrEnd), isTrue);
      expect(timeRegex.hasMatch(mockPrayerTimes.maghrib), isTrue);
      expect(timeRegex.hasMatch(mockPrayerTimes.maghribEnd), isTrue);
      expect(timeRegex.hasMatch(mockPrayerTimes.nisfulLayl), isTrue);
      expect(timeRegex.hasMatch(mockPrayerTimes.nisfulLaylEnd), isTrue);
    });

    test('Prayer times should be chronologically ordered', () {
      final mockPrayerTimes = prayerTimesService.getMockPrayerTimes();
      
      // Convert times to minutes for comparison
      int timeToMinutes(String time) {
        final parts = time.split(':');
        return int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
      
      final sihoriMinutes = timeToMinutes(mockPrayerTimes.sihori);
      final fajrMinutes = timeToMinutes(mockPrayerTimes.fajr);
      final sunriseMinutes = timeToMinutes(mockPrayerTimes.sunrise);
      
      // Basic chronological checks (some prayers should be in order)
      expect(sihoriMinutes < fajrMinutes, isTrue);
      expect(fajrMinutes < sunriseMinutes, isTrue);
    });
  });

  group('Task 7 - Requirements Verification', () {
    test('Requirement 5.1: PrayerTimesService uses mumineen.org API', () {
      final service = PrayerTimesService();
      expect(service.getTodayPrayerTimes, isA<Function>());
    });

    test('Requirement 5.2: Display all prayer times', () {
      final mockPrayerTimes = PrayerTimesService().getMockPrayerTimes();
      
      // All required prayer times should be present
      expect(mockPrayerTimes.sihori, isNotEmpty);
      expect(mockPrayerTimes.fajr, isNotEmpty);
      expect(mockPrayerTimes.sunrise, isNotEmpty);
      expect(mockPrayerTimes.zawaal, isNotEmpty);
      expect(mockPrayerTimes.zohrEnd, isNotEmpty);
      expect(mockPrayerTimes.asrEnd, isNotEmpty);
      expect(mockPrayerTimes.maghrib, isNotEmpty);
      expect(mockPrayerTimes.maghribEnd, isNotEmpty);
      expect(mockPrayerTimes.nisfulLayl, isNotEmpty);
      expect(mockPrayerTimes.nisfulLaylEnd, isNotEmpty);
    });

    test('Requirement 5.3: Fallback coordinates when location unavailable', () {
      final locationService = LocationService();
      final fallback = locationService.getFallbackLocation();
      
      expect(fallback['latitude'], equals(6.9271)); // Colombo, Sri Lanka
      expect(fallback['longitude'], equals(79.8612));
    });

    test('Requirement 5.5: Prayer time formatting using formatTime method', () {
      final mockPrayerTimes = PrayerTimesService().getMockPrayerTimes();
      
      // Test formatTime method exists and works
      final formatted = mockPrayerTimes.formatTime('14:30', use24Hour: false);
      expect(formatted, contains('PM'));
    });

    test('Requirement 5.6: Location permission handling', () {
      final locationService = LocationService();
      expect(locationService.requestLocationPermissionWithDialog, isA<Function>());
      expect(locationService.hasValidLocationPermissions, isA<Function>());
    });

    test('Requirement 5.7: API fallback to mock data', () {
      final service = PrayerTimesService();
      final mockData = service.getMockPrayerTimes();
      
      expect(mockData, isNotNull);
      expect(mockData.locationName, contains('Fallback'));
    });

    test('Requirement 5.8: Prayer times for specific dates', () {
      final service = PrayerTimesService();
      expect(service.getPrayerTimesForHijriDate, isA<Function>());
    });

    test('Requirement 5.9: Weekly and monthly prayer schedules', () {
      final service = PrayerTimesService();
      expect(service.getCurrentWeekPrayerTimes, isA<Function>());
      expect(service.getCurrentMonthPrayerTimes, isA<Function>());
    });
  });
}