import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:hefty_chest/features/tracker/tracker_screen.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';
import 'package:hefty_chest/shared/widgets/exercise_picker_modal.dart';
import 'package:hefty_chest/shared/widgets/floating_session_widget.dart';
import 'package:hefty_chest/gen/common.pbenum.dart';

import 'tracker_test_helpers.dart';

void main() {
  group('TrackerScreen Add Section flow', () {
    /// Mock notifier that tracks addExercise calls
    late TrackingActiveSession trackingNotifier;
    late SessionModel mockSession;

    setUp(() {
      mockSession = SessionModel(
        id: 'test-session',
        workoutTemplateId: 'test-workout',
        name: 'Test Workout',
        exercises: [
          const SessionExerciseModel(
            id: 'ex-1',
            exerciseId: 'exercise-1',
            exerciseName: 'Bench Press',
            sectionName: 'Main',
            exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
            sets: [
              SessionSetModel(id: 'set-1', setNumber: 1),
            ],
          ),
        ],
        completedSets: 0,
        totalSets: 1,
      );
      trackingNotifier = TrackingActiveSession(mockSession);
    });

    Widget createTrackerWidget() {
      return ProviderScope(
        overrides: [
          activeSessionProvider.overrideWith(() => trackingNotifier),
          floatingWidgetVisibleProvider.overrideWith(SafeFloatingWidgetVisible.new),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.dark,
            child: const TrackerScreen(sessionId: 'test-session'),
          ),
        ),
      );
    }

    testWidgets('renders Add Section button at bottom', (tester) async {
      await tester.pumpWidget(createTrackerWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add Section'), findsOneWidget);
    });

    testWidgets('tapping Add Section opens dialog', (tester) async {
      await tester.pumpWidget(createTrackerWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Section'));
      await tester.pumpAndSettle();

      // Dialog title should appear
      expect(find.text('New Section'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Cancel closes dialog without opening modal', (tester) async {
      await tester.pumpWidget(createTrackerWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Section'));
      await tester.pumpAndSettle();

      // Dialog should be open
      expect(find.text('New Section'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('New Section'), findsNothing);
      // Modal should not open
      expect(find.byType(ExercisePickerModal), findsNothing);
    });

    testWidgets('entering name and Next opens exercise modal', (tester) async {
      await tester.pumpWidget(createTrackerWidget());
      await tester.pumpAndSettle();

      // Open Add Section dialog
      await tester.tap(find.text('Add Section'));
      await tester.pumpAndSettle();

      // Find the TextField with 'Section name' hint (from FTextField)
      // Since there may be multiple TextFields, find the one near "New Section" title
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Enter text in the last TextField (the one in the dialog)
      await tester.enterText(textFields.last, 'My Custom Section');
      await tester.pumpAndSettle();

      // Tap Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Exercise modal should open
      expect(find.byType(ExercisePickerModal), findsOneWidget);
    });
  });

  group('TrackerScreen Add Exercise to Section', () {
    late TrackingActiveSession trackingNotifier;
    late SessionModel mockSession;

    setUp(() {
      mockSession = SessionModel(
        id: 'test-session',
        workoutTemplateId: 'test-workout',
        name: 'Test Workout',
        exercises: [
          const SessionExerciseModel(
            id: 'ex-1',
            exerciseId: 'exercise-1',
            exerciseName: 'Bench Press',
            sectionName: 'Main',
            exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
            sets: [
              SessionSetModel(id: 'set-1', setNumber: 1),
            ],
          ),
        ],
        completedSets: 0,
        totalSets: 1,
      );
      trackingNotifier = TrackingActiveSession(mockSession);
    });

    Widget createTrackerWidget() {
      return ProviderScope(
        overrides: [
          activeSessionProvider.overrideWith(() => trackingNotifier),
          floatingWidgetVisibleProvider.overrideWith(SafeFloatingWidgetVisible.new),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.zinc.dark,
            child: const TrackerScreen(sessionId: 'test-session'),
          ),
        ),
      );
    }

    testWidgets('section header shows + Exercise button', (tester) async {
      await tester.pumpWidget(createTrackerWidget());
      await tester.pumpAndSettle();

      // Should find the "Exercise" add button in section header
      expect(find.text('Exercise'), findsOneWidget);
    });

    testWidgets('tapping + Exercise opens exercise modal', (tester) async {
      await tester.pumpWidget(createTrackerWidget());
      await tester.pumpAndSettle();

      // Tap the "Exercise" add button
      await tester.tap(find.text('Exercise'));
      await tester.pumpAndSettle();

      // Exercise modal should open
      expect(find.byType(ExercisePickerModal), findsOneWidget);
    });
  });

  group('Superset UI', () {
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

    testWidgets('Superset badge appears when exercises have supersetId', (tester) async {
      final supersetExercises = [
        const SessionExerciseModel(
          id: 'ex1',
          exerciseId: 'exercise-1',
          exerciseName: 'Bench Press',
          sectionName: 'Chest Superset',
          exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          sets: [SessionSetModel(id: 'set1', setNumber: 1)],
          supersetId: 'superset-uuid-123', // Same superset ID
        ),
        const SessionExerciseModel(
          id: 'ex2',
          exerciseId: 'exercise-2',
          exerciseName: 'Dumbbell Fly',
          sectionName: 'Chest Superset',
          exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          sets: [SessionSetModel(id: 'set2', setNumber: 1)],
          supersetId: 'superset-uuid-123', // Same superset ID
        ),
      ];

      final session = SessionModel(
        id: 'test-session',
        workoutTemplateId: 'test-workout',
        name: 'Test Workout',
        exercises: supersetExercises,
      );

      await tester.pumpWidget(createTrackerWidgetWithSession(session));
      await tester.pumpAndSettle();

      // Verify "Superset" badge appears
      expect(find.text('Superset'), findsOneWidget);
    });

    testWidgets('Superset toggle shows inactive state when exercises have no supersetId', (tester) async {
      final normalExercises = [
        const SessionExerciseModel(
          id: 'ex1',
          exerciseId: 'exercise-1',
          exerciseName: 'Bench Press',
          sectionName: 'Main Workout',
          exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          sets: [SessionSetModel(id: 'set1', setNumber: 1)],
          supersetId: null, // No superset
        ),
        const SessionExerciseModel(
          id: 'ex2',
          exerciseId: 'exercise-2',
          exerciseName: 'Squats',
          sectionName: 'Main Workout',
          exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          sets: [SessionSetModel(id: 'set2', setNumber: 1)],
          supersetId: null, // No superset
        ),
      ];

      final session = SessionModel(
        id: 'test-session',
        workoutTemplateId: 'test-workout',
        name: 'Test Workout',
        exercises: normalExercises,
      );

      await tester.pumpWidget(createTrackerWidgetWithSession(session));
      await tester.pumpAndSettle();

      // Superset toggle always visible but shows inactive icon (link_off)
      expect(find.text('Superset'), findsOneWidget);
      expect(find.byIcon(Icons.link_off), findsOneWidget);
      expect(find.byIcon(Icons.link), findsNothing);
    });

    testWidgets('Superset exercises are wrapped with left border', (tester) async {
      final supersetExercises = [
        const SessionExerciseModel(
          id: 'ex1',
          exerciseId: 'exercise-1',
          exerciseName: 'Bench Press',
          sectionName: 'Chest Superset',
          exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          sets: [SessionSetModel(id: 'set1', setNumber: 1)],
          supersetId: 'superset-uuid-123',
        ),
      ];

      final session = SessionModel(
        id: 'test-session',
        workoutTemplateId: 'test-workout',
        name: 'Test Workout',
        exercises: supersetExercises,
      );

      await tester.pumpWidget(createTrackerWidgetWithSession(session));
      await tester.pumpAndSettle();

      // Verify container with superset border exists (3px left border)
      final borderContainers = tester.widgetList<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          if (decoration is! BoxDecoration) return false;
          final border = decoration.border;
          if (border is! Border) return false;
          return border.left.width == 3;
        }),
      );
      expect(borderContainers.isNotEmpty, isTrue,
          reason: 'Should have container with 3px superset left border');
    });

    testWidgets('Mixed sections show active/inactive superset toggles', (tester) async {
      final mixedExercises = [
        // Normal section
        const SessionExerciseModel(
          id: 'ex1',
          exerciseId: 'exercise-1',
          exerciseName: 'Warm Up Exercise',
          sectionName: 'Warm Up',
          exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          sets: [SessionSetModel(id: 'set1', setNumber: 1)],
          supersetId: null,
        ),
        // Superset section
        const SessionExerciseModel(
          id: 'ex2',
          exerciseId: 'exercise-2',
          exerciseName: 'Bench Press',
          sectionName: 'Chest Superset',
          exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          sets: [SessionSetModel(id: 'set2', setNumber: 1)],
          supersetId: 'superset-uuid-123',
        ),
        const SessionExerciseModel(
          id: 'ex3',
          exerciseId: 'exercise-3',
          exerciseName: 'Dumbbell Fly',
          sectionName: 'Chest Superset',
          exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          sets: [SessionSetModel(id: 'set3', setNumber: 1)],
          supersetId: 'superset-uuid-123',
        ),
      ];

      final session = SessionModel(
        id: 'test-session',
        workoutTemplateId: 'test-workout',
        name: 'Test Workout',
        exercises: mixedExercises,
      );

      await tester.pumpWidget(createTrackerWidgetWithSession(session));
      await tester.pumpAndSettle();

      // Both sections show superset toggle
      expect(find.text('Superset'), findsNWidgets(2));

      // One active (link icon) and one inactive (link_off icon)
      expect(find.byIcon(Icons.link), findsOneWidget);
      expect(find.byIcon(Icons.link_off), findsOneWidget);

      // Both section headers should exist
      expect(find.text('Warm Up'), findsOneWidget);
      expect(find.text('Chest Superset'), findsOneWidget);
    });
  });
}
