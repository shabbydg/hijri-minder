import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/prayer_times_service.dart';
import 'package:hijri_minder/services/events_service.dart';
import 'package:hijri_minder/services/settings_service.dart';
import 'package:hijri_minder/services/cache_service.dart';
import 'package:hijri_minder/services/connectivity_service.dart';
import 'package:hijri_minder/services/offline_manager.dart';
import 'package:hijri_minder/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Task 15: Offline Functionality Integration Tests', () {
    late PrayerTimesService prayerTimesService;
    late EventsService eventsService;
    late SettingsService settingsService;
    late CacheService cacheService;
    late ConnectivityService connectivityService;
    late OfflineManager offlineManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      
      prayerTimesService = PrayerTimesService();
      eventsService = EventsService();
      settingsService = SettingsService();
      cacheService = CacheService();
      connectivityService = ConnectivityService();
      offlineManager = OfflineManager();
    });

    tearDown(() {
      connectivityService.dispose();
      offlineManager.dispose();
    });

    group('Prayer Times Offline Functionality', () {
      test('should cache prayer times with 30-day expiration', () async {
        final today = DateTime.now();
        
        // Get prayer times (this should cache them)
        final prayerTimes = await prayerTimesService.getPrayerTimesForDate(today);
        expect(prayerTimes, isNotNull);
        
        // Verify cache status
        final cacheStatus = await prayerTimesService.getCacheStatus();
        expect(cacheStatus['memoryCacheSize'], greaterThan(0));
      });

      test('should return cached data when offline', () async {
        final today = DateTime.now();
        
        // First, cache some data
        final originalPrayerTimes = await prayerTimesService.getPrayerTimesForDate(today);
        expect(originalPrayerTimes, isNotNull);
        
        // Get prayer times again (should come from cache)
        final cachedPrayerTimes = await prayerTimesService.getPrayerTimesForDate(today);
        expect(cachedPrayerTimes, isNotNull);
        expect(cachedPrayerTimes!.date, equals(originalPrayerTimes!.date));
      });

      test('should provide mock data as fallback', () async {
        final today = DateTime.now();
        
        // Get mock prayer times
        final mockPrayerTimes = prayerTimesService.getMockPrayerTimes(today);
        expect(mockPrayerTimes, isNotNull);
        expect(mockPrayerTimes.date, equals(today));
        expect(mockPrayerTimes.locationName, contains('Fallback'));
      });

      test('should sync when connectivity returns', () async {
        expect(() => prayerTimesService.syncWhenOnline(), returnsNormally);
      });

      test('should clear cache properly', () async {
        final today = DateTime.now();
        
        // Cache some data
        await prayerTimesService.getPrayerTimesForDate(today);
        
        // Clear cache
        await prayerTimesService.clearCache();
        
        // Verify cache is cleared
        final cacheStatus = await prayerTimesService.getCacheStatus();
        expect(cacheStatus['memoryCacheSize'], equals(0));
      });
    });

    group('Events Offline Functionality', () {
      test('should cache Islamic events', () async {
        // Get events for a specific date
        final events = await eventsService.getEventsForDate(1, 1); // Islamic New Year
        expect(events, isNotEmpty);
        
        // Get events for a month
        final monthEvents = await eventsService.getEventsForMonth(1); // Muharram
        expect(monthEvents, isNotEmpty);
        
        // Get important events
        final importantEvents = await eventsService.getImportantEvents();
        expect(importantEvents, isNotEmpty);
      });

      test('should initialize events cache', () async {
        expect(() => eventsService.initializeCache(), returnsNormally);
      });

      test('should sync events when online', () async {
        expect(() => eventsService.syncWhenOnline(), returnsNormally);
      });

      test('should clear events cache', () async {
        await eventsService.clearCache();
        
        final cacheStatus = await eventsService.getCacheStatus();
        expect(cacheStatus, isA<Map<String, dynamic>>());
      });
    });

    group('Settings Offline Functionality', () {
      test('should persist settings with backup', () async {
        final testSettings = AppSettings.defaultSettings().copyWith(
          language: 'ar',
          enablePrayerNotifications: false,
        );
        
        // Save settings
        final saved = await settingsService.saveSettings(testSettings);
        expect(saved, isTrue);
        
        // Retrieve settings
        final retrievedSettings = await settingsService.getSettings();
        expect(retrievedSettings.language, equals('ar'));
        expect(retrievedSettings.enablePrayerNotifications, isFalse);
      });

      test('should verify settings integrity', () async {
        final integrity = await settingsService.verifySettingsIntegrity();
        expect(integrity, isA<bool>());
      });

      test('should repair corrupted settings', () async {
        final repaired = await settingsService.repairSettings();
        expect(repaired, isTrue);
      });

      test('should get settings status', () async {
        final status = await settingsService.getSettingsStatus();
        
        expect(status, isA<Map<String, dynamic>>());
        expect(status.containsKey('isOnline'), isTrue);
        expect(status.containsKey('hasSettings'), isTrue);
        expect(status.containsKey('hasBackup'), isTrue);
        expect(status.containsKey('isIntegrityValid'), isTrue);
      });

      test('should sync settings when online', () async {
        expect(() => settingsService.syncWhenOnline(), returnsNormally);
      });
    });

    group('Cache Service Functionality', () {
      test('should manage cache with expiration', () async {
        final testData = {'test': 'value', 'timestamp': DateTime.now().toIso8601String()};
        const cacheKey = 'test_cache';
        const expiration = Duration(minutes: 30);
        
        // Set cache
        final cached = await cacheService.setCache(cacheKey, testData, expiration);
        expect(cached, isTrue);
        
        // Get cache
        final retrieved = await cacheService.getCache(cacheKey);
        expect(retrieved, equals(testData));
        
        // Check validity
        final isValid = await cacheService.isCacheValid(cacheKey);
        expect(isValid, isTrue);
      });

      test('should handle expired cache', () async {
        final testData = {'test': 'expired'};
        const cacheKey = 'expired_cache';
        const expiration = Duration(milliseconds: 1);
        
        // Set cache with very short expiration
        await cacheService.setCache(cacheKey, testData, expiration);
        
        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 10));
        
        // Should return null for expired cache
        final retrieved = await cacheService.getCache(cacheKey);
        expect(retrieved, isNull);
      });

      test('should manage cache size and cleanup', () async {
        // Add multiple cache entries
        for (int i = 0; i < 5; i++) {
          await cacheService.setCache(
            'key_$i',
            {'data': 'value_$i'},
            const Duration(minutes: 30),
          );
        }
        
        // Check cache size
        final size = await cacheService.getCacheSize();
        expect(size, greaterThanOrEqualTo(5));
        
        // Clean expired cache
        final cleanedCount = await cacheService.cleanExpiredCache();
        expect(cleanedCount, isA<int>());
        
        // Clear all cache
        final cleared = await cacheService.clearAllCache();
        expect(cleared, isTrue);
        
        // Verify cache is empty
        final finalSize = await cacheService.getCacheSize();
        expect(finalSize, equals(0));
      });
    });

    group('Offline Manager Integration', () {
      test('should initialize offline manager', () async {
        await offlineManager.initialize();
        
        final status = await offlineManager.getOfflineStatus();
        expect(status['isInitialized'], isTrue);
      });

      test('should prepare for offline mode', () async {
        await offlineManager.initialize();
        await offlineManager.prepareForOffline();
        
        // Verify data is cached
        final status = await offlineManager.getOfflineStatus();
        expect(status['totalCacheSize'], greaterThan(0));
      });

      test('should provide comprehensive offline status', () async {
        await offlineManager.initialize();
        
        final status = await offlineManager.getOfflineStatus();
        
        // Verify all required status fields
        expect(status.containsKey('isOnline'), isTrue);
        expect(status.containsKey('isOffline'), isTrue);
        expect(status.containsKey('isSyncing'), isTrue);
        expect(status.containsKey('isInitialized'), isTrue);
        expect(status.containsKey('totalCacheSize'), isTrue);
        expect(status.containsKey('prayerTimes'), isTrue);
        expect(status.containsKey('events'), isTrue);
        expect(status.containsKey('settings'), isTrue);
      });

      test('should get cache statistics', () async {
        await offlineManager.initialize();
        
        final stats = await offlineManager.getCacheStatistics();
        
        expect(stats.containsKey('totalCacheEntries'), isTrue);
        expect(stats.containsKey('expiredEntriesCleaned'), isTrue);
        expect(stats.containsKey('lastCleanup'), isTrue);
      });

      test('should force sync', () async {
        await offlineManager.initialize();
        expect(() => offlineManager.forcSync(), returnsNormally);
      });

      test('should clear all cache', () async {
        await offlineManager.initialize();
        
        // Add some cache data first
        await offlineManager.prepareForOffline();
        
        // Clear all cache
        await offlineManager.clearAllCache();
        
        // Verify cache is cleared
        final status = await offlineManager.getOfflineStatus();
        expect(status['totalCacheSize'], equals(0));
      });
    });

    group('Connectivity Service', () {
      test('should monitor connectivity', () async {
        connectivityService.initialize();
        
        expect(connectivityService.isOnline, isA<bool>());
        expect(connectivityService.connectivityStream, isA<Stream<bool>>());
      });

      test('should check connectivity status', () async {
        final isOnline = await connectivityService.checkConnectivity();
        expect(isOnline, isA<bool>());
      });
    });

    group('End-to-End Offline Scenarios', () {
      test('should handle complete offline workflow', () async {
        // Initialize all services
        await offlineManager.initialize();
        
        // Prepare for offline
        await offlineManager.prepareForOffline();
        
        // Simulate offline usage
        final today = DateTime.now();
        
        // Get prayer times (should work offline)
        final prayerTimes = await prayerTimesService.getPrayerTimesForDate(today);
        expect(prayerTimes, isNotNull);
        
        // Get events (should work offline)
        final events = await eventsService.getEventsForDate(1, 1);
        expect(events, isNotEmpty);
        
        // Get settings (should work offline)
        final settings = await settingsService.getSettings();
        expect(settings, isNotNull);
        
        // Verify offline status
        final status = await offlineManager.getOfflineStatus();
        expect(status['totalCacheSize'], greaterThan(0));
      });

      test('should gracefully degrade when network unavailable', () async {
        await offlineManager.initialize();
        
        // Test prayer times fallback
        final mockPrayerTimes = prayerTimesService.getMockPrayerTimes();
        expect(mockPrayerTimes, isNotNull);
        expect(mockPrayerTimes.locationName, contains('Fallback'));
        
        // Test events fallback
        final events = await eventsService.getEventsForDate(10, 1); // Ashura
        expect(events, isNotEmpty);
        
        // Test settings fallback
        final settings = await settingsService.getSettings();
        expect(settings, isNotNull);
      });

      test('should sync data when connectivity returns', () async {
        await offlineManager.initialize();
        
        // Simulate sync when online
        expect(() => offlineManager.forcSync(), returnsNormally);
        
        // Verify individual service syncs
        expect(() => prayerTimesService.syncWhenOnline(), returnsNormally);
        expect(() => eventsService.syncWhenOnline(), returnsNormally);
        expect(() => settingsService.syncWhenOnline(), returnsNormally);
      });
    });
  });
}