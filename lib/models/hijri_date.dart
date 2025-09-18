import '../utils/hijri_date_converter.dart';

class HijriDate {
  final int year;
  final int month;
  final int day;

  // Hijri year remainders for determining Kabisa years
  static const List<int> kabisaYearRemainders = [2, 5, 8, 10, 13, 16, 19, 21, 24, 27, 29];

  // Number of days in a Hijri year per month
  static const List<int> daysInYear = [30, 59, 89, 118, 148, 177, 207, 236, 266, 295, 325];

  // Number of days in 30-years per Hijri year
  static const List<int> daysIn30Years = [
    354,  708, 1063, 1417, 1771, 2126, 2480, 2834,  3189,  3543,
    3898, 4252, 4606, 4961, 5315, 5669, 6024, 6378,  6732,  7087,
    7441, 7796, 8150, 8504, 8859, 9213, 9567, 9922, 10276, 10631
  ];

  // Month names
  static const List<String> monthNamesLong = [
    "Moharram al-Haraam",
    "Safar al-Muzaffar",
    "Rabi al-Awwal",
    "Rabi al-Aakhar",
    "Jumada al-Ula",
    "Jumada al-Ukhra",
    "Rajab al-Asab",
    "Shabaan al-Karim",
    "Ramadaan al-Moazzam",
    "Shawwal al-Mukarram",
    "Zilqadah al-Haraam",
    "Zilhaj al-Haraam"
  ];

  static const List<String> monthNamesShort = [
    "Moharram",
    "Safar",
    "Rabi I",
    "Rabi II",
    "Jumada I",
    "Jumada II",
    "Rajab",
    "Shabaan",
    "Ramadaan",
    "Shawwal",
    "Zilqadah",
    "Zilhaj"
  ];

  HijriDate(this.year, this.month, this.day);

  // Convert from Gregorian date using the proven algorithm
  factory HijriDate.fromGregorian(DateTime gregorianDate) {
    return HijriDate.fromAJD(gregorianToAJD(gregorianDate));
  }

  // Convert from Astronomical Julian Day
  factory HijriDate.fromAJD(double ajd) {
    int year, month, date;
    int i = 0;
    int left = (ajd - 1948083.5).floor();
    int y30 = (left / 10631.0).floor();

    left -= y30 * 10631;
    while (i < daysIn30Years.length && left > daysIn30Years[i]) {
      i += 1;
    }

    year = (y30 * 30.0 + i).round();
    if (i > 0) {
      left -= daysIn30Years[i - 1];
    }
    i = 0;
    while (i < daysInYear.length && left > daysInYear[i]) {
      i += 1;
    }
    month = i;
    date = (i > 0) ? (left - daysInYear[i - 1]).round() : left.round();

    // Ensure valid date values
    if (date <= 0) date = 1;
    if (month < 0) month = 0;
    if (month > 11) month = 11;

    return HijriDate(year, month, date);
  }

  // Convert to Astronomical Julian Day
  double toAJD() {
    int y30 = (year / 30.0).floor();
    double ajd = 1948083.5 + y30 * 10631 + dayOfYear();
    if (year % 30 != 0) {
      ajd += daysIn30Years[year - y30 * 30 - 1];
    }
    return ajd;
  }

  // Convert to Gregorian date using the proven algorithm
  DateTime toGregorian() {
    return ajdToGregorian(toAJD());
  }

  // Get month name
  static String getMonthName(int month) {
    final idx = month.clamp(0, 11);
    return monthNamesLong[idx];
  }

  static String getShortMonthName(int month) {
    final idx = month.clamp(0, 11);
    return monthNamesShort[idx];
  }

  // Check if Hijri year is Kabisa (leap year)
  static bool isKabisa(int year) {
    for (int remainder in kabisaYearRemainders) {
      if (year % 30 == remainder) {
        return true;
      }
    }
    return false;
  }

  // Get number of days in a Hijri month
  static int daysInMonth(int year, int month) {
    return ((month == 11) && isKabisa(year)) || (month % 2 == 0) ? 30 : 29;
  }

  // Get day of year
  int dayOfYear() {
    return (month == 0) ? day : (daysInYear[month - 1] + day);
  }

  int getYear() => year;
  int getMonth() => month;
  int getDate() => day;

  /// Add days to the current Hijri date, handling month and year overflow
  HijriDate addDays(int daysToAdd) {
    if (daysToAdd == 0) return this;
    
    // Convert to Gregorian, add days, then convert back to Hijri
    // This ensures proper handling of month/year boundaries
    final gregorianDate = toGregorian();
    final newGregorianDate = gregorianDate.add(Duration(days: daysToAdd));
    return HijriDate.fromGregorian(newGregorianDate);
  }

  /// Subtract days from the current Hijri date, handling month and year underflow
  HijriDate subtractDays(int daysToSubtract) {
    return addDays(-daysToSubtract);
  }

  /// Add months to the current Hijri date
  HijriDate addMonths(int monthsToAdd) {
    if (monthsToAdd == 0) return this;
    
    int newYear = year;
    int newMonth = month + monthsToAdd;
    
    // Handle year overflow/underflow
    while (newMonth > 11) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 0) {
      newMonth += 12;
      newYear--;
    }
    
    // Ensure day is valid for the new month
    final maxDaysInNewMonth = daysInMonth(newYear, newMonth);
    final newDay = day > maxDaysInNewMonth ? maxDaysInNewMonth : day;
    
    return HijriDate(newYear, newMonth, newDay);
  }

  /// Add years to the current Hijri date
  HijriDate addYears(int yearsToAdd) {
    if (yearsToAdd == 0) return this;
    
    final newYear = year + yearsToAdd;
    
    // Ensure day is valid for the new year (in case of leap year changes)
    final maxDaysInMonth = daysInMonth(newYear, month);
    final newDay = day > maxDaysInMonth ? maxDaysInMonth : day;
    
    return HijriDate(newYear, month, newDay);
  }

  /// Check if this date is valid
  bool isValid() {
    if (year < 1 || month < 0 || month > 11 || day < 1) {
      return false;
    }
    
    final maxDays = daysInMonth(year, month);
    return day <= maxDays;
  }

  @override
  String toString() {
    return 'HijriDate(year: $year, month: $month, day: $day)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HijriDate &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;
}