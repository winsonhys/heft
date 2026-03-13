import 'package:hefty_chest/features/auth/providers/auth_providers.dart';

import 'web_test_setup.dart';

/// Shared MockAuth for web integration tests.
///
/// Overrides the real Auth provider to skip SharedPreferences loading
/// and return a pre-authenticated state directly.
class MockAuth extends Auth {
  @override
  AuthState build() => AuthState(
    token: WebTestSetup.authToken,
    userId: WebTestSetup.testUserId,
    isLoading: false,
  );
}
