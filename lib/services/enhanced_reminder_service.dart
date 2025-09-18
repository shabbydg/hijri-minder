import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/hijri_date.dart';
import 'notification_service.dart';
import 'firestore_service.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';
import '../utils/error_handler.dart';
import '../utils/input_validator.dart';

/// Enhanced reminder service with Firebase integration and local storage backup
class EnhancedReminderService {
  static const String _remindersKey = 'reminders';
  static const String _lastSyncKey = 'reminders_last_sync';
  static const String _backupRemindersKey = 'reminders_backup';
  
  SharedPreferences? _prefs;
  final NotificationService _notificationService = NotificationService();
  late FirestoreService _firestoreService;
  late AuthService _authService;
  final ConnectivityService _connectivityService = ConnectivityService();
  
  bool _isInitialized = false;

  /// Initialize the enhanced reminder service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _firestoreService = FirestoreService();
    _authService = AuthService();
    _prefs ??= await SharedPreferences.getInstance();
    _isInitialized = true;
    
    debugPrint('EnhancedReminderService: Initialized');
  }

  /// Get all reminders (local first, then sync with cloud)
  Future<List<Reminder>> getAllReminders() async {
    if (!_isInitialized) await initialize();
    
    try {
      // Always load from local storage first for fast access
      final localReminders = await _getLocalReminders();
      
      // If user is authenticated and online, sync with cloud
      if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
        try {
          final cloudReminders = await _firestoreService.loadReminders();
          
          // Merge local and cloud reminders (cloud takes precedence for conflicts)
          final mergedReminders = _mergeReminders(localReminders, cloudReminders);
          
          // Save merged reminders locally
          await _saveLocalReminders(mergedReminders);
          
          // Update cloud with any local-only reminders
          await _syncLocalToCloud(localReminders, cloudReminders);
          
          debugPrint('EnhancedReminderService: Loaded ${mergedReminders.length} reminders (local + cloud)');
          return mergedReminders;
        } catch (e) {
          debugPrint('EnhancedReminderService: Cloud sync failed, using local: $e');
        }
      }
      
      debugPrint('EnhancedReminderService: Loaded ${localReminders.length} reminders (local only)');
      return localReminders;
    } catch (e) {
      debugPrint('EnhancedReminderService: Error loading reminders: $e');
      return [];
    }
  }

  /// Save a reminder with validation and cloud sync
  Future<bool> saveReminder(Reminder reminder) async {
    if (!_isInitialized) await initialize();
    
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

        // Save locally first
        final localSuccess = await _saveReminderLocally(reminder);
        if (!localSuccess) {
          throw Exception('Failed to save reminder locally');
        }

        // Try to save to cloud if authenticated and online
        if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
          try {
            await _firestoreService.saveReminder(reminder);
            debugPrint('EnhancedReminderService: Reminder synced to cloud');
          } catch (e) {
            debugPrint('EnhancedReminderService: Cloud save failed: $e');
            // Continue with local save even if cloud fails
          }
        }
        
        // Schedule notification for the reminder
        if (reminder.isEnabled) {
          await _notificationService.scheduleReminderNotification(reminder);
        }
        
        return true;
      },
      () => false,
      'save reminder',
      errorType: ErrorType.storage,
      severity: ErrorSeverity.medium,
      context: {'reminderId': reminder.id},
    );
  }

  /// Delete a reminder from both local and cloud storage
  Future<bool> deleteReminder(String id) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Cancel notification before removing
      await _notificationService.cancelReminderNotification(id);
      
      // Delete locally
      final localSuccess = await _deleteReminderLocally(id);
      
      // Try to delete from cloud if authenticated and online
      if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
        try {
          await _firestoreService.deleteReminder(id);
          debugPrint('EnhancedReminderService: Reminder deleted from cloud');
        } catch (e) {
          debugPrint('EnhancedReminderService: Cloud delete failed: $e');
          // Continue even if cloud delete fails
        }
      }
      
      return localSuccess;
    } catch (e) {
      debugPrint('EnhancedReminderService: Error deleting reminder: $e');
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

  /// Get real-time updates for reminders
  Stream<List<Reminder>> getRemindersStream() {
    if (!_authService.isUserSignedIn()) {
      // Return local reminders as stream if not authenticated
      return Stream.fromFuture(getAllReminders());
    }
    
    return _firestoreService.getRemindersStream();
  }

  /// Force sync with cloud
  Future<bool> forceSyncWithCloud() async {
    if (!_authService.isUserSignedIn()) {
      debugPrint('EnhancedReminderService: Cannot sync - user not authenticated');
      return false;
    }
    
    if (!_connectivityService.isOnline) {
      debugPrint('EnhancedReminderService: Cannot sync - offline');
      return false;
    }
    
    try {
      final localReminders = await _getLocalReminders();
      await _firestoreService.saveReminders(localReminders);
      
      await _prefs!.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('EnhancedReminderService: Force sync completed');
      return true;
    } catch (e) {
      debugPrint('EnhancedReminderService: Force sync failed: $e');
      return false;
    }
  }

  /// Load reminders from cloud (overwrites local)
  Future<bool> loadFromCloud() async {
    if (!_authService.isUserSignedIn()) {
      debugPrint('EnhancedReminderService: Cannot load from cloud - user not authenticated');
      return false;
    }
    
    if (!_connectivityService.isOnline) {
      debugPrint('EnhancedReminderService: Cannot load from cloud - offline');
      return false;
    }
    
    try {
      final cloudReminders = await _firestoreService.loadReminders();
      await _saveLocalReminders(cloudReminders);
      
      debugPrint('EnhancedReminderService: Reminders loaded from cloud');
      return true;
    } catch (e) {
      debugPrint('EnhancedReminderService: Load from cloud failed: $e');
      return false;
    }
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

  /// Generate unique ID for new reminder
  String generateReminderId() {
    return 'reminder_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Clear all reminders (for testing or reset)
  Future<bool> clearAllReminders() async {
    if (!_isInitialized) await initialize();
    
    try {
      // Clear locally
      await _prefs!.remove(_remindersKey);
      await _prefs!.remove(_backupRemindersKey);
      
      // Try to clear from cloud if authenticated and online
      if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
        try {
          await _firestoreService.clearAllUserData();
          debugPrint('EnhancedReminderService: Reminders cleared from cloud');
        } catch (e) {
          debugPrint('EnhancedReminderService: Cloud clear failed: $e');
        }
      }
      
      // Cancel all notifications
      await cancelAllReminderNotifications();
      
      return true;
    } catch (e) {
      debugPrint('EnhancedReminderService: Error clearing reminders: $e');
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
          await _notificationService.scheduleReminderNotification(reminder);
        }
      }
    } catch (e) {
      debugPrint('EnhancedReminderService: Error scheduling notifications: $e');
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
      debugPrint('EnhancedReminderService: Error canceling notifications: $e');
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    if (!_isInitialized) await initialize();
    
    final lastSync = _prefs!.getInt(_lastSyncKey);
    final hasLocalReminders = _prefs!.containsKey(_remindersKey);
    final hasBackupReminders = _prefs!.containsKey(_backupRemindersKey);
    
    bool hasCloudReminders = false;
    if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
      try {
        hasCloudReminders = await _firestoreService.hasUserData();
      } catch (e) {
        debugPrint('EnhancedReminderService: Error checking cloud data: $e');
      }
    }
    
    return {
      'isOnline': _connectivityService.isOnline,
      'isAuthenticated': _authService.isUserSignedIn(),
      'hasLocalReminders': hasLocalReminders,
      'hasBackupReminders': hasBackupReminders,
      'hasCloudReminders': hasCloudReminders,
      'lastSync': lastSync != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastSync).toIso8601String()
          : null,
      'canSync': _authService.isUserSignedIn() && _connectivityService.isOnline,
    };
  }

  // Private helper methods

  /// Get reminders from local storage
  Future<List<Reminder>> _getLocalReminders() async {
    final remindersJson = _prefs?.getStringList(_remindersKey) ?? [];
    
    return remindersJson.map((json) {
      try {
        return Reminder.fromJson(jsonDecode(json));
      } catch (e) {
        debugPrint('EnhancedReminderService: Error parsing reminder JSON: $e');
        return null;
      }
    }).where((reminder) => reminder != null).cast<Reminder>().toList();
  }

  /// Save reminders to local storage
  Future<bool> _saveLocalReminders(List<Reminder> reminders) async {
    try {
      final remindersJson = reminders.map((r) => jsonEncode(r.toJson())).toList();
      
      // Save primary
      await _prefs!.setStringList(_remindersKey, remindersJson);
      
      // Create backup
      await _prefs!.setStringList(_backupRemindersKey, remindersJson);
      
      return true;
    } catch (e) {
      debugPrint('EnhancedReminderService: Error saving local reminders: $e');
      return false;
    }
  }

  /// Save a single reminder locally
  Future<bool> _saveReminderLocally(Reminder reminder) async {
    try {
      final reminders = await _getLocalReminders();
      
      // Check if reminder with same ID exists
      final existingIndex = reminders.indexWhere((r) => r.id == reminder.id);
      
      if (existingIndex >= 0) {
        // Update existing reminder
        reminders[existingIndex] = reminder;
      } else {
        // Add new reminder
        reminders.add(reminder);
      }
      
      return await _saveLocalReminders(reminders);
    } catch (e) {
      debugPrint('EnhancedReminderService: Error saving reminder locally: $e');
      return false;
    }
  }

  /// Delete a reminder locally
  Future<bool> _deleteReminderLocally(String id) async {
    try {
      final reminders = await _getLocalReminders();
      reminders.removeWhere((reminder) => reminder.id == id);
      return await _saveLocalReminders(reminders);
    } catch (e) {
      debugPrint('EnhancedReminderService: Error deleting reminder locally: $e');
      return false;
    }
  }

  /// Merge local and cloud reminders (cloud takes precedence for conflicts)
  List<Reminder> _mergeReminders(List<Reminder> local, List<Reminder> cloud) {
    final Map<String, Reminder> merged = {};
    
    // Add local reminders first
    for (final reminder in local) {
      merged[reminder.id] = reminder;
    }
    
    // Override with cloud reminders (cloud takes precedence)
    for (final reminder in cloud) {
      merged[reminder.id] = reminder;
    }
    
    return merged.values.toList();
  }

  /// Sync local-only reminders to cloud
  Future<void> _syncLocalToCloud(List<Reminder> local, List<Reminder> cloud) async {
    try {
      final cloudIds = cloud.map((r) => r.id).toSet();
      final localOnlyReminders = local.where((r) => !cloudIds.contains(r.id)).toList();
      
      if (localOnlyReminders.isNotEmpty) {
        for (final reminder in localOnlyReminders) {
          await _firestoreService.saveReminder(reminder);
        }
        debugPrint('EnhancedReminderService: Synced ${localOnlyReminders.length} local-only reminders to cloud');
      }
    } catch (e) {
      debugPrint('EnhancedReminderService: Error syncing local to cloud: $e');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isUserSignedIn();

  /// Check if online
  bool get isOnline => _connectivityService.isOnline;
}
