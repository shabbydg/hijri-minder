import 'package:flutter/material.dart';
import 'reminder_service.dart';
import 'enhanced_reminder_service.dart';
import 'firestore_service.dart';
import 'auth_service.dart';
import '../models/reminder.dart';

/// Service to migrate reminders from old service to enhanced service
class ReminderMigrationService {
  final ReminderService _oldReminderService = ReminderService();
  late EnhancedReminderService _enhancedReminderService;
  late FirestoreService _firestoreService;
  late AuthService _authService;

  /// Initialize the migration service
  Future<void> initialize() async {
    _enhancedReminderService = EnhancedReminderService();
    _firestoreService = FirestoreService();
    _authService = AuthService();
    
    await _oldReminderService.initialize();
    await _enhancedReminderService.initialize();
  }

  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      // Check if old service has reminders
      final oldReminders = await _oldReminderService.getAllReminders();
      
      // Check if enhanced service has reminders
      final enhancedReminders = await _enhancedReminderService.getAllReminders();
      
      // Migration needed if old service has reminders but enhanced service doesn't
      return oldReminders.isNotEmpty && enhancedReminders.isEmpty;
    } catch (e) {
      debugPrint('ReminderMigrationService: Error checking migration status: $e');
      return false;
    }
  }

  /// Migrate reminders from old service to enhanced service
  Future<bool> migrateReminders() async {
    try {
      debugPrint('ReminderMigrationService: Starting reminder migration...');
      
      // Get reminders from old service
      final oldReminders = await _oldReminderService.getAllReminders();
      
      if (oldReminders.isEmpty) {
        debugPrint('ReminderMigrationService: No reminders to migrate');
        return true;
      }
      
      debugPrint('ReminderMigrationService: Found ${oldReminders.length} reminders to migrate');
      
      // Migrate each reminder
      int successCount = 0;
      int failCount = 0;
      
      for (final reminder in oldReminders) {
        try {
          final success = await _enhancedReminderService.saveReminder(reminder);
          if (success) {
            successCount++;
            debugPrint('ReminderMigrationService: Migrated reminder: ${reminder.title}');
          } else {
            failCount++;
            debugPrint('ReminderMigrationService: Failed to migrate reminder: ${reminder.title}');
          }
        } catch (e) {
          failCount++;
          debugPrint('ReminderMigrationService: Error migrating reminder ${reminder.title}: $e');
        }
      }
      
      debugPrint('ReminderMigrationService: Migration completed - Success: $successCount, Failed: $failCount');
      
      // If all reminders were migrated successfully, clear old reminders
      if (failCount == 0) {
        await _oldReminderService.clearAllReminders();
        debugPrint('ReminderMigrationService: Cleared old reminders after successful migration');
      }
      
      return failCount == 0;
    } catch (e) {
      debugPrint('ReminderMigrationService: Migration failed: $e');
      return false;
    }
  }

  /// Get migration status
  Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      final oldReminders = await _oldReminderService.getAllReminders();
      final enhancedReminders = await _enhancedReminderService.getAllReminders();
      final isNeeded = await isMigrationNeeded();
      
      return {
        'isNeeded': isNeeded,
        'oldRemindersCount': oldReminders.length,
        'enhancedRemindersCount': enhancedReminders.length,
        'canMigrate': oldReminders.isNotEmpty,
        'isAuthenticated': _authService.isUserSignedIn(),
      };
    } catch (e) {
      debugPrint('ReminderMigrationService: Error getting migration status: $e');
      return {
        'isNeeded': false,
        'oldRemindersCount': 0,
        'enhancedRemindersCount': 0,
        'canMigrate': false,
        'isAuthenticated': false,
        'error': e.toString(),
      };
    }
  }

  /// Backup old reminders before migration
  Future<bool> backupOldReminders() async {
    try {
      final oldReminders = await _oldReminderService.getAllReminders();
      
      if (oldReminders.isEmpty) {
        return true;
      }
      
      // Save backup to enhanced service with a backup prefix
      for (final reminder in oldReminders) {
        final backupReminder = reminder.copyWith(
          id: 'backup_${reminder.id}',
          title: '[BACKUP] ${reminder.title}',
        );
        
        await _enhancedReminderService.saveReminder(backupReminder);
      }
      
      debugPrint('ReminderMigrationService: Backed up ${oldReminders.length} reminders');
      return true;
    } catch (e) {
      debugPrint('ReminderMigrationService: Error backing up reminders: $e');
      return false;
    }
  }

  /// Restore reminders from backup
  Future<bool> restoreFromBackup() async {
    try {
      final allReminders = await _enhancedReminderService.getAllReminders();
      final backupReminders = allReminders.where((r) => r.id.startsWith('backup_')).toList();
      
      if (backupReminders.isEmpty) {
        debugPrint('ReminderMigrationService: No backup reminders found');
        return true;
      }
      
      int restoredCount = 0;
      for (final backupReminder in backupReminders) {
        final restoredReminder = backupReminder.copyWith(
          id: backupReminder.id.replaceFirst('backup_', ''),
          title: backupReminder.title.replaceFirst('[BACKUP] ', ''),
        );
        
        final success = await _enhancedReminderService.saveReminder(restoredReminder);
        if (success) {
          restoredCount++;
        }
      }
      
      debugPrint('ReminderMigrationService: Restored $restoredCount reminders from backup');
      return restoredCount == backupReminders.length;
    } catch (e) {
      debugPrint('ReminderMigrationService: Error restoring from backup: $e');
      return false;
    }
  }

  /// Clean up backup reminders
  Future<bool> cleanupBackupReminders() async {
    try {
      final allReminders = await _enhancedReminderService.getAllReminders();
      final backupReminders = allReminders.where((r) => r.id.startsWith('backup_')).toList();
      
      for (final backupReminder in backupReminders) {
        await _enhancedReminderService.deleteReminder(backupReminder.id);
      }
      
      debugPrint('ReminderMigrationService: Cleaned up ${backupReminders.length} backup reminders');
      return true;
    } catch (e) {
      debugPrint('ReminderMigrationService: Error cleaning up backup reminders: $e');
      return false;
    }
  }

  /// Complete migration process with backup and cleanup
  Future<bool> completeMigration() async {
    try {
      debugPrint('ReminderMigrationService: Starting complete migration process...');
      
      // Step 1: Check if migration is needed
      if (!await isMigrationNeeded()) {
        debugPrint('ReminderMigrationService: No migration needed');
        return true;
      }
      
      // Step 2: Backup old reminders
      final backupSuccess = await backupOldReminders();
      if (!backupSuccess) {
        debugPrint('ReminderMigrationService: Backup failed, aborting migration');
        return false;
      }
      
      // Step 3: Migrate reminders
      final migrationSuccess = await migrateReminders();
      if (!migrationSuccess) {
        debugPrint('ReminderMigrationService: Migration failed, keeping backup');
        return false;
      }
      
      // Step 4: Clean up backup reminders
      await cleanupBackupReminders();
      
      debugPrint('ReminderMigrationService: Complete migration successful');
      return true;
    } catch (e) {
      debugPrint('ReminderMigrationService: Complete migration failed: $e');
      return false;
    }
  }
}
