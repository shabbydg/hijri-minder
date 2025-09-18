import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'platform_clients.dart';

/// Platform configuration utility class for handling platform-specific settings
/// and configurations for the HijriMinder app.
class PlatformConfig {
  static const MethodChannel _channel = MethodChannel('com.hijriminder/platform_config');
  
  // Dependency injection clients
  static LocationPermissionClient _locationClient = DefaultLocationPermissionClient();
  static NotificationClient _notificationClient = DefaultNotificationClient();
  static PlatformChannelClient _platformChannelClient = DefaultPlatformChannelClient();
  
  /// Set custom clients for testing
  static void setClients({
    LocationPermissionClient? locationClient,
    NotificationClient? notificationClient,
    PlatformChannelClient? platformChannelClient,
  }) {
    if (locationClient != null) _locationClient = locationClient;
    if (notificationClient != null) _notificationClient = notificationClient;
    if (platformChannelClient != null) _platformChannelClient = platformChannelClient;
  }
  
  /// Reset to default clients
  static void resetClients() {
    _locationClient = DefaultLocationPermissionClient();
    _notificationClient = DefaultNotificationClient();
    _platformChannelClient = DefaultPlatformChannelClient();
  }
  
  /// Detects the current platform (iOS/Android/Web)
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWeb => kIsWeb;
  
  /// Gets the platform name as a string
  static String get platformName {
    if (kIsWeb) return 'web';
    return Platform.operatingSystem;
  }
  
  /// Configures notification channels for Android
  static Future<void> configureNotificationChannels() async {
    if (!isAndroid) return;
    
    // Prayer Times Channel
    const prayerTimesChannel = AndroidNotificationChannel(
      'prayer_times',
      'Prayer Times',
      description: 'Notifications for prayer times and Adhan calls',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan_default'),
    );
    
    // Islamic Reminders Channel
    const remindersChannel = AndroidNotificationChannel(
      'islamic_reminders',
      'Islamic Reminders',
      description: 'Notifications for Islamic events, birthdays, and anniversaries',
      importance: Importance.defaultImportance,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_reminder'),
    );
    
    // General Notifications Channel
    const generalChannel = AndroidNotificationChannel(
      'general_notifications',
      'General Notifications',
      description: 'General app notifications and updates',
      importance: Importance.low,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_prayer'),
    );
    
    await _notificationClient.createNotificationChannel(prayerTimesChannel);
    await _notificationClient.createNotificationChannel(remindersChannel);
    await _notificationClient.createNotificationChannel(generalChannel);
  }
  
  /// Requests location permission with platform-specific handling
  static Future<bool> requestLocationPermission() async {
    if (isIOS) {
      return await _requestIOSLocationPermission();
    } else if (isAndroid) {
      return await _requestAndroidLocationPermission();
    }
    return false;
  }
  
  /// Requests notification permission with platform-specific handling
  /// @deprecated Use NotificationService.requestPermissions() instead
  static Future<bool> requestNotificationPermission() async {
    // This method is deprecated - use NotificationService.requestPermissions() instead
    return false;
  }
  
  /// Gets the platform-specific audio file path for notifications
  static String getAudioFilePath(String soundType) {
    switch (soundType) {
      case 'adhan_default':
        return isIOS 
            ? 'adhan_default.aiff'
            : 'android.resource://com.hijriminder.hijri_minder/raw/adhan_default';
      case 'notification_prayer':
        return isIOS 
            ? 'notification_prayer.aiff'
            : 'android.resource://com.hijriminder.hijri_minder/raw/notification_prayer';
      case 'notification_reminder':
        return isIOS 
            ? 'notification_reminder.aiff'
            : 'android.resource://com.hijriminder.hijri_minder/raw/notification_reminder';
      default:
        return '';
    }
  }
  
  /// Configures platform-specific notification settings
  static Future<void> configureNotificationSettings() async {
    if (isIOS) {
      await _configureIOSNotificationSettings();
    } else if (isAndroid) {
      await _configureAndroidNotificationSettings();
    }
  }
  
  /// Handles platform-specific permission flows
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};
    
    // Request location permission
    results['location'] = await requestLocationPermission();
    
    // Request notification permission
    // Note: Use NotificationService.requestPermissions() instead
    results['notifications'] = false;
    
    // Request additional permissions based on platform
    if (isAndroid) {
      results['exact_alarm'] = await _requestAndroidExactAlarmPermission();
    }
    
    return results;
  }
  
  /// Gets platform-specific notification channel ID
  static String getNotificationChannelId(String notificationType) {
    if (!isAndroid) return '';
    
    switch (notificationType) {
      case 'prayer_times':
        return 'prayer_times';
      case 'reminders':
        return 'islamic_reminders';
      case 'general':
        return 'general_notifications';
      default:
        return 'general_notifications';
    }
  }
  
  /// Configures platform-specific background execution
  static Future<void> configureBackgroundExecution() async {
    if (isIOS) {
      await _configureIOSBackgroundExecution();
    } else if (isAndroid) {
      await _configureAndroidBackgroundExecution();
    }
  }
  
  // Private methods for iOS-specific configurations
  static Future<bool> _requestIOSLocationPermission() async {
    try {
      final status = await _locationClient.checkPermission();
      if (status == LocationPermission.denied) {
        final newStatus = await _locationClient.requestPermission();
        return newStatus == LocationPermission.whileInUse || 
               newStatus == LocationPermission.always;
      }
      return status == LocationPermission.whileInUse || 
             status == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }
  
  
  static Future<void> _configureIOSNotificationSettings() async {
    // iOS-specific notification configuration
    // This can be extended with additional iOS-specific settings
  }
  
  static Future<void> _configureIOSBackgroundExecution() async {
    // iOS-specific background execution configuration
    // This can be extended with additional iOS-specific settings
  }
  
  // Private methods for Android-specific configurations
  static Future<bool> _requestAndroidLocationPermission() async {
    try {
      final status = await _locationClient.checkPermission();
      if (status == LocationPermission.denied) {
        final newStatus = await _locationClient.requestPermission();
        return newStatus == LocationPermission.whileInUse || 
               newStatus == LocationPermission.always;
      }
      return status == LocationPermission.whileInUse || 
             status == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }
  
  
  static Future<bool> _requestAndroidExactAlarmPermission() async {
    try {
      // For Android 12+, exact alarm permission requires user to go to settings
      // This method will launch the settings intent
      return await _launchExactAlarmSettings();
    } catch (e) {
      return false;
    }
  }

  /// Launch Android exact alarm settings intent
  static Future<bool> _launchExactAlarmSettings() async {
    try {
      await _platformChannelClient.invokeMethod('launchExactAlarmSettings');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> _configureAndroidNotificationSettings() async {
    // Android-specific notification configuration
    // This can be extended with additional Android-specific settings
  }
  
  static Future<void> _configureAndroidBackgroundExecution() async {
    // Android-specific background execution configuration
    // This can be extended with additional Android-specific settings
  }
}
