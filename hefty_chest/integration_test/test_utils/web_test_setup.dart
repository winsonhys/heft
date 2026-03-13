import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:http/http.dart' as http;

import 'mock_auth.dart';

/// Web-safe setup for integration tests running in Chrome.
///
/// Replaces [IntegrationTestSetup] which uses dart:io (HttpClient, HttpOverrides)
/// that don't exist on web. Uses `package:http` for health checks and
/// Connect-RPC clients (already web-compatible) for auth.
class WebTestSetup {
  WebTestSetup._();

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

  /// Generate a unique name for test data to avoid collisions.
  static String uniqueName(String base) {
    return '$base ${DateTime.now().microsecondsSinceEpoch}';
  }

  /// Wait for backend to be healthy.
  ///
  /// Polls the /health endpoint via package:http (web-safe) until 200 or timeout.
  static Future<void> waitForBackend({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      try {
        final response = await http.get(Uri.parse('$backendUrl/health'));
        if (response.statusCode == 200) {
          return;
        }
      } catch (_) {
        // Backend not ready yet
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    throw Exception('Backend not available after $timeout');
  }

  /// Authenticate the test user and set up the token provider.
  ///
  /// Uses Connect-RPC authClient (web-compatible) instead of dart:io HttpClient.
  static Future<void> authenticateTestUser() async {
    final request = LoginRequest()..email = testUserEmail;
    final response = await authClient.login(request);

    _authToken = response.token;
    _testUserId = response.userId;

    // Set the global token provider for the auth interceptor
    setTokenProvider(() => _authToken);
  }

  /// Restore the test token provider.
  ///
  /// The app widget overwrites the token provider in initState.
  /// Call this in setUp() to ensure tests have access to the valid test token.
  static void restoreTokenProvider() {
    if (_authToken != null) {
      setTokenProvider(() => _authToken);
    }
  }

  /// Reset test database to clean state.
  ///
  /// Uses package:http (web-safe) instead of dart:io HttpClient.
  static Future<void> resetDatabase() async {
    final response = await http.post(Uri.parse('$backendUrl/test/reset'));
    if (response.statusCode == 404) {
      // ignore: avoid_print
      print(
        'Warning: /test/reset not available. Run tests via run_web_integration_tests.sh',
      );
      return;
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to reset database: ${response.statusCode}');
    }
  }

  /// Clear authentication state.
  static void clearAuth() {
    _authToken = null;
    _testUserId = null;
    setTokenProvider(() => null);
  }

  /// Pump the app with MockAuth and wait for initial data to load.
  ///
  /// Combines pumpWidget + async wait + pump into a single call.
  /// Wraps in tester.runAsync internally so callers don't need to.
  static Future<void> pumpAppAndWait(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(MockAuth.new)],
          child: const HeftyChestApp(),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
    });
    await tester.pump();
  }

  /// Wait for a finder to match at least one widget, pumping repeatedly.
  ///
  /// Use instead of fixed `Future.delayed` — adapts to actual load time.
  /// Falls back to a single pump after timeout if the finder never matches.
  static Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  /// Tap a widget and wait for the UI to settle with a short pump.
  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration settle = const Duration(milliseconds: 500),
  }) async {
    await tester.tap(finder);
    await tester.pump(settle);
  }

  /// Navigate to a bottom nav tab and wait for content to load.
  static Future<void> navigateToTab(
    WidgetTester tester,
    String tabLabel,
  ) async {
    await tester.tap(find.text(tabLabel));
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 1));
    });
    await tester.pump();
  }
}
