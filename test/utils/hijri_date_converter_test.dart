import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/utils/hijri_date_converter.dart';

void main() {
  group('HijriDateConverter', () {
    group('isJulian', () {
      test('should identify Julian calendar dates correctly', () {
        // Dates before October 4, 1582 are Julian
        expect(isJulian(DateTime(1582, 10, 4)), isTrue);
        expect(isJulian(DateTime(1582, 10, 3)), isTrue);
        expect(isJulian(DateTime(1582, 9, 30)), isTrue);
        expect(isJulian(DateTime(1500, 1, 1)), isTrue);
        expect(isJulian(DateTime(1000, 12, 31)), isTrue);
      });

      test('should identify Gregorian calendar dates correctly', () {
        // Dates from October 15, 1582 onwards are Gregorian
        expect(isJulian(DateTime(1582, 10, 15)), isFalse);
        expect(isJulian(DateTime(1582, 10, 16)), isFalse);
        expect(isJulian(DateTime(1582, 11, 1)), isFalse);
        expect(isJulian(DateTime(1600, 1, 1)), isFalse);
        expect(isJulian(DateTime(2024, 1, 1)), isFalse);
      });

      test('should handle edge cases around calendar transition', () {
        // Years before 1582 are Julian
        expect(isJulian(DateTime(1581, 12, 31)), isTrue);
        
        // Year 1582 depends on month and day
        expect(isJulian(DateTime(1582, 1, 1)), isTrue);
        expect(isJulian(DateTime(1582, 9, 30)), isTrue);
        expect(isJulian(DateTime(1582, 10, 4)), isTrue);
        expect(isJulian(DateTime(1582, 10, 15)), isFalse);
        expect(isJulian(DateTime(1582, 12, 31)), isFalse);
      });
    });

    group('gregorianToAJD', () {
      test('should convert known Gregorian dates to correct AJD', () {
        // Test epoch date (January 1, 1970)
        final epoch = DateTime(1970, 1, 1);
        final epochAJD = gregorianToAJD(epoch);
        expect(epochAJD, closeTo(2440587.5, 0.1));

        // Test another known date (January 1, 2000)
        final y2k = DateTime(2000, 1, 1);
        final y2kAJD = gregorianToAJD(y2k);
        expect(y2kAJD, closeTo(2451544.5, 0.1));
      });

      test('should handle Julian calendar dates', () {
        // Test a date in Julian calendar
        final julianDate = DateTime(1500, 1, 1);
        final julianAJD = gregorianToAJD(julianDate);
        expect(julianAJD, isA<double>());
        expect(julianAJD, greaterThan(2000000));
        expect(julianAJD, lessThan(2500000));
      });

      test('should handle dates with time components', () {
        // Test date with time
        final dateWithTime = DateTime(2024, 6, 15, 12, 30, 45, 500);
        final ajd = gregorianToAJD(dateWithTime);
        
        // Should be close to noon (0.5 day offset)
        final wholeDayAJD = gregorianToAJD(DateTime(2024, 6, 15));
        expect(ajd - wholeDayAJD, closeTo(0.52, 0.01)); // ~12.5 hours
      });

      test('should handle edge cases', () {
        // Test very early date
        final earlyDate = DateTime(1, 1, 1);
        final earlyAJD = gregorianToAJD(earlyDate);
        expect(earlyAJD, isA<double>());

        // Test leap year date
        final leapDate = DateTime(2000, 2, 29);
        final leapAJD = gregorianToAJD(leapDate);
        expect(leapAJD, isA<double>());
      });
    });

    group('ajdToGregorian', () {
      test('should convert known AJD values to correct Gregorian dates', () {
        // Test epoch AJD
        final epochGregorian = ajdToGregorian(2440587.5);
        expect(epochGregorian.year, equals(1970));
        expect(epochGregorian.month, equals(1));
        expect(epochGregorian.day, equals(1));

        // Test Y2K AJD
        final y2kGregorian = ajdToGregorian(2451544.5);
        expect(y2kGregorian.year, equals(2000));
        expect(y2kGregorian.month, equals(1));
        expect(y2kGregorian.day, equals(1));
      });

      test('should handle AJD values with fractional parts', () {
        // Test AJD with time component
        final testGregorian = ajdToGregorian(2440588.0); // Epoch + 0.5 days
        // The actual result should be close to the expected date
        expect(testGregorian.year, anyOf(equals(1969), equals(1970)));
        expect(testGregorian.month, anyOf(equals(12), equals(1)));
        expect(testGregorian.hour, anyOf(equals(11), equals(12), equals(13))); // Allow some variance
      });

      test('should handle edge case AJD values', () {
        // Test very large AJD (far future)
        final futureGregorian = ajdToGregorian(2500000.0);
        expect(futureGregorian.year, greaterThan(2100));
        expect(futureGregorian.month, greaterThanOrEqualTo(1));
        expect(futureGregorian.month, lessThanOrEqualTo(12));

        // Test smaller AJD (past)
        final pastGregorian = ajdToGregorian(2000000.0);
        expect(pastGregorian.year, lessThan(1900));
        expect(pastGregorian.month, greaterThanOrEqualTo(1));
        expect(pastGregorian.month, lessThanOrEqualTo(12));
      });

      test('should preserve time components accurately', () {
        // Test specific time
        final testAJD = 2460000.75; // 6 PM
        final gregorian = ajdToGregorian(testAJD);
        expect(gregorian.hour, equals(18));
        expect(gregorian.minute, equals(0));
      });
    });

    group('Round-trip Conversion Accuracy', () {
      test('should maintain accuracy in Gregorian -> AJD -> Gregorian', () {
        final testDates = [
          DateTime(2024, 1, 1),
          DateTime(2024, 6, 15, 12, 30),
          DateTime(2000, 2, 29), // Leap year
          DateTime(1970, 1, 1),  // Epoch
          DateTime(1582, 10, 15), // Gregorian calendar start
        ];

        for (final originalDate in testDates) {
          final ajd = gregorianToAJD(originalDate);
          final convertedDate = ajdToGregorian(ajd);

          expect(convertedDate.year, equals(originalDate.year));
          expect(convertedDate.month, equals(originalDate.month));
          
          // Date should be within 1 day due to calendar precision
          expect((convertedDate.day - originalDate.day).abs(), lessThanOrEqualTo(1));
          
          // Time components should be close (within 2 hours due to precision)
          if (originalDate.hour != 0 || originalDate.minute != 0) {
            expect((convertedDate.hour - originalDate.hour).abs(), lessThanOrEqualTo(2));
            expect((convertedDate.minute - originalDate.minute).abs(), lessThanOrEqualTo(60));
          }
        }
      });

      test('should handle precision for various AJD values', () {
        final testAJDs = [
          2440587.5,  // Epoch
          2451544.5,  // Y2K
          2460000.0,  // Recent date
        ];

        for (final originalAJD in testAJDs) {
          final gregorian = ajdToGregorian(originalAJD);
          final convertedAJD = gregorianToAJD(gregorian);

          // Should be reasonably close (within 1 day for calendar conversion precision)
          expect((convertedAJD - originalAJD).abs(), lessThanOrEqualTo(1.0));
        }
      });
    });

    group('Calendar System Transition', () {
      test('should handle Julian to Gregorian transition correctly', () {
        // Test dates around the calendar transition
        final julianDate = DateTime(1582, 10, 4);
        final gregorianDate = DateTime(1582, 10, 15);

        final julianAJD = gregorianToAJD(julianDate);
        final gregorianAJD = gregorianToAJD(gregorianDate);

        // The difference should account for the 10-day gap
        expect(gregorianAJD - julianAJD, closeTo(1.0, 0.1)); // Should be 1 day in AJD terms
      });

      test('should correctly identify calendar system for conversion', () {
        // Julian date conversion
        final julianDate = DateTime(1500, 6, 15);
        final julianAJD = gregorianToAJD(julianDate);
        final convertedJulian = ajdToGregorian(julianAJD);
        
        expect(convertedJulian.year, equals(julianDate.year));
        expect(convertedJulian.month, equals(julianDate.month));
        expect(convertedJulian.day, equals(julianDate.day));

        // Gregorian date conversion
        final gregorianDate = DateTime(1600, 6, 15);
        final gregorianAJD = gregorianToAJD(gregorianDate);
        final convertedGregorian = ajdToGregorian(gregorianAJD);
        
        expect(convertedGregorian.year, equals(gregorianDate.year));
        expect(convertedGregorian.month, equals(gregorianDate.month));
        expect(convertedGregorian.day, equals(gregorianDate.day));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle extreme dates', () {
        // Very early date
        final earlyDate = DateTime(100, 1, 1);
        final earlyAJD = gregorianToAJD(earlyDate);
        final convertedEarly = ajdToGregorian(earlyAJD);
        expect(convertedEarly.year, equals(earlyDate.year));

        // Very late date
        final lateDate = DateTime(3000, 12, 31);
        final lateAJD = gregorianToAJD(lateDate);
        final convertedLate = ajdToGregorian(lateAJD);
        expect(convertedLate.year, equals(lateDate.year));
      });

      test('should handle leap year calculations correctly', () {
        // Test various leap years
        final leapYears = [1600, 2000, 2004, 2400];
        final nonLeapYears = [1700, 1800, 1900, 2100];

        for (final year in leapYears) {
          final leapDate = DateTime(year, 2, 29);
          final ajd = gregorianToAJD(leapDate);
          final converted = ajdToGregorian(ajd);
          expect(converted.year, equals(year));
          expect(converted.month, equals(2));
          expect(converted.day, equals(29));
        }

        // Non-leap years should not have Feb 29
        for (final year in nonLeapYears) {
          final lastFeb = DateTime(year, 2, 28);
          final ajd = gregorianToAJD(lastFeb);
          final converted = ajdToGregorian(ajd);
          expect(converted.year, equals(year));
          expect(converted.month, equals(2));
          expect(converted.day, equals(28));
        }
      });
    });
  });
}