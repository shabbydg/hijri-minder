/// Test Configuration for HijriMinder Comprehensive Test Suite
/// 
/// This file contains configuration and utilities for running the complete test suite
library test_config;

import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/service_locator.dart';

/// Test configuration class to manage test setup and teardown
class TestConfig {
  static bool _isInitialized = false;

  /// Initialize test environment
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupServiceLocator();
    _isInitialized = true;
  }

  /// Clean up test environment
  static Future<void> cleanup() async {
    if (!_isInitialized) return;
    
    await ServiceLocator.instance.reset();
    _isInitialized = false;
  }

  /// Setup for each test
  static Future<void> setUp() async {
    await initialize();
  }

  /// Teardown for each test
  static Future<void> tearDown() async {
    // Reset any test-specific state but keep services initialized
  }

  /// Complete cleanup (for test suite teardown)
  static Future<void> tearDownAll() async {
    await cleanup();
  }
}

/// Test categories for organizing test execution
enum TestCategory {
  unit,
  widget,
  integration,
  endToEnd,
  performance,
  accessibility,
  localization,
}

/// Test suite configuration
class TestSuiteConfig {
  static const Map<TestCategory, List<String>> testFiles = {
    TestCategory.unit: [
      'test/models/',
      'test/services/',
      'test/utils/',
    ],
    TestCategory.widget: [
      'test/screens/',
      'test/widgets/',
    ],
    TestCategory.integration: [
      'test/integration/',
    ],
    TestCategory.endToEnd: [
      'test/integration/complete_user_flows_test.dart',
      'test/integration/permission_handling_integration_test.dart',
    ],
    TestCategory.localization: [
      'test/integration/rtl_localization_integration_test.dart',
      'test/integration/task13_localization_integration_test.dart',
    ],
  };

  /// Get test timeout for different categories
  static Duration getTimeout(TestCategory category) {
    switch (category) {
      case TestCategory.unit:
        return const Duration(seconds: 30);
      case TestCategory.widget:
        return const Duration(seconds: 60);
      case TestCategory.integration:
        return const Duration(minutes: 2);
      case TestCategory.endToEnd:
        return const Duration(minutes: 5);
      case TestCategory.performance:
        return const Duration(minutes: 3);
      case TestCategory.accessibility:
        return const Duration(minutes: 2);
      case TestCategory.localization:
        return const Duration(minutes: 3);
    }
  }
}

/// Test utilities
class TestUtils {
  /// Pump and settle with custom timeout
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Wait for condition with timeout
  static Future<void> waitForCondition(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (!condition() && stopwatch.elapsed < timeout) {
      await Future.delayed(interval);
    }
    
    if (!condition()) {
      throw TimeoutException('Condition not met within timeout', timeout);
    }
  }

  /// Create test widget with proper setup
  static Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
      localizationsDelegates: const [
        // Add localization delegates if needed
      ],
    );
  }
}

/// Mock data for tests
class TestData {
  static const sampleHijriDate = '15 Ramadan 1445';
  static const sampleGregorianDate = '2024-03-25';
  
  static const samplePrayerTimes = {
    'fajr': '05:30',
    'sunrise': '06:45',
    'dhuhr': '12:15',
    'asr': '15:30',
    'maghrib': '18:00',
    'isha': '19:15',
  };

  static const sampleLocation = {
    'latitude': 21.3891,
    'longitude': 39.8579,
    'city': 'Mecca',
    'country': 'Saudi Arabia',
  };

  static const sampleReminder = {
    'id': 'test-reminder-1',
    'title': 'Test Birthday',
    'description': 'John Doe Birthday',
    'hijriDate': '15 Shawwal 1445',
    'type': 'birthday',
    'isActive': true,
  };
}