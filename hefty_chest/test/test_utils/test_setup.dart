import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hefty_chest/core/client.dart';

/// Setup utilities for integration tests.
///
/// Integration tests require a running backend. Use Docker Compose
/// to start the test environment before running tests.
class IntegrationTestSetup {
  IntegrationTestSetup._();

  /// Backend URL for integration tests
  static const backendUrl = 'http://localhost:8080';

  /// Test user email for authentication
  static const testUserEmail = 'integration-test@example.com';

  /// Cached test user ID after login
  static String? _testUserId;

  /// Cached auth token after login
  static String? _authToken;

  /// Get the authenticated test user ID
  static String get testUserId {
    if (_testUserId == null) {
      throw StateError(
        'Test user not authenticated. Call authenticateTestUser() in setUpAll.',
      );
    }
    return _testUserId!;
  }

  /// Get the auth token
  static String? get authToken => _authToken;

  /// Wait for backend to be healthy.
  ///
  /// Polls the /health endpoint until it responds with 200 or timeout.
  static Future<void> waitForBackend({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // Enable real network requests
    HttpOverrides.global = null;

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

  /// Authenticate the test user and set up the token provider.
  ///
  /// This logs in with the test email and configures the global token
  /// provider so all subsequent API calls include the auth token.
  /// Call this in setUpAll() before running test groups.
  static Future<void> authenticateTestUser() async {
    // Login to get a token
    final request = LoginRequest()..email = testUserEmail;
    final response = await authClient.login(request);

    _authToken = response.token;
    _testUserId = response.userId;

    // Set the global token provider for the auth interceptor
    setTokenProvider(() => _authToken);

    // Also persist to SharedPreferences so the app wrapper picks it up
    // This supports both finding the token in the provider AND in the app
    // When running in flutter_tester, we need to mock initial values
    SharedPreferences.setMockInitialValues({
      'auth_token': _authToken!,
      'user_id': _testUserId!,
    });
  }

  /// Restore the test token provider.
  ///
  /// The app widget overwrites the token provider in initState.
  /// Call this in setUp() to ensure tests have access to the valid test token
  /// when using TestData helpers outside the widget tree.
  static void restoreTokenProvider() {
    if (_authToken != null) {
      setTokenProvider(() => _authToken);
      
      // Restore SharedPreferences mock values as they are cleared between tests
      SharedPreferences.setMockInitialValues({
        'auth_token': _authToken!,
        'user_id': _testUserId!,
      });
    }
  }

  /// Clear authentication state.
  ///
  /// Call this in tearDownAll() if needed.
  static void clearAuth() {
    _authToken = null;
    _testUserId = null;
    setTokenProvider(() => null);
    SharedPreferences.setMockInitialValues({});
  }

  /// Reset test database to clean state.
  ///
  /// Calls the /test/reset endpoint which truncates user-generated data
  /// while keeping seed data (users, categories, system exercises).
  /// This endpoint is only available when backend runs with TEST_MODE=true.
  /// Call this in setUpAll() before running test groups.
  static Future<void> resetDatabase() async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$backendUrl/test/reset'));
      final response = await request.close();
      if (response.statusCode == 404) {
        // Test mode not enabled - skip reset (tests may have stale data)
        print('Warning: /test/reset not available. Run tests via run_integration_tests.sh');
        return;
      }
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
