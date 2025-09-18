import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../services/prayer_times_service.dart' as pts;
import '../models/reminder.dart';
import '../models/app_settings.dart';

/// Service for managing local notifications for prayers and reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      final bool? result = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = result ?? false;
      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      return false;
    }
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('Notification tapped with payload: $payload');
      // Handle navigation based on payload
      _handleNotificationNavigation(payload);
    }
  }

  /// Handle navigation when notification is tapped
  void _handleNotificationNavigation(String payload) {
    // Parse payload and navigate accordingly
    // Format: "type:prayer" or "type:reminder:id"
    final parts = payload.split(':');
    if (parts.isNotEmpty) {
      switch (parts[0]) {
        case 'prayer':
          // Navigate to prayer times screen
          debugPrint('Navigate to prayer times screen');
          break;
        case 'reminder':
          if (parts.length > 1) {
            final reminderId = parts[1];
            debugPrint('Navigate to reminder details: $reminderId');
          }
          break;
      }
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (Platform.isIOS) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? result = await androidImplementation?.requestNotificationsPermission();
      return result ?? false;
    }

    return true;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }

    return true; // iOS permissions are handled differently
  }

  /// Schedule prayer time notifications
  Future<void> schedulePrayerNotifications(
    dynamic prayerTimes, // Accept both PrayerTimes models
    AppSettings settings,
  ) async {
    if (!settings.enablePrayerNotifications || !_isInitialized) {
      return;
    }

    // Cancel existing prayer notifications
    await cancelPrayerNotifications();

    final prayers = [
      {'name': 'Sihori', 'time': _getTimeFromPrayerTimes(prayerTimes, 'sihori')},
      {'name': 'Fajr', 'time': _getTimeFromPrayerTimes(prayerTimes, 'fajr')},
      {'name': 'Sunrise', 'time': _getTimeFromPrayerTimes(prayerTimes, 'sunrise')},
      {'name': 'Zawaal', 'time': _getTimeFromPrayerTimes(prayerTimes, 'zawaal')},
      {'name': 'Zohr End', 'time': _getTimeFromPrayerTimes(prayerTimes, 'zohrEnd')},
      {'name': 'Asr End', 'time': _getTimeFromPrayerTimes(prayerTimes, 'asrEnd')},
      {'name': 'Maghrib', 'time': _getTimeFromPrayerTimes(prayerTimes, 'maghrib')},
      {'name': 'Maghrib End', 'time': _getTimeFromPrayerTimes(prayerTimes, 'maghribEnd')},
      {'name': 'Nisful Layl', 'time': _getTimeFromPrayerTimes(prayerTimes, 'nisfulLayl')},
      {'name': 'Nisful Layl End', 'time': _getTimeFromPrayerTimes(prayerTimes, 'nisfulLaylEnd')},
    ];

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final prayerName = prayer['name'] as String;
      final prayerTime = prayer['time'] as String;

      if (prayerTime.isNotEmpty) {
        await _schedulePrayerNotification(
          id: 1000 + i, // Prayer notification IDs start from 1000
          prayerName: prayerName,
          prayerTime: prayerTime,
          date: _getDateFromPrayerTimes(prayerTimes),
          advanceMinutes: settings.prayerNotificationAdvance.inMinutes,
          enableAdhan: settings.enableAdhanSounds,
        );
      }
    }
  }

  /// Schedule a single prayer notification
  Future<void> _schedulePrayerNotification({
    required int id,
    required String prayerName,
    required String prayerTime,
    required DateTime date,
    required int advanceMinutes,
    required bool enableAdhan,
  }) async {
    try {
      final scheduledTime = _parseTimeString(prayerTime, date);
      if (scheduledTime == null) return;

      final notificationTime = scheduledTime.subtract(
        Duration(minutes: advanceMinutes),
      );

      // Only schedule if the notification time is in the future
      if (notificationTime.isAfter(DateTime.now())) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Prayer Time Reminder',
          '$prayerName time is in $advanceMinutes minutes',
          _convertToTZDateTime(notificationTime),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_times',
              'Prayer Times',
              channelDescription: 'Notifications for prayer times and Adhan calls',
              importance: Importance.high,
              priority: Priority.high,
              sound: enableAdhan 
                  ? const RawResourceAndroidNotificationSound('adhan_default')
                  : null,
              playSound: true,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(
              sound: enableAdhan ? 'adhan_default.aiff' : null,
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'type:prayer',
        );
      }
    } catch (e) {
      debugPrint('Error scheduling prayer notification for $prayerName: $e');
    }
  }

  /// Schedule reminder notifications (default uses reminder.notificationAdvance)
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    return scheduleReminderNotificationWithAdvance(reminder, advance: reminder.notificationAdvance);
  }

  /// Schedule reminder notification with specific advance time
  Future<void> scheduleReminderNotificationWithAdvance(Reminder reminder, {Duration? advance}) async {
    if (!_isInitialized) return;

    try {
      final advanceTime = advance ?? reminder.notificationAdvance;
      final notificationTime = reminder.gregorianDate.subtract(advanceTime);

      // Only schedule if the notification time is in the future
      if (notificationTime.isAfter(DateTime.now())) {
        // Create unique notification ID by combining reminder ID with advance time
        final notificationId = reminder.id.hashCode ^ advanceTime.inMinutes;
        
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'Hijri Reminder',
          _buildReminderMessage(reminder),
          _convertToTZDateTime(notificationTime),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'islamic_reminders',
              'Islamic Reminders',
              channelDescription: 'Notifications for Islamic events, birthdays, and anniversaries',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'type:reminder:${reminder.id}',
        );
      }
    } catch (e) {
      debugPrint('Error scheduling reminder notification: $e');
    }
  }

  /// Build reminder notification message
  String _buildReminderMessage(Reminder reminder) {
    final hijriDateStr = '${reminder.hijriDate.day}/${reminder.hijriDate.month}/${reminder.hijriDate.year}';
    final typeStr = reminder.type.toString().split('.').last;
    
    return '${reminder.title} - $typeStr on $hijriDateStr AH';
  }

  /// Cancel all prayer notifications
  Future<void> cancelPrayerNotifications() async {
    if (!_isInitialized) return;

    // Cancel prayer notification IDs (1000-1009)
    for (int i = 1000; i < 1010; i++) {
      await _flutterLocalNotificationsPlugin.cancel(i);
    }
  }

  /// Cancel a specific reminder notification
  Future<void> cancelReminderNotification(String reminderId) async {
    if (!_isInitialized) return;

    await _flutterLocalNotificationsPlugin.cancel(reminderId.hashCode);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Parse time string to DateTime
  DateTime? _parseTimeString(String timeStr, DateTime date) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      debugPrint('Error parsing time string: $timeStr');
      return null;
    }
  }

  /// Convert DateTime to TZDateTime
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local;
    return tz.TZDateTime.from(dateTime, location);
  }

  /// Get time from prayer times object (handles both model types)
  String _getTimeFromPrayerTimes(dynamic prayerTimes, String field) {
    try {
      switch (field) {
        case 'sihori':
          return prayerTimes.sihori ?? '';
        case 'fajr':
          return prayerTimes.fajr ?? '';
        case 'sunrise':
          return prayerTimes.sunrise ?? '';
        case 'zawaal':
          return prayerTimes.zawaal ?? '';
        case 'zohrEnd':
          return prayerTimes.zohrEnd ?? '';
        case 'asrEnd':
          return prayerTimes.asrEnd ?? '';
        case 'maghrib':
          return prayerTimes.maghrib ?? '';
        case 'maghribEnd':
          return prayerTimes.maghribEnd ?? '';
        case 'nisfulLayl':
          return prayerTimes.nisfulLayl ?? '';
        case 'nisfulLaylEnd':
          return prayerTimes.nisfulLaylEnd ?? '';
        default:
          return '';
      }
    } catch (e) {
      return '';
    }
  }

  /// Get date from prayer times object (handles both model types)
  DateTime _getDateFromPrayerTimes(dynamic prayerTimes) {
    try {
      return prayerTimes.date ?? DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Show immediate notification (for testing)
  Future<void> showTestNotification() async {
    if (!_isInitialized) return;

    await _flutterLocalNotificationsPlugin.show(
      0,
      'HijriMinder Test',
      'Notification system is working correctly',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_notifications',
          'General Notifications',
          channelDescription: 'General app notifications and updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}