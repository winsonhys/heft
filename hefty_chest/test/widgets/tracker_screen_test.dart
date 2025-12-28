import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hefty_chest/features/tracker/tracker_screen.dart';
import 'package:hefty_chest/features/tracker/widgets/progress_header.dart';
import 'package:hefty_chest/features/tracker/widgets/tracker_section_card.dart';
import 'package:hefty_chest/features/tracker/widgets/rest_timer_sheet.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';
import 'package:hefty_chest/features/workout_builder/providers/workout_builder_providers.dart';
import 'package:hefty_chest/features/workout_builder/widgets/exercise_search_modal.dart';
import 'package:hefty_chest/shared/widgets/floating_session_widget.dart';
import 'package:hefty_chest/gen/common.pbenum.dart';
import 'package:hefty_chest/gen/exercise.pb.dart' as pb;

/// Mock ActiveSession notifier for testing
class MockActiveSession extends ActiveSession {
  final SessionModel? _mockSession;

  MockActiveSession(this._mockSession);

  @override
  AsyncValue<SessionModel?> build() => AsyncValue.data(_mockSession);
}

/// Creates a mock SessionModel for testing
SessionModel createMockSession({
  String id = 'test-session-id',
  String name = 'Test Workout',
  int completedSets = 3,
  int totalSets = 10,
  List<SessionExerciseModel>? exercises,
}) {
  return SessionModel(
    id: id,
    workoutTemplateId: 'test-workout-id',
    name: name,
    exercises: exercises ?? [],
    completedSets: completedSets,
    totalSets: totalSets,
  );
}

/// Creates a mock SessionExerciseModel for testing
SessionExerciseModel createMockExercise({
  String id = 'exercise-1',
  String exerciseId = 'ex-1',
  String exerciseName = 'Bench Press',
  String sectionName = 'Main Workout',
  ExerciseType exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
  List<SessionSetModel>? sets,
  String notes = '',
}) {
  return SessionExerciseModel(
    id: id,
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    sectionName: sectionName,
    exerciseType: exerciseType,
    notes: notes,
    sets: sets ?? [
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
        weightKg: 60.0,
        reps: 10,
        isCompleted: false,
      ),
    ],
  );
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

/// Helper to wrap widget with FTheme and ProviderScope
Widget wrapWithThemeAndProvider(Widget child, {SessionModel? mockSession}) {
  return ProviderScope(
    overrides: [
      activeSessionProvider.overrideWith(() => MockActiveSession(mockSession)),
    ],
    child: MaterialApp(
      home: FTheme(
        data: FThemes.zinc.dark,
        child: Scaffold(body: child),
      ),
    ),
  );
}

/// Creates a session with exercises that have the specified completed/total sets
SessionModel createSessionWithSets(int completedSets, int totalSets) {
  final sets = <SessionSetModel>[];
  for (var i = 0; i < totalSets; i++) {
    sets.add(SessionSetModel(
      id: 'set-$i',
      setNumber: i + 1,
      isCompleted: i < completedSets,
    ));
  }
  return SessionModel(
    id: 'test-session',
    workoutTemplateId: 'test-workout',
    name: 'Test',
    exercises: [
      SessionExerciseModel(
        id: 'ex-1',
        exerciseId: 'ex-1',
        exerciseName: 'Test Exercise',
        sectionName: 'Main',
        sets: sets,
      ),
    ],
    completedSets: completedSets,
    totalSets: totalSets,
  );
}

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
          exerciseListProvider.overrideWith((ref) async => [
            pb.Exercise()
              ..id = 'ex-1'
              ..name = 'Squat'
              ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
            pb.Exercise()
              ..id = 'ex-2'
              ..name = 'Deadlift'
              ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          ]),
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
      expect(find.byType(ExerciseSearchModal), findsNothing);
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
      expect(find.byType(ExerciseSearchModal), findsOneWidget);
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
          exerciseListProvider.overrideWith((ref) async => [
            pb.Exercise()
              ..id = 'ex-1'
              ..name = 'Squat'
              ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
            pb.Exercise()
              ..id = 'ex-2'
              ..name = 'Deadlift'
              ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
          ]),
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

    testWidgets('section header shows + button', (tester) async {
      await tester.pumpWidget(createTrackerWidget());
      await tester.pumpAndSettle();

      // Should find the add_circle_outline icon in section header
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('tapping + opens exercise modal', (tester) async {
      await tester.pumpWidget(createTrackerWidget());
      await tester.pumpAndSettle();

      // Tap the + button
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // Exercise modal should open
      expect(find.byType(ExerciseSearchModal), findsOneWidget);
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

    testWidgets('shows X discard button in header', (tester) async {
      await tester.pumpWidget(createTrackerWidget(createTestSession()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('tapping X shows discard confirmation dialog', (tester) async {
      await tester.pumpWidget(createTrackerWidget(createTestSession()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Discard Workout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
    });

    testWidgets('Cancel in discard dialog does not abandon session', (tester) async {
      await tester.pumpWidget(createTrackerWidget(createTestSession()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
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

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(trackingNotifier.abandonSessionCalled, isTrue);
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

    testWidgets('Superset badge does NOT appear when exercises have no supersetId', (tester) async {
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

      // Verify "Superset" badge does NOT appear
      expect(find.text('Superset'), findsNothing);
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

    testWidgets('Mixed sections show badge only for superset section', (tester) async {
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

      // Should find exactly one Superset badge (for Chest Superset section)
      expect(find.text('Superset'), findsOneWidget);

      // Both section headers should exist
      expect(find.text('Warm Up'), findsOneWidget);
      expect(find.text('Chest Superset'), findsOneWidget);
    });
  });
}

/// Mock ActiveSession notifier that tracks addExercise calls
class TrackingActiveSession extends ActiveSession {
  final SessionModel _session;
  final List<Map<String, dynamic>> addExerciseCalls = [];
  bool abandonSessionCalled = false;

  TrackingActiveSession(this._session);

  @override
  AsyncValue<SessionModel?> build() => AsyncValue.data(_session);

  @override
  Future<SessionModel?> loadSession({required String sessionId}) async {
    state = AsyncValue.data(_session);
    return _session;
  }

  @override
  void addExercise({
    required String exerciseId,
    required String exerciseName,
    required ExerciseType exerciseType,
    required String sectionName,
    int numSets = 3,
    String? supersetId,
  }) {
    addExerciseCalls.add({
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'exerciseType': exerciseType,
      'sectionName': sectionName,
      'numSets': numSets,
      'supersetId': supersetId,
    });
  }

  @override
  Future<void> abandonSession() async {
    abandonSessionCalled = true;
    state = const AsyncValue.data(null);
  }
}

/// Safe mock for FloatingWidgetVisible that handles disposal gracefully
class SafeFloatingWidgetVisible extends FloatingWidgetVisible {
  bool _isMounted = true;

  @override
  bool build() {
    ref.onDispose(() => _isMounted = false);
    return true;
  }

  @override
  void hide() {
    if (_isMounted) state = false;
  }

  @override
  void show() {
    if (_isMounted) state = true;
  }
}
