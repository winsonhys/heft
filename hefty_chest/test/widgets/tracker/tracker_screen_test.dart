import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hefty_chest/features/tracker/tracker_screen.dart';
import 'package:hefty_chest/features/tracker/widgets/progress_header.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';
import 'package:hefty_chest/shared/widgets/floating_session_widget.dart';
import 'package:hefty_chest/gen/common.pbenum.dart';

import 'tracker_test_helpers.dart';

void main() {
  group('ProgressHeader', () {
    testWidgets('displays correct progress values', (tester) async {
      await tester.pumpWidget(
        wrapWithThemeAndProvider(
          const ProgressHeader(),
          mockSession: createSessionWithSets(6, 10),
        ),
      );

      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('6 / 10 sets'), findsOneWidget);
      expect(find.text('60% complete'), findsOneWidget);
    });

    testWidgets('handles zero total sets', (tester) async {
      await tester.pumpWidget(
        wrapWithThemeAndProvider(
          const ProgressHeader(),
          mockSession: createSessionWithSets(0, 0),
        ),
      );

      expect(find.text('0 / 0 sets'), findsOneWidget);
      expect(find.text('0% complete'), findsOneWidget);
    });

    testWidgets('shows 100% when all sets completed', (tester) async {
      await tester.pumpWidget(
        wrapWithThemeAndProvider(
          const ProgressHeader(),
          mockSession: createSessionWithSets(12, 12),
        ),
      );

      expect(find.text('12 / 12 sets'), findsOneWidget);
      expect(find.text('100% complete'), findsOneWidget);
    });

    testWidgets('rounds percentage correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithThemeAndProvider(
          const ProgressHeader(),
          mockSession: createSessionWithSets(1, 3),
        ),
      );

      expect(find.text('1 / 3 sets'), findsOneWidget);
      expect(find.text('33% complete'), findsOneWidget);
    });

    testWidgets('uses consistent 16px padding', (tester) async {
      await tester.pumpWidget(
        wrapWithThemeAndProvider(
          const ProgressHeader(),
          mockSession: createSessionWithSets(5, 10),
        ),
      );

      // Find the Container that wraps the ProgressHeader content
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ProgressHeader),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.padding, equals(const EdgeInsets.all(16)));
    });
  });

  // Title and Discard tests
  group('TrackerScreen Title', () {
    late TrackingActiveSession trackingNotifier;

    Widget createTrackerWidget(SessionModel session) {
      trackingNotifier = TrackingActiveSession(session);
      return ProviderScope(
        overrides: [
          activeSessionProvider.overrideWith(() => trackingNotifier),
          floatingWidgetVisibleProvider.overrideWith(SafeFloatingWidgetVisible.new),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.dark,
            child: FToaster(
              child: const TrackerScreen(sessionId: 'test-session'),
            ),
          ),
        ),
      );
    }

    testWidgets('shows workout name in title', (tester) async {
      final session = SessionModel(
        id: 'test-session',
        workoutTemplateId: 'test-workout',
        name: 'Push Day',
        exercises: const [
          SessionExerciseModel(
            id: 'ex-1',
            exerciseId: 'exercise-1',
            exerciseName: 'Bench Press',
            sectionName: 'Main',
            exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
            sets: [SessionSetModel(id: 'set-1', setNumber: 1)],
          ),
        ],
        completedSets: 0,
        totalSets: 1,
      );

      await tester.pumpWidget(createTrackerWidget(session));
      await tester.pumpAndSettle();

      expect(find.text('Push Day'), findsOneWidget);
    });

    testWidgets('shows fallback title when name empty', (tester) async {
      final session = SessionModel(
        id: 'test-session',
        workoutTemplateId: 'test-workout',
        name: '',
        exercises: const [
          SessionExerciseModel(
            id: 'ex-1',
            exerciseId: 'exercise-1',
            exerciseName: 'Bench Press',
            sectionName: 'Main',
            exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
            sets: [SessionSetModel(id: 'set-1', setNumber: 1)],
          ),
        ],
        completedSets: 0,
        totalSets: 1,
      );

      await tester.pumpWidget(createTrackerWidget(session));
      await tester.pumpAndSettle();

      expect(find.text('Workout'), findsOneWidget);
    });
  });

  group('TrackerScreen Discard Workout', () {
    late TrackingActiveSession trackingNotifier;

    Widget createTrackerWidget(SessionModel session) {
      trackingNotifier = TrackingActiveSession(session);
      final router = GoRouter(
        initialLocation: '/session/test-session',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/session/:sessionId',
            builder: (context, state) => const TrackerScreen(sessionId: 'test-session'),
          ),
        ],
      );
      return ProviderScope(
        overrides: [
          activeSessionProvider.overrideWith(() => trackingNotifier),
          floatingWidgetVisibleProvider.overrideWith(SafeFloatingWidgetVisible.new),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => FTheme(
            data: FThemes.zinc.dark,
            child: FToaster(child: child!),
          ),
        ),
      );
    }

    SessionModel createTestSession() {
      return const SessionModel(
        id: 'test-session',
        workoutTemplateId: 'test-workout',
        name: 'Test Workout',
        exercises: [
          SessionExerciseModel(
            id: 'ex-1',
            exerciseId: 'exercise-1',
            exerciseName: 'Bench Press',
            sectionName: 'Main',
            exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
            sets: [SessionSetModel(id: 'set-1', setNumber: 1)],
          ),
        ],
        completedSets: 0,
        totalSets: 1,
      );
    }

    testWidgets('shows Discard button in header', (tester) async {
      await tester.pumpWidget(createTrackerWidget(createTestSession()));
      await tester.pumpAndSettle();

      expect(find.text('Discard'), findsOneWidget);
    });

    testWidgets('tapping Discard shows discard confirmation dialog', (tester) async {
      await tester.pumpWidget(createTrackerWidget(createTestSession()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.text('Discard Workout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      // "Discard" appears twice: header button + dialog confirm button
      expect(find.text('Discard'), findsNWidgets(2));
    });

    testWidgets('Cancel in discard dialog does not abandon session', (tester) async {
      await tester.pumpWidget(createTrackerWidget(createTestSession()));
      await tester.pumpAndSettle();

      // Tap header Discard to open dialog
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.text('Discard Workout?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Discard Workout?'), findsNothing);
      expect(trackingNotifier.abandonSessionCalled, isFalse);
    });

    testWidgets('Discard in dialog calls abandonSession', (tester) async {
      await tester.pumpWidget(createTrackerWidget(createTestSession()));
      await tester.pumpAndSettle();

      // Tap the header "Discard" button
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Now tap "Discard" in the confirmation dialog
      // The dialog has "Discard Workout?" title, "Cancel" and "Discard" buttons
      // There are now two "Discard" texts — tap the last one (dialog button)
      await tester.tap(find.text('Discard').last);
      await tester.pumpAndSettle();

      expect(trackingNotifier.abandonSessionCalled, isTrue);
    });
  });
}
