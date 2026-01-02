import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';

import '../../test_utils/test_setup.dart';
import '../../test_utils/test_data.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  setUp(() async {
    // Restore token provider and SharedPreferences mock for each test (required for SessionStorage)
    IntegrationTestSetup.restoreTokenProvider();
    container = IntegrationTestSetup.createContainer();
    // Clean up any leftover active sessions from previous tests
    await TestData.abandonAnyActiveSession();
  });

  tearDown(() {
    container.dispose();
  });

  group('Session Rest Items Integration', () {
    test('starting session from workout with rest item includes rest items', () async {
      // Create workout with rest item
      final workoutId = await TestData.createWorkoutWithRestItem(
        name: 'Rest Item Test Workout',
        restDurationSeconds: 90,
      );

      // Start session
      final response = await sessionClient.startSession(
        StartSessionRequest()..workoutTemplateId = workoutId,
      );

      expect(response.session.id, isNotEmpty);
      expect(response.session.restItems, isNotEmpty);
      expect(response.session.restItems.length, equals(1));

      final restItem = response.session.restItems.first;
      expect(restItem.restDurationSeconds, equals(90));
      expect(restItem.isCompleted, isFalse);
      expect(restItem.sectionName, equals('Main Set'));

      // Clean up
      await TestData.abandonSession(response.session.id);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('get session returns rest items', () async {
      // Create workout with rest item and start session
      final workoutId = await TestData.createWorkoutWithRestItem(
        restDurationSeconds: 60,
      );
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get session
      final response = await sessionClient.getSession(
        GetSessionRequest()..id = sessionId,
      );

      expect(response.session.restItems, isNotEmpty);
      expect(response.session.restItems.first.restDurationSeconds, equals(60));

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('sync session completes rest item', () async {
      // Create workout with rest item and start session
      final workoutId = await TestData.createWorkoutWithRestItem();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get session to find rest item ID
      final getResponse = await sessionClient.getSession(
        GetSessionRequest()..id = sessionId,
      );
      final restItemId = getResponse.session.restItems.first.id;

      // Sync to complete the rest item
      final syncResponse = await sessionClient.syncSession(
        SyncSessionRequest()
          ..sessionId = sessionId
          ..restItems.add(SyncRestItemData()
            ..id = restItemId
            ..isCompleted = true),
      );

      expect(syncResponse.success, isTrue);
      expect(syncResponse.session.restItems.first.isCompleted, isTrue);

      // Verify completion persisted via GetSession
      final verifyResponse = await sessionClient.getSession(
        GetSessionRequest()..id = sessionId,
      );
      expect(verifyResponse.session.restItems.first.isCompleted, isTrue);
      expect(verifyResponse.session.restItems.first.completedAt, isNotNull);

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('sync session toggles rest item completion', () async {
      // Create workout with rest item and start session
      final workoutId = await TestData.createWorkoutWithRestItem();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get session to find rest item ID
      final getResponse = await sessionClient.getSession(
        GetSessionRequest()..id = sessionId,
      );
      final restItemId = getResponse.session.restItems.first.id;

      // Step 1: Complete the rest item
      await sessionClient.syncSession(
        SyncSessionRequest()
          ..sessionId = sessionId
          ..restItems.add(SyncRestItemData()
            ..id = restItemId
            ..isCompleted = true),
      );

      // Verify it's completed
      final afterComplete = await sessionClient.getSession(
        GetSessionRequest()..id = sessionId,
      );
      expect(afterComplete.session.restItems.first.isCompleted, isTrue);

      // Step 2: Toggle back to incomplete
      await sessionClient.syncSession(
        SyncSessionRequest()
          ..sessionId = sessionId
          ..restItems.add(SyncRestItemData()
            ..id = restItemId
            ..isCompleted = false),
      );

      // Verify it's uncompleted
      final afterUncomplete = await sessionClient.getSession(
        GetSessionRequest()..id = sessionId,
      );
      expect(afterUncomplete.session.restItems.first.isCompleted, isFalse);

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('rest items have correct display order', () async {
      // Create workout with rest item (exercise at order 1, rest at order 2)
      final workoutId = await TestData.createWorkoutWithRestItem();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get session
      final response = await sessionClient.getSession(
        GetSessionRequest()..id = sessionId,
      );

      // Verify exercise is at display order 1
      expect(response.session.exercises, isNotEmpty);
      expect(response.session.exercises.first.displayOrder, equals(1));

      // Verify rest item is at display order 2
      expect(response.session.restItems, isNotEmpty);
      expect(response.session.restItems.first.displayOrder, equals(2));

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('completeRestItem via provider updates local state', () async {
      // Create workout with rest item and start session
      final workoutId = await TestData.createWorkoutWithRestItem();

      // Keep provider alive during async operations (auto-dispose protection)
      final subscription = container.listen(activeSessionProvider, (_, __) {});

      try {
        // Start session via provider
        final notifier = container.read(activeSessionProvider.notifier);
        final session = await notifier.startSession(workoutTemplateId: workoutId);

        expect(session, isNotNull);
        expect(session!.restItems, isNotEmpty);

        final restItemId = session.restItems.first.id;

        // Complete rest item via provider method
        notifier.completeRestItem(restItemId: restItemId);

        // Check local state is updated
        final updatedSession = container.read(activeSessionProvider).value;
        expect(updatedSession, isNotNull);
        final updatedRestItem = updatedSession!.restItems.firstWhere(
          (r) => r.id == restItemId,
        );
        expect(updatedRestItem.isCompleted, isTrue);

        // Clean up
        await TestData.abandonSession(session.id);
        await TestData.deleteWorkoutSafe(workoutId);
      } finally {
        subscription.close();
      }
    });

    test('completeRestItem toggle via provider', () async {
      // Create workout with rest item and start session
      final workoutId = await TestData.createWorkoutWithRestItem();

      // Keep provider alive during async operations (auto-dispose protection)
      final subscription = container.listen(activeSessionProvider, (_, __) {});

      try {
        // Start session via provider
        final notifier = container.read(activeSessionProvider.notifier);
        final session = await notifier.startSession(workoutTemplateId: workoutId);

        expect(session, isNotNull);
        final restItemId = session!.restItems.first.id;

        // Complete rest item
        notifier.completeRestItem(restItemId: restItemId);

        // Verify completed
        var currentSession = container.read(activeSessionProvider).value;
        expect(currentSession!.restItems.first.isCompleted, isTrue);

        // Toggle back to incomplete
        notifier.completeRestItem(restItemId: restItemId, toggle: true);

        // Verify uncompleted
        currentSession = container.read(activeSessionProvider).value;
        expect(currentSession!.restItems.first.isCompleted, isFalse);

        // Clean up
        await TestData.abandonSession(session.id);
        await TestData.deleteWorkoutSafe(workoutId);
      } finally {
        subscription.close();
      }
    });
  });
}
