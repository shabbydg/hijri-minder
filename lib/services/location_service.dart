import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

/// Service for handling location permissions and coordinate management
/// Provides methods for location access, permission handling, and fallback coordinates
class LocationService {
  static const double _fallbackLatitude = 6.9271; // Colombo, Sri Lanka
  static const double _fallbackLongitude = 79.8612;
  static const String _fallbackLocationName = "Colombo, Sri Lanka";

  /// Request location permission with user dialog
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestLocationPermissionWithDialog() async {
    return await ErrorHandler.withFallback<bool>(
      () async {
        // Check if location services are enabled
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          ErrorHandler.logError(
            'Location services are disabled',
            type: ErrorType.location,
            severity: ErrorSeverity.medium,
          );
          return false;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            ErrorHandler.logError(
              'Location permission denied by user',
              type: ErrorType.permission,
              severity: ErrorSeverity.medium,
            );
            return false;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          ErrorHandler.logError(
            'Location permission denied forever',
            type: ErrorType.permission,
            severity: ErrorSeverity.high,
            context: {'action_required': 'User must enable in settings'},
          );
          return false;
        }

        return true;
      },
      () => false,
      'request location permission',
      errorType: ErrorType.permission,
      severity: ErrorSeverity.medium,
    );
  }

  /// Get current location coordinates
  /// Returns Position if successful, null if failed
  Future<Position?> getCurrentLocation() async {
    return await ErrorHandler.withFallback<Position?>(
      () async {
        final hasPermission = await hasValidLocationPermissions();
        if (!hasPermission) {
          ErrorHandler.logError(
            'Cannot get location: insufficient permissions',
            type: ErrorType.permission,
            severity: ErrorSeverity.medium,
          );
          return null;
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        
        return position;
      },
      () => null,
      'get current location',
      errorType: ErrorType.location,
      severity: ErrorSeverity.medium,
    );
  }

  /// Check if location services are enabled
  /// Returns true if enabled, false otherwise
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get last known location as fallback
  /// Returns Position if available, null otherwise
  Future<Position?> getLastKnownLocation() async {
    try {
      bool hasPermission = await hasValidLocationPermissions();
      if (!hasPermission) {
        return null;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      debugPrint('LocationService: Error getting last known location: $e');
      return null;
    }
  }

  /// Check if app has valid location permissions
  /// Returns true if permissions are granted, false otherwise
  Future<bool> hasValidLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Calculate distance between two coordinates in meters
  /// Returns distance in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get readable location name from coordinates
  /// Returns formatted location name string
  String getLocationName(double latitude, double longitude) {
    // For now, return a simple formatted string
    // In a full implementation, this could use reverse geocoding
    return "${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}";
  }

  /// Get fallback coordinates when location is unavailable
  /// Returns Map with latitude and longitude for Colombo, Sri Lanka
  Map<String, dynamic> getFallbackLocation() {
    return {
      'latitude': _fallbackLatitude,
      'longitude': _fallbackLongitude,
      'name': _fallbackLocationName,
    };
  }

  /// Get best available location (current, last known, or fallback)
  /// Returns Map with latitude, longitude, and name
  Future<Map<String, dynamic>> getBestAvailableLocation() async {
    return await ErrorHandler.withFallback<Map<String, dynamic>>(
      () async {
        // Try current location first
        Position? currentPosition = await getCurrentLocation();
        if (currentPosition != null) {
          return {
            'latitude': currentPosition.latitude,
            'longitude': currentPosition.longitude,
            'name': getLocationName(currentPosition.latitude, currentPosition.longitude),
          };
        }

        // Try last known location
        Position? lastKnownPosition = await getLastKnownLocation();
        if (lastKnownPosition != null) {
          return {
            'latitude': lastKnownPosition.latitude,
            'longitude': lastKnownPosition.longitude,
            'name': getLocationName(lastKnownPosition.latitude, lastKnownPosition.longitude),
          };
        }

        // If no location available, use fallback
        ErrorHandler.logError(
          'No location available, using fallback coordinates',
          type: ErrorType.location,
          severity: ErrorSeverity.low,
          context: {'fallback': 'Colombo, Sri Lanka'},
        );
        
        return getFallbackLocation();
      },
      () => getFallbackLocation(),
      'get best available location',
      errorType: ErrorType.location,
      severity: ErrorSeverity.low,
    );
  }
}