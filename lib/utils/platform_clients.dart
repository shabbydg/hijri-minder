import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Interface for location permission operations
abstract class LocationPermissionClient {
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
}

/// Interface for notification operations
abstract class NotificationClient {
  Future<bool> initialize();
  Future<bool> requestPermissions();
  Future<bool> areNotificationsEnabled();
  Future<void> createNotificationChannel(AndroidNotificationChannel channel);
}

/// Interface for platform channel operations
abstract class PlatformChannelClient {
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]);
}

/// Default implementation using actual platform APIs
class DefaultLocationPermissionClient implements LocationPermissionClient {
  @override
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
}

/// Default implementation using actual notification APIs
class DefaultNotificationClient implements NotificationClient {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<bool> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    final bool? result = await _plugin.initialize(initializationSettings);
    return result ?? false;
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final bool? result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? result = await androidImplementation?.requestNotificationsPermission();
      return result ?? false;
    }
    return true;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  @override
  Future<void> createNotificationChannel(AndroidNotificationChannel channel) async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

/// Default implementation using actual platform channel APIs
class DefaultPlatformChannelClient implements PlatformChannelClient {
  static const MethodChannel _channel = MethodChannel('com.hijriminder/platform_config');

  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    return await _channel.invokeMethod<T>(method, arguments);
  }
}
