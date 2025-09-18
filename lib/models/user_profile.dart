import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reminder_preferences.dart';
import 'subscription_types.dart';

class UserProfile {
  final String userId;
  final String email;
  final String? displayName;
  final SubscriptionStatus subscriptionStatus;
  final SubscriptionType? subscriptionType;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool hasHijriReminders;
  final bool hasMessagingFeatures;
  final ReminderPreferences defaultReminderSettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const UserProfile({
    required this.userId,
    required this.email,
    this.displayName,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.subscriptionType,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.hasHijriReminders = false,
    this.hasMessagingFeatures = false,
    required this.defaultReminderSettings,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return UserProfile(
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (e) => e.name == (json['subscriptionStatus'] ?? 'free'),
        orElse: () => SubscriptionStatus.free,
      ),
      subscriptionType: json['subscriptionType'] != null
          ? SubscriptionType.values.firstWhere(
              (e) => e.name == json['subscriptionType'],
              orElse: () => SubscriptionType.monthly,
            )
          : null,
      trialStartDate: _parseDate(json['trialStartDate']),
      trialEndDate: _parseDate(json['trialEndDate']),
      subscriptionStartDate: _parseDate(json['subscriptionStartDate']),
      subscriptionEndDate: _parseDate(json['subscriptionEndDate']),
      hasHijriReminders: json['hasHijriReminders'] ?? false,
      hasMessagingFeatures: json['hasMessagingFeatures'] ?? false,
      defaultReminderSettings: json['defaultReminderSettings'] != null
          ? ReminderPreferences.fromJson(
              Map<String, dynamic>.from(json['defaultReminderSettings']))
          : ReminderPreferences.defaultSettings(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
      lastLoginAt: _parseDate(json['lastLoginAt']),
    );
  }

  Map<String, dynamic> toJson() {
    int? _toMillis(DateTime? d) => d?.millisecondsSinceEpoch;
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'subscriptionStatus': subscriptionStatus.name,
      'subscriptionType': subscriptionType?.name,
      'trialStartDate': _toMillis(trialStartDate),
      'trialEndDate': _toMillis(trialEndDate),
      'subscriptionStartDate': _toMillis(subscriptionStartDate),
      'subscriptionEndDate': _toMillis(subscriptionEndDate),
      'hasHijriReminders': hasHijriReminders,
      'hasMessagingFeatures': hasMessagingFeatures,
      'defaultReminderSettings': defaultReminderSettings.toJson(),
      'createdAt': _toMillis(createdAt),
      'updatedAt': _toMillis(updatedAt),
      'lastLoginAt': _toMillis(lastLoginAt),
    };
  }

  /// Convert to Firestore-compatible format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'subscriptionStatus': subscriptionStatus.name,
      'subscriptionType': subscriptionType?.name,
      'trialStartDate': trialStartDate != null ? Timestamp.fromDate(trialStartDate!) : null,
      'trialEndDate': trialEndDate != null ? Timestamp.fromDate(trialEndDate!) : null,
      'subscriptionStartDate': subscriptionStartDate != null ? Timestamp.fromDate(subscriptionStartDate!) : null,
      'subscriptionEndDate': subscriptionEndDate != null ? Timestamp.fromDate(subscriptionEndDate!) : null,
      'hasHijriReminders': hasHijriReminders,
      'hasMessagingFeatures': hasMessagingFeatures,
      'defaultReminderSettings': defaultReminderSettings.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  /// Create from Firestore data
  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (e) => e.name == data['subscriptionStatus'],
        orElse: () => SubscriptionStatus.free,
      ),
      subscriptionType: data['subscriptionType'] != null
          ? SubscriptionType.values.firstWhere(
              (e) => e.name == data['subscriptionType'],
              orElse: () => SubscriptionType.monthly,
            )
          : null,
      trialStartDate: data['trialStartDate'] != null
          ? (data['trialStartDate'] as Timestamp).toDate()
          : null,
      trialEndDate: data['trialEndDate'] != null
          ? (data['trialEndDate'] as Timestamp).toDate()
          : null,
      subscriptionStartDate: data['subscriptionStartDate'] != null
          ? (data['subscriptionStartDate'] as Timestamp).toDate()
          : null,
      subscriptionEndDate: data['subscriptionEndDate'] != null
          ? (data['subscriptionEndDate'] as Timestamp).toDate()
          : null,
      hasHijriReminders: data['hasHijriReminders'] ?? false,
      hasMessagingFeatures: data['hasMessagingFeatures'] ?? false,
      defaultReminderSettings: ReminderPreferences.fromFirestore(
        Map<String, dynamic>.from(data['defaultReminderSettings'] ?? {}),
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? displayName,
    SubscriptionStatus? subscriptionStatus,
    SubscriptionType? subscriptionType,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? hasHijriReminders,
    bool? hasMessagingFeatures,
    ReminderPreferences? defaultReminderSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      hasHijriReminders: hasHijriReminders ?? this.hasHijriReminders,
      hasMessagingFeatures: hasMessagingFeatures ?? this.hasMessagingFeatures,
      defaultReminderSettings: defaultReminderSettings ?? this.defaultReminderSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Check if the user is currently in trial period
  bool get isTrialActive {
    if (subscriptionStatus != SubscriptionStatus.trial) return false;
    if (trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  /// Check if the user has active premium subscription
  bool get isPremiumActive {
    if (subscriptionStatus != SubscriptionStatus.premium) return false;
    if (subscriptionEndDate == null) return false;
    return DateTime.now().isBefore(subscriptionEndDate!);
  }

  /// Check if the trial has expired
  bool get isTrialExpired {
    if (subscriptionStatus != SubscriptionStatus.trial) return false;
    if (trialEndDate == null) return false;
    return DateTime.now().isAfter(trialEndDate!);
  }

  /// Get the number of remaining trial days
  int get remainingTrialDays {
    if (!isTrialActive) return 0;
    if (trialEndDate == null) return 0;
    final now = DateTime.now();
    final difference = trialEndDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Check if user has access to premium features
  bool get hasPremiumAccess {
    return isTrialActive || isPremiumActive;
  }

  /// Check if user can create Hijri reminders
  bool get canCreateHijriReminders {
    return hasPremiumAccess && hasHijriReminders;
  }

  /// Check if user can use messaging features
  bool get canUseMessagingFeatures {
    return hasPremiumAccess && hasMessagingFeatures;
  }

  /// Validate the user profile data
  bool isValid() {
    if (userId.isEmpty || email.isEmpty) return false;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) return false;
    if (trialStartDate != null && trialEndDate != null) {
      if (trialStartDate!.isAfter(trialEndDate!)) return false;
    }
    if (subscriptionStartDate != null && subscriptionEndDate != null) {
      if (subscriptionStartDate!.isAfter(subscriptionEndDate!)) return false;
    }
    return defaultReminderSettings.isValid();
  }

  /// Create a new user profile for a new user
  factory UserProfile.createNew({
    required String userId,
    required String email,
    String? displayName,
    ReminderPreferences? defaultReminderSettings,
  }) {
    final now = DateTime.now();
    return UserProfile(
      userId: userId,
      email: email,
      displayName: displayName,
      subscriptionStatus: SubscriptionStatus.trial,
      trialStartDate: now,
      trialEndDate: now.add(const Duration(days: 14)),
      hasHijriReminders: true,
      hasMessagingFeatures: true,
      defaultReminderSettings: defaultReminderSettings ?? ReminderPreferences.defaultSettings(),
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );
  }

  /// Update last login timestamp
  UserProfile updateLastLogin() {
    return copyWith(
      lastLoginAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Activate premium subscription
  UserProfile activateSubscription({
    required SubscriptionType type,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return copyWith(
      subscriptionStatus: SubscriptionStatus.premium,
      subscriptionType: type,
      subscriptionStartDate: startDate,
      subscriptionEndDate: endDate,
      updatedAt: DateTime.now(),
    );
  }

  /// Cancel subscription
  UserProfile cancelSubscription() {
    return copyWith(
      subscriptionStatus: SubscriptionStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  /// Expire subscription
  UserProfile expireSubscription() {
    return copyWith(
      subscriptionStatus: SubscriptionStatus.expired,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.userId == userId &&
        other.email == email &&
        other.displayName == displayName &&
        other.subscriptionStatus == subscriptionStatus &&
        other.subscriptionType == subscriptionType &&
        other.trialStartDate == trialStartDate &&
        other.trialEndDate == trialEndDate &&
        other.subscriptionStartDate == subscriptionStartDate &&
        other.subscriptionEndDate == subscriptionEndDate &&
        other.hasHijriReminders == hasHijriReminders &&
        other.hasMessagingFeatures == hasMessagingFeatures &&
        other.defaultReminderSettings == defaultReminderSettings &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      email,
      displayName,
      subscriptionStatus,
      subscriptionType,
      trialStartDate,
      trialEndDate,
      subscriptionStartDate,
      subscriptionEndDate,
      hasHijriReminders,
      hasMessagingFeatures,
      defaultReminderSettings,
      createdAt,
      updatedAt,
      lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, email: $email, subscriptionStatus: $subscriptionStatus, hasPremiumAccess: $hasPremiumAccess)';
  }
}
