import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'subscription_types.dart';
class ReminderPreferences {
  final List<String> preferredCalendarTypes;
  final String primaryCalendarType;
  final List<Duration> defaultAdvanceNotifications;
  final Map<String, List<Duration>> notificationTimes;
  final String defaultReminderType;
  final bool enableRecurring;
  final List<String> defaultMessageTemplates;
  final bool enableCustomMessages;

  const ReminderPreferences({
    this.preferredCalendarTypes = const ['hijri', 'gregorian'],
    this.primaryCalendarType = 'hijri',
    this.defaultAdvanceNotifications = const [
      Duration(minutes: 15),
      Duration(hours: 1),
      Duration(days: 1),
    ],
    this.notificationTimes = const {},
    this.defaultReminderType = 'prayer',
    this.enableRecurring = true,
    this.defaultMessageTemplates = const [],
    this.enableCustomMessages = true,
  });

  factory ReminderPreferences.fromJson(Map<String, dynamic> json) {
    List<Duration> _parseDurations(dynamic v) {
      if (v is List) {
        return v.map((e) => Duration(minutes: (e as num).toInt())).toList();
      }
      return const [Duration(minutes: 15), Duration(hours: 1), Duration(days: 1)];
    }

    Map<String, List<Duration>> _parseTimes(dynamic v) {
      if (v is Map<String, dynamic>) {
        return v.map((k, value) => MapEntry(k, _parseDurations(value)));
      }
      return const {};
    }

    return ReminderPreferences(
      preferredCalendarTypes: List<String>.from(json['preferredCalendarTypes'] ?? ['hijri', 'gregorian']),
      primaryCalendarType: json['primaryCalendarType'] ?? 'hijri',
      defaultAdvanceNotifications: _parseDurations(json['defaultAdvanceNotifications']),
      notificationTimes: _parseTimes(json['notificationTimes']),
      defaultReminderType: json['defaultReminderType'] ?? 'prayer',
      enableRecurring: json['enableRecurring'] ?? true,
      defaultMessageTemplates: List<String>.from(json['defaultMessageTemplates'] ?? []),
      enableCustomMessages: json['enableCustomMessages'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredCalendarTypes': preferredCalendarTypes,
      'primaryCalendarType': primaryCalendarType,
      'defaultAdvanceNotifications': defaultAdvanceNotifications.map((d) => d.inMinutes).toList(),
      'notificationTimes': notificationTimes.map((k, v) => MapEntry(k, v.map((d) => d.inMinutes).toList())),
      'defaultReminderType': defaultReminderType,
      'enableRecurring': enableRecurring,
      'defaultMessageTemplates': defaultMessageTemplates,
      'enableCustomMessages': enableCustomMessages,
    };
  }

  /// Convert to Firestore-compatible format
  Map<String, dynamic> toFirestore() {
    return {
      'preferredCalendarTypes': preferredCalendarTypes,
      'primaryCalendarType': primaryCalendarType,
      'defaultAdvanceNotifications': defaultAdvanceNotifications.map((d) => d.inMinutes).toList(),
      'notificationTimes': notificationTimes.map((key, value) {
        return MapEntry(key, value.map((d) => d.inMinutes).toList());
      }),
      'defaultReminderType': defaultReminderType,
      'enableRecurring': enableRecurring,
      'defaultMessageTemplates': defaultMessageTemplates,
      'enableCustomMessages': enableCustomMessages,
    };
  }

  /// Create from Firestore data
  factory ReminderPreferences.fromFirestore(Map<String, dynamic> data) {
    // Parse default advance notifications
    List<Duration> defaultAdvanceNotifications = [
      const Duration(minutes: 15),
      const Duration(hours: 1),
      const Duration(days: 1),
    ];
    if (data['defaultAdvanceNotifications'] != null) {
      defaultAdvanceNotifications = (data['defaultAdvanceNotifications'] as List)
          .map((e) => Duration(minutes: e as int))
          .toList();
    }

    // Parse notification times
    Map<String, List<Duration>> notificationTimes = {};
    if (data['notificationTimes'] != null) {
      final timesMap = data['notificationTimes'] as Map<String, dynamic>;
      notificationTimes = timesMap.map((key, value) {
        final durations = (value as List).map((e) => Duration(minutes: e as int)).toList();
        return MapEntry(key, durations);
      });
    }

    return ReminderPreferences(
      preferredCalendarTypes: List<String>.from(data['preferredCalendarTypes'] ?? ['hijri', 'gregorian']),
      primaryCalendarType: data['primaryCalendarType'] ?? 'hijri',
      defaultAdvanceNotifications: defaultAdvanceNotifications,
      notificationTimes: notificationTimes,
      defaultReminderType: data['defaultReminderType'] ?? 'prayer',
      enableRecurring: data['enableRecurring'] ?? true,
      defaultMessageTemplates: List<String>.from(data['defaultMessageTemplates'] ?? []),
      enableCustomMessages: data['enableCustomMessages'] ?? true,
    );
  }

  ReminderPreferences copyWith({
    List<String>? preferredCalendarTypes,
    String? primaryCalendarType,
    List<Duration>? defaultAdvanceNotifications,
    Map<String, List<Duration>>? notificationTimes,
    String? defaultReminderType,
    bool? enableRecurring,
    List<String>? defaultMessageTemplates,
    bool? enableCustomMessages,
  }) {
    return ReminderPreferences(
      preferredCalendarTypes: preferredCalendarTypes ?? this.preferredCalendarTypes,
      primaryCalendarType: primaryCalendarType ?? this.primaryCalendarType,
      defaultAdvanceNotifications: defaultAdvanceNotifications ?? this.defaultAdvanceNotifications,
      notificationTimes: notificationTimes ?? this.notificationTimes,
      defaultReminderType: defaultReminderType ?? this.defaultReminderType,
      enableRecurring: enableRecurring ?? this.enableRecurring,
      defaultMessageTemplates: defaultMessageTemplates ?? this.defaultMessageTemplates,
      enableCustomMessages: enableCustomMessages ?? this.enableCustomMessages,
    );
  }

  /// Get supported calendar types
  List<String> getSupportedCalendarTypes() {
    return preferredCalendarTypes;
  }

  /// Get default notification times
  List<Duration> getDefaultNotificationTimes() {
    return defaultAdvanceNotifications;
  }

  /// Get notification times for a specific reminder type
  List<Duration> getNotificationTimesForType(String reminderType) {
    return notificationTimes[reminderType] ?? defaultAdvanceNotifications;
  }

  /// Check if Hijri calendar is supported
  bool supportsHijriCalendar() {
    return preferredCalendarTypes.contains('hijri');
  }

  /// Check if Gregorian calendar is supported
  bool supportsGregorianCalendar() {
    return preferredCalendarTypes.contains('gregorian');
  }

  /// Check if both calendars are supported
  bool supportsBothCalendars() {
    return preferredCalendarTypes.contains('hijri') && 
           preferredCalendarTypes.contains('gregorian');
  }

  /// Validate reminder preferences
  bool isValid() {
    // Check calendar types
    if (preferredCalendarTypes.isEmpty) return false;
    for (final type in preferredCalendarTypes) {
      if (!SubscriptionConstants.isValidCalendarType(type)) return false;
    }
    
    // Check primary calendar type
    if (!SubscriptionConstants.isValidCalendarType(primaryCalendarType)) return false;
    if (!preferredCalendarTypes.contains(primaryCalendarType)) return false;
    
    // Check notification times
    if (defaultAdvanceNotifications.isEmpty) return false;
    for (final duration in defaultAdvanceNotifications) {
      if (duration.isNegative) return false;
    }
    
    // Check notification times for each type
    for (final times in notificationTimes.values) {
      for (final duration in times) {
        if (duration.isNegative) return false;
      }
    }
    
    return true;
  }

  /// Create default reminder preferences
  factory ReminderPreferences.defaultSettings() {
    return const ReminderPreferences(
      preferredCalendarTypes: ['hijri', 'gregorian'],
      primaryCalendarType: 'hijri',
      defaultAdvanceNotifications: [
        Duration(minutes: 15),
        Duration(hours: 1),
        Duration(days: 1),
      ],
      notificationTimes: {
        'prayer': [
          Duration(minutes: 15),
          Duration(hours: 1),
        ],
        'hijri': [
          Duration(days: 1),
          Duration(days: 3),
        ],
        'gregorian': [
          Duration(hours: 6),
          Duration(days: 1),
        ],
      },
      defaultReminderType: 'prayer',
      enableRecurring: true,
      defaultMessageTemplates: [
        'Prayer reminder',
        'Hijri date reminder',
        'Custom reminder',
      ],
      enableCustomMessages: true,
    );
  }

  /// Create preferences for free users (limited features)
  factory ReminderPreferences.freeUserSettings() {
    return const ReminderPreferences(
      preferredCalendarTypes: ['gregorian'],
      primaryCalendarType: 'gregorian',
      defaultAdvanceNotifications: [
        Duration(minutes: 15),
        Duration(hours: 1),
      ],
      notificationTimes: {
        'prayer': [
          Duration(minutes: 15),
          Duration(hours: 1),
        ],
      },
      defaultReminderType: 'prayer',
      enableRecurring: false,
      defaultMessageTemplates: [
        'Prayer reminder',
      ],
      enableCustomMessages: false,
    );
  }

  /// Create preferences for trial users (full features)
  factory ReminderPreferences.trialUserSettings() {
    return ReminderPreferences.defaultSettings();
  }

  /// Create preferences for premium users (full features)
  factory ReminderPreferences.premiumUserSettings() {
    return ReminderPreferences.defaultSettings();
  }

  /// Update notification times for a specific reminder type
  ReminderPreferences updateNotificationTimes(String reminderType, List<Duration> times) {
    final updatedTimes = Map<String, List<Duration>>.from(notificationTimes);
    updatedTimes[reminderType] = times;
    return copyWith(notificationTimes: updatedTimes);
  }

  /// Add a new calendar type
  ReminderPreferences addCalendarType(String calendarType) {
    if (preferredCalendarTypes.contains(calendarType)) return this;
    final updatedTypes = List<String>.from(preferredCalendarTypes)..add(calendarType);
    return copyWith(preferredCalendarTypes: updatedTypes);
  }

  /// Remove a calendar type
  ReminderPreferences removeCalendarType(String calendarType) {
    if (!preferredCalendarTypes.contains(calendarType)) return this;
    final updatedTypes = List<String>.from(preferredCalendarTypes)..remove(calendarType);
    String newPrimary = primaryCalendarType;
    if (primaryCalendarType == calendarType && updatedTypes.isNotEmpty) {
      newPrimary = updatedTypes.first;
    }
    return copyWith(
      preferredCalendarTypes: updatedTypes,
      primaryCalendarType: newPrimary,
    );
  }

  /// Set primary calendar type
  ReminderPreferences setPrimaryCalendarType(String calendarType) {
    if (!preferredCalendarTypes.contains(calendarType)) return this;
    return copyWith(primaryCalendarType: calendarType);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderPreferences &&
        const DeepCollectionEquality().equals(other.preferredCalendarTypes, preferredCalendarTypes) &&
        other.primaryCalendarType == primaryCalendarType &&
        const DeepCollectionEquality().equals(other.defaultAdvanceNotifications, defaultAdvanceNotifications) &&
        const DeepCollectionEquality().equals(other.notificationTimes, notificationTimes) &&
        other.defaultReminderType == defaultReminderType &&
        other.enableRecurring == enableRecurring &&
        const DeepCollectionEquality().equals(other.defaultMessageTemplates, defaultMessageTemplates) &&
        other.enableCustomMessages == enableCustomMessages;
  }

  @override
  int get hashCode {
    return Object.hash(
      preferredCalendarTypes,
      primaryCalendarType,
      defaultAdvanceNotifications,
      notificationTimes,
      defaultReminderType,
      enableRecurring,
      defaultMessageTemplates,
      enableCustomMessages,
    );
  }

  @override
  String toString() {
    return 'ReminderPreferences(primaryCalendarType: $primaryCalendarType, supportedCalendars: $preferredCalendarTypes, defaultNotifications: $defaultAdvanceNotifications)';
  }
}
