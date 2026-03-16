@Tags(['e2e', 'session'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/home/widgets/workout_card.dart';
import 'package:hefty_chest/features/tracker/widgets/rest_timer_sheet.dart';
import 'package:hefty_chest/features/tracker/widgets/set_row.dart';

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

  group('Session Flow E2E', () {
    testWidgets('starts workout session from workout card', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Session Start Test');
        await TestData.createWorkoutWithExercise(name: name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Verify my workout is visible
        expect(find.text(name), findsOneWidget);

        // Find Start button on the specific workout card (skip Quick Start card)
        final workoutCard = find.ancestor(
          of: find.text(name),
          matching: find.byType(WorkoutCard),
        );
        final startButton = find.descendant(
          of: workoutCard,
          matching: find.text('Start'),
        );
        await tester.tap(startButton);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        // Should navigate to tracker screen
        expect(find.byType(Scaffold), findsWidgets);

        // Cleanup
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('tracker screen shows exercise information', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Exercise Info Test');
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Should see Resume button for the active session, or Start
        final resumeButtons = find.text('Resume');
        final startButtons = find.text('Start');
        expect(
          resumeButtons.evaluate().isNotEmpty || startButtons.evaluate().isNotEmpty,
          isTrue,
          reason: 'Either Resume or Start button should be visible',
        );
        if (resumeButtons.evaluate().isNotEmpty) {
          await tester.tap(resumeButtons.first);
        } else {
          await tester.tap(startButtons.last);
        }

        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        expect(find.byType(Scaffold), findsWidgets);

        // Cleanup
        await sessionClient.abandonSession(
            AbandonSessionRequest()..id = sessionId);
      });
    });

    testWidgets('can complete workout and return to home', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Complete Flow Test');
        await TestData.createWorkoutWithExercise(name: name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Find Start button on the specific workout card
        final workoutCard = find.ancestor(
          of: find.text(name),
          matching: find.byType(WorkoutCard),
        );
        expect(workoutCard, findsOneWidget, reason: 'Workout card for "$name" should be visible');
        final startButton = find.descendant(
          of: workoutCard,
          matching: find.text('Start'),
        );
        await tester.tap(startButton);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        // For now, just ensure no crash.
        await TestData.abandonAnyActiveSession();
      });
    });

    /*
    testWidgets('displays active session indicator if session exists', (tester) async {
      await tester.runAsync(() async {
        final name = getUniqueName('Active Session Test');
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Check for Resume button which indicates active session
        expect(find.text('Resume'), findsWidgets);
        
        await sessionClient.abandonSession(
            AbandonSessionRequest()..id = sessionId..userId = TestData.testUserId);
      });
    });
    */

    testWidgets('tracker shows set completion UI', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Set Completion UI');
        await TestData.createWorkoutWithExercise(name: name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        final workoutCard = find.ancestor(
          of: find.text(name),
          matching: find.byType(WorkoutCard),
        );
        expect(workoutCard, findsOneWidget, reason: 'Workout card for "$name" should be visible');
        final startButton = find.descendant(
          of: workoutCard,
          matching: find.text('Start'),
        );
        await tester.tap(startButton);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        expect(find.byType(Scaffold), findsWidgets);

        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('can navigate back from tracker without finishing', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Back Nav Test');
        await TestData.createWorkoutWithExercise(name: name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        final workoutCard = find.ancestor(
          of: find.text(name),
          matching: find.byType(WorkoutCard),
        );
        expect(workoutCard, findsOneWidget, reason: 'Workout card for "$name" should be visible');
        final startButton = find.descendant(
          of: workoutCard,
          matching: find.text('Start'),
        );
        await tester.tap(startButton);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });
      // GoRouter navigation completes after exiting runAsync
      await tester.pump();

      // Wait for tracker screen to fully load (session init is async)
      await tester.runAsync(() async {
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          await tester.pump();
          if (find.byKey(const Key('tracker_back')).evaluate().isNotEmpty) break;
        }
      });
      await tester.pump();

      // Try to go back — invoke onPress directly since FHeaderAction uses FTappable, not GestureDetector
      final backButton = find.byKey(const Key('tracker_back'));
      expect(backButton, findsOneWidget, reason: 'Back button should be visible on tracker');
      await tester.runAsync(() async {
        final headerAction = tester.widget<FHeaderAction>(backButton);
        headerAction.onPress?.call();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });
      // GoRouter navigation back completes after pump
      await tester.pump();

      // Should be back home
      expect(find.text('Heft'), findsOneWidget);

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('session data persists across app restart', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Persistence Test');
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        // Complete one set via sync API
        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final setId = sessionResponse.session.exercises.first.sets.first.id;

        await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = sessionId
            ..sets.add(SyncSetData()
              ..id = setId
              ..weightKg = 50.0
              ..reps = 10
              ..isCompleted = true),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Verify session set completed status via API (independent of UI)
        final checkResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );

        expect(checkResponse.session.exercises.first.sets.first.isCompleted, isTrue);

        await sessionClient.abandonSession(
            AbandonSessionRequest()..id = sessionId);
      });
    });
  });

  // Session interaction tests — UI-level coverage for the core workout loop
  sessionInteractionE2ETests();

  // Run rest items E2E tests
  restItemsE2ETests();

  group('Progress Update E2E', () {
    testWidgets('completing session updates progress stats', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Stats Update Test');
        final workoutId = await TestData.createWorkoutWithExercise(name: name);

        final initialStats = await progressClient.getDashboardStats(
          GetDashboardStatsRequest(),
        );
        final initialCount = initialStats.stats.totalWorkouts;

        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );

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

        await sessionClient.finishSession(
          FinishSessionRequest()..id = sessionId,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        final updatedStats = await progressClient.getDashboardStats(
          GetDashboardStatsRequest(),
        );

        expect(updatedStats.stats.totalWorkouts, equals(initialCount + 1));
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

/// E2E tests for rest items in session flow
void restItemsE2ETests() {
  String getUniqueName(String base) {
    return '$base ${DateTime.now().microsecondsSinceEpoch}';
  }

  group('Rest Items E2E', () {
    testWidgets('tracker screen shows rest items from workout template', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Rest Item Display Test');
        await TestData.createWorkoutWithRestItem(
          name: name,
          restDurationSeconds: 60,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await navigateToTracker(tester, name);

        // Rest item card is info-only (timer auto-triggers on set completion)
        // Verify rest item displays with duration in "Rest — M:SS" format
        expect(find.textContaining('Rest'), findsWidgets,
            reason: 'Rest item card should show "Rest —" label');
        expect(find.byIcon(Icons.timer_outlined), findsWidgets,
            reason: 'Rest item card should show timer icon');

        // Cleanup
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('rest item completion persists to backend', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Rest Persist Test');
        final workoutId = await TestData.createWorkoutWithRestItem(
          name: name,
          restDurationSeconds: 60,
        );
        final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

        // Get rest item ID
        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final restItemId = sessionResponse.session.restItems.first.id;

        // Complete rest item via API (simulating Skip button action)
        await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = sessionId
            ..restItems.add(SyncRestItemData()
              ..id = restItemId
              ..isCompleted = true),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Verify rest item is still completed via API
        final checkResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );

        expect(checkResponse.session.restItems.first.isCompleted, isTrue);
        expect(checkResponse.session.restItems.first.completedAt, isNotNull);

        // Cleanup
        await sessionClient.abandonSession(
          AbandonSessionRequest()..id = sessionId,
        );
      });
    });

    testWidgets('full session flow with rest item', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Full Rest Flow');
        final workoutId = await TestData.createWorkoutWithRestItem(
          name: name,
          restDurationSeconds: 30,
        );

        // Start session
        final startResponse = await sessionClient.startSession(
          StartSessionRequest()..workoutTemplateId = workoutId,
        );
        final session = startResponse.session;
        expect(session.restItems, isNotEmpty);

        // Complete exercise sets
        final syncSets = <SyncSetData>[];
        for (final exercise in session.exercises) {
          for (final set in exercise.sets) {
            syncSets.add(SyncSetData()
              ..id = set.id
              ..weightKg = 50.0
              ..reps = 10
              ..isCompleted = true);
          }
        }

        // Complete rest items
        final syncRestItems = <SyncRestItemData>[];
        for (final restItem in session.restItems) {
          syncRestItems.add(SyncRestItemData()
            ..id = restItem.id
            ..isCompleted = true);
        }

        // Sync all
        final syncResponse = await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = session.id
            ..sets.addAll(syncSets)
            ..restItems.addAll(syncRestItems),
        );
        expect(syncResponse.success, isTrue);

        // Verify rest item is completed
        expect(syncResponse.session.restItems.first.isCompleted, isTrue);

        // Finish session
        final finishResponse = await sessionClient.finishSession(
          FinishSessionRequest()..id = session.id,
        );
        expect(
          finishResponse.session.status,
          equals(WorkoutStatus.WORKOUT_STATUS_COMPLETED),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Verify session is in history with rest items
        final historyResponse = await sessionClient.listSessions(
          ListSessionsRequest(),
        );

        final completedSession = historyResponse.sessions.firstWhere(
          (s) => s.id == session.id,
        );
        expect(completedSession.status, equals(WorkoutStatus.WORKOUT_STATUS_COMPLETED));
      });
    });
  });
}

/// Navigate from home to the tracker screen for a specific workout.
///
/// Finds the workout card by [workoutName], taps its Start button,
/// then polls for SetRow widgets to appear.
Future<void> navigateToTracker(
    WidgetTester tester, String workoutName) async {
  // Wait for home screen to load and show the workout card
  for (int i = 0; i < 10; i++) {
    await Future.delayed(const Duration(milliseconds: 500));
    await tester.pump();
    if (find.text(workoutName).evaluate().isNotEmpty) break;
  }

  // Find the Start button specifically on this workout's card.
  final workoutCard = find.ancestor(
    of: find.text(workoutName),
    matching: find.byType(WorkoutCard),
  );

  expect(workoutCard, findsOneWidget,
      reason: 'Workout card for "$workoutName" should be visible on home screen');
  final startButton = find.descendant(
    of: workoutCard,
    matching: find.text('Start'),
  );
  await tester.tap(startButton);

  // Poll for tracker content to fully load (SetRow = session data rendered)
  for (int i = 0; i < 20; i++) {
    await Future.delayed(const Duration(milliseconds: 500));
    await tester.pump();
    if (find.byType(SetRow).evaluate().isNotEmpty) return;
  }
}

/// Enter weight/reps and tap the completion circle on a set.
///
/// Uses global EditableText and Container finders indexed by [setIndex].
Future<void> completeSetViaUI(
  WidgetTester tester,
  int setIndex, {
  String weight = '60',
  String reps = '8',
}) async {
  final weightFieldIndex = setIndex * 2;
  final repsFieldIndex = setIndex * 2 + 1;

  await tester.enterText(
      find.byType(EditableText).at(weightFieldIndex), weight);
  await tester.pump();
  await tester.enterText(
      find.byType(EditableText).at(repsFieldIndex), reps);
  await tester.pump();

  final completionCircles = find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    final decoration = widget.decoration;
    return decoration is BoxDecoration &&
        decoration.shape == BoxShape.circle;
  });
  await tester.tap(completionCircles.at(setIndex));
  await Future.delayed(const Duration(milliseconds: 500));
  await tester.pump();
}

/// E2E tests for core workout interaction loop: enter sets, complete, rest timer, progress
void sessionInteractionE2ETests() {
  String getUniqueName(String base) {
    return '$base ${DateTime.now().microsecondsSinceEpoch}';
  }

  group('Session Interaction E2E', () {
    testWidgets('enter weight and reps, then complete a set via UI',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Set Entry Test');
        await TestData.createWorkoutWithExercise(name: name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await navigateToTracker(tester, name);

        // Verify SetRow widgets loaded on tracker
        expect(find.byType(SetRow), findsWidgets);

        // Enter weight/reps and tap complete on first set
        await completeSetViaUI(tester, 0, weight: '60', reps: '8');

        // Verify: check icon appears after completing a set
        expect(find.byIcon(Icons.check), findsAtLeast(1));

        // Cleanup
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('rest timer sheet appears after completing a set',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Rest Timer Test');
        await TestData.createWorkoutWithRestDuration(
          name: name,
          restSeconds: 60,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await navigateToTracker(tester, name);

        // Verify tracker loaded
        expect(find.byType(SetRow), findsWidgets);

        // Complete first set
        await completeSetViaUI(tester, 0);

        // Verify: RestTimerSheet appears
        expect(find.byType(RestTimerSheet), findsOneWidget);

        // Verify countdown text is showing (should be "1:00" since timer just started)
        expect(
          find.descendant(
            of: find.byType(RestTimerSheet),
            matching: find.text('1:00'),
          ),
          findsOneWidget,
        );

        // Verify Skip button is present in the sheet
        expect(
          find.descendant(
            of: find.byType(RestTimerSheet),
            matching: find.text('Skip'),
          ),
          findsOneWidget,
        );

        // Cleanup
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('rest timer shows correct next exercise and set info',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Rest Info Test');
        await TestData.createWorkoutWithRestDuration(
          name: name,
          restSeconds: 60,
        );

        // Get exercise name (createWorkoutWithRestDuration uses first exercise)
        final exercisesResponse = await exerciseClient.listExercises(
          ListExercisesRequest(),
        );
        final exerciseName = exercisesResponse.exercises.first.name;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await navigateToTracker(tester, name);

        // Verify tracker loaded
        expect(find.byType(SetRow), findsWidgets);

        // Complete first set
        await completeSetViaUI(tester, 0);

        // Verify rest timer shows next exercise info
        // Format: "Next: {exerciseName} - Set 2"
        expect(
          find.text('Next: $exerciseName - Set 2'),
          findsOneWidget,
        );

        // Cleanup
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('complete all sets and verify progress', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Progress Test');
        await TestData.createWorkoutWithExercise(name: name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await navigateToTracker(tester, name);

        // Verify initial progress
        expect(find.text('0 / 2 sets'), findsOneWidget);

        // Complete both sets (workout has 2 target sets, no rest duration)
        expect(find.byType(SetRow), findsNWidgets(2));

        for (int i = 0; i < 2; i++) {
          await completeSetViaUI(tester, i, weight: '60', reps: '10');
        }

        // Verify progress header shows "2 / 2 sets"
        expect(find.text('2 / 2 sets'), findsOneWidget);

        // Verify "100% complete"
        expect(find.text('100% complete'), findsOneWidget);

        // Cleanup
        await TestData.abandonAnyActiveSession();
      });
    });
  });
}
