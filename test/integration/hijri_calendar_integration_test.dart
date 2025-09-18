import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/hijri_calendar.dart';
import 'package:hijri_minder/models/hijri_date.dart';

void main() {
  group('HijriCalendar Integration Tests', () {
    test('should integrate properly with HijriDate model', () {
      final calendar = HijriCalendar(1445, 8); // Ramadan 1445
      final days = calendar.days();
      
      // Verify that all generated days have valid HijriDate objects
      for (final day in days) {
        final hijriDate = day['hijriDate'] as HijriDate;
        final gregorianDate = day['gregorianDate'] as DateTime;
        
        // Verify conversion consistency
        final convertedGregorian = hijriDate.toGregorian();
        expect(convertedGregorian.year, equals(gregorianDate.year));
        expect(convertedGregorian.month, equals(gregorianDate.month));
        expect(convertedGregorian.day, equals(gregorianDate.day));
        
        // Verify reverse conversion
        final convertedHijri = HijriDate.fromGregorian(gregorianDate);
        expect(convertedHijri.year, equals(hijriDate.year));
        expect(convertedHijri.month, equals(hijriDate.month));
        expect(convertedHijri.day, equals(hijriDate.day));
      }
    });

    test('should handle month boundaries correctly with HijriDate', () {
      final calendar = HijriCalendar(1445, 8); // Ramadan 1445
      final weeks = calendar.weeks();
      
      DateTime? lastDate;
      for (final week in weeks) {
        for (final day in week) {
          if (day != null) {
            final gregorianDate = day['gregorianDate'] as DateTime;
            if (lastDate != null) {
              // Verify chronological order
              expect(
                gregorianDate.isAfter(lastDate) || gregorianDate.isAtSameMomentAs(lastDate), 
                isTrue,
                reason: 'Dates should be in chronological order'
              );
            }
            lastDate = gregorianDate;
          }
        }
      }
    });

    test('should correctly identify Kabisa years using HijriDate logic', () {
      // Test with known Kabisa year
      final kabisaYear = 1445;
      if (HijriDate.isKabisa(kabisaYear)) {
        final zilhajCalendar = HijriCalendar(kabisaYear, 11); // Zilhaj
        final days = zilhajCalendar.days();
        
        // Kabisa year Zilhaj should have 30 days
        expect(days.length, equals(30));
        
        // Verify last day is 30th
        final lastDay = days.last['hijriDate'] as HijriDate;
        expect(lastDay.day, equals(30));
      }
    });

    test('should handle year transitions correctly', () {
      final decemberCalendar = HijriCalendar(1445, 11); // Zilhaj 1445
      final nextMonth = decemberCalendar.nextMonth(); // Should be Moharram 1446
      
      expect(nextMonth.getYear(), equals(1446));
      expect(nextMonth.getMonth(), equals(0)); // Moharram
      
      // Verify the first day of next year
      final firstDayOfNewYear = nextMonth.days().first['hijriDate'] as HijriDate;
      expect(firstDayOfNewYear.year, equals(1446));
      expect(firstDayOfNewYear.month, equals(0));
      expect(firstDayOfNewYear.day, equals(1));
    });

    test('should maintain date accuracy across navigation', () {
      final originalCalendar = HijriCalendar(1445, 6); // Rajab 1445
      
      // Navigate forward and back
      final nextMonth = originalCalendar.nextMonth();
      final backToOriginal = nextMonth.previousMonth();
      
      expect(backToOriginal.getYear(), equals(originalCalendar.getYear()));
      expect(backToOriginal.getMonth(), equals(originalCalendar.getMonth()));
      
      // Verify days are identical
      final originalDays = originalCalendar.days();
      final backDays = backToOriginal.days();
      
      expect(originalDays.length, equals(backDays.length));
      
      for (int i = 0; i < originalDays.length; i++) {
        final originalHijri = originalDays[i]['hijriDate'] as HijriDate;
        final backHijri = backDays[i]['hijriDate'] as HijriDate;
        
        expect(originalHijri.year, equals(backHijri.year));
        expect(originalHijri.month, equals(backHijri.month));
        expect(originalHijri.day, equals(backHijri.day));
      }
    });
  });
}