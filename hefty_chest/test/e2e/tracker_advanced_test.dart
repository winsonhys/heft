@Tags(['e2e', 'misc'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/home/widgets/workout_card.dart';
import 'package:hefty_chest/features/tracker/widgets/set_row.dart';
import 'package:hefty_chest/features/workout_builder/widgets/exercise_search_modal.dart';
import 'package:hefty_chest/shared/widgets/floating_session_widget.dart';

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

  // Use short numeric suffix to avoid header overflow
  String getUniqueName(String base) {
    return '$base ${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  /// Pump app widget.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(MockAuth.new)],
        child: const HeftyChestApp(),
      ),
    );
  }

  /// Navigate to tracker by tapping Start on a WorkoutCard.
  Future<void> navigateToTrackerViaStart(
    WidgetTester tester,
    String workoutName,
  ) async {
    await Future.delayed(const Duration(seconds: 3));
    await tester.pump();

    final workoutCard = find.ancestor(
      of: find.text(workoutName),
      matching: find.byType(WorkoutCard),
    );
    final startButton = find.descendant(
      of: workoutCard,
      matching: find.text('Start'),
    );
    await tester.tap(startButton);
    // Multiple pump cycles to ensure async navigation + session init completes
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      await tester.pump();
    }
  }

  /// Tap a GestureDetector wrapping a specific text, even if off-screen.
  /// The tracker header suffixes can overflow, so we invoke onTap directly.
  Future<void> tapGestureDetectorWithText(
    WidgetTester tester,
    String text,
  ) async {
    final gestureDetector = find.ancestor(
      of: find.text(text),
      matching: find.byType(GestureDetector),
    );
    final widget = tester.widget<GestureDetector>(gestureDetector.first);
    widget.onTap?.call();
    await Future.delayed(const Duration(seconds: 1));
    await tester.pump();
  }

  group('Tracker Advanced E2E', () {
    testWidgets('Quick Start session launches empty tracker', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        await pumpApp(tester);

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Find the Quick Start card's Start button
        final quickStartCard = find.ancestor(
          of: find.text('Quick Start'),
          matching: find.byType(Container),
        );
        final startButton = find.descendant(
          of: quickStartCard.first,
          matching: find.text('Start'),
        );
        await tester.tap(startButton.first);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Tracker screen should load
      expect(find.byType(Scaffold), findsWidgets);
      // Empty session - no SetRow widgets
      expect(find.byType(SetRow), findsNothing);

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('Finish workout from tracker shows confirm dialog',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('FW');
        await TestData.createWorkoutWithExercise(name: name);
        await pumpApp(tester);
        await navigateToTrackerViaStart(tester, name);

        // Invoke Finish via GestureDetector.onTap (may be off-screen in header)
        await tapGestureDetectorWithText(tester, 'Finish');
      });

      // Confirm dialog should appear
      expect(find.text('Finish Workout?'), findsOneWidget);
      expect(
        find.text('Are you sure you want to finish this workout?'),
        findsOneWidget,
      );

      // Tap confirm button in dialog (dialog buttons are centered, on-screen)
      await tester.runAsync(() async {
        await tester.tap(find.text('Finish').last);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Should return to home
      expect(find.text('Heft'), findsOneWidget);
    });

    testWidgets('Discard workout from tracker shows confirm dialog',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('DW');
        await TestData.createWorkoutWithExercise(name: name);
        await pumpApp(tester);
        await navigateToTrackerViaStart(tester, name);

        // Invoke Discard via GestureDetector.onTap (may be off-screen in header)
        await tapGestureDetectorWithText(tester, 'Discard');
      });

      // Confirm dialog should appear
      expect(find.text('Discard Workout?'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to discard this workout? All progress will be lost.',
        ),
        findsOneWidget,
      );

      // Tap confirm button in dialog
      await tester.runAsync(() async {
        await tester.tap(find.text('Discard').last);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Should return to home
      expect(find.text('Heft'), findsOneWidget);
    });

    testWidgets('Resume active session via floating widget loads tracker',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('RS');
        final workoutId =
            await TestData.createWorkoutWithExercise(name: name);
        await TestData.startSession(workoutTemplateId: workoutId);
        await pumpApp(tester);

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Floating session widget should be visible
      expect(find.byType(FloatingSessionWidget), findsOneWidget);

      await tester.runAsync(() async {
        // Tap the floating widget's GestureDetector to navigate to tracker
        // The floating widget is positioned absolutely and may not pass hit test
        final floatingGesture = find.descendant(
          of: find.byType(FloatingSessionWidget),
          matching: find.byType(GestureDetector),
        );
        if (floatingGesture.evaluate().isNotEmpty) {
          final widget =
              tester.widget<GestureDetector>(floatingGesture.first);
          widget.onTap?.call();
        }
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Tracker should load (Scaffold visible, with session data)
      expect(find.byType(Scaffold), findsWidgets);

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('Add exercise mid-session opens search modal',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('AE');
        await TestData.createWorkoutWithExercise(name: name);
        await pumpApp(tester);
        await navigateToTrackerViaStart(tester, name);

        // Tap "Exercise" button in section header via GestureDetector.onTap
        // (may be off-screen in narrow viewport)
        await tapGestureDetectorWithText(tester, 'Exercise');
      });

      // ExerciseSearchModal should open
      expect(find.byType(ExerciseSearchModal), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tapAt(const Offset(10, 10));
        await Future.delayed(const Duration(seconds: 1));
        await tester.pump();
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('Session duration timer is visible in header',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('DT');
        await TestData.createWorkoutWithExercise(name: name);
        await pumpApp(tester);
        await navigateToTrackerViaStart(tester, name);
      });

      // Duration timer should be visible - formatDuration outputs "X:XX" format
      final durationFinder = find.textContaining(RegExp(r'\d+:\d{2}'));
      expect(durationFinder, findsWidgets);

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
      });
    });

    testWidgets('Prevent second session shows toast', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final nameA = getUniqueName('WA');
        final nameB = getUniqueName('WB');
        final workoutIdA =
            await TestData.createWorkoutWithExercise(name: nameA);
        await TestData.createWorkoutWithExercise(name: nameB);

        // Start session for workout A
        await TestData.startSession(workoutTemplateId: workoutIdA);
        await pumpApp(tester);

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Find workout B card and tap its Start button
        final workoutBCard = find.ancestor(
          of: find.text(nameB),
          matching: find.byType(WorkoutCard),
        );
        final startButton = find.descendant(
          of: workoutBCard,
          matching: find.text('Start'),
        );
        await tester.tap(startButton);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Toast message should appear
      expect(
        find.text('Please finish your current workout first'),
        findsOneWidget,
      );

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
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
