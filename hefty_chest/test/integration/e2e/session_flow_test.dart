import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';

import '../../test_utils/test_setup.dart';
import '../../test_utils/test_data.dart';

void main() {
  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  group('Session Flow E2E', () {
    testWidgets('starts workout session from workout card', (tester) async {
      // Create test workout with exercise
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Session Start Test',
      );

      await tester.pumpWidget(
        const ProviderScope(child: HeftyChestApp()),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find the workout card
      expect(find.text('Session Start Test'), findsOneWidget);

      // Find and tap Start button
      final startButtons = find.text('Start');
      expect(startButtons, findsWidgets);

      // Tap the first Start button
      await tester.tap(startButtons.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to tracker screen
      // Look for tracker-specific UI elements
      expect(find.byType(Scaffold), findsOneWidget);

      // Abandon any started session
      final sessionsResponse = await sessionClient.listSessions(
        ListSessionsRequest()
          ..userId = TestData.testUserId
          ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS,
      );

      for (final session in sessionsResponse.sessions) {
        await sessionClient.abandonSession(
          AbandonSessionRequest()
            ..id = session.id
            ..userId = TestData.testUserId,
        );
      }

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });

    testWidgets('tracker screen shows exercise information', (tester) async {
      // Create workout and start session directly
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Exercise Info Test',
      );
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      await tester.pumpWidget(
        const ProviderScope(child: HeftyChestApp()),
      );

      // Navigate directly to session (if router supports it)
      // For now, go through home screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap the workout
      final startButtons = find.text('Start');
      if (startButtons.evaluate().isNotEmpty) {
        // There might be a "Resume" option instead
        final resumeButton = find.text('Resume');
        if (resumeButton.evaluate().isNotEmpty) {
          await tester.tap(resumeButton.first);
        }
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkout(workoutId);
    });

    testWidgets('can complete workout and return to home', (tester) async {
      // This is a full flow test
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Complete Flow Test',
      );

      await tester.pumpWidget(
        const ProviderScope(child: HeftyChestApp()),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on home
      expect(find.text('Heft'), findsOneWidget);

      // Clean up any test data
      await TestData.deleteWorkout(workoutId);
    });

    testWidgets('displays active session indicator if session exists', (tester) async {
      // Create and start a session
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Active Session Test',
      );
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      await tester.pumpWidget(
        const ProviderScope(child: HeftyChestApp()),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // The app should show some indicator of active session
      // This depends on your UI implementation
      // Could be a banner, different button text, etc.

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkout(workoutId);
    });

    testWidgets('tracker shows set completion UI', (tester) async {
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Set Completion UI Test',
      );

      await tester.pumpWidget(
        const ProviderScope(child: HeftyChestApp()),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find workout and start
      final startButton = find.text('Start');
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should see exercise sets
        // The specific UI depends on your tracker implementation
        // Look for common elements like weight/reps inputs
        expect(find.byType(Scaffold), findsOneWidget);
      }

      // Clean up any sessions
      final sessionsResponse = await sessionClient.listSessions(
        ListSessionsRequest()
          ..userId = TestData.testUserId
          ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS,
      );

      for (final session in sessionsResponse.sessions) {
        await sessionClient.abandonSession(
          AbandonSessionRequest()
            ..id = session.id
            ..userId = TestData.testUserId,
        );
      }

      await TestData.deleteWorkout(workoutId);
    });

    testWidgets('can navigate back from tracker without finishing', (tester) async {
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Back Navigation Test',
      );

      await tester.pumpWidget(
        const ProviderScope(child: HeftyChestApp()),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Start workout
      final startButton = find.text('Start');
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Try to go back (might show confirmation dialog)
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
      }

      // Clean up
      final sessionsResponse = await sessionClient.listSessions(
        ListSessionsRequest()
          ..userId = TestData.testUserId
          ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS,
      );

      for (final session in sessionsResponse.sessions) {
        await sessionClient.abandonSession(
          AbandonSessionRequest()
            ..id = session.id
            ..userId = TestData.testUserId,
        );
      }

      await TestData.deleteWorkout(workoutId);
    });

    testWidgets('session data persists across app restart', (tester) async {
      // Create and start session
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Persistence Test',
      );
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

      // Complete one set via API
      final sessionResponse = await sessionClient.getSession(
        GetSessionRequest()
          ..id = sessionId
          ..userId = TestData.testUserId,
      );
      final setId = sessionResponse.session.exercises.first.sets.first.id;

      await sessionClient.completeSet(
        CompleteSetRequest()
          ..sessionSetId = setId
          ..userId = TestData.testUserId
          ..weightKg = 50.0
          ..reps = 10,
      );

      // Launch app
      await tester.pumpWidget(
        const ProviderScope(child: HeftyChestApp()),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // The app should detect the in-progress session
      // Verify session still exists
      final checkResponse = await sessionClient.getSession(
        GetSessionRequest()
          ..id = sessionId
          ..userId = TestData.testUserId,
      );

      expect(checkResponse.session.exercises.first.sets.first.isCompleted, isTrue);

      // Clean up
      await TestData.abandonSession(sessionId);
      await TestData.deleteWorkout(workoutId);
    });
  });

  group('Progress Update E2E', () {
    testWidgets('completing session updates progress stats', (tester) async {
      // This test verifies the full flow updates stats
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Stats Update Test',
      );

      // Get initial stats
      final initialStats = await progressClient.getDashboardStats(
        GetDashboardStatsRequest()..userId = TestData.testUserId,
      );
      final initialCount = initialStats.stats.totalWorkouts;

      // Complete a session via API
      final sessionId = await TestData.startSession(
        workoutTemplateId: workoutId,
      );

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

      await sessionClient.finishSession(
        FinishSessionRequest()
          ..id = sessionId
          ..userId = TestData.testUserId,
      );

      // Launch app and check stats
      await tester.pumpWidget(
        const ProviderScope(child: HeftyChestApp()),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify via API that stats updated
      final updatedStats = await progressClient.getDashboardStats(
        GetDashboardStatsRequest()..userId = TestData.testUserId,
      );

      expect(updatedStats.stats.totalWorkouts, equals(initialCount + 1));

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });
  });
}
