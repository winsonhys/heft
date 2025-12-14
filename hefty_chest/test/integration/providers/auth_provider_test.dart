import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_utils/test_setup.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    await IntegrationTestSetup.waitForBackend();
  });

  setUp(() {
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
    container = IntegrationTestSetup.createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthService Integration', () {
    test('login creates new user and returns token', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Login with a unique email
      final email = 'test-${DateTime.now().millisecondsSinceEpoch}@example.com';
      final success = await authNotifier.login(email);

      expect(success, isTrue);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.token, isNotNull);
      expect(state.token, isNotEmpty);
      expect(state.userId, isNotNull);
      expect(state.userId, isNotEmpty);
      expect(state.error, isNull);
    });

    test('login returns existing user for known email', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Login twice with the same email
      final email = 'returning-${DateTime.now().millisecondsSinceEpoch}@example.com';

      final success1 = await authNotifier.login(email);
      expect(success1, isTrue);

      final state1 = container.read(authProvider);
      final userId1 = state1.userId;

      // Logout
      await authNotifier.logout();

      // Login again with same email
      final success2 = await authNotifier.login(email);
      expect(success2, isTrue);

      final state2 = container.read(authProvider);
      expect(state2.userId, equals(userId1)); // Same user
    });

    test('login fails with invalid email', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await authNotifier.login('invalid-email');

      expect(success, isFalse);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.error, isNotNull);
    });

    test('login fails with empty email', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await authNotifier.login('');

      expect(success, isFalse);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.error, isNotNull);
    });

    test('logout clears authentication state', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Login first
      final email = 'logout-test-${DateTime.now().millisecondsSinceEpoch}@example.com';
      await authNotifier.login(email);

      expect(container.read(authProvider).isAuthenticated, isTrue);

      // Logout
      await authNotifier.logout();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(state.userId, isNull);
    });

    test('authenticated request works with token', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Login to get token
      final email = 'auth-request-${DateTime.now().millisecondsSinceEpoch}@example.com';
      await authNotifier.login(email);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);

      // Set up the token provider so the interceptor can access the token
      // In the actual app, this is typically done when setting up providers
      setTokenProvider(() => container.read(authProvider).token);

      // Make an authenticated request using the token
      // The auth interceptor should automatically add the token
      final profileRequest = GetProfileRequest();

      // This should succeed because we're authenticated
      final response = await userClient.getProfile(profileRequest);

      expect(response.user, isNotNull);
      expect(response.user.id, equals(state.userId));
    });

    test('token persists in SharedPreferences', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Login
      final email = 'persist-${DateTime.now().millisecondsSinceEpoch}@example.com';
      await authNotifier.login(email);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);

      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), equals(state.token));
      expect(prefs.getString('user_id'), equals(state.userId));
    });

    test('currentUserId provider returns correct value', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Before login - should be null
      expect(container.read(currentUserIdProvider), isNull);

      // Login
      final email = 'userid-${DateTime.now().millisecondsSinceEpoch}@example.com';
      await authNotifier.login(email);

      final authState = container.read(authProvider);
      expect(container.read(currentUserIdProvider), equals(authState.userId));

      // After logout - should be null again
      await authNotifier.logout();
      expect(container.read(currentUserIdProvider), isNull);
    });

    test('authToken provider returns correct value', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Before login - should be null
      expect(container.read(authTokenProvider), isNull);

      // Login
      final email = 'token-${DateTime.now().millisecondsSinceEpoch}@example.com';
      await authNotifier.login(email);

      final authState = container.read(authProvider);
      expect(container.read(authTokenProvider), equals(authState.token));

      // After logout - should be null again
      await authNotifier.logout();
      expect(container.read(authTokenProvider), isNull);
    });
  });
}
