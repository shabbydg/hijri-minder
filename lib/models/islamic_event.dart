import 'dart:convert';

/// Enum for Islamic event categories
enum EventCategory {
  eid,
  shahadat,
  ramadan,
  hajj,
  milad,
  other,
}

/// Model representing Islamic events and holidays
class IslamicEvent {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final int hijriDay;
  final int hijriMonth;
  final int? hijriYear; // null for recurring annual events
  final bool isImportant;
  final String? location;
  final Map<String, String> localizedTitles;
  final Map<String, String> localizedDescriptions;

  const IslamicEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.hijriDay,
    required this.hijriMonth,
    this.hijriYear,
    this.isImportant = false,
    this.location,
    this.localizedTitles = const {},
    this.localizedDescriptions = const {},
  });

  /// Factory constructor from JSON
  factory IslamicEvent.fromJson(Map<String, dynamic> json) {
    return IslamicEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.other,
      ),
      hijriDay: json['hijriDay'] ?? 1,
      hijriMonth: json['hijriMonth'] ?? 1,
      hijriYear: json['hijriYear'],
      isImportant: json['isImportant'] ?? false,
      location: json['location'],
      localizedTitles: Map<String, String>.from(json['localizedTitles'] ?? {}),
      localizedDescriptions: Map<String, String>.from(json['localizedDescriptions'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'hijriDay': hijriDay,
      'hijriMonth': hijriMonth,
      'hijriYear': hijriYear,
      'isImportant': isImportant,
      'location': location,
      'localizedTitles': localizedTitles,
      'localizedDescriptions': localizedDescriptions,
    };
  }

  /// Get localized title for specified language
  String getLocalizedTitle(String languageCode) {
    return localizedTitles[languageCode] ?? title;
  }

  /// Get localized description for specified language
  String getLocalizedDescription(String languageCode) {
    return localizedDescriptions[languageCode] ?? description;
  }

  /// Get category display name
  String getCategoryDisplayName() {
    switch (category) {
      case EventCategory.eid:
        return 'Eid';
      case EventCategory.shahadat:
        return 'Shahadat';
      case EventCategory.ramadan:
        return 'Ramadan';
      case EventCategory.hajj:
        return 'Hajj';
      case EventCategory.milad:
        return 'Milad';
      case EventCategory.other:
        return 'Other';
    }
  }

  /// Check if event occurs on specific Hijri date
  bool occursOnDate(int day, int month, [int? year]) {
    if (hijriDay != day || hijriMonth != month) return false;
    
    // If event has specific year, check year match
    if (hijriYear != null && year != null) {
      return hijriYear == year;
    }
    
    // For recurring events (hijriYear is null), always match
    return hijriYear == null;
  }

  /// Check if event is in specified month
  bool occursInMonth(int month) {
    return hijriMonth == month;
  }

  /// Get event importance level (for sorting/display priority)
  int getImportanceLevel() {
    if (isImportant) return 3;
    
    switch (category) {
      case EventCategory.eid:
        return 2;
      case EventCategory.shahadat:
      case EventCategory.milad:
        return 1;
      case EventCategory.ramadan:
      case EventCategory.hajj:
      case EventCategory.other:
        return 0;
    }
  }

  /// Create a copy with updated fields
  IslamicEvent copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    int? hijriDay,
    int? hijriMonth,
    int? hijriYear,
    bool? isImportant,
    String? location,
    Map<String, String>? localizedTitles,
    Map<String, String>? localizedDescriptions,
  }) {
    return IslamicEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      hijriDay: hijriDay ?? this.hijriDay,
      hijriMonth: hijriMonth ?? this.hijriMonth,
      hijriYear: hijriYear ?? this.hijriYear,
      isImportant: isImportant ?? this.isImportant,
      location: location ?? this.location,
      localizedTitles: localizedTitles ?? this.localizedTitles,
      localizedDescriptions: localizedDescriptions ?? this.localizedDescriptions,
    );
  }

  @override
  String toString() {
    return 'IslamicEvent(id: $id, title: $title, category: ${category.name}, date: $hijriDay/$hijriMonth${hijriYear != null ? '/$hijriYear' : ''})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IslamicEvent &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.hijriDay == hijriDay &&
        other.hijriMonth == hijriMonth &&
        other.hijriYear == hijriYear &&
        other.isImportant == isImportant &&
        other.location == location;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      category,
      hijriDay,
      hijriMonth,
      hijriYear,
      isImportant,
      location,
    );
  }
}

/// Extension for EventCategory enum
extension EventCategoryExtension on EventCategory {
  /// Get category color for UI display
  String get colorHex {
    switch (this) {
      case EventCategory.eid:
        return '#4CAF50'; // Green
      case EventCategory.shahadat:
        return '#F44336'; // Red
      case EventCategory.ramadan:
        return '#9C27B0'; // Purple
      case EventCategory.hajj:
        return '#FF9800'; // Orange
      case EventCategory.milad:
        return '#2196F3'; // Blue
      case EventCategory.other:
        return '#607D8B'; // Blue Grey
    }
  }

  /// Get category icon name
  String get iconName {
    switch (this) {
      case EventCategory.eid:
        return 'celebration';
      case EventCategory.shahadat:
        return 'favorite';
      case EventCategory.ramadan:
        return 'nights_stay';
      case EventCategory.hajj:
        return 'place';
      case EventCategory.milad:
        return 'cake';
      case EventCategory.other:
        return 'event';
    }
  }
}