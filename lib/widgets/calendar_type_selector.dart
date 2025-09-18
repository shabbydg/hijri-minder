import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../models/subscription_types.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_patterns.dart';

/// Widget for selecting calendar types with premium feature gating
class CalendarTypeSelector extends StatefulWidget {
  final List<String> selectedTypes;
  final Function(List<String>) onSelectionChanged;
  final bool allowMultipleSelection;
  final bool showPremiumBadges;
  final EdgeInsets? padding;

  const CalendarTypeSelector({
    Key? key,
    required this.selectedTypes,
    required this.onSelectionChanged,
    this.allowMultipleSelection = true,
    this.showPremiumBadges = true,
    this.padding,
  }) : super(key: key);

  @override
  State<CalendarTypeSelector> createState() => _CalendarTypeSelectorState();
}

class _CalendarTypeSelectorState extends State<CalendarTypeSelector> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _hasPremiumAccess = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPremiumAccess();
  }

  Future<void> _checkPremiumAccess() async {
    try {
      final hasAccess = await _subscriptionService.hasActiveSubscription();
      setState(() {
        _hasPremiumAccess = hasAccess;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasPremiumAccess = false;
        _isLoading = false;
      });
    }
  }

  void _toggleCalendarType(String calendarType) {
    if (_isLoading) return;

    List<String> newSelection = List.from(widget.selectedTypes);

    if (widget.allowMultipleSelection) {
      if (newSelection.contains(calendarType)) {
        newSelection.remove(calendarType);
      } else {
        // Check premium access for Hijri calendar
        if (calendarType == 'hijri' && !_hasPremiumAccess) {
          _showPremiumUpgradeDialog();
          return;
        }
        newSelection.add(calendarType);
      }
    } else {
      // Single selection mode
      if (calendarType == 'hijri' && !_hasPremiumAccess) {
        _showPremiumUpgradeDialog();
        return;
      }
      newSelection = [calendarType];
    }

    widget.onSelectionChanged(newSelection);
  }

  void _showPremiumUpgradeDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.creamSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: AppTheme.createIslamicDecoration(
            backgroundColor: AppTheme.creamSurface,
            borderColor: AppTheme.goldAccent.withOpacity(0.3),
            borderRadius: 20,
            boxShadow: AppTheme.createIslamicShadows(
              color: AppTheme.goldAccent,
              blurRadius: 12,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.goldAccent.withOpacity(0.1), AppTheme.lightGold.withOpacity(0.05)],
                  ),
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
                        color: AppTheme.goldAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.star,
                        color: AppTheme.goldAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.premiumFeature,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.goldAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.hijriRemindersRequirePremium,
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
                        onPressed: () => Navigator.of(context).pop(),
                        style: AppTheme.createIslamicButtonStyle(
                          backgroundColor: AppTheme.warmBeige,
                          foregroundColor: AppTheme.islamicTextLight,
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: Navigate to subscription screen
                        },
                        style: AppTheme.createIslamicButtonStyle(
                          backgroundColor: AppTheme.goldAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(l10n.upgradeToPremium),
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
                  Icons.calendar_month,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.selectCalendarTypes,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.islamicText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.selectCalendarTypesForReminder,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.islamicTextLight,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCalendarTypeCard(
                  'gregorian',
                  l10n.gregorianCalendar,
                  Icons.calendar_today,
                  AppTheme.primaryPurple,
                  l10n.standardCalendar,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCalendarTypeCard(
                  'hijri',
                  l10n.hijriCalendar,
                  Icons.nights_stay,
                  AppTheme.secondaryPurple,
                  l10n.islamicCalendar,
                ),
              ),
            ],
          ),
          if (widget.selectedTypes.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: AppTheme.errorRed,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.pleaseSelectCalendarType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarTypeCard(
    String calendarType,
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = widget.selectedTypes.contains(calendarType);
    final isHijri = calendarType == 'hijri';
    final isPremiumRestricted = isHijri && !_hasPremiumAccess;

    return DecorativeCorner(
      position: CornerPosition.topLeft,
      color: color,
      opacity: isSelected ? 0.2 : 0.05,
      child: GestureDetector(
        onTap: () => _toggleCalendarType(calendarType),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.createIslamicDecoration(
            backgroundColor: isSelected 
                ? color.withOpacity(0.08) 
                : AppTheme.creamBackground,
            borderColor: isSelected 
                ? color.withOpacity(0.4) 
                : AppTheme.lightPurple.withOpacity(0.2),
            borderRadius: 16,
            boxShadow: isSelected 
                ? AppTheme.createIslamicShadows(color: color, blurRadius: 6)
                : AppTheme.createIslamicShadows(color: AppTheme.islamicTextLight, blurRadius: 2),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? color.withOpacity(0.15) 
                          : AppTheme.lightPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: isSelected ? color : AppTheme.islamicTextLight,
                    ),
                  ),
                  if (isPremiumRestricted && widget.showPremiumBadges)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.goldAccent, AppTheme.lightGold],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.createIslamicShadows(
                            color: AppTheme.goldAccent,
                            blurRadius: 4,
                          ),
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : AppTheme.islamicText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected 
                      ? color.withOpacity(0.8) 
                      : AppTheme.islamicTextLight,
                ),
                textAlign: TextAlign.center,
              ),
              if (isPremiumRestricted && widget.showPremiumBadges) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.goldAccent, AppTheme.lightGold],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.premium,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version of calendar type selector for smaller spaces
class CompactCalendarTypeSelector extends StatelessWidget {
  final List<String> selectedTypes;
  final Function(List<String>) onSelectionChanged;
  final bool allowMultipleSelection;
  final bool showPremiumBadges;

  const CompactCalendarTypeSelector({
    Key? key,
    required this.selectedTypes,
    required this.onSelectionChanged,
    this.allowMultipleSelection = true,
    this.showPremiumBadges = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _buildCompactChip(context, 'gregorian', l10n.gregorianCalendar, Icons.calendar_today, AppTheme.primaryPurple),
        const SizedBox(width: 8),
        _buildCompactChip(context, 'hijri', l10n.hijriCalendar, Icons.nights_stay, AppTheme.secondaryPurple),
      ],
    );
  }

  Widget _buildCompactChip(BuildContext context, String calendarType, String label, IconData icon, Color color) {
    final isSelected = selectedTypes.contains(calendarType);
    
    return GestureDetector(
      onTap: () {
        List<String> newSelection = List.from(selectedTypes);
        
        if (allowMultipleSelection) {
          if (newSelection.contains(calendarType)) {
            newSelection.remove(calendarType);
          } else {
            newSelection.add(calendarType);
          }
        } else {
          newSelection = [calendarType];
        }
        
        onSelectionChanged(newSelection);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: AppTheme.createIslamicDecoration(
          backgroundColor: isSelected 
              ? color.withOpacity(0.1) 
              : AppTheme.creamBackground,
          borderColor: isSelected 
              ? color.withOpacity(0.4) 
              : AppTheme.lightPurple.withOpacity(0.2),
          borderRadius: 20,
          boxShadow: isSelected 
              ? AppTheme.createIslamicShadows(color: color, blurRadius: 4)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? color.withOpacity(0.2) 
                    : AppTheme.lightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 14,
                color: isSelected ? color : AppTheme.islamicTextLight,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppTheme.islamicTextLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
