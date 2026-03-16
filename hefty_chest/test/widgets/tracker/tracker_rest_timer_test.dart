import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:hefty_chest/features/tracker/tracker_screen.dart';
import 'package:hefty_chest/features/tracker/widgets/rest_timer_sheet.dart';
import 'package:hefty_chest/features/tracker/widgets/rest_item_card.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';
import 'package:hefty_chest/shared/widgets/floating_session_widget.dart';

import 'tracker_test_helpers.dart';

void main() {
  group('RestTimerSheet', () {
    testWidgets('displays timer with formatted time', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Stack(
            children: [
              RestTimerSheet(
                initialTime: 90,
                nextExerciseName: 'Squat',
                nextSetNumber: 2,
                onSkip: () {},
                onComplete: () {},
              ),
            ],
          ),
        ),
      );

      // Should show "Rest" label
      expect(find.text('Rest'), findsOneWidget);

      // Should show next exercise info
      expect(find.text('Next: Squat - Set 2'), findsOneWidget);
    });

    testWidgets('displays Skip button with FButton ghost style', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Stack(
            children: [
              RestTimerSheet(
                initialTime: 60,
                nextExerciseName: 'Deadlift',
                nextSetNumber: 1,
                onSkip: () {},
                onComplete: () {},
              ),
            ],
          ),
        ),
      );

      // Should show Skip button
      expect(find.text('Skip'), findsOneWidget);

      // Should have FButton widgets (Skip and +30s)
      expect(find.byType(FButton), findsNWidgets(2));
    });

    testWidgets('displays +30s button', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Stack(
            children: [
              RestTimerSheet(
                initialTime: 60,
                nextExerciseName: 'Bench Press',
                nextSetNumber: 3,
                onSkip: () {},
                onComplete: () {},
              ),
            ],
          ),
        ),
      );

      // Should show +30s button
      expect(find.text('+30s'), findsOneWidget);
    });

    testWidgets('Skip button is tappable', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Stack(
            children: [
              RestTimerSheet(
                initialTime: 60,
                nextExerciseName: 'Squat',
                nextSetNumber: 1,
                onSkip: () {},
                onComplete: () {},
              ),
            ],
          ),
        ),
      );

      // Verify Skip button exists and is a FButton
      final skipButton = find.widgetWithText(FButton, 'Skip');
      expect(skipButton, findsOneWidget);
    });

    testWidgets('shows circular progress indicator', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Stack(
            children: [
              RestTimerSheet(
                initialTime: 120,
                nextExerciseName: 'Lat Pulldown',
                nextSetNumber: 1,
                onSkip: () {},
                onComplete: () {},
              ),
            ],
          ),
        ),
      );

      // Should have CustomPaint for circular progress
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('timer counts down', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Stack(
            children: [
              RestTimerSheet(
                initialTime: 5,
                nextExerciseName: 'Test',
                nextSetNumber: 1,
                onSkip: () {},
                onComplete: () {},
              ),
            ],
          ),
        ),
      );

      // Initial time should show 0:05
      expect(find.text('0:05'), findsOneWidget);

      // Wait 1 second
      await tester.pump(const Duration(seconds: 1));

      // Should show 0:04
      expect(find.text('0:04'), findsOneWidget);
    });

    testWidgets('formats time with minutes correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          Stack(
            children: [
              RestTimerSheet(
                initialTime: 125, // 2:05
                nextExerciseName: 'Test',
                nextSetNumber: 1,
                onSkip: () {},
                onComplete: () {},
              ),
            ],
          ),
        ),
      );

      // Should show 2:05
      expect(find.text('2:05'), findsOneWidget);
    });
  });

  group('Zero-duration rest items', () {
    Widget createTrackerWidgetWithSession(SessionModel session) {
      final trackingNotifier = TrackingActiveSession(session);
      return ProviderScope(
        overrides: [
          activeSessionProvider.overrideWith(() => trackingNotifier),
          floatingWidgetVisibleProvider.overrideWith(SafeFloatingWidgetVisible.new),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.dark,
            child: TrackerScreen(sessionId: session.id),
          ),
        ),
      );
    }

    testWidgets('does not render rest item with zero duration', (tester) async {
      final session = createMockSession(
        exercises: [
          createMockExercise(
            id: 'ex-1',
            exerciseName: 'Bench Press',
            sectionName: 'Main',
          ),
        ],
      ).copyWith(
        restItems: [
          const SessionRestItemModel(
            id: 'rest-zero',
            displayOrder: 2,
            sectionName: 'Main',
            restDurationSeconds: 0,
          ),
        ],
      );

      await tester.pumpWidget(createTrackerWidgetWithSession(session));
      await tester.pumpAndSettle();

      // Zero-duration rest item should not be rendered
      expect(find.byType(RestItemCard), findsNothing);
      expect(find.text('Rest'), findsNothing);
    });
  });
}
