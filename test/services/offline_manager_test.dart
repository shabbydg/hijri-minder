import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/offline_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OfflineManager', () {
    late OfflineManager offlineManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      offlineManager = OfflineManager();
    });

    tearDown(() {
      offlineManager.dispose();
    });

    test('should initialize successfully', () async {
      expect(() => offlineManager.initialize(), returnsNormally);
    });

    test('should provide offline status', () {
      expect(offlineManager.isOffline, isA<bool>());
    });

    test('should provide sync status', () {
      expect(offlineManager.isSyncing, isA<bool>());
    });

    test('should get comprehensive offline status', () async {
      await offlineManager.initialize();
      
      final status = await offlineManager.getOfflineStatus();
      
      expect(status, isA<Map<String, dynamic>>());
      expect(status.containsKey('isOnline'), isTrue);
      expect(status.containsKey('isOffline'), isTrue);
      expect(status.containsKey('isSyncing'), isTrue);
      expect(status.containsKey('isInitialized'), isTrue);
      expect(status.containsKey('totalCacheSize'), isTrue);
      expect(status.containsKey('prayerTimes'), isTrue);
      expect(status.containsKey('events'), isTrue);
      expect(status.containsKey('settings'), isTrue);
    });

    test('should clear all cache', () async {
      await offlineManager.initialize();
      expect(() => offlineManager.clearAllCache(), returnsNormally);
    });

    test('should prepare for offline mode', () async {
      await offlineManager.initialize();
      expect(() => offlineManager.prepareForOffline(), returnsNormally);
    });

    test('should get cache statistics', () async {
      await offlineManager.initialize();
      
      final stats = await offlineManager.getCacheStatistics();
      
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('totalCacheEntries'), isTrue);
      expect(stats.containsKey('expiredEntriesCleaned'), isTrue);
      expect(stats.containsKey('lastCleanup'), isTrue);
    });

    test('should force sync when online', () async {
      await offlineManager.initialize();
      expect(() => offlineManager.forcSync(), returnsNormally);
    });

    test('should dispose resources properly', () {
      expect(() => offlineManager.dispose(), returnsNormally);
    });
  });
}