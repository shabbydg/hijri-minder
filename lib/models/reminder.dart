import 'dart:convert';
import 'hijri_date.dart';

/// Enum for reminder types
enum ReminderType {
  birthday,
  anniversary,
  religious,
  personal,
  family,
  other,
}

/// Model representing reminders for birthdays, anniversaries, and other events
class Reminder {
  final String id;
  final String title;
  final String description;
  final HijriDate hijriDate;
  final DateTime gregorianDate;
  final ReminderType type;
  final List<String> messageTemplates;
  final bool isRecurring;
  final Duration notificationAdvance;
  final bool isEnabled;
  final String? recipientName;
  final String? relationship;
  final Map<String, String> customFields;
  final DateTime createdAt;
  final DateTime? lastNotified;
  
  // Enhanced fields for calendar type selection and multiple advance notifications
  final List<String> selectedCalendarTypes;
  final List<Duration> advanceNotifications;
  final String calendarPreference;
  final Map<String, dynamic> notificationSettings;

  const Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.hijriDate,
    required this.gregorianDate,
    required this.type,
    this.messageTemplates = const [],
    this.isRecurring = true,
    this.notificationAdvance = const Duration(hours: 1),
    this.isEnabled = true,
    this.recipientName,
    this.relationship,
    this.customFields = const {},
    required this.createdAt,
    this.lastNotified,
    // Enhanced fields with defaults
    this.selectedCalendarTypes = const ['gregorian'],
    this.advanceNotifications = const [Duration(hours: 1)],
    this.calendarPreference = 'gregorian',
    this.notificationSettings = const {},
  });

  /// Factory constructor from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    final gDateStr = json['gregorianDate'] as String?;
    final createdAtStr = json['createdAt'] as String?;
    
    return Reminder(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      hijriDate: HijriDate(
        json['hijriYear'] ?? 1445,
        json['hijriMonth'] ?? 1,
        json['hijriDay'] ?? 1,
      ),
      gregorianDate: gDateStr != null ? DateTime.parse(gDateStr) : DateTime.now(),
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.other,
      ),
      messageTemplates: List<String>.from(json['messageTemplates'] ?? []),
      isRecurring: json['isRecurring'] ?? true,
      notificationAdvance: Duration(minutes: json['notificationAdvanceMinutes'] ?? 60),
      isEnabled: json['isEnabled'] ?? true,
      recipientName: json['recipientName'],
      relationship: json['relationship'],
      customFields: Map<String, String>.from(json['customFields'] ?? {}),
      createdAt: createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now(),
      lastNotified: json['lastNotified'] != null 
          ? DateTime.parse(json['lastNotified']) 
          : null,
      // Enhanced fields with backward compatibility
      selectedCalendarTypes: List<String>.from(json['selectedCalendarTypes'] ?? ['gregorian']),
      advanceNotifications: (json['advanceNotifications'] as List<dynamic>?)
          ?.map((e) => Duration(minutes: e as int))
          .toList() ?? [Duration(minutes: json['notificationAdvanceMinutes'] ?? 60)],
      calendarPreference: json['calendarPreference'] ?? 'gregorian',
      notificationSettings: Map<String, dynamic>.from(json['notificationSettings'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hijriYear': hijriDate.year,
      'hijriMonth': hijriDate.month,
      'hijriDay': hijriDate.day,
      'gregorianDate': gregorianDate.toIso8601String(),
      'type': type.name,
      'messageTemplates': messageTemplates,
      'isRecurring': isRecurring,
      'notificationAdvanceMinutes': notificationAdvance.inMinutes,
      'isEnabled': isEnabled,
      'recipientName': recipientName,
      'relationship': relationship,
      'customFields': customFields,
      'createdAt': createdAt.toIso8601String(),
      'lastNotified': lastNotified?.toIso8601String(),
      // Enhanced fields
      'selectedCalendarTypes': selectedCalendarTypes,
      'advanceNotifications': advanceNotifications.map((d) => d.inMinutes).toList(),
      'calendarPreference': calendarPreference,
      'notificationSettings': notificationSettings,
    };
  }

  /// Get reminder type display name
  String getTypeDisplayName() {
    switch (type) {
      case ReminderType.birthday:
        return 'Birthday';
      case ReminderType.anniversary:
        return 'Anniversary';
      case ReminderType.religious:
        return 'Religious';
      case ReminderType.personal:
        return 'Personal';
      case ReminderType.family:
        return 'Family';
      case ReminderType.other:
        return 'Other';
    }
  }

  /// Get default message templates for the reminder type
  static List<String> getDefaultMessageTemplates(ReminderType type, String language) {
    switch (type) {
      case ReminderType.birthday:
        return _getBirthdayTemplates(language);
      case ReminderType.anniversary:
        return _getAnniversaryTemplates(language);
      case ReminderType.religious:
        return _getReligiousTemplates(language);
      default:
        return _getGeneralTemplates(language);
    }
  }

  /// Get personalized message with recipient name
  String getPersonalizedMessage(String template) {
    String message = template;
    
    if (recipientName != null && recipientName!.isNotEmpty) {
      message = message.replaceAll('[NAME]', recipientName!);
    }
    
    if (relationship != null && relationship!.isNotEmpty) {
      message = message.replaceAll('[RELATIONSHIP]', relationship!);
    }
    
    // Replace date placeholders
    message = message.replaceAll('[HIJRI_DATE]', 
        '${hijriDate.day} ${HijriDate.getMonthName(hijriDate.month)} ${hijriDate.year}');
    message = message.replaceAll('[GREGORIAN_DATE]', 
        '${gregorianDate.day}/${gregorianDate.month}/${gregorianDate.year}');
    
    return message;
  }

  /// Check if reminder should trigger on given date
  bool shouldTriggerOnDate(DateTime date) {
    if (!isEnabled) return false;
    
    if (isRecurring) {
      // For recurring reminders, check based on selected calendar types
      if (selectedCalendarTypes.contains('hijri') && selectedCalendarTypes.contains('gregorian')) {
        // Both calendars selected - trigger when either matches
        final inputHijriDate = HijriDate.fromGregorian(date);
        return (date.month == gregorianDate.month && date.day == gregorianDate.day) ||
               (inputHijriDate.month == hijriDate.month && inputHijriDate.day == hijriDate.day);
      } else if (selectedCalendarTypes.contains('hijri')) {
        // Only Hijri calendar selected
        final inputHijriDate = HijriDate.fromGregorian(date);
        return inputHijriDate.month == hijriDate.month && inputHijriDate.day == hijriDate.day;
      } else {
        // Only Gregorian calendar selected (default)
        return date.month == gregorianDate.month && date.day == gregorianDate.day;
      }
    } else {
      // For one-time reminders, check exact date match
      return date.year == gregorianDate.year &&
             date.month == gregorianDate.month &&
             date.day == gregorianDate.day;
    }
  }

  /// Get next occurrence date
  DateTime getNextOccurrence() {
    final now = DateTime.now();
    
    if (!isRecurring) {
      return gregorianDate.isAfter(now) ? gregorianDate : gregorianDate;
    }
    
    // For recurring reminders, find next occurrence based on primary calendar
    if (calendarPreference == 'hijri' && selectedCalendarTypes.contains('hijri')) {
      // Use Hijri calendar for next occurrence calculation
      var nextHijriYear = now.year;
      var nextHijriDate = HijriDate.fromGregorian(DateTime(nextHijriYear, hijriDate.month, hijriDate.day));
      
      // If the hijri date has already passed this year, use next year
      if (nextHijriDate.toGregorian().isBefore(now) || nextHijriDate.toGregorian().isAtSameMomentAs(now)) {
        nextHijriYear++;
        nextHijriDate = HijriDate.fromGregorian(DateTime(nextHijriYear, hijriDate.month, hijriDate.day));
      }
      
      return nextHijriDate.toGregorian();
    } else {
      // Use Gregorian calendar for next occurrence calculation (default)
      var nextDate = DateTime(now.year, gregorianDate.month, gregorianDate.day);
      
      if (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
        nextDate = DateTime(now.year + 1, gregorianDate.month, gregorianDate.day);
      }
      
      return nextDate;
    }
  }

  /// Calculate age/years since the original date
  int calculateYearsSince() {
    final now = DateTime.now();
    int years = now.year - gregorianDate.year;
    
    if (now.month < gregorianDate.month || 
        (now.month == gregorianDate.month && now.day < gregorianDate.day)) {
      years--;
    }
    
    return years;
  }

  /// Create a copy with updated fields
  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    HijriDate? hijriDate,
    DateTime? gregorianDate,
    ReminderType? type,
    List<String>? messageTemplates,
    bool? isRecurring,
    Duration? notificationAdvance,
    bool? isEnabled,
    String? recipientName,
    String? relationship,
    Map<String, String>? customFields,
    DateTime? createdAt,
    DateTime? lastNotified,
    // Enhanced fields
    List<String>? selectedCalendarTypes,
    List<Duration>? advanceNotifications,
    String? calendarPreference,
    Map<String, dynamic>? notificationSettings,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hijriDate: hijriDate ?? this.hijriDate,
      gregorianDate: gregorianDate ?? this.gregorianDate,
      type: type ?? this.type,
      messageTemplates: messageTemplates ?? this.messageTemplates,
      isRecurring: isRecurring ?? this.isRecurring,
      notificationAdvance: notificationAdvance ?? this.notificationAdvance,
      isEnabled: isEnabled ?? this.isEnabled,
      recipientName: recipientName ?? this.recipientName,
      relationship: relationship ?? this.relationship,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      lastNotified: lastNotified ?? this.lastNotified,
      // Enhanced fields
      selectedCalendarTypes: selectedCalendarTypes ?? this.selectedCalendarTypes,
      advanceNotifications: advanceNotifications ?? this.advanceNotifications,
      calendarPreference: calendarPreference ?? this.calendarPreference,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  // Enhanced helper methods for calendar type selection and notifications
  
  /// Get selected calendar types
  List<String> getSelectedCalendarTypes() {
    return selectedCalendarTypes;
  }
  
  /// Get advance notifications
  List<Duration> getAdvanceNotifications() {
    return advanceNotifications;
  }
  
  /// Check if reminder supports Hijri calendar
  bool supportsHijriCalendar() {
    return selectedCalendarTypes.contains('hijri');
  }
  
  /// Check if reminder supports Gregorian calendar
  bool supportsGregorianCalendar() {
    return selectedCalendarTypes.contains('gregorian');
  }
  
  /// Get notification times for a specific calendar type
  List<Duration> getNotificationTimesForCalendar(String calendarType) {
    if (calendarType == 'hijri' && supportsHijriCalendar()) {
      return advanceNotifications;
    } else if (calendarType == 'gregorian' && supportsGregorianCalendar()) {
      return advanceNotifications;
    }
    return [];
  }
  
  /// Check if reminder has multiple advance notifications
  bool hasMultipleAdvanceNotifications() {
    return advanceNotifications.length > 1;
  }
  
  /// Get primary calendar type for display
  String getPrimaryCalendarType() {
    return calendarPreference;
  }
  
  /// Check if reminder uses both calendar types
  bool usesBothCalendars() {
    return selectedCalendarTypes.length == 2 && 
           selectedCalendarTypes.contains('hijri') && 
           selectedCalendarTypes.contains('gregorian');
  }

  // Private helper methods for message templates
  static List<String> _getBirthdayTemplates(String language) {
    switch (language) {
      case 'ar':
        return [
          'عيد ميلاد سعيد [NAME]! بارك الله في عمرك',
          'كل عام وأنت بخير يا [NAME]',
          'أسأل الله أن يبارك في عمرك ويحفظك',
        ];
      case 'ur':
        return [
          '[NAME] کو سالگرہ مبارک ہو!',
          'اللہ آپ کو لمبی عمر عطا فرمائے',
          'آپ کی زندگی خوشیوں سے بھری رہے',
        ];
      default:
        return [
          'Happy Birthday [NAME]! May Allah bless you with many more years.',
          'Wishing you a blessed birthday filled with joy and happiness.',
          'May this new year of your life bring you closer to Allah.',
          'Happy Birthday! May Allah grant you health, happiness, and success.',
        ];
    }
  }

  static List<String> _getAnniversaryTemplates(String language) {
    switch (language) {
      case 'ar':
        return [
          'ذكرى سعيدة [NAME]!',
          'بارك الله لكما وبارك عليكما',
          'كل عام وأنتما بخير',
        ];
      default:
        return [
          'Happy Anniversary [NAME]!',
          'May Allah bless your union with happiness and prosperity.',
          'Wishing you many more years of togetherness.',
        ];
    }
  }

  static List<String> _getReligiousTemplates(String language) {
    switch (language) {
      case 'ar':
        return [
          'تقبل الله منا ومنكم',
          'كل عام وأنتم بخير',
          'بارك الله فيكم',
        ];
      default:
        return [
          'May Allah accept our good deeds.',
          'Blessed occasion! May Allah shower His blessings upon you.',
          'Remembering this sacred day with prayers and gratitude.',
        ];
    }
  }

  static List<String> _getGeneralTemplates(String language) {
    return [
      'Remembering you on this special day.',
      'Thinking of you today.',
      'May this day bring you joy and blessings.',
    ];
  }

  @override
  String toString() {
    return 'Reminder(id: $id, title: $title, type: ${type.name}, date: ${hijriDate.day}/${hijriDate.month}/${hijriDate.year})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.hijriDate == hijriDate &&
        other.gregorianDate == gregorianDate &&
        other.type == type &&
        other.isRecurring == isRecurring &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      hijriDate,
      gregorianDate,
      type,
      isRecurring,
      isEnabled,
    );
  }
}