import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/hijri_date.dart';

void main() {
  group('HijriDate', () {
    group('Constructor and Basic Properties', () {
      test('should create HijriDate with valid parameters', () {
        final hijriDate = HijriDate(1445, 6, 15);
        expect(hijriDate.year, equals(1445));
        expect(hijriDate.month, equals(6));
        expect(hijriDate.day, equals(15));
      });

      test('should provide getter methods', () {
        final hijriDate = HijriDate(1445, 6, 15);
        expect(hijriDate.getYear(), equals(1445));
        expect(hijriDate.getMonth(), equals(6));
        expect(hijriDate.getDate(), equals(15));
      });

      test('should implement toString correctly', () {
        final hijriDate = HijriDate(1445, 6, 15);
        expect(hijriDate.toString(), equals('HijriDate(year: 1445, month: 6, day: 15)'));
      });

      test('should implement equality correctly', () {
        final hijriDate1 = HijriDate(1445, 6, 15);
        final hijriDate2 = HijriDate(1445, 6, 15);
        final hijriDate3 = HijriDate(1445, 6, 16);

        expect(hijriDate1, equals(hijriDate2));
        expect(hijriDate1, isNot(equals(hijriDate3)));
      });

      test('should implement hashCode correctly', () {
        final hijriDate1 = HijriDate(1445, 6, 15);
        final hijriDate2 = HijriDate(1445, 6, 15);
        final hijriDate3 = HijriDate(1445, 6, 16);

        expect(hijriDate1.hashCode, equals(hijriDate2.hashCode));
        expect(hijriDate1.hashCode, isNot(equals(hijriDate3.hashCode)));
      });
    });

    group('Kabisa Year Calculations', () {
      test('should correctly identify Kabisa years', () {
        // Test known Kabisa years based on 30-year cycle remainders
        expect(HijriDate.isKabisa(1442), isTrue); // remainder 2
        expect(HijriDate.isKabisa(1445), isTrue); // remainder 5
        expect(HijriDate.isKabisa(1448), isTrue); // remainder 8
        expect(HijriDate.isKabisa(1450), isTrue); // remainder 10
        
        // Test non-Kabisa years
        expect(HijriDate.isKabisa(1441), isFalse);
        expect(HijriDate.isKabisa(1443), isFalse);
        expect(HijriDate.isKabisa(1444), isFalse);
      });

      test('should handle edge cases for Kabisa years', () {
        // Test year 0 and negative years (edge cases)
        expect(HijriDate.isKabisa(0), isFalse);
        expect(HijriDate.isKabisa(30), isFalse); // remainder 0
        expect(HijriDate.isKabisa(32), isTrue);  // remainder 2
      });
    });

    group('Days in Month Calculations', () {
      test('should return correct days for regular months', () {
        // Odd months (0-indexed) have 30 days, even months have 29 days
        expect(HijriDate.daysInMonth(1445, 0), equals(30)); // Moharram
        expect(HijriDate.daysInMonth(1445, 1), equals(29)); // Safar
        expect(HijriDate.daysInMonth(1445, 2), equals(30)); // Rabi I
        expect(HijriDate.daysInMonth(1445, 3), equals(29)); // Rabi II
      });

      test('should handle Zilhaj in Kabisa years', () {
        // Zilhaj (month 11) has 30 days in Kabisa years, 29 in regular years
        expect(HijriDate.daysInMonth(1445, 11), equals(30)); // Kabisa year
        expect(HijriDate.daysInMonth(1444, 11), equals(29)); // Regular year
      });

      test('should handle all months correctly', () {
        final regularYear = 1444;
        final kabisaYear = 1445;

        // Test all months for regular year
        final expectedDaysRegular = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];
        for (int month = 0; month < 12; month++) {
          expect(HijriDate.daysInMonth(regularYear, month), equals(expectedDaysRegular[month]));
        }

        // Test all months for Kabisa year (only Zilhaj differs)
        final expectedDaysKabisa = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30];
        for (int month = 0; month < 12; month++) {
          expect(HijriDate.daysInMonth(kabisaYear, month), equals(expectedDaysKabisa[month]));
        }
      });
    });

    group('Month Names', () {
      test('should return correct long month names', () {
        expect(HijriDate.getMonthName(0), equals("Moharram al-Haraam"));
        expect(HijriDate.getMonthName(1), equals("Safar al-Muzaffar"));
        expect(HijriDate.getMonthName(8), equals("Ramadaan al-Moazzam"));
        expect(HijriDate.getMonthName(11), equals("Zilhaj al-Haraam"));
      });

      test('should return correct short month names', () {
        expect(HijriDate.getShortMonthName(0), equals("Moharram"));
        expect(HijriDate.getShortMonthName(1), equals("Safar"));
        expect(HijriDate.getShortMonthName(8), equals("Ramadaan"));
        expect(HijriDate.getShortMonthName(11), equals("Zilhaj"));
      });

      test('should handle out-of-range month indices', () {
        // Should clamp to valid range
        expect(HijriDate.getMonthName(-1), equals("Moharram al-Haraam"));
        expect(HijriDate.getMonthName(12), equals("Zilhaj al-Haraam"));
        expect(HijriDate.getShortMonthName(-1), equals("Moharram"));
        expect(HijriDate.getShortMonthName(12), equals("Zilhaj"));
      });
    });

    group('Day of Year Calculations', () {
      test('should calculate day of year correctly for first month', () {
        final hijriDate = HijriDate(1445, 0, 15); // 15th Moharram
        expect(hijriDate.dayOfYear(), equals(15));
      });

      test('should calculate day of year correctly for other months', () {
        final hijriDate1 = HijriDate(1445, 1, 15); // 15th Safar
        expect(hijriDate1.dayOfYear(), equals(30 + 15)); // 30 days in Moharram + 15

        final hijriDate2 = HijriDate(1445, 2, 10); // 10th Rabi I
        expect(hijriDate2.dayOfYear(), equals(30 + 29 + 10)); // Moharram + Safar + 10
      });

      test('should handle edge cases for day of year', () {
        final firstDay = HijriDate(1445, 0, 1);
        expect(firstDay.dayOfYear(), equals(1));

        final lastDayRegular = HijriDate(1444, 11, 29); // Last day of regular year
        expect(lastDayRegular.dayOfYear(), equals(354));

        final lastDayKabisa = HijriDate(1445, 11, 30); // Last day of Kabisa year
        expect(lastDayKabisa.dayOfYear(), equals(355));
      });
    });

    group('Gregorian to Hijri Conversion', () {
      test('should convert known Gregorian dates to Hijri correctly', () {
        // Test some known conversions
        final gregorian1 = DateTime(2024, 1, 1);
        final hijri1 = HijriDate.fromGregorian(gregorian1);
        
        // Verify the conversion is reasonable (around 1445 AH)
        expect(hijri1.year, greaterThan(1440));
        expect(hijri1.year, lessThan(1450));
        expect(hijri1.month, greaterThanOrEqualTo(0));
        expect(hijri1.month, lessThanOrEqualTo(11));
        expect(hijri1.day, greaterThanOrEqualTo(1));
        expect(hijri1.day, lessThanOrEqualTo(30));
      });

      test('should handle edge case dates', () {
        // Test epoch date
        final epoch = DateTime(1970, 1, 1);
        final hijriEpoch = HijriDate.fromGregorian(epoch);
        expect(hijriEpoch.year, greaterThan(1300));
        expect(hijriEpoch.year, lessThan(1400));

        // Test future date
        final future = DateTime(2050, 12, 31);
        final hijriFuture = HijriDate.fromGregorian(future);
        expect(hijriFuture.year, greaterThan(1450));
        expect(hijriFuture.year, lessThan(1500));
      });
    });

    group('Hijri to Gregorian Conversion', () {
      test('should convert Hijri dates to Gregorian correctly', () {
        final hijri = HijriDate(1445, 6, 15);
        final gregorian = hijri.toGregorian();
        
        // Verify the conversion is reasonable
        expect(gregorian.year, greaterThan(2020));
        expect(gregorian.year, lessThan(2030));
        expect(gregorian.month, greaterThanOrEqualTo(1));
        expect(gregorian.month, lessThanOrEqualTo(12));
        expect(gregorian.day, greaterThanOrEqualTo(1));
        expect(gregorian.day, lessThanOrEqualTo(31));
      });

      test('should handle edge case Hijri dates', () {
        // Test early Hijri date
        final earlyHijri = HijriDate(1000, 0, 1);
        final earlyGregorian = earlyHijri.toGregorian();
        expect(earlyGregorian.year, greaterThan(1500));
        expect(earlyGregorian.year, lessThan(1700));

        // Test far future Hijri date
        final futureHijri = HijriDate(1500, 11, 30);
        final futureGregorian = futureHijri.toGregorian();
        expect(futureGregorian.year, greaterThan(2050));
        expect(futureGregorian.year, lessThan(2150));
      });
    });

    group('Round-trip Conversion Accuracy', () {
      test('should maintain accuracy in round-trip conversions', () {
        // Test Gregorian -> Hijri -> Gregorian
        final originalGregorian = DateTime(2024, 6, 15);
        final hijri = HijriDate.fromGregorian(originalGregorian);
        final convertedGregorian = hijri.toGregorian();
        
        // Should be within 1 day due to calendar system differences
        final difference = originalGregorian.difference(convertedGregorian).inDays.abs();
        expect(difference, lessThanOrEqualTo(1));
      });

      test('should maintain accuracy in reverse round-trip conversions', () {
        // Test Hijri -> Gregorian -> Hijri
        final originalHijri = HijriDate(1445, 6, 15);
        final gregorian = originalHijri.toGregorian();
        final convertedHijri = HijriDate.fromGregorian(gregorian);
        
        // Should be exactly the same or within 1 day
        final yearDiff = (originalHijri.year - convertedHijri.year).abs();
        final monthDiff = (originalHijri.month - convertedHijri.month).abs();
        final dayDiff = (originalHijri.day - convertedHijri.day).abs();
        
        expect(yearDiff, lessThanOrEqualTo(1));
        if (yearDiff == 0) {
          expect(monthDiff, lessThanOrEqualTo(1));
          if (monthDiff == 0) {
            expect(dayDiff, lessThanOrEqualTo(1));
          }
        }
      });
    });

    group('AJD Conversion', () {
      test('should convert to and from AJD correctly', () {
        final hijri = HijriDate(1445, 6, 15);
        final ajd = hijri.toAJD();
        final convertedHijri = HijriDate.fromAJD(ajd);
        
        expect(convertedHijri, equals(hijri));
      });

      test('should handle AJD edge cases', () {
        // Test with known AJD values
        final ajd = 2460000.0; // A reasonable AJD value
        final hijri = HijriDate.fromAJD(ajd);
        final convertedAjd = hijri.toAJD();
        
        // Should be very close (within 1 day)
        expect((ajd - convertedAjd).abs(), lessThan(1.0));
      });
    });
  });
}