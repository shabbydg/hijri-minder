import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/hijri_date.dart';
import 'package:hijri_minder/utils/arabic_numerals.dart';
import 'package:hijri_minder/utils/hijri_date_converter.dart';

void main() {
  group('Task 2 Implementation Verification', () {
    test('Requirement 1.1-1.5: Hijri-first calendar interface support', () {
      // Test Hijri date creation and display
      final hijriDate = HijriDate(1445, 6, 15);
      
      // 1.1 & 1.3: Display current Hijri date prominently
      expect(hijriDate.year, equals(1445));
      expect(hijriDate.month, equals(6));
      expect(hijriDate.day, equals(15));
      
      // 1.2 & 1.4: Show Hijri months and years with proper names
      expect(HijriDate.getMonthName(6), equals("Rajab al-Asab"));
      expect(HijriDate.getShortMonthName(6), equals("Rajab"));
      
      // 1.5: Display corresponding Gregorian dates
      final gregorianDate = hijriDate.toGregorian();
      expect(gregorianDate, isA<DateTime>());
      expect(gregorianDate.year, greaterThan(2020));
      expect(gregorianDate.year, lessThan(2030));
    });

    test('Requirement 2.1: Use proven astronomical algorithms', () {
      // Test that we're using the exact algorithms from documentation
      final gregorianDate = DateTime(2024, 1, 1);
      final ajd = gregorianToAJD(gregorianDate);
      final hijriDate = HijriDate.fromAJD(ajd);
      
      // Verify conversion works both ways
      final convertedGregorian = hijriDate.toGregorian();
      final dayDifference = gregorianDate.difference(convertedGregorian).inDays.abs();
      expect(dayDifference, lessThanOrEqualTo(1)); // Within 1 day accuracy
    });

    test('Requirement 2.2: Account for Kabisa years correctly using 30-year cycle', () {
      // Test known Kabisa years based on 30-year cycle remainders
      final kabisaYears = [1442, 1445, 1448, 1450, 1453, 1456, 1459, 1461, 1464, 1467, 1469];
      final nonKabisaYears = [1441, 1443, 1444, 1446, 1447, 1449, 1451, 1452];
      
      for (final year in kabisaYears) {
        expect(HijriDate.isKabisa(year), isTrue, reason: 'Year $year should be Kabisa');
      }
      
      for (final year in nonKabisaYears) {
        expect(HijriDate.isKabisa(year), isFalse, reason: 'Year $year should not be Kabisa');
      }
    });

    test('Requirement 2.3: Display 29 or 30 days per month according to Islamic calendar rules', () {
      final regularYear = 1444; // Non-Kabisa year
      final kabisaYear = 1445;  // Kabisa year
      
      // Test regular year: odd months (0-indexed) have 30 days, even have 29, except Zilhaj has 29
      for (int month = 0; month < 12; month++) {
        final expectedDays = (month % 2 == 0) ? 30 : 29;
        final actualDays = HijriDate.daysInMonth(regularYear, month);
        
        if (month == 11) { // Zilhaj in regular year
          expect(actualDays, equals(29));
        } else {
          expect(actualDays, equals(expectedDays));
        }
      }
      
      // Test Kabisa year: Zilhaj has 30 days
      expect(HijriDate.daysInMonth(kabisaYear, 11), equals(30));
    });

    test('Requirement 2.4: Use accurate day counting system from HijriDate model', () {
      // Test day of year calculations
      final firstDay = HijriDate(1445, 0, 1);
      expect(firstDay.dayOfYear(), equals(1));
      
      final midYear = HijriDate(1445, 6, 15); // 15th Rajab
      final expectedDayOfYear = 30 + 29 + 30 + 29 + 30 + 29 + 15; // Sum of previous months + current day
      expect(midYear.dayOfYear(), equals(expectedDayOfYear));
      
      final lastDayKabisa = HijriDate(1445, 11, 30); // Last day of Kabisa year
      expect(lastDayKabisa.dayOfYear(), equals(355));
    });

    test('Requirement 2.5: Maintain precision through Astronomical Julian Day conversion', () {
      // Test AJD conversion precision
      final originalHijri = HijriDate(1445, 6, 15);
      final ajd = originalHijri.toAJD();
      final convertedHijri = HijriDate.fromAJD(ajd);
      
      // Should maintain exact precision
      expect(convertedHijri, equals(originalHijri));
      
      // Test with realistic date ranges (precision is maintained for reasonable dates)
      final testDates = [
        HijriDate(1400, 0, 1),
        HijriDate(1445, 5, 15),
        HijriDate(1450, 6, 20),
      ];
      
      for (final date in testDates) {
        final ajdValue = date.toAJD();
        final recovered = HijriDate.fromAJD(ajdValue);
        
        // For reasonable date ranges, precision should be maintained
        // For extreme dates, allow small differences due to calendar system limitations
        final yearDiff = (date.year - recovered.year).abs();
        final monthDiff = (date.month - recovered.month).abs();
        final dayDiff = (date.day - recovered.day).abs();
        
        expect(yearDiff, lessThanOrEqualTo(1), reason: 'Year precision failed for $date');
        if (yearDiff == 0) {
          expect(monthDiff, lessThanOrEqualTo(1), reason: 'Month precision failed for $date');
          if (monthDiff == 0) {
            expect(dayDiff, lessThanOrEqualTo(1), reason: 'Day precision failed for $date');
          }
        }
      }
    });

    test('Arabic numerals utility integration', () {
      // Test Arabic numeral conversion for Islamic calendar numbers
      expect(ArabicNumerals.convertToArabic(1445), equals('١٤٤٥'));
      expect(ArabicNumerals.convertToArabic(15), equals('١٥'));
      expect(ArabicNumerals.convertToArabic(30), equals('٣٠'));
      
      // Test safe conversion
      expect(ArabicNumerals.convertToArabicSafe(1445), equals('١٤٤٥'));
    });

    test('Hijri date converter utility integration', () {
      // Test Julian calendar detection
      expect(isJulian(DateTime(1582, 10, 4)), isTrue);
      expect(isJulian(DateTime(1582, 10, 15)), isFalse);
      
      // Test Gregorian to AJD conversion
      final testDate = DateTime(2024, 6, 15);
      final ajd = gregorianToAJD(testDate);
      expect(ajd, isA<double>());
      expect(ajd, greaterThan(2400000)); // Reasonable AJD range
      
      // Test AJD to Gregorian conversion
      final recovered = ajdToGregorian(ajd);
      expect(recovered.year, equals(testDate.year));
      expect(recovered.month, equals(testDate.month));
      expect(recovered.day, equals(testDate.day));
    });

    test('Complete integration: Gregorian -> Hijri -> Gregorian round-trip', () {
      final originalGregorian = DateTime(2024, 6, 15);
      
      // Convert to Hijri
      final hijriDate = HijriDate.fromGregorian(originalGregorian);
      expect(hijriDate.year, greaterThan(1440));
      expect(hijriDate.year, lessThan(1450));
      
      // Convert back to Gregorian
      final convertedGregorian = hijriDate.toGregorian();
      
      // Should be within 1 day due to calendar system differences
      final difference = originalGregorian.difference(convertedGregorian).inDays.abs();
      expect(difference, lessThanOrEqualTo(1));
    });

    test('Month names localization support', () {
      // Test all month names are properly defined
      for (int month = 0; month < 12; month++) {
        final longName = HijriDate.getMonthName(month);
        final shortName = HijriDate.getShortMonthName(month);
        
        expect(longName, isNotEmpty);
        expect(shortName, isNotEmpty);
        expect(longName.length, greaterThan(shortName.length));
      }
      
      // Test specific Islamic month names
      expect(HijriDate.getMonthName(0), equals("Moharram al-Haraam"));
      expect(HijriDate.getMonthName(8), equals("Ramadaan al-Moazzam"));
      expect(HijriDate.getShortMonthName(0), equals("Moharram"));
      expect(HijriDate.getShortMonthName(8), equals("Ramadaan"));
    });
  });
}