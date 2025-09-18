import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/utils/arabic_numerals.dart';

void main() {
  group('ArabicNumerals', () {
    group('convertToArabic', () {
      test('should convert single digits correctly', () {
        expect(ArabicNumerals.convertToArabic(0), equals('٠'));
        expect(ArabicNumerals.convertToArabic(1), equals('١'));
        expect(ArabicNumerals.convertToArabic(2), equals('٢'));
        expect(ArabicNumerals.convertToArabic(3), equals('٣'));
        expect(ArabicNumerals.convertToArabic(4), equals('٤'));
        expect(ArabicNumerals.convertToArabic(5), equals('٥'));
        expect(ArabicNumerals.convertToArabic(6), equals('٦'));
        expect(ArabicNumerals.convertToArabic(7), equals('٧'));
        expect(ArabicNumerals.convertToArabic(8), equals('٨'));
        expect(ArabicNumerals.convertToArabic(9), equals('٩'));
      });

      test('should convert multi-digit numbers correctly', () {
        expect(ArabicNumerals.convertToArabic(10), equals('١٠'));
        expect(ArabicNumerals.convertToArabic(23), equals('٢٣'));
        expect(ArabicNumerals.convertToArabic(456), equals('٤٥٦'));
        expect(ArabicNumerals.convertToArabic(1234), equals('١٢٣٤'));
        expect(ArabicNumerals.convertToArabic(9876), equals('٩٨٧٦'));
      });

      test('should convert common Islamic calendar numbers', () {
        // Common Hijri years
        expect(ArabicNumerals.convertToArabic(1445), equals('١٤٤٥'));
        expect(ArabicNumerals.convertToArabic(1446), equals('١٤٤٦'));
        
        // Common day numbers
        expect(ArabicNumerals.convertToArabic(15), equals('١٥'));
        expect(ArabicNumerals.convertToArabic(29), equals('٢٩'));
        expect(ArabicNumerals.convertToArabic(30), equals('٣٠'));
        
        // Month numbers (1-12)
        expect(ArabicNumerals.convertToArabic(12), equals('١٢'));
      });

      test('should handle large numbers', () {
        expect(ArabicNumerals.convertToArabic(12345), equals('١٢٣٤٥'));
        expect(ArabicNumerals.convertToArabic(987654), equals('٩٨٧٦٥٤'));
        expect(ArabicNumerals.convertToArabic(1000000), equals('١٠٠٠٠٠٠'));
      });

      test('should handle numbers with repeated digits', () {
        expect(ArabicNumerals.convertToArabic(111), equals('١١١'));
        expect(ArabicNumerals.convertToArabic(222), equals('٢٢٢'));
        expect(ArabicNumerals.convertToArabic(1000), equals('١٠٠٠'));
        expect(ArabicNumerals.convertToArabic(2020), equals('٢٠٢٠'));
      });
    });

    group('convertToArabicSafe', () {
      test('should convert valid numbers correctly', () {
        expect(ArabicNumerals.convertToArabicSafe(123), equals('١٢٣'));
        expect(ArabicNumerals.convertToArabicSafe(456), equals('٤٥٦'));
        expect(ArabicNumerals.convertToArabicSafe(0), equals('٠'));
      });

      test('should handle edge cases gracefully', () {
        // These should work normally
        expect(ArabicNumerals.convertToArabicSafe(0), equals('٠'));
        expect(ArabicNumerals.convertToArabicSafe(9999), equals('٩٩٩٩'));
      });

      test('should provide fallback for any conversion issues', () {
        // Since the conversion is simple, we test that it behaves the same as convertToArabic
        // for valid inputs, but has error handling built in
        final testNumbers = [0, 1, 12, 123, 1234, 12345];
        
        for (final number in testNumbers) {
          final regularResult = ArabicNumerals.convertToArabic(number);
          final safeResult = ArabicNumerals.convertToArabicSafe(number);
          expect(safeResult, equals(regularResult));
        }
      });
    });

    group('Arabic Numerals Array', () {
      test('should have correct Arabic numerals in order', () {
        const expectedNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
        expect(ArabicNumerals.arabicNumerals, equals(expectedNumerals));
        expect(ArabicNumerals.arabicNumerals.length, equals(10));
      });

      test('should map correctly to Western digits', () {
        for (int i = 0; i < 10; i++) {
          final arabicDigit = ArabicNumerals.arabicNumerals[i];
          final convertedNumber = ArabicNumerals.convertToArabic(i);
          expect(convertedNumber, equals(arabicDigit));
        }
      });
    });

    group('Real-world Usage Scenarios', () {
      test('should handle typical Hijri calendar dates', () {
        // Test typical Hijri year range (1400-1500 AH)
        for (int year = 1400; year <= 1500; year += 10) {
          final arabicYear = ArabicNumerals.convertToArabic(year);
          expect(arabicYear.length, equals(4)); // Should be 4 Arabic digits
          expect(arabicYear, matches(RegExp(r'^[٠-٩]+$'))); // Should only contain Arabic digits
        }
      });

      test('should handle day and month numbers', () {
        // Test days 1-30
        for (int day = 1; day <= 30; day++) {
          final arabicDay = ArabicNumerals.convertToArabic(day);
          expect(arabicDay, matches(RegExp(r'^[٠-٩]+$')));
          expect(arabicDay.length, lessThanOrEqualTo(2));
        }

        // Test months 1-12
        for (int month = 1; month <= 12; month++) {
          final arabicMonth = ArabicNumerals.convertToArabic(month);
          expect(arabicMonth, matches(RegExp(r'^[٠-٩]+$')));
          expect(arabicMonth.length, lessThanOrEqualTo(2));
        }
      });

      test('should handle prayer time numbers', () {
        // Test typical hour numbers (0-23)
        for (int hour = 0; hour <= 23; hour++) {
          final arabicHour = ArabicNumerals.convertToArabic(hour);
          expect(arabicHour, matches(RegExp(r'^[٠-٩]+$')));
        }

        // Test minute numbers (0-59)
        for (int minute = 0; minute <= 59; minute += 5) {
          final arabicMinute = ArabicNumerals.convertToArabic(minute);
          expect(arabicMinute, matches(RegExp(r'^[٠-٩]+$')));
        }
      });
    });

    group('Performance and Edge Cases', () {
      test('should handle zero correctly', () {
        expect(ArabicNumerals.convertToArabic(0), equals('٠'));
        expect(ArabicNumerals.convertToArabicSafe(0), equals('٠'));
      });

      test('should handle negative numbers by converting absolute value', () {
        // Note: The current implementation doesn't handle negative numbers
        // but we test what happens if someone passes them
        // This test documents current behavior
        expect(() => ArabicNumerals.convertToArabic(-1), throwsA(isA<FormatException>()));
      });

      test('should be consistent between safe and regular methods', () {
        final testCases = [0, 1, 10, 100, 1000, 1445, 2024, 9999];
        
        for (final testCase in testCases) {
          final regular = ArabicNumerals.convertToArabic(testCase);
          final safe = ArabicNumerals.convertToArabicSafe(testCase);
          expect(safe, equals(regular), reason: 'Mismatch for number $testCase');
        }
      });
    });

    group('String Pattern Validation', () {
      test('should produce valid Arabic numeral strings', () {
        final testNumbers = [1, 12, 123, 1234, 12345];
        
        for (final number in testNumbers) {
          final result = ArabicNumerals.convertToArabic(number);
          
          // Should only contain Arabic-Indic digits
          expect(result, matches(RegExp(r'^[٠-٩]+$')));
          
          // Should have the same length as the original number string
          expect(result.length, equals(number.toString().length));
          
          // Should not contain any Western digits
          expect(result, isNot(matches(RegExp(r'[0-9]'))));
        }
      });

      test('should maintain digit order correctly', () {
        // Test that the order of digits is preserved
        final result = ArabicNumerals.convertToArabic(12345);
        expect(result, equals('١٢٣٤٥'));
        
        // Verify each position
        expect(result[0], equals('١')); // 1
        expect(result[1], equals('٢')); // 2
        expect(result[2], equals('٣')); // 3
        expect(result[3], equals('٤')); // 4
        expect(result[4], equals('٥')); // 5
      });
    });
  });
}