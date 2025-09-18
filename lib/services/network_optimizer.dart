import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'performance_service.dart';
import 'logging_service.dart';
import 'connectivity_service.dart';

/// Network optimization service for efficient API calls
/// Provides request batching, caching, and retry mechanisms
class NetworkOptimizer {
  static final NetworkOptimizer _instance = NetworkOptimizer._internal();
  factory NetworkOptimizer() => _instance;
  NetworkOptimizer._internal();

  final PerformanceService _performanceService = PerformanceService();

  final ConnectivityService _connectivityService = ConnectivityService();
  
  // Request batching
  final Map<String, List<_BatchRequest>> _pendingBatches = {};
  final Map<String, Timer> _batchTimers = {};
  
  // Request deduplication
  final Map<String, Future<http.Response>> _ongoingRequests = {};
  
  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);
  
  bool _initialized = false;

  /// Initialize network optimizer
  Future<void> initialize() async {
    if (_initialized) return;
    
    debugPrint('NetworkOptimizer: Initializing network optimization...');
    _initialized = true;
    debugPrint('NetworkOptimizer: Network optimization initialized');
  }

  /// Make an optimized HTTP GET request with batching and deduplication
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
    bool enableBatching = true,
    String? batchKey,
  }) async {
    return await _performanceService.timeOperation(
      'network_get_request',
      () async {
        // Check for ongoing identical request (deduplication)
        final requestKey = _generateRequestKey('GET', url, headers);
        if (_ongoingRequests.containsKey(requestKey)) {
          debugPrint('NetworkOptimizer: Deduplicating request for $url');
          return await _ongoingRequests[requestKey]!;
        }

        // Create the request future
        final requestFuture = _makeRequest(
          'GET',
          url,
          headers: headers,
          timeout: timeout ?? const Duration(seconds: 30),
        );
        
        // Store for deduplication
        _ongoingRequests[requestKey] = requestFuture;
        
        try {
          final response = await requestFuture;
          return response;
        } finally {
          // Remove from ongoing requests
          _ongoingRequests.remove(requestKey);
        }
      },
      metadata: {
        'url': url,
        'method': 'GET',
        'enableBatching': enableBatching,
      },
    );
  }

  /// Make an optimized HTTP POST request
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    return await _performanceService.timeOperation(
      'network_post_request',
      () async {
        return await _makeRequest(
          'POST',
          url,
          headers: headers,
          body: body,
          encoding: encoding,
          timeout: timeout ?? const Duration(seconds: 30),
        );
      },
      metadata: {
        'url': url,
        'method': 'POST',
      },
    );
  }

  /// Batch multiple GET requests for better efficiency
  Future<List<http.Response>> batchGet(
    List<String> urls, {
    Map<String, String>? headers,
    Duration? timeout,
    int? concurrency,
  }) async {
    return await _performanceService.timeOperation(
      'network_batch_get',
      () async {
        final futures = urls.map((url) => get(
          url,
          headers: headers,
          timeout: timeout,
          enableBatching: false, // Already batching at this level
        )).toList();
        
        if (concurrency != null && concurrency > 0) {
          // Process with limited concurrency
          final results = <http.Response>[];
          for (int i = 0; i < futures.length; i += concurrency) {
            final batch = futures.skip(i).take(concurrency);
            final batchResults = await Future.wait(batch);
            results.addAll(batchResults);
          }
          return results;
        } else {
          // Process all concurrently
          return await Future.wait(futures);
        }
      },
      metadata: {
        'urlCount': urls.length,
        'concurrency': concurrency,
      },
    );
  }

  /// Make HTTP request with retry logic and error handling
  Future<http.Response> _makeRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    required Duration timeout,
  }) async {
    if (!_connectivityService.isOnline) {
      throw Exception('No internet connection available');
    }

    Exception? lastException;
    
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final uri = Uri.parse(url);
        http.Response response;
        
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers).timeout(timeout);
            break;
          case 'POST':
            response = await http.post(
              uri,
              headers: headers,
              body: body,
              encoding: encoding,
            ).timeout(timeout);
            break;
          default:
            throw UnsupportedError('HTTP method $method not supported');
        }
        
        // Log successful request
        debugPrint('NetworkOptimizer: ${response.statusCode} $method $url');
        
        // Check for HTTP errors
        if (response.statusCode >= 400) {
          throw HttpException(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            response.statusCode,
          );
        }
        
        return response;
        
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        // Don't retry on certain errors
        if (e is HttpException && e.statusCode >= 400 && e.statusCode < 500) {
          break; // Client errors shouldn't be retried
        }
        
        if (attempt < _maxRetries) {
          final delay = _calculateRetryDelay(attempt);
          debugPrint('NetworkOptimizer: Retrying $method $url in ${delay.inMilliseconds}ms (attempt ${attempt + 1}/$_maxRetries)');
          await Future.delayed(delay);
        }
      }
    }
    
    // Log failed request
    LoggingService.logError(
      'Network request failed after ${_maxRetries + 1} attempts',
      details: '$method $url',
      context: {'lastException': lastException.toString()},
    );
    
    throw lastException!;
  }

  /// Calculate exponential backoff delay for retries
  Duration _calculateRetryDelay(int attempt) {
    final multiplier = (1 << attempt); // 2^attempt
    return Duration(
      milliseconds: (_baseRetryDelay.inMilliseconds * multiplier).clamp(
        _baseRetryDelay.inMilliseconds,
        10000, // Max 10 seconds
      ),
    );
  }

  /// Generate unique key for request deduplication
  String _generateRequestKey(String method, String url, Map<String, String>? headers) {
    final headersStr = headers?.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',') ?? '';
    return '$method:$url:$headersStr';
  }

  /// Get network statistics
  Map<String, dynamic> getNetworkStats() {
    return {
      'ongoingRequests': _ongoingRequests.length,
      'pendingBatches': _pendingBatches.length,
      'isOnline': _connectivityService.isOnline,
    };
  }

  /// Clear all pending requests and batches
  void clearPendingRequests() {
    _ongoingRequests.clear();
    _pendingBatches.clear();
    
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();
    
    debugPrint('NetworkOptimizer: Cleared all pending requests');
  }

  /// Dispose of network optimizer
  void dispose() {
    clearPendingRequests();
  }
}

/// Batch request container
class _BatchRequest {
  final String url;
  final Map<String, String>? headers;
  final Completer<http.Response> completer = Completer<http.Response>();

  _BatchRequest(this.url, this.headers);
}

/// HTTP exception with status code
class HttpException implements Exception {
  final String message;
  final int statusCode;

  const HttpException(this.message, this.statusCode);

  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}

/// Network request configuration
class NetworkConfig {
  final Duration timeout;
  final int maxRetries;
  final Duration baseRetryDelay;
  final int maxConcurrency;
  final bool enableDeduplication;
  final bool enableBatching;

  const NetworkConfig({
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.baseRetryDelay = const Duration(seconds: 1),
    this.maxConcurrency = 5,
    this.enableDeduplication = true,
    this.enableBatching = true,
  });
}