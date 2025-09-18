# HijriMinder

HijriMinder is a comprehensive Hijri-first calendar application that serves the global Muslim community by providing accurate Islamic date conversion, prayer times, birthday/anniversary reminders, and culturally authentic messaging features.

## Features

- Hijri-first calendar interface with accurate date conversion
- Location-based prayer times with notifications
- Hijri-based birthday and anniversary reminders
- Auto-suggested culturally appropriate Islamic messages
- Multi-language support with proper Arabic script handling
- Islamic events and holidays display
- Offline functionality for core features

## Project Structure

```
lib/
├── models/          # Data models (HijriDate, PrayerTimes, etc.)
├── services/        # Business logic services
├── widgets/         # Reusable UI components
├── screens/         # App screens and pages
├── utils/           # Utility functions and helpers
└── main.dart        # App entry point
```

## Dependencies

- **http**: For API calls to prayer times service
- **geolocator**: For location-based prayer times
- **shared_preferences**: For persistent settings storage
- **flutter_local_notifications**: For prayer and reminder notifications
- **intl**: For internationalization and localization
- **provider**: For state management

## Getting Started

1. Ensure Flutter is installed and configured
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Platform Configuration

### iOS
- Location permissions configured in Info.plist
- Background modes enabled for notifications
- Bundle identifier: com.hijriminder.hijri_minder

### Android
- Internet, location, and notification permissions configured
- Notification receivers set up for local notifications
- Package name: com.hijriminder.hijri_minder

## Development

This project follows Flutter best practices with a clean architecture pattern:
- Presentation layer (UI widgets and screens)
- Business logic layer (services)
- Data layer (models and local storage)

## License

This project is developed for the global Muslim community.