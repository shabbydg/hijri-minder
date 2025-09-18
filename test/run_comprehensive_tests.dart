#!/usr/bin/env dart

/// Comprehensive Test Runner for HijriMinder
/// 
/// This script runs all test suites in a systematic order and provides
/// detailed reporting on test results and coverage.

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  print('🚀 Starting HijriMinder Comprehensive Test Suite');
  print('=' * 60);

  final testRunner = TestRunner();
  
  try {
    await testRunner.runAllTests();
  } catch (e) {
    print('❌ Test execution failed: $e');
    exit(1);
  }
}

class TestRunner {
  final List<TestSuite> testSuites = [
    TestSuite('Unit Tests - Models', 'test/models/', timeout: 30),
    TestSuite('Unit Tests - Services', 'test/services/', timeout: 60),
    TestSuite('Unit Tests - Utils', 'test/utils/', timeout: 30),
    TestSuite('Widget Tests - Screens', 'test/screens/', timeout: 90),
    TestSuite('Widget Tests - Widgets', 'test/widgets/', timeout: 60),
    TestSuite('Integration Tests', 'test/integration/', timeout: 300),
    TestSuite('Performance Tests', 'test/performance/', timeout: 180),
    TestSuite('Accessibility Tests', 'test/accessibility/', timeout: 120),
    TestSuite('Comprehensive Suite', 'test/comprehensive_test_suite.dart', timeout: 600),
  ];

  Future<void> runAllTests() async {
    final results = <TestResult>[];
    
    for (final suite in testSuites) {
      print('\n📋 Running ${suite.name}...');
      print('-' * 40);
      
      final result = await runTestSuite(suite);
      results.add(result);
      
      if (result.success) {
        print('✅ ${suite.name} passed (${result.duration}ms)');
      } else {
        print('❌ ${suite.name} failed (${result.duration}ms)');
        print('Error: ${result.error}');
      }
    }
    
    printSummary(results);
  }

  Future<TestResult> runTestSuite(TestSuite suite) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final process = await Process.run(
        'flutter',
        ['test', suite.path, '--reporter=compact'],
        timeout: Duration(seconds: suite.timeout),
      );
      
      stopwatch.stop();
      
      return TestResult(
        suiteName: suite.name,
        success: process.exitCode == 0,
        duration: stopwatch.elapsedMilliseconds,
        output: process.stdout.toString(),
        error: process.exitCode != 0 ? process.stderr.toString() : null,
      );
    } catch (e) {
      stopwatch.stop();
      
      return TestResult(
        suiteName: suite.name,
        success: false,
        duration: stopwatch.elapsedMilliseconds,
        output: '',
        error: e.toString(),
      );
    }
  }

  void printSummary(List<TestResult> results) {
    print('\n' + '=' * 60);
    print('📊 TEST SUMMARY');
    print('=' * 60);
    
    final passed = results.where((r) => r.success).length;
    final failed = results.where((r) => !r.success).length;
    final totalDuration = results.fold<int>(0, (sum, r) => sum + r.duration);
    
    print('Total Test Suites: ${results.length}');
    print('Passed: $passed');
    print('Failed: $failed');
    print('Total Duration: ${totalDuration}ms (${(totalDuration / 1000).toStringAsFixed(2)}s)');
    
    if (failed > 0) {
      print('\n❌ FAILED SUITES:');
      for (final result in results.where((r) => !r.success)) {
        print('  - ${result.suiteName}: ${result.error}');
      }
    }
    
    print('\n📈 DETAILED RESULTS:');
    for (final result in results) {
      final status = result.success ? '✅' : '❌';
      print('  $status ${result.suiteName}: ${result.duration}ms');
    }
    
    // Generate coverage report
    generateCoverageReport();
    
    if (failed == 0) {
      print('\n🎉 All tests passed successfully!');
    } else {
      print('\n⚠️  Some tests failed. Please review the errors above.');
      exit(1);
    }
  }

  void generateCoverageReport() {
    print('\n📊 Generating coverage report...');
    
    try {
      Process.runSync('flutter', ['test', '--coverage']);
      
      final coverageFile = File('coverage/lcov.info');
      if (coverageFile.existsSync()) {
        print('✅ Coverage report generated at coverage/lcov.info');
        
        // Try to generate HTML report if genhtml is available
        try {
          Process.runSync('genhtml', [
            'coverage/lcov.info',
            '-o',
            'coverage/html',
            '--title',
            'HijriMinder Test Coverage'
          ]);
          print('✅ HTML coverage report generated at coverage/html/index.html');
        } catch (e) {
          print('ℹ️  Install genhtml to generate HTML coverage reports');
        }
      }
    } catch (e) {
      print('⚠️  Could not generate coverage report: $e');
    }
  }
}

class TestSuite {
  final String name;
  final String path;
  final int timeout;

  TestSuite(this.name, this.path, {this.timeout = 60});
}

class TestResult {
  final String suiteName;
  final bool success;
  final int duration;
  final String output;
  final String? error;

  TestResult({
    required this.suiteName,
    required this.success,
    required this.duration,
    required this.output,
    this.error,
  });
}