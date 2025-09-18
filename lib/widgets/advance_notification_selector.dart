import 'package:flutter/material.dart';
import '../models/reminder_preferences.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_patterns.dart';

/// Widget for selecting multiple advance notification times
class AdvanceNotificationSelector extends StatefulWidget {
  final List<Duration> selectedNotifications;
  final Function(List<Duration>) onSelectionChanged;
  final bool allowCustomTimes;
  final EdgeInsets? padding;

  const AdvanceNotificationSelector({
    Key? key,
    required this.selectedNotifications,
    required this.onSelectionChanged,
    this.allowCustomTimes = true,
    this.padding,
  }) : super(key: key);

  @override
  State<AdvanceNotificationSelector> createState() => _AdvanceNotificationSelectorState();
}

class _AdvanceNotificationSelectorState extends State<AdvanceNotificationSelector> {
  final List<Duration> _predefinedTimes = [
    const Duration(minutes: 15),
    const Duration(hours: 1),
    const Duration(hours: 24),
    const Duration(days: 3),
    const Duration(days: 7),
  ];

  void _toggleNotificationTime(Duration duration) {
    List<Duration> newSelection = List.from(widget.selectedNotifications);
    
    if (newSelection.contains(duration)) {
      newSelection.remove(duration);
    } else {
      newSelection.add(duration);
    }
    
    widget.onSelectionChanged(newSelection);
  }

  void _removeNotificationTime(Duration duration) {
    List<Duration> newSelection = List.from(widget.selectedNotifications);
    newSelection.remove(duration);
    widget.onSelectionChanged(newSelection);
  }

  void _addCustomTime() {
    showDialog(
      context: context,
      builder: (context) => _CustomTimeDialog(
        onTimeAdded: (duration) {
          List<Duration> newSelection = List.from(widget.selectedNotifications);
          if (!newSelection.contains(duration)) {
            newSelection.add(duration);
            widget.onSelectionChanged(newSelection);
          }
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.advanceNotifications,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.islamicText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.chooseWhenToBeNotified,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.islamicTextLight,
            ),
          ),
          const SizedBox(height: 20),
          
          // Predefined time options
          Text(
            l10n.quickOptions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.islamicText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _predefinedTimes.map((duration) {
              final isSelected = widget.selectedNotifications.contains(duration);
              return GestureDetector(
                onTap: () => _toggleNotificationTime(duration),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: AppTheme.createIslamicDecoration(
                    backgroundColor: isSelected 
                        ? AppTheme.primaryPurple.withOpacity(0.1) 
                        : AppTheme.creamBackground,
                    borderColor: isSelected 
                        ? AppTheme.primaryPurple.withOpacity(0.4) 
                        : AppTheme.lightPurple.withOpacity(0.2),
                    borderRadius: 20,
                    boxShadow: isSelected 
                        ? AppTheme.createIslamicShadows(color: AppTheme.primaryPurple, blurRadius: 4)
                        : null,
                  ),
                  child: Text(
                    _formatDuration(duration),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryPurple : AppTheme.islamicTextLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Custom time button
          if (widget.allowCustomTimes) ...[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.secondaryPurple.withOpacity(0.1), AppTheme.lightPurple.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.secondaryPurple.withOpacity(0.3),
                ),
              ),
              child: OutlinedButton.icon(
                onPressed: _addCustomTime,
                icon: Icon(Icons.add, color: AppTheme.secondaryPurple),
                label: Text(
                  l10n.addCustomTime,
                  style: TextStyle(color: AppTheme.secondaryPurple),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
          
          // Selected notifications
          if (widget.selectedNotifications.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.selectedNotifications,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.islamicText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedNotifications.map((duration) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: AppTheme.createIslamicDecoration(
                    backgroundColor: AppTheme.successGreen.withOpacity(0.1),
                    borderColor: AppTheme.successGreen.withOpacity(0.3),
                    borderRadius: 20,
                    boxShadow: AppTheme.createIslamicShadows(
                      color: AppTheme.successGreen,
                      blurRadius: 4,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDuration(duration),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeNotificationTime(duration),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          
          // Validation message
          if (widget.selectedNotifications.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.pleaseSelectNotificationTime,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialog for adding custom notification times
class _CustomTimeDialog extends StatefulWidget {
  final Function(Duration) onTimeAdded;

  const _CustomTimeDialog({required this.onTimeAdded});

  @override
  State<_CustomTimeDialog> createState() => _CustomTimeDialogState();
}

class _CustomTimeDialogState extends State<_CustomTimeDialog> {
  int _days = 0;
  int _hours = 0;
  int _minutes = 15;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.addCustomTime),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(l10n.days),
                    DropdownButton<int>(
                      value: _days,
                      items: List.generate(31, (index) => DropdownMenuItem(
                        value: index,
                        child: Text('$index'),
                      )),
                      onChanged: (value) => setState(() => _days = value ?? 0),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(l10n.hours),
                    DropdownButton<int>(
                      value: _hours,
                      items: List.generate(24, (index) => DropdownMenuItem(
                        value: index,
                        child: Text('$index'),
                      )),
                      onChanged: (value) => setState(() => _hours = value ?? 0),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(l10n.minutes),
                    DropdownButton<int>(
                      value: _minutes,
                      items: [15, 30, 45].map((value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value'),
                      )).toList(),
                      onChanged: (value) => setState(() => _minutes = value ?? 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n.total}: ${_formatTotalDuration()}',
            style: const TextStyle(fontWeight: FontWeight.bold),
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
            final duration = Duration(days: _days, hours: _hours, minutes: _minutes);
            widget.onTimeAdded(duration);
            Navigator.of(context).pop();
          },
          child: Text(l10n.add),
        ),
      ],
    );
  }

  String _formatTotalDuration() {
    final duration = Duration(days: _days, hours: _hours, minutes: _minutes);
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
}

/// Compact version for smaller spaces
class CompactAdvanceNotificationSelector extends StatelessWidget {
  final List<Duration> selectedNotifications;
  final Function(List<Duration>) onSelectionChanged;
  final bool allowCustomTimes;

  const CompactAdvanceNotificationSelector({
    Key? key,
    required this.selectedNotifications,
    required this.onSelectionChanged,
    this.allowCustomTimes = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quickOptions = [
      const Duration(minutes: 15),
      const Duration(hours: 1),
      const Duration(hours: 24),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notifications,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...quickOptions.map((duration) => _buildCompactChip(duration)),
            if (allowCustomTimes)
              GestureDetector(
                onTap: () => _showCustomTimeDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: AppTheme.createIslamicDecoration(
                    backgroundColor: AppTheme.lightPurple.withOpacity(0.1),
                    borderColor: AppTheme.lightPurple.withOpacity(0.3),
                    borderRadius: 12,
                  ),
                  child: Icon(Icons.add, size: 16, color: AppTheme.primaryPurple),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactChip(Duration duration) {
    final isSelected = selectedNotifications.contains(duration);
    
    return GestureDetector(
      onTap: () {
        List<Duration> newSelection = List.from(selectedNotifications);
        if (newSelection.contains(duration)) {
          newSelection.remove(duration);
        } else {
          newSelection.add(duration);
        }
        onSelectionChanged(newSelection);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: AppTheme.createIslamicDecoration(
          backgroundColor: isSelected 
              ? AppTheme.primaryPurple.withOpacity(0.1) 
              : AppTheme.creamBackground,
          borderColor: isSelected 
              ? AppTheme.primaryPurple.withOpacity(0.4) 
              : AppTheme.lightPurple.withOpacity(0.2),
          borderRadius: 12,
        ),
        child: Text(
          _formatDuration(duration),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryPurple : AppTheme.islamicTextLight,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  void _showCustomTimeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CustomTimeDialog(
        onTimeAdded: (duration) {
          List<Duration> newSelection = List.from(selectedNotifications);
          if (!newSelection.contains(duration)) {
            newSelection.add(duration);
            onSelectionChanged(newSelection);
          }
        },
      ),
    );
  }
}
