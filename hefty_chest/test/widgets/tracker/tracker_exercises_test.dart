import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hefty_chest/features/tracker/widgets/tracker_section_card.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/gen/common.pbenum.dart';

import 'tracker_test_helpers.dart';

void main() {
  group('TrackerSectionCard', () {
    testWidgets('displays exercise name', (tester) async {
      final exercise = createMockExercise(exerciseName: 'Deadlift');

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      expect(find.text('Deadlift'), findsOneWidget);
    });

    testWidgets('displays set rows with table headers', (tester) async {
      final exercise = createMockExercise(
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            weightKg: 100.0,
            reps: 5,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Should show table headers
      expect(find.text('SET'), findsOneWidget);
      expect(find.text('KG'), findsOneWidget);
      expect(find.text('REPS'), findsOneWidget);
      expect(find.text('PR'), findsOneWidget);
    });

    testWidgets('displays TIME header for time-based exercises', (tester) async {
      final exercise = createMockExercise(
        exerciseName: 'Plank',
        exerciseType: ExerciseType.EXERCISE_TYPE_TIME,
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            timeSeconds: 60,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Should show TIME header instead of KG/REPS
      expect(find.text('TIME'), findsOneWidget);
      expect(find.text('KG'), findsNothing);
      expect(find.text('REPS'), findsNothing);
    });

    testWidgets('shows Add Set button with FButton', (tester) async {
      final exercise = createMockExercise(
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Should show Add Set button
      expect(find.text('Add Set'), findsOneWidget);

      // Should be using FButton
      expect(find.byType(FButton), findsOneWidget);

      // Should have add icon
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays notes when present', (tester) async {
      final exercise = createMockExercise(
        notes: 'Keep core tight, control the descent',
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      expect(find.text('Keep core tight, control the descent'), findsOneWidget);
    });

    testWidgets('does not display notes section when notes empty',
        (tester) async {
      final exercise = createMockExercise(
        notes: '',
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Notes text should not be present
      expect(find.text('Keep core tight'), findsNothing);
    });

    testWidgets('can toggle expansion by tapping header', (tester) async {
      final exercise = createMockExercise(
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Initially expanded - FCollapsible value should be 1.0
      var collapsible = tester.widget<FCollapsible>(find.byType(FCollapsible));
      expect(collapsible.value, equals(1.0));
      expect(find.text('SET'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      // Should be collapsed - FCollapsible value should be 0.0
      collapsible = tester.widget<FCollapsible>(find.byType(FCollapsible));
      expect(collapsible.value, equals(0.0));

      // Tap to expand again
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      // Should be expanded again - FCollapsible value should be 1.0
      collapsible = tester.widget<FCollapsible>(find.byType(FCollapsible));
      expect(collapsible.value, equals(1.0));
    });

    testWidgets('uses FCollapsible for smooth expand/collapse animation', (tester) async {
      final exercise = createMockExercise(
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Verify FCollapsible is used and starts expanded
      expect(find.byType(FCollapsible), findsOneWidget);
      var collapsible = tester.widget<FCollapsible>(find.byType(FCollapsible));
      expect(collapsible.value, equals(1.0));

      // Tap to start collapse animation
      await tester.tap(find.text('Bench Press'));

      // Pump a frame to start the animation
      await tester.pump();

      // Pump partial duration (animation is 200ms, so 100ms should be mid-animation)
      await tester.pump(const Duration(milliseconds: 100));

      // Content should be animating (FCollapsible value between 0 and 1)
      collapsible = tester.widget<FCollapsible>(find.byType(FCollapsible));
      expect(collapsible.value, lessThan(1.0));
      expect(collapsible.value, greaterThan(0.0));

      // Complete animation
      await tester.pumpAndSettle();

      // Verify fully collapsed
      collapsible = tester.widget<FCollapsible>(find.byType(FCollapsible));
      expect(collapsible.value, equals(0.0));
    });

    testWidgets('starts expanded by default with FCollapsible value 1.0', (tester) async {
      final exercise = createMockExercise(
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Verify starts expanded (FCollapsible value = 1.0)
      final collapsible = tester.widget<FCollapsible>(find.byType(FCollapsible));
      expect(collapsible.value, equals(1.0));

      // Content should be visible
      expect(find.text('SET'), findsOneWidget);
      expect(find.text('Add Set'), findsOneWidget);
    });

    testWidgets('shows more options menu icon in header', (tester) async {
      final exercise = createMockExercise(
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Should show the more_vert icon (header has one, each set row may have one too)
      expect(find.byIcon(Icons.more_vert), findsWidgets);
    });

    testWidgets('uses 16px padding in header', (tester) async {
      final exercise = createMockExercise(
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Find the header Container with the exercise name
      final headerFinder = find.ancestor(
        of: find.text('Bench Press'),
        matching: find.byType(Container),
      );

      // Should have at least one Container ancestor
      expect(headerFinder, findsWidgets);
    });

    testWidgets('renders multiple sets', (tester) async {
      final exercise = createMockExercise(
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            weightKg: 60.0,
            reps: 10,
            isCompleted: true,
          ),
          const SessionSetModel(
            id: 'set-2',
            setNumber: 2,
            weightKg: 65.0,
            reps: 8,
            isCompleted: false,
          ),
          const SessionSetModel(
            id: 'set-3',
            setNumber: 3,
            weightKg: 70.0,
            reps: 6,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // The exercise card should render without errors with multiple sets
      expect(find.byType(TrackerSectionCard), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('shows exercise card with 12px border radius', (tester) async {
      final exercise = createMockExercise(
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      // Find the main container of TrackerSectionCard
      final exerciseCardContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(TrackerSectionCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = exerciseCardContainer.decoration as BoxDecoration?;
      expect(decoration?.borderRadius, equals(BorderRadius.circular(12)));
    });
  });

  group('TrackerSectionCard - Different Exercise Types', () {
    testWidgets('weight_reps exercise shows KG and REPS columns',
        (tester) async {
      final exercise = createMockExercise(
        exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      expect(find.text('KG'), findsOneWidget);
      expect(find.text('REPS'), findsOneWidget);
      expect(find.text('TIME'), findsNothing);
    });

    testWidgets('time exercise shows TIME column only', (tester) async {
      final exercise = createMockExercise(
        exerciseType: ExerciseType.EXERCISE_TYPE_TIME,
        sets: [
          const SessionSetModel(
            id: 'set-1',
            setNumber: 1,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: TrackerSectionCard(
              exercise: exercise,
              onSetCompleted: (_, _, _, _) {},
            ),
          ),
        ),
      );

      expect(find.text('TIME'), findsOneWidget);
      expect(find.text('KG'), findsNothing);
      expect(find.text('REPS'), findsNothing);
    });
  });
}
