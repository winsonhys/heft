/// Test configuration that can override AppConfig values for integration tests.
///
/// This allows tests to point to a different backend (e.g., Docker test environment)
/// without modifying the main AppConfig.
class TestConfig {
  TestConfig._();

  /// Backend URL for integration tests (Docker environment)
  static String backendUrl = 'http://localhost:8080';

  /// Test user ID (matches seed data)
  static String testUserId = '00000000-0000-0000-0000-000000000001';

  /// Configure test settings
  static void configure({String? backendUrl, String? testUserId}) {
    if (backendUrl != null) TestConfig.backendUrl = backendUrl;
    if (testUserId != null) TestConfig.testUserId = testUserId;
  }

  /// Reset to defaults
  static void reset() {
    backendUrl = 'http://localhost:8080';
    testUserId = '00000000-0000-0000-0000-000000000001';
  }
}
