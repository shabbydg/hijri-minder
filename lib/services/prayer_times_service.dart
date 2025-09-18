import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'location_service.dart';
import 'notification_service.dart';
import 'settings_service.dart';
import 'cache_service.dart';
import 'cache_manager.dart';
import 'performance_service.dart';
import 'connectivity_service.dart';
import '../utils/error_handler.dart';

/// Model for prayer times data
class PrayerTimes {
  final String sihori;
  final String fajr;
  final String sunrise;
  final String zawaal;
  final String zohrEnd;
  final String asrEnd;
  final String maghrib;
  final String maghribEnd;
  final String nisfulLayl;
  final String nisfulLaylEnd;
  final DateTime date;
  final String locationName;

  const PrayerTimes({
    required this.sihori,
    required this.fajr,
    required this.sunrise,
    required this.zawaal,
    required this.zohrEnd,
    required this.asrEnd,
    required this.maghrib,
    required this.maghribEnd,
    required this.nisfulLayl,
    required this.nisfulLaylEnd,
    required this.date,
    required this.locationName,
  });

  /// Create PrayerTimes from API response Map
  factory PrayerTimes.fromMap(Map<String, dynamic> map, DateTime date, String locationName) {
    return PrayerTimes(
      sihori: map['sihori'] ?? '00:00',
      fajr: map['fajr'] ?? '00:00',
      sunrise: map['sunrise'] ?? '00:00',
      zawaal: map['zawaal'] ?? '00:00',
      zohrEnd: map['zohr_end'] ?? '00:00',
      asrEnd: map['asr_end'] ?? '00:00',
      maghrib: map['maghrib'] ?? '00:00',
      maghribEnd: map['maghrib_end'] ?? '00:00',
      nisfulLayl: map['nisful_layl'] ?? '00:00',
      nisfulLaylEnd: map['nisful_layl_end'] ?? '00:00',
      date: date,
      locationName: locationName,
    );
  }

  /// Convert PrayerTimes to Map
  Map<String, dynamic> toMap() {
    return {
      'sihori': sihori,
      'fajr': fajr,
      'sunrise': sunrise,
      'zawaal': zawaal,
      'zohr_end': zohrEnd,
      'asr_end': asrEnd,
      'maghrib': maghrib,
      'maghrib_end': maghribEnd,
      'nisful_layl': nisfulLayl,
      'nisful_layl_end': nisfulLaylEnd,
      'date': date.toIso8601String(),
      'location_name': locationName,
    };
  }

  /// Format time string according to user preference
  /// Returns formatted time string (12h or 24h format)
  String formatTime(String time, {bool use24Hour = false}) {
    try {
      if (time.isEmpty || time == '00:00') return time;
      
      final parts = time.split(':');
      if (parts.length < 2) return time;
      
      // Handle both HH:MM and HH:MM:SS formats
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      if (use24Hour) {
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      } else {
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      debugPrint('PrayerTimes: Error formatting time $time: $e');
      return time;
    }
  }

  /// Get the next prayer time from current time
  /// Returns the name of the next prayer
  String getNextPrayer() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final prayers = [
      {'name': 'Sihori', 'time': sihori},
      {'name': 'Fajr', 'time': fajr},
      {'name': 'Sunrise', 'time': sunrise},
      {'name': 'Zawaal', 'time': zawaal},
      {'name': 'Zohr End', 'time': zohrEnd},
      {'name': 'Asr End', 'time': asrEnd},
      {'name': 'Maghrib', 'time': maghrib},
      {'name': 'Maghrib End', 'time': maghribEnd},
      {'name': 'Nisful Layl', 'time': nisfulLayl},
      {'name': 'Nisful Layl End', 'time': nisfulLaylEnd},
    ];

    for (final prayer in prayers) {
      if (_isTimeAfter(currentTime, prayer['time']!)) {
        return prayer['name']!;
      }
    }

    // If no prayer is found for today, return first prayer of next day
    return 'Sihori';
  }

  /// Check if current time is a prayer time
  /// Returns true if it's currently a prayer time
  bool isPrayerTime() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final prayerTimes = [sihori, fajr, sunrise, zawaal, zohrEnd, asrEnd, maghrib, maghribEnd, nisfulLayl, nisfulLaylEnd];
    
    return prayerTimes.any((time) => time == currentTime);
  }

  /// Get current prayer period
  /// Returns the name of the current prayer period
  String getCurrentPrayerPeriod() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    if (_isTimeBetween(currentTime, sihori, fajr)) return 'Sihori Period';
    if (_isTimeBetween(currentTime, fajr, sunrise)) return 'Fajr Period';
    if (_isTimeBetween(currentTime, sunrise, zawaal)) return 'Morning Period';
    if (_isTimeBetween(currentTime, zawaal, zohrEnd)) return 'Zawaal Period';
    if (_isTimeBetween(currentTime, zohrEnd, asrEnd)) return 'Zohr Period';
    if (_isTimeBetween(currentTime, asrEnd, maghrib)) return 'Asr Period';
    if (_isTimeBetween(currentTime, maghrib, maghribEnd)) return 'Maghrib Period';
    if (_isTimeBetween(currentTime, maghribEnd, nisfulLayl)) return 'Evening Period';
    if (_isTimeBetween(currentTime, nisfulLayl, nisfulLaylEnd)) return 'Nisful Layl Period';
    
    return 'Night Period';
  }

  /// Helper method to check if time1 is after time2
  bool _isTimeAfter(String time1, String time2) {
    try {
      final parts1 = time1.split(':');
      final parts2 = time2.split(':');
      
      final minutes1 = int.parse(parts1[0]) * 60 + int.parse(parts1[1]);
      final minutes2 = int.parse(parts2[0]) * 60 + int.parse(parts2[1]);
      
      return minutes1 < minutes2;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to check if time is between start and end times
  bool _isTimeBetween(String time, String start, String end) {
    try {
      final parts = time.split(':');
      final startParts = start.split(':');
      final endParts = end.split(':');
      
      final minutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      
      return minutes >= startMinutes && minutes < endMinutes;
    } catch (e) {
      return false;
    }
  }
}

/// Service for managing prayer times and API integration
/// Provides methods for fetching prayer times from mumineen.org API with offline support
class PrayerTimesService {
  static const String _baseUrl = 'https://mumineen.org/api/v1';
  static const Duration _cacheTimeout = Duration(days: 30);
  
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();
  final CacheService _cacheService = CacheService();
  final CacheManager _cacheManager = CacheManager();
  final PerformanceService _performanceService = PerformanceService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final Map<String, PrayerTimes> _memoryCache = {};
  DateTime? _lastCacheUpdate;
  
  // Batch request queue for API optimization
  final List<_PrayerTimeRequest> _pendingRequests = [];
  Timer? _batchTimer;

  /// Get today's prayer times
  /// Returns PrayerTimes for current date and location
  Future<PrayerTimes?> getTodayPrayerTimes() async {
    final DateTime today = DateTime.now();
    return await getPrayerTimesForDate(today);
  }

  /// Get prayer times for a specific date
  /// Returns PrayerTimes for the given date and current location with offline support
  Future<PrayerTimes?> getPrayerTimesForDate(DateTime date) async {
    return await _performanceService.timeOperation(
      'get_prayer_times_for_date',
      () async {
        return await ErrorHandler.withFallback<PrayerTimes?>(
          () async {
            final String cacheKey = _getCacheKey(date);
            
            // Use enhanced cache manager for better performance
            final cachedPrayerTimes = await _cacheManager.get<PrayerTimes>(
              'prayer_times_$cacheKey',
              fromJson: (json) => PrayerTimes.fromMap(json, date, json['location_name'] ?? 'Unknown'),
              ttl: _cacheTimeout,
            );
            
            if (cachedPrayerTimes != null) {
              debugPrint('PrayerTimesService: Retrieved from cache for $cacheKey');
              return cachedPrayerTimes;
            }

            // If offline, return mock data
            if (!_connectivityService.isOnline) {
              debugPrint('PrayerTimesService: Offline - returning mock data for $cacheKey');
              return getMockPrayerTimes(date);
            }

            // Get location
            final Map<String, dynamic> location = await _locationService.getBestAvailableLocation();
            
            // Use batch processing for better API efficiency
            return await _getBatchedPrayerTimes(date, location);
          },
          () => getMockPrayerTimes(date),
          'get prayer times for date',
          errorType: ErrorType.api,
          severity: ErrorSeverity.medium,
          context: {'date': date.toIso8601String()},
        );
      },
      metadata: {'date': date.toIso8601String()},
    );
  }

  /// Get batched prayer times for better API efficiency
  Future<PrayerTimes?> _getBatchedPrayerTimes(DateTime date, Map<String, dynamic> location) async {
    final request = _PrayerTimeRequest(date, location);
    _pendingRequests.add(request);
    
    // Start batch timer if not already running
    _batchTimer ??= Timer(const Duration(milliseconds: 100), _processBatchRequests);
    
    return await request.completer.future;
  }

  /// Process batched requests for optimal API usage
  Future<void> _processBatchRequests() async {
    if (_pendingRequests.isEmpty) return;
    
    final requests = List<_PrayerTimeRequest>.from(_pendingRequests);
    _pendingRequests.clear();
    _batchTimer = null;
    
    // Group requests by location to minimize API calls
    final locationGroups = <String, List<_PrayerTimeRequest>>{};
    for (final request in requests) {
      final locationKey = '${request.location['latitude']}_${request.location['longitude']}';
      locationGroups.putIfAbsent(locationKey, () => []).add(request);
    }
    
    // Process each location group
    for (final group in locationGroups.values) {
      await _processBatchForLocation(group);
    }
  }

  /// Process batch requests for a specific location
  Future<void> _processBatchForLocation(List<_PrayerTimeRequest> requests) async {
    try {
      // Fetch prayer times for all dates in the batch
      final futures = requests.map((request) => 
        _fetchPrayerTimesFromAPI(
          request.date,
          request.location['latitude'],
          request.location['longitude'],
          request.location['name'],
        )
      ).toList();
      
      final results = await _performanceService.batchOperations(
        'prayer_times_batch_fetch',
        futures.map((future) => () => future).toList(),
        concurrency: 3, // Limit concurrent API calls
      );
      
      // Complete all requests with their results
      for (int i = 0; i < requests.length; i++) {
        final request = requests[i];
        final result = results[i];
        
        if (result != null) {
          // Cache the result
          final cacheKey = _getCacheKey(request.date);
          await _cacheManager.set(
            'prayer_times_$cacheKey',
            result,
            persistentTTL: _cacheTimeout,
            toJson: (prayerTimes) => prayerTimes.toMap(),
          );
        }
        
        request.completer.complete(result);
      }
    } catch (e) {
      // Complete all requests with error
      for (final request in requests) {
        request.completer.completeError(e);
      }
    }
  }

  /// Get prayer times for a specific Hijri date
  /// Returns PrayerTimes for the given Hijri date
  Future<PrayerTimes?> getPrayerTimesForHijriDate(int day, int month, int year) async {
    try {
      // Convert Hijri to Gregorian date
      // This would use the HijriDate model in a full implementation
      // For now, use current date as approximation
      final DateTime gregorianDate = DateTime.now();
      return await getPrayerTimesForDate(gregorianDate);
    } catch (e) {
      debugPrint('PrayerTimesService: Error getting prayer times for Hijri date: $e');
      return null;
    }
  }

  /// Get prayer times for current week with optimized batch processing
  /// Returns list of PrayerTimes for the next 7 days
  Future<List<PrayerTimes>> getCurrentWeekPrayerTimes() async {
    return await _performanceService.timeOperation(
      'get_current_week_prayer_times',
      () async {
        final DateTime today = DateTime.now();
        final dates = List.generate(7, (i) => today.add(Duration(days: i)));
        
        // Use batch processing for better performance
        return await _getBatchPrayerTimes(dates);
      },
    );
  }

  /// Get prayer times for current month with optimized batch processing
  /// Returns list of PrayerTimes for the current month
  Future<List<PrayerTimes>> getCurrentMonthPrayerTimes() async {
    return await _performanceService.timeOperation(
      'get_current_month_prayer_times',
      () async {
        final DateTime now = DateTime.now();
        final DateTime lastDay = DateTime(now.year, now.month + 1, 0);
        final dates = List.generate(
          lastDay.day,
          (i) => DateTime(now.year, now.month, i + 1),
        );
        
        // Use batch processing for better performance
        return await _getBatchPrayerTimes(dates);
      },
    );
  }

  /// Get prayer times for multiple dates efficiently
  Future<List<PrayerTimes>> _getBatchPrayerTimes(List<DateTime> dates) async {
    // Check cache first for all dates
    final cacheKeys = dates.map(_getCacheKey).toList();
    final cachedResults = await _cacheManager.batchGet<PrayerTimes>(
      cacheKeys.map((key) => 'prayer_times_$key').toList(),
      fromJson: (json) => PrayerTimes.fromMap(
        json,
        dates[cacheKeys.indexOf(json['cache_key']?.replaceFirst('prayer_times_', '') ?? '')],
        json['location_name'] ?? 'Unknown',
      ),
    );
    
    final results = <PrayerTimes>[];
    final uncachedDates = <DateTime>[];
    
    // Separate cached and uncached dates
    for (int i = 0; i < dates.length; i++) {
      final cached = cachedResults['prayer_times_${cacheKeys[i]}'];
      if (cached != null) {
        results.add(cached);
      } else {
        uncachedDates.add(dates[i]);
      }
    }
    
    // Fetch uncached dates if any
    if (uncachedDates.isNotEmpty && _connectivityService.isOnline) {
      final location = await _locationService.getBestAvailableLocation();
      
      // Use concurrent fetching with limited concurrency
      final uncachedResults = await _performanceService.batchOperations(
        'fetch_uncached_prayer_times',
        uncachedDates.map((date) => () => _fetchPrayerTimesFromAPI(
          date,
          location['latitude'],
          location['longitude'],
          location['name'],
        )).toList(),
        concurrency: 3,
      );
      
      // Cache and add results
      for (int i = 0; i < uncachedDates.length; i++) {
        final result = uncachedResults[i];
        if (result != null) {
          results.add(result);
          
          // Cache the result
          final cacheKey = _getCacheKey(uncachedDates[i]);
          await _cacheManager.set(
            'prayer_times_$cacheKey',
            result,
            persistentTTL: _cacheTimeout,
            toJson: (prayerTimes) => prayerTimes.toMap(),
          );
        }
      }
    } else if (uncachedDates.isNotEmpty) {
      // Add mock data for offline uncached dates
      for (final date in uncachedDates) {
        results.add(getMockPrayerTimes(date));
      }
    }
    
    // Sort results by date
    results.sort((a, b) => a.date.compareTo(b.date));
    return results;
  }

  /// Get best available location for prayer times
  /// Returns Map with location information
  Future<Map<String, dynamic>> getBestAvailableLocation() async {
    return await _locationService.getBestAvailableLocation();
  }

  /// Fetch prayer times from mumineen.org API
  /// Returns PrayerTimes from API response
  Future<PrayerTimes?> _fetchPrayerTimesFromAPI(
    DateTime date,
    double latitude,
    double longitude,
    String locationName,
  ) async {
    final String dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    // Get timezone from location service
    final location = await _locationService.getBestAvailableLocation();
    final String timezone = location['timezone'] ?? 'UTC';
    
    final String url = '$_baseUrl/salaat?start=$dateStr&latitude=$latitude&longitude=$longitude&timezone=${Uri.encodeComponent(timezone)}';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        final prayerData = data['data'][dateStr]; // Extract data like HTML version
        
        if (prayerData != null) {
          return PrayerTimes.fromMap(prayerData, date, locationName);
        } else {
          throw FormatException('No prayer data found for date: $dateStr');
        }
      } catch (e) {
        ErrorHandler.logError(
          'Failed to parse prayer times API response',
          details: 'Response body: ${response.body}',
          type: ErrorType.parsing,
          severity: ErrorSeverity.high,
          context: {'url': url, 'statusCode': response.statusCode},
        );
        throw FormatException('Invalid API response format');
      }
    } else {
      ErrorHandler.logError(
        'Prayer times API returned error status',
        details: 'Status: ${response.statusCode}, Body: ${response.body}',
        type: ErrorType.api,
        severity: ErrorSeverity.high,
        context: {'url': url, 'statusCode': response.statusCode},
      );
      throw Exception('API error: ${response.statusCode}');
    }
  }

  /// Get mock prayer times as fallback
  /// Returns mock PrayerTimes data when API is unavailable
  PrayerTimes getMockPrayerTimes([DateTime? date]) {
    final DateTime targetDate = date ?? DateTime.now();
    
    return PrayerTimes(
      sihori: '04:30',
      fajr: '05:15',
      sunrise: '06:30',
      zawaal: '12:15',
      zohrEnd: '12:45',
      asrEnd: '16:30',
      maghrib: '18:15',
      maghribEnd: '18:45',
      nisfulLayl: '23:30',
      nisfulLaylEnd: '00:15',
      date: targetDate,
      locationName: 'Colombo, Sri Lanka (Fallback)',
    );
  }

  /// Generate cache key for date
  String _getCacheKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout;
  }

  /// Clear prayer times cache
  Future<void> clearCache() async {
    _memoryCache.clear();
    _lastCacheUpdate = null;
    
    // Clear persistent cache for prayer times
    final keys = await _getAllPrayerTimesCacheKeys();
    for (final key in keys) {
      await _cacheService.removeCache(key);
    }
    
    debugPrint('PrayerTimesService: Cleared all prayer times cache');
  }

  /// Get all prayer times cache keys
  Future<List<String>> _getAllPrayerTimesCacheKeys() async {
    // This would typically scan all cache keys starting with 'prayer_times_'
    // For now, return empty list as SharedPreferences doesn't have a direct way to list keys
    return [];
  }

  /// Sync cached data when connectivity returns
  Future<void> syncWhenOnline() async {
    if (!_connectivityService.isOnline) {
      debugPrint('PrayerTimesService: Cannot sync - still offline');
      return;
    }

    debugPrint('PrayerTimesService: Syncing prayer times data...');
    
    // Refresh today's prayer times
    final today = DateTime.now();
    final todayKey = _getCacheKey(today);
    _memoryCache.remove(todayKey);
    await _cacheService.removeCache('prayer_times_$todayKey');
    
    // Fetch fresh data
    await getPrayerTimesForDate(today);
    
    // Optionally refresh next few days
    for (int i = 1; i <= 7; i++) {
      final futureDate = today.add(Duration(days: i));
      final futureKey = _getCacheKey(futureDate);
      _memoryCache.remove(futureKey);
      await _cacheService.removeCache('prayer_times_$futureKey');
      await getPrayerTimesForDate(futureDate);
    }
    
    debugPrint('PrayerTimesService: Sync completed');
  }

  /// Get offline status indicator
  bool get isOffline => !_connectivityService.isOnline;

  /// Get cache status information
  Future<Map<String, dynamic>> getCacheStatus() async {
    final cacheSize = await _cacheService.getCacheSize();
    return {
      'isOnline': _connectivityService.isOnline,
      'memoryCacheSize': _memoryCache.length,
      'persistentCacheSize': cacheSize,
      'lastCacheUpdate': _lastCacheUpdate?.toIso8601String(),
    };
  }

  /// Request user location for accurate prayer times
  /// Returns true if location permission granted, false otherwise
  Future<bool> requestUserLocation() async {
    return await _locationService.requestLocationPermissionWithDialog();
  }

  /// Schedule prayer notifications for today
  /// Schedules notifications based on user settings
  Future<void> scheduleTodayPrayerNotifications() async {
    try {
      final prayerTimes = await getTodayPrayerTimes();
      if (prayerTimes != null) {
        final settings = await _settingsService.getSettings();
        await _notificationService.schedulePrayerNotifications(prayerTimes, settings);
      }
    } catch (e) {
      debugPrint('PrayerTimesService: Error scheduling prayer notifications: $e');
    }
  }

  /// Schedule prayer notifications for multiple days
  /// Schedules notifications for the next 7 days
  Future<void> scheduleWeeklyPrayerNotifications() async {
    try {
      final weeklyTimes = await getCurrentWeekPrayerTimes();
      final settings = await _settingsService.getSettings();
      
      for (final prayerTimes in weeklyTimes) {
        await _notificationService.schedulePrayerNotifications(prayerTimes, settings);
      }
    } catch (e) {
      debugPrint('PrayerTimesService: Error scheduling weekly prayer notifications: $e');
    }
  }

  /// Cancel all prayer notifications
  Future<void> cancelPrayerNotifications() async {
    await _notificationService.cancelPrayerNotifications();
  }
}

/// Batch request class for prayer times
class _PrayerTimeRequest {
  final DateTime date;
  final Map<String, dynamic> location;
  final Completer<PrayerTimes?> completer = Completer<PrayerTimes?>();

  _PrayerTimeRequest(this.date, this.location);
}