# Models Directory

This directory contains all data models for the HijriMinder application:

- `hijri_date.dart` - Core Hijri date model with conversion methods
- `hijri_calendar.dart` - Hijri calendar model with month/year navigation and day generation
- `prayer_times.dart` - Prayer times data structure with formatting capabilities
- `islamic_event.dart` - Islamic events and holidays model with localization support
- `app_settings.dart` - User preferences and settings model with validation
- `reminder.dart` - Birthday/anniversary reminder model with message templates
- `model_validation.dart` - Validation utilities and error handling for all models

All models follow the design specifications from the requirements document and include:
- JSON serialization/deserialization
- Comprehensive validation and error handling
- Localization support where applicable
- Type-safe enums and constants
- Immutable data structures with copyWith methods

## HijriCalendar Model

The `HijriCalendar` model provides comprehensive calendar functionality:

### Features
- Month and year navigation (previousMonth, nextMonth, previousYear, nextYear)
- Calendar day generation with proper week alignment
- Previous/next month day filling for complete calendar weeks
- Today highlighting functionality
- Support for both ISO and non-ISO calendar modes
- Boundary checking for min/max years (1000-3000 AH)

### Usage
```dart
// Create a calendar for Ramadan 1445
final calendar = HijriCalendar(1445, 8);

// Navigate months
final nextMonth = calendar.nextMonth();
final prevMonth = calendar.previousMonth();

// Generate calendar days
final days = calendar.days(); // Current month days
final weeks = calendar.weeks(); // Complete weeks with prev/next month days

// Check day of week
final dayOfWeek = calendar.dayOfWeek(1); // Day of week for 1st of month
```