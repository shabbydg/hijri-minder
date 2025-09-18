import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/service_locator.dart';
import '../services/localization_service.dart';
import '../l10n/app_localizations.dart';

/// Settings and preferences screen for the HijriMinder app
/// Provides comprehensive configuration options for all app features
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load current settings from SettingsService
  Future<void> _loadSettings() async {
    try {
      final settings = await ServiceLocator.settingsService.getSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _settings = AppSettings.defaultSettings();
        _isLoading = false;
      });
      if (mounted) {
        _showErrorSnackBar('Failed to load settings');
      }
    }
  }

  /// Save settings to SettingsService
  Future<void> _saveSettings(AppSettings newSettings) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await ServiceLocator.settingsService.saveSettings(newSettings);
      if (success) {
        setState(() {
          _settings = newSettings;
        });
        if (mounted) {
          _showSuccessSnackBar('Settings saved successfully');
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('Failed to save settings');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error saving settings: $e');
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Update a specific setting
  Future<void> _updateSetting<T>(String key, T value) async {
    if (_settings == null) return;

    AppSettings updatedSettings;
    switch (key) {
      case 'enablePrayerNotifications':
        updatedSettings = _settings!.copyWith(enablePrayerNotifications: value as bool);
        // Request notification permissions if enabling
        if (value as bool) {
          await ServiceLocator.notificationService.requestPermissions();
        }
        break;
      case 'enableAdhanSounds':
        updatedSettings = _settings!.copyWith(enableAdhanSounds: value as bool);
        break;
      case 'enableLocationServices':
        updatedSettings = _settings!.copyWith(enableLocationServices: value as bool);
        // Request location permissions if enabling
        if (value as bool) {
          await ServiceLocator.locationService.requestLocationPermissionWithDialog();
        }
        break;
      case 'language':
        updatedSettings = _settings!.copyWith(language: value as String);
        // Update localization service
        await ServiceLocator.localizationService.changeLanguage(value as String);
        break;
      case 'theme':
        updatedSettings = _settings!.copyWith(theme: value as String);
        break;
      case 'showGregorianDates':
        updatedSettings = _settings!.copyWith(showGregorianDates: value as bool);
        break;
      case 'showEventDots':
        updatedSettings = _settings!.copyWith(showEventDots: value as bool);
        break;
      case 'prayerTimeFormat':
        updatedSettings = _settings!.copyWith(prayerTimeFormat: value as String);
        break;
      case 'prayerNotificationAdvance':
        updatedSettings = _settings!.copyWith(prayerNotificationAdvance: value as Duration);
        break;
      case 'enableReminderNotifications':
        updatedSettings = _settings!.copyWith(enableReminderNotifications: value as bool);
        break;
      case 'enableVibration':
        updatedSettings = _settings!.copyWith(enableVibration: value as bool);
        break;
      case 'fontSize':
        updatedSettings = _settings!.copyWith(fontSize: value as double);
        break;
      case 'useArabicNumerals':
        updatedSettings = _settings!.copyWith(useArabicNumerals: value as bool);
        break;
      case 'autoLocationUpdate':
        updatedSettings = _settings!.copyWith(autoLocationUpdate: value as bool);
        break;
      default:
        return;
    }

    await _saveSettings(updatedSettings);
  }

  /// Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Reset settings to default
  Future<void> _resetToDefault() async {
    final confirmed = await _showResetConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await ServiceLocator.settingsService.resetToDefault();
      if (success) {
        await _loadSettings();
        if (mounted) {
          _showSuccessSnackBar('Settings reset to default');
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('Failed to reset settings');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error resetting settings: $e');
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Show confirmation dialog for reset
  Future<bool> _showResetConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_settings == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: Text('Failed to load settings'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _resetToDefault();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Reset to Default'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildPrayerNotificationSection(),
          const SizedBox(height: 24),
          _buildDisplaySection(),
          const SizedBox(height: 24),
          _buildLanguageAndThemeSection(),
          const SizedBox(height: 24),
          _buildLocationSection(),
          const SizedBox(height: 24),
          _buildReminderSection(),
          const SizedBox(height: 24),
          _buildAccessibilitySection(),
        ],
      ),
    );
  }

  /// Build prayer notification settings section
  Widget _buildPrayerNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Prayer Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Prayer Notifications'),
              subtitle: const Text('Receive notifications for prayer times'),
              value: _settings!.enablePrayerNotifications,
              onChanged: (value) => _updateSetting('enablePrayerNotifications', value),
            ),
            SwitchListTile(
              title: const Text('Enable Adhan Sounds'),
              subtitle: const Text('Play Adhan sound with notifications'),
              value: _settings!.enableAdhanSounds,
              onChanged: _settings!.enablePrayerNotifications 
                ? (value) => _updateSetting('enableAdhanSounds', value)
                : null,
            ),
            SwitchListTile(
              title: const Text('Enable Vibration'),
              subtitle: const Text('Vibrate device for notifications'),
              value: _settings!.enableVibration,
              onChanged: _settings!.enablePrayerNotifications 
                ? (value) => _updateSetting('enableVibration', value)
                : null,
            ),
            ListTile(
              title: const Text('Prayer Time Format'),
              subtitle: Text(_settings!.prayerTimeFormat == '12h' ? '12-hour format' : '24-hour format'),
              trailing: DropdownButton<String>(
                value: _settings!.prayerTimeFormat,
                items: AppSettings.getSupportedTimeFormats().map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Text(format == '12h' ? '12-hour' : '24-hour'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateSetting('prayerTimeFormat', value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Notification Advance Time'),
              subtitle: Text('${_settings!.prayerNotificationAdvance.inMinutes} minutes before'),
              trailing: DropdownButton<int>(
                value: _settings!.prayerNotificationAdvance.inMinutes,
                items: [0, 5, 10, 15, 30, 60].map((minutes) {
                  return DropdownMenuItem(
                    value: minutes,
                    child: Text(minutes == 0 ? 'At prayer time' : '$minutes minutes before'),
                  );
                }).toList(),
                onChanged: _settings!.enablePrayerNotifications 
                  ? (value) {
                      if (value != null) {
                        _updateSetting('prayerNotificationAdvance', Duration(minutes: value));
                      }
                    }
                  : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build display customization section
  Widget _buildDisplaySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.display_settings, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Display Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Gregorian Dates'),
              subtitle: const Text('Display Gregorian dates alongside Hijri dates'),
              value: _settings!.showGregorianDates,
              onChanged: (value) => _updateSetting('showGregorianDates', value),
            ),
            SwitchListTile(
              title: const Text('Show Event Dots'),
              subtitle: const Text('Display dots on calendar dates with Islamic events'),
              value: _settings!.showEventDots,
              onChanged: (value) => _updateSetting('showEventDots', value),
            ),
            SwitchListTile(
              title: const Text('Use Arabic Numerals'),
              subtitle: const Text('Display numbers in Arabic-Indic format'),
              value: _settings!.useArabicNumerals,
              onChanged: (value) => _updateSetting('useArabicNumerals', value),
            ),
            ListTile(
              title: const Text('Font Size'),
              subtitle: Text('${_settings!.fontSize.toInt()}pt'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: _settings!.fontSize,
                  min: 10.0,
                  max: 24.0,
                  divisions: 14,
                  label: '${_settings!.fontSize.toInt()}pt',
                  onChanged: (value) => _updateSetting('fontSize', value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build language and theme section
  Widget _buildLanguageAndThemeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${AppLocalizations.of(context)!.language} & ${AppLocalizations.of(context)!.theme}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(AppLocalizations.of(context)!.language),
              subtitle: Text(LocalizationService.supportedLanguages[ServiceLocator.localizationService.currentLocale.languageCode] ?? 'English'),
              trailing: DropdownButton<String>(
                value: ServiceLocator.localizationService.currentLocale.languageCode,
                items: LocalizationService.supportedLanguages.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateSetting('language', value);
                  }
                },
              ),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.format12Hour.contains('Arabic') ? 'استخدام الأرقام العربية' : 'Use Arabic Numerals'),
              subtitle: Text(AppLocalizations.of(context)!.format12Hour.contains('Arabic') ? 'عرض الأرقام بالأرقام العربية' : 'Display numbers in Arabic-Indic numerals'),
              value: ServiceLocator.localizationService.useArabicNumerals,
              onChanged: (value) async {
                await ServiceLocator.localizationService.toggleArabicNumerals();
                setState(() {}); // Refresh UI
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.theme),
              subtitle: Text(_settings!.getThemeDisplayName()),
              trailing: DropdownButton<String>(
                value: _settings!.theme,
                items: AppSettings.getSupportedThemes().map((theme) {
                  String displayName;
                  switch (theme) {
                    case 'light':
                      displayName = 'Light';
                      break;
                    case 'dark':
                      displayName = 'Dark';
                      break;
                    case 'system':
                      displayName = 'System';
                      break;
                    default:
                      displayName = 'Light';
                  }
                  return DropdownMenuItem(
                    value: theme,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updateSetting('theme', value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build location services section
  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Location Services',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Location Services'),
              subtitle: const Text('Use GPS for accurate prayer times'),
              value: _settings!.enableLocationServices,
              onChanged: (value) => _updateSetting('enableLocationServices', value),
            ),
            SwitchListTile(
              title: const Text('Auto Location Update'),
              subtitle: const Text('Automatically update location when changed'),
              value: _settings!.autoLocationUpdate,
              onChanged: _settings!.enableLocationServices 
                ? (value) => _updateSetting('autoLocationUpdate', value)
                : null,
            ),
            ListTile(
              title: const Text('Default Location'),
              subtitle: Text(_settings!.defaultLocation),
              trailing: const Icon(Icons.edit),
              onTap: () => _showLocationEditDialog(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build reminder settings section
  Widget _buildReminderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Reminder Notifications'),
              subtitle: const Text('Receive notifications for birthdays and anniversaries'),
              value: _settings!.enableReminderNotifications,
              onChanged: (value) => _updateSetting('enableReminderNotifications', value),
            ),
          ],
        ),
      ),
    );
  }

  /// Build accessibility section
  Widget _buildAccessibilitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.accessibility, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Accessibility',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('About HijriMinder'),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.info_outline),
              onTap: () => _showAboutDialog(),
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.privacy_tip_outlined),
              onTap: () => _showPrivacyPolicy(),
            ),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.description_outlined),
              onTap: () => _showTermsOfService(),
            ),
          ],
        ),
      ),
    );
  }

  /// Show location edit dialog
  Future<void> _showLocationEditDialog() async {
    final controller = TextEditingController(text: _settings!.defaultLocation);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'Enter city, country',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != _settings!.defaultLocation) {
      final updatedSettings = _settings!.copyWith(defaultLocation: result);
      await _saveSettings(updatedSettings);
    }
  }

  /// Show about dialog
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'HijriMinder',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.calendar_month, size: 48),
      children: [
        const Text('A comprehensive Hijri calendar application for the global Muslim community.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Accurate Hijri date conversion'),
        const Text('• Prayer times with notifications'),
        const Text('• Islamic events and holidays'),
        const Text('• Birthday and anniversary reminders'),
        const Text('• Multi-language support'),
      ],
    );
  }

  /// Show privacy policy
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'HijriMinder respects your privacy and is committed to protecting your personal information.\n\n'
            'Data Collection:\n'
            '• Location data is used only for prayer time calculations\n'
            '• Reminder data is stored locally on your device\n'
            '• No personal data is shared with third parties\n\n'
            'Data Storage:\n'
            '• All data is stored locally on your device\n'
            '• Settings and preferences are saved in device storage\n'
            '• No data is transmitted to external servers\n\n'
            'Permissions:\n'
            '• Location: For accurate prayer times\n'
            '• Notifications: For prayer and reminder alerts\n'
            '• Storage: For saving app settings and data',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show terms of service
  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service for HijriMinder\n\n'
            'By using this application, you agree to the following terms:\n\n'
            '1. The app is provided "as is" without warranties\n'
            '2. Prayer times are calculated using astronomical algorithms\n'
            '3. Users should verify prayer times with local Islamic authorities\n'
            '4. The app is for personal use only\n'
            '5. Islamic dates are calculated based on astronomical calculations\n'
            '6. Users are responsible for their own data backup\n\n'
            'Disclaimer:\n'
            'While we strive for accuracy, please consult local Islamic authorities for official prayer times and Islamic dates.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}