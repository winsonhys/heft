@Tags(['e2e', 'session'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';

import '../test_utils/test_setup.dart';
import '../test_utils/test_data.dart';

void main() {
  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  setUp(() {
    IntegrationTestSetup.restoreTokenProvider();
  });

  String getUniqueName(String base) {
    return '$base ${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(MockAuth.new)],
        child: const HeftyChestApp(),
      ),
    );
  }

  group('Session Notes & RPE E2E', () {
    testWidgets('RPE value syncs to backend', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('RPE Sync Test');
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        // Get session to find set IDs
        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final setId = sessionResponse.session.exercises.first.sets.first.id;

        // Sync set with RPE value
        await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = sessionId
            ..sets.add(SyncSetData()
              ..id = setId
              ..weightKg = 60.0
              ..reps = 10
              ..isCompleted = true
              ..rpe = 8.0),
        );

        // Pump app to satisfy testWidgets contract
        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        // Verify RPE value persisted via API
        final checkResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final syncedSet = checkResponse.session.exercises.first.sets.first;

        expect(syncedSet.isCompleted, isTrue);
        // RPE field is on SessionSet proto — verify it round-trips through the backend
        expect(syncedSet.rpe, equals(8.0));
        expect(syncedSet.hasRpe(), isTrue);

        // Cleanup
        await sessionClient.abandonSession(
          AbandonSessionRequest()..id = sessionId,
        );
      });
    });

    testWidgets('set notes sync to backend', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Set Notes Test');
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        // Get session to find set IDs
        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final setId = sessionResponse.session.exercises.first.sets.first.id;

        // Sync set with notes
        await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = sessionId
            ..sets.add(SyncSetData()
              ..id = setId
              ..weightKg = 50.0
              ..reps = 8
              ..isCompleted = true
              ..notes = 'Felt strong today'),
        );

        // Pump app to satisfy testWidgets contract
        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        // Verify notes persisted via API
        final checkResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final syncedSet = checkResponse.session.exercises.first.sets.first;

        expect(syncedSet.isCompleted, isTrue);
        // Notes field is on SessionSet proto — verify it round-trips through the backend
        expect(syncedSet.notes, equals('Felt strong today'));
        expect(syncedSet.hasNotes(), isTrue);

        // Cleanup
        await sessionClient.abandonSession(
          AbandonSessionRequest()..id = sessionId,
        );
      });
    });

    testWidgets('session notes persist through finish', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Session Notes Finish Test');
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        // Get session to find all set IDs
        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );

        // Complete all sets so the session can be finished
        final syncSets = <SyncSetData>[];
        for (final exercise in sessionResponse.session.exercises) {
          for (final set in exercise.sets) {
            syncSets.add(SyncSetData()
              ..id = set.id
              ..weightKg = 50.0
              ..reps = 10
              ..isCompleted = true);
          }
        }

        await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = sessionId
            ..sets.addAll(syncSets),
        );

        // Finish session with notes — FinishSessionRequest has a notes field
        const sessionNotes = 'Great workout, PRed on bench press!';
        final finishResponse = await sessionClient.finishSession(
          FinishSessionRequest()
            ..id = sessionId
            ..notes = sessionNotes,
        );

        // Pump app to satisfy testWidgets contract
        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        // Verify notes on the finished session response
        expect(
          finishResponse.session.status,
          equals(WorkoutStatus.WORKOUT_STATUS_COMPLETED),
        );
        // Session proto has a notes field — verify it persists through finish
        expect(finishResponse.session.notes, equals(sessionNotes));

        // Also verify via getSession that notes persist
        final checkResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        expect(checkResponse.session.notes, equals(sessionNotes));
      });
    });

    testWidgets('RPE value of zero means unset', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('RPE Zero Test');
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        // Get session to find set IDs
        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final setId = sessionResponse.session.exercises.first.sets.first.id;

        // Sync set without setting RPE (default proto value is 0 for double)
        await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = sessionId
            ..sets.add(SyncSetData()
              ..id = setId
              ..weightKg = 70.0
              ..reps = 5
              ..isCompleted = true),
        );

        // Pump app to satisfy testWidgets contract
        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        // Verify RPE is 0 (default/unset) via API
        final checkResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final syncedSet = checkResponse.session.exercises.first.sets.first;

        expect(syncedSet.isCompleted, isTrue);
        // Proto double default is 0.0 — RPE of 0 means unset/not recorded
        expect(syncedSet.rpe, equals(0.0));
        // hasRpe() should be false when RPE was never explicitly set
        expect(syncedSet.hasRpe(), isFalse);

        // Cleanup
        await sessionClient.abandonSession(
          AbandonSessionRequest()..id = sessionId,
        );
      });
    });

    testWidgets('multiple sets can have different RPE values', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Multi RPE Test');
        // createWorkoutWithExercise creates 2 target sets
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        // Get session to find both set IDs
        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final sets = sessionResponse.session.exercises.first.sets;
        expect(sets.length, greaterThanOrEqualTo(2),
            reason: 'Workout should have at least 2 target sets');

        final firstSetId = sets[0].id;
        final secondSetId = sets[1].id;

        // Sync both sets with different RPE values
        await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = sessionId
            ..sets.addAll([
              SyncSetData()
                ..id = firstSetId
                ..weightKg = 60.0
                ..reps = 10
                ..isCompleted = true
                ..rpe = 7.0,
              SyncSetData()
                ..id = secondSetId
                ..weightKg = 65.0
                ..reps = 8
                ..isCompleted = true
                ..rpe = 9.5,
            ]),
        );

        // Pump app to satisfy testWidgets contract
        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        // Verify each set has its distinct RPE value
        final checkResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final checkedSets = checkResponse.session.exercises.first.sets;

        // Find sets by ID since order may not be guaranteed
        final firstSet = checkedSets.firstWhere((s) => s.id == firstSetId);
        final secondSet = checkedSets.firstWhere((s) => s.id == secondSetId);

        expect(firstSet.rpe, equals(7.0));
        expect(firstSet.hasRpe(), isTrue);
        expect(firstSet.weightKg, equals(60.0));
        expect(firstSet.reps, equals(10));

        expect(secondSet.rpe, equals(9.5));
        expect(secondSet.hasRpe(), isTrue);
        expect(secondSet.weightKg, equals(65.0));
        expect(secondSet.reps, equals(8));

        // Cleanup
        await sessionClient.abandonSession(
          AbandonSessionRequest()..id = sessionId,
        );
      });
    });
  });
}

class MockAuth extends Auth {
  @override
  AuthState build() {
    return AuthState(
      token: IntegrationTestSetup.authToken,
      userId: IntegrationTestSetup.testUserId,
      isLoading: false,
    );
  }
}
