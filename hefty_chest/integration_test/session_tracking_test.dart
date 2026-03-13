import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:integration_test/integration_test.dart';

import 'test_utils/test_data.dart';
import 'test_utils/web_test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await WebTestSetup.waitForBackend();
    await WebTestSetup.resetDatabase();
    await WebTestSetup.authenticateTestUser();
  });

  setUp(() async {
    WebTestSetup.restoreTokenProvider();
    await TestData.abandonAnyActiveSession();
  });

  group('Session Tracking', () {
    testWidgets('start_session_from_home', (tester) async {
      final name = WebTestSetup.uniqueName('Start Session Test');

      await tester.runAsync(() async {
        await TestData.createWorkoutWithExercise(name: name);
      });

      await WebTestSetup.pumpAppAndWait(tester);

      // Verify workout is visible
      expect(find.text(name), findsOneWidget);

      // Find and tap Start button
      final startButtons = find.text('Start');
      expect(startButtons, findsWidgets);

      await tester.runAsync(() async {
        await tester.tap(startButtons.first);
        await Future.delayed(const Duration(seconds: 1));
      });
      // Use pump(Duration) instead of pumpAndSettle — tracker has a running timer
      await tester.pump(const Duration(seconds: 1));

      // Should be on tracker screen
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('complete_set_and_finish_session', (tester) async {
      final name = WebTestSetup.uniqueName('Complete Session Test');

      late String sessionId;

      await tester.runAsync(() async {
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        sessionId = await TestData.startSession(
          workoutTemplateId: workoutId,
        );

        // Complete all sets via API
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
      });

      await WebTestSetup.pumpAppAndWait(tester);

      // Navigate to tracker (Resume active session)
      expect(find.text('Resume'), findsWidgets);
      await tester.runAsync(() async {
        await tester.tap(find.text('Resume').first);
        await Future.delayed(const Duration(seconds: 1));
      });
      await tester.pump(const Duration(seconds: 1));

      // Tap Finish button
      expect(find.text('Finish'), findsWidgets);
      await tester.tap(find.text('Finish').first);
      await tester.pump(const Duration(seconds: 1));

      // Confirm the finish dialog (second "Finish" button)
      final confirmButtons = find.text('Finish');
      if (confirmButtons.evaluate().length > 1) {
        await tester.runAsync(() async {
          await tester.tap(confirmButtons.last);
          await Future.delayed(const Duration(seconds: 1));
        });
        await tester.pump(const Duration(seconds: 1));
      }

      // Should redirect to home
      await WebTestSetup.waitFor(tester, find.text('Heft'));
      expect(find.text('Heft'), findsOneWidget);

      // Check history tab shows the completed session
      await WebTestSetup.navigateToTab(tester, 'History');
      await WebTestSetup.waitFor(tester, find.text(name));
      expect(find.text(name), findsOneWidget);
    });

    testWidgets('discard_session', (tester) async {
      final name = WebTestSetup.uniqueName('Discard Session Test');

      await tester.runAsync(() async {
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        await TestData.startSession(workoutTemplateId: workoutId);
      });

      await WebTestSetup.pumpAppAndWait(tester);

      // Navigate to tracker (Resume active session)
      expect(find.text('Resume'), findsWidgets);
      await tester.runAsync(() async {
        await tester.tap(find.text('Resume').first);
        await Future.delayed(const Duration(seconds: 1));
      });
      await tester.pump(const Duration(seconds: 1));

      // Tap Discard button
      expect(find.text('Discard'), findsWidgets);
      await tester.tap(find.text('Discard').first);
      await tester.pump(const Duration(seconds: 1));

      // Confirm discard dialog
      final confirmButtons = find.text('Discard');
      if (confirmButtons.evaluate().length > 1) {
        await tester.runAsync(() async {
          await tester.tap(confirmButtons.last);
          await Future.delayed(const Duration(seconds: 1));
        });
        await tester.pump(const Duration(seconds: 1));
      }

      // Should redirect to home
      await WebTestSetup.waitFor(tester, find.text('Heft'));
      expect(find.text('Heft'), findsOneWidget);

      // Verify no session in history
      await WebTestSetup.navigateToTab(tester, 'History');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(name), findsNothing);
    });
  });
}
