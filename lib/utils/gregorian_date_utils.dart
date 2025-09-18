/// Utility functions for Gregorian date operations
/// 
/// This utility provides helper functions for working with Gregorian dates,
/// mirroring the existing Hijri utilities in the codebase.
class GregorianDateUtils {
  /// Get abbreviated Gregorian month names
  /// 
  /// Returns a 3-letter abbreviation for the given month (1-based).
  /// Example: getShortMonthName(1) returns "Jan"
  static String getShortMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    // Ensure month is within valid range (1-12)
    final validMonth = month.clamp(1, 12);
    return months[validMonth - 1];
  }
  
  /// Get full Gregorian month names
  /// 
  /// Returns the full name for the given month (1-based).
  /// Example: getFullMonthName(1) returns "January"
  static String getFullMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    // Ensure month is within valid range (1-12)
    final validMonth = month.clamp(1, 12);
    return months[validMonth - 1];
  }
}

/// Extension on DateTime for convenient Gregorian date operations
extension DateTimeGregorianUtils on DateTime {
  /// Get the short month name for this date
  String get shortMonthName => GregorianDateUtils.getShortMonthName(month);
  
  /// Get the full month name for this date
  String get fullMonthName => GregorianDateUtils.getFullMonthName(month);
  
  /// Get formatted date string with short month name
  /// 
  /// Returns format like "15 Jan" for day 15 of January
  String get formattedDateWithShortMonth => '$day $shortMonthName';
  
  /// Get formatted date string with full month name
  /// 
  /// Returns format like "15 January" for day 15 of January
  String get formattedDateWithFullMonth => '$day $fullMonthName';
}
