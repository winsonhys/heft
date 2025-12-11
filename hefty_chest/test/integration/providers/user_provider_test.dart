import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/profile/providers/profile_providers.dart';

import '../../test_utils/test_setup.dart';
import '../../test_utils/test_data.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
  });

  setUp(() {
    container = IntegrationTestSetup.createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('UserService Integration', () {
    test('fetches user profile successfully', () async {
      final profile = await container.read(userProfileProvider.future);

      expect(profile, isNotNull);
      expect(profile.id, equals(TestData.testUserId));
    });

    test('fetches profile stats from dashboard', () async {
      final stats = await container.read(profileStatsProvider.future);

      expect(stats, isNotNull);
      expect(stats.totalWorkouts, isNonNegative);
    });

    test('updates user settings', () async {
      // Get current settings via direct client call
      final getRequest = GetProfileRequest()..userId = TestData.testUserId;
      final profileResponse = await userClient.getProfile(getRequest);
      final originalUsePounds = profileResponse.user.usePounds;
      final originalRestTimer = profileResponse.user.restTimerSeconds;

      // Update settings to opposite values
      final updateRequest = UpdateSettingsRequest()
        ..userId = TestData.testUserId
        ..usePounds = !originalUsePounds
        ..restTimerSeconds = 120;

      final updateResponse = await userClient.updateSettings(updateRequest);

      expect(updateResponse.user.usePounds, equals(!originalUsePounds));
      expect(updateResponse.user.restTimerSeconds, equals(120));

      // Restore original settings
      final restoreRequest = UpdateSettingsRequest()
        ..userId = TestData.testUserId
        ..usePounds = originalUsePounds
        ..restTimerSeconds = originalRestTimer;

      await userClient.updateSettings(restoreRequest);
    });

    test('user settings notifier updates settings', () async {
      // Get notifier
      final notifier = container.read(userSettingsProvider.notifier);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 500));

      // Get current state
      final currentState = container.read(userSettingsProvider);
      final currentUser = currentState.value;
      expect(currentUser, isNotNull);

      final originalRestTimer = currentUser!.restTimerSeconds;

      // Update rest timer
      await notifier.updateSettings(restTimerSeconds: 180);

      // Wait for update
      await Future.delayed(const Duration(milliseconds: 300));

      final updatedState = container.read(userSettingsProvider);
      expect(updatedState.value?.restTimerSeconds, equals(180));

      // Restore original
      await notifier.updateSettings(restTimerSeconds: originalRestTimer);
    });

    test('logs weight successfully', () async {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final request = LogWeightRequest()
        ..userId = TestData.testUserId
        ..weightKg = 75.5
        ..loggedDate = dateStr
        ..notes = 'Integration test weight log';

      final response = await userClient.logWeight(request);

      expect(response.weightLog, isNotNull);
      expect(response.weightLog.weightKg, equals(75.5));
      expect(response.weightLog.notes, equals('Integration test weight log'));

      // Clean up - delete the weight log
      final deleteRequest = DeleteWeightLogRequest()
        ..id = response.weightLog.id
        ..userId = TestData.testUserId;

      await userClient.deleteWeightLog(deleteRequest);
    });

    test('retrieves weight history', () async {
      // First log a weight
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final logRequest = LogWeightRequest()
        ..userId = TestData.testUserId
        ..weightKg = 80.0
        ..loggedDate = dateStr
        ..notes = 'Test weight for history';

      final logResponse = await userClient.logWeight(logRequest);

      // Get history
      final historyRequest = GetWeightHistoryRequest()
        ..userId = TestData.testUserId;

      final historyResponse = await userClient.getWeightHistory(historyRequest);

      expect(historyResponse.weightLogs, isNotEmpty);
      expect(
        historyResponse.weightLogs.any((log) => log.id == logResponse.weightLog.id),
        isTrue,
      );

      // Clean up
      final deleteRequest = DeleteWeightLogRequest()
        ..id = logResponse.weightLog.id
        ..userId = TestData.testUserId;

      await userClient.deleteWeightLog(deleteRequest);
    });
  });
}
