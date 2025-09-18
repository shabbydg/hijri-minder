import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/subscription_service.dart';
import '../models/reminder_preferences.dart';
import '../models/subscription_types.dart';
import '../widgets/calendar_type_selector.dart';
import '../widgets/advance_notification_selector.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_patterns.dart';

/// Dialog for managing default reminder preferences
class ReminderPreferencesDialog extends StatefulWidget {
  final ReminderPreferences? initialPreferences;
  final Function(ReminderPreferences) onPreferencesSaved;

  const ReminderPreferencesDialog({
    Key? key,
    this.initialPreferences,
    required this.onPreferencesSaved,
  }) : super(key: key);

  @override
  State<ReminderPreferencesDialog> createState() => _ReminderPreferencesDialogState();
}

class _ReminderPreferencesDialogState extends State<ReminderPreferencesDialog> {
  final SettingsService _settingsService = SettingsService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  late ReminderPreferences _preferences;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasPremiumAccess = false;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    try {
      // Check premium access
      final hasPremium = await _subscriptionService.hasActiveSubscription();
      
      // Load initial preferences or create defaults
      ReminderPreferences preferences;
      if (widget.initialPreferences != null) {
        preferences = widget.initialPreferences!;
      } else {
        final settings = await _settingsService.getSettings();
        preferences = ReminderPreferences.defaultSettings(); // Use default since settings doesn't have reminderPreferences
      }
      
      setState(() {
        _preferences = preferences;
        _hasPremiumAccess = hasPremium;
        _isLoading = false;
      });
    } catch (e) {
      // Use default preferences if loading fails
      setState(() {
        _preferences = ReminderPreferences.defaultPreferences();
        _hasPremiumAccess = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Save preferences through settings service
      final settings = await _settingsService.getSettings();
      final updatedSettings = settings.copyWith(reminderPreferences: _preferences);
      await _settingsService.saveSettings(updatedSettings);
      
      // Notify parent widget
      widget.onPreferencesSaved(_preferences);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.preferencesSaved),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preferences: $e'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetToDefaults() {
    setState(() {
      _preferences = ReminderPreferences.defaultPreferences();
    });
  }

  void _updateCalendarTypes(List<String> calendarTypes) {
    setState(() {
      _preferences = _preferences.copyWith(
        defaultCalendarTypes: calendarTypes,
      );
    });
  }

  void _updateAdvanceNotifications(List<Duration> notifications) {
    setState(() {
      _preferences = _preferences.copyWith(
        defaultAdvanceNotifications: notifications,
      );
    });
  }

  void _updatePrimaryCalendar(String calendar) {
    setState(() {
      _preferences = _preferences.copyWith(
        primaryCalendar: calendar,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryPurple,
        ),
      );
    }

    return Dialog(
      backgroundColor: AppTheme.creamSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: AppTheme.createIslamicDecoration(
          backgroundColor: AppTheme.creamSurface,
          borderColor: AppTheme.lightPurple.withOpacity(0.3),
          borderRadius: 20,
          boxShadow: AppTheme.createIslamicShadows(
            color: AppTheme.primaryPurple,
            blurRadius: 12,
          ),
        ),
        child: Column(
          children: [
            // Header with Islamic decoration
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.createIslamicGradient(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.reminderPreferences,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: AppTheme.primaryPurple),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Default Calendar Types Section
                    _buildSection(
                      title: l10n.defaultCalendarTypes,
                      child: CalendarTypeSelector(
                        selectedTypes: _preferences.defaultCalendarTypes,
                        onSelectionChanged: _updateCalendarTypes,
                        allowMultipleSelection: true,
                        showPremiumBadges: true,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Default Advance Notifications Section
                    _buildSection(
                      title: l10n.defaultAdvanceNotifications,
                      child: AdvanceNotificationSelector(
                        selectedNotifications: _preferences.defaultAdvanceNotifications,
                        onSelectionChanged: _updateAdvanceNotifications,
                        allowCustomTimes: true,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Primary Calendar Section
                    _buildSection(
                      title: l10n.primaryCalendar,
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Text(l10n.gregorianCalendar),
                            value: 'gregorian',
                            groupValue: _preferences.primaryCalendar,
                            onChanged: (value) => _updatePrimaryCalendar(value!),
                          ),
                          RadioListTile<String>(
                            title: Row(
                              children: [
                                Text(l10n.hijriCalendar),
                                if (!_hasPremiumAccess) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.premium,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            value: 'hijri',
                            groupValue: _preferences.primaryCalendar,
                            onChanged: _hasPremiumAccess 
                                ? (value) => _updatePrimaryCalendar(value!)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Notification Settings Section
                    _buildSection(
                      title: l10n.notificationSettings,
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Enable push notifications'),
                            subtitle: const Text('Receive notifications for reminders'),
                            value: _preferences.notificationSettings['enablePushNotifications'] ?? true,
                            onChanged: (value) {
                              setState(() {
                                _preferences = _preferences.copyWith(
                                  notificationSettings: {
                                    ..._preferences.notificationSettings,
                                    'enablePushNotifications': value,
                                  },
                                );
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Enable email notifications'),
                            subtitle: const Text('Receive email reminders'),
                            value: _preferences.notificationSettings['enableEmailNotifications'] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _preferences = _preferences.copyWith(
                                  notificationSettings: {
                                    ..._preferences.notificationSettings,
                                    'enableEmailNotifications': value,
                                  },
                                );
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Enable SMS notifications'),
                            subtitle: const Text('Receive SMS reminders (Premium)'),
                            value: _preferences.notificationSettings['enableSmsNotifications'] ?? false,
                            onChanged: _hasPremiumAccess 
                                ? (value) {
                                    setState(() {
                                      _preferences = _preferences.copyWith(
                                        notificationSettings: {
                                          ..._preferences.notificationSettings,
                                          'enableSmsNotifications': value,
                                        },
                                      );
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recurring Reminder Preferences Section
                    _buildSection(
                      title: l10n.recurringReminderPreferences,
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Default to recurring reminders'),
                            subtitle: const Text('New reminders will be recurring by default'),
                            value: _preferences.notificationSettings['defaultRecurring'] ?? true,
                            onChanged: (value) {
                              setState(() {
                                _preferences = _preferences.copyWith(
                                  notificationSettings: {
                                    ..._preferences.notificationSettings,
                                    'defaultRecurring': value,
                                  },
                                );
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Auto-generate message templates'),
                            subtitle: const Text('Generate templates based on reminder type'),
                            value: _preferences.notificationSettings['autoGenerateTemplates'] ?? true,
                            onChanged: (value) {
                              setState(() {
                                _preferences = _preferences.copyWith(
                                  notificationSettings: {
                                    ..._preferences.notificationSettings,
                                    'autoGenerateTemplates': value,
                                  },
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.warmBeige.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetToDefaults,
                      style: AppTheme.createIslamicButtonStyle(
                        backgroundColor: AppTheme.warmBeige,
                        foregroundColor: AppTheme.islamicTextLight,
                      ),
                      child: Text(l10n.resetToDefaults),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePreferences,
                      style: AppTheme.createIslamicButtonStyle(),
                      child: _isSaving 
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(l10n.savePreferences),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Compact version for quick access
class CompactReminderPreferencesDialog extends StatefulWidget {
  final ReminderPreferences? initialPreferences;
  final Function(ReminderPreferences) onPreferencesSaved;

  const CompactReminderPreferencesDialog({
    Key? key,
    this.initialPreferences,
    required this.onPreferencesSaved,
  }) : super(key: key);

  @override
  State<CompactReminderPreferencesDialog> createState() => _CompactReminderPreferencesDialogState();
}

class _CompactReminderPreferencesDialogState extends State<CompactReminderPreferencesDialog> {
  final SettingsService _settingsService = SettingsService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  late ReminderPreferences _preferences;
  bool _isLoading = true;
  bool _hasPremiumAccess = false;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    try {
      final hasPremium = await _subscriptionService.hasActiveSubscription();
      
      ReminderPreferences preferences;
      if (widget.initialPreferences != null) {
        preferences = widget.initialPreferences!;
      } else {
        final settings = await _settingsService.getSettings();
        preferences = ReminderPreferences.defaultSettings(); // Use default since settings doesn't have reminderPreferences
      }
      
      setState(() {
        _preferences = preferences;
        _hasPremiumAccess = hasPremium;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _preferences = ReminderPreferences.defaultPreferences();
        _hasPremiumAccess = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    try {
      final settings = await _settingsService.getSettings();
      final updatedSettings = settings.copyWith(reminderPreferences: _preferences);
      await _settingsService.saveSettings(updatedSettings);
      
      widget.onPreferencesSaved(_preferences);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.preferencesSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      title: Text(l10n.reminderPreferences),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact Calendar Type Selector
            CompactCalendarTypeSelector(
              selectedTypes: _preferences.defaultCalendarTypes,
              onSelectionChanged: (types) {
                setState(() {
                  _preferences = _preferences.copyWith(defaultCalendarTypes: types);
                });
              },
              showPremiumBadges: true,
            ),
            
            const SizedBox(height: 16),
            
            // Compact Advance Notification Selector
            CompactAdvanceNotificationSelector(
              selectedNotifications: _preferences.defaultAdvanceNotifications,
              onSelectionChanged: (notifications) {
                setState(() {
                  _preferences = _preferences.copyWith(defaultAdvanceNotifications: notifications);
                });
              },
              allowCustomTimes: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _savePreferences,
          child: Text(l10n.savePreferences),
        ),
      ],
    );
  }
}
