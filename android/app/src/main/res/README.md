# Android App Icon Requirements for HijriMinder

This document outlines the requirements for the Android app icons in the HijriMinder application.

## Required Icon Sizes

The following icon sizes are required for Android app submission:

### Density-Specific Icons
- **mipmap-mdpi/ic_launcher.png** - 48x48 pixels (160 dpi)
- **mipmap-hdpi/ic_launcher.png** - 72x72 pixels (240 dpi)
- **mipmap-xhdpi/ic_launcher.png** - 96x96 pixels (320 dpi)
- **mipmap-xxhdpi/ic_launcher.png** - 144x144 pixels (480 dpi)
- **mipmap-xxxhdpi/ic_launcher.png** - 192x192 pixels (640 dpi)

### Play Store Icon
- **512x512** pixels - Google Play Store listing

## Design Guidelines

### Islamic Theme Considerations
- Use culturally appropriate Islamic symbols (crescent moon, mosque silhouette, prayer beads)
- Avoid depicting human figures or faces
- Use respectful and dignified imagery
- Consider RTL (right-to-left) language support in design

### Color Scheme
- Primary colors: Deep green (#2E7D32), Gold (#FFD700), or Navy blue (#1976D2)
- Secondary colors: White (#FFFFFF), Light gray (#F5F5F5)
- Ensure good contrast for accessibility
- Avoid overly bright or flashy colors

### Design Principles
- Keep design simple and recognizable at small sizes
- Use clear, bold shapes that work well at 48x48 pixels
- Ensure the icon is distinguishable from other Islamic apps
- Test icon visibility on various backgrounds and themes

## Technical Requirements
- Format: PNG with transparency support
- Color space: sRGB
- No rounded corners (Android will apply them automatically)
- No drop shadows or effects (Android will apply them automatically)
- High quality, crisp edges
- Optimized file size for mobile devices

## File Locations
Replace the existing placeholder icons in:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

## Brand Identity
The HijriMinder app icon should represent:
- Islamic calendar and timekeeping
- Prayer and spiritual connection
- Community and global Muslim unity
- Modern, clean, and professional appearance

## Cultural Sensitivity
- Ensure the design is respectful to all Islamic traditions
- Avoid controversial symbols or interpretations
- Consider global Muslim community diversity
- Test with community members for cultural appropriateness

## Current Status
The existing icon files are Flutter default placeholders and must be replaced with the actual HijriMinder app icon before release.
