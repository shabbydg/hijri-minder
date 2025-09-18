# Platform Setup Documentation for HijriMinder

This document provides comprehensive instructions for setting up platform-specific configurations for the HijriMinder Flutter application, including iOS and Android platform configurations, permissions, notifications, and app store preparation.

## Table of Contents

1. [Overview](#overview)
2. [iOS Configuration](#ios-configuration)
3. [Android Configuration](#android-configuration)
4. [Notification Setup](#notification-setup)
5. [Audio File Integration](#audio-file-integration)
6. [App Store Preparation](#app-store-preparation)
7. [Testing Platform Features](#testing-platform-features)
8. [Troubleshooting](#troubleshooting)

## Overview

HijriMinder is a comprehensive Hijri-first calendar application that requires platform-specific configurations for:
- Location services for accurate prayer times
- Notification systems for prayer reminders and Islamic events
- Audio playback for Adhan sounds
- Background execution for timely notifications
- App store compliance and security

## iOS Configuration

### 1. Info.plist Configuration

The iOS `Info.plist` file has been configured with comprehensive permissions and capabilities:

**Location Permissions:**
- `NSLocationWhenInUseUsageDescription`: For prayer time calculations
- `NSLocationAlwaysAndWhenInUseUsageDescription`: For background prayer notifications

**Notification Permissions:**
- `NSUserNotificationUsageDescription`: For prayer time and Islamic event notifications
- `BGTaskSchedulerPermittedIdentifiers`: For background task scheduling

**Audio Permissions:**
- `NSMicrophoneUsageDescription`: For audio feedback during notifications

**App Transport Security:**
- Configured to allow API calls to mumineen.org
- Maintains security while enabling necessary network access

**URL Schemes:**
- Deep linking support with `hijriminder://` scheme
- Share functionality for Islamic events and dates

**Localization Support:**
- RTL language support for Arabic, Urdu, Persian, Turkish, Bengali, Indonesian, and Malay

### 2. App Icons

**Required Icon Sizes:**
- iPhone: 20x20, 40x40, 60x60 (@1x, @2x, @3x)
- iPad: 29x29, 58x58, 76x76, 152x152, 167x167
- App Store: 1024x1024

**Design Guidelines:**
- Islamic-themed symbols (crescent moon, mosque silhouette, prayer beads)
- Culturally appropriate colors (deep green, gold, navy blue)
- Simple, recognizable design that works at small sizes
- Respectful and dignified imagery

### 3. Provisioning Profiles

**Development Profile:**
- Configure for development and testing
- Include necessary capabilities (push notifications, background modes)

**Distribution Profile:**
- Configure for App Store submission
- Include all required capabilities
- Ensure proper code signing

## Android Configuration

### 1. AndroidManifest.xml Configuration

The Android manifest includes comprehensive permissions and configurations:

**Core Permissions:**
- `INTERNET`: For prayer times API access
- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`: For location-based prayer times
- `POST_NOTIFICATIONS`: Android 13+ notification support
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`: For precise prayer notifications
- `MODIFY_AUDIO_SETTINGS`: For Adhan sound playback

**Background Execution:**
- `FOREGROUND_SERVICE`: For background notification processing
- `RECEIVE_BOOT_COMPLETED`: For notification restoration after device restart
- `VIBRATE` / `WAKE_LOCK`: For notification delivery

**Notification Channels:**
- Prayer Times: High importance, Adhan sound
- Islamic Reminders: Default importance, reminder sound
- General Notifications: Low importance, standard sound

**Intent Filters:**
- Deep linking support with `hijriminder://` scheme
- Share functionality for Islamic events

### 2. Build Configuration (build.gradle.kts)

**Signing Configuration:**
- Release signing with keystore properties
- Debug and release build variants
- ProGuard/R8 obfuscation for release builds

**Build Variants:**
- Debug: `.debug` suffix, debug signing
- Release: Production signing, code obfuscation

**Minimum SDK:**
- Android 5.0 (API 21) for modern notification features
- MultiDex support for large apps

### 3. ProGuard Rules

**Protected Classes:**
- Flutter framework classes
- Notification service classes
- Model classes for JSON serialization
- Location service classes
- Audio playback classes
- RTL layout classes

### 4. App Icons

**Required Densities:**
- mdpi: 48x48 pixels
- hdpi: 72x72 pixels
- xhdpi: 96x96 pixels
- xxhdpi: 144x144 pixels
- xxxhdpi: 192x192 pixels
- Play Store: 512x512 pixels

**Design Guidelines:**
- Same Islamic theme as iOS
- Android-specific design considerations
- Material Design compliance

### 5. Keystore Configuration

**Key Generation:**
```bash
keytool -genkey -v -keystore hijriminder-release-key.keystore -alias hijriminder -keyalg RSA -keysize 2048 -validity 10000
```

**Security Notes:**
- Use strong passwords
- Keep keystore file secure and backed up
- Never commit actual credentials to version control
- Required for app updates on Google Play Store

## Notification Setup

### 1. Platform-Specific Configuration

**iOS Notifications:**
- Background app refresh enabled
- Background task scheduler configured
- Notification categories for different types

**Android Notifications:**
- Notification channels configured
- Exact alarm permissions for precise timing
- Boot receiver for notification restoration

### 2. Audio Integration

**iOS Audio Files:**
- Stored in `assets/sounds/` directory
- Referenced in notification configurations
- Optimized for iOS playback

**Android Audio Files:**
- Stored in `res/raw/` directory
- Referenced as raw resources
- Optimized for Android playback

**Audio File Types:**
- `adhan_default.mp3`: Default Adhan sound (2-5 minutes)
- `notification_prayer.mp3`: Prayer notification sound (2-3 seconds)
- `notification_reminder.mp3`: Reminder notification sound (2-3 seconds)

## Audio File Integration

### 1. Asset Management

**Flutter Assets:**
- Configured in `pubspec.yaml`
- Cross-platform asset access
- Optimized file sizes

**Platform-Specific Resources:**
- iOS: Asset catalog integration
- Android: Raw resource integration
- Proper file naming conventions

### 2. Audio Quality Requirements

**Format:** MP3
**Quality:** 128kbps or higher
**Volume:** Normalized to prevent distortion
**Duration:** Appropriate for notification type
**Source:** Licensed Islamic audio content

## App Store Preparation

### 1. iOS App Store

**App Store Connect:**
- App information and metadata
- Screenshots for different device sizes
- App description and keywords
- Privacy policy and terms of service

**App Review Guidelines:**
- Ensure compliance with Islamic content guidelines
- Test all notification features
- Verify location permission flows
- Test audio playback functionality

### 2. Google Play Store

**Play Console:**
- App information and metadata
- Screenshots and promotional graphics
- App description and keywords
- Content rating and privacy policy

**Play Store Guidelines:**
- Ensure compliance with Islamic content policies
- Test notification channels
- Verify permission handling
- Test audio file integration

## Testing Platform Features

### 1. Unit Tests

**Platform Configuration Tests:**
- Platform detection methods
- Notification channel setup
- Permission handling
- Audio file path resolution
- Error handling scenarios

**Location Service Tests:**
- Location permission flows
- GPS accuracy testing
- Background location handling
- Permission state changes

### 2. Integration Tests

**Permission Flow Tests:**
- Complete permission request flows
- Permission denial handling
- App lifecycle permission management
- Platform-specific permission behaviors

**Notification Tests:**
- Notification delivery testing
- Audio playback testing
- Background execution testing
- Notification channel configuration

### 3. Device Testing

**iOS Testing:**
- Test on various iOS versions
- Test notification permissions
- Test background execution
- Test audio playback

**Android Testing:**
- Test on various Android versions
- Test notification channels
- Test exact alarm permissions
- Test audio resource integration

## Troubleshooting

### 1. Common Issues

**Permission Denied:**
- Check Info.plist/AndroidManifest.xml configuration
- Verify permission descriptions
- Test permission request flows

**Notifications Not Working:**
- Check notification channel configuration
- Verify audio file paths
- Test background execution permissions

**Audio Playback Issues:**
- Check audio file formats and quality
- Verify platform-specific audio paths
- Test audio file accessibility

**Build Issues:**
- Check ProGuard rules
- Verify keystore configuration
- Test signing configuration

### 2. Platform-Specific Issues

**iOS Issues:**
- Check provisioning profile capabilities
- Verify background modes configuration
- Test App Transport Security settings

**Android Issues:**
- Check notification channel setup
- Verify exact alarm permissions
- Test ProGuard obfuscation rules

### 3. Debugging Tools

**iOS Debugging:**
- Xcode console logs
- iOS Simulator testing
- Device testing with Xcode

**Android Debugging:**
- Android Studio logcat
- Android Emulator testing
- Device testing with ADB

## Security Considerations

### 1. Data Protection

**Location Data:**
- Minimize location data collection
- Secure location data storage
- Respect user privacy preferences

**Audio Files:**
- Use licensed audio content
- Respect copyright and cultural sensitivity
- Optimize file sizes for security

### 2. App Security

**Code Obfuscation:**
- ProGuard/R8 configuration
- Protect sensitive code
- Maintain functionality

**Signing Security:**
- Secure keystore management
- Strong password policies
- Backup and recovery procedures

## Conclusion

This comprehensive platform setup ensures that HijriMinder is properly configured for both iOS and Android platforms, with all necessary permissions, notifications, audio integration, and app store compliance. The configuration supports the app's core functionality while maintaining security and user privacy.

For additional support or questions about platform configuration, refer to the Flutter documentation, platform-specific developer guides, or contact the development team.
