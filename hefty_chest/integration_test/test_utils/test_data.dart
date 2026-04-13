import 'package:hefty_chest/core/client.dart';

import 'web_test_setup.dart';

/// Web-safe test data utilities for integration tests.
///
/// Adapted from test/test_utils/test_data.dart to use WebTestSetup
/// instead of IntegrationTestSetup (which depends on dart:io).
class TestData {
  TestData._();

  /// Get the authenticated test user ID.
  static String get testUserId => WebTestSetup.testUserId;

  /// Create a test workout with optional sections.
  static Future<String> createTestWorkout({
    String name = 'Integration Test Workout',
    String description = 'Created for integration testing',
    List<CreateWorkoutSection>? sections,
  }) async {
    final request = CreateWorkoutRequest()
      ..name = name
      ..description = description;

    if (sections != null) {
      request.sections.addAll(sections);
    }

    final response = await workoutClient.createWorkout(request);
    return response.workout.id;
  }

  /// Create a workout with one section and one exercise.
  ///
  /// Returns the workout ID. Useful for quick session testing.
  static Future<String> createWorkoutWithExercise({
    String name = 'Test Workout',
  }) async {
    final exercisesResponse = await exerciseClient.listExercises(
      ListExercisesRequest(),
    );
    final exercise = exercisesResponse.exercises.first;

    final section = CreateWorkoutSection()
      ..name = 'Main Set'
      ..displayOrder = 1
      ..isSuperset = false;

    final item = CreateSectionItem()
      ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
      ..displayOrder = 1
      ..exerciseId = exercise.id;

    final set1 = CreateTargetSet()
      ..setNumber = 1
      ..targetWeightKg = 60.0
      ..targetReps = 10;

    final set2 = CreateTargetSet()
      ..setNumber = 2
      ..targetWeightKg = 60.0
      ..targetReps = 10;

    item.targetSets.addAll([set1, set2]);
    section.items.add(item);

    return createTestWorkout(
      name: name,
      sections: [section],
    );
  }

  /// Delete a workout by ID.
  static Future<void> deleteWorkout(String workoutId) async {
    final request = DeleteWorkoutRequest()..id = workoutId;
    await workoutClient.deleteWorkout(request);
  }

  /// Safely delete a workout by first cleaning up any in-progress sessions.
  static Future<void> deleteWorkoutSafe(String workoutId) async {
    try {
      await deleteWorkout(workoutId);
    } catch (_) {
      // Ignore errors - workout may have completed sessions referencing it
    }
  }

  /// Create a test program and return its ID.
  static Future<String> createTestProgram({
    String name = 'Integration Test Program',
    int durationWeeks = 4,
  }) async {
    final today = DateTime.now();
    final iso =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final request = CreateProgramRequest()
      ..name = name
      ..startDate = iso
      ..durationWeeks = durationWeeks;

    final response = await programClient.createProgram(request);
    return response.program.id;
  }

  /// Delete a program by ID.
  static Future<void> deleteProgram(String programId) async {
    final request = DeleteProgramRequest()..id = programId;
    await programClient.deleteProgram(request);
  }

  /// Start a session and return the session ID.
  static Future<String> startSession({
    required String workoutTemplateId,
  }) async {
    final request = StartSessionRequest()
      ..workoutTemplateId = workoutTemplateId;

    final response = await sessionClient.startSession(request);
    return response.session.id;
  }

  /// Abandon a session by ID.
  static Future<void> abandonSession(String sessionId) async {
    final request = AbandonSessionRequest()..id = sessionId;
    await sessionClient.abandonSession(request);
  }

  /// Abandon any active session for the test user.
  static Future<void> abandonAnyActiveSession() async {
    try {
      final response = await sessionClient.listSessions(
        ListSessionsRequest()
          ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS,
      );

      for (final session in response.sessions) {
        try {
          await sessionClient.abandonSession(
            AbandonSessionRequest()..id = session.id,
          );
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Complete a session fully via API.
  ///
  /// Starts a session, completes all sets, and finishes it.
  /// Returns the completed session ID.
  static Future<String> completeSession({
    required String workoutTemplateId,
  }) async {
    final sessionId = await startSession(
      workoutTemplateId: workoutTemplateId,
    );

    final sessionResponse = await sessionClient.getSession(
      GetSessionRequest()..id = sessionId,
    );

    final syncSets = <SyncSetData>[];
    for (final exercise in sessionResponse.session.exercises) {
      for (final set in exercise.sets) {
        syncSets.add(
          SyncSetData()
            ..id = set.id
            ..weightKg = 50.0
            ..reps = 10
            ..isCompleted = true,
        );
      }
    }

    await sessionClient.syncSession(
      SyncSessionRequest()
        ..sessionId = sessionId
        ..sets.addAll(syncSets),
    );

    await sessionClient.finishSession(
      FinishSessionRequest()..id = sessionId,
    );

    return sessionId;
  }

  /// Create a workout with one exercise and one rest item.
  static Future<String> createWorkoutWithRestItem({
    String name = 'Test Workout With Rest',
    int restDurationSeconds = 90,
  }) async {
    final exercisesResponse = await exerciseClient.listExercises(
      ListExercisesRequest(),
    );
    final exercise = exercisesResponse.exercises.first;

    final section = CreateWorkoutSection()
      ..name = 'Main Set'
      ..displayOrder = 1
      ..isSuperset = false;

    final exerciseItem = CreateSectionItem()
      ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
      ..displayOrder = 1
      ..exerciseId = exercise.id;

    final set1 = CreateTargetSet()
      ..setNumber = 1
      ..targetWeightKg = 60.0
      ..targetReps = 10;
    exerciseItem.targetSets.add(set1);

    final restItem = CreateSectionItem()
      ..itemType = SectionItemType.SECTION_ITEM_TYPE_REST
      ..displayOrder = 2
      ..restDurationSeconds = restDurationSeconds;

    section.items.addAll([exerciseItem, restItem]);

    return createTestWorkout(
      name: name,
      sections: [section],
    );
  }
}
