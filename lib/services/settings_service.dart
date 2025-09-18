import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/app_settings.dart';
import '../models/user_profile.dart';
import '../models/reminder_preferences.dart';
import '../models/subscription_types.dart';
import 'connectivity_service.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'subscription_service.dart';

/// Service for managing user preferences and app settings with offline support
/// Provides persistent storage using SharedPreferences and Firestore for authenticated users
class SettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _backupSettingsKey = 'app_settings_backup';
  static const String _cloudSettingsKey = 'cloud_settings';
  SharedPreferences? _prefs;
  AppSettings? _cachedSettings;
  final ConnectivityService _connectivityService = ConnectivityService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  /// Initialize SharedPreferences instance
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get current app settings with fallback recovery
  /// Returns AppSettings object with current preferences
  /// For authenticated users, tries to load from Firestore first
  Future<AppSettings> getSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    await _initPrefs();
    
    // For authenticated users, try to load from Firestore first
    if (_authService.isUserSignedIn()) {
      try {
        final cloudSettings = await _firestoreService.loadUserSettings();
        if (cloudSettings != null) {
          _cachedSettings = cloudSettings;
          // Sync to local storage as backup
          await _saveToLocalStorage(cloudSettings);
          debugPrint('SettingsService: Loaded settings from Firestore');
          return _cachedSettings!;
        }
      } catch (e) {
        debugPrint('SettingsService: Error loading from Firestore: $e');
        // Fall back to local storage
      }
    }
    
    try {
      // Try to load primary settings from local storage
      final String? settingsJson = _prefs!.getString(_settingsKey);
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(settingsJson);
        _cachedSettings = AppSettings.fromJson(settingsMap);
        debugPrint('SettingsService: Loaded settings from primary storage');
        return _cachedSettings!;
      }
      
      // Try backup settings if primary fails
      final String? backupSettingsJson = _prefs!.getString(_backupSettingsKey);
      if (backupSettingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(backupSettingsJson);
        _cachedSettings = AppSettings.fromJson(settingsMap);
        
        // Restore primary settings from backup
        await _prefs!.setString(_settingsKey, backupSettingsJson);
        
        debugPrint('SettingsService: Restored settings from backup');
        return _cachedSettings!;
      }
    } catch (e) {
      debugPrint('SettingsService: Error loading settings: $e');
      
      // Try to recover from backup
      try {
        final String? backupSettingsJson = _prefs!.getString(_backupSettingsKey);
        if (backupSettingsJson != null) {
          final Map<String, dynamic> settingsMap = json.decode(backupSettingsJson);
          _cachedSettings = AppSettings.fromJson(settingsMap);
          debugPrint('SettingsService: Recovered settings from backup after error');
          return _cachedSettings!;
        }
      } catch (backupError) {
        debugPrint('SettingsService: Backup recovery also failed: $backupError');
      }
    }

    // Use default settings as last resort
    _cachedSettings = AppSettings.defaultSettings();
    await saveSettings(_cachedSettings!); // Save defaults for future use
    debugPrint('SettingsService: Using default settings');
    return _cachedSettings!;
  }

  /// Save complete app settings with backup
  /// Returns true if successful, false otherwise
  /// For authenticated users, saves to both Firestore and local storage
  Future<bool> saveSettings(AppSettings settings) async {
    await _initPrefs();
    
    try {
      // Save to local storage first
      final success = await _saveToLocalStorage(settings);
      if (!success) {
        debugPrint('SettingsService: Failed to save to local storage');
        return false;
      }
      
      // For authenticated users, also save to Firestore
      if (_authService.isUserSignedIn()) {
        try {
          await _firestoreService.saveUserSettings(settings);
          debugPrint('SettingsService: Settings saved to Firestore');
        } catch (e) {
          debugPrint('SettingsService: Error saving to Firestore: $e');
          // Continue with local storage success
        }
      }
      
      _cachedSettings = settings;
      debugPrint('SettingsService: Settings saved successfully');
      return true;
    } catch (e) {
      debugPrint('SettingsService: Error saving settings: $e');
      return false;
    }
  }

  /// Save settings to local storage
  Future<bool> _saveToLocalStorage(AppSettings settings) async {
    try {
      final String settingsJson = json.encode(settings.toJson());
      
      // Save primary settings
      await _prefs!.setString(_settingsKey, settingsJson);
      
      // Create backup copy
      await _prefs!.setString(_backupSettingsKey, settingsJson);
      
      // Add timestamp for sync tracking
      await _prefs!.setInt('settings_last_updated', DateTime.now().millisecondsSinceEpoch);
      
      debugPrint('SettingsService: Settings saved to local storage with backup');
      return true;
    } catch (e) {
      debugPrint('SettingsService: Error saving to local storage: $e');
      return false;
    }
  }

  /// Update a specific setting
  /// Returns true if successful, false otherwise
  Future<bool> updateSetting<T>(String key, T value) async {
    await _initPrefs();
    
    try {
      AppSettings currentSettings = await getSettings();
      AppSettings updatedSettings;

      switch (key) {
        case 'enablePrayerNotifications':
          updatedSettings = currentSettings.copyWith(enablePrayerNotifications: value as bool);
          break;
        case 'enableAdhanSounds':
          updatedSettings = currentSettings.copyWith(enableAdhanSounds: value as bool);
          break;
        case 'enableLocationServices':
          updatedSettings = currentSettings.copyWith(enableLocationServices: value as bool);
          break;
        case 'language':
          updatedSettings = currentSettings.copyWith(language: value as String);
          break;
        case 'theme':
          updatedSettings = currentSettings.copyWith(theme: value as String);
          break;
        case 'showGregorianDates':
          updatedSettings = currentSettings.copyWith(showGregorianDates: value as bool);
          break;
        case 'showEventDots':
          updatedSettings = currentSettings.copyWith(showEventDots: value as bool);
          break;
        case 'prayerTimeFormat':
          updatedSettings = currentSettings.copyWith(prayerTimeFormat: value as String);
          break;
        case 'prayerNotificationAdvanceMinutes':
          updatedSettings = currentSettings.copyWith(prayerNotificationAdvance: Duration(minutes: value as int));
          break;
        default:
          debugPrint('SettingsService: Unknown setting key: $key');
          return false;
      }

      return await saveSettings(updatedSettings);
    } catch (e) {
      debugPrint('SettingsService: Error updating setting $key: $e');
      return false;
    }
  }

  /// Reset all settings to default values
  /// Returns true if successful, false otherwise
  Future<bool> resetToDefault() async {
    await _initPrefs();
    
    try {
      await _prefs!.remove(_settingsKey);
      _cachedSettings = null;
      return true;
    } catch (e) {
      debugPrint('SettingsService: Error resetting settings: $e');
      return false;
    }
  }

  /// Get a specific setting value
  /// Returns the setting value or default if not found
  Future<T> getSetting<T>(String key, T defaultValue) async {
    await _initPrefs();
    
    try {
      if (T == bool) {
        return (_prefs!.getBool(key) ?? defaultValue) as T;
      } else if (T == String) {
        return (_prefs!.getString(key) ?? defaultValue) as T;
      } else if (T == int) {
        return (_prefs!.getInt(key) ?? defaultValue) as T;
      } else if (T == double) {
        return (_prefs!.getDouble(key) ?? defaultValue) as T;
      } else {
        return defaultValue;
      }
    } catch (e) {
      debugPrint('SettingsService: Error getting setting $key: $e');
      return defaultValue;
    }
  }

  /// Clear cached settings (force reload from storage)
  void clearCache() {
    _cachedSettings = null;
  }

  /// Sync settings when connectivity returns
  Future<void> syncWhenOnline() async {
    if (!_connectivityService.isOnline) {
      debugPrint('SettingsService: Cannot sync - still offline');
      return;
    }

    debugPrint('SettingsService: Syncing settings...');
    
    // Ensure settings are properly backed up
    final currentSettings = await getSettings();
    await saveSettings(currentSettings);
    
    debugPrint('SettingsService: Settings sync completed');
  }

  /// Get offline status indicator
  bool get isOffline => !_connectivityService.isOnline;

  /// Verify settings integrity
  Future<bool> verifySettingsIntegrity() async {
    await _initPrefs();
    
    try {
      // Check if primary settings exist and are valid
      final String? settingsJson = _prefs!.getString(_settingsKey);
      if (settingsJson != null) {
        json.decode(settingsJson); // This will throw if invalid JSON
      }
      
      // Check if backup settings exist and are valid
      final String? backupSettingsJson = _prefs!.getString(_backupSettingsKey);
      if (backupSettingsJson != null) {
        json.decode(backupSettingsJson); // This will throw if invalid JSON
      }
      
      debugPrint('SettingsService: Settings integrity verified');
      return true;
    } catch (e) {
      debugPrint('SettingsService: Settings integrity check failed: $e');
      return false;
    }
  }

  /// Repair corrupted settings
  Future<bool> repairSettings() async {
    await _initPrefs();
    
    try {
      debugPrint('SettingsService: Attempting to repair settings...');
      
      // Try to use backup settings
      final String? backupSettingsJson = _prefs!.getString(_backupSettingsKey);
      if (backupSettingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(backupSettingsJson);
        final settings = AppSettings.fromJson(settingsMap);
        
        // Restore primary settings from backup
        await saveSettings(settings);
        _cachedSettings = settings;
        
        debugPrint('SettingsService: Settings repaired from backup');
        return true;
      }
      
      // Use default settings if backup is also corrupted
      final defaultSettings = AppSettings.defaultSettings();
      await saveSettings(defaultSettings);
      _cachedSettings = defaultSettings;
      
      debugPrint('SettingsService: Settings repaired with defaults');
      return true;
    } catch (e) {
      debugPrint('SettingsService: Settings repair failed: $e');
      return false;
    }
  }

  /// Get settings status information
  Future<Map<String, dynamic>> getSettingsStatus() async {
    await _initPrefs();
    
    final hasSettings = _prefs!.containsKey(_settingsKey);
    final hasBackup = _prefs!.containsKey(_backupSettingsKey);
    final lastUpdated = _prefs!.getInt('settings_last_updated');
    
    return {
      'isOnline': _connectivityService.isOnline,
      'isAuthenticated': _authService.isUserSignedIn(),
      'hasSettings': hasSettings,
      'hasBackup': hasBackup,
      'lastUpdated': lastUpdated != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastUpdated).toIso8601String()
          : null,
      'isIntegrityValid': await verifySettingsIntegrity(),
    };
  }

  // Cloud Settings Management Methods

  /// Save settings to cloud (Firestore)
  Future<bool> saveSettingsToCloud(AppSettings settings) async {
    if (!_authService.isUserSignedIn()) {
      debugPrint('SettingsService: Cannot save to cloud - user not authenticated');
      return false;
    }

    try {
      await _firestoreService.saveUserSettings(settings);
      debugPrint('SettingsService: Settings saved to cloud successfully');
      return true;
    } catch (e) {
      debugPrint('SettingsService: Error saving settings to cloud: $e');
      return false;
    }
  }

  /// Load settings from cloud (Firestore)
  Future<AppSettings?> loadSettingsFromCloud() async {
    if (!_authService.isUserSignedIn()) {
      debugPrint('SettingsService: Cannot load from cloud - user not authenticated');
      return null;
    }

    try {
      final cloudSettings = await _firestoreService.loadUserSettings();
      if (cloudSettings != null) {
        debugPrint('SettingsService: Settings loaded from cloud successfully');
        return cloudSettings;
      }
      return null;
    } catch (e) {
      debugPrint('SettingsService: Error loading settings from cloud: $e');
      return null;
    }
  }

  /// Sync settings with cloud
  Future<bool> syncSettingsWithCloud() async {
    if (!_authService.isUserSignedIn()) {
      debugPrint('SettingsService: Cannot sync with cloud - user not authenticated');
      return false;
    }

    try {
      final localSettings = await getSettings();
      await _firestoreService.saveUserSettings(localSettings);
      debugPrint('SettingsService: Settings synced with cloud successfully');
      return true;
    } catch (e) {
      debugPrint('SettingsService: Error syncing settings with cloud: $e');
      return false;
    }
  }

  // User Profile Integration Methods

  /// Get user profile
  Future<UserProfile?> getUserProfile() async {
    if (!_authService.isUserSignedIn()) {
      return null;
    }

    try {
      final userId = _authService.getCurrentUserId();
      if (userId == null) return null;
      
      return await _firestoreService.loadUserProfile(userId);
    } catch (e) {
      debugPrint('SettingsService: Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    if (!_authService.isUserSignedIn()) {
      debugPrint('SettingsService: Cannot update profile - user not authenticated');
      return false;
    }

    try {
      await _firestoreService.updateUserProfile(profile);
      debugPrint('SettingsService: User profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('SettingsService: Error updating user profile: $e');
      return false;
    }
  }

  // Reminder Preferences Management Methods

  /// Get default reminder settings
  Future<ReminderPreferences> getDefaultReminderSettings() async {
    if (_authService.isUserSignedIn()) {
      try {
        final userProfile = await getUserProfile();
        if (userProfile != null) {
          return userProfile.defaultReminderSettings;
        }
      } catch (e) {
        debugPrint('SettingsService: Error getting reminder settings from profile: $e');
      }
    }

    // Fall back to app settings
    try {
      final appSettings = await getSettings();
      return ReminderPreferences(
        preferredCalendarTypes: appSettings.defaultCalendarTypes,
        primaryCalendarType: appSettings.defaultReminderCalendarType,
        defaultAdvanceNotifications: appSettings.defaultAdvanceNotifications,
        notificationTimes: appSettings.reminderNotificationTimes,
        defaultReminderType: 'prayer',
        enableRecurring: true,
        defaultMessageTemplates: const ['Prayer reminder', 'Hijri date reminder'],
        enableCustomMessages: true,
      );
    } catch (e) {
      debugPrint('SettingsService: Error getting reminder settings from app settings: $e');
      return ReminderPreferences.defaultSettings();
    }
  }

  /// Update default reminder settings
  Future<bool> updateDefaultReminderSettings(ReminderPreferences settings) async {
    if (_authService.isUserSignedIn()) {
      try {
        final userProfile = await getUserProfile();
        if (userProfile != null) {
          final updatedProfile = userProfile.copyWith(
            defaultReminderSettings: settings,
            updatedAt: DateTime.now(),
          );
          return await updateUserProfile(updatedProfile);
        }
      } catch (e) {
        debugPrint('SettingsService: Error updating reminder settings in profile: $e');
      }
    }

    // Fall back to app settings
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        defaultCalendarTypes: settings.preferredCalendarTypes,
        defaultReminderCalendarType: settings.primaryCalendarType,
        defaultAdvanceNotifications: settings.defaultAdvanceNotifications,
        reminderNotificationTimes: settings.notificationTimes,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      debugPrint('SettingsService: Error updating reminder settings in app settings: $e');
      return false;
    }
  }

  // Settings Migration Methods

  /// Migrate settings when user signs in
  Future<bool> migrateSettingsOnSignIn() async {
    if (!_authService.isUserSignedIn()) {
      debugPrint('SettingsService: Cannot migrate - user not authenticated');
      return false;
    }

    try {
      // Load local settings
      final localSettings = await getSettings();
      
      // Check if cloud settings exist
      final cloudSettings = await loadSettingsFromCloud();
      
      if (cloudSettings != null) {
        // Merge cloud settings with local settings (cloud takes precedence)
        final mergedSettings = _mergeSettings(localSettings, cloudSettings);
        await saveSettings(mergedSettings);
        debugPrint('SettingsService: Settings migrated on sign in (cloud priority)');
      } else {
        // Upload local settings to cloud
        await saveSettingsToCloud(localSettings);
        debugPrint('SettingsService: Settings migrated on sign in (local to cloud)');
      }
      
      return true;
    } catch (e) {
      debugPrint('SettingsService: Error migrating settings on sign in: $e');
      return false;
    }
  }

  /// Migrate settings when user signs out
  Future<bool> migrateSettingsOnSignOut() async {
    try {
      // Ensure local settings are up to date
      final currentSettings = await getSettings();
      await _saveToLocalStorage(currentSettings);
      debugPrint('SettingsService: Settings migrated on sign out');
      return true;
    } catch (e) {
      debugPrint('SettingsService: Error migrating settings on sign out: $e');
      return false;
    }
  }

  /// Merge two settings objects (cloud takes precedence)
  AppSettings _mergeSettings(AppSettings local, AppSettings cloud) {
    return cloud.copyWith(
      // Keep some local preferences that shouldn't be overridden
      language: local.language,
      theme: local.theme,
      fontSize: local.fontSize,
    );
  }

  /// Check if user has premium access to reminder features
  bool hasPremiumReminderAccess() {
    return _subscriptionService.hasAccessToFeature(PremiumFeature.hijriReminders);
  }

  /// Check if user can create Hijri reminders
  bool canCreateHijriReminders() {
    return _subscriptionService.hasAccessToHijriReminders();
  }

  /// Check if user can use messaging features
  bool canUseMessagingFeatures() {
    return _subscriptionService.hasAccessToMessaging();
  }
}