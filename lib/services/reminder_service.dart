import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/hijri_date.dart';
import '../models/reminder_preferences.dart';
import '../models/subscription_types.dart';
import 'notification_service.dart';
import 'firestore_service.dart';
import 'auth_service.dart';
import 'settings_service.dart';
import 'subscription_service.dart';
import 'service_locator.dart';
import '../utils/error_handler.dart';
import '../utils/input_validator.dart';

/// Service for managing reminders with hybrid storage (Firestore + SharedPreferences)
class ReminderService {
  static const String _remindersKey = 'reminders';
  static const String _cloudRemindersKey = 'cloud_reminders';
  SharedPreferences? _prefs;
  final NotificationService _notificationService = ServiceLocator.notificationService;
  final FirestoreService _firestoreService = ServiceLocator.firestoreService;
  final AuthService _authService = ServiceLocator.authService;
  final SettingsService _settingsService = ServiceLocator.settingsService;
  final SubscriptionService _subscriptionService = ServiceLocator.subscriptionService;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Other services are already initialized by ServiceLocator
  }

  /// Get all reminders using hybrid storage
  Future<List<Reminder>> getAllReminders() async {
    await initialize();
    
    // For authenticated users, try to load from Firestore first
    if (_authService.isUserSignedIn()) {
      try {
        final cloudReminders = await _firestoreService.loadReminders();
        if (cloudReminders.isNotEmpty) {
          // Sync to local storage as backup
          await _saveToLocalStorage(cloudReminders);
          return cloudReminders;
        }
      } catch (e) {
        // Fall back to local storage if cloud fails
        debugPrint('ReminderService: Failed to load from cloud, using local storage: $e');
      }
    }
    
    // Load from local storage
    final remindersJson = _prefs?.getStringList(_remindersKey) ?? [];
    
    return remindersJson.map((json) {
      try {
        return Reminder.fromJson(jsonDecode(json));
      } catch (e) {
        // Skip invalid reminders
        return null;
      }
    }).where((reminder) => reminder != null).cast<Reminder>().toList();
  }

  /// Save a reminder with validation using hybrid storage
  Future<bool> saveReminder(Reminder reminder) async {
    return await ErrorHandler.withFallback<bool>(
      () async {
        // Validate reminder data
        final validationResult = validateReminder(reminder);
        if (!validationResult.isValid) {
          ErrorHandler.logError(
            'Reminder validation failed: ${validationResult.errorMessage}',
            type: ErrorType.validation,
            severity: ErrorSeverity.medium,
            context: {'reminderId': reminder.id, 'title': reminder.title},
          );
          throw Exception(validationResult.errorMessage);
        }

        await initialize();
        
        // For authenticated users, save to Firestore first
        if (_authService.isUserSignedIn()) {
          try {
            final success = await _firestoreService.saveReminder(reminder);
            if (success) {
              // Also save to local storage as backup
              await _saveReminderToLocalStorage(reminder);
              debugPrint('ReminderService: Reminder saved to cloud and local storage');
              
              // Schedule notifications for the reminder
              if (reminder.isEnabled) {
                final times = reminder.advanceNotifications.isNotEmpty
                    ? reminder.advanceNotifications
                    : [reminder.notificationAdvance];
                for (final d in times) {
                  await _notificationService.scheduleReminderNotificationWithAdvance(reminder, advance: d);
                }
              }
              
              return true;
            }
          } catch (e) {
            debugPrint('ReminderService: Failed to save to cloud, using local storage: $e');
          }
        }
        
        // Fall back to local storage for unauthenticated users or cloud failures
        final reminders = await getAllReminders();
        
        // Check if reminder with same ID exists
        final existingIndex = reminders.indexWhere((r) => r.id == reminder.id);
        
        if (existingIndex >= 0) {
          // Update existing reminder
          reminders[existingIndex] = reminder;
        } else {
          // Add new reminder
          reminders.add(reminder);
        }
        
        // Save to preferences
        final remindersJson = reminders.map((r) => jsonEncode(r.toJson())).toList();
        final success = await _prefs!.setStringList(_remindersKey, remindersJson);
        
        if (!success) {
          throw Exception('Failed to save reminder to storage');
        }
        
        // Schedule notifications for the reminder
        if (reminder.isEnabled) {
          final times = reminder.advanceNotifications.isNotEmpty
              ? reminder.advanceNotifications
              : [reminder.notificationAdvance];
          for (final d in times) {
            await _notificationService.scheduleReminderNotificationWithAdvance(reminder, advance: d);
          }
        }
        
        debugPrint('ReminderService: Reminder saved to local storage');
        return true;
      },
      () => false,
      'save reminder',
      errorType: ErrorType.storage,
      severity: ErrorSeverity.medium,
      context: {'reminderId': reminder.id},
    );
  }

  /// Delete a reminder using hybrid storage
  Future<bool> deleteReminder(String id) async {
    try {
      await initialize();
      
      // Cancel notification before removing
      await _notificationService.cancelReminderNotification(id);
      
      // For authenticated users, delete from Firestore first
      if (_authService.isUserSignedIn()) {
        try {
          final success = await _firestoreService.deleteReminder(id);
          if (success) {
            // Also remove from local storage
            await _deleteReminderFromLocalStorage(id);
            debugPrint('ReminderService: Reminder deleted from cloud and local storage');
            return true;
          }
        } catch (e) {
          debugPrint('ReminderService: Failed to delete from cloud, using local storage: $e');
        }
      }
      
      // Fall back to local storage for unauthenticated users or cloud failures
      final reminders = await getAllReminders();
      reminders.removeWhere((reminder) => reminder.id == id);
      
      final remindersJson = reminders.map((r) => jsonEncode(r.toJson())).toList();
      final success = await _prefs!.setStringList(_remindersKey, remindersJson);
      
      debugPrint('ReminderService: Reminder deleted from local storage');
      return success;
    } catch (e) {
      debugPrint('ReminderService: Error deleting reminder: $e');
      return false;
    }
  }

  /// Get reminders by type
  Future<List<Reminder>> getRemindersByType(ReminderType type) async {
    final reminders = await getAllReminders();
    return reminders.where((reminder) => reminder.type == type).toList();
  }

  /// Get upcoming reminders (next 30 days)
  Future<List<Reminder>> getUpcomingReminders({int days = 30}) async {
    final reminders = await getAllReminders();
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    return reminders.where((reminder) {
      if (!reminder.isEnabled) return false;
      
      final nextOccurrence = reminder.getNextOccurrence();
      return nextOccurrence.isAfter(now) && nextOccurrence.isBefore(endDate);
    }).toList()
      ..sort((a, b) => a.getNextOccurrence().compareTo(b.getNextOccurrence()));
  }

  /// Get reminders for a specific date
  Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    final reminders = await getAllReminders();
    return reminders.where((reminder) => 
        reminder.isEnabled && reminder.shouldTriggerOnDate(date)).toList();
  }

  /// Get reminders for a specific Hijri date
  Future<List<Reminder>> getRemindersForHijriDate(HijriDate hijriDate) async {
    final reminders = await getAllReminders();
    return reminders.where((reminder) => 
        reminder.isEnabled && 
        reminder.hijriDate.month == hijriDate.month &&
        reminder.hijriDate.day == hijriDate.day).toList();
  }

  /// Validate reminder data using comprehensive validation
  ValidationResult validateReminder(Reminder reminder) {
    return InputValidator.validateReminder(
      reminder.title,
      reminder.description,
      reminder.hijriDate.year,
      reminder.hijriDate.month,
      reminder.hijriDate.day,
      reminder.type,
      reminder.notificationAdvance.inMinutes,
    );
  }

  /// Validate reminder data (legacy method for backward compatibility)
  String? validateReminderLegacy(Reminder reminder) {
    final result = validateReminder(reminder);
    return result.isValid ? null : result.errorMessage;
  }

  /// Generate unique ID for new reminder
  String generateReminderId() {
    return 'reminder_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Clear all reminders (for testing or reset)
  Future<bool> clearAllReminders() async {
    try {
      await initialize();
      return await _prefs!.remove(_remindersKey);
    } catch (e) {
      return false;
    }
  }

  /// Get reminder statistics
  Future<Map<String, int>> getReminderStatistics() async {
    final reminders = await getAllReminders();
    
    final stats = <String, int>{
      'total': reminders.length,
      'enabled': reminders.where((r) => r.isEnabled).length,
      'disabled': reminders.where((r) => !r.isEnabled).length,
      'recurring': reminders.where((r) => r.isRecurring).length,
      'oneTime': reminders.where((r) => !r.isRecurring).length,
    };
    
    // Count by type
    for (final type in ReminderType.values) {
      stats[type.name] = reminders.where((r) => r.type == type).length;
    }
    
    return stats;
  }

  /// Schedule notifications for all enabled reminders
  Future<void> scheduleAllReminderNotifications() async {
    try {
      final reminders = await getAllReminders();
      for (final reminder in reminders) {
        if (reminder.isEnabled) {
          final times = reminder.advanceNotifications.isNotEmpty
              ? reminder.advanceNotifications
              : [reminder.notificationAdvance];
          for (final d in times) {
            await _notificationService.scheduleReminderNotificationWithAdvance(reminder, advance: d);
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Cancel all reminder notifications
  Future<void> cancelAllReminderNotifications() async {
    try {
      final reminders = await getAllReminders();
      for (final reminder in reminders) {
        await _notificationService.cancelReminderNotification(reminder.id);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Enhanced methods for cloud reminder management and user preferences

  /// Sync reminders with cloud storage
  Future<bool> syncRemindersWithCloud() async {
    if (!_authService.isUserSignedIn()) {
      return false;
    }

    try {
      await initialize();
      
      // Load reminders from cloud
      final cloudReminders = await _firestoreService.loadReminders();
      
      // Load reminders from local storage
      final localReminders = await _loadFromLocalStorage();
      
      // Merge cloud and local reminders (cloud takes precedence)
      final mergedReminders = <String, Reminder>{};
      
      // Add local reminders first
      for (final reminder in localReminders) {
        mergedReminders[reminder.id] = reminder;
      }
      
      // Override with cloud reminders
      for (final reminder in cloudReminders) {
        mergedReminders[reminder.id] = reminder;
      }
      
      // Save merged reminders to local storage
      await _saveToLocalStorage(mergedReminders.values.toList());
      
      debugPrint('ReminderService: Synced ${mergedReminders.length} reminders with cloud');
      return true;
    } catch (e) {
      debugPrint('ReminderService: Failed to sync reminders with cloud: $e');
      return false;
    }
  }

  /// Load reminders from cloud storage
  Future<List<Reminder>> loadRemindersFromCloud() async {
    if (!_authService.isUserSignedIn()) {
      return [];
    }

    try {
      return await _firestoreService.loadReminders();
    } catch (e) {
      debugPrint('ReminderService: Failed to load reminders from cloud: $e');
      return [];
    }
  }

  /// Save reminders to cloud storage
  Future<bool> saveRemindersToCloud(List<Reminder> reminders) async {
    if (!_authService.isUserSignedIn()) {
      return false;
    }

    try {
      return await _firestoreService.saveReminders(reminders);
    } catch (e) {
      debugPrint('ReminderService: Failed to save reminders to cloud: $e');
      return false;
    }
  }

  /// Get default reminder settings from user preferences
  Future<Map<String, dynamic>> getDefaultReminderSettings() async {
    try {
      final settings = await _settingsService.getSettings();
      return {
        'selectedCalendarTypes': settings.defaultCalendarTypes,
        'advanceNotifications': settings.defaultAdvanceNotifications,
        'calendarPreference': settings.defaultReminderCalendarType,
        'notificationSettings': settings.reminderNotificationTimes,
      };
    } catch (e) {
      debugPrint('ReminderService: Failed to get default reminder settings: $e');
      return {
        'selectedCalendarTypes': ['gregorian'],
        'advanceNotifications': [Duration(hours: 1)],
        'calendarPreference': 'gregorian',
        'notificationSettings': {},
      };
    }
  }

  /// Apply user preferences to a reminder
  Future<Reminder> applyUserPreferences(Reminder reminder) async {
    try {
      final defaultSettings = await getDefaultReminderSettings();
      
      return reminder.copyWith(
        selectedCalendarTypes: reminder.selectedCalendarTypes.isEmpty 
            ? List<String>.from(defaultSettings['selectedCalendarTypes'])
            : reminder.selectedCalendarTypes,
        advanceNotifications: reminder.advanceNotifications.isEmpty 
            ? List<Duration>.from(defaultSettings['advanceNotifications'])
            : reminder.advanceNotifications,
        calendarPreference: reminder.calendarPreference.isEmpty 
            ? defaultSettings['calendarPreference'] as String
            : reminder.calendarPreference,
        notificationSettings: reminder.notificationSettings.isEmpty 
            ? Map<String, dynamic>.from(defaultSettings['notificationSettings'])
            : reminder.notificationSettings,
      );
    } catch (e) {
      debugPrint('ReminderService: Failed to apply user preferences: $e');
      return reminder;
    }
  }

  /// Migrate reminders on sign in
  Future<bool> migrateRemindersOnSignIn() async {
    try {
      await initialize();
      
      // Load local reminders
      final localReminders = await _loadFromLocalStorage();
      
      if (localReminders.isEmpty) {
        return true;
      }
      
      // Save to cloud
      final success = await saveRemindersToCloud(localReminders);
      
      if (success) {
        debugPrint('ReminderService: Migrated ${localReminders.length} reminders to cloud');
      }
      
      return success;
    } catch (e) {
      debugPrint('ReminderService: Failed to migrate reminders on sign in: $e');
      return false;
    }
  }

  /// Migrate reminders on sign out
  Future<bool> migrateRemindersOnSignOut() async {
    try {
      await initialize();
      
      // Load cloud reminders
      final cloudReminders = await loadRemindersFromCloud();
      
      if (cloudReminders.isEmpty) {
        return true;
      }
      
      // Save to local storage
      await _saveToLocalStorage(cloudReminders);
      
      debugPrint('ReminderService: Migrated ${cloudReminders.length} reminders to local storage');
      return true;
    } catch (e) {
      debugPrint('ReminderService: Failed to migrate reminders on sign out: $e');
      return false;
    }
  }

  /// Check if user has premium access for Hijri calendar features
  Future<bool> hasPremiumAccess() async {
    try {
      return await _subscriptionService.hasActiveSubscription();
    } catch (e) {
      debugPrint('ReminderService: Failed to check premium access: $e');
      return false;
    }
  }

  /// Validate premium features for reminder
  Future<bool> validatePremiumFeatures(Reminder reminder) async {
    try {
      final hasPremium = await hasPremiumAccess();
      
      // Check if reminder uses Hijri calendar
      if (reminder.supportsHijriCalendar() && !hasPremium) {
        return false;
      }
      
      // Check if reminder has multiple advance notifications (premium feature)
      if (reminder.hasMultipleAdvanceNotifications() && !hasPremium) {
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('ReminderService: Failed to validate premium features: $e');
      return false;
    }
  }

  /// Get real-time reminder updates using Firestore streams
  Stream<List<Reminder>> getReminderUpdates() {
    if (!_authService.isUserSignedIn()) {
      return Stream.value([]);
    }

    try {
      return _firestoreService.getReminderUpdates();
    } catch (e) {
      debugPrint('ReminderService: Failed to get reminder updates: $e');
      return Stream.value([]);
    }
  }

  // Private helper methods

  /// Save reminders to local storage
  Future<void> _saveToLocalStorage(List<Reminder> reminders) async {
    final remindersJson = reminders.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs!.setStringList(_remindersKey, remindersJson);
  }

  /// Load reminders from local storage
  Future<List<Reminder>> _loadFromLocalStorage() async {
    final remindersJson = _prefs?.getStringList(_remindersKey) ?? [];
    
    return remindersJson.map((json) {
      try {
        return Reminder.fromJson(jsonDecode(json));
      } catch (e) {
        return null;
      }
    }).where((reminder) => reminder != null).cast<Reminder>().toList();
  }

  /// Save a single reminder to local storage
  Future<void> _saveReminderToLocalStorage(Reminder reminder) async {
    final reminders = await _loadFromLocalStorage();
    
    final existingIndex = reminders.indexWhere((r) => r.id == reminder.id);
    if (existingIndex >= 0) {
      reminders[existingIndex] = reminder;
    } else {
      reminders.add(reminder);
    }
    
    await _saveToLocalStorage(reminders);
  }

  /// Delete a single reminder from local storage
  Future<void> _deleteReminderFromLocalStorage(String id) async {
    final reminders = await _loadFromLocalStorage();
    reminders.removeWhere((reminder) => reminder.id == id);
    await _saveToLocalStorage(reminders);
  }
}