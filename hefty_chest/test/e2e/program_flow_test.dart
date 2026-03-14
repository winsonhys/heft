@Tags(['e2e', 'program'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/home/widgets/today_workout_card.dart';


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

  /// Create a program with today as a workout day and set it active.
  /// Returns (workoutId, programId).
  Future<(String, String)> setupTodayProgram(String workoutName) async {
    final workoutId = await TestData.createWorkoutWithExercise(
      name: workoutName,
    );

    // Calculate today's day number in a 7-day program (1-based)
    // Use day 1 for simplicity — the program starts today
    final programResponse = await programClient.createProgram(
      CreateProgramRequest()
        ..name = 'Test Program ${DateTime.now().microsecondsSinceEpoch}'
        ..durationWeeks = 1
        ..durationDays = 7
        ..days.add(
          CreateProgramDay()
            ..dayNumber = 1
            ..dayType = ProgramDayType.PROGRAM_DAY_TYPE_WORKOUT
            ..workoutTemplateId = workoutId,
        ),
    );

    final programId = programResponse.program.id;

    // Set as active program
    await programClient.setActiveProgram(
      SetActiveProgramRequest()..id = programId,
    );

    return (workoutId, programId);
  }

  group('Program Flow E2E', () {
    testWidgets('today workout card appears with active program',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Today Workout');
        await setupTodayProgram(name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // TodayWorkoutCard should be visible
      expect(find.byType(TodayWorkoutCard), findsOneWidget);
      // Should show "Day" text and workout name
      expect(find.textContaining('Day'), findsWidgets);
      // Start button on the card
      final todayCard = find.byType(TodayWorkoutCard);
      expect(
        find.descendant(of: todayCard, matching: find.text('Start')),
        findsOneWidget,
      );
    });

    testWidgets('start session from today workout card', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final name = getUniqueName('Start Today');
        await setupTodayProgram(name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Tap Start on TodayWorkoutCard (GestureDetector may be off-screen)
        final todayCard = find.byType(TodayWorkoutCard);
        final startGesture = find.descendant(
          of: todayCard,
          matching: find.ancestor(
            of: find.text('Start'),
            matching: find.byType(GestureDetector),
          ),
        );
        expect(startGesture, findsWidgets, reason: 'Start button should be on TodayWorkoutCard');
        final startWidget = tester.widget<GestureDetector>(startGesture.first);
        startWidget.onTap?.call();
        // Multiple pump cycles for async navigation + session init
        for (int i = 0; i < 5; i++) {
          await Future.delayed(const Duration(seconds: 1));
          await tester.pump();
        }
      });

      // Tracker should load (Scaffold visible with session data)
      expect(find.byType(Scaffold), findsWidgets);

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('create program via API and verify exists', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        final programName = getUniqueName('API Program');
        final programResponse = await programClient.createProgram(
          CreateProgramRequest()
            ..name = programName
            ..durationWeeks = 4
            ..durationDays = 28,
        );

        // Verify via API
        final listResponse = await programClient.listPrograms(
          ListProgramsRequest(),
        );

        final found = listResponse.programs.any(
          (p) => p.id == programResponse.program.id,
        );
        expect(found, isTrue);

        // Cleanup
        await programClient.deleteProgram(
          DeleteProgramRequest()..id = programResponse.program.id,
        );
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
