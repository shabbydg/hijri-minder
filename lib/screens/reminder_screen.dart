import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/hijri_date.dart';
import '../services/service_locator.dart';
import '../widgets/calendar_type_selector.dart';
import '../widgets/advance_notification_selector.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_patterns.dart';
import '../services/reminder_service.dart';

/// Screen for managing Hijri-based reminders
class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late final ReminderService _reminderService;
  
  List<Reminder> _reminders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _reminderService = ServiceLocator.reminderService;
    _loadReminders();
  }

  /// Load all reminders
  Future<void> _loadReminders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final reminders = await _reminderService.getAllReminders();
      
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reminders: $e';
        _isLoading = false;
      });
    }
  }

  /// Show create/edit reminder dialog
  Future<void> _showReminderDialog([Reminder? reminder]) async {
    final result = await showDialog<Reminder>(
      context: context,
      builder: (context) => ReminderDialog(
        reminder: reminder,
        reminderService: _reminderService,
      ),
    );

    if (result != null) {
      await _loadReminders();
    }
  }

  /// Delete reminder with confirmation
  Future<void> _deleteReminder(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.creamSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: AppTheme.createIslamicDecoration(
            backgroundColor: AppTheme.creamSurface,
            borderColor: AppTheme.errorRed.withOpacity(0.3),
            borderRadius: 20,
            boxShadow: AppTheme.createIslamicShadows(
              color: AppTheme.errorRed,
              blurRadius: 12,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
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
                        color: AppTheme.errorRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorRed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.deleteReminderTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  AppLocalizations.of(context)!.deleteReminderConfirmation(reminder.title),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.islamicText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
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
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: AppTheme.createIslamicButtonStyle(
                          backgroundColor: AppTheme.warmBeige,
                          foregroundColor: AppTheme.islamicTextLight,
                        ),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: AppTheme.createIslamicButtonStyle(
                          backgroundColor: AppTheme.errorRed,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final success = await _reminderService.deleteReminder(reminder.id);
      if (success) {
        await _loadReminders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.reminderDeletedSuccessfully)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.failedToDeleteReminder)),
          );
        }
      }
    }
  }

  /// Toggle reminder enabled/disabled
  Future<void> _toggleReminder(Reminder reminder) async {
    final updatedReminder = reminder.copyWith(isEnabled: !reminder.isEnabled);
    final success = await _reminderService.saveReminder(updatedReminder);
    
    if (success) {
      await _loadReminders();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToUpdateReminder)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event_note,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.reminders),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadReminders,
              tooltip: AppLocalizations.of(context)!.refresh,
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryPurple, AppTheme.secondaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.createIslamicShadows(
            color: AppTheme.primaryPurple,
            blurRadius: 8,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () => _showReminderDialog(),
          tooltip: AppLocalizations.of(context)!.addReminder,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.loadingReminders,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.islamicTextLight,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReminders,
              style: AppTheme.createIslamicButtonStyle(),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.event_note,
                size: 64,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noRemindersYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.islamicText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tapToCreateFirstReminder,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.islamicTextLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.secondaryPurple],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showReminderDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(AppLocalizations.of(context)!.createReminder, style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReminders,
      color: AppTheme.primaryPurple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return _buildReminderCard(reminder);
        },
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final nextOccurrence = reminder.getNextOccurrence();
    final yearsSince = reminder.calculateYearsSince();
    
    return IslamicBorder(
      color: reminder.isEnabled ? AppTheme.primaryPurple : AppTheme.islamicTextLight,
      opacity: reminder.isEnabled ? 0.3 : 0.1,
      padding: const EdgeInsets.all(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.createIslamicDecoration(
          backgroundColor: AppTheme.creamSurface,
          borderColor: reminder.isEnabled 
              ? AppTheme.primaryPurple.withOpacity(0.2)
              : AppTheme.islamicTextLight.withOpacity(0.1),
          borderRadius: 16,
          boxShadow: AppTheme.createIslamicShadows(
            color: reminder.isEnabled ? AppTheme.primaryPurple : AppTheme.islamicTextLight,
            blurRadius: 6,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: reminder.isEnabled 
                      ? AppTheme.primaryPurple
                      : AppTheme.islamicTextLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getReminderTypeIcon(reminder.type),
                  color: reminder.isEnabled 
                      ? Colors.white
                      : AppTheme.islamicTextLight,
                  size: 20,
                ),
              ),
            title: Text(
              reminder.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: reminder.isEnabled 
                    ? AppTheme.islamicText
                    : AppTheme.islamicTextLight,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reminder.description.isNotEmpty)
                  Text(
                    reminder.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: reminder.isEnabled 
                          ? AppTheme.islamicTextLight
                          : AppTheme.islamicTextLight.withOpacity(0.7),
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: reminder.isEnabled 
                        ? AppTheme.primaryPurple.withOpacity(0.1)
                        : AppTheme.islamicTextLight.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${reminder.hijriDate.day} ${HijriDate.getMonthName(reminder.hijriDate.month)} ${reminder.hijriDate.year} AH',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: reminder.isEnabled 
                          ? AppTheme.primaryPurple
                          : AppTheme.islamicTextLight,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reminder.gregorianDate.day}/${reminder.gregorianDate.month}/${reminder.gregorianDate.year}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: reminder.isEnabled 
                        ? AppTheme.islamicTextLight
                        : AppTheme.islamicTextLight.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showReminderDialog(reminder);
                      break;
                    case 'toggle':
                      _toggleReminder(reminder);
                      break;
                    case 'delete':
                      _deleteReminder(reminder);
                      break;
                  }
                },
                icon: Icon(
                  Icons.more_vert,
                  color: AppTheme.primaryPurple,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppTheme.primaryPurple),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.edit, style: TextStyle(color: AppTheme.islamicText)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          reminder.isEnabled ? Icons.pause : Icons.play_arrow,
                          color: AppTheme.secondaryPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          reminder.isEnabled ? AppLocalizations.of(context)!.disable : AppLocalizations.of(context)!.enable,
                          style: TextStyle(color: AppTheme.islamicText),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppTheme.errorRed),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: AppTheme.errorRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (reminder.isEnabled) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.lightPurple.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.nextOccurrence,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.lightPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${nextOccurrence.day}/${nextOccurrence.month}/${nextOccurrence.year}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.islamicText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (reminder.isRecurring && yearsSince > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.goldAccent, AppTheme.lightGold],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.createIslamicShadows(
                          color: AppTheme.goldAccent,
                          blurRadius: 4,
                        ),
                      ),
                      child: Text(
                        '$yearsSince ${yearsSince == 1 ? AppLocalizations.of(context)!.year : AppLocalizations.of(context)!.years}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    ));
  }

  IconData _getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.birthday:
        return Icons.cake;
      case ReminderType.anniversary:
        return Icons.favorite;
      case ReminderType.religious:
        return Icons.mosque;
      case ReminderType.family:
        return Icons.family_restroom;
      case ReminderType.personal:
        return Icons.person;
      case ReminderType.other:
        return Icons.event;
    }
  }
}

/// Dialog for creating/editing reminders
class ReminderDialog extends StatefulWidget {
  final Reminder? reminder;
  final ReminderService reminderService;
  final HijriDate? initialHijriDate;
  final DateTime? initialGregorianDate;

  const ReminderDialog({
    super.key,
    this.reminder,
    required this.reminderService,
    this.initialHijriDate,
    this.initialGregorianDate,
  });

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _relationshipController = TextEditingController();
  
  ReminderType _selectedType = ReminderType.birthday;
  DateTime _selectedGregorianDate = DateTime.now();
  HijriDate _selectedHijriDate = HijriDate.fromGregorian(DateTime.now());
  bool _isRecurring = true;
  bool _isNightSensitive = false;
  Duration _notificationAdvance = const Duration(hours: 1);
  bool _isLoading = false;
  
  // Enhanced fields for calendar type selection and multiple advance notifications
  List<String> _selectedCalendarTypes = ['gregorian'];
  List<Duration> _advanceNotifications = const [Duration(hours:1)];
  String _primaryCalendar = 'gregorian';

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() async {
    if (widget.reminder != null) {
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description;
      _recipientNameController.text = reminder.recipientName ?? '';
      _relationshipController.text = reminder.relationship ?? '';
      _selectedType = reminder.type;
      _selectedGregorianDate = reminder.gregorianDate;
      _selectedHijriDate = reminder.hijriDate;
      _isRecurring = reminder.isRecurring;
      _notificationAdvance = reminder.notificationAdvance;
      _selectedCalendarTypes = List<String>.from(reminder.selectedCalendarTypes);
      _advanceNotifications = List<Duration>.from(reminder.advanceNotifications);
      _primaryCalendar = reminder.calendarPreference;
    } else {
      // Use initial dates if provided, otherwise use current date
      if (widget.initialHijriDate != null && widget.initialGregorianDate != null) {
        _selectedHijriDate = widget.initialHijriDate!;
        _selectedGregorianDate = widget.initialGregorianDate!;
      } else {
        _selectedGregorianDate = DateTime.now();
        _selectedHijriDate = HijriDate.fromGregorian(DateTime.now());
      }
      
      // Fetch defaults for new reminder
      final defaults = await widget.reminderService.getDefaultReminderSettings();
      setState(() {
        _selectedCalendarTypes = List<String>.from(defaults['selectedCalendarTypes']);
        _advanceNotifications = List<Duration>.from(defaults['advanceNotifications']);
        _primaryCalendar = defaults['calendarPreference'] as String;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recipientNameController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  /// Show Gregorian date picker
  Future<void> _selectGregorianDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedGregorianDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedGregorianDate = date;
        // Convert to Hijri and apply night sensitivity
        _selectedHijriDate = HijriDate.fromGregorian(date);
        if (_isNightSensitive) {
          _selectedHijriDate = _selectedHijriDate.addDays(1);
        }
      });
    }
  }

  /// Show Hijri date picker dialog
  Future<void> _selectHijriDate() async {
    final result = await showDialog<HijriDate>(
      context: context,
      builder: (context) => HijriDatePickerDialog(
        initialDate: _selectedHijriDate,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedHijriDate = result;
        _selectedGregorianDate = result.toGregorian();
      });
    }
  }

  /// Save reminder
  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate calendar types and advance notifications
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCalendarTypes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseSelectCalendarType)),
        );
      }
      return;
    }
    
    if (_advanceNotifications.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseSelectNotificationTime)),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reminder = Reminder(
        id: widget.reminder?.id ?? widget.reminderService.generateReminderId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        hijriDate: _selectedHijriDate,
        gregorianDate: _selectedGregorianDate,
        type: _selectedType,
        isRecurring: _isRecurring,
        notificationAdvance: _notificationAdvance,
        recipientName: _recipientNameController.text.trim().isEmpty 
            ? null 
            : _recipientNameController.text.trim(),
        relationship: _relationshipController.text.trim().isEmpty 
            ? null 
            : _relationshipController.text.trim(),
        messageTemplates: Reminder.getDefaultMessageTemplates(_selectedType, 'en'),
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
        selectedCalendarTypes: _selectedCalendarTypes,
        advanceNotifications: _advanceNotifications,
        calendarPreference: _primaryCalendar,
      );

      // Validate reminder
      final validation = widget.reminderService.validateReminder(reminder);
      if (!validation.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(validation.errorMessage ?? 'Validation failed')),
          );
        }
        return;
      }

      final success = await widget.reminderService.saveReminder(reminder);
      
      if (success) {
        if (mounted) {
          Navigator.of(context).pop(reminder);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save reminder')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(widget.reminder == null ? l10n.addReminder : l10n.edit),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: '${l10n.reminderTitle} *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.titleRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.reminderDescription,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Reminder type dropdown
                DropdownButtonFormField<ReminderType>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: l10n.reminderType,
                    border: const OutlineInputBorder(),
                  ),
                  items: ReminderType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Date selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dateSelection,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Night sensitivity checkbox
                        CheckboxListTile(
                          title: Text(l10n.nightSensitive),
                          subtitle: Text(l10n.nightSensitiveHelp),
                          value: _isNightSensitive,
                          onChanged: (value) {
                            setState(() {
                              _isNightSensitive = value ?? false;
                              // Recalculate Hijri date
                              _selectedHijriDate = HijriDate.fromGregorian(_selectedGregorianDate);
                              if (_isNightSensitive) {
                                _selectedHijriDate = _selectedHijriDate.addDays(1);
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        
                        // Gregorian date picker
                        ListTile(
                          title: Text(l10n.gregorianDate),
                          subtitle: Text(
                            '${_selectedGregorianDate.day}/${_selectedGregorianDate.month}/${_selectedGregorianDate.year}',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: _selectGregorianDate,
                          contentPadding: EdgeInsets.zero,
                        ),
                        
                        // Hijri date display/picker
                        ListTile(
                          title: Text(l10n.hijriDate),
                          subtitle: Text(
                            '${_selectedHijriDate.day} ${HijriDate.getMonthName(_selectedHijriDate.month)} ${_selectedHijriDate.year} AH',
                          ),
                          trailing: const Icon(Icons.edit_calendar),
                          onTap: _selectHijriDate,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Recipient name field
                TextFormField(
                  controller: _recipientNameController,
                  decoration: InputDecoration(
                    labelText: l10n.recipientName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Relationship field
                TextFormField(
                  controller: _relationshipController,
                  decoration: InputDecoration(
                    labelText: l10n.relationship,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Recurring checkbox
                CheckboxListTile(
                  title: Text(l10n.recurringReminder),
                  subtitle: Text(l10n.repeatEveryYear),
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value ?? true;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                
                // Calendar Type Selection
                CalendarTypeSelector(
                  selectedTypes: _selectedCalendarTypes,
                  onSelectionChanged: (types) {
                    setState(() {
                      _selectedCalendarTypes = types;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Advance Notification Selection
                AdvanceNotificationSelector(
                  selectedNotifications: _advanceNotifications,
                  onSelectionChanged: (notifications) {
                    setState(() {
                      _advanceNotifications = notifications;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveReminder,
          child: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.reminder == null ? l10n.add : l10n.save),
        ),
      ],
    );
  }
}

/// Dialog for selecting Hijri dates
class HijriDatePickerDialog extends StatefulWidget {
  final HijriDate initialDate;

  const HijriDatePickerDialog({
    super.key,
    required this.initialDate,
  });

  @override
  State<HijriDatePickerDialog> createState() => _HijriDatePickerDialogState();
}

class _HijriDatePickerDialogState extends State<HijriDatePickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final daysInMonth = HijriDate.daysInMonth(_selectedYear, _selectedMonth);
    
    // Adjust day if it's invalid for the selected month
    if (_selectedDay > daysInMonth) {
      _selectedDay = daysInMonth;
    }

    return AlertDialog(
      title: Text(l10n.selectHijriDate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Year picker
          DropdownButtonFormField<int>(
            initialValue: _selectedYear,
            decoration: InputDecoration(
              labelText: l10n.yearAH,
              border: const OutlineInputBorder(),
            ),
            items: List.generate(101, (index) => 1400 + index).map((year) {
              return DropdownMenuItem(
                value: year,
                child: Text('$year AH'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedYear = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Month picker
          DropdownButtonFormField<int>(
            initialValue: _selectedMonth,
            decoration: InputDecoration(
              labelText: l10n.month,
              border: const OutlineInputBorder(),
            ),
            items: List.generate(12, (i) => i + 1).map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(HijriDate.getMonthName(month)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMonth = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Day picker
          DropdownButtonFormField<int>(
            initialValue: _selectedDay,
            decoration: InputDecoration(
              labelText: l10n.day,
              border: const OutlineInputBorder(),
            ),
            items: List.generate(daysInMonth, (index) => index + 1).map((day) {
              return DropdownMenuItem(
                value: day,
                child: Text('$day'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedDay = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final selectedDate = HijriDate(_selectedYear, _selectedMonth, _selectedDay);
            Navigator.of(context).pop(selectedDate);
          },
          child: Text(l10n.select),
        ),
      ],
    );
  }
}