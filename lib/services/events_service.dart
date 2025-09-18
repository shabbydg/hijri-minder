import 'package:flutter/material.dart';
import '../models/islamic_event.dart';
import 'cache_service.dart';
import 'cache_manager.dart';
import 'performance_service.dart';
import 'connectivity_service.dart';

/// Service for managing Islamic events and holidays with offline support
/// Provides methods for event retrieval, search, and categorization
class EventsService {
  final CacheService _cacheService = CacheService();
  final CacheManager _cacheManager = CacheManager();
  final PerformanceService _performanceService = PerformanceService();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const Duration _eventsCacheTimeout = Duration(days: 365); // Events rarely change
  
  // Lazy loading cache for events
  final Map<int, List<IslamicEvent>> _monthlyEventsCache = {};
  final Map<String, List<IslamicEvent>> _searchCache = {};
  bool _allEventsLoaded = false;
  static final List<IslamicEvent> _events = [
    // Muharram events
    IslamicEvent(
      id: 'muharram_1',
      title: 'Islamic New Year',
      description: 'The first day of the Islamic calendar year',
      hijriDay: 1,
      hijriMonth: 1,
      category: EventCategory.other,
      isImportant: true,
    ),
    IslamicEvent(
      id: 'ashura',
      title: 'Day of Ashura',
      description: 'The 10th day of Muharram, commemorating various historical events',
      hijriDay: 10,
      hijriMonth: 1,
      category: EventCategory.shahadat,
      isImportant: true,
    ),

    // Safar events
    IslamicEvent(
      id: 'arbaeen',
      title: 'Arbaeen',
      description: 'The 40th day after Ashura',
      hijriDay: 20,
      hijriMonth: 2,
      category: EventCategory.shahadat,
      isImportant: true,
    ),

    // Rabi al-Awwal events
    IslamicEvent(
      id: 'mawlid',
      title: 'Mawlid an-Nabi',
      description: 'Birth of Prophet Muhammad (PBUH)',
      hijriDay: 12,
      hijriMonth: 3,
      category: EventCategory.milad,
      isImportant: true,
    ),

    // Rajab events
    IslamicEvent(
      id: 'isra_miraj',
      title: 'Isra and Mi\'raj',
      description: 'The Night Journey and Ascension of Prophet Muhammad (PBUH)',
      hijriDay: 27,
      hijriMonth: 7,
      category: EventCategory.milad,
      isImportant: true,
    ),

    // Sha\'ban events
    IslamicEvent(
      id: 'laylat_bara',
      title: 'Laylat al-Bara\'ah',
      description: 'The Night of Forgiveness',
      hijriDay: 15,
      hijriMonth: 8,
      category: EventCategory.other,
      isImportant: true,
    ),

    // Ramadan events
    IslamicEvent(
      id: 'ramadan_start',
      title: 'First Day of Ramadan',
      description: 'Beginning of the holy month of fasting',
      hijriDay: 1,
      hijriMonth: 9,
      category: EventCategory.ramadan,
      isImportant: true,
    ),
    IslamicEvent(
      id: 'laylat_qadr',
      title: 'Laylat al-Qadr',
      description: 'The Night of Power (estimated)',
      hijriDay: 27,
      hijriMonth: 9,
      category: EventCategory.ramadan,
      isImportant: true,
    ),

    // Shawwal events
    IslamicEvent(
      id: 'eid_fitr',
      title: 'Eid al-Fitr',
      description: 'Festival of Breaking the Fast',
      hijriDay: 1,
      hijriMonth: 10,
      category: EventCategory.eid,
      isImportant: true,
    ),

    // Dhul Hijjah events
    IslamicEvent(
      id: 'hajj_start',
      title: 'Hajj Season Begins',
      description: 'Beginning of the Hajj pilgrimage period',
      hijriDay: 8,
      hijriMonth: 12,
      category: EventCategory.hajj,
      isImportant: true,
    ),
    IslamicEvent(
      id: 'arafat',
      title: 'Day of Arafat',
      description: 'The most important day of Hajj pilgrimage',
      hijriDay: 9,
      hijriMonth: 12,
      category: EventCategory.hajj,
      isImportant: true,
    ),
    IslamicEvent(
      id: 'eid_adha',
      title: 'Eid al-Adha',
      description: 'Festival of Sacrifice',
      hijriDay: 10,
      hijriMonth: 12,
      category: EventCategory.eid,
      isImportant: true,
    ),

    // Additional important events
    IslamicEvent(
      id: 'jumma',
      title: 'Jumu\'ah Prayer',
      description: 'Weekly congregational prayer',
      hijriDay: 0, // Special case for weekly events
      hijriMonth: 0,
      category: EventCategory.other,
      isImportant: false,
    ),
  ];

  /// Get events for a specific Hijri date with offline support and lazy loading
  /// Returns list of IslamicEvent objects for the given date
  Future<List<IslamicEvent>> getEventsForDate(int hijriDay, int hijriMonth) async {
    return await _performanceService.timeOperation(
      'get_events_for_date',
      () async {
        return await _cacheManager.getOrCompute<List<IslamicEvent>>(
          'events_${hijriMonth}_$hijriDay',
          () async {
            // Get from static data with performance tracking
            return _performanceService.timeSync(
              'filter_events_for_date',
              () => _events.where((event) {
                return event.hijriDay == hijriDay && event.hijriMonth == hijriMonth;
              }).toList(),
            );
          },
          memoryTTL: const Duration(hours: 1),
          persistentTTL: _eventsCacheTimeout,
          fromJson: (json) => (json['events'] as List)
              .map((eventMap) => IslamicEvent.fromJson(eventMap))
              .toList(),
          toJson: (events) => {'events': events.map((e) => e.toJson()).toList()},
        );
      },
      metadata: {'hijriDay': hijriDay, 'hijriMonth': hijriMonth},
    );
  }

  /// Get all events for a specific Hijri month with lazy loading and caching
  /// Returns list of IslamicEvent objects for the given month
  Future<List<IslamicEvent>> getEventsForMonth(int hijriMonth) async {
    return await _performanceService.timeOperation(
      'get_events_for_month',
      () async {
        // Check memory cache first for better performance
        if (_monthlyEventsCache.containsKey(hijriMonth)) {
          return _monthlyEventsCache[hijriMonth]!;
        }

        final events = await _cacheManager.getOrCompute<List<IslamicEvent>>(
          'events_month_$hijriMonth',
          () async {
            return _performanceService.timeSync(
              'filter_events_for_month',
              () => _events.where((event) {
                return event.hijriMonth == hijriMonth;
              }).toList(),
            );
          },
          memoryTTL: const Duration(hours: 2),
          persistentTTL: _eventsCacheTimeout,
          fromJson: (json) => (json['events'] as List)
              .map((eventMap) => IslamicEvent.fromJson(eventMap))
              .toList(),
          toJson: (events) => {'events': events.map((e) => e.toJson()).toList()},
        );

        // Cache in memory for faster subsequent access
        _monthlyEventsCache[hijriMonth] = events;
        
        // Limit memory cache size
        if (_monthlyEventsCache.length > 12) {
          final oldestKey = _monthlyEventsCache.keys.first;
          _monthlyEventsCache.remove(oldestKey);
        }

        return events;
      },
      metadata: {'hijriMonth': hijriMonth},
    );
  }

  /// Get all events
  /// Returns list of all IslamicEvent objects
  List<IslamicEvent> getAllEvents() {
    return List.from(_events);
  }

  /// Get all important events with offline support
  /// Returns list of IslamicEvent objects marked as important
  Future<List<IslamicEvent>> getImportantEvents() async {
    try {
      // Try to get from cache first
      const cacheKey = 'important_events';
      final cachedEvents = await _cacheService.getCacheList(cacheKey);
      
      if (cachedEvents != null) {
        debugPrint('EventsService: Retrieved cached important events');
        return cachedEvents.map((eventMap) => IslamicEvent.fromJson(eventMap)).toList();
      }

      // Get from static data
      final events = _events.where((event) => event.isImportant).toList();

      // Cache the results
      final eventMaps = events.map((event) => event.toJson()).toList();
      await _cacheService.setCacheList(cacheKey, eventMaps, _eventsCacheTimeout);
      
      return events;
    } catch (e) {
      debugPrint('EventsService: Error getting important events: $e');
      // Fallback to static data
      return _events.where((event) => event.isImportant).toList();
    }
  }

  /// Search events by title, description, or category with caching
  /// Returns list of IslamicEvent objects matching the query
  List<IslamicEvent> searchEvents(String query) {
    if (query.isEmpty) {
      return [];
    }

    return _performanceService.timeSync(
      'search_events',
      () {
        final String lowerQuery = query.toLowerCase();
        
        // Check search cache first
        if (_searchCache.containsKey(lowerQuery)) {
          return _searchCache[lowerQuery]!;
        }

        final results = _events.where((event) {
          return event.title.toLowerCase().contains(lowerQuery) ||
                 event.description.toLowerCase().contains(lowerQuery) ||
                 event.getCategoryDisplayName().toLowerCase().contains(lowerQuery);
        }).toList();

        // Cache search results
        _searchCache[lowerQuery] = results;
        
        // Limit search cache size
        if (_searchCache.length > 50) {
          final oldestKey = _searchCache.keys.first;
          _searchCache.remove(oldestKey);
        }

        return results;
      },
      metadata: {'query': query, 'queryLength': query.length},
    );
  }

  /// Get events by category
  /// Returns list of IslamicEvent objects in the specified category
  List<IslamicEvent> getEventsByCategory(EventCategory category) {
    return _events.where((event) {
      return event.category == category;
    }).toList();
  }

  /// Get all available event categories
  /// Returns list of unique category names
  List<String> getEventCategories() {
    final Set<String> categories = _events.map((event) => event.getCategoryDisplayName()).toSet();
    return categories.toList()..sort();
  }

  /// Check if a specific date has events
  /// Returns true if events exist for the given date
  bool hasEventsForDate(int hijriDay, int hijriMonth) {
    return _events.any((event) {
      return event.hijriDay == hijriDay && event.hijriMonth == hijriMonth;
    });
  }

  /// Get event by ID
  /// Returns IslamicEvent if found, null otherwise
  IslamicEvent? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      debugPrint('EventsService: Event not found with ID: $id');
      return null;
    }
  }

  /// Get events for current Hijri month
  /// Returns list of IslamicEvent objects for the current month
  Future<List<IslamicEvent>> getCurrentMonthEvents() async {
    // This would typically get the current Hijri month
    // For now, return all events as a placeholder
    final DateTime now = DateTime.now();
    // Simple approximation - in real implementation, use HijriDate conversion
    final int approximateHijriMonth = ((now.month + 2) % 12) + 1;
    return await getEventsForMonth(approximateHijriMonth);
  }

  /// Get upcoming events within the next N days
  /// Returns list of IslamicEvent objects occurring soon
  Future<List<IslamicEvent>> getUpcomingEvents({int daysAhead = 30}) async {
    // This would typically calculate upcoming events based on current date
    // For now, return important events as a placeholder
    return await getImportantEvents();
  }

  /// Add custom event (for future implementation)
  /// Returns true if successful, false otherwise
  Future<bool> addCustomEvent(IslamicEvent event) async {
    try {
      // In a full implementation, this would save to persistent storage
      _events.add(event);
      return true;
    } catch (e) {
      debugPrint('EventsService: Error adding custom event: $e');
      return false;
    }
  }

  /// Remove custom event (for future implementation)
  /// Returns true if successful, false otherwise
  Future<bool> removeCustomEvent(String eventId) async {
    try {
      // In a full implementation, this would remove from persistent storage
      _events.removeWhere((event) => event.id == eventId);
      return true;
    } catch (e) {
      debugPrint('EventsService: Error removing custom event: $e');
      return false;
    }
  }

  /// Clear all cached events data
  Future<void> clearCache() async {
    try {
      // Clear month caches
      for (int month = 1; month <= 12; month++) {
        await _cacheService.removeCache('events_month_$month');
        
        // Clear daily caches for this month (approximate)
        for (int day = 1; day <= 30; day++) {
          await _cacheService.removeCache('events_${month}_$day');
        }
      }
      
      // Clear important events cache
      await _cacheService.removeCache('important_events');
      
      debugPrint('EventsService: Cleared all events cache');
    } catch (e) {
      debugPrint('EventsService: Error clearing events cache: $e');
    }
  }

  /// Sync cached events data when connectivity returns
  Future<void> syncWhenOnline() async {
    if (!_connectivityService.isOnline) {
      debugPrint('EventsService: Cannot sync - still offline');
      return;
    }

    debugPrint('EventsService: Syncing events data...');
    
    // Clear cache to force refresh
    await clearCache();
    
    // Pre-cache important events
    await getImportantEvents();
    
    // Pre-cache current month events
    final now = DateTime.now();
    final approximateHijriMonth = ((now.month + 2) % 12) + 1;
    await getEventsForMonth(approximateHijriMonth);
    
    debugPrint('EventsService: Events sync completed');
  }

  /// Get offline status indicator
  bool get isOffline => !_connectivityService.isOnline;

  /// Get cache status information
  Future<Map<String, dynamic>> getCacheStatus() async {
    final cacheSize = await _cacheService.getCacheSize();
    return {
      'isOnline': _connectivityService.isOnline,
      'totalCacheSize': cacheSize,
      'eventsCount': _events.length,
    };
  }

  /// Initialize events cache with essential data
  Future<void> initializeCache() async {
    try {
      debugPrint('EventsService: Initializing events cache...');
      
      // Cache important events
      await getImportantEvents();
      
      // Cache events for all months
      for (int month = 1; month <= 12; month++) {
        await getEventsForMonth(month);
      }
      
      debugPrint('EventsService: Events cache initialization completed');
    } catch (e) {
      debugPrint('EventsService: Error initializing events cache: $e');
    }
  }
}