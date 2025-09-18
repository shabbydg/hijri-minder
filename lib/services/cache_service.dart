import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Service for managing cached data with expiration
/// Provides methods for storing, retrieving, and managing cached data
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Store data in cache with expiration
  Future<bool> setCache(String key, Map<String, dynamic> data, Duration expiration) async {
    await _initPrefs();
    
    try {
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiration': expiration.inMilliseconds,
      };
      
      final String cacheJson = json.encode(cacheData);
      await _prefs!.setString('cache_$key', cacheJson);
      
      debugPrint('CacheService: Cached data for key: $key');
      return true;
    } catch (e) {
      debugPrint('CacheService: Error caching data for key $key: $e');
      return false;
    }
  }

  /// Retrieve data from cache if not expired
  Future<Map<String, dynamic>?> getCache(String key) async {
    await _initPrefs();
    
    try {
      final String? cacheJson = _prefs!.getString('cache_$key');
      if (cacheJson == null) {
        return null;
      }

      final Map<String, dynamic> cacheData = json.decode(cacheJson);
      final int timestamp = cacheData['timestamp'];
      final int expiration = cacheData['expiration'];
      
      final DateTime cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final DateTime expiryTime = cacheTime.add(Duration(milliseconds: expiration));
      
      if (DateTime.now().isAfter(expiryTime)) {
        // Cache expired, remove it
        await removeCache(key);
        debugPrint('CacheService: Cache expired for key: $key');
        return null;
      }

      debugPrint('CacheService: Retrieved cached data for key: $key');
      return cacheData['data'];
    } catch (e) {
      debugPrint('CacheService: Error retrieving cache for key $key: $e');
      return null;
    }
  }

  /// Check if cache exists and is valid
  Future<bool> isCacheValid(String key) async {
    final cachedData = await getCache(key);
    return cachedData != null;
  }

  /// Remove specific cache entry
  Future<bool> removeCache(String key) async {
    await _initPrefs();
    
    try {
      await _prefs!.remove('cache_$key');
      debugPrint('CacheService: Removed cache for key: $key');
      return true;
    } catch (e) {
      debugPrint('CacheService: Error removing cache for key $key: $e');
      return false;
    }
  }

  /// Clear all cached data
  Future<bool> clearAllCache() async {
    await _initPrefs();
    
    try {
      final keys = _prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();
      for (final key in keys) {
        await _prefs!.remove(key);
      }
      
      debugPrint('CacheService: Cleared all cached data (${keys.length} entries)');
      return true;
    } catch (e) {
      debugPrint('CacheService: Error clearing all cache: $e');
      return false;
    }
  }

  /// Get cache size (number of cached entries)
  Future<int> getCacheSize() async {
    await _initPrefs();
    
    try {
      final keys = _prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();
      return keys.length;
    } catch (e) {
      debugPrint('CacheService: Error getting cache size: $e');
      return 0;
    }
  }

  /// Clean expired cache entries
  Future<int> cleanExpiredCache() async {
    await _initPrefs();
    
    try {
      final keys = _prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();
      int cleanedCount = 0;
      
      for (final key in keys) {
        final cacheKey = key.substring(6); // Remove 'cache_' prefix
        final cachedData = await getCache(cacheKey);
        if (cachedData == null) {
          cleanedCount++;
        }
      }
      
      debugPrint('CacheService: Cleaned $cleanedCount expired cache entries');
      return cleanedCount;
    } catch (e) {
      debugPrint('CacheService: Error cleaning expired cache: $e');
      return 0;
    }
  }

  /// Store list data in cache
  Future<bool> setCacheList(String key, List<Map<String, dynamic>> dataList, Duration expiration) async {
    return await setCache(key, {'list': dataList}, expiration);
  }

  /// Retrieve list data from cache
  Future<List<Map<String, dynamic>>?> getCacheList(String key) async {
    final cachedData = await getCache(key);
    if (cachedData != null && cachedData.containsKey('list')) {
      return List<Map<String, dynamic>>.from(cachedData['list']);
    }
    return null;
  }

  /// Store string data in cache
  Future<bool> setCacheString(String key, String data, Duration expiration) async {
    return await setCache(key, {'string': data}, expiration);
  }

  /// Retrieve string data from cache
  Future<String?> getCacheString(String key) async {
    final cachedData = await getCache(key);
    if (cachedData != null && cachedData.containsKey('string')) {
      return cachedData['string'];
    }
    return null;
  }
}