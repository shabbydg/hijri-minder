import 'package:flutter/material.dart';
import 'dart:async';
import '../services/prayer_times_service.dart';
import '../services/settings_service.dart';
import '../services/location_service.dart';
import '../models/app_settings.dart';

// Use the PrayerTimes class from the service file which includes locationName
// The service file defines its own PrayerTimes class with additional fields

/// Screen for displaying prayer times with real-time updates and countdown
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final SettingsService _settingsService = SettingsService();
  final LocationService _locationService = LocationService();
  
  PrayerTimes? _currentPrayerTimes;
  AppSettings? _settings;
  String _locationName = '';
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _countdownTimer;
  String _nextPrayerCountdown = '';
  String _nextPrayerName = '';

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Initialize screen data
  Future<void> _initializeScreen() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load settings first
      _settings = await _settingsService.getSettings();
      
      // Check and request location permission if needed
      if (_settings!.enableLocationServices) {
        await _handleLocationPermission();
      }
      
      // Load prayer times
      await _loadPrayerTimes();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load prayer times: $e';
        _isLoading = false;
      });
    }
  }

  /// Handle location permission request
  Future<void> _handleLocationPermission() async {
    try {
      bool hasPermission = await _locationService.hasValidLocationPermissions();
      
      if (!hasPermission) {
        bool granted = await _prayerTimesService.requestUserLocation();
        if (!granted) {
          // Show info that fallback location will be used
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Using fallback location (Colombo, Sri Lanka) for prayer times'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling location permission: $e');
    }
  }

  /// Load current prayer times
  Future<void> _loadPrayerTimes() async {
    try {
      final prayerTimes = await _prayerTimesService.getTodayPrayerTimes();
      final location = await _prayerTimesService.getBestAvailableLocation();
      
      setState(() {
        _currentPrayerTimes = prayerTimes;
        _locationName = location['name'] ?? 'Unknown Location';
        _isLoading = false;
        _errorMessage = null;
      });
      
      _updateNextPrayerInfo();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load prayer times: $e';
        _isLoading = false;
      });
    }
  }

  /// Start countdown timer for next prayer
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateNextPrayerInfo();
    });
  }

  /// Update next prayer information and countdown
  void _updateNextPrayerInfo() {
    if (_currentPrayerTimes == null) return;

    final now = DateTime.now();
    final prayers = _getPrayerList();
    
    // Find next prayer
    for (final prayer in prayers) {
      final prayerTime = _parseTimeString(prayer['time']!);
      if (prayerTime != null && prayerTime.isAfter(now)) {
        setState(() {
          _nextPrayerName = prayer['name']!;
          _nextPrayerCountdown = _calculateCountdown(now, prayerTime);
        });
        return;
      }
    }
    
    // If no prayer found for today, next prayer is tomorrow's first prayer
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final firstPrayerTomorrow = _parseTimeString(_currentPrayerTimes!.sihori, tomorrow);
    if (firstPrayerTomorrow != null) {
      setState(() {
        _nextPrayerName = 'Sihori (Tomorrow)';
        _nextPrayerCountdown = _calculateCountdown(now, firstPrayerTomorrow);
      });
    }
  }

  /// Get list of prayers with names and times
  List<Map<String, String>> _getPrayerList() {
    if (_currentPrayerTimes == null) return [];
    
    return [
      {'name': 'Sihori', 'time': _currentPrayerTimes!.sihori},
      {'name': 'Fajr', 'time': _currentPrayerTimes!.fajr},
      {'name': 'Sunrise', 'time': _currentPrayerTimes!.sunrise},
      {'name': 'Zawaal', 'time': _currentPrayerTimes!.zawaal},
      {'name': 'Zohr End', 'time': _currentPrayerTimes!.zohrEnd},
      {'name': 'Asr End', 'time': _currentPrayerTimes!.asrEnd},
      {'name': 'Maghrib', 'time': _currentPrayerTimes!.maghrib},
      {'name': 'Maghrib End', 'time': _currentPrayerTimes!.maghribEnd},
      {'name': 'Nisful Layl', 'time': _currentPrayerTimes!.nisfulLayl},
      {'name': 'Nisful Layl End', 'time': _currentPrayerTimes!.nisfulLaylEnd},
    ];
  }

  /// Parse time string to DateTime
  DateTime? _parseTimeString(String timeStr, [DateTime? baseDate]) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final base = baseDate ?? DateTime.now();
      
      return DateTime(base.year, base.month, base.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  /// Calculate countdown string
  String _calculateCountdown(DateTime now, DateTime target) {
    final difference = target.difference(now);
    
    if (difference.isNegative) return '00:00:00';
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format prayer time according to user preference
  String _formatPrayerTime(String time) {
    if (_settings == null || _currentPrayerTimes == null) return time;
    
    final use24Hour = _settings!.prayerTimeFormat == '24h';
    return _currentPrayerTimes!.formatTime(time, use24Hour: use24Hour);
  }

  /// Refresh prayer times
  Future<void> _refreshPrayerTimes() async {
    await _loadPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPrayerTimes,
            tooltip: 'Refresh Prayer Times',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading prayer times...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshPrayerTimes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPrayerTimes,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationCard(),
            const SizedBox(height: 16),
            _buildNextPrayerCard(),
            const SizedBox(height: 16),
            _buildPrayerTimesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _locationName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildNextPrayerCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Next Prayer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _nextPrayerName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _nextPrayerCountdown,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hours : Minutes : Seconds',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesList() {
    if (_currentPrayerTimes == null) return const SizedBox.shrink();

    final prayers = _getPrayerList();
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Prayer Times',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...prayers.map((prayer) => _buildPrayerTimeItem(
            prayer['name']!,
            prayer['time']!,
            _isCurrentPrayer(prayer['time']!, currentTime),
          )),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeItem(String name, String time, bool isCurrent) {
    return Container(
      decoration: isCurrent ? BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      ) : null,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrent 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.access_time,
            color: isCurrent 
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(
          _formatPrayerTime(time),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  /// Check if given time is the current prayer time
  bool _isCurrentPrayer(String prayerTime, String currentTime) {
    // Check if current time is within 5 minutes of prayer time
    try {
      final prayerParts = prayerTime.split(':');
      final currentParts = currentTime.split(':');
      
      final prayerMinutes = int.parse(prayerParts[0]) * 60 + int.parse(prayerParts[1]);
      final currentMinutes = int.parse(currentParts[0]) * 60 + int.parse(currentParts[1]);
      
      final difference = (currentMinutes - prayerMinutes).abs();
      return difference <= 5; // Within 5 minutes
    } catch (e) {
      return false;
    }
  }
}