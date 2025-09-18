import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/app_settings.dart';
import 'connectivity_service.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

/// Enhanced settings service with Firebase sync capabilities
/// Provides persistent storage using SharedPreferences with cloud backup
class EnhancedSettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _backupSettingsKey = 'app_settings_backup';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  SharedPreferences? _prefs;
  AppSettings? _cachedSettings;
  final ConnectivityService _connectivityService = ConnectivityService();
  late FirestoreService _firestoreService;
  late AuthService _authService;
  
  bool _isInitialized = false;

  /// Initialize the enhanced settings service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _firestoreService = FirestoreService();
    _authService = AuthService();
    await _initPrefs();
    _isInitialized = true;
    
    debugPrint('EnhancedSettingsService: Initialized');
  }

  /// Initialize SharedPreferences instance
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get current app settings with cloud sync
  /// Returns AppSettings object with current preferences
  Future<AppSettings> getSettings() async {
    if (!_isInitialized) await initialize();
    
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    await _initPrefs();
    
    try {
      // Try to load primary settings
      final String? settingsJson = _prefs!.getString(_settingsKey);
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(settingsJson);
        _cachedSettings = AppSettings.fromJson(settingsMap);
        debugPrint('EnhancedSettingsService: Loaded settings from local storage');
        
        // Try to sync with cloud if user is authenticated and online
        if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
          _syncWithCloud();
        }
        
        return _cachedSettings!;
      }
      
      // Try backup settings if primary fails
      final String? backupSettingsJson = _prefs!.getString(_backupSettingsKey);
      if (backupSettingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(backupSettingsJson);
        _cachedSettings = AppSettings.fromJson(settingsMap);
        
        // Restore primary settings from backup
        await _prefs!.setString(_settingsKey, backupSettingsJson);
        
        debugPrint('EnhancedSettingsService: Restored settings from backup');
        return _cachedSettings!;
      }
    } catch (e) {
      debugPrint('EnhancedSettingsService: Error loading settings: $e');
      
      // Try to recover from backup
      try {
        final String? backupSettingsJson = _prefs!.getString(_backupSettingsKey);
        if (backupSettingsJson != null) {
          final Map<String, dynamic> settingsMap = json.decode(backupSettingsJson);
          _cachedSettings = AppSettings.fromJson(settingsMap);
          debugPrint('EnhancedSettingsService: Recovered settings from backup after error');
          return _cachedSettings!;
        }
      } catch (backupError) {
        debugPrint('EnhancedSettingsService: Backup recovery also failed: $backupError');
      }
    }

    // Try to load from cloud if user is authenticated
    if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
      try {
        final cloudSettings = await _firestoreService.loadUserSettings();
        if (cloudSettings != null) {
          _cachedSettings = cloudSettings;
          await saveSettings(_cachedSettings!); // Save locally
          debugPrint('EnhancedSettingsService: Loaded settings from cloud');
          return _cachedSettings!;
        }
      } catch (e) {
        debugPrint('EnhancedSettingsService: Error loading from cloud: $e');
      }
    }

    // Use default settings as last resort
    _cachedSettings = AppSettings.defaultSettings();
    await saveSettings(_cachedSettings!); // Save defaults for future use
    debugPrint('EnhancedSettingsService: Using default settings');
    return _cachedSettings!;
  }

  /// Save complete app settings with cloud sync
  /// Returns true if successful, false otherwise
  Future<bool> saveSettings(AppSettings settings) async {
    if (!_isInitialized) await initialize();
    
    await _initPrefs();
    
    try {
      final String settingsJson = json.encode(settings.toJson());
      
      // Save primary settings locally
      await _prefs!.setString(_settingsKey, settingsJson);
      
      // Create backup copy
      await _prefs!.setString(_backupSettingsKey, settingsJson);
      
      // Add timestamp for sync tracking
      await _prefs!.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      
      _cachedSettings = settings;
      debugPrint('EnhancedSettingsService: Settings saved locally');
      
      // Try to sync with cloud if user is authenticated and online
      if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
        try {
          await _firestoreService.saveUserSettings(settings);
          debugPrint('EnhancedSettingsService: Settings synced to cloud');
        } catch (e) {
          debugPrint('EnhancedSettingsService: Cloud sync failed: $e');
          // Continue with local save even if cloud sync fails
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('EnhancedSettingsService: Error saving settings: $e');
      return false;
    }
  }

  /// Sync settings with cloud
  Future<void> _syncWithCloud() async {
    if (!_authService.isUserSignedIn() || !_connectivityService.isOnline) {
      return;
    }
    
    try {
      final lastSync = _prefs!.getInt(_lastSyncKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Only sync if it's been more than 5 minutes since last sync
      if (now - lastSync < 5 * 60 * 1000) {
        return;
      }
      
      // Try to load from cloud and compare with local
      final cloudSettings = await _firestoreService.loadUserSettings();
      if (cloudSettings != null) {
        // For now, prioritize local settings over cloud
        // In a more sophisticated implementation, you might want to merge or resolve conflicts
        await _firestoreService.saveUserSettings(_cachedSettings!);
        debugPrint('EnhancedSettingsService: Settings synced to cloud');
      } else {
        // No cloud settings exist, upload local settings
        await _firestoreService.saveUserSettings(_cachedSettings!);
        debugPrint('EnhancedSettingsService: Settings uploaded to cloud');
      }
      
      await _prefs!.setInt(_lastSyncKey, now);
    } catch (e) {
      debugPrint('EnhancedSettingsService: Sync error: $e');
    }
  }

  /// Force sync with cloud
  Future<bool> forceSyncWithCloud() async {
    if (!_authService.isUserSignedIn()) {
      debugPrint('EnhancedSettingsService: Cannot sync - user not authenticated');
      return false;
    }
    
    if (!_connectivityService.isOnline) {
      debugPrint('EnhancedSettingsService: Cannot sync - offline');
      return false;
    }
    
    try {
      if (_cachedSettings != null) {
        await _firestoreService.saveUserSettings(_cachedSettings!);
        await _prefs!.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
        debugPrint('EnhancedSettingsService: Force sync completed');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('EnhancedSettingsService: Force sync failed: $e');
      return false;
    }
  }

  /// Load settings from cloud (overwrites local)
  Future<bool> loadFromCloud() async {
    if (!_authService.isUserSignedIn()) {
      debugPrint('EnhancedSettingsService: Cannot load from cloud - user not authenticated');
      return false;
    }
    
    if (!_connectivityService.isOnline) {
      debugPrint('EnhancedSettingsService: Cannot load from cloud - offline');
      return false;
    }
    
    try {
      final cloudSettings = await _firestoreService.loadUserSettings();
      if (cloudSettings != null) {
        _cachedSettings = cloudSettings;
        await saveSettings(_cachedSettings!); // This will save locally
        debugPrint('EnhancedSettingsService: Settings loaded from cloud');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('EnhancedSettingsService: Load from cloud failed: $e');
      return false;
    }
  }

  /// Update a specific setting with cloud sync
  /// Returns true if successful, false otherwise
  Future<bool> updateSetting<T>(String key, T value) async {
    if (!_isInitialized) await initialize();
    
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
          debugPrint('EnhancedSettingsService: Unknown setting key: $key');
          return false;
      }

      return await saveSettings(updatedSettings);
    } catch (e) {
      debugPrint('EnhancedSettingsService: Error updating setting $key: $e');
      return false;
    }
  }

  /// Reset all settings to default values
  /// Returns true if successful, false otherwise
  Future<bool> resetToDefault() async {
    if (!_isInitialized) await initialize();
    
    await _initPrefs();
    
    try {
      await _prefs!.remove(_settingsKey);
      _cachedSettings = null;
      
      // Also clear from cloud if user is authenticated
      if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
        try {
          await _firestoreService.clearAllUserData();
        } catch (e) {
          debugPrint('EnhancedSettingsService: Error clearing cloud data: $e');
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('EnhancedSettingsService: Error resetting settings: $e');
      return false;
    }
  }

  /// Get a specific setting value
  /// Returns the setting value or default if not found
  Future<T> getSetting<T>(String key, T defaultValue) async {
    if (!_isInitialized) await initialize();
    
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
      debugPrint('EnhancedSettingsService: Error getting setting $key: $e');
      return defaultValue;
    }
  }

  /// Clear cached settings (force reload from storage)
  void clearCache() {
    _cachedSettings = null;
  }

  /// Get offline status indicator
  bool get isOffline => !_connectivityService.isOnline;

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isUserSignedIn();

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    if (!_isInitialized) await initialize();
    
    await _initPrefs();
    
    final lastSync = _prefs!.getInt(_lastSyncKey);
    final hasLocalSettings = _prefs!.containsKey(_settingsKey);
    final hasBackupSettings = _prefs!.containsKey(_backupSettingsKey);
    
    bool hasCloudSettings = false;
    if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
      try {
        hasCloudSettings = await _firestoreService.hasUserData();
      } catch (e) {
        debugPrint('EnhancedSettingsService: Error checking cloud data: $e');
      }
    }
    
    return {
      'isOnline': _connectivityService.isOnline,
      'isAuthenticated': _authService.isUserSignedIn(),
      'hasLocalSettings': hasLocalSettings,
      'hasBackupSettings': hasBackupSettings,
      'hasCloudSettings': hasCloudSettings,
      'lastSync': lastSync != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastSync).toIso8601String()
          : null,
      'canSync': _authService.isUserSignedIn() && _connectivityService.isOnline,
    };
  }

  /// Verify settings integrity
  Future<bool> verifySettingsIntegrity() async {
    if (!_isInitialized) await initialize();
    
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
      
      debugPrint('EnhancedSettingsService: Settings integrity verified');
      return true;
    } catch (e) {
      debugPrint('EnhancedSettingsService: Settings integrity check failed: $e');
      return false;
    }
  }

  /// Repair corrupted settings
  Future<bool> repairSettings() async {
    if (!_isInitialized) await initialize();
    
    await _initPrefs();
    
    try {
      debugPrint('EnhancedSettingsService: Attempting to repair settings...');
      
      // Try to use backup settings
      final String? backupSettingsJson = _prefs!.getString(_backupSettingsKey);
      if (backupSettingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(backupSettingsJson);
        final settings = AppSettings.fromJson(settingsMap);
        
        // Restore primary settings from backup
        await saveSettings(settings);
        _cachedSettings = settings;
        
        debugPrint('EnhancedSettingsService: Settings repaired from backup');
        return true;
      }
      
      // Try to load from cloud
      if (_authService.isUserSignedIn() && _connectivityService.isOnline) {
        try {
          final cloudSettings = await _firestoreService.loadUserSettings();
          if (cloudSettings != null) {
            await saveSettings(cloudSettings);
            _cachedSettings = cloudSettings;
            
            debugPrint('EnhancedSettingsService: Settings repaired from cloud');
            return true;
          }
        } catch (e) {
          debugPrint('EnhancedSettingsService: Cloud repair failed: $e');
        }
      }
      
      // Use default settings if all else fails
      final defaultSettings = AppSettings.defaultSettings();
      await saveSettings(defaultSettings);
      _cachedSettings = defaultSettings;
      
      debugPrint('EnhancedSettingsService: Settings repaired with defaults');
      return true;
    } catch (e) {
      debugPrint('EnhancedSettingsService: Settings repair failed: $e');
      return false;
    }
  }
}
