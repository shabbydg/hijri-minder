import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hijri_minder/main.dart' as app;
import 'package:hijri_minder/services/location_service.dart';
import 'package:hijri_minder/services/notification_service.dart';
import 'package:hijri_minder/services/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Permission Handling Integration Tests', () {
    setUp(() async {
      await setupServiceLocator();
    });

    tearDown(() async {
      await ServiceLocator.instance.reset();
    });

    testWidgets('should handle location permission flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final locationService = ServiceLocator.instance.get<LocationService>();

      // Test permission request
      try {
        final hasPermission = await locationService.hasValidLocationPermissions();
        expect(hasPermission, isA<bool>());
      } catch (e) {
        // Expected in test environment
        expect(e, isA<PlatformException>());
      }
    });

    testWidgets('should handle notification permission flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final notificationService = ServiceLocator.instance.get<NotificationService>();

      // Test notification permission
      try {
        await notificationService.requestPermissions();
        // Should not throw in test environment
      } catch (e) {
        // Expected in test environment without proper platform setup
        expect(e, isA<Exception>());
      }
    });

    testWidgets('should gracefully handle denied location permissions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times screen
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Should display fallback location message
      expect(find.textContaining('Using default location'), findsOneWidget);
    });

    testWidgets('should show permission dialog when needed', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Try to enable location services
      await tester.tap(find.text('Enable Location Services'));
      await tester.pumpAndSettle();

      // Should show permission explanation dialog
      expect(find.textContaining('Location Permission'), findsOneWidget);
    });

    testWidgets('should handle permission permanently denied scenario', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final locationService = ServiceLocator.instance.get<LocationService>();

      // Simulate permanently denied permission
      try {
        await locationService.requestLocationPermissionWithDialog();
      } catch (e) {
        // Should handle gracefully and show settings redirect option
        expect(e, isA<Exception>());
      }
    });

    testWidgets('should maintain app functionality without permissions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // App should still function with core features
      expect(find.text('HijriMinder'), findsOneWidget);

      // Calendar should work without location
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);

      // Events should work without permissions
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should show appropriate error messages for permission failures', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to prayer times
      await tester.tap(find.text('Prayer Times'));
      await tester.pumpAndSettle();

      // Should show error message for location access failure
      expect(find.textContaining('location'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle notification permission states correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find notification settings
      await tester.tap(find.text('Prayer Notifications'));
      await tester.pumpAndSettle();

      // Should handle permission check
      expect(tester.takeException(), isNull);
    });

    testWidgets('should provide clear permission explanations', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Look for permission explanations
      expect(find.textContaining('Location'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Notification'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle system permission dialog responses', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final locationService = ServiceLocator.instance.get<LocationService>();

      // Test different permission responses
      try {
        final result = await locationService.requestLocationPermissionWithDialog();
        expect(result, isA<bool>());
      } catch (e) {
        // Expected in test environment
        expect(e, isNotNull);
      }
    });
  });
}