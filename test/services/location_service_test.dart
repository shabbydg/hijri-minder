import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('LocationService Tests', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService();
    });

    test('should return fallback location when needed', () {
      final fallbackLocation = locationService.getFallbackLocation();
      
      expect(fallbackLocation['latitude'], equals(6.9271));
      expect(fallbackLocation['longitude'], equals(79.8612));
      expect(fallbackLocation['name'], equals('Colombo, Sri Lanka'));
    });

    test('should calculate distance between coordinates', () {
      const double lat1 = 6.9271; // Colombo
      const double lon1 = 79.8612;
      const double lat2 = 24.7136; // Riyadh
      const double lon2 = 46.6753;

      final distance = locationService.calculateDistance(lat1, lon1, lat2, lon2);
      
      expect(distance, greaterThan(0));
      expect(distance, isA<double>());
    });

    test('should format location name from coordinates', () {
      const double lat = 6.9271;
      const double lon = 79.8612;

      final locationName = locationService.getLocationName(lat, lon);
      
      expect(locationName, contains('6.9271'));
      expect(locationName, contains('79.8612'));
    });

    test('should get best available location', () async {
      final location = await locationService.getBestAvailableLocation();
      
      expect(location, isA<Map<String, dynamic>>());
      expect(location.containsKey('latitude'), isTrue);
      expect(location.containsKey('longitude'), isTrue);
      expect(location.containsKey('name'), isTrue);
    });
  });
}