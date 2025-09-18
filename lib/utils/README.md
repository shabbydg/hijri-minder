# Utils Directory

This directory contains all utility functions and helpers for the HijriMinder application:

- `hijri_date_converter.dart` - Hijri to Gregorian date conversion utilities
- `arabic_numerals.dart` - Arabic-Indic numeral conversion utilities
- `error_handler.dart` - Comprehensive error handling and fallback mechanisms
- `input_validator.dart` - Input validation and sanitization utilities

## Error Handling System

The error handling system provides:

### ErrorHandler
- Centralized error logging and management
- Fallback mechanisms with `withFallback()`
- Retry mechanisms with exponential backoff using `withRetry()`
- User-friendly error message generation
- Error categorization by type and severity
- Error statistics and reporting

### InputValidator
- Comprehensive input validation for all user data
- Hijri date validation with month-specific day limits
- String sanitization to prevent XSS attacks
- Email, phone, and URL format validation
- Password strength validation
- Numeric range validation

### Integration
- Automatic error logging in all services
- Graceful degradation when APIs are unavailable
- Fallback to mock data when network fails
- User-friendly error messages in UI components
- Crash reporting and logging service integration

All utilities support the core functionality and follow the design specifications with comprehensive error handling and input validation.