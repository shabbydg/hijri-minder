import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/performance_service.dart';
import '../services/logging_service.dart';

/// Memory management utility for optimizing app performance
/// Provides methods for monitoring and managing memory usage
class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  final PerformanceService _performanceService = PerformanceService();

  
  // Memory monitoring
  Timer? _memoryMonitorTimer;
  final Queue<MemorySnapshot> _memoryHistory = Queue();
  static const int _maxHistorySize = 100;
  
  // Cache management
  final Map<String, _CachePool> _cachePools = {};
  
  bool _initialized = false;

  /// Initialize memory manager
  Future<void> initialize() async {
    if (_initialized) return;
    
    debugPrint('MemoryManager: Initializing memory management...');
    
    // Start memory monitoring in debug mode
    if (kDebugMode) {
      _memoryMonitorTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _monitorMemoryUsage(),
      );
    }
    
    _initialized = true;
    debugPrint('MemoryManager: Memory management initialized');
  }

  /// Monitor memory usage and log warnings if needed
  void _monitorMemoryUsage() {
    _performanceService.timeSync('memory_monitoring', () {
      // Get current memory info (platform-specific)
      _getCurrentMemoryUsage().then((memoryInfo) {
        final snapshot = MemorySnapshot(
          timestamp: DateTime.now(),
          usedMemoryMB: memoryInfo['used'] ?? 0,
          availableMemoryMB: memoryInfo['available'] ?? 0,
          totalMemoryMB: memoryInfo['total'] ?? 0,
        );
        
        _memoryHistory.add(snapshot);
        
        // Keep only recent history
        while (_memoryHistory.length > _maxHistorySize) {
          _memoryHistory.removeFirst();
        }
        
        // Check for memory pressure
        _checkMemoryPressure(snapshot);
      });
    });
  }

  /// Get current memory usage (platform-specific implementation)
  Future<Map<String, double>> _getCurrentMemoryUsage() async {
    try {
      // This would typically use platform channels to get actual memory info
      // For now, return mock data
      return {
        'used': 150.0, // MB
        'available': 350.0, // MB
        'total': 500.0, // MB
      };
    } catch (e) {
      return {
        'used': 0.0,
        'available': 0.0,
        'total': 0.0,
      };
    }
  }

  /// Check for memory pressure and take action if needed
  void _checkMemoryPressure(MemorySnapshot snapshot) {
    final usagePercent = (snapshot.usedMemoryMB / snapshot.totalMemoryMB) * 100;
    
    if (usagePercent > 80) {
      LoggingService.logWarning(
        'High memory usage detected',
        details: 'Memory usage: ${usagePercent.toStringAsFixed(1)}%',
        context: {
          'usedMB': snapshot.usedMemoryMB,
          'totalMB': snapshot.totalMemoryMB,
        },
      );
      
      // Trigger aggressive cleanup
      performAggressiveCleanup();
    } else if (usagePercent > 60) {
      // Trigger gentle cleanup
      performGentleCleanup();
    }
  }

  /// Create a managed cache pool for specific data types
  CachePool<T> createCachePool<T>(
    String poolName, {
    int maxSize = 100,
    Duration defaultTTL = const Duration(minutes: 30),
  }) {
    final pool = _CachePool<T>(
      name: poolName,
      maxSize: maxSize,
      defaultTTL: defaultTTL,
      memoryManager: this,
    );
    
    _cachePools[poolName] = pool;
    return pool;
  }

  /// Get existing cache pool
  CachePool<T>? getCachePool<T>(String poolName) {
    return _cachePools[poolName] as CachePool<T>?;
  }

  /// Perform gentle memory cleanup
  void performGentleCleanup() {
    debugPrint('MemoryManager: Performing gentle cleanup...');
    
    _performanceService.timeSync('gentle_memory_cleanup', () {
      // Clean expired cache entries
      for (final pool in _cachePools.values) {
        pool._cleanExpired();
      }
      
      // Suggest garbage collection
      if (kDebugMode) {
        SystemChannels.platform.invokeMethod('System.gc');
      }
    });
  }

  /// Perform aggressive memory cleanup
  void performAggressiveCleanup() {
    debugPrint('MemoryManager: Performing aggressive cleanup...');
    
    _performanceService.timeSync('aggressive_memory_cleanup', () {
      // Clear all cache pools
      for (final pool in _cachePools.values) {
        pool._clearOldest(pool._maxSize ~/ 2); // Clear half of each pool
      }
      
      // Force garbage collection
      if (kDebugMode) {
        SystemChannels.platform.invokeMethod('System.gc');
      }
    });
  }

  /// Get memory statistics
  Map<String, dynamic> getMemoryStats() {
    if (_memoryHistory.isEmpty) {
      return {'message': 'No memory data available'};
    }

    final latest = _memoryHistory.last;
    final usagePercent = (latest.usedMemoryMB / latest.totalMemoryMB) * 100;
    
    return {
      'currentUsageMB': latest.usedMemoryMB,
      'totalMemoryMB': latest.totalMemoryMB,
      'usagePercent': usagePercent,
      'availableMemoryMB': latest.availableMemoryMB,
      'cachePoolsCount': _cachePools.length,
      'totalCachedItems': _cachePools.values.fold(0, (sum, pool) => sum + pool._cache.length),
    };
  }

  /// Get memory usage history
  List<MemorySnapshot> getMemoryHistory() {
    return List.from(_memoryHistory);
  }

  /// Clear all managed caches
  void clearAllCaches() {
    for (final pool in _cachePools.values) {
      pool.clear();
    }
    debugPrint('MemoryManager: Cleared all managed caches');
  }

  /// Dispose of memory manager
  void dispose() {
    _memoryMonitorTimer?.cancel();
    clearAllCaches();
    _cachePools.clear();
    _memoryHistory.clear();
  }
}

/// Memory snapshot for tracking usage over time
class MemorySnapshot {
  final DateTime timestamp;
  final double usedMemoryMB;
  final double availableMemoryMB;
  final double totalMemoryMB;

  const MemorySnapshot({
    required this.timestamp,
    required this.usedMemoryMB,
    required this.availableMemoryMB,
    required this.totalMemoryMB,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'usedMemoryMB': usedMemoryMB,
      'availableMemoryMB': availableMemoryMB,
      'totalMemoryMB': totalMemoryMB,
    };
  }
}

/// Managed cache pool with automatic cleanup
abstract class CachePool<T> {
  void put(String key, T value, {Duration? ttl});
  T? get(String key);
  bool remove(String key);
  void clear();
  int get size;
  Map<String, dynamic> getStats();
}

/// Implementation of managed cache pool
class _CachePool<T> extends CachePool<T> {
  final String name;
  final int _maxSize;
  final Duration _defaultTTL;
  final MemoryManager memoryManager;
  
  final LinkedHashMap<String, _CacheEntry<T>> _cache = LinkedHashMap();

  _CachePool({
    required this.name,
    required int maxSize,
    required Duration defaultTTL,
    required this.memoryManager,
  }) : _maxSize = maxSize, _defaultTTL = defaultTTL;

  @override
  void put(String key, T value, {Duration? ttl}) {
    // Remove existing entry to update position
    _cache.remove(key);
    
    // Add new entry
    _cache[key] = _CacheEntry(
      value,
      DateTime.now().add(ttl ?? _defaultTTL),
    );
    
    // Evict oldest entries if cache is full
    while (_cache.length > _maxSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
  }

  @override
  T? get(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    // Move to end (LRU)
    _cache.remove(key);
    _cache[key] = entry;
    
    return entry.value;
  }

  @override
  bool remove(String key) {
    return _cache.remove(key) != null;
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  int get size => _cache.length;

  @override
  Map<String, dynamic> getStats() {
    final expiredCount = _cache.values.where((entry) => entry.isExpired).length;
    
    return {
      'name': name,
      'size': _cache.length,
      'maxSize': _maxSize,
      'expiredEntries': expiredCount,
      'utilizationPercent': (_cache.length / _maxSize * 100),
    };
  }

  /// Clean expired entries
  void _cleanExpired() {
    final expiredKeys = <String>[];
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  /// Clear oldest entries
  void _clearOldest(int count) {
    final keysToRemove = _cache.keys.take(count).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }
}

/// Cache entry with expiration
class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  _CacheEntry(this.value, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}