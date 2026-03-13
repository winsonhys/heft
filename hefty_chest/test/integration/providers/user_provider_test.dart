import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/profile/providers/profile_providers.dart';

void main() {
  group('User Provider - Mock Tests', () {
    test('fetches user profile successfully', () async {
      final mockProfile = User()
        ..id = 'mock-user-123'
        ..email = 'test@example.com';

      final container = ProviderContainer(overrides: [
        userProfileProvider.overrideWith((ref) async => mockProfile),
      ]);

      final profile = await container.read(userProfileProvider.future);

      expect(profile, isNotNull);
      expect(profile.id, equals('mock-user-123'));

      container.dispose();
    });
  });
}
