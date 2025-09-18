import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/hijri_date.dart';

void main() {
  group('HijriDate Night Sensitive Tests', () {
    test('addDays should handle month overflow correctly', () {
      // Test case: 30 Jumada al-Ula 1412 + 1 day should become 1 Jumada al-Ukhra 1412
      // Jumada al-Ula (month 4) has 30 days in year 1412 (Kabisa year)
      final hijriDate = HijriDate(1412, 4, 30); // 30 Jumada al-Ula 1412
      final nextDay = hijriDate.addDays(1);
      
      expect(nextDay.year, equals(1412));
      expect(nextDay.month, equals(5)); // Jumada al-Ukhra
      expect(nextDay.day, equals(1));
    });

    test('addDays should handle year overflow correctly', () {
      // Test case: 30 Zilhaj 1412 + 1 day should become 1 Moharram 1413
      // 1412 is a Kabisa year, so Zilhaj has 30 days
      final hijriDate = HijriDate(1412, 11, 30); // 30 Zilhaj 1412
      final nextDay = hijriDate.addDays(1);
      
      expect(nextDay.year, equals(1413));
      expect(nextDay.month, equals(0)); // Moharram
      expect(nextDay.day, equals(1));
    });

    test('addDays should handle leap year correctly', () {
      // Test case: In a Kabisa year, Zilhaj has 30 days
      // Check if year 1413 is Kabisa
      final isKabisa1413 = HijriDate.isKabisa(1413);
      
      if (isKabisa1413) {
        final hijriDate = HijriDate(1413, 11, 30); // 30 Zilhaj 1413 (Kabisa year)
        final nextDay = hijriDate.addDays(1);
        
        expect(nextDay.year, equals(1414));
        expect(nextDay.month, equals(0)); // Moharram
        expect(nextDay.day, equals(1));
      } else {
        final hijriDate = HijriDate(1413, 11, 29); // 29 Zilhaj 1413 (non-Kabisa year)
        final nextDay = hijriDate.addDays(1);
        
        expect(nextDay.year, equals(1414));
        expect(nextDay.month, equals(0)); // Moharram
        expect(nextDay.day, equals(1));
      }
    });

    test('Night Sensitive scenario - 6/12/1991 should not result in invalid date', () {
      // This is the specific case mentioned in the issue
      final gregorianDate = DateTime(1991, 6, 12);
      final hijriDate = HijriDate.fromGregorian(gregorianDate);
      final nightSensitiveDate = hijriDate.addDays(1);
      
      // Verify the date is valid
      expect(nightSensitiveDate.isValid(), isTrue);
      
      // Verify it doesn't exceed month limits
      final maxDaysInMonth = HijriDate.daysInMonth(nightSensitiveDate.year, nightSensitiveDate.month);
      expect(nightSensitiveDate.day, lessThanOrEqualTo(maxDaysInMonth));
      
      print('Original Gregorian: ${gregorianDate.day}/${gregorianDate.month}/${gregorianDate.year}');
      print('Original Hijri: ${hijriDate.day} ${HijriDate.getMonthName(hijriDate.month)} ${hijriDate.year}');
      print('Night Sensitive Hijri: ${nightSensitiveDate.day} ${HijriDate.getMonthName(nightSensitiveDate.month)} ${nightSensitiveDate.year}');
    });

    test('daysInMonth should return correct values', () {
      // Test various months and years (1412 is a Kabisa year)
      expect(HijriDate.daysInMonth(1412, 0), equals(30)); // Moharram - 30 days
      expect(HijriDate.daysInMonth(1412, 1), equals(29)); // Safar - 29 days
      expect(HijriDate.daysInMonth(1412, 4), equals(30)); // Jumada al-Ula - 30 days (even month)
      expect(HijriDate.daysInMonth(1412, 5), equals(29)); // Jumada al-Ukhra - 29 days (odd month)
      
      // Test Zilhaj in Kabisa vs non-Kabisa years
      final isKabisa1412 = HijriDate.isKabisa(1412);
      final expectedZilhajDays = isKabisa1412 ? 30 : 29;
      expect(HijriDate.daysInMonth(1412, 11), equals(expectedZilhajDays));
    });

    test('isValid should correctly identify invalid dates', () {
      // Valid dates
      expect(HijriDate(1412, 4, 29).isValid(), isTrue);
      expect(HijriDate(1412, 5, 30).isValid(), isTrue);
      
      // Invalid dates
      expect(HijriDate(1412, 4, 31).isValid(), isFalse); // Jumada al-Ula only has 29 days
      expect(HijriDate(1412, 1, 30).isValid(), isFalse); // Safar only has 29 days
      expect(HijriDate(1412, -1, 15).isValid(), isFalse); // Invalid month
      expect(HijriDate(1412, 12, 15).isValid(), isFalse); // Invalid month
      expect(HijriDate(1412, 5, 0).isValid(), isFalse); // Invalid day
    });

    test('addDays with multiple days should work correctly', () {
      final hijriDate = HijriDate(1412, 4, 25); // 25 Jumada al-Ula 1412
      final futureDate = hijriDate.addDays(10);
      
      // Should be valid
      expect(futureDate.isValid(), isTrue);
      
      // Should handle month overflow if necessary
      final maxDaysInMonth = HijriDate.daysInMonth(futureDate.year, futureDate.month);
      expect(futureDate.day, lessThanOrEqualTo(maxDaysInMonth));
    });

    test('subtractDays should work correctly', () {
      final hijriDate = HijriDate(1412, 5, 5); // 5 Jumada al-Ukhra 1412
      final pastDate = hijriDate.subtractDays(10);
      
      // Should be valid
      expect(pastDate.isValid(), isTrue);
      
      // Should handle month underflow correctly
      expect(pastDate.month, lessThan(hijriDate.month));
    });
  });
}