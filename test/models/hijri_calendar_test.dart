import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/models/hijri_calendar.dart';
import 'package:hijri_minder/models/hijri_date.dart';

void main() {
  group('HijriCalendar', () {
    late HijriCalendar calendar;

    setUp(() {
      // Test with Ramadan 1445 (March 2024)
      calendar = HijriCalendar(1445, 8); // Ramadan is month 8 (0-indexed)
    });

    group('Basic Properties', () {
      test('should initialize with correct year and month', () {
        expect(calendar.getYear(), equals(1445));
        expect(calendar.getMonth(), equals(8));
        expect(calendar.isISOCalendar(), equals(false));
      });

      test('should support ISO calendar flag', () {
        final isoCalendar = HijriCalendar(1445, 8, isISO: true);
        expect(isoCalendar.isISOCalendar(), equals(true));
      });

      test('should have correct min and max years', () {
        expect(HijriCalendar.getMinYear(), equals(1000));
        expect(HijriCalendar.getMaxYear(), equals(3000));
      });
    });

    group('Navigation Methods', () {
      test('should navigate to previous month correctly', () {
        final prevMonth = calendar.previousMonth();
        expect(prevMonth.getYear(), equals(1445));
        expect(prevMonth.getMonth(), equals(7)); // Shabaan
      });

      test('should navigate to next month correctly', () {
        final nextMonth = calendar.nextMonth();
        expect(nextMonth.getYear(), equals(1445));
        expect(nextMonth.getMonth(), equals(9)); // Shawwal
      });

      test('should handle year boundary when navigating months', () {
        final decemberCalendar = HijriCalendar(1445, 11); // Zilhaj
        final nextMonth = decemberCalendar.nextMonth();
        expect(nextMonth.getYear(), equals(1446));
        expect(nextMonth.getMonth(), equals(0)); // Moharram

        final januaryCalendar = HijriCalendar(1445, 0); // Moharram
        final prevMonth = januaryCalendar.previousMonth();
        expect(prevMonth.getYear(), equals(1444));
        expect(prevMonth.getMonth(), equals(11)); // Zilhaj
      });

      test('should navigate to previous year correctly', () {
        final prevYear = calendar.previousYear();
        expect(prevYear.getYear(), equals(1444));
        expect(prevYear.getMonth(), equals(8)); // Same month
      });

      test('should navigate to next year correctly', () {
        final nextYear = calendar.nextYear();
        expect(nextYear.getYear(), equals(1446));
        expect(nextYear.getMonth(), equals(8)); // Same month
      });

      test('should respect min year boundary', () {
        final minYearCalendar = HijriCalendar(1000, 5);
        final prevYear = minYearCalendar.previousYear();
        expect(prevYear.getYear(), equals(1000)); // Should not go below min
        expect(prevYear.getMonth(), equals(5));
      });

      test('should respect max year boundary', () {
        final maxYearCalendar = HijriCalendar(3000, 5);
        final nextYear = maxYearCalendar.nextYear();
        expect(nextYear.getYear(), equals(3000)); // Should not go above max
        expect(nextYear.getMonth(), equals(5));
      });
    });

    group('Day of Week Calculation', () {
      test('should calculate day of week correctly', () {
        final dayOfWeek = calendar.dayOfWeek(1); // 1st Ramadan
        expect(dayOfWeek, isA<int>());
        expect(dayOfWeek, inInclusiveRange(0, 6));
      });
    });

    group('Days Generation', () {
      test('should generate correct number of days for the month', () {
        final days = calendar.days();
        final expectedDays = HijriDate.daysInMonth(1445, 8);
        expect(days.length, equals(expectedDays));
      });

      test('should generate days with correct structure', () {
        final days = calendar.days();
        expect(days.isNotEmpty, isTrue);
        
        final firstDay = days.first;
        expect(firstDay.containsKey('hijriDate'), isTrue);
        expect(firstDay.containsKey('gregorianDate'), isTrue);
        expect(firstDay.containsKey('isPrevious'), isTrue);
        expect(firstDay.containsKey('isNext'), isTrue);
        expect(firstDay.containsKey('isToday'), isTrue);
        
        expect(firstDay['hijriDate'], isA<HijriDate>());
        expect(firstDay['gregorianDate'], isA<DateTime>());
        expect(firstDay['isPrevious'], equals(false));
        expect(firstDay['isNext'], equals(false));
      });

      test('should have sequential hijri dates', () {
        final days = calendar.days();
        for (int i = 0; i < days.length; i++) {
          final hijriDate = days[i]['hijriDate'] as HijriDate;
          expect(hijriDate.day, equals(i + 1));
          expect(hijriDate.month, equals(8));
          expect(hijriDate.year, equals(1445));
        }
      });
    });

    group('Previous Days Generation', () {
      test('should generate previous month days to fill week start', () {
        final previousDays = calendar.previousDays();
        expect(previousDays, isA<List<Map<String, dynamic>?>>());
        
        for (final day in previousDays) {
          if (day != null) {
            expect(day['isPrevious'], isTrue);
            expect(day['isNext'], isFalse);
            final hijriDate = day['hijriDate'] as HijriDate;
            expect(hijriDate.month, equals(7)); // Shabaan (previous month)
            expect(hijriDate.year, equals(1445));
          }
        }
      });
    });

    group('Next Days Generation', () {
      test('should generate next month days to fill week end', () {
        final nextDays = calendar.nextDays();
        expect(nextDays, isA<List<Map<String, dynamic>?>>());
        
        for (final day in nextDays) {
          if (day != null) {
            expect(day['isPrevious'], isFalse);
            expect(day['isNext'], isTrue);
            final hijriDate = day['hijriDate'] as HijriDate;
            expect(hijriDate.month, equals(9)); // Shawwal (next month)
            expect(hijriDate.year, equals(1445));
          }
        }
      });
    });

    group('Weeks Generation', () {
      test('should generate weeks with 7 days each', () {
        final weeks = calendar.weeks();
        expect(weeks, isA<List<List<Map<String, dynamic>?>>>());
        
        for (final week in weeks) {
          expect(week.length, equals(7));
        }
      });

      test('should include current month days', () {
        final weeks = calendar.weeks();
        final allDays = weeks.expand((week) => week).where((day) => day != null).toList();
        
        bool hasCurrent = false;
        
        for (final day in allDays) {
          if (day!['isPrevious'] == false && day['isNext'] == false) {
            hasCurrent = true;
            break;
          }
        }
        
        expect(hasCurrent, isTrue); // Should always have current month days
      });
    });

    group('Today Highlighting', () {
      test('should correctly identify today', () {
        final today = DateTime.now();
        final todayHijri = HijriDate.fromGregorian(today);
        final todayCalendar = HijriCalendar(todayHijri.year, todayHijri.month);
        
        final days = todayCalendar.days();
        final todayDay = days.firstWhere(
          (day) => (day['hijriDate'] as HijriDate).day == todayHijri.day,
          orElse: () => <String, dynamic>{},
        );
        
        if (todayDay.isNotEmpty) {
          expect(todayDay['isToday'], isTrue);
        }
      });
    });

    group('Edge Cases', () {
      test('should handle Kabisa year months correctly', () {
        final kabisaYear = 1445;
        if (HijriDate.isKabisa(kabisaYear)) {
          final zilhajCalendar = HijriCalendar(kabisaYear, 11); // Zilhaj
          final days = zilhajCalendar.days();
          expect(days.length, equals(30)); // Kabisa year has 30 days in Zilhaj
        }
      });

      test('should handle first month of year', () {
        final moharramCalendar = HijriCalendar(1445, 0); // Moharram
        final days = moharramCalendar.days();
        expect(days.length, equals(30)); // Moharram has 30 days
        
        final firstDay = days.first['hijriDate'] as HijriDate;
        expect(firstDay.day, equals(1));
        expect(firstDay.month, equals(0));
        expect(firstDay.year, equals(1445));
      });

      test('should handle last month of year', () {
        final zilhajCalendar = HijriCalendar(1445, 11); // Zilhaj
        final days = zilhajCalendar.days();
        final expectedDays = HijriDate.daysInMonth(1445, 11);
        expect(days.length, equals(expectedDays));
        
        final lastDay = days.last['hijriDate'] as HijriDate;
        expect(lastDay.day, equals(expectedDays));
        expect(lastDay.month, equals(11));
        expect(lastDay.year, equals(1445));
      });
    });

    group('Equality and String Representation', () {
      test('should implement equality correctly', () {
        final calendar1 = HijriCalendar(1445, 8);
        final calendar2 = HijriCalendar(1445, 8);
        final calendar3 = HijriCalendar(1445, 9);
        
        expect(calendar1, equals(calendar2));
        expect(calendar1, isNot(equals(calendar3)));
      });

      test('should implement hashCode correctly', () {
        final calendar1 = HijriCalendar(1445, 8);
        final calendar2 = HijriCalendar(1445, 8);
        
        expect(calendar1.hashCode, equals(calendar2.hashCode));
      });

      test('should have meaningful string representation', () {
        final calendarString = calendar.toString();
        expect(calendarString, contains('1445'));
        expect(calendarString, contains('8'));
        expect(calendarString, contains('HijriCalendar'));
      });
    });
  });
}