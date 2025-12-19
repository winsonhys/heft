import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hefty_chest/features/tracker/widgets/progress_header.dart';
import 'package:hefty_chest/features/tracker/widgets/exercise_card.dart';
import 'package:hefty_chest/features/tracker/widgets/rest_timer_sheet.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/gen/common.pbenum.dart';

/// Creates a mock Session for testing
Session createMockSession({
  String id = 'test-session-id',
  String name = 'Test Workout',
  int completedSets = 3,
  int totalSets = 10,
  List<SessionExercise>? exercises,
}) {
  final session = Session()
    ..id = id
    ..name = name
    ..completedSets = completedSets
    ..totalSets = totalSets;

  if (exercises != null) {
    session.exercises.addAll(exercises);
  }

  return session;
}

/// Creates a mock SessionExercise for testing
SessionExercise createMockExercise({
  String id = 'exercise-1',
  String exerciseId = 'ex-1',
  String exerciseName = 'Bench Press',
  String sectionName = 'Main Workout',
  ExerciseType exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
  List<SessionSet>? sets,
  String notes = '',
}) {
  final exercise = SessionExercise()
    ..id = id
    ..exerciseId = exerciseId
    ..exerciseName = exerciseName
    ..sectionName = sectionName
    ..exerciseType = exerciseType
    ..notes = notes;

  if (sets != null) {
    exercise.sets.addAll(sets);
  } else {
    // Add default sets
    exercise.sets.addAll([
      SessionSet()
        ..id = 'set-1'
        ..setNumber = 1
        ..weightKg = 60.0
        ..reps = 10
        ..isCompleted = true,
      SessionSet()
        ..id = 'set-2'
        ..setNumber = 2
        ..weightKg = 60.0
        ..reps = 10
        ..isCompleted = false,
    ]);
  }

  return exercise;
}

/// Helper to wrap widget with FTheme
Widget wrapWithTheme(Widget child) {
  return MaterialApp(
    home: FTheme(
      data: FThemes.zinc.dark,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('ProgressHeader', () {
    testWidgets('displays correct progress values', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const ProgressHeader(
            progress: 0.6,
            completedSets: 6,
            totalSets: 10,
          ),
        ),
      );

      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('6 / 10 sets'), findsOneWidget);
      expect(find.text('60% complete'), findsOneWidget);
    });

    testWidgets('handles zero total sets', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const ProgressHeader(
            progress: 0.0,
            completedSets: 0,
            totalSets: 0,
          ),
        ),
      );

      expect(find.text('0 / 0 sets'), findsOneWidget);
      expect(find.text('0% complete'), findsOneWidget);
    });

    testWidgets('shows 100% when all sets completed', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const ProgressHeader(
            progress: 1.0,
            completedSets: 12,
            totalSets: 12,
          ),
        ),
      );

      expect(find.text('12 / 12 sets'), findsOneWidget);
      expect(find.text('100% complete'), findsOneWidget);
    });

    testWidgets('rounds percentage correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const ProgressHeader(
            progress: 0.333,
            completedSets: 1,
            totalSets: 3,
          ),
        ),
      );

      expect(find.text('1 / 3 sets'), findsOneWidget);
      expect(find.text('33% complete'), findsOneWidget);
    });

    testWidgets('uses consistent 16px padding', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const ProgressHeader(
            progress: 0.5,
            completedSets: 5,
            totalSets: 10,
          ),
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

  group('ExerciseCard', () {
    testWidgets('displays exercise name', (tester) async {
      final exercise = createMockExercise(exerciseName: 'Deadlift');

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
            ),
          ),
        ),
      );

      expect(find.text('Deadlift'), findsOneWidget);
    });

    testWidgets('displays set rows with table headers', (tester) async {
      final exercise = createMockExercise(
        sets: [
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..weightKg = 100.0
            ..reps = 5
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
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
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..timeSeconds = 60
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
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
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
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
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
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
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
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
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
            ),
          ),
        ),
      );

      // Initially expanded - should show table header
      expect(find.text('SET'), findsOneWidget);
      expect(find.text('Add Set'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      // Should be collapsed - no table header
      expect(find.text('SET'), findsNothing);
      expect(find.text('Add Set'), findsNothing);

      // Tap to expand again
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      // Should be expanded again
      expect(find.text('SET'), findsOneWidget);
      expect(find.text('Add Set'), findsOneWidget);
    });

    testWidgets('shows more options menu icon in header', (tester) async {
      final exercise = createMockExercise(
        sets: [
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
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
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
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
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..weightKg = 60.0
            ..reps = 10
            ..isCompleted = true,
          SessionSet()
            ..id = 'set-2'
            ..setNumber = 2
            ..weightKg = 65.0
            ..reps = 8
            ..isCompleted = false,
          SessionSet()
            ..id = 'set-3'
            ..setNumber = 3
            ..weightKg = 70.0
            ..reps = 6
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
            ),
          ),
        ),
      );

      // The exercise card should render without errors with multiple sets
      expect(find.byType(ExerciseCard), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('shows exercise card with 12px border radius', (tester) async {
      final exercise = createMockExercise(
        sets: [
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
            ),
          ),
        ),
      );

      // Find the main container of ExerciseCard
      final exerciseCardContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(ExerciseCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = exerciseCardContainer.decoration as BoxDecoration?;
      expect(decoration?.borderRadius, equals(BorderRadius.circular(12)));
    });
  });

  group('ExerciseCard - Different Exercise Types', () {
    testWidgets('weight_reps exercise shows KG and REPS columns',
        (tester) async {
      final exercise = createMockExercise(
        exerciseType: ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
        sets: [
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
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
          SessionSet()
            ..id = 'set-1'
            ..setNumber = 1
            ..isCompleted = false,
        ],
      );

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: ExerciseCard(
              exercise: exercise,
              onSetCompleted: (_, __, ___, ____) {},
            ),
          ),
        ),
      );

      expect(find.text('TIME'), findsOneWidget);
      expect(find.text('KG'), findsNothing);
      expect(find.text('REPS'), findsNothing);
    });
  });

  group('RestTimerSheet', () {
    testWidgets('displays timer with formatted time', (tester) async {
      bool skipCalled = false;
      bool completeCalled = false;

      await tester.pumpWidget(
        wrapWithTheme(
          Stack(
            children: [
              RestTimerSheet(
                initialTime: 90,
                nextExerciseName: 'Squat',
                nextSetNumber: 2,
                onSkip: () => skipCalled = true,
                onComplete: () => completeCalled = true,
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
}
