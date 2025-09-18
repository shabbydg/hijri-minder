import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/hijri_date.dart';

void main() {
  group('Night Sensitive Fix Tests', () {
    test('Night Sensitive should not create invalid dates', () {
      // Test the specific case mentioned in the issue
      final gregorianDate = DateTime(1991, 6, 12);
      final hijriDate = HijriDate.fromGregorian(gregorianDate);
      
      // Apply Night Sensitive using the new correct method
      final nightSensitiveDate = hijriDate.addDays(1);
      
      // Verify the result is valid
      expect(nightSensitiveDate.isValid(), isTrue, 
        reason: 'Night sensitive date should be valid');
      
      // Verify it doesn't exceed month boundaries
      final maxDaysInMonth = HijriDate.daysInMonth(
        nightSensitiveDate.year, 
        nightSensitiveDate.month
      );
      expect(nightSensitiveDate.day, lessThanOrEqualTo(maxDaysInMonth),
        reason: 'Day should not exceed maximum days in month');
      
      print('Original: ${hijriDate.day} ${HijriDate.getMonthName(hijriDate.month)} ${hijriDate.year}');
      print('Night Sensitive: ${nightSensitiveDate.day} ${HijriDate.getMonthName(nightSensitiveDate.month)} ${nightSensitiveDate.year}');
    });

    test('Jumada al-Ula month boundary should work correctly', () {
      // Test the last day of Jumada al-Ula in a Kabisa year
      final year = 1412; // Kabisa year
      final daysInJumadaUla = HijriDate.daysInMonth(year, 4); // Jumada al-Ula
      final lastDayJumadaUla = HijriDate(year, 4, daysInJumadaUla);
      
      // Apply Night Sensitive
      final nextDay = lastDayJumadaUla.addDays(1);
      
      // Should move to Jumada al-Ukhra (month 5)
      expect(nextDay.month, equals(5), 
        reason: 'Should move to Jumada al-Ukhra');
      expect(nextDay.day, equals(1), 
        reason: 'Should be the 1st day of next month');
      expect(nextDay.year, equals(year), 
        reason: 'Year should remain the same');
      
      print('Last day Jumada al-Ula: ${lastDayJumadaUla.day} ${HijriDate.getMonthName(lastDayJumadaUla.month)} ${lastDayJumadaUla.year}');
      print('Next day: ${nextDay.day} ${HijriDate.getMonthName(nextDay.month)} ${nextDay.year}');
    });

    test('Year boundary should work correctly', () {
      // Test the last day of Zilhaj in a Kabisa year
      final year = 1412; // Kabisa year
      final daysInZilhaj = HijriDate.daysInMonth(year, 11); // Zilhaj
      final lastDayZilhaj = HijriDate(year, 11, daysInZilhaj);
      
      // Apply Night Sensitive
      final nextDay = lastDayZilhaj.addDays(1);
      
      // Should move to next year, Moharram
      expect(nextDay.year, equals(year + 1), 
        reason: 'Should move to next year');
      expect(nextDay.month, equals(0), 
        reason: 'Should move to Moharram');
      expect(nextDay.day, equals(1), 
        reason: 'Should be the 1st day of next year');
      
      print('Last day Zilhaj: ${lastDayZilhaj.day} ${HijriDate.getMonthName(lastDayZilhaj.month)} ${lastDayZilhaj.year}');
      print('Next day: ${nextDay.day} ${HijriDate.getMonthName(nextDay.month)} ${nextDay.year}');
    });

    test('Broken implementation comparison', () {
      // Test various edge cases where the broken implementation would fail
      final testCases = [
        HijriDate(1412, 4, 30), // Last day of Jumada al-Ula (30 days in Kabisa year)
        HijriDate(1413, 4, 29), // Last day of Jumada al-Ula (29 days in non-Kabisa year)
        HijriDate(1412, 1, 29), // Last day of Safar (29 days)
        HijriDate(1412, 11, 30), // Last day of Zilhaj in Kabisa year (30 days)
      ];
      
      for (final testDate in testCases) {
        // Correct implementation
        final correctNextDay = testDate.addDays(1);
        
        // Broken implementation (what it used to do)
        final brokenNextDay = HijriDate(testDate.year, testDate.month, testDate.day + 1);
        
        // Verify correct implementation is valid
        expect(correctNextDay.isValid(), isTrue,
          reason: 'Correct implementation should produce valid date for ${testDate.day} ${HijriDate.getMonthName(testDate.month)} ${testDate.year}');
        
        // Verify broken implementation is invalid (for edge cases)
        if (testDate.day == HijriDate.daysInMonth(testDate.year, testDate.month)) {
          expect(brokenNextDay.isValid(), isFalse,
            reason: 'Broken implementation should produce invalid date for ${testDate.day} ${HijriDate.getMonthName(testDate.month)} ${testDate.year}');
        }
        
        print('Test: ${testDate.day} ${HijriDate.getMonthName(testDate.month)} ${testDate.year}');
        print('  Correct: ${correctNextDay.day} ${HijriDate.getMonthName(correctNextDay.month)} ${correctNextDay.year} (valid: ${correctNextDay.isValid()})');
        print('  Broken:  ${brokenNextDay.day} ${HijriDate.getMonthName(brokenNextDay.month)} ${brokenNextDay.year} (valid: ${brokenNextDay.isValid()})');
      }
    });

    test('addDays should handle multiple days correctly', () {
      final startDate = HijriDate(1412, 4, 28); // 28 Jumada al-Ula
      
      // Add 1 day - should stay in same month
      final plus1 = startDate.addDays(1);
      expect(plus1.month, equals(4));
      expect(plus1.day, equals(29));
      
      // Add 2 days - should stay in same month (Jumada al-Ula has 30 days in 1412)
      final plus2 = startDate.addDays(2);
      expect(plus2.month, equals(4));
      expect(plus2.day, equals(30));
      
      // Add 3 days - should move to next month
      final plus3 = startDate.addDays(3);
      expect(plus3.month, equals(5)); // Jumada al-Ukhra
      expect(plus3.day, equals(1));
      
      print('Start: ${startDate.day} ${HijriDate.getMonthName(startDate.month)} ${startDate.year}');
      print('+1 day: ${plus1.day} ${HijriDate.getMonthName(plus1.month)} ${plus1.year}');
      print('+2 days: ${plus2.day} ${HijriDate.getMonthName(plus2.month)} ${plus2.year}');
      print('+3 days: ${plus3.day} ${HijriDate.getMonthName(plus3.month)} ${plus3.year}');
    });
  });
}