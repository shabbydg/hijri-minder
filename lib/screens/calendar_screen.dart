import 'package:flutter/material.dart';
import '../models/hijri_calendar.dart';
import '../models/hijri_date.dart';
import '../models/islamic_event.dart';
import '../models/app_settings.dart';
import '../models/reminder.dart';
import '../services/events_service.dart';
import '../services/prayer_times_service.dart' as pts;
import '../services/settings_service.dart';
import '../services/service_locator.dart';
import '../services/performance_service.dart';
import '../services/reminder_service.dart';
import '../utils/gregorian_date_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/islamic_patterns.dart';
import 'reminder_screen.dart';
import '../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late HijriCalendar _currentCalendar;
  late EventsService _eventsService;
  late pts.PrayerTimesService _prayerTimesService;
  late PerformanceService _performanceService;
  late SettingsService _settingsService;
  late ReminderService _reminderService;
  
  // State variables for prayer times
  DateTime _selectedDate = DateTime.now();
  pts.PrayerTimes? _selectedPrayerTimes;
  bool _isLoadingPrayerTimes = false;
  int _lastPrayerTimesRequestId = 0;
  
  // Cache for calendar data to avoid recalculation
  final Map<String, List<List<Map<String, dynamic>?>>> _calendarCache = {};
  final Map<String, Map<String, bool>> _eventsCache = {};

  @override
  void initState() {
    super.initState();
    _eventsService = ServiceLocator.eventsService;
    _prayerTimesService = ServiceLocator.prayerTimesService;
    _performanceService = PerformanceService();
    _settingsService = ServiceLocator.settingsService;
    _reminderService = ServiceLocator.reminderService;
    
    // Initialize with current Hijri date
    _performanceService.timeSync('calendar_init', () {
      final now = DateTime.now();
      final currentHijriDate = HijriDate.fromGregorian(now);
      _currentCalendar = HijriCalendar(
        currentHijriDate.getYear(),
        currentHijriDate.getMonth(),
      );
    });
    
    // Preload events for current and adjacent months
    _preloadEvents();
    
    // Load prayer times for current date
    _loadPrayerTimesForDate(_selectedDate);
  }

  void _navigateToPreviousMonth() {
    _performanceService.timeSync('calendar_navigate_previous', () {
      setState(() {
        _currentCalendar = _currentCalendar.previousMonth();
      });
      _preloadEvents(); // Preload events for new month
    });
  }

  void _navigateToNextMonth() {
    _performanceService.timeSync('calendar_navigate_next', () {
      setState(() {
        _currentCalendar = _currentCalendar.nextMonth();
      });
      _preloadEvents(); // Preload events for new month
    });
  }

  void _navigateToToday() {
    _performanceService.timeSync('calendar_navigate_today', () {
      final now = DateTime.now();
      final currentHijriDate = HijriDate.fromGregorian(now);
      setState(() {
        _currentCalendar = HijriCalendar(
          currentHijriDate.getYear(),
          currentHijriDate.getMonth(),
        );
      });
      _preloadEvents();
    });
  }

  /// Preload events for current and adjacent months for better performance
  void _preloadEvents() {
    _performanceService.debounce('preload_events', () async {
      final currentMonth = _currentCalendar.getMonth();
      final currentYear = _currentCalendar.getYear();
      
      // Preload events for current, previous, and next months
      final monthsToLoad = [
        {'year': currentYear, 'month': currentMonth == 1 ? 12 : currentMonth - 1},
        {'year': currentYear, 'month': currentMonth},
        {'year': currentYear, 'month': currentMonth == 12 ? 1 : currentMonth + 1},
      ];
      
      for (final monthData in monthsToLoad) {
        final cacheKey = 'events_${monthData['year']}_${monthData['month']}';
        if (!_eventsCache.containsKey(cacheKey)) {
          final events = await _eventsService.getEventsForMonth(monthData['month']!);
          final eventsMap = <String, bool>{};
          for (final event in events) {
            eventsMap['${event.hijriDay}_${event.hijriMonth}'] = true;
          }
          _eventsCache[cacheKey] = eventsMap;
        }
      }
    }, const Duration(milliseconds: 300));
  }

  /// Load prayer times for a specific date
  Future<void> _loadPrayerTimesForDate(DateTime date) async {
    if (!mounted) return;
    
    // Increment request ID and capture for race condition check
    _lastPrayerTimesRequestId++;
    final requestId = _lastPrayerTimesRequestId;
    
    setState(() {
      _isLoadingPrayerTimes = true;
      _selectedDate = date;
    });

    try {
      final prayerTimes = await _prayerTimesService.getPrayerTimesForDate(date);
      
      // Check for race conditions before updating state
      if (!mounted || requestId != _lastPrayerTimesRequestId) return;
      
      setState(() {
        _selectedPrayerTimes = prayerTimes;
        _isLoadingPrayerTimes = false;
      });
    } catch (e) {
      debugPrint('CalendarScreen: Error loading prayer times for $date: $e');
      
      // Check for race conditions before updating state
      if (!mounted || requestId != _lastPrayerTimesRequestId) return;
      
      setState(() {
        _selectedPrayerTimes = null;
        _isLoadingPrayerTimes = false;
      });
    }
  }

  /// Build prayer times section widget
  Widget _buildPrayerTimesSection() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: AppTheme.createIslamicDecoration(
        backgroundColor: AppTheme.creamSurface,
        borderColor: AppTheme.lightPurple.withOpacity(0.3),
        borderRadius: 12,
      ),
      child: Column(
        children: [
          if (_isLoadingPrayerTimes)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: AppTheme.primaryPurple,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_selectedPrayerTimes == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.error_outline,
                  color: AppTheme.errorRed,
                  size: 24,
                ),
              ),
            )
          else
            _buildPrayerTimesGrid(),
        ],
      ),
    );
  }

  /// Build prayer times grid with Sunrise, Zawaal, and Maghrib
  Widget _buildPrayerTimesGrid() {
    return FutureBuilder<AppSettings>(
      future: _settingsService.getSettings(),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? AppSettings.defaultSettings();
        final use24Hour = settings.is24HourFormat();
        
        return Row(
          children: [
            Expanded(
              child: _buildPrayerTimeItem(
                'Sunrise',
                _selectedPrayerTimes!.formatTime(_selectedPrayerTimes!.sunrise, use24Hour: use24Hour),
                Icons.wb_sunny,
                Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPrayerTimeItem(
                'Zawaal',
                _selectedPrayerTimes!.formatTime(_selectedPrayerTimes!.zawaal, use24Hour: use24Hour),
                Icons.wb_sunny_outlined,
                Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPrayerTimeItem(
                'Maghrib',
                _selectedPrayerTimes!.formatTime(_selectedPrayerTimes!.maghrib, use24Hour: use24Hour),
                Icons.nights_stay,
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build individual prayer time item
  Widget _buildPrayerTimeItem(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: AppTheme.createIslamicDecoration(
        backgroundColor: color.withOpacity(0.08),
        borderColor: color.withOpacity(0.2),
        borderRadius: 8,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.islamicText,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
                Icons.calendar_month,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.hijriCalendar),
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
              icon: const Icon(Icons.today, color: Colors.white),
              onPressed: _navigateToToday,
              tooltip: AppLocalizations.of(context)!.goToToday,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          _buildWeekdayHeaders(),
          Expanded(
            child: _buildCalendarGrid(),
          ),
          _buildPrayerTimesSection(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final monthName = HijriDate.getMonthName(_currentCalendar.getMonth());
    final year = _currentCalendar.getYear();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: IslamicBorder(
        color: AppTheme.primaryPurple,
        opacity: 0.15,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: AppTheme.createIslamicDecoration(
            backgroundColor: AppTheme.creamSurface,
            borderColor: AppTheme.lightPurple.withOpacity(0.2),
            borderRadius: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.chevron_left, color: AppTheme.primaryPurple),
                  onPressed: _navigateToPreviousMonth,
                  tooltip: AppLocalizations.of(context)!.previousMonth,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      monthName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$year AH',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.islamicTextLight,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.chevron_right, color: AppTheme.primaryPurple),
                  onPressed: _navigateToNextMonth,
                  tooltip: AppLocalizations.of(context)!.nextMonth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: weekdays.map((day) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return _performanceService.optimizedBuilder(
      operationName: 'calendar_grid_build',
      cacheFor: const Duration(seconds: 30), // Cache for 30 seconds
      builder: () {
        final weeks = _getOptimizedWeeks();
        
        return ListView.builder(
          itemCount: weeks.length,
          itemBuilder: (context, weekIndex) {
            final previousWeek = weekIndex > 0 ? weeks[weekIndex - 1] : null;
            return _buildWeekRow(weeks[weekIndex], weekIndex, previousWeek);
          },
          // Add performance optimizations
          cacheExtent: 200, // Cache 200 pixels ahead
          physics: const ClampingScrollPhysics(),
        );
      },
    );
  }

  /// Get weeks with caching for better performance
  List<List<Map<String, dynamic>?>> _getOptimizedWeeks() {
    final cacheKey = '${_currentCalendar.getYear()}_${_currentCalendar.getMonth()}';
    
    if (_calendarCache.containsKey(cacheKey)) {
      return _calendarCache[cacheKey]!;
    }
    
    final weeks = _performanceService.timeSync('calendar_weeks_generation', () {
      return _currentCalendar.weeks();
    });
    
    // Cache the result
    _calendarCache[cacheKey] = weeks;
    
    // Limit cache size to prevent memory issues
    if (_calendarCache.length > 12) { // Keep only 12 months
      final oldestKey = _calendarCache.keys.first;
      _calendarCache.remove(oldestKey);
    }
    
    return weeks;
  }

  Widget _buildWeekRow(List<Map<String, dynamic>?> week, int weekIndex, List<Map<String, dynamic>?>? previousWeek) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: week.asMap().entries.map((entry) {
          final dayIndex = entry.key;
          final dayData = entry.value;
          
          // Get previous day data for month change detection
          Map<String, dynamic>? previousDayData;
          if (dayIndex > 0) {
            previousDayData = week[dayIndex - 1];
          } else if (dayIndex == 0 && previousWeek != null) {
            // When dayIndex == 0, set previousDayData from the last non-null entry of previousWeek
            for (int i = previousWeek.length - 1; i >= 0; i--) {
              if (previousWeek[i] != null) {
                previousDayData = previousWeek[i];
                break;
              }
            }
          }
          
          // Add additional data to dayData if it exists
          Map<String, dynamic>? enhancedDayData;
          if (dayData != null) {
            enhancedDayData = Map<String, dynamic>.from(dayData);
            enhancedDayData['dayIndex'] = dayIndex;
            enhancedDayData['weekIndex'] = weekIndex;
            enhancedDayData['previousDayData'] = previousDayData;
          }
          
          return Expanded(
            child: _buildDayCell(enhancedDayData),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildDayCell(Map<String, dynamic>? dayData) {
    if (dayData == null) {
      return Container(
        height: 60,
        margin: const EdgeInsets.all(2.0),
      );
    }

    final hijriDate = dayData['hijriDate'] as HijriDate;
    final gregorianDate = dayData['gregorianDate'] as DateTime;
    final isToday = dayData['isToday'] as bool;
    final isPrevious = dayData['isPrevious'] as bool;
    final isNext = dayData['isNext'] as bool;
    final weekIndex = dayData['weekIndex'] as int;
    final dayIndex = dayData['dayIndex'] as int;
    final previousDayData = dayData['previousDayData'] as Map<String, dynamic>?;
    
    // Check if this date has events using cached data
    final hasEvents = _hasEventsOptimized(hijriDate.getDate(), hijriDate.getMonth() + 1);

    // Determine if we should show Gregorian month name
    bool shouldShowMonthName = false;
    String monthAbbreviation = '';
    
    if (weekIndex == 0 && dayIndex == 0) {
      // First tile in the calendar grid
      shouldShowMonthName = true;
      monthAbbreviation = GregorianDateUtils.getShortMonthName(gregorianDate.month);
    } else if (previousDayData != null) {
      // Check if a new Gregorian month starts
      final previousGregorianDate = previousDayData['gregorianDate'] as DateTime;
      if (gregorianDate.month != previousGregorianDate.month) {
        shouldShowMonthName = true;
        monthAbbreviation = GregorianDateUtils.getShortMonthName(gregorianDate.month);
      }
    }

    // Determine cell colors
    Color? backgroundColor;
    Color textColor;

    if (isToday) {
      backgroundColor = AppTheme.primaryPurple;
      textColor = Colors.white;
    } else if (isPrevious || isNext) {
      textColor = AppTheme.islamicTextLight.withOpacity(0.7);
    } else {
      textColor = AppTheme.islamicTextDark; // Use darker text for better visibility
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.all(2.0),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () => _onDayTapped(hijriDate, gregorianDate),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hijri date (primary)
                Text(
                  '${hijriDate.getDate()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 16, // Make it slightly larger
                  ),
                ),
                // Gregorian date (secondary) with optional month name
                Text(
                  shouldShowMonthName 
                    ? '${gregorianDate.day} $monthAbbreviation'
                    : '${gregorianDate.day}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor.withOpacity(0.8), // Increase opacity for better visibility
                    fontSize: 11, // Make it slightly larger
                  ),
                ),
                // Event indicator
                if (hasEvents)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isToday 
                        ? Colors.white
                        : AppTheme.secondaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDayTapped(HijriDate hijriDate, DateTime gregorianDate) {
    _performanceService.timeSync('calendar_day_tap', () async {
      // Start fetch (non-blocking)
      _loadPrayerTimesForDate(gregorianDate);
      
      // Get events for this date
      final events = await _eventsService.getEventsForDate(
        hijriDate.getDate(),
        hijriDate.getMonth() + 1, // EventsService uses 1-based months
      );

      // Show dialog immediately
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _buildDayDetailsDialog(
            hijriDate,
            gregorianDate,
            events,
          ),
        );
      }
    });
  }

  /// Optimized events checking using cached data
  bool _hasEventsOptimized(int day, int month) {
    final cacheKey = 'events_${_currentCalendar.getYear()}_$month';
    final eventsMap = _eventsCache[cacheKey];
    
    if (eventsMap != null) {
      return eventsMap['${day}_$month'] ?? false;
    }
    
    // Fallback to service call (should be rare due to preloading)
    return _eventsService.hasEventsForDate(day, month);
  }

  @override
  void dispose() {
    // Clear caches to free memory
    _calendarCache.clear();
    _eventsCache.clear();
    super.dispose();
  }

  Widget _buildDayDetailsDialog(
    HijriDate hijriDate,
    DateTime gregorianDate,
    List<IslamicEvent> events,
  ) {
    final hijriMonthName = HijriDate.getMonthName(hijriDate.getMonth());
    
    return Dialog(
      backgroundColor: AppTheme.creamSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Islamic decoration
            Container(
              padding: const EdgeInsets.all(20),
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
                      Icons.calendar_month,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${hijriDate.getDate()} $hijriMonthName ${hijriDate.getYear()} AH',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                        Text(
                          '${gregorianDate.day}/${gregorianDate.month}/${gregorianDate.year}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.islamicTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: events.isEmpty
                  ? Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: AppTheme.islamicTextLight,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.noEventsOnThisDate,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.islamicTextLight,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              color: AppTheme.primaryPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.events,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...events.map((event) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: AppTheme.createIslamicDecoration(
                            backgroundColor: AppTheme.lightPurple.withOpacity(0.05),
                            borderColor: AppTheme.lightPurple.withOpacity(0.2),
                            borderRadius: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (event.isImportant)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.goldAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.star,
                                        size: 16,
                                        color: AppTheme.goldAccent,
                                      ),
                                    ),
                                  if (event.isImportant) const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.islamicText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (event.description.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  event.description,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.islamicTextLight,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  event.getCategoryDisplayName(),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.secondaryPurple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
            ),
            // Actions
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
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showReminderDialogWithDate(hijriDate, gregorianDate),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppLocalizations.of(context)!.addReminder),
                      style: AppTheme.createIslamicButtonStyle(),
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

  /// Show reminder dialog with pre-filled dates
  Future<void> _showReminderDialogWithDate(HijriDate hijriDate, DateTime gregorianDate) async {
    // Close the day details dialog first
    Navigator.of(context).pop();
    
    final result = await showDialog<Reminder>(
      context: context,
      builder: (context) => ReminderDialog(
        reminder: null,
        reminderService: _reminderService,
        initialHijriDate: hijriDate,
        initialGregorianDate: gregorianDate,
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.reminderCreatedSuccessfully)),
      );
    }
  }
}