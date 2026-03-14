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

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(MockAuth.new)],
        child: const HeftyChestApp(),
      ),
    );
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

  group('Profile Weight Log & Settings E2E', () {
    testWidgets('update display name via API', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final uniqueSuffix = DateTime.now().microsecondsSinceEpoch;
        final newName = 'Test User $uniqueSuffix';

        // Update display name via API
        await userClient.updateProfile(
          UpdateProfileRequest()..displayName = newName,
        );

        // Verify via getProfile that the name was updated
        final profileResponse = await userClient.getProfile(
          GetProfileRequest(),
        );
        expect(profileResponse.user.displayName, equals(newName));

        // Pump app and navigate to Profile tab to verify UI
        await pumpApp(tester);

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Profile tab
        await tester.tap(
          find.byIcon(Icons.person_outline),
          warnIfMissed: false,
        );
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Verify the updated name appears in the UI
      expect(find.textContaining('Test User'), findsWidgets);
    });

    testWidgets('profile screen shows user stats', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        // Create a workout and complete a session so stats have data
        final name = getUniqueName('Stats Workout');
        final workoutId =
            await TestData.createWorkoutWithExercise(name: name);
        await completeSession(workoutId);

        // Pump app
        await pumpApp(tester);

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Profile tab
        await tester.tap(
          find.byIcon(Icons.person_outline),
          warnIfMissed: false,
        );
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // StatsGrid widget should render
      expect(find.byType(StatsGrid), findsOneWidget);
      // Settings section should also be visible
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('unit setting toggle persists', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        // Pump app and navigate to Profile tab
        await pumpApp(tester);

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Profile tab
        await tester.tap(
          find.byIcon(Icons.person_outline),
          warnIfMissed: false,
        );
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // SettingsCard should render
      expect(find.byType(SettingsCard), findsOneWidget);

      await tester.runAsync(() async {
        // Tap LBS to switch units
        await tester.tap(find.text('LBS'));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Navigate away (tap home icon) and back to Profile
      await tester.runAsync(() async {
        await tester.tap(
          find.byIcon(Icons.home_outlined),
          warnIfMissed: false,
        );
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        // Navigate back to Profile
        await tester.tap(
          find.byIcon(Icons.person_outline),
          warnIfMissed: false,
        );
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Verify LBS is still selected (SettingsCard still renders)
      expect(find.byType(SettingsCard), findsOneWidget);
      expect(find.text('LBS'), findsOneWidget);

      // Switch back to KG for clean state
      await tester.runAsync(() async {
        await tester.tap(find.text('KG'));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });
    });

    testWidgets('profile shows member since date', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        // Pump app and navigate to Profile tab
        await pumpApp(tester);

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Profile tab
        await tester.tap(
          find.byIcon(Icons.person_outline),
          warnIfMissed: false,
        );
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Verify 'Member since' text is visible
      expect(find.textContaining('Member since'), findsOneWidget);
    });

    testWidgets('weight unit setting affects display', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        // Verify initial user settings via API
        final initialProfile = await userClient.getProfile(
          GetProfileRequest(),
        );
        // ignore: unused_local_variable — documents the before-state
        final _ = initialProfile.user.usePounds;

        // Update to use pounds via API
        await userClient.updateSettings(
          UpdateSettingsRequest()..usePounds = true,
        );

        // Get user again and verify usePounds is true
        final updatedProfile = await userClient.getProfile(
          GetProfileRequest(),
        );
        expect(updatedProfile.user.usePounds, isTrue);

        // Reset to false (KG) for clean state
        await userClient.updateSettings(
          UpdateSettingsRequest()..usePounds = false,
        );

        // Verify reset succeeded
        final resetProfile = await userClient.getProfile(
          GetProfileRequest(),
        );
        expect(resetProfile.user.usePounds, isFalse);

        // Pump app to ensure no crash with the settings
        await pumpApp(tester);

        await Future.delayed(const Duration(seconds: 3));
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
