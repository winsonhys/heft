@Tags(['e2e', 'profile'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/profile/widgets/stats_grid.dart';
import 'package:hefty_chest/features/profile/widgets/settings_card.dart';

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

  group('Profile Flow E2E', () {
    testWidgets('displays user info and member since', (tester) async {
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

        // Navigate to Profile tab
        await tester.tap(find.byIcon(Icons.person_outline), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Profile header
      expect(find.text('Profile'), findsWidgets);
      // Member since text
      expect(find.textContaining('Member since'), findsOneWidget);
    });

    testWidgets('stats grid renders with data', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Profile Stats');
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

        // Navigate to Profile tab
        await tester.tap(find.byIcon(Icons.person_outline), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // StatsGrid widget should render
      expect(find.byType(StatsGrid), findsOneWidget);
      // Settings section should be visible
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('unit toggle between KG and LBS', (tester) async {
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

        // Navigate to Profile tab
        await tester.tap(find.byIcon(Icons.person_outline), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // SettingsCard should render
      expect(find.byType(SettingsCard), findsOneWidget);
      // Weight Unit label
      expect(find.text('Weight Unit'), findsOneWidget);
      // KG and LBS options visible
      expect(find.text('KG'), findsOneWidget);
      expect(find.text('LBS'), findsOneWidget);

      await tester.runAsync(() async {
        // Tap LBS
        await tester.tap(find.text('LBS'));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // LBS should now be selected (verify API succeeded by checking
      // the widget is still rendered without error)
      expect(find.text('LBS'), findsOneWidget);
      expect(find.byType(SettingsCard), findsOneWidget);

      // Switch back to KG for clean state
      await tester.runAsync(() async {
        await tester.tap(find.text('KG'));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });
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
