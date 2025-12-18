import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hefty_chest/features/workout_builder/workout_builder_screen.dart';
import 'package:hefty_chest/features/workout_builder/providers/workout_builder_providers.dart';
import 'package:hefty_chest/features/workout_builder/widgets/section_card.dart';

/// Test notifier that provides controlled state without making API calls
class TestWorkoutBuilder extends WorkoutBuilder {
  final WorkoutBuilderState initialState;

  TestWorkoutBuilder(this.initialState);

  @override
  WorkoutBuilderState build() => initialState;

  @override
  Future<void> loadWorkout(String workoutId) async {
    // No-op in tests - state is already set via initialState
  }

  @override
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  @override
  void addSection() {
    final newSection = BuilderSection(
      id: 'test-section-${state.sections.length + 1}',
      name: 'Section ${state.sections.length + 1}',
    );
    state = state.copyWith(sections: [...state.sections, newSection]);
  }

  @override
  Future<bool> saveWorkout() async {
    // No-op in tests
    return true;
  }
}

/// Creates a test widget wrapped with necessary providers
Widget createTestWidget({
  required Widget child,
  WorkoutBuilderState? builderState,
}) {
  final state = builderState ?? const WorkoutBuilderState();
  return ProviderScope(
    overrides: [
      workoutBuilderProvider.overrideWith(() => TestWorkoutBuilder(state)),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Creates a mock WorkoutBuilderState for testing
WorkoutBuilderState createMockState({
  String? id,
  String name = '',
  List<BuilderSection> sections = const [],
  bool isLoading = false,
  String? error,
}) {
  return WorkoutBuilderState(
    id: id,
    name: name,
    sections: sections,
    isLoading: isLoading,
    error: error,
  );
}

void main() {
  group('WorkoutBuilderScreen', () {
    testWidgets('renders Create mode when workoutId is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const WorkoutBuilderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify "Create Workout" title
      expect(find.text('Create Workout'), findsOneWidget);
      expect(find.text('Edit Workout'), findsNothing);

      // Verify name TextField is present with hint
      expect(find.byType(TextField), findsOneWidget);

      // Verify Add Section button is visible
      expect(find.text('Add Section'), findsOneWidget);

      // Verify Save button is present
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders Edit mode when workoutId is provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          builderState: createMockState(
            id: 'existing-workout-id',
            name: 'Leg Day',
          ),
          child: const WorkoutBuilderScreen(workoutId: 'existing-workout-id'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify "Edit Workout" title
      expect(find.text('Edit Workout'), findsOneWidget);
      expect(find.text('Create Workout'), findsNothing);

      // Verify Save button is present
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('displays sections when state has sections', (tester) async {
      final testSections = [
        const BuilderSection(
          id: 'section-1',
          name: 'Warmup',
          items: [],
        ),
        const BuilderSection(
          id: 'section-2',
          name: 'Main Workout',
          items: [],
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          builderState: createMockState(sections: testSections),
          child: const WorkoutBuilderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify SectionCard widgets are rendered
      expect(find.byType(SectionCard), findsNWidgets(2));

      // Verify section names are displayed
      expect(find.text('Warmup'), findsOneWidget);
      expect(find.text('Main Workout'), findsOneWidget);
    });

    testWidgets('name TextField accepts input', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const WorkoutBuilderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the name TextField
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Enter text
      await tester.enterText(textFieldFinder, 'My New Workout');
      await tester.pump();

      // Verify text is in the field
      expect(find.text('My New Workout'), findsOneWidget);
    });

    testWidgets('Add Section button is tappable and adds section',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const WorkoutBuilderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially no sections
      expect(find.byType(SectionCard), findsNothing);

      // Find and tap the Add Section button
      final addSectionFinder = find.text('Add Section');
      expect(addSectionFinder, findsOneWidget);

      await tester.tap(addSectionFinder);
      await tester.pumpAndSettle();

      // Now there should be one section
      expect(find.byType(SectionCard), findsOneWidget);
    });

    testWidgets('displays single section with correct structure',
        (tester) async {
      final testSections = [
        const BuilderSection(
          id: 'section-1',
          name: 'Push Day',
          isSuperset: false,
          items: [],
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          builderState: createMockState(sections: testSections),
          child: const WorkoutBuilderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify section card is rendered
      expect(find.byType(SectionCard), findsOneWidget);

      // Verify section name
      expect(find.text('Push Day'), findsOneWidget);

      // Verify Superset toggle exists
      expect(find.text('Superset'), findsOneWidget);
    });

    testWidgets('back button (chevron) is visible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const WorkoutBuilderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify back chevron icon
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('shows correct number of sections', (tester) async {
      final testSections = [
        const BuilderSection(id: 's1', name: 'Section 1', items: []),
        const BuilderSection(id: 's2', name: 'Section 2', items: []),
        const BuilderSection(id: 's3', name: 'Section 3', items: []),
      ];

      await tester.pumpWidget(
        createTestWidget(
          builderState: createMockState(sections: testSections),
          child: const WorkoutBuilderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify exactly 3 SectionCard widgets
      expect(find.byType(SectionCard), findsNWidgets(3));
    });
  });
}
