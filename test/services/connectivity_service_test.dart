import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_minder/services/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    late ConnectivityService connectivityService;

    setUp(() {
      connectivityService = ConnectivityService();
    });

    tearDown(() {
      connectivityService.dispose();
    });

    test('should initialize with default online status', () {
      expect(connectivityService.isOnline, isTrue);
    });

    test('should provide connectivity stream', () {
      expect(connectivityService.connectivityStream, isA<Stream<bool>>());
    });

    test('should check connectivity status', () async {
      final isOnline = await connectivityService.checkConnectivity();
      expect(isOnline, isA<bool>());
    });

    test('should initialize connectivity monitoring', () {
      expect(() => connectivityService.initialize(), returnsNormally);
    });

    test('should dispose resources properly', () {
      connectivityService.initialize();
      expect(() => connectivityService.dispose(), returnsNormally);
    });
  });
}