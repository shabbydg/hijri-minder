import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/prayer_times.dart';

void main() {
  group('PrayerTimes Model Tests', () {
    late PrayerTimes testPrayerTimes;

    setUp(() {
      testPrayerTimes = PrayerTimes(
        sihori: '04:30',
        fajr: '05:15',
        sunrise: '06:45',
        zawaal: '12:15',
        zohrEnd: '16:30',
        asrEnd: '17:45',
        maghrib: '18:30',
        maghribEnd: '19:45',
        nisfulLayl: '23:30',
        nisfulLaylEnd: '00:15',
        date: DateTime(2024, 1, 15),
      );
    });

    test('should create PrayerTimes with all required fields', () {
      expect(testPrayerTimes.sihori, '04:30');
      expect(testPrayerTimes.fajr, '05:15');
      expect(testPrayerTimes.sunrise, '06:45');
      expect(testPrayerTimes.zawaal, '12:15');
      expect(testPrayerTimes.zohrEnd, '16:30');
      expect(testPrayerTimes.asrEnd, '17:45');
      expect(testPrayerTimes.maghrib, '18:30');
      expect(testPrayerTimes.maghribEnd, '19:45');
      expect(testPrayerTimes.nisfulLayl, '23:30');
      expect(testPrayerTimes.nisfulLaylEnd, '00:15');
      expect(testPrayerTimes.date, DateTime(2024, 1, 15));
    });

    test('should serialize to JSON correctly', () {
      final json = testPrayerTimes.toJson();
      
      expect(json['sihori'], '04:30');
      expect(json['fajr'], '05:15');
      expect(json['sunrise'], '06:45');
      expect(json['zawaal'], '12:15');
      expect(json['zohrEnd'], '16:30');
      expect(json['asrEnd'], '17:45');
      expect(json['maghrib'], '18:30');
      expect(json['maghribEnd'], '19:45');
      expect(json['nisfulLayl'], '23:30');
      expect(json['nisfulLaylEnd'], '00:15');
      expect(json['date'], '2024-01-15T00:00:00.000');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'sihori': '04:30',
        'fajr': '05:15',
        'sunrise': '06:45',
        'zawaal': '12:15',
        'zohrEnd': '16:30',
        'asrEnd': '17:45',
        'maghrib': '18:30',
        'maghribEnd': '19:45',
        'nisfulLayl': '23:30',
        'nisfulLaylEnd': '00:15',
        'date': '2024-01-15T00:00:00.000',
      };

      final prayerTimes = PrayerTimes.fromJson(json);
      
      expect(prayerTimes.sihori, '04:30');
      expect(prayerTimes.fajr, '05:15');
      expect(prayerTimes.sunrise, '06:45');
      expect(prayerTimes.zawaal, '12:15');
      expect(prayerTimes.zohrEnd, '16:30');
      expect(prayerTimes.asrEnd, '17:45');
      expect(prayerTimes.maghrib, '18:30');
      expect(prayerTimes.maghribEnd, '19:45');
      expect(prayerTimes.nisfulLayl, '23:30');
      expect(prayerTimes.nisfulLaylEnd, '00:15');
      expect(prayerTimes.date, DateTime(2024, 1, 15));
    });

    test('should format time in 24-hour format', () {
      expect(testPrayerTimes.formatTime('05:15', is24Hour: true), '05:15');
      expect(testPrayerTimes.formatTime('13:30', is24Hour: true), '13:30');
      expect(testPrayerTimes.formatTime('00:00', is24Hour: true), '00:00');
    });

    test('should format time in 12-hour format', () {
      expect(testPrayerTimes.formatTime('05:15', is24Hour: false), '05:15 AM');
      expect(testPrayerTimes.formatTime('13:30', is24Hour: false), '01:30 PM');
      expect(testPrayerTimes.formatTime('00:00', is24Hour: false), '12:00 AM');
      expect(testPrayerTimes.formatTime('12:00', is24Hour: false), '12:00 PM');
    });

    test('should handle invalid time format gracefully', () {
      expect(testPrayerTimes.formatTime('invalid'), 'invalid');
      expect(testPrayerTimes.formatTime(''), '');
      expect(testPrayerTimes.formatTime('25:70'), '25:70');
    });

    test('should get current prayer period correctly', () {
      // This test would need to mock DateTime.now() for proper testing
      // For now, we'll test the method exists and returns a string
      final period = testPrayerTimes.getCurrentPrayerPeriod();
      expect(period, isA<String>());
      expect(period.isNotEmpty, true);
    });

    test('should check if current time is prayer time', () {
      // This test would need to mock DateTime.now() for proper testing
      // For now, we'll test the method exists and returns a boolean
      final isPrayerTime = testPrayerTimes.isPrayerTime();
      expect(isPrayerTime, isA<bool>());
    });

    test('should implement equality correctly', () {
      final prayerTimes1 = PrayerTimes(
        sihori: '04:30',
        fajr: '05:15',
        sunrise: '06:45',
        zawaal: '12:15',
        zohrEnd: '16:30',
        asrEnd: '17:45',
        maghrib: '18:30',
        maghribEnd: '19:45',
        nisfulLayl: '23:30',
        nisfulLaylEnd: '00:15',
        date: DateTime(2024, 1, 15),
      );

      final prayerTimes2 = PrayerTimes(
        sihori: '04:30',
        fajr: '05:15',
        sunrise: '06:45',
        zawaal: '12:15',
        zohrEnd: '16:30',
        asrEnd: '17:45',
        maghrib: '18:30',
        maghribEnd: '19:45',
        nisfulLayl: '23:30',
        nisfulLaylEnd: '00:15',
        date: DateTime(2024, 1, 15),
      );

      final prayerTimes3 = PrayerTimes(
        sihori: '04:35', // Different time
        fajr: '05:15',
        sunrise: '06:45',
        zawaal: '12:15',
        zohrEnd: '16:30',
        asrEnd: '17:45',
        maghrib: '18:30',
        maghribEnd: '19:45',
        nisfulLayl: '23:30',
        nisfulLaylEnd: '00:15',
        date: DateTime(2024, 1, 15),
      );

      expect(prayerTimes1, equals(prayerTimes2));
      expect(prayerTimes1, isNot(equals(prayerTimes3)));
      expect(prayerTimes1.hashCode, equals(prayerTimes2.hashCode));
    });

    test('should have proper toString representation', () {
      final string = testPrayerTimes.toString();
      expect(string, contains('PrayerTimes'));
      expect(string, contains('2024-01-15'));
      expect(string, contains('04:30'));
      expect(string, contains('05:15'));
      expect(string, contains('18:30'));
    });
  });
}