import 'reminder.dart';

/// Represents a message template with metadata
class MessageTemplate {
  final String id;
  final String content;
  final String language;
  final ReminderType type;
  final List<String> tags;
  final bool isReligious;
  final String? quranicVerse;
  final String? hadith;

  const MessageTemplate({
    required this.id,
    required this.content,
    required this.language,
    required this.type,
    this.tags = const [],
    this.isReligious = false,
    this.quranicVerse,
    this.hadith,
  });

  /// Create a copy with modified fields
  MessageTemplate copyWith({
    String? id,
    String? content,
    String? language,
    ReminderType? type,
    List<String>? tags,
    bool? isReligious,
    String? quranicVerse,
    String? hadith,
  }) {
    return MessageTemplate(
      id: id ?? this.id,
      content: content ?? this.content,
      language: language ?? this.language,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      isReligious: isReligious ?? this.isReligious,
      quranicVerse: quranicVerse ?? this.quranicVerse,
      hadith: hadith ?? this.hadith,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'language': language,
      'type': type.toString(),
      'tags': tags,
      'isReligious': isReligious,
      'quranicVerse': quranicVerse,
      'hadith': hadith,
    };
  }

  /// Create from JSON
  factory MessageTemplate.fromJson(Map<String, dynamic> json) {
    return MessageTemplate(
      id: json['id'] as String,
      content: json['content'] as String,
      language: json['language'] as String,
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ReminderType.birthday,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      isReligious: json['isReligious'] as bool? ?? false,
      quranicVerse: json['quranicVerse'] as String?,
      hadith: json['hadith'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageTemplate &&
        other.id == id &&
        other.content == content &&
        other.language == language &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(id, content, language, type);
  }

  @override
  String toString() {
    return 'MessageTemplate(id: $id, language: $language, type: $type, isReligious: $isReligious)';
  }
}

/// Represents a personalized message ready for sharing
class PersonalizedMessage {
  final String content;
  final String recipientName;
  final String relationship;
  final String language;
  final ReminderType type;
  final DateTime createdAt;

  const PersonalizedMessage({
    required this.content,
    required this.recipientName,
    required this.relationship,
    required this.language,
    required this.type,
    required this.createdAt,
  });

  /// Create a copy with modified fields
  PersonalizedMessage copyWith({
    String? content,
    String? recipientName,
    String? relationship,
    String? language,
    ReminderType? type,
    DateTime? createdAt,
  }) {
    return PersonalizedMessage(
      content: content ?? this.content,
      recipientName: recipientName ?? this.recipientName,
      relationship: relationship ?? this.relationship,
      language: language ?? this.language,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'recipientName': recipientName,
      'relationship': relationship,
      'language': language,
      'type': type.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PersonalizedMessage.fromJson(Map<String, dynamic> json) {
    return PersonalizedMessage(
      content: json['content'] as String,
      recipientName: json['recipientName'] as String,
      relationship: json['relationship'] as String,
      language: json['language'] as String,
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ReminderType.birthday,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'PersonalizedMessage(recipientName: $recipientName, type: $type, language: $language)';
  }
}