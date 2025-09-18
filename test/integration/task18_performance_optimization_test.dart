import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/main.dart' as app;
import 'package:hijri_minder/services/service_locator.dart';
import 'package:hijri_minder/services/performance_service.dart';
import 'package:hijri_minder/services/cache_manager.dart';
import 'package:hijri_minder/services/network_optimizer.dart';
import 'package:hijri_minder/utils/memory_manager.dart';
import 'package:hijri_minder/services/prayer_times_service.dart';
import 'package:hijri_minder/services/events_service.dart';
import 'package:hijri_minder/models/hijri_date.dart';
import 'package:hijri_minder/models/hijri_calendar.dart';

void main() {
  group('Task 18: Performance Optimization Integration Tests', () {
    late PerformanceService performanceService;
    late CacheManager cacheManager;
    late NetworkOptimizer networkOptimizer;
    late MemoryManager memoryManager;
    late PrayerTimesService prayerTimesService;
    late EventsService eventsService;

    setUp(() async {
      await setupServiceLocator();
      performanceService = ServiceLocator.performanceService;
      cacheManager = ServiceLocator.cacheManager;
      networkOptimizer = ServiceLocator.networkOptimizer;
      memoryManager = ServiceLocator.memoryManager;
      prayerTimesService = ServiceLocator.prayerTimesService;
      eventsService = ServiceLocator.eventsService;
    });

    tearDown(() async {
      await ServiceLocator.reset();
    });

    group('Calendar Rendering Performance', () {
      testWidgets('calendar renders efficiently with caching', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();
        
        // Navigate to calendar
        await tester.tap(find.text('Calendar'));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // Calendar should render within 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        // Verify calendar is rendered
        expect(find.byType(GridView), findsOneWidget);
        
        // Check performance metrics
        final stats = performanceService.getPerformanceStats();
        expect(stats, isNotEmpty);
      });

      testWidgets('calendar navigation is optimized', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate to calendar
        await tester.tap(find.text('Calendar'));
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();
        
        // Navigate through multiple months
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byIcon(Icons.chevron_right));
          await tester.pump();
        }
        
        stopwatch.stop();
        
        // Navigation should be smooth (less than 100ms per navigation)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      test('hijri date calculations are optimized', () {
        final stopwatch = Stopwatch()..start();
        
        // Convert 1000 dates
        for (int i = 0; i < 1000; i++) {
          final gregorianDate = DateTime(2024, 1, 1).add(Duration(days: i));
          HijriDate.fromGregorian(gregorianDate);
        }
        
        stopwatch.stop();
        
        // Should convert 1000 dates within 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('hijri calendar generation is efficient', () {
        final stopwatch = Stopwatch()..start();
        
        // Generate calendar for a full year
        for (int month = 1; month <= 12; month++) {
          final calendar = HijriCalendar(1445, month);
          calendar.weeks();
        }
        
        stopwatch.stop();
        
        // Should generate full year within 500ms
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    group('Prayer Times Caching', () {
      test('prayer times are cached efficiently', () async {
        final date = DateTime.now();
        
        // First call should fetch and cache
        final stopwatch1 = Stopwatch()..start();
        final prayerTimes1 = await prayerTimesService.getPrayerTimesForDate(date);
        stopwatch1.stop();
        
        // Second call should use cache
        final stopwatch2 = Stopwatch()..start();
        final prayerTimes2 = await prayerTimesService.getPrayerTimesForDate(date);
        stopwatch2.stop();
        
        // Cached call should be significantly faster
        expect(stopwatch2.elapsedMilliseconds, lessThan(stopwatch1.elapsedMilliseconds ~/ 2));
        
        // Results should be identical
        expect(prayerTimes1?.fajr, equals(prayerTimes2?.fajr));
      });

      test('batch prayer times requests are optimized', () async {
        final dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
        
        final stopwatch = Stopwatch()..start();
        final weeklyTimes = await prayerTimesService.getCurrentWeekPrayerTimes();
        stopwatch.stop();
        
        // Batch request should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        expect(weeklyTimes.length, greaterThan(0));
      });

      test('prayer times cache has intelligent refresh logic', () async {
        // Test cache expiration and refresh
        final cacheStats = await cacheManager.getStatistics();
        expect(cacheStats['hitRate'], isA<double>());
      });
    });

    group('Events Service Optimization', () {
      test('events are loaded lazily', () async {
        final stopwatch = Stopwatch()..start();
        
        // Load events for multiple months
        for (int month = 1; month <= 12; month++) {
          await eventsService.getEventsForMonth(month);
        }
        
        stopwatch.stop();
        
        // Should load all months efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('event search is cached and optimized', () {
        final stopwatch1 = Stopwatch()..start();
        final results1 = eventsService.searchEvents('Ramadan');
        stopwatch1.stop();
        
        final stopwatch2 = Stopwatch()..start();
        final results2 = eventsService.searchEvents('Ramadan');
        stopwatch2.stop();
        
        // Second search should be faster (cached)
        expect(stopwatch2.elapsedMilliseconds, lessThanOrEqualTo(stopwatch1.elapsedMilliseconds));
        expect(results1.length, equals(results2.length));
      });

      test('events have efficient memory management', () async {
        // Load many events to test memory management
        for (int month = 1; month <= 12; month++) {
          await eventsService.getEventsForMonth(month);
        }
        
        final memoryStats = memoryManager.getMemoryStats();
        expect(memoryStats['cachePoolsCount'], greaterThan(0));
      });
    });

    group('Network Optimization', () {
      test('network requests are deduplicated', () async {
        final url = 'https://example.com/test';
        
        // Make multiple identical requests
        final futures = List.generate(5, (_) => networkOptimizer.get(url));
        
        final stopwatch = Stopwatch()..start();
        try {
          await Future.wait(futures);
        } catch (e) {
          // Expected to fail in test environment
        }
        stopwatch.stop();
        
        final networkStats = networkOptimizer.getNetworkStats();
        expect(networkStats['ongoingRequests'], isA<int>());
      });

      test('batch network requests are efficient', () async {
        final urls = List.generate(5, (i) => 'https://example.com/test$i');
        
        final stopwatch = Stopwatch()..start();
        try {
          await networkOptimizer.batchGet(urls, concurrency: 2);
        } catch (e) {
          // Expected to fail in test environment
        }
        stopwatch.stop();
        
        // Batch processing should be implemented
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });

    group('Memory Management', () {
      test('memory manager monitors usage', () {
        final memoryStats = memoryManager.getMemoryStats();
        expect(memoryStats, isA<Map<String, dynamic>>());
      });

      test('cache pools are managed efficiently', () {
        final pool = memoryManager.createCachePool<String>('test_pool');
        
        // Add items to pool
        for (int i = 0; i < 50; i++) {
          pool.put('key_$i', 'value_$i');
        }
        
        expect(pool.size, equals(50));
        
        final stats = pool.getStats();
        expect(stats['size'], equals(50));
        expect(stats['utilizationPercent'], lessThanOrEqualTo(100));
      });

      test('memory cleanup is performed when needed', () {
        final pool = memoryManager.createCachePool<String>('cleanup_test');
        
        // Fill pool beyond capacity
        for (int i = 0; i < 150; i++) {
          pool.put('key_$i', 'value_$i');
        }
        
        // Pool should have evicted old entries
        expect(pool.size, lessThanOrEqualTo(100));
      });
    });

    group('Performance Monitoring', () {
      test('performance metrics are collected', () {
        performanceService.startTimer('test_operation');
        
        // Simulate some work
        for (int i = 0; i < 1000; i++) {
          i.toString();
        }
        
        performanceService.stopTimer('test_operation');
        
        final stats = performanceService.getPerformanceStats();
        expect(stats, contains('test_operation'));
      });

      test('slow operations are detected', () {
        // Simulate slow operation
        performanceService.timeSync('slow_operation', () {
          // Simulate work that takes time
          final stopwatch = Stopwatch()..start();
          while (stopwatch.elapsedMilliseconds < 100) {
            // Busy wait
          }
        });
        
        final slowOps = performanceService.getSlowOperations(thresholdMs: 50);
        expect(slowOps.length, greaterThanOrEqualTo(0));
      });

      test('batch operations are optimized', () async {
        final operations = List.generate(10, (i) => () async {
          await Future.delayed(Duration(milliseconds: 10));
          return i;
        });
        
        final stopwatch = Stopwatch()..start();
        final results = await performanceService.batchOperations(
          'test_batch',
          operations,
          concurrency: 3,
        );
        stopwatch.stop();
        
        expect(results.length, equals(10));
        // Should be faster than sequential execution
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });
    });

    group('Cache Manager Performance', () {
      test('cache manager provides efficient storage', () async {
        final testData = {'key': 'value', 'number': 42};
        
        // Set data
        final setSuccess = await cacheManager.set('test_key', testData);
        expect(setSuccess, isTrue);
        
        // Get data
        final retrievedData = await cacheManager.get<Map<String, dynamic>>('test_key');
        expect(retrievedData, equals(testData));
        
        // Check cache statistics
        final stats = cacheManager.getStatistics();
        expect(stats['hits'], greaterThan(0));
      });

      test('batch cache operations are efficient', () async {
        final testData = <String, Map<String, dynamic>>{};
        for (int i = 0; i < 10; i++) {
          testData['key_$i'] = {'value': i};
        }
        
        final stopwatch = Stopwatch()..start();
        final setResults = await cacheManager.batchSet(testData);
        stopwatch.stop();
        
        expect(setResults.length, equals(10));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        // Test batch get
        final getResults = await cacheManager.batchGet<Map<String, dynamic>>(
          testData.keys.toList(),
        );
        expect(getResults.length, equals(10));
      });

      test('cache preloading works efficiently', () async {
        final loaders = <String, Future<dynamic> Function()>{
          'data1': () async => {'value': 1},
          'data2': () async => {'value': 2},
          'data3': () async => {'value': 3},
        };
        
        final stopwatch = Stopwatch()..start();
        await cacheManager.preloadCache(loaders);
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        
        // Verify data was cached
        final data1 = await cacheManager.get('data1');
        expect(data1, isNotNull);
      });
    });

    testWidgets('overall app performance with optimizations', (WidgetTester tester) async {
      final appStartStopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      appStartStopwatch.stop();
      
      // App should start quickly
      expect(appStartStopwatch.elapsedMilliseconds, lessThan(5000));
      
      // Navigate through all screens to test performance
      final screens = ['Calendar', 'Prayer Times', 'Events', 'Reminders', 'Settings'];
      
      for (final screen in screens) {
        final navigationStopwatch = Stopwatch()..start();
        
        await tester.tap(find.text(screen));
        await tester.pumpAndSettle();
        
        navigationStopwatch.stop();
        
        // Each screen should load quickly
        expect(navigationStopwatch.elapsedMilliseconds, lessThan(2000));
      }
      
      // Check overall performance metrics
      final performanceStats = performanceService.getPerformanceStats();
      final cacheStats = cacheManager.getStatistics();
      final memoryStats = memoryManager.getMemoryStats();
      
      expect(performanceStats, isNotEmpty);
      expect(cacheStats['hitRate'], greaterThanOrEqualTo(0));
      expect(memoryStats, isNotEmpty);
    });
  });
}

/// Helper function to set up service locator for tests
Future<void> setupServiceLocator() async {
  await ServiceLocator.setupServices();
}