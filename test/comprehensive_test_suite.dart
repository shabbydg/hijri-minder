import 'package:flutter_test/flutter_test.dart';

// Import all test files to ensure they run as part of the comprehensive suite
import 'models/hijri_date_test.dart' as hijri_date_tests;
import 'models/hijri_calendar_test.dart' as hijri_calendar_tests;
import 'models/prayer_times_test.dart' as prayer_times_tests;
import 'models/islamic_event_test.dart' as islamic_event_tests;
import 'models/app_settings_test.dart' as app_settings_tests;
import 'models/reminder_test.dart' as reminder_tests;
import 'models/message_template_test.dart' as message_template_tests;
import 'models/model_validation_test.dart' as model_validation_tests;

import 'services/prayer_times_service_test.dart' as prayer_times_service_tests;
import 'services/location_service_test.dart' as location_service_tests;
import 'services/events_service_test.dart' as events_service_tests;
import 'services/settings_service_test.dart' as settings_service_tests;
import 'services/reminder_service_test.dart' as reminder_service_tests;
import 'services/notification_service_test.dart' as notification_service_tests;
import 'services/message_templates_service_test.dart' as message_templates_service_tests;
import 'services/sharing_service_test.dart' as sharing_service_tests;
import 'services/localization_service_test.dart' as localization_service_tests;
import 'services/cache_service_test.dart' as cache_service_tests;
import 'services/offline_manager_test.dart' as offline_manager_tests;

import 'screens/calendar_screen_test.dart' as calendar_screen_tests;
import 'screens/prayer_times_screen_test.dart' as prayer_times_screen_tests;
import 'screens/events_screen_test.dart' as events_screen_tests;
import 'screens/reminder_screen_test.dart' as reminder_screen_tests;
import 'screens/settings_screen_test.dart' as settings_screen_tests;

import 'utils/hijri_date_converter_test.dart' as hijri_date_converter_tests;
import 'utils/arabic_numerals_test.dart' as arabic_numerals_tests;
import 'utils/input_validator_test.dart' as input_validator_tests;
import 'utils/error_handler_test.dart' as error_handler_tests;

import 'integration/hijri_calendar_integration_test.dart' as hijri_calendar_integration_tests;
import 'integration/prayer_times_integration_test.dart' as prayer_times_integration_tests;
import 'integration/calendar_screen_integration_test.dart' as calendar_screen_integration_tests;
import 'integration/events_screen_integration_test.dart' as events_screen_integration_tests;
import 'integration/settings_screen_integration_test.dart' as settings_screen_integration_tests;
import 'integration/task13_localization_integration_test.dart' as localization_integration_tests;
import 'integration/task15_offline_integration_test.dart' as offline_integration_tests;
import 'integration/task16_error_handling_integration_test.dart' as error_handling_integration_tests;
import 'integration/permission_handling_integration_test.dart' as permission_handling_integration_tests;
import 'integration/rtl_localization_integration_test.dart' as rtl_localization_integration_tests;
import 'integration/complete_user_flows_test.dart' as complete_user_flows_tests;
import 'integration/task18_performance_optimization_test.dart' as task18_performance_tests;

import 'widgets/error_display_test.dart' as error_display_widget_tests;
import 'widgets/offline_indicator_test.dart' as offline_indicator_widget_tests;
import 'widgets/message_template_selector_test.dart' as message_template_selector_widget_tests;
import 'widgets/sharing_dialog_test.dart' as sharing_dialog_widget_tests;

import 'services/logging_service_test.dart' as logging_service_tests;

import 'performance/performance_test_suite.dart' as performance_tests;
import 'accessibility/accessibility_test_suite.dart' as accessibility_tests;

/// Comprehensive Test Suite for HijriMinder
/// 
/// This test suite covers all aspects of the application:
/// - Unit tests for all models
/// - Service layer tests with mocked dependencies
/// - Widget tests for UI components
/// - Integration tests for complete user flows
/// - End-to-end tests for offline scenarios and permission handling
/// - Localization and RTL support tests
void main() {
  group('Comprehensive HijriMinder Test Suite', () {
    group('Model Tests', () {
      hijri_date_tests.main();
      hijri_calendar_tests.main();
      prayer_times_tests.main();
      islamic_event_tests.main();
      app_settings_tests.main();
      reminder_tests.main();
      message_template_tests.main();
      model_validation_tests.main();
    });

    group('Service Tests', () {
      prayer_times_service_tests.main();
      location_service_tests.main();
      events_service_tests.main();
      settings_service_tests.main();
      reminder_service_tests.main();
      notification_service_tests.main();
      message_templates_service_tests.main();
      sharing_service_tests.main();
      localization_service_tests.main();
      cache_service_tests.main();
      offline_manager_tests.main();
      logging_service_tests.main();
    });

    group('Widget Tests', () {
      calendar_screen_tests.main();
      prayer_times_screen_tests.main();
      events_screen_tests.main();
      reminder_screen_tests.main();
      settings_screen_tests.main();
      
      // Widget tests
      error_display_widget_tests.main();
      offline_indicator_widget_tests.main();
      message_template_selector_widget_tests.main();
      sharing_dialog_widget_tests.main();
    });

    group('Utility Tests', () {
      hijri_date_converter_tests.main();
      arabic_numerals_tests.main();
      input_validator_tests.main();
      error_handler_tests.main();
    });

    group('Integration Tests', () {
      hijri_calendar_integration_tests.main();
      prayer_times_integration_tests.main();
      calendar_screen_integration_tests.main();
      events_screen_integration_tests.main();
      settings_screen_integration_tests.main();
      localization_integration_tests.main();
      offline_integration_tests.main();
      error_handling_integration_tests.main();
      permission_handling_integration_tests.main();
      rtl_localization_integration_tests.main();
      complete_user_flows_tests.main();
      task18_performance_tests.main();
    });

    group('Performance Tests', () {
      performance_tests.main();
    });

    group('Accessibility Tests', () {
      accessibility_tests.main();
    });
  });
}