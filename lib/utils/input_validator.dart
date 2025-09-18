import '../models/hijri_date.dart';
import '../models/reminder.dart';
import '../models/app_settings.dart';

/// Result of input validation
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warnings = const [],
  });

  ValidationResult.valid([List<String>? warnings]) 
      : this(isValid: true, warnings: warnings ?? []);
  
  ValidationResult.invalid(String errorMessage, [List<String>? warnings])
      : this(isValid: false, errorMessage: errorMessage, warnings: warnings ?? []);
}

/// Comprehensive input validation utility
class InputValidator {
  
  /// Validate reminder title
  static ValidationResult validateReminderTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return ValidationResult.invalid('Title is required');
    }
    
    final trimmed = title.trim();
    if (trimmed.length < 2) {
      return ValidationResult.invalid('Title must be at least 2 characters long');
    }
    
    if (trimmed.length > 100) {
      return ValidationResult.invalid('Title must be less than 100 characters');
    }
    
    // Check for invalid characters
    if (RegExp(r'[<>{}[\]\\|`~]').hasMatch(trimmed)) {
      return ValidationResult.invalid('Title contains invalid characters');
    }
    
    return ValidationResult.valid();
  }

  /// Validate reminder description
  static ValidationResult validateReminderDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return ValidationResult.valid(); // Description is optional
    }
    
    final trimmed = description.trim();
    if (trimmed.length > 500) {
      return ValidationResult.invalid('Description must be less than 500 characters');
    }
    
    // Check for invalid characters
    if (RegExp(r'[<>{}[\]\\|`~]').hasMatch(trimmed)) {
      return ValidationResult.invalid('Description contains invalid characters');
    }
    
    return ValidationResult.valid();
  }

  /// Validate Hijri date
  static ValidationResult validateHijriDate(int? year, int? month, int? day) {
    if (year == null || month == null || day == null) {
      return ValidationResult.invalid('All date fields are required');
    }
    
    // Validate year range
    if (year < 1000 || year > 3000) {
      return ValidationResult.invalid('Year must be between 1000 and 3000 AH');
    }
    
    // Validate month range
    if (month < 0 || month > 11) {
      return ValidationResult.invalid('Month must be between 1 and 12');
    }
    
    // Validate day range
    if (day < 1 || day > 30) {
      return ValidationResult.invalid('Day must be between 1 and 30');
    }
    
    // Check if day is valid for the specific month
    try {
      final daysInMonth = HijriDate.daysInMonth(year, month);
      if (day > daysInMonth) {
        return ValidationResult.invalid(
          'Day $day is not valid for ${HijriDate.getMonthName(month)} $year AH (max: $daysInMonth days)'
        );
      }
    } catch (e) {
      return ValidationResult.invalid('Invalid Hijri date');
    }
    
    return ValidationResult.valid();
  }

  /// Validate reminder type
  static ValidationResult validateReminderType(ReminderType? type) {
    if (type == null) {
      return ValidationResult.invalid('Reminder type is required');
    }
    
    return ValidationResult.valid();
  }

  /// Validate notification advance time
  static ValidationResult validateNotificationAdvance(int? minutes) {
    if (minutes == null) {
      return ValidationResult.invalid('Notification advance time is required');
    }
    
    if (minutes < 0) {
      return ValidationResult.invalid('Notification advance time cannot be negative');
    }
    
    if (minutes > 1440) { // 24 hours
      return ValidationResult.invalid('Notification advance time cannot exceed 24 hours');
    }
    
    return ValidationResult.valid();
  }

  /// Validate complete reminder
  static ValidationResult validateReminder(
    String? title,
    String? description,
    int? hijriYear,
    int? hijriMonth,
    int? hijriDay,
    ReminderType? type,
    int? notificationAdvance,
  ) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Validate title
    final titleResult = validateReminderTitle(title);
    if (!titleResult.isValid) {
      errors.add(titleResult.errorMessage!);
    }
    
    // Validate description
    final descResult = validateReminderDescription(description);
    if (!descResult.isValid) {
      errors.add(descResult.errorMessage!);
    }
    
    // Validate Hijri date
    final dateResult = validateHijriDate(hijriYear, hijriMonth, hijriDay);
    if (!dateResult.isValid) {
      errors.add(dateResult.errorMessage!);
    }
    
    // Validate type
    final typeResult = validateReminderType(type);
    if (!typeResult.isValid) {
      errors.add(typeResult.errorMessage!);
    }
    
    // Validate notification advance
    final advanceResult = validateNotificationAdvance(notificationAdvance);
    if (!advanceResult.isValid) {
      errors.add(advanceResult.errorMessage!);
    }
    
    // Check if date is in the past (warning only)
    if (hijriYear != null && hijriMonth != null && hijriDay != null) {
      try {
        final hijriDate = HijriDate(hijriYear, hijriMonth, hijriDay);
        final gregorianDate = hijriDate.toGregorian();
        if (gregorianDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          warnings.add('The selected date is in the past');
        }
      } catch (e) {
        // Date validation already handled above
      }
    }
    
    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors.first, warnings);
    }
    
    return ValidationResult.valid(warnings);
  }

  /// Validate app settings language
  static ValidationResult validateLanguage(String? language) {
    if (language == null || language.trim().isEmpty) {
      return ValidationResult.invalid('Language is required');
    }
    
    final validLanguages = ['en', 'ar', 'id', 'ur', 'ms', 'tr', 'fa', 'bn'];
    if (!validLanguages.contains(language)) {
      return ValidationResult.invalid('Invalid language code: $language');
    }
    
    return ValidationResult.valid();
  }

  /// Validate app settings theme
  static ValidationResult validateTheme(String? theme) {
    if (theme == null || theme.trim().isEmpty) {
      return ValidationResult.invalid('Theme is required');
    }
    
    final validThemes = ['light', 'dark', 'system'];
    if (!validThemes.contains(theme)) {
      return ValidationResult.invalid('Invalid theme: $theme');
    }
    
    return ValidationResult.valid();
  }

  /// Validate prayer time format
  static ValidationResult validatePrayerTimeFormat(String? format) {
    if (format == null || format.trim().isEmpty) {
      return ValidationResult.invalid('Prayer time format is required');
    }
    
    final validFormats = ['12h', '24h'];
    if (!validFormats.contains(format)) {
      return ValidationResult.invalid('Invalid prayer time format: $format');
    }
    
    return ValidationResult.valid();
  }

  /// Validate font size
  static ValidationResult validateFontSize(double? fontSize) {
    if (fontSize == null) {
      return ValidationResult.invalid('Font size is required');
    }
    
    if (fontSize < 10.0 || fontSize > 24.0) {
      return ValidationResult.invalid('Font size must be between 10.0 and 24.0');
    }
    
    return ValidationResult.valid();
  }

  /// Validate location coordinates
  static ValidationResult validateCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return ValidationResult.invalid('Both latitude and longitude are required');
    }
    
    if (latitude < -90.0 || latitude > 90.0) {
      return ValidationResult.invalid('Latitude must be between -90.0 and 90.0');
    }
    
    if (longitude < -180.0 || longitude > 180.0) {
      return ValidationResult.invalid('Longitude must be between -180.0 and 180.0');
    }
    
    return ValidationResult.valid();
  }

  /// Validate email format
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return ValidationResult.invalid('Email is required');
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return ValidationResult.invalid('Invalid email format');
    }
    
    return ValidationResult.valid();
  }

  /// Validate phone number
  static ValidationResult validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return ValidationResult.invalid('Phone number is required');
    }
    
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) {
      return ValidationResult.invalid('Phone number must be between 10 and 15 digits');
    }
    
    return ValidationResult.valid();
  }

  /// Validate time format (HH:MM)
  static ValidationResult validateTimeFormat(String? time) {
    if (time == null || time.trim().isEmpty) {
      return ValidationResult.invalid('Time is required');
    }
    
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(time.trim())) {
      return ValidationResult.invalid('Invalid time format. Use HH:MM format');
    }
    
    return ValidationResult.valid();
  }

  /// Sanitize string input
  static String sanitizeString(String? input) {
    if (input == null) return '';
    
    // Remove potentially dangerous characters
    String sanitized = input.trim();
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}[\]\\|`~]'), '');
    
    // Limit length
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }
    
    return sanitized;
  }

  /// Sanitize and validate ID
  static ValidationResult validateAndSanitizeId(String? id) {
    if (id == null || id.trim().isEmpty) {
      return ValidationResult.invalid('ID is required');
    }
    
    final sanitized = id.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    
    if (sanitized.length < 3) {
      return ValidationResult.invalid('ID must be at least 3 characters long');
    }
    
    if (sanitized.length > 50) {
      return ValidationResult.invalid('ID must be less than 50 characters');
    }
    
    return ValidationResult.valid();
  }

  /// Validate URL format
  static ValidationResult validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return ValidationResult.invalid('URL is required');
    }
    
    try {
      final uri = Uri.parse(url.trim());
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return ValidationResult.invalid('URL must start with http:// or https://');
      }
      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid('Invalid URL format');
    }
  }

  /// Validate password strength
  static ValidationResult validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }
    
    final warnings = <String>[];
    
    if (password.length < 8) {
      return ValidationResult.invalid('Password must be at least 8 characters long');
    }
    
    if (password.length > 128) {
      return ValidationResult.invalid('Password must be less than 128 characters');
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      warnings.add('Password should contain at least one uppercase letter');
    }
    
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      warnings.add('Password should contain at least one lowercase letter');
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      warnings.add('Password should contain at least one number');
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      warnings.add('Password should contain at least one special character');
    }
    
    return ValidationResult.valid(warnings);
  }

  /// Validate date range
  static ValidationResult validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return ValidationResult.invalid('Both start and end dates are required');
    }
    
    if (startDate.isAfter(endDate)) {
      return ValidationResult.invalid('Start date must be before end date');
    }
    
    final difference = endDate.difference(startDate).inDays;
    if (difference > 365) {
      return ValidationResult.invalid('Date range cannot exceed 365 days');
    }
    
    return ValidationResult.valid();
  }

  /// Validate numeric range
  static ValidationResult validateNumericRange(
    num? value,
    num min,
    num max,
    String fieldName,
  ) {
    if (value == null) {
      return ValidationResult.invalid('$fieldName is required');
    }
    
    if (value < min || value > max) {
      return ValidationResult.invalid('$fieldName must be between $min and $max');
    }
    
    return ValidationResult.valid();
  }
}