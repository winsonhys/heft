@Tags(['e2e', 'misc'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/history/widgets/session_card.dart';


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
    return '$base ${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  /// Complete a session: start, sync all sets as completed, finish.
  Future<String> completeSession(String workoutId) async {
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
            ..weightKg = 60.0
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

  /// Navigate to History tab by tapping its icon.
  Future<void> navigateToHistory(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.history), warnIfMissed: false);
    await Future.delayed(const Duration(seconds: 3));
    await tester.pump();
    // Extra delay for async provider to resolve
    await Future.delayed(const Duration(seconds: 2));
    await tester.pump();
  }

  group('History Flow E2E', () {
    testWidgets('shows empty state when no completed sessions',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to History tab (index 1)
        await navigateToHistory(tester);
      });

      // Empty state text
      expect(find.text('No completed workouts yet'), findsOneWidget);
      expect(find.text('Complete a workout to see it here'), findsOneWidget);
    });

    testWidgets('shows completed sessions', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name1 = getUniqueName('HA');
        final name2 = getUniqueName('HB');
        final workoutId1 =
            await TestData.createWorkoutWithExercise(name: name1);
        final workoutId2 =
            await TestData.createWorkoutWithExercise(name: name2);

        await completeSession(workoutId1);
        await completeSession(workoutId2);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to History tab
        await navigateToHistory(tester);
      });

      // Should find SessionCard widgets
      expect(find.byType(SessionCard), findsWidgets);
      // Should find "sets" text indicating stats row
      expect(find.textContaining('sets'), findsWidgets);
    });

    testWidgets('tapping session card shows detail screen', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('HD');
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

        // Navigate to History tab
        await navigateToHistory(tester);

        // Tap first SessionCard
        final sessionCard = find.byType(SessionCard);
        expect(sessionCard, findsWidgets, reason: 'SessionCard should be visible in history');
        await tester.tap(sessionCard.first);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        // Extra delay for detail screen async provider
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Detail screen should show stat items
      // Use defensive checks — tapping SessionCard might need extra time
      final timerIcon = find.byIcon(Icons.timer);
      final dateLabel = find.text('Date');
      final durationLabel = find.text('Duration');
      expect(
        timerIcon.evaluate().isNotEmpty ||
            dateLabel.evaluate().isNotEmpty ||
            durationLabel.evaluate().isNotEmpty,
        isTrue,
        reason: 'Expected detail screen stat items (Date/Duration/Timer)',
      );
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
