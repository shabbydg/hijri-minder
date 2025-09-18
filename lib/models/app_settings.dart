import 'dart:convert';
import 'package:collection/collection.dart';
import 'reminder_preferences.dart';

/// Model representing user app settings and preferences
class AppSettings {
  final bool enablePrayerNotifications;
  final bool enableAdhanSounds;
  final bool enableLocationServices;
  final String language;
  final String theme;
  final bool showGregorianDates;
  final bool showEventDots;
  final String prayerTimeFormat;
  final Duration prayerNotificationAdvance;
  final bool enableReminderNotifications;
  final bool enableVibration;
  final double fontSize;
  final bool useArabicNumerals;
  final String defaultLocation;
  final bool autoLocationUpdate;
  
  // Default reminder preferences
  final List<String> defaultCalendarTypes;
  final List<Duration> defaultAdvanceNotifications;
  final bool enableHijriReminders;
  final bool enableGregorianReminders;
  final String defaultReminderCalendarType;
  final Map<String, List<Duration>> reminderNotificationTimes;

  const AppSettings({
    this.enablePrayerNotifications = true,
    this.enableAdhanSounds = false,
    this.enableLocationServices = true,
    this.language = 'en',
    this.theme = 'light',
    this.showGregorianDates = true,
    this.showEventDots = true,
    this.prayerTimeFormat = '24h',
    this.prayerNotificationAdvance = const Duration(minutes: 10),
    this.enableReminderNotifications = true,
    this.enableVibration = true,
    this.fontSize = 14.0,
    this.useArabicNumerals = false,
    this.defaultLocation = 'Colombo, Sri Lanka',
    this.autoLocationUpdate = true,
    this.defaultCalendarTypes = const ['hijri', 'gregorian'],
    this.defaultAdvanceNotifications = const [
      Duration(minutes: 15),
      Duration(hours: 1),
      Duration(days: 1),
    ],
    this.enableHijriReminders = true,
    this.enableGregorianReminders = true,
    this.defaultReminderCalendarType = 'hijri',
    this.reminderNotificationTimes = const {
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
  });

  /// Default settings factory
  factory AppSettings.defaultSettings() {
    return const AppSettings();
  }

  /// Factory constructor from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    // Parse default calendar types
    List<String> defaultCalendarTypes = ['hijri', 'gregorian'];
    if (json['defaultCalendarTypes'] != null) {
      defaultCalendarTypes = List<String>.from(json['defaultCalendarTypes']);
    }

    // Parse default advance notifications
    List<Duration> defaultAdvanceNotifications = [
      const Duration(minutes: 15),
      const Duration(hours: 1),
      const Duration(days: 1),
    ];
    if (json['defaultAdvanceNotifications'] != null) {
      defaultAdvanceNotifications = (json['defaultAdvanceNotifications'] as List)
          .map((e) => Duration(minutes: e as int))
          .toList();
    }

    // Parse reminder notification times
    Map<String, List<Duration>> reminderNotificationTimes = {
      'prayer': [const Duration(minutes: 15), const Duration(hours: 1)],
      'hijri': [const Duration(days: 1), const Duration(days: 3)],
      'gregorian': [const Duration(hours: 6), const Duration(days: 1)],
    };
    if (json['reminderNotificationTimes'] != null) {
      final timesMap = json['reminderNotificationTimes'] as Map<String, dynamic>;
      reminderNotificationTimes = timesMap.map((key, value) {
        final durations = (value as List).map((e) => Duration(minutes: e as int)).toList();
        return MapEntry(key, durations);
      });
    }

    return AppSettings(
      enablePrayerNotifications: json['enablePrayerNotifications'] ?? true,
      enableAdhanSounds: json['enableAdhanSounds'] ?? false,
      enableLocationServices: json['enableLocationServices'] ?? true,
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'light',
      showGregorianDates: json['showGregorianDates'] ?? true,
      showEventDots: json['showEventDots'] ?? true,
      prayerTimeFormat: json['prayerTimeFormat'] ?? '24h',
      prayerNotificationAdvance: Duration(
        minutes: json['prayerNotificationAdvanceMinutes'] ?? 10,
      ),
      enableReminderNotifications: json['enableReminderNotifications'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      fontSize: (json['fontSize'] ?? 14.0).toDouble(),
      useArabicNumerals: json['useArabicNumerals'] ?? false,
      defaultLocation: json['defaultLocation'] ?? 'Colombo, Sri Lanka',
      autoLocationUpdate: json['autoLocationUpdate'] ?? true,
      defaultCalendarTypes: defaultCalendarTypes,
      defaultAdvanceNotifications: defaultAdvanceNotifications,
      enableHijriReminders: json['enableHijriReminders'] ?? true,
      enableGregorianReminders: json['enableGregorianReminders'] ?? true,
      defaultReminderCalendarType: json['defaultReminderCalendarType'] ?? 'hijri',
      reminderNotificationTimes: reminderNotificationTimes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'enablePrayerNotifications': enablePrayerNotifications,
      'enableAdhanSounds': enableAdhanSounds,
      'enableLocationServices': enableLocationServices,
      'language': language,
      'theme': theme,
      'showGregorianDates': showGregorianDates,
      'showEventDots': showEventDots,
      'prayerTimeFormat': prayerTimeFormat,
      'prayerNotificationAdvanceMinutes': prayerNotificationAdvance.inMinutes,
      'enableReminderNotifications': enableReminderNotifications,
      'enableVibration': enableVibration,
      'fontSize': fontSize,
      'useArabicNumerals': useArabicNumerals,
      'defaultLocation': defaultLocation,
      'autoLocationUpdate': autoLocationUpdate,
      'defaultCalendarTypes': defaultCalendarTypes,
      'defaultAdvanceNotifications': defaultAdvanceNotifications.map((d) => d.inMinutes).toList(),
      'enableHijriReminders': enableHijriReminders,
      'enableGregorianReminders': enableGregorianReminders,
      'defaultReminderCalendarType': defaultReminderCalendarType,
      'reminderNotificationTimes': reminderNotificationTimes.map((key, value) {
        return MapEntry(key, value.map((d) => d.inMinutes).toList());
      }),
    };
  }

  /// Get supported languages
  static List<String> getSupportedLanguages() {
    return [
      'en', // English
      'ar', // Arabic
      'id', // Indonesian
      'ur', // Urdu
      'ms', // Malay
      'tr', // Turkish
      'fa', // Persian
      'bn', // Bengali
    ];
  }

  /// Get language display name
  String getLanguageDisplayName() {
    switch (language) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'id':
        return 'Bahasa Indonesia';
      case 'ur':
        return 'اردو';
      case 'ms':
        return 'Bahasa Melayu';
      case 'tr':
        return 'Türkçe';
      case 'fa':
        return 'فارسی';
      case 'bn':
        return 'বাংলা';
      default:
        return 'English';
    }
  }

  /// Get supported themes
  static List<String> getSupportedThemes() {
    return ['light', 'dark', 'system'];
  }

  /// Get theme display name
  String getThemeDisplayName() {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System';
      default:
        return 'Light';
    }
  }

  /// Get supported prayer time formats
  static List<String> getSupportedTimeFormats() {
    return ['12h', '24h'];
  }

  /// Check if 24-hour format is enabled
  bool is24HourFormat() {
    return prayerTimeFormat == '24h';
  }

  /// Check if language is RTL (Right-to-Left)
  bool isRTLLanguage() {
    return ['ar', 'ur', 'fa'].contains(language);
  }

  /// Get supported calendar types
  List<String> getSupportedCalendarTypes() {
    return defaultCalendarTypes;
  }

  /// Get default notification times
  List<Duration> getDefaultNotificationTimes() {
    return defaultAdvanceNotifications;
  }

  /// Get notification times for a specific reminder type
  List<Duration> getNotificationTimesForType(String reminderType) {
    return reminderNotificationTimes[reminderType] ?? defaultAdvanceNotifications;
  }

  /// Check if Hijri calendar is supported
  bool supportsHijriCalendar() {
    return defaultCalendarTypes.contains('hijri');
  }

  /// Check if Gregorian calendar is supported
  bool supportsGregorianCalendar() {
    return defaultCalendarTypes.contains('gregorian');
  }

  /// Check if both calendars are supported
  bool supportsBothCalendars() {
    return defaultCalendarTypes.contains('hijri') && 
           defaultCalendarTypes.contains('gregorian');
  }

  /// Validate settings values
  bool isValid() {
    return getSupportedLanguages().contains(language) &&
           getSupportedThemes().contains(theme) &&
           getSupportedTimeFormats().contains(prayerTimeFormat) &&
           fontSize >= 10.0 &&
           fontSize <= 24.0 &&
           prayerNotificationAdvance.inMinutes >= 0 &&
           prayerNotificationAdvance.inMinutes <= 60 &&
           defaultCalendarTypes.isNotEmpty &&
           ['hijri', 'gregorian'].contains(defaultReminderCalendarType) &&
           defaultCalendarTypes.contains(defaultReminderCalendarType) &&
           defaultAdvanceNotifications.isNotEmpty &&
           defaultAdvanceNotifications.every((d) => d.inMinutes >= 0);
  }

  /// Create a copy with updated fields
  AppSettings copyWith({
    bool? enablePrayerNotifications,
    bool? enableAdhanSounds,
    bool? enableLocationServices,
    String? language,
    String? theme,
    bool? showGregorianDates,
    bool? showEventDots,
    String? prayerTimeFormat,
    Duration? prayerNotificationAdvance,
    bool? enableReminderNotifications,
    bool? enableVibration,
    double? fontSize,
    bool? useArabicNumerals,
    String? defaultLocation,
    bool? autoLocationUpdate,
    List<String>? defaultCalendarTypes,
    List<Duration>? defaultAdvanceNotifications,
    bool? enableHijriReminders,
    bool? enableGregorianReminders,
    String? defaultReminderCalendarType,
    Map<String, List<Duration>>? reminderNotificationTimes,
  }) {
    return AppSettings(
      enablePrayerNotifications: enablePrayerNotifications ?? this.enablePrayerNotifications,
      enableAdhanSounds: enableAdhanSounds ?? this.enableAdhanSounds,
      enableLocationServices: enableLocationServices ?? this.enableLocationServices,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      showGregorianDates: showGregorianDates ?? this.showGregorianDates,
      showEventDots: showEventDots ?? this.showEventDots,
      prayerTimeFormat: prayerTimeFormat ?? this.prayerTimeFormat,
      prayerNotificationAdvance: prayerNotificationAdvance ?? this.prayerNotificationAdvance,
      enableReminderNotifications: enableReminderNotifications ?? this.enableReminderNotifications,
      enableVibration: enableVibration ?? this.enableVibration,
      fontSize: fontSize ?? this.fontSize,
      useArabicNumerals: useArabicNumerals ?? this.useArabicNumerals,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      autoLocationUpdate: autoLocationUpdate ?? this.autoLocationUpdate,
      defaultCalendarTypes: defaultCalendarTypes ?? this.defaultCalendarTypes,
      defaultAdvanceNotifications: defaultAdvanceNotifications ?? this.defaultAdvanceNotifications,
      enableHijriReminders: enableHijriReminders ?? this.enableHijriReminders,
      enableGregorianReminders: enableGregorianReminders ?? this.enableGregorianReminders,
      defaultReminderCalendarType: defaultReminderCalendarType ?? this.defaultReminderCalendarType,
      reminderNotificationTimes: reminderNotificationTimes ?? this.reminderNotificationTimes,
    );
  }

  @override
  String toString() {
    return 'AppSettings(language: $language, theme: $theme, prayerNotifications: $enablePrayerNotifications)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.enablePrayerNotifications == enablePrayerNotifications &&
        other.enableAdhanSounds == enableAdhanSounds &&
        other.enableLocationServices == enableLocationServices &&
        other.language == language &&
        other.theme == theme &&
        other.showGregorianDates == showGregorianDates &&
        other.showEventDots == showEventDots &&
        other.prayerTimeFormat == prayerTimeFormat &&
        other.prayerNotificationAdvance == prayerNotificationAdvance &&
        other.enableReminderNotifications == enableReminderNotifications &&
        other.enableVibration == enableVibration &&
        other.fontSize == fontSize &&
        other.useArabicNumerals == useArabicNumerals &&
        other.defaultLocation == defaultLocation &&
        other.autoLocationUpdate == autoLocationUpdate &&
        const DeepCollectionEquality().equals(other.defaultCalendarTypes, defaultCalendarTypes) &&
        const DeepCollectionEquality().equals(other.defaultAdvanceNotifications, defaultAdvanceNotifications) &&
        other.enableHijriReminders == enableHijriReminders &&
        other.enableGregorianReminders == enableGregorianReminders &&
        other.defaultReminderCalendarType == defaultReminderCalendarType &&
        const DeepCollectionEquality().equals(other.reminderNotificationTimes, reminderNotificationTimes);
  }

  @override
  int get hashCode {
    return Object.hashAll([
      enablePrayerNotifications,
      enableAdhanSounds,
      enableLocationServices,
      language,
      theme,
      showGregorianDates,
      showEventDots,
      prayerTimeFormat,
      prayerNotificationAdvance,
      enableReminderNotifications,
      enableVibration,
      fontSize,
      useArabicNumerals,
      defaultLocation,
      autoLocationUpdate,
      const DeepCollectionEquality().hash(defaultCalendarTypes),
      const DeepCollectionEquality().hash(defaultAdvanceNotifications),
      enableHijriReminders,
      enableGregorianReminders,
      defaultReminderCalendarType,
      const DeepCollectionEquality().hash(reminderNotificationTimes),
    ]);
  }
}