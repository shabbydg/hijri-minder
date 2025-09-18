import 'package:json_annotation/json_annotation.dart';
enum SubscriptionStatus {
  @JsonValue('free')
  free,
  @JsonValue('trial')
  trial,
  @JsonValue('premium')
  premium,
  @JsonValue('expired')
  expired,
  @JsonValue('cancelled')
  cancelled,
}

enum SubscriptionType {
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
}

enum PremiumFeature {
  hijriReminders,
  messagingFeatures,
  unlimitedReminders,
  customTemplates,
  advancedNotifications,
  cloudSync,
}

enum CalendarType {
  hijri,
  gregorian,
  both,
}

class SubscriptionConstants {
  // Trial settings
  static const int trialDurationDays = 14;
  static const Duration trialDuration = Duration(days: trialDurationDays);
  
  // Subscription pricing (in cents)
  static const int monthlyPriceCents = 299; // $2.99
  static const int yearlyPriceCents = 2999; // $29.99
  
  // Feature limits
  static const int freeReminderLimit = 5;
  static const int trialReminderLimit = 50;
  static const int premiumReminderLimit = -1; // unlimited
  
  // Notification advance time options
  static const List<Duration> defaultAdvanceNotifications = [
    Duration(minutes: 15),
    Duration(hours: 1),
    Duration(hours: 6),
    Duration(days: 1),
    Duration(days: 3),
  ];
  
  // Display names for enums
  static String getSubscriptionStatusDisplayName(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return 'Free';
      case SubscriptionStatus.trial:
        return 'Trial';
      case SubscriptionStatus.premium:
        return 'Premium';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  static String getSubscriptionTypeDisplayName(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.monthly:
        return 'Monthly';
      case SubscriptionType.yearly:
        return 'Yearly';
    }
  }
  
  static String getPremiumFeatureDisplayName(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.hijriReminders:
        return 'Hijri Reminders';
      case PremiumFeature.messagingFeatures:
        return 'Messaging Features';
      case PremiumFeature.unlimitedReminders:
        return 'Unlimited Reminders';
      case PremiumFeature.customTemplates:
        return 'Custom Templates';
      case PremiumFeature.advancedNotifications:
        return 'Advanced Notifications';
      case PremiumFeature.cloudSync:
        return 'Cloud Sync';
    }
  }
  
  static String getCalendarTypeDisplayName(CalendarType type) {
    switch (type) {
      case CalendarType.hijri:
        return 'Hijri';
      case CalendarType.gregorian:
        return 'Gregorian';
      case CalendarType.both:
        return 'Both';
    }
  }
  
  // Validation methods
  static bool isValidSubscriptionStatus(String status) {
    return SubscriptionStatus.values.any((e) => e.name == status);
  }
  
  static bool isValidSubscriptionType(String type) {
    return SubscriptionType.values.any((e) => e.name == type);
  }
  
  static bool isValidPremiumFeature(String feature) {
    return PremiumFeature.values.any((e) => e.name == feature);
  }
  
  static bool isValidCalendarType(String type) {
    return CalendarType.values.any((e) => e.name == type);
  }
  
  // Helper methods
  static int getReminderLimit(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return freeReminderLimit;
      case SubscriptionStatus.trial:
        return trialReminderLimit;
      case SubscriptionStatus.premium:
        return premiumReminderLimit;
      case SubscriptionStatus.expired:
      case SubscriptionStatus.cancelled:
        return freeReminderLimit;
    }
  }
  
  static bool hasFeatureAccess(SubscriptionStatus status, PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.hijriReminders:
        return status == SubscriptionStatus.trial || status == SubscriptionStatus.premium;
      case PremiumFeature.messagingFeatures:
        return status == SubscriptionStatus.trial || status == SubscriptionStatus.premium;
      case PremiumFeature.unlimitedReminders:
        return status == SubscriptionStatus.premium;
      case PremiumFeature.customTemplates:
        return status == SubscriptionStatus.trial || status == SubscriptionStatus.premium;
      case PremiumFeature.advancedNotifications:
        return status == SubscriptionStatus.trial || status == SubscriptionStatus.premium;
      case PremiumFeature.cloudSync:
        return status == SubscriptionStatus.trial || status == SubscriptionStatus.premium;
    }
  }
  
  static Duration getTrialDuration() {
    return trialDuration;
  }
  
  static int getTrialDurationDays() {
    return trialDurationDays;
  }
  
  static String formatPrice(int priceCents) {
    final dollars = priceCents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }
  
  static String getMonthlyPrice() {
    return formatPrice(monthlyPriceCents);
  }
  
  static String getYearlyPrice() {
    return formatPrice(yearlyPriceCents);
  }
}
