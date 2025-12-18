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

  setUp(() {
    container = IntegrationTestSetup.createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SessionService Integration', () {
    test('starts session from workout template', () async {
      // Create workout with exercise
      final workoutId = await TestData.createWorkoutWithExercise();

      // Start session
      final request = StartSessionRequest()
        ..userId = TestData.testUserId
        ..workoutTemplateId = workoutId;

      final response = await sessionClient.startSession(request);

      expect(response.session.id, isNotEmpty);
      expect(
        response.session.status,
        equals(WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS),
      );
      expect(response.session.workoutTemplateId, equals(workoutId));

      // Clean up - abandon session first, then try to delete workout
      await TestData.abandonSession(response.session.id);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('gets session details', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get session
      final request = GetSessionRequest()
        ..id = sessionId
        ..userId = TestData.testUserId;

      final response = await sessionClient.getSession(request);

      expect(response.session.id, equals(sessionId));
      expect(response.session.exercises, isNotEmpty);
      expect(response.session.exercises.first.sets, isNotEmpty);

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('syncs session with completed sets', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get session to find a set
      final getRequest = GetSessionRequest()
        ..id = sessionId
        ..userId = TestData.testUserId;

      final getResponse = await sessionClient.getSession(getRequest);
      final firstSet = getResponse.session.exercises.first.sets.first;

      // Sync the session with the set completed
      final syncRequest = SyncSessionRequest()
        ..sessionId = sessionId
        ..sets.add(SyncSetData()
          ..setId = firstSet.id
          ..weightKg = 50.0
          ..reps = 10
          ..isCompleted = true);

      final syncResponse = await sessionClient.syncSession(syncRequest);

      expect(syncResponse.success, isTrue);
      final updatedSet = syncResponse.session.exercises.first.sets.first;
      expect(updatedSet.isCompleted, isTrue);
      expect(updatedSet.weightKg, equals(50.0));
      expect(updatedSet.reps, equals(10));

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('syncs session without completing sets', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get session to find a set
      final getRequest = GetSessionRequest()
        ..id = sessionId
        ..userId = TestData.testUserId;

      final getResponse = await sessionClient.getSession(getRequest);
      final firstSet = getResponse.session.exercises.first.sets.first;

      // Sync the session with updated values but not completed
      final syncRequest = SyncSessionRequest()
        ..sessionId = sessionId
        ..sets.add(SyncSetData()
          ..setId = firstSet.id
          ..weightKg = 55.0
          ..reps = 8
          ..isCompleted = false);

      final syncResponse = await sessionClient.syncSession(syncRequest);

      expect(syncResponse.success, isTrue);
      final updatedSet = syncResponse.session.exercises.first.sets.first;
      expect(updatedSet.weightKg, equals(55.0));
      expect(updatedSet.reps, equals(8));
      expect(updatedSet.isCompleted, isFalse);

      // Clean up - use deleteWorkoutSafe as abandoned sessions still reference workout
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('finishes session', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Finish session
      final request = FinishSessionRequest()
        ..id = sessionId
        ..userId = TestData.testUserId
        ..notes = 'Great workout!';

      final response = await sessionClient.finishSession(request);

      expect(
        response.session.status,
        equals(WorkoutStatus.WORKOUT_STATUS_COMPLETED),
      );

      // Note: Cannot delete workout as completed session references it
      // Workout remains in test DB for isolation reasons
    });

    test('abandons session', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Abandon session
      final request = AbandonSessionRequest()
        ..id = sessionId
        ..userId = TestData.testUserId;

      final response = await sessionClient.abandonSession(request);

      expect(response.success, isTrue);

      // Clean up - use deleteWorkoutSafe as abandoned sessions still reference workout
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('lists session history', () async {
      // Create workout and complete a session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Finish session
      await sessionClient.finishSession(
        FinishSessionRequest()
          ..id = sessionId
          ..userId = TestData.testUserId,
      );

      // List sessions
      final request = ListSessionsRequest()..userId = TestData.testUserId;

      final response = await sessionClient.listSessions(request);

      expect(response.sessions, isNotEmpty);
      expect(
        response.sessions.any((s) => s.id == sessionId),
        isTrue,
      );

      // Note: Cannot delete workout as completed session references it
    });

    test('start session via API', () async {
      // Create workout
      final workoutId = await TestData.createWorkoutWithExercise();

      // Start session via API
      final response = await sessionClient.startSession(
        StartSessionRequest()..workoutTemplateId = workoutId,
      );

      expect(response.session.id, isNotEmpty);
      expect(
        response.session.status,
        equals(WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS),
      );

      // Clean up
      await TestData.abandonSession(response.session.id);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('load existing session via API', () async {
      // Create workout and start session directly
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Load session via API
      final response = await sessionClient.getSession(
        GetSessionRequest()..id = sessionId,
      );

      expect(response.session.id, equals(sessionId));
      expect(response.session.exercises, isNotEmpty);

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('syncs set completion via API', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get session to find a set
      final sessionResponse = await sessionClient.getSession(
        GetSessionRequest()..id = sessionId,
      );
      final setId = sessionResponse.session.exercises.first.sets.first.id;

      // Complete set via sync API
      final syncRequest = SyncSessionRequest()
        ..sessionId = sessionId
        ..sets.add(SyncSetData()
          ..setId = setId
          ..weightKg = 100.0
          ..reps = 5
          ..isCompleted = true);

      final syncResponse = await sessionClient.syncSession(syncRequest);

      expect(syncResponse.success, isTrue);
      final updatedSet = syncResponse.session.exercises.first.sets.first;
      expect(updatedSet.isCompleted, isTrue);
      expect(updatedSet.weightKg, equals(100.0));
      expect(updatedSet.reps, equals(5));

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('checks for active session via provider', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Check for active session
      final activeSession = await container.read(
        hasActiveSessionProvider.future,
      );

      expect(activeSession, isNotNull);
      expect(activeSession!.id, equals(sessionId));

      // Clean up - use deleteWorkoutSafe as abandoned sessions still reference workout
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('hasActiveSessionProvider returns null after finishing session', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Verify session is active
      final activeSessionBefore = await container.read(
        hasActiveSessionProvider.future,
      );
      expect(activeSessionBefore, isNotNull);
      expect(activeSessionBefore!.id, equals(sessionId));

      // Finish the session
      await sessionClient.finishSession(
        FinishSessionRequest()..id = sessionId,
      );

      // Refresh and verify no active session
      final activeSessionAfter = await container.refresh(
        hasActiveSessionProvider.future,
      );
      expect(activeSessionAfter, isNull);

      // Note: Cannot delete workout as completed session references it
    });

    test('hasActiveSessionProvider returns null after abandoning session', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Verify session is active
      final activeSessionBefore = await container.read(
        hasActiveSessionProvider.future,
      );
      expect(activeSessionBefore, isNotNull);
      expect(activeSessionBefore!.id, equals(sessionId));

      // Abandon the session
      await sessionClient.abandonSession(
        AbandonSessionRequest()..id = sessionId,
      );

      // Refresh and verify no active session
      final activeSessionAfter = await container.refresh(
        hasActiveSessionProvider.future,
      );
      expect(activeSessionAfter, isNull);

      // Clean up
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('full session workflow', () async {
      // Create workout
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Full Workflow Test',
      );

      // Use direct API calls to avoid Riverpod lifecycle issues in tests
      // 1. Start session
      final startResponse = await sessionClient.startSession(
        StartSessionRequest()..workoutTemplateId = workoutId,
      );
      final session = startResponse.session;
      expect(session.id, isNotEmpty);

      // 2. Complete all sets via sync API
      final syncSets = <SyncSetData>[];
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          syncSets.add(SyncSetData()
            ..setId = set.id
            ..weightKg = 60.0
            ..reps = 10
            ..isCompleted = true);
        }
      }

      final syncResponse = await sessionClient.syncSession(
        SyncSessionRequest()
          ..sessionId = session.id
          ..sets.addAll(syncSets),
      );
      expect(syncResponse.success, isTrue);

      // 3. Finish session
      final finishResponse = await sessionClient.finishSession(
        FinishSessionRequest()..id = session.id,
      );
      expect(
        finishResponse.session.status,
        equals(WorkoutStatus.WORKOUT_STATUS_COMPLETED),
      );

      // Note: Cannot delete workout as completed session references it
    });

    test('adds exercise to session', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get another exercise to add
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final newExerciseId = exercisesResponse.exercises[1].id;

      // Add exercise
      final request = AddExerciseRequest()
        ..sessionId = sessionId
        ..userId = TestData.testUserId
        ..exerciseId = newExerciseId
        ..displayOrder = 2
        ..numSets = 3;

      final response = await sessionClient.addExercise(request);

      expect(response.exercise, isNotNull);
      expect(response.exercise.exerciseId, equals(newExerciseId));
      expect(response.exercise.sets, hasLength(3));

      // Clean up - use deleteWorkoutSafe as abandoned sessions still reference workout
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });
  });
}
