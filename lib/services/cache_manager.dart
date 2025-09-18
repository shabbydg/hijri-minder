import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_service.dart';
import 'performance_service.dart';
import 'logging_service.dart';

/// Advanced cache manager with intelligent caching strategies
/// Provides memory and persistent caching with automatic cleanup and optimization
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final CacheService _persistentCache = CacheService();
  final PerformanceService _performanceService = PerformanceService();

  
  // Memory cache with LRU eviction
  final LinkedHashMap<String, _CacheEntry> _memoryCache = LinkedHashMap();
  static const int _maxMemoryCacheSize = 100;
  static const Duration _defaultMemoryCacheTTL = Duration(minutes: 30);
  
  // Cache statistics
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;
  
  Timer? _cleanupTimer;
  bool _initialized = false;

  /// Initialize the cache manager
  Future<void> initialize() async {
    if (_initialized) return;
    
    debugPrint('CacheManager: Initializing cache manager...');
    
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _performCleanup(),
    );
    
    // Load cache statistics
    await _loadCacheStatistics();
    
    _initialized = true;
    debugPrint('CacheManager: Cache manager initialized');
  }

  /// Get data from cache with fallback to persistent storage
  Future<T?> get<T>(
    String key, {
    T Function(Map<String, dynamic>)? fromJson,
    Duration? ttl,
  }) async {
    return await _performanceService.timeOperation(
      'cache_get',
      () async {
        // Check memory cache first
        final memoryEntry = _memoryCache[key];
        if (memoryEntry != null && !memoryEntry.isExpired) {
          _hits++;
          _moveToEnd(key); // LRU update
          debugPrint('CacheManager: Memory cache hit for key: $key');
          return memoryEntry.data as T?;
        }

        // Check persistent cache
        final persistentData = await _persistentCache.getCache(key);
        if (persistentData != null) {
          _hits++;
          final data = fromJson != null ? fromJson(persistentData) : persistentData as T?;
          
          // Store in memory cache for faster access
          _setMemoryCache(key, data, ttl ?? _defaultMemoryCacheTTL);
          
          debugPrint('CacheManager: Persistent cache hit for key: $key');
          return data;
        }

        _misses++;
        debugPrint('CacheManager: Cache miss for key: $key');
        return null;
      },
      metadata: {'key': key, 'type': 'get'},
    );
  }

  /// Set data in both memory and persistent cache
  Future<bool> set<T>(
    String key,
    T data, {
    Duration? memoryTTL,
    Duration? persistentTTL,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    return await _performanceService.timeOperation(
      'cache_set',
      () async {
        // Set in memory cache
        _setMemoryCache(key, data, memoryTTL ?? _defaultMemoryCacheTTL);
        
        // Set in persistent cache
        final jsonData = toJson != null ? toJson(data) : data as Map<String, dynamic>;
        final success = await _persistentCache.setCache(
          key,
          jsonData,
          persistentTTL ?? const Duration(days: 7),
        );
        
        debugPrint('CacheManager: Cached data for key: $key');
        return success;
      },
      metadata: {'key': key, 'type': 'set'},
    );
  }

  /// Get or compute data with caching
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() compute, {
    Duration? memoryTTL,
    Duration? persistentTTL,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    // Try to get from cache first
    final cached = await get<T>(key, fromJson: fromJson, ttl: memoryTTL);
    if (cached != null) {
      return cached;
    }

    // Compute the value
    final computed = await _performanceService.timeOperation(
      'cache_compute_$key',
      compute,
    );

    // Cache the computed value
    await set(
      key,
      computed,
      memoryTTL: memoryTTL,
      persistentTTL: persistentTTL,
      toJson: toJson,
    );

    return computed;
  }

  /// Batch get multiple keys
  Future<Map<String, T?>> batchGet<T>(
    List<String> keys, {
    T Function(Map<String, dynamic>)? fromJson,
    Duration? ttl,
  }) async {
    return await _performanceService.timeOperation(
      'cache_batch_get',
      () async {
        final results = <String, T?>{};
        
        // Process in batches to avoid overwhelming the system
        const batchSize = 10;
        for (int i = 0; i < keys.length; i += batchSize) {
          final batch = keys.skip(i).take(batchSize);
          final batchResults = await Future.wait(
            batch.map((key) => get<T>(key, fromJson: fromJson, ttl: ttl)),
          );
          
          for (int j = 0; j < batch.length; j++) {
            results[batch.elementAt(j)] = batchResults[j];
          }
        }
        
        return results;
      },
      metadata: {'keyCount': keys.length, 'type': 'batch_get'},
    );
  }

  /// Batch set multiple key-value pairs
  Future<Map<String, bool>> batchSet<T>(
    Map<String, T> data, {
    Duration? memoryTTL,
    Duration? persistentTTL,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    return await _performanceService.timeOperation(
      'cache_batch_set',
      () async {
        final results = <String, bool>{};
        
        // Process in batches
        const batchSize = 10;
        final entries = data.entries.toList();
        
        for (int i = 0; i < entries.length; i += batchSize) {
          final batch = entries.skip(i).take(batchSize);
          final batchResults = await Future.wait(
            batch.map((entry) => set(
              entry.key,
              entry.value,
              memoryTTL: memoryTTL,
              persistentTTL: persistentTTL,
              toJson: toJson,
            )),
          );
          
          for (int j = 0; j < batch.length; j++) {
            results[batch.elementAt(j).key] = batchResults[j];
          }
        }
        
        return results;
      },
      metadata: {'keyCount': data.length, 'type': 'batch_set'},
    );
  }

  /// Remove data from both caches
  Future<bool> remove(String key) async {
    _memoryCache.remove(key);
    return await _persistentCache.removeCache(key);
  }

  /// Clear all cache data
  Future<void> clear() async {
    _memoryCache.clear();
    await _persistentCache.clearAllCache();
    _hits = 0;
    _misses = 0;
    _evictions = 0;
    debugPrint('CacheManager: All cache data cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    final totalRequests = _hits + _misses;
    final hitRate = totalRequests > 0 ? (_hits / totalRequests * 100) : 0.0;
    
    return {
      'hits': _hits,
      'misses': _misses,
      'evictions': _evictions,
      'hitRate': hitRate,
      'memoryCacheSize': _memoryCache.length,
      'maxMemoryCacheSize': _maxMemoryCacheSize,
      'memoryUsagePercent': (_memoryCache.length / _maxMemoryCacheSize * 100),
    };
  }

  /// Preload cache with essential data
  Future<void> preloadCache(Map<String, Future<dynamic> Function()> loaders) async {
    debugPrint('CacheManager: Preloading cache with ${loaders.length} items...');
    
    await _performanceService.batchOperations(
      'cache_preload',
      loaders.entries.map((entry) => () async {
        try {
          final data = await entry.value();
          await set(entry.key, data);
        } catch (e) {
          LoggingService.logError(
            'Failed to preload cache for key: ${entry.key}',
            details: e.toString(),
          );
        }
      }).toList(),
      concurrency: 5, // Limit concurrent preloading
    );
    
    debugPrint('CacheManager: Cache preloading completed');
  }

  /// Warm up cache with frequently accessed data
  Future<void> warmUpCache() async {
    debugPrint('CacheManager: Warming up cache...');
    
    // This would typically load frequently accessed data
    // For now, we'll just ensure the cache is ready
    await initialize();
    
    debugPrint('CacheManager: Cache warm-up completed');
  }

  /// Set data in memory cache with LRU eviction
  void _setMemoryCache(String key, dynamic data, Duration ttl) {
    // Remove existing entry to update position
    _memoryCache.remove(key);
    
    // Add new entry
    _memoryCache[key] = _CacheEntry(data, DateTime.now().add(ttl));
    
    // Evict oldest entries if cache is full
    while (_memoryCache.length > _maxMemoryCacheSize) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
      _evictions++;
    }
  }

  /// Move cache entry to end (most recently used)
  void _moveToEnd(String key) {
    final entry = _memoryCache.remove(key);
    if (entry != null) {
      _memoryCache[key] = entry;
    }
  }

  /// Perform periodic cleanup
  Future<void> _performCleanup() async {
    debugPrint('CacheManager: Performing cache cleanup...');
    
    // Clean expired memory cache entries
    final expiredKeys = <String>[];
    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }
    
    // Clean expired persistent cache entries
    await _persistentCache.cleanExpiredCache();
    
    // Save cache statistics
    await _saveCacheStatistics();
    
    debugPrint('CacheManager: Cache cleanup completed. Removed ${expiredKeys.length} expired entries');
  }

  /// Load cache statistics from persistent storage
  Future<void> _loadCacheStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hits = prefs.getInt('cache_hits') ?? 0;
      _misses = prefs.getInt('cache_misses') ?? 0;
      _evictions = prefs.getInt('cache_evictions') ?? 0;
    } catch (e) {
      debugPrint('CacheManager: Error loading cache statistics: $e');
    }
  }

  /// Save cache statistics to persistent storage
  Future<void> _saveCacheStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cache_hits', _hits);
      await prefs.setInt('cache_misses', _misses);
      await prefs.setInt('cache_evictions', _evictions);
    } catch (e) {
      debugPrint('CacheManager: Error saving cache statistics: $e');
    }
  }

  /// Dispose of the cache manager
  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
  }
}

/// Cache entry with expiration
class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry(this.data, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Cache strategy enum
enum CacheStrategy {
  memoryOnly,
  persistentOnly,
  memoryFirst,
  persistentFirst,
  both,
}

/// Cache configuration
class CacheConfig {
  final Duration memoryTTL;
  final Duration persistentTTL;
  final CacheStrategy strategy;
  final int maxMemorySize;

  const CacheConfig({
    this.memoryTTL = const Duration(minutes: 30),
    this.persistentTTL = const Duration(days: 7),
    this.strategy = CacheStrategy.both,
    this.maxMemorySize = 100,
  });
}