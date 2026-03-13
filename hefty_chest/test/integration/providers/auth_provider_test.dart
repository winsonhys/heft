import 'package:connectrpc/test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/gen/auth.connect.spec.dart' as auth_specs;
import 'package:hefty_chest/gen/user.connect.spec.dart' as user_specs;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Auth Provider - Mock Tests', () {
    test('logout clears authentication state', () async {
      // Set up SharedPreferences with mock auth data
      SharedPreferences.setMockInitialValues({
        'auth_token': 'mock-token',
        'user_id': 'mock-user-id',
      });

      final container = ProviderContainer();
      final authNotifier = container.read(authProvider.notifier);

      // Wait for _loadSavedAuth() to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(authProvider).isAuthenticated, isTrue);

      // Logout
      await authNotifier.logout();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(state.userId, isNull);

      container.dispose();
    });

    test('currentUserId provider returns correct value', () async {
      // Pre-populate SharedPreferences so _loadSavedAuth() loads mock state
      SharedPreferences.setMockInitialValues({
        'auth_token': 'mock-token',
        'user_id': 'mock-user-123',
      });
      final container = ProviderContainer();

      // Trigger auth provider creation (starts async _loadSavedAuth())
      container.read(authProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(currentUserIdProvider), equals('mock-user-123'));

      // After logout - should be null
      await container.read(authProvider.notifier).logout();
      expect(container.read(currentUserIdProvider), isNull);

      container.dispose();
    });

    test('authToken provider returns correct value', () async {
      // Pre-populate SharedPreferences so _loadSavedAuth() loads mock state
      SharedPreferences.setMockInitialValues({
        'auth_token': 'mock-token-456',
        'user_id': 'mock-user',
      });
      final container = ProviderContainer();

      // Trigger auth provider creation (starts async _loadSavedAuth())
      container.read(authProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(container.read(authTokenProvider), equals('mock-token-456'));

      // After logout - should be null
      await container.read(authProvider.notifier).logout();
      expect(container.read(authTokenProvider), isNull);

      container.dispose();
    });
  });

  group('Auth Provider - Contract Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      final transport = (FakeTransportBuilder()
            ..unary(auth_specs.AuthService.login, (req, ctx) {
              return LoginResponse()
                ..token = 'fake-token-abc'
                ..userId = 'fake-user-123';
            })
            ..unary(user_specs.UserService.getProfile, (req, ctx) {
              return GetProfileResponse()
                ..user = (User()
                  ..id = 'fake-user-123'
                  ..email = 'test@example.com');
            }))
          .build();

      useTestTransport(transport);
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
      resetTransport();
    });

    test('authenticated request works with token', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Login to get token
      await authNotifier.login('test@example.com');

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);

      // Set up the token provider so the interceptor can access the token
      setTokenProvider(() => container.read(authProvider).token);

      // Make an authenticated request using the token
      final profileRequest = GetProfileRequest();
      final response = await userClient.getProfile(profileRequest);

      expect(response.user, isNotNull);
      expect(response.user.id, equals(state.userId));
    });

    test('token persists in SharedPreferences', () async {
      final authNotifier = container.read(authProvider.notifier);

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Login
      await authNotifier.login('test@example.com');

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);

      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), equals(state.token));
      expect(prefs.getString('user_id'), equals(state.userId));
    });
  });
}
