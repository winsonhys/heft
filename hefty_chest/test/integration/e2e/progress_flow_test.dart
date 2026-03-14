import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/progress/widgets/summary_cards_row.dart';
import 'package:hefty_chest/features/progress/widgets/weekly_activity_chart.dart';
import 'package:hefty_chest/features/progress/widgets/pr_list.dart';
import 'package:hefty_chest/features/progress/widgets/exercise_progress_section.dart';

import '../../test_utils/test_setup.dart';
import '../../test_utils/test_data.dart';

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

  /// Complete a session: start, sync all sets as completed, finish.
  Future<String> completeSession(String workoutId,
      {double weightKg = 60.0, int reps = 10}) async {
    final sessionId = await TestData.startSession(
      workoutTemplateId: workoutId,
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
            ..weightKg = weightKg
            ..reps = reps
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

  group('Progress Flow E2E', () {
    testWidgets('summary cards show stats', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Progress Stats');
        final workoutId =
            await TestData.createWorkoutWithExercise(name: name);
        await completeSession(workoutId);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Progress tab
        await tester.tap(find.byIcon(Icons.bar_chart_outlined), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Progress header
      expect(find.text('Progress'), findsWidgets);
      // Summary card labels
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('Day Streak'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      // SummaryCardsRow widget
      expect(find.byType(SummaryCardsRow), findsOneWidget);
    });

    testWidgets('weekly activity chart renders', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Weekly Chart');
        final workoutId =
            await TestData.createWorkoutWithExercise(name: name);
        await completeSession(workoutId);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Progress tab
        await tester.tap(find.byIcon(Icons.bar_chart_outlined), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      expect(find.text('Weekly Activity'), findsOneWidget);
      expect(find.byType(WeeklyActivityChart), findsOneWidget);
    });

    testWidgets('personal records section renders', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('PR Test');
        final workoutId =
            await TestData.createWorkoutWithExercise(name: name);
        // Complete with heavy weight to trigger PR
        await completeSession(workoutId, weightKg: 100.0, reps: 5);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Progress tab
        await tester.tap(find.byIcon(Icons.bar_chart_outlined), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      expect(find.text('Recent PRs'), findsOneWidget);
      expect(find.byType(PrList), findsOneWidget);
    });

    testWidgets('exercise progress section renders', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Exercise Progress');
        final workoutId =
            await TestData.createWorkoutWithExercise(name: name);
        await completeSession(workoutId);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Progress tab
        await tester.tap(find.byIcon(Icons.bar_chart_outlined), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      expect(find.byType(ExerciseProgressSection), findsOneWidget);
    });
  });
}

class MockAuth extends Auth {
  @override
  AuthState build() => AuthState(
        token: IntegrationTestSetup.authToken,
        userId: IntegrationTestSetup.testUserId,
        isLoading: false,
      );
}
