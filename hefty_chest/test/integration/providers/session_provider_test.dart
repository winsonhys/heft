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

    test('completes a set', () async {
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

      // Complete the set
      final completeRequest = CompleteSetRequest()
        ..sessionSetId = firstSet.id
        ..userId = TestData.testUserId
        ..weightKg = 50.0
        ..reps = 10;

      final completeResponse = await sessionClient.completeSet(completeRequest);

      expect(completeResponse.set.isCompleted, isTrue);
      expect(completeResponse.set.weightKg, equals(50.0));
      expect(completeResponse.set.reps, equals(10));

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('updates a set without completing', () async {
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

      // Update the set
      final updateRequest = UpdateSetRequest()
        ..sessionSetId = firstSet.id
        ..userId = TestData.testUserId
        ..weightKg = 55.0
        ..reps = 8;

      final updateResponse = await sessionClient.updateSet(updateRequest);

      expect(updateResponse.set.weightKg, equals(55.0));
      expect(updateResponse.set.reps, equals(8));

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

    test('active session notifier starts session', () async {
      // Create workout
      final workoutId = await TestData.createWorkoutWithExercise();

      // Use notifier to start session
      final notifier = container.read(activeSessionProvider.notifier);
      final session = await notifier.startSession(
        workoutTemplateId: workoutId,
      );

      expect(session, isNotNull);
      expect(session!.id, isNotEmpty);

      // Check state
      final state = container.read(activeSessionProvider);
      expect(state.value?.id, equals(session.id));

      // Clean up - use deleteWorkoutSafe as abandoned sessions still reference workout
      await notifier.abandonSession();
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('active session notifier loads existing session', () async {
      // Create workout and start session directly
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Use notifier to load session
      final notifier = container.read(activeSessionProvider.notifier);
      final session = await notifier.loadSession(sessionId: sessionId);

      expect(session, isNotNull);
      expect(session!.id, equals(sessionId));

      // Clean up - use deleteWorkoutSafe as abandoned sessions still reference workout
      await notifier.abandonSession();
      await TestData.deleteWorkoutSafe(workoutId);
    });

    test('active session notifier completes set', () async {
      // Create workout and start session
      final workoutId = await TestData.createWorkoutWithExercise();

      final notifier = container.read(activeSessionProvider.notifier);
      final session = await notifier.startSession(
        workoutTemplateId: workoutId,
      );

      // Get set ID from session
      final setId = session!.exercises.first.sets.first.id;

      // Complete set via notifier
      final isPersonalRecord = await notifier.completeSet(
        sessionSetId: setId,
        weightKg: 100.0,
        reps: 5,
      );

      expect(isPersonalRecord, isA<bool>());

      // Clean up - use deleteWorkoutSafe as abandoned sessions still reference workout
      await notifier.abandonSession();
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

    test('full session workflow', () async {
      // Create workout
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Full Workflow Test',
      );

      final notifier = container.read(activeSessionProvider.notifier);

      // 1. Start session
      final session = await notifier.startSession(
        workoutTemplateId: workoutId,
      );
      expect(session, isNotNull);

      // 2. Complete all sets
      for (final exercise in session!.exercises) {
        for (final set in exercise.sets) {
          await notifier.completeSet(
            sessionSetId: set.id,
            weightKg: 60.0,
            reps: 10,
          );
        }
      }

      // 3. Finish session
      await notifier.finishSession();

      // 4. Verify session state is cleared
      final state = container.read(activeSessionProvider);
      expect(state.value, isNull);

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
