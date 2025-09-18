import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/service_locator.dart';
import 'package:hijri_minder/services/location_service.dart';
import 'package:hijri_minder/services/settings_service.dart';
import 'package:hijri_minder/services/events_service.dart';
import 'package:hijri_minder/services/prayer_times_service.dart';

void main() {
  group('Task 4 - Service Integration Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await ServiceLocator.setupServices();
    });

    tearDownAll(() async {
      await ServiceLocator.reset();
    });

    test('should initialize all services successfully', () {
      expect(ServiceLocator.isReady, isTrue);
    });

    test('should provide access to LocationService', () {
      final locationService = ServiceLocator.locationService;
      expect(locationService, isA<LocationService>());
      
      // Test fallback location functionality
      final fallbackLocation = locationService.getFallbackLocation();
      expect(fallbackLocation['latitude'], equals(6.9271));
      expect(fallbackLocation['longitude'], equals(79.8612));
      expect(fallbackLocation['name'], equals('Colombo, Sri Lanka'));
    });

    test('should provide access to SettingsService', () {
      final settingsService = ServiceLocator.settingsService;
      expect(settingsService, isA<SettingsService>());
    });

    test('should provide access to EventsService', () {
      final eventsService = ServiceLocator.eventsService;
      expect(eventsService, isA<EventsService>());
      
      // Test basic functionality
      final importantEvents = eventsService.getImportantEvents();
      expect(importantEvents, isNotEmpty);
      expect(importantEvents.every((event) => event.isImportant), isTrue);
    });

    test('should provide access to PrayerTimesService', () {
      final prayerTimesService = ServiceLocator.prayerTimesService;
      expect(prayerTimesService, isA<PrayerTimesService>());
      
      // Test mock prayer times functionality
      final mockPrayerTimes = prayerTimesService.getMockPrayerTimes();
      expect(mockPrayerTimes.sihori, isNotEmpty);
      expect(mockPrayerTimes.fajr, isNotEmpty);
      expect(mockPrayerTimes.locationName, contains('Fallback'));
    });

    test('should provide services through extension methods', () {
      final testObject = Object();
      
      expect(testObject.locationService, isA<LocationService>());
      expect(testObject.settingsService, isA<SettingsService>());
      expect(testObject.eventsService, isA<EventsService>());
      expect(testObject.prayerTimesService, isA<PrayerTimesService>());
    });

    test('should handle service interactions correctly', () async {
      // Test interaction between LocationService and PrayerTimesService
      final locationService = ServiceLocator.locationService;
      final prayerTimesService = ServiceLocator.prayerTimesService;
      
      final location = await locationService.getBestAvailableLocation();
      expect(location, isA<Map<String, dynamic>>());
      
      final bestLocation = await prayerTimesService.getBestAvailableLocation();
      expect(bestLocation, isA<Map<String, dynamic>>());
      expect(bestLocation.containsKey('latitude'), isTrue);
      expect(bestLocation.containsKey('longitude'), isTrue);
    });

    test('should handle EventsService and date-based queries', () {
      final eventsService = ServiceLocator.eventsService;
      
      // Test Eid al-Fitr (1st Shawwal)
      final eidEvents = eventsService.getEventsForDate(1, 10);
      expect(eidEvents, isNotEmpty);
      expect(eidEvents.any((event) => event.title == 'Eid al-Fitr'), isTrue);
      
      // Test search functionality
      final searchResults = eventsService.searchEvents('Eid');
      expect(searchResults, isNotEmpty);
      expect(searchResults.every((event) => 
        event.title.toLowerCase().contains('eid') ||
        event.description.toLowerCase().contains('eid') ||
        event.category.toLowerCase().contains('eid')
      ), isTrue);
    });

    test('should verify all required service methods are implemented', () {
      final locationService = ServiceLocator.locationService;
      final settingsService = ServiceLocator.settingsService;
      final eventsService = ServiceLocator.eventsService;
      final prayerTimesService = ServiceLocator.prayerTimesService;

      // LocationService methods
      expect(() => locationService.getFallbackLocation(), returnsNormally);
      expect(() => locationService.calculateDistance(0, 0, 1, 1), returnsNormally);
      expect(() => locationService.getLocationName(6.9271, 79.8612), returnsNormally);

      // EventsService methods
      expect(() => eventsService.getEventsForDate(1, 1), returnsNormally);
      expect(() => eventsService.getEventsForMonth(1), returnsNormally);
      expect(() => eventsService.getImportantEvents(), returnsNormally);
      expect(() => eventsService.searchEvents('test'), returnsNormally);
      expect(() => eventsService.getEventCategories(), returnsNormally);

      // PrayerTimesService methods
      expect(() => prayerTimesService.getMockPrayerTimes(), returnsNormally);
      expect(() => prayerTimesService.clearCache(), returnsNormally);
    });
  });
}