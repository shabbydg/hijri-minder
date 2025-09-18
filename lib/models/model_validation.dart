/// Validation result class
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  ValidationResult.valid() : this(isValid: true);
  
  ValidationResult.invalid(List<String> errors, [List<String>? warnings])
      : this(isValid: false, errors: errors, warnings: warnings ?? []);
}

/// Utility class for model validation and error handling
class ModelValidation {
  /// Validate prayer times model
  static ValidationResult validatePrayerTimes(Map<String, dynamic> json) {
    final errors = <String>[];
    final warnings = <String>[];

    // Required fields
    final requiredFields = [
      'sihori', 'fajr', 'sunrise', 'zawaal', 'zohrEnd', 
      'asrEnd', 'maghrib', 'maghribEnd', 'nisfulLayl', 'nisfulLaylEnd', 'date'
    ];

    for (final field in requiredFields) {
      if (!json.containsKey(field) || json[field] == null) {
        errors.add('Missing required field: $field');
      }
    }

    // Validate time format
    final timeFields = requiredFields.where((f) => f != 'date').toList();
    for (final field in timeFields) {
      if (json[field] != null && !_isValidTimeFormat(json[field])) {
        errors.add('Invalid time format for $field: ${json[field]}');
      }
    }

    // Validate date
    if (json['date'] != null) {
      try {
        DateTime.parse(json['date']);
      } catch (e) {
        errors.add('Invalid date format: ${json['date']}');
      }
    }

    return errors.isEmpty 
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors, warnings);
  }

  /// Validate Islamic event model
  static ValidationResult validateIslamicEvent(Map<String, dynamic> json) {
    final errors = <String>[];
    final warnings = <String>[];

    // Required fields
    if (!json.containsKey('id') || json['id'] == null || json['id'].toString().isEmpty) {
      errors.add('Missing or empty required field: id');
    }

    if (!json.containsKey('title') || json['title'] == null || json['title'].toString().isEmpty) {
      errors.add('Missing or empty required field: title');
    }

    // Validate category
    if (json.containsKey('category')) {
      final validCategories = ['eid', 'shahadat', 'ramadan', 'hajj', 'milad', 'other'];
      if (!validCategories.contains(json['category'])) {
        errors.add('Invalid category: ${json['category']}');
      }
    }

    // Validate Hijri date
    if (json.containsKey('hijriDay')) {
      final day = json['hijriDay'];
      if (day is! int || day < 1 || day > 30) {
        errors.add('Invalid hijriDay: must be between 1 and 30');
      }
    }

    if (json.containsKey('hijriMonth')) {
      final month = json['hijriMonth'];
      if (month is! int || month < 0 || month > 11) {
        errors.add('Invalid hijriMonth: must be between 0 and 11');
      }
    }

    if (json.containsKey('hijriYear')) {
      final year = json['hijriYear'];
      if (year != null && (year is! int || year < 1000 || year > 3000)) {
        errors.add('Invalid hijriYear: must be between 1000 and 3000 or null');
      }
    }

    return errors.isEmpty 
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors, warnings);
  }

  /// Validate app settings model
  static ValidationResult validateAppSettings(Map<String, dynamic> json) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate language
    if (json.containsKey('language')) {
      final validLanguages = ['en', 'ar', 'id', 'ur', 'ms', 'tr', 'fa', 'bn'];
      if (!validLanguages.contains(json['language'])) {
        errors.add('Invalid language: ${json['language']}');
      }
    }

    // Validate theme
    if (json.containsKey('theme')) {
      final validThemes = ['light', 'dark', 'system'];
      if (!validThemes.contains(json['theme'])) {
        errors.add('Invalid theme: ${json['theme']}');
      }
    }

    // Validate prayer time format
    if (json.containsKey('prayerTimeFormat')) {
      final validFormats = ['12h', '24h'];
      if (!validFormats.contains(json['prayerTimeFormat'])) {
        errors.add('Invalid prayerTimeFormat: ${json['prayerTimeFormat']}');
      }
    }

    // Validate font size
    if (json.containsKey('fontSize')) {
      final fontSize = json['fontSize'];
      if (fontSize is! num || fontSize < 10.0 || fontSize > 24.0) {
        errors.add('Invalid fontSize: must be between 10.0 and 24.0');
      }
    }

    // Validate notification advance time
    if (json.containsKey('prayerNotificationAdvanceMinutes')) {
      final minutes = json['prayerNotificationAdvanceMinutes'];
      if (minutes is! int || minutes < 0 || minutes > 60) {
        errors.add('Invalid prayerNotificationAdvanceMinutes: must be between 0 and 60');
      }
    }

    return errors.isEmpty 
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors, warnings);
  }

  /// Validate reminder model
  static ValidationResult validateReminder(Map<String, dynamic> json) {
    final errors = <String>[];
    final warnings = <String>[];

    // Required fields
    final requiredFields = ['id', 'title', 'hijriYear', 'hijriMonth', 'hijriDay', 'gregorianDate', 'createdAt'];
    
    for (final field in requiredFields) {
      if (!json.containsKey(field) || json[field] == null) {
        errors.add('Missing required field: $field');
      }
    }

    // Validate reminder type
    if (json.containsKey('type')) {
      final validTypes = ['birthday', 'anniversary', 'religious', 'personal', 'family', 'other'];
      if (!validTypes.contains(json['type'])) {
        errors.add('Invalid reminder type: ${json['type']}');
      }
    }

    // Validate Hijri date
    if (json.containsKey('hijriDay')) {
      final day = json['hijriDay'];
      if (day is! int || day < 1 || day > 30) {
        errors.add('Invalid hijriDay: must be between 1 and 30');
      }
    }

    if (json.containsKey('hijriMonth')) {
      final month = json['hijriMonth'];
      if (month is! int || month < 0 || month > 11) {
        errors.add('Invalid hijriMonth: must be between 0 and 11');
      }
    }

    if (json.containsKey('hijriYear')) {
      final year = json['hijriYear'];
      if (year is! int || year < 1000 || year > 3000) {
        errors.add('Invalid hijriYear: must be between 1000 and 3000');
      }
    }

    // Validate dates
    if (json.containsKey('gregorianDate')) {
      try {
        DateTime.parse(json['gregorianDate']);
      } catch (e) {
        errors.add('Invalid gregorianDate format: ${json['gregorianDate']}');
      }
    }

    if (json.containsKey('createdAt')) {
      try {
        DateTime.parse(json['createdAt']);
      } catch (e) {
        errors.add('Invalid createdAt format: ${json['createdAt']}');
      }
    }

    if (json.containsKey('lastNotified') && json['lastNotified'] != null) {
      try {
        DateTime.parse(json['lastNotified']);
      } catch (e) {
        errors.add('Invalid lastNotified format: ${json['lastNotified']}');
      }
    }

    // Validate notification advance time
    if (json.containsKey('notificationAdvanceMinutes')) {
      final minutes = json['notificationAdvanceMinutes'];
      if (minutes is! int || minutes < 0 || minutes > 1440) { // Max 24 hours
        errors.add('Invalid notificationAdvanceMinutes: must be between 0 and 1440');
      }
    }

    return errors.isEmpty 
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors, warnings);
  }

  /// Helper method to validate time format (HH:MM)
  static bool _isValidTimeFormat(String time) {
    if (time.isEmpty) return false;
    
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  /// Sanitize string input
  static String sanitizeString(String? input) {
    if (input == null) return '';
    return input.trim().replaceAll(RegExp(r'[^\w\s\-.,!?()[\]{}]'), '');
  }

  /// Validate and sanitize ID
  static String? validateId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    
    final sanitized = id.trim();
    if (sanitized.length < 3 || sanitized.length > 50) return null;
    
    // Allow alphanumeric, hyphens, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(sanitized)) return null;
    
    return sanitized;
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Validate phone number format (basic)
  static bool isValidPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }
}

/// Custom exception for model validation errors
class ModelValidationException implements Exception {
  final String message;
  final List<String> errors;

  const ModelValidationException(this.message, this.errors);

  @override
  String toString() {
    return 'ModelValidationException: $message\nErrors: ${errors.join(', ')}';
  }
}