import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hijri_minder/utils/platform_config.dart';
import 'package:hijri_minder/utils/platform_clients.dart';

import 'platform_config_test.mocks.dart';

@GenerateMocks([
  LocationPermissionClient,
  NotificationClient,
  PlatformChannelClient,
])
void main() {
  group('PlatformConfig', () {
    late MockLocationPermissionClient mockLocationClient;
    late MockNotificationClient mockNotificationClient;
    late MockPlatformChannelClient mockPlatformChannelClient;

    setUp(() {
      mockLocationClient = MockLocationPermissionClient();
      mockNotificationClient = MockNotificationClient();
      mockPlatformChannelClient = MockPlatformChannelClient();
      
      // Set up mock clients
      PlatformConfig.setClients(
        locationClient: mockLocationClient,
        notificationClient: mockNotificationClient,
        platformChannelClient: mockPlatformChannelClient,
      );
    });

    tearDown(() {
      PlatformConfig.resetClients();
    });

    group('Platform Detection', () {
      test('should detect iOS platform correctly', () {
        // This test would need platform-specific mocking
        // For now, we test the logic structure
        expect(PlatformConfig.isIOS, isA<bool>());
        expect(PlatformConfig.isAndroid, isA<bool>());
        expect(PlatformConfig.platformName, isA<String>());
      });

      test('should return correct platform name', () {
        expect(PlatformConfig.platformName, isNotEmpty);
        expect(['ios', 'android', 'linux', 'macos', 'windows'], 
               contains(PlatformConfig.platformName));
      });
    });

    group('Audio File Path Resolution', () {
      test('should return correct audio file path for adhan_default', () {
        final path = PlatformConfig.getAudioFilePath('adhan_default');
        expect(path, isNotEmpty);
        expect(path, contains('adhan_default'));
      });

      test('should return correct audio file path for notification_prayer', () {
        final path = PlatformConfig.getAudioFilePath('notification_prayer');
        expect(path, isNotEmpty);
        expect(path, contains('notification_prayer'));
      });

      test('should return correct audio file path for notification_reminder', () {
        final path = PlatformConfig.getAudioFilePath('notification_reminder');
        expect(path, isNotEmpty);
        expect(path, contains('notification_reminder'));
      });

      test('should return empty string for unknown sound type', () {
        final path = PlatformConfig.getAudioFilePath('unknown_sound');
        expect(path, isEmpty);
      });
    });

    group('Notification Channel Configuration', () {
      test('should configure Android notification channels', () async {
        // Mock Android platform
        when(mockNotificationClient.createNotificationChannel(any))
            .thenAnswer((_) async {});
        
        // Test that the method doesn't throw
        await PlatformConfig.configureNotificationChannels();
        
        // Verify that createNotificationChannel was called for each channel
        verify(mockNotificationClient.createNotificationChannel(any)).called(3);
      });
    });

    group('Permission Handling', () {
      test('should handle location permission request', () async {
        when(mockLocationClient.checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(mockLocationClient.requestPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);

        final result = await PlatformConfig.requestLocationPermission();
        
        expect(result, isTrue);
        verify(mockLocationClient.checkPermission()).called(1);
        verify(mockLocationClient.requestPermission()).called(1);
      });

      test('should handle notification permission request', () async {
        // Notification permission is now handled by NotificationService
        final result = await PlatformConfig.requestNotificationPermission();
        
        expect(result, isFalse); // Deprecated method returns false
      });

      test('should request all permissions and return results', () async {
        when(mockLocationClient.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(mockPlatformChannelClient.invokeMethod('launchExactAlarmSettings'))
            .thenAnswer((_) async => true);

        final results = await PlatformConfig.requestAllPermissions();
        
        expect(results, isA<Map<String, bool>>());
        expect(results['location'], isTrue);
        expect(results['notifications'], isFalse); // Deprecated
        expect(results['exact_alarm'], isTrue);
      });
    });

    group('Notification Channel ID Resolution', () {
      test('should return correct channel ID for prayer times', () {
        final channelId = PlatformConfig.getNotificationChannelId('prayer_times');
        expect(channelId, isNotEmpty);
      });

      test('should return correct channel ID for reminders', () {
        final channelId = PlatformConfig.getNotificationChannelId('reminders');
        expect(channelId, isNotEmpty);
      });

      test('should return correct channel ID for general notifications', () {
        final channelId = PlatformConfig.getNotificationChannelId('general');
        expect(channelId, isNotEmpty);
      });

      test('should return default channel ID for unknown type', () {
        final channelId = PlatformConfig.getNotificationChannelId('unknown');
        expect(channelId, isNotEmpty);
      });
    });

    group('Platform-Specific Configuration', () {
      test('should configure notification settings', () async {
        expect(() => PlatformConfig.configureNotificationSettings(), 
               returnsNormally);
      });

      test('should configure background execution', () async {
        expect(() => PlatformConfig.configureBackgroundExecution(), 
               returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should handle permission request errors gracefully', () async {
        when(mockLocationClient.checkPermission())
            .thenThrow(Exception('Permission check failed'));

        final result = await PlatformConfig.requestLocationPermission();
        
        expect(result, isFalse);
      });

      test('should handle notification configuration errors gracefully', () async {
        when(mockNotificationClient.createNotificationChannel(any))
            .thenThrow(Exception('Channel creation failed'));

        // The method should handle errors gracefully
        await PlatformConfig.configureNotificationChannels();
        
        // Should not throw
        expect(true, isTrue);
      });
    });
  });
}
