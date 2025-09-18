import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      cacheService = CacheService();
    });

    test('should cache and retrieve data', () async {
      final testData = {'test': 'value', 'number': 42};
      const testKey = 'test_key';
      const expiration = Duration(minutes: 30);

      // Cache data
      final cached = await cacheService.setCache(testKey, testData, expiration);
      expect(cached, isTrue);

      // Retrieve data
      final retrieved = await cacheService.getCache(testKey);
      expect(retrieved, equals(testData));
    });

    test('should return null for expired cache', () async {
      final testData = {'test': 'value'};
      const testKey = 'expired_key';
      const expiration = Duration(milliseconds: 1);

      // Cache data with very short expiration
      await cacheService.setCache(testKey, testData, expiration);

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 10));

      // Should return null for expired cache
      final retrieved = await cacheService.getCache(testKey);
      expect(retrieved, isNull);
    });

    test('should check cache validity', () async {
      final testData = {'test': 'value'};
      const testKey = 'validity_key';
      const expiration = Duration(minutes: 30);

      // Initially invalid
      expect(await cacheService.isCacheValid(testKey), isFalse);

      // Cache data
      await cacheService.setCache(testKey, testData, expiration);

      // Should be valid now
      expect(await cacheService.isCacheValid(testKey), isTrue);
    });

    test('should remove specific cache entry', () async {
      final testData = {'test': 'value'};
      const testKey = 'remove_key';
      const expiration = Duration(minutes: 30);

      // Cache data
      await cacheService.setCache(testKey, testData, expiration);
      expect(await cacheService.isCacheValid(testKey), isTrue);

      // Remove cache
      final removed = await cacheService.removeCache(testKey);
      expect(removed, isTrue);
      expect(await cacheService.isCacheValid(testKey), isFalse);
    });

    test('should clear all cache', () async {
      // Clear any existing cache first
      await cacheService.clearAllCache();
      
      final testData1 = {'test1': 'value1'};
      final testData2 = {'test2': 'value2'};
      const expiration = Duration(minutes: 30);

      // Cache multiple entries
      await cacheService.setCache('key1', testData1, expiration);
      await cacheService.setCache('key2', testData2, expiration);

      // Verify cache size
      final sizeBefore = await cacheService.getCacheSize();
      expect(sizeBefore, equals(2));

      // Clear all cache
      final cleared = await cacheService.clearAllCache();
      expect(cleared, isTrue);

      // Verify cache is empty
      final sizeAfter = await cacheService.getCacheSize();
      expect(sizeAfter, equals(0));
    });

    test('should cache and retrieve list data', () async {
      final testList = [
        {'id': 1, 'name': 'Item 1'},
        {'id': 2, 'name': 'Item 2'},
      ];
      const testKey = 'list_key';
      const expiration = Duration(minutes: 30);

      // Cache list
      final cached = await cacheService.setCacheList(testKey, testList, expiration);
      expect(cached, isTrue);

      // Retrieve list
      final retrieved = await cacheService.getCacheList(testKey);
      expect(retrieved, equals(testList));
    });

    test('should cache and retrieve string data', () async {
      const testString = 'Hello, World!';
      const testKey = 'string_key';
      const expiration = Duration(minutes: 30);

      // Cache string
      final cached = await cacheService.setCacheString(testKey, testString, expiration);
      expect(cached, isTrue);

      // Retrieve string
      final retrieved = await cacheService.getCacheString(testKey);
      expect(retrieved, equals(testString));
    });

    test('should clean expired cache entries', () async {
      final testData1 = {'test1': 'value1'};
      final testData2 = {'test2': 'value2'};
      const shortExpiration = Duration(milliseconds: 1);
      const longExpiration = Duration(minutes: 30);

      // Cache one entry with short expiration, one with long
      await cacheService.setCache('short_key', testData1, shortExpiration);
      await cacheService.setCache('long_key', testData2, longExpiration);

      // Wait for short expiration
      await Future.delayed(const Duration(milliseconds: 10));

      // Clean expired cache
      final cleanedCount = await cacheService.cleanExpiredCache();
      expect(cleanedCount, equals(1));

      // Verify only valid cache remains
      expect(await cacheService.isCacheValid('short_key'), isFalse);
      expect(await cacheService.isCacheValid('long_key'), isTrue);
    });
  });
}