import 'dart:async';
import 'package:flutter/material.dart';
import 'connectivity_service.dart';
import 'cache_service.dart';
import 'prayer_times_service.dart';
import 'events_service.dart';
import 'settings_service.dart';

/// Service for managing offline functionality and data synchronization
/// Coordinates offline behavior across all services
class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final CacheService _cacheService = CacheService();
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final EventsService _eventsService = EventsService();
  final SettingsService _settingsService = SettingsService();

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isInitialized = false;
  bool _isSyncing = false;

  /// Initialize offline manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('OfflineManager: Initializing...');

    // Initialize connectivity service
    _connectivityService.initialize();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      _onConnectivityChanged,
    );

    // Initialize cache with essential data if online
    if (_connectivityService.isOnline) {
      await _initializeEssentialCache();
    }

    // Clean expired cache entries
    await _cacheService.cleanExpiredCache();

    _isInitialized = true;
    debugPrint('OfflineManager: Initialization completed');
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(bool isOnline) async {
    debugPrint('OfflineManager: Connectivity changed to ${isOnline ? 'online' : 'offline'}');

    if (isOnline && !_isSyncing) {
      await _syncWhenOnline();
    }
  }

  /// Initialize essential cache data
  Future<void> _initializeEssentialCache() async {
    try {
      debugPrint('OfflineManager: Initializing essential cache...');

      // Cache today's prayer times
      await _prayerTimesService.getTodayPrayerTimes();

      // Cache next week's prayer times
      await _prayerTimesService.getCurrentWeekPrayerTimes();

      // Cache important Islamic events
      await _eventsService.initializeCache();

      // Ensure settings are properly cached
      await _settingsService.getSettings();

      debugPrint('OfflineManager: Essential cache initialization completed');
    } catch (e) {
      debugPrint('OfflineManager: Error initializing essential cache: $e');
    }
  }

  /// Sync all data when connectivity returns
  Future<void> _syncWhenOnline() async {
    if (_isSyncing) {
      debugPrint('OfflineManager: Sync already in progress');
      return;
    }

    _isSyncing = true;
    debugPrint('OfflineManager: Starting sync...');

    try {
      // Sync prayer times
      await _prayerTimesService.syncWhenOnline();

      // Sync events
      await _eventsService.syncWhenOnline();

      // Sync settings
      await _settingsService.syncWhenOnline();

      // Clean expired cache
      await _cacheService.cleanExpiredCache();

      debugPrint('OfflineManager: Sync completed successfully');
    } catch (e) {
      debugPrint('OfflineManager: Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Force sync all data
  Future<void> forcSync() async {
    if (_connectivityService.isOnline) {
      await _syncWhenOnline();
    } else {
      debugPrint('OfflineManager: Cannot force sync - device is offline');
    }
  }

  /// Get offline status
  bool get isOffline => !_connectivityService.isOnline;

  /// Get sync status
  bool get isSyncing => _isSyncing;

  /// Get comprehensive offline status
  Future<Map<String, dynamic>> getOfflineStatus() async {
    final prayerTimesStatus = await _prayerTimesService.getCacheStatus();
    final eventsStatus = await _eventsService.getCacheStatus();
    final settingsStatus = await _settingsService.getSettingsStatus();
    final cacheSize = await _cacheService.getCacheSize();

    return {
      'isOnline': _connectivityService.isOnline,
      'isOffline': isOffline,
      'isSyncing': _isSyncing,
      'isInitialized': _isInitialized,
      'totalCacheSize': cacheSize,
      'prayerTimes': prayerTimesStatus,
      'events': eventsStatus,
      'settings': settingsStatus,
    };
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    debugPrint('OfflineManager: Clearing all cached data...');

    try {
      await _prayerTimesService.clearCache();
      await _eventsService.clearCache();
      await _cacheService.clearAllCache();

      debugPrint('OfflineManager: All cached data cleared');
    } catch (e) {
      debugPrint('OfflineManager: Error clearing cache: $e');
    }
  }

  /// Prepare for offline mode
  Future<void> prepareForOffline() async {
    if (!_connectivityService.isOnline) {
      debugPrint('OfflineManager: Already offline');
      return;
    }

    debugPrint('OfflineManager: Preparing for offline mode...');

    try {
      // Cache extended prayer times (next 30 days)
      final today = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final date = today.add(Duration(days: i));
        await _prayerTimesService.getPrayerTimesForDate(date);
      }

      // Ensure all events are cached
      await _eventsService.initializeCache();

      // Backup settings
      final settings = await _settingsService.getSettings();
      await _settingsService.saveSettings(settings);

      debugPrint('OfflineManager: Offline preparation completed');
    } catch (e) {
      debugPrint('OfflineManager: Error preparing for offline: $e');
    }
  }

  /// Get cache usage statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    final cacheSize = await _cacheService.getCacheSize();
    final cleanedCount = await _cacheService.cleanExpiredCache();

    return {
      'totalCacheEntries': cacheSize,
      'expiredEntriesCleaned': cleanedCount,
      'lastCleanup': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    _isInitialized = false;
    debugPrint('OfflineManager: Disposed');
  }
}