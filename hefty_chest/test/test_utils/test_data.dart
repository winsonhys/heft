import 'package:hefty_chest/core/client.dart';

import 'test_setup.dart';

/// Test data utilities for integration tests.
///
/// Provides helpers for creating, seeding, and cleaning up test data
/// against the real backend.
///
/// IMPORTANT: Call [IntegrationTestSetup.authenticateTestUser()] before
/// using any methods in this class.
class TestData {
  TestData._();

  /// Get the authenticated test user ID.
  ///
  /// This returns the user ID from the login response, not a hardcoded value.
  /// Throws if [IntegrationTestSetup.authenticateTestUser()] hasn't been called.
  static String get testUserId => IntegrationTestSetup.testUserId;

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
    // Get first exercise from list
    final exercisesResponse = await exerciseClient.listExercises(
      ListExercisesRequest(),
    );
    final exercise = exercisesResponse.exercises.first;

    // Create workout with section and exercise
    final section = CreateWorkoutSection()
      ..name = 'Main Set'
      ..displayOrder = 1
      ..isSuperset = false;

    final item = CreateSectionItem()
      ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
      ..displayOrder = 1
      ..exerciseId = exercise.id;

    // Add target sets
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
  ///
  /// If the workout has associated sessions, this will fail with a FK error.
  /// Use [deleteWorkoutSafe] instead if sessions may exist.
  static Future<void> deleteWorkout(String workoutId) async {
    final request = DeleteWorkoutRequest()
      ..id = workoutId;

    await workoutClient.deleteWorkout(request);
  }

  /// Safely delete a workout by first cleaning up any in-progress sessions.
  ///
  /// Note: This only handles IN_PROGRESS sessions. Completed sessions cannot
  /// be abandoned and will cause FK constraint violations. For tests that
  /// complete sessions, the workout cannot be deleted.
  static Future<void> deleteWorkoutSafe(String workoutId) async {
    // Try to delete - if it fails due to FK constraint, that's expected
    // for workouts with completed sessions
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
    final request = CreateProgramRequest()
      ..name = name
      ..durationWeeks = durationWeeks
      ..durationDays = durationWeeks * 7;

    final response = await programClient.createProgram(request);
    return response.program.id;
  }

  /// Delete a program by ID.
  static Future<void> deleteProgram(String programId) async {
    final request = DeleteProgramRequest()
      ..id = programId;
    await programClient.deleteProgram(request);
  }

  /// Start a session and return the session ID.
  static Future<String> startSession({required String workoutTemplateId}) async {
    final request = StartSessionRequest()
      ..workoutTemplateId = workoutTemplateId;

    final response = await sessionClient.startSession(request);
    return response.session.id;
  }

  /// Abandon a session by ID.
  static Future<void> abandonSession(String sessionId) async {
    final request = AbandonSessionRequest()
      ..id = sessionId;

    await sessionClient.abandonSession(request);
  }

  /// Abandon any active session for the test user.
  ///
  /// Call this in setUp() or at the start of tests that need a clean slate.
  /// Silently succeeds if no active session exists.
  static Future<void> abandonAnyActiveSession() async {
    try {
      // List sessions to find any in-progress ones
      final response = await sessionClient.listSessions(
        ListSessionsRequest()
          ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS,
      );

      // Abandon each in-progress session
      for (final session in response.sessions) {
        try {
          await sessionClient.abandonSession(
            AbandonSessionRequest()..id = session.id,
          );
        } catch (_) {
          // Ignore errors - session may have been finished/abandoned already
        }
      }
    } catch (_) {
      // Ignore errors - no sessions to abandon
    }
  }

  /// Create a workout with one exercise and one rest item.
  ///
  /// Returns the workout ID. Useful for testing rest item functionality.
  static Future<String> createWorkoutWithRestItem({
    String name = 'Test Workout With Rest',
    int restDurationSeconds = 90,
  }) async {
    // Get first exercise from list
    final exercisesResponse = await exerciseClient.listExercises(
      ListExercisesRequest(),
    );
    final exercise = exercisesResponse.exercises.first;

    // Create workout section with exercise and rest item
    final section = CreateWorkoutSection()
      ..name = 'Main Set'
      ..displayOrder = 1
      ..isSuperset = false;

    // Add exercise item
    final exerciseItem = CreateSectionItem()
      ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
      ..displayOrder = 1
      ..exerciseId = exercise.id;

    // Add target sets for exercise
    final set1 = CreateTargetSet()
      ..setNumber = 1
      ..targetWeightKg = 60.0
      ..targetReps = 10;
    exerciseItem.targetSets.add(set1);

    // Add rest item
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
