import 'dart:convert';

/// Model representing prayer times for a specific date
class PrayerTimes {
  final String sihori;
  final String fajr;
  final String sunrise;
  final String zawaal;
  final String zohrEnd;
  final String asrEnd;
  final String maghrib;
  final String maghribEnd;
  final String nisfulLayl;
  final String nisfulLaylEnd;
  final DateTime date;

  const PrayerTimes({
    required this.sihori,
    required this.fajr,
    required this.sunrise,
    required this.zawaal,
    required this.zohrEnd,
    required this.asrEnd,
    required this.maghrib,
    required this.maghribEnd,
    required this.nisfulLayl,
    required this.nisfulLaylEnd,
    required this.date,
  });

  /// Factory constructor from JSON
  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      sihori: json['sihori'] ?? '',
      fajr: json['fajr'] ?? '',
      sunrise: json['sunrise'] ?? '',
      zawaal: json['zawaal'] ?? '',
      zohrEnd: json['zohrEnd'] ?? '',
      asrEnd: json['asrEnd'] ?? '',
      maghrib: json['maghrib'] ?? '',
      maghribEnd: json['maghribEnd'] ?? '',
      nisfulLayl: json['nisfulLayl'] ?? '',
      nisfulLaylEnd: json['nisfulLaylEnd'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sihori': sihori,
      'fajr': fajr,
      'sunrise': sunrise,
      'zawaal': zawaal,
      'zohrEnd': zohrEnd,
      'asrEnd': asrEnd,
      'maghrib': maghrib,
      'maghribEnd': maghribEnd,
      'nisfulLayl': nisfulLayl,
      'nisfulLaylEnd': nisfulLaylEnd,
      'date': date.toIso8601String(),
    };
  }

  /// Get the next prayer time from current time
  String getNextPrayer() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final prayers = [
      {'name': 'Sihori', 'time': sihori},
      {'name': 'Fajr', 'time': fajr},
      {'name': 'Sunrise', 'time': sunrise},
      {'name': 'Zawaal', 'time': zawaal},
      {'name': 'Zohr End', 'time': zohrEnd},
      {'name': 'Asr End', 'time': asrEnd},
      {'name': 'Maghrib', 'time': maghrib},
      {'name': 'Maghrib End', 'time': maghribEnd},
      {'name': 'Nisful Layl', 'time': nisfulLayl},
      {'name': 'Nisful Layl End', 'time': nisfulLaylEnd},
    ];

    for (final prayer in prayers) {
      if (_isTimeAfter(currentTime, prayer['time']!)) {
        return prayer['name']!;
      }
    }
    
    // If no prayer is found for today, return first prayer of next day
    return 'Sihori';
  }

  /// Get current prayer period
  String getCurrentPrayerPeriod() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    if (_isTimeBetween(currentTime, sihori, fajr)) return 'Sihori Period';
    if (_isTimeBetween(currentTime, fajr, sunrise)) return 'Fajr Period';
    if (_isTimeBetween(currentTime, sunrise, zawaal)) return 'Sunrise Period';
    if (_isTimeBetween(currentTime, zawaal, zohrEnd)) return 'Zawaal Period';
    if (_isTimeBetween(currentTime, zohrEnd, asrEnd)) return 'Zohr Period';
    if (_isTimeBetween(currentTime, asrEnd, maghrib)) return 'Asr Period';
    if (_isTimeBetween(currentTime, maghrib, maghribEnd)) return 'Maghrib Period';
    if (_isTimeBetween(currentTime, maghribEnd, nisfulLayl)) return 'Maghrib End Period';
    if (_isTimeBetween(currentTime, nisfulLayl, nisfulLaylEnd)) return 'Nisful Layl Period';
    
    return 'Night Period';
  }

  /// Format time according to specified format (12h/24h)
  String formatTime(String time, {bool is24Hour = true}) {
    if (time.isEmpty) return '';
    
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      if (is24Hour) {
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      } else {
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }

  /// Check if current time is a prayer time
  bool isPrayerTime() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return currentTime == sihori ||
           currentTime == fajr ||
           currentTime == sunrise ||
           currentTime == zawaal ||
           currentTime == zohrEnd ||
           currentTime == asrEnd ||
           currentTime == maghrib ||
           currentTime == maghribEnd ||
           currentTime == nisfulLayl ||
           currentTime == nisfulLaylEnd;
  }

  /// Helper method to check if time1 is after time2
  bool _isTimeAfter(String time1, String time2) {
    try {
      final parts1 = time1.split(':');
      final parts2 = time2.split(':');
      
      final hour1 = int.parse(parts1[0]);
      final minute1 = int.parse(parts1[1]);
      final hour2 = int.parse(parts2[0]);
      final minute2 = int.parse(parts2[1]);
      
      if (hour1 > hour2) return true;
      if (hour1 == hour2 && minute1 > minute2) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to check if time is between start and end times
  bool _isTimeBetween(String time, String start, String end) {
    return !_isTimeAfter(time, start) && _isTimeAfter(time, end);
  }

  @override
  String toString() {
    return 'PrayerTimes(date: $date, sihori: $sihori, fajr: $fajr, maghrib: $maghrib)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrayerTimes &&
        other.sihori == sihori &&
        other.fajr == fajr &&
        other.sunrise == sunrise &&
        other.zawaal == zawaal &&
        other.zohrEnd == zohrEnd &&
        other.asrEnd == asrEnd &&
        other.maghrib == maghrib &&
        other.maghribEnd == maghribEnd &&
        other.nisfulLayl == nisfulLayl &&
        other.nisfulLaylEnd == nisfulLaylEnd &&
        other.date == date;
  }

  @override
  int get hashCode {
    return Object.hash(
      sihori,
      fajr,
      sunrise,
      zawaal,
      zohrEnd,
      asrEnd,
      maghrib,
      maghribEnd,
      nisfulLayl,
      nisfulLaylEnd,
      date,
    );
  }
}