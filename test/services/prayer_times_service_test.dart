import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/prayer_times_service.dart';

void main() {
  group('PrayerTimesService Tests', () {
    late PrayerTimesService prayerTimesService;

    setUp(() {
      prayerTimesService = PrayerTimesService();
    });

    test('should get mock prayer times', () {
      final prayerTimes = prayerTimesService.getMockPrayerTimes();
      
      expect(prayerTimes.sihori, isNotEmpty);
      expect(prayerTimes.fajr, isNotEmpty);
      expect(prayerTimes.sunrise, isNotEmpty);
      expect(prayerTimes.zawaal, isNotEmpty);
      expect(prayerTimes.zohrEnd, isNotEmpty);
      expect(prayerTimes.asrEnd, isNotEmpty);
      expect(prayerTimes.maghrib, isNotEmpty);
      expect(prayerTimes.maghribEnd, isNotEmpty);
      expect(prayerTimes.nisfulLayl, isNotEmpty);
      expect(prayerTimes.nisfulLaylEnd, isNotEmpty);
      expect(prayerTimes.locationName, contains('Fallback'));
    });

    test('should get mock prayer times for specific date', () {
      final testDate = DateTime(2024, 1, 15);
      final prayerTimes = prayerTimesService.getMockPrayerTimes(testDate);
      
      expect(prayerTimes.date, equals(testDate));
    });

    test('should get best available location', () async {
      final location = await prayerTimesService.getBestAvailableLocation();
      
      expect(location, isA<Map<String, dynamic>>());
      expect(location.containsKey('latitude'), isTrue);
      expect(location.containsKey('longitude'), isTrue);
      expect(location.containsKey('name'), isTrue);
    });
  });

  group('PrayerTimes Model Tests', () {
    late PrayerTimes prayerTimes;

    setUp(() {
      prayerTimes = PrayerTimes(
        sihori: '04:30',
        fajr: '05:15',
        sunrise: '06:30',
        zawaal: '12:15',
        zohrEnd: '12:45',
        asrEnd: '16:30',
        maghrib: '18:15',
        maghribEnd: '18:45',
        nisfulLayl: '23:30',
        nisfulLaylEnd: '00:15',
        date: DateTime.now(),
        locationName: 'Test Location',
      );
    });

    test('should format time in 12-hour format', () {
      final formatted = prayerTimes.formatTime('13:30', use24Hour: false);
      
      expect(formatted, equals('1:30 PM'));
    });

    test('should format time in 24-hour format', () {
      final formatted = prayerTimes.formatTime('13:30', use24Hour: true);
      
      expect(formatted, equals('13:30'));
    });

    test('should handle midnight in 12-hour format', () {
      final formatted = prayerTimes.formatTime('00:15', use24Hour: false);
      
      expect(formatted, equals('12:15 AM'));
    });

    test('should handle noon in 12-hour format', () {
      final formatted = prayerTimes.formatTime('12:00', use24Hour: false);
      
      expect(formatted, equals('12:00 PM'));
    });

    test('should return original time for invalid format', () {
      final formatted = prayerTimes.formatTime('invalid', use24Hour: false);
      
      expect(formatted, equals('invalid'));
    });

    test('should create PrayerTimes from map', () {
      final map = {
        'sihori': '04:30',
        'fajr': '05:15',
        'sunrise': '06:30',
        'zawaal': '12:15',
        'zohr_end': '12:45',
        'asr_end': '16:30',
        'maghrib': '18:15',
        'maghrib_end': '18:45',
        'nisful_layl': '23:30',
        'nisful_layl_end': '00:15',
      };

      final date = DateTime.now();
      const locationName = 'Test Location';
      
      final prayerTimes = PrayerTimes.fromMap(map, date, locationName);
      
      expect(prayerTimes.sihori, equals('04:30'));
      expect(prayerTimes.fajr, equals('05:15'));
      expect(prayerTimes.sunrise, equals('06:30'));
      expect(prayerTimes.zawaal, equals('12:15'));
      expect(prayerTimes.zohrEnd, equals('12:45'));
      expect(prayerTimes.asrEnd, equals('16:30'));
      expect(prayerTimes.maghrib, equals('18:15'));
      expect(prayerTimes.maghribEnd, equals('18:45'));
      expect(prayerTimes.nisfulLayl, equals('23:30'));
      expect(prayerTimes.nisfulLaylEnd, equals('00:15'));
      expect(prayerTimes.date, equals(date));
      expect(prayerTimes.locationName, equals(locationName));
    });

    test('should convert PrayerTimes to map', () {
      final date = DateTime.now();
      final prayerTimes = PrayerTimes(
        sihori: '04:30',
        fajr: '05:15',
        sunrise: '06:30',
        zawaal: '12:15',
        zohrEnd: '12:45',
        asrEnd: '16:30',
        maghrib: '18:15',
        maghribEnd: '18:45',
        nisfulLayl: '23:30',
        nisfulLaylEnd: '00:15',
        date: date,
        locationName: 'Test Location',
      );

      final map = prayerTimes.toMap();
      
      expect(map['sihori'], equals('04:30'));
      expect(map['fajr'], equals('05:15'));
      expect(map['sunrise'], equals('06:30'));
      expect(map['zawaal'], equals('12:15'));
      expect(map['zohr_end'], equals('12:45'));
      expect(map['asr_end'], equals('16:30'));
      expect(map['maghrib'], equals('18:15'));
      expect(map['maghrib_end'], equals('18:45'));
      expect(map['nisful_layl'], equals('23:30'));
      expect(map['nisful_layl_end'], equals('00:15'));
      expect(map['date'], equals(date.toIso8601String()));
      expect(map['location_name'], equals('Test Location'));
    });
  });
}