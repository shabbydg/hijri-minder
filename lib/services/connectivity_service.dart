import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

/// Service for managing network connectivity status
/// Provides methods to check network availability and monitor connectivity changes
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isOnline = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Timer? _connectivityTimer;

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Initialize connectivity monitoring
  void initialize() {
    _startConnectivityMonitoring();
  }

  /// Start monitoring connectivity status
  void _startConnectivityMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkConnectivity();
    });
    
    // Initial check
    _checkConnectivity();
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final bool wasOnline = _isOnline;
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (wasOnline != _isOnline) {
        _connectivityController.add(_isOnline);
        debugPrint('ConnectivityService: Connectivity changed to ${_isOnline ? 'online' : 'offline'}');
      }
    } catch (e) {
      final bool wasOnline = _isOnline;
      _isOnline = false;
      
      if (wasOnline != _isOnline) {
        _connectivityController.add(_isOnline);
        debugPrint('ConnectivityService: Connectivity changed to offline due to error: $e');
      }
    }
  }

  /// Check connectivity status once
  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('ConnectivityService: Error checking connectivity: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivityController.close();
  }
}