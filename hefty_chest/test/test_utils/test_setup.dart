import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Setup utilities for integration tests.
///
/// Integration tests require a running backend. Use Docker Compose
/// to start the test environment before running tests.
class IntegrationTestSetup {
  IntegrationTestSetup._();

  /// Backend URL for integration tests
  static const backendUrl = 'http://localhost:8080';

  /// Test user ID (matches seed data in migrations)
  static const testUserId = '00000000-0000-0000-0000-000000000001';

  /// Wait for backend to be healthy.
  ///
  /// Polls the /health endpoint until it responds with 200 or timeout.
  static Future<void> waitForBackend({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final client = HttpClient();
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      try {
        final request = await client.getUrl(Uri.parse('$backendUrl/health'));
        final response = await request.close();
        if (response.statusCode == 200) {
          client.close();
          return;
        }
      } catch (_) {
        // Backend not ready yet
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    client.close();
    throw Exception('Backend not available after $timeout');
  }

  /// Reset test database to clean state.
  ///
  /// Calls the /test/reset endpoint which truncates user-generated data
  /// while keeping seed data (users, categories, system exercises).
  /// Call this in setUpAll() before running test groups.
  static Future<void> resetDatabase() async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$backendUrl/test/reset'));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('Failed to reset database: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  /// Create a ProviderContainer for testing.
  ///
  /// Use this instead of ProviderScope for provider-level tests
  /// that don't need widget rendering.
  static ProviderContainer createContainer() {
    return ProviderContainer();
  }
}
