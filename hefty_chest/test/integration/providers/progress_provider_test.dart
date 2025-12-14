import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/progress/providers/progress_providers.dart';

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

  group('ProgressService Integration', () {
    test('gets dashboard stats', () async {
      final request = GetDashboardStatsRequest()
        ..userId = TestData.testUserId;

      final response = await progressClient.getDashboardStats(request);

      expect(response.stats, isNotNull);
      expect(response.stats.totalWorkouts, isNonNegative);
      expect(response.stats.workoutsThisWeek, isNonNegative);
      expect(response.stats.currentStreak, isNonNegative);
    });

    test('gets dashboard stats via provider', () async {
      final stats = await container.read(progressStatsProvider.future);

      expect(stats, isNotNull);
      expect(stats.totalWorkouts, isNonNegative);
    });

    test('gets weekly activity', () async {
      final request = GetWeeklyActivityRequest()
        ..userId = TestData.testUserId;

      final response = await progressClient.getWeeklyActivity(request);

      expect(response.days, hasLength(7));

      // Each day should have the required fields
      for (final day in response.days) {
        expect(day.dayOfWeek, isNotEmpty);
        expect(day.workoutCount, isNonNegative);
      }
    });

    test('gets weekly activity via provider', () async {
      final days = await container.read(weeklyActivityProvider.future);

      expect(days, hasLength(7));
    });

    test('gets personal records', () async {
      final request = GetPersonalRecordsRequest()
        ..userId = TestData.testUserId;

      final response = await progressClient.getPersonalRecords(request);

      // May be empty if no workouts completed, but should not error
      expect(response.records, isA<List>());
    });

    test('gets personal records via provider', () async {
      final records = await container.read(personalRecordsProvider.future);

      expect(records, isA<List>());
    });

    test('gets exercise progress', () async {
      // Get an exercise ID first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exerciseId = exercisesResponse.exercises.first.id;

      final request = GetExerciseProgressRequest()
        ..userId = TestData.testUserId
        ..exerciseId = exerciseId
        ..limit = 10;

      final response = await progressClient.getExerciseProgress(request);

      // May have no data if exercise hasn't been done
      expect(response.progress, isNotNull);
    });

    test('gets exercise progress via provider', () async {
      // Get an exercise ID first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exerciseId = exercisesResponse.exercises.first.id;

      final progress = await container.read(
        exerciseProgressProvider(exerciseId).future,
      );

      // May be null if no progress data
      expect(progress, isA<ExerciseProgressSummary?>());
    });

    test('gets streak', () async {
      final request = GetStreakRequest()..userId = TestData.testUserId;

      final response = await progressClient.getStreak(request);

      expect(response.currentStreak, isNonNegative);
      expect(response.longestStreak, isNonNegative);
    });

    test('gets calendar month', () async {
      final now = DateTime.now();
      final request = GetCalendarMonthRequest()
        ..userId = TestData.testUserId
        ..year = now.year
        ..month = now.month;

      final response = await progressClient.getCalendarMonth(request);

      // May be empty if no workouts completed this month
      expect(response.days, isA<List>());
      expect(response.totalWorkouts, isNonNegative);
    });

    test('selected exercise progress workflow', () async {
      // Get an exercise ID
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exerciseId = exercisesResponse.exercises.first.id;

      // Initially no selection
      expect(container.read(selectedExerciseIdProvider), isNull);

      // Select exercise
      container.read(selectedExerciseIdProvider.notifier).selectExercise(
        exerciseId,
      );

      expect(container.read(selectedExerciseIdProvider), equals(exerciseId));

      // Get current progress
      final progress = await container.read(
        currentExerciseProgressProvider.future,
      );
      expect(progress, isA<ExerciseProgressSummary?>());

      // Clear selection
      container.read(selectedExerciseIdProvider.notifier).clearSelection();
      expect(container.read(selectedExerciseIdProvider), isNull);
    });

    test('progress updates after completing workout', () async {
      // Get initial stats
      final initialStats = await container.read(progressStatsProvider.future);
      final initialWorkoutCount = initialStats.totalWorkouts;

      // Create and complete a workout session
      final workoutId = await TestData.createWorkoutWithExercise();
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Get session and complete sets
      final sessionResponse = await sessionClient.getSession(
        GetSessionRequest()
          ..id = sessionId
          ..userId = TestData.testUserId,
      );

      for (final exercise in sessionResponse.session.exercises) {
        for (final set in exercise.sets) {
          await sessionClient.completeSet(
            CompleteSetRequest()
              ..sessionSetId = set.id
              ..userId = TestData.testUserId
              ..weightKg = 50.0
              ..reps = 10,
          );
        }
      }

      // Finish session
      await sessionClient.finishSession(
        FinishSessionRequest()
          ..id = sessionId
          ..userId = TestData.testUserId,
      );

      // Invalidate provider to force refresh
      container.invalidate(progressStatsProvider);

      // Get updated stats
      final updatedStats = await container.read(progressStatsProvider.future);

      expect(
        updatedStats.totalWorkouts,
        equals(initialWorkoutCount + 1),
      );

      // Note: Cannot delete workout as completed session references it
    });

    test('exercises list provider for progress screen', () async {
      final exercises = await container.read(exercisesListProvider.future);

      expect(exercises, isNotEmpty);

      // Should have system exercises from seed data
      expect(
        exercises.any((e) => e.name == 'Bench Press'),
        isTrue,
      );
    });
  });
}
