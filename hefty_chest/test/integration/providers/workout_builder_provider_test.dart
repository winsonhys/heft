import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/workout_builder/providers/workout_builder_providers.dart';

import '../../test_utils/test_data.dart';
import '../../test_utils/test_setup.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  setUp(() {
    IntegrationTestSetup.restoreTokenProvider();
    container = IntegrationTestSetup.createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('WorkoutBuilder State Management', () {
    test('initial state is empty', () {
      final state = container.read(workoutBuilderProvider);

      expect(state.id, isNull);
      expect(state.name, isEmpty);
      expect(state.sections, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('updateName updates state', () {
      final notifier = container.read(workoutBuilderProvider.notifier);

      notifier.updateName('My Workout');

      final state = container.read(workoutBuilderProvider);
      expect(state.name, equals('My Workout'));
    });

    test('addSection adds new section', () {
      final notifier = container.read(workoutBuilderProvider.notifier);

      notifier.addSection();

      final state = container.read(workoutBuilderProvider);
      expect(state.sections, hasLength(1));
      expect(state.sections.first.name, equals('Section 1'));
      expect(state.sections.first.items, isEmpty);
      expect(state.sections.first.isSuperset, isFalse);
    });

    test('addSection increments section numbers', () {
      final notifier = container.read(workoutBuilderProvider.notifier);

      notifier.addSection();
      notifier.addSection();
      notifier.addSection();

      final state = container.read(workoutBuilderProvider);
      expect(state.sections, hasLength(3));
      expect(state.sections[0].name, equals('Section 1'));
      expect(state.sections[1].name, equals('Section 2'));
      expect(state.sections[2].name, equals('Section 3'));
    });

    test('deleteSection removes section', () {
      final notifier = container.read(workoutBuilderProvider.notifier);

      notifier.addSection();
      notifier.addSection();

      final sectionId = container.read(workoutBuilderProvider).sections.first.id;
      notifier.deleteSection(sectionId);

      final state = container.read(workoutBuilderProvider);
      expect(state.sections, hasLength(1));
      expect(state.sections.first.id, isNot(equals(sectionId)));
    });

    test('toggleSuperset toggles flag', () {
      final notifier = container.read(workoutBuilderProvider.notifier);

      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;

      // Initially false
      expect(
        container.read(workoutBuilderProvider).sections.first.isSuperset,
        isFalse,
      );

      // Toggle on
      notifier.toggleSuperset(sectionId);
      expect(
        container.read(workoutBuilderProvider).sections.first.isSuperset,
        isTrue,
      );

      // Toggle off
      notifier.toggleSuperset(sectionId);
      expect(
        container.read(workoutBuilderProvider).sections.first.isSuperset,
        isFalse,
      );
    });

    test('updateSectionName changes name', () {
      final notifier = container.read(workoutBuilderProvider.notifier);

      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;

      notifier.updateSectionName(sectionId, 'Warm Up');

      final state = container.read(workoutBuilderProvider);
      expect(state.sections.first.name, equals('Warm Up'));
    });

    test('addExercise adds exercise to section', () async {
      // Get an exercise from the API first (before accessing the notifier)
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Now access and use the notifier synchronously
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;

      notifier.addExercise(sectionId, exercise);

      final state = container.read(workoutBuilderProvider);
      expect(state.sections.first.items, hasLength(1));

      final item = state.sections.first.items.first;
      expect(item.isRest, isFalse);
      expect(item.exerciseId, equals(exercise.id));
      expect(item.exerciseName, equals(exercise.name));
      expect(item.sets, hasLength(1)); // Default with 1 set
    });

    test('deleteExercise removes exercise', () async {
      // Get an exercise from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Now access and use the notifier synchronously
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;

      notifier.addExercise(sectionId, exercise);
      final itemId = container.read(workoutBuilderProvider).sections.first.items.first.id;

      notifier.deleteExercise(sectionId, itemId);

      final state = container.read(workoutBuilderProvider);
      expect(state.sections.first.items, isEmpty);
    });

    test('addRest adds rest item', () {
      final notifier = container.read(workoutBuilderProvider.notifier);

      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;

      notifier.addRest(sectionId);

      final state = container.read(workoutBuilderProvider);
      expect(state.sections.first.items, hasLength(1));

      final item = state.sections.first.items.first;
      expect(item.isRest, isTrue);
      expect(item.restDurationSeconds, equals(60)); // Default 60 seconds
    });

    test('updateRestDuration changes duration', () {
      final notifier = container.read(workoutBuilderProvider.notifier);

      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;
      notifier.addRest(sectionId);
      final itemId = container.read(workoutBuilderProvider).sections.first.items.first.id;

      notifier.updateRestDuration(sectionId, itemId, 90);

      final state = container.read(workoutBuilderProvider);
      expect(state.sections.first.items.first.restDurationSeconds, equals(90));
    });

    test('reorderItems moves items', () async {
      // Get exercises from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise1 = exercisesResponse.exercises[0];
      final exercise2 = exercisesResponse.exercises[1];

      // Now access and use the notifier synchronously
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;

      // Add two exercises
      notifier.addExercise(sectionId, exercise1);
      notifier.addExercise(sectionId, exercise2);

      final item1Id = container.read(workoutBuilderProvider).sections.first.items[0].id;

      // Reorder: move item at index 0 to index 2 (after item at index 1)
      notifier.reorderItems(sectionId, 0, 2);

      final state = container.read(workoutBuilderProvider);
      // Item 1 should now be at index 1 (moved to end)
      expect(state.sections.first.items[1].id, equals(item1Id));
    });

    test('addSet adds set to exercise', () async {
      // Get exercise from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Now access and use the notifier synchronously
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;
      notifier.addExercise(sectionId, exercise);
      final itemId = container.read(workoutBuilderProvider).sections.first.items.first.id;

      // Initially 1 set
      expect(
        container.read(workoutBuilderProvider).sections.first.items.first.sets,
        hasLength(1),
      );

      notifier.addSet(sectionId, itemId);

      // Now 2 sets
      final state = container.read(workoutBuilderProvider);
      expect(state.sections.first.items.first.sets, hasLength(2));
      expect(state.sections.first.items.first.sets[1].setNumber, equals(2));
    });

    test('deleteSet removes and renumbers', () async {
      // Get exercise from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Now access and use the notifier synchronously
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;
      notifier.addExercise(sectionId, exercise);
      final itemId = container.read(workoutBuilderProvider).sections.first.items.first.id;

      // Add 2 more sets (total 3)
      notifier.addSet(sectionId, itemId);
      notifier.addSet(sectionId, itemId);

      final sets = container.read(workoutBuilderProvider).sections.first.items.first.sets;
      expect(sets, hasLength(3));

      // Delete the first set
      final firstSetId = sets.first.id;
      notifier.deleteSet(sectionId, itemId, firstSetId);

      final state = container.read(workoutBuilderProvider);
      final updatedSets = state.sections.first.items.first.sets;
      expect(updatedSets, hasLength(2));
      // Check renumbering
      expect(updatedSets[0].setNumber, equals(1));
      expect(updatedSets[1].setNumber, equals(2));
    });

    test('updateSetValues modifies set', () async {
      // Get exercise from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Now access and use the notifier synchronously
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();
      final sectionId = container.read(workoutBuilderProvider).sections.first.id;
      notifier.addExercise(sectionId, exercise);
      final itemId = container.read(workoutBuilderProvider).sections.first.items.first.id;
      final setId = container.read(workoutBuilderProvider).sections.first.items.first.sets.first.id;

      notifier.updateSetValues(
        sectionId,
        itemId,
        setId,
        weight: 100.0,
        reps: 8,
      );

      final state = container.read(workoutBuilderProvider);
      final set = state.sections.first.items.first.sets.first;
      expect(set.targetWeightKg, equals(100.0));
      expect(set.targetReps, equals(8));
    });

    test('reset clears state', () {
      final notifier = container.read(workoutBuilderProvider.notifier);

      notifier.updateName('Test Workout');
      notifier.addSection();

      // Verify state is not empty
      expect(container.read(workoutBuilderProvider).name, isNotEmpty);
      expect(container.read(workoutBuilderProvider).sections, isNotEmpty);

      notifier.reset();

      final state = container.read(workoutBuilderProvider);
      expect(state.name, isEmpty);
      expect(state.sections, isEmpty);
      expect(state.id, isNull);
    });
  });

  group('WorkoutBuilder API Integration', () {
    test('loadWorkout populates state from API', () async {
      // Create a workout via API first
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Load Test Workout',
      );

      // Keep provider alive during async operations by listening
      final subscription = container.listen(workoutBuilderProvider, (_, _) {});

      try {
        final notifier = container.read(workoutBuilderProvider.notifier);
        await notifier.loadWorkout(workoutId);

        final state = container.read(workoutBuilderProvider);
        expect(state.id, equals(workoutId));
        expect(state.name, equals('Load Test Workout'));
        expect(state.sections, hasLength(1));
        expect(state.sections.first.items, hasLength(1));
        expect(state.isLoading, isFalse);
      } finally {
        subscription.close();
        // Clean up
        await TestData.deleteWorkout(workoutId);
      }
    });

    test('saveWorkout creates new workout', () async {
      // Get an exercise first (before accessing notifier)
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;
      final uniqueName = 'Save Test ${DateTime.now().millisecondsSinceEpoch}';

      // Keep provider alive during async operations
      final subscription = container.listen(workoutBuilderProvider, (_, _) {});

      String? createdWorkoutId;
      try {
        final notifier = container.read(workoutBuilderProvider.notifier);

        // Build workout synchronously
        notifier.updateName(uniqueName);
        notifier.addSection();

        final sectionId = container.read(workoutBuilderProvider).sections.first.id;
        notifier.addExercise(sectionId, exercise);

        // Save (async)
        final success = await notifier.saveWorkout();

        expect(success, isTrue);
        expect(container.read(workoutBuilderProvider).isLoading, isFalse);

        // Verify workout was created by listing
        final listResponse = await workoutClient.listWorkouts(
          ListWorkoutsRequest(),
        );

        final created = listResponse.workouts.where((w) => w.name == uniqueName);
        expect(created, isNotEmpty);
        createdWorkoutId = created.first.id;
      } finally {
        subscription.close();
        // Clean up
        if (createdWorkoutId != null) {
          await TestData.deleteWorkout(createdWorkoutId);
        }
      }
    });

    test('saveWorkout validates name required', () async {
      // Keep provider alive
      final subscription = container.listen(workoutBuilderProvider, (_, _) {});

      try {
        final notifier = container.read(workoutBuilderProvider.notifier);

        // Don't set name
        notifier.addSection();

        final success = await notifier.saveWorkout();

        expect(success, isFalse);
        expect(container.read(workoutBuilderProvider).error, isNotNull);
      } finally {
        subscription.close();
      }
    });

    test('saveWorkout updates existing workout', () async {
      // Create workout via API first
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Update Test Workout',
      );

      // Keep provider alive
      final subscription = container.listen(workoutBuilderProvider, (_, _) {});

      try {
        final notifier = container.read(workoutBuilderProvider.notifier);

        // Load it (async)
        await notifier.loadWorkout(workoutId);

        // Modify name
        notifier.updateName('Updated Workout Name');

        // Save (async)
        final success = await notifier.saveWorkout();

        expect(success, isTrue);
        expect(container.read(workoutBuilderProvider).id, equals(workoutId));
      } finally {
        subscription.close();
        // Clean up
        await TestData.deleteWorkout(workoutId);
      }
    });
  });

  group('Cross-section item movement', () {
    test('moveItem moves item to different section', () async {
      // Get an exercise from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Access notifier synchronously after async operation
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection(); // Section 1
      notifier.addSection(); // Section 2

      final state1 = container.read(workoutBuilderProvider);
      final section1Id = state1.sections[0].id;
      final section2Id = state1.sections[1].id;

      // Add exercise to section 1
      notifier.addExercise(section1Id, exercise);
      final itemId =
          container.read(workoutBuilderProvider).sections[0].items[0].id;

      // Move to section 2 at index 0
      notifier.moveItem(
        itemId: itemId,
        fromSectionId: section1Id,
        toSectionId: section2Id,
        targetIndex: 0,
      );

      final finalState = container.read(workoutBuilderProvider);
      expect(finalState.sections[0].items, isEmpty);
      expect(finalState.sections[1].items, hasLength(1));
      expect(finalState.sections[1].items[0].id, equals(itemId));
    });

    test('moveItem handles within-section reorder', () async {
      // Get exercises from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise1 = exercisesResponse.exercises[0];
      final exercise2 = exercisesResponse.exercises[1];

      // Access notifier synchronously after async operation
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();

      final sectionId = container.read(workoutBuilderProvider).sections[0].id;
      notifier.addExercise(sectionId, exercise1);
      notifier.addExercise(sectionId, exercise2);

      final item1Id =
          container.read(workoutBuilderProvider).sections[0].items[0].id;

      // Move first item to position 2 (after second item)
      notifier.moveItem(
        itemId: item1Id,
        fromSectionId: sectionId,
        toSectionId: sectionId,
        targetIndex: 2, // After the second item
      );

      final finalState = container.read(workoutBuilderProvider);
      expect(finalState.sections[0].items[1].id, equals(item1Id));
    });

    test('moveItem to empty section works', () async {
      // Get an exercise from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Access notifier synchronously after async operation
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();
      notifier.addSection();

      final state = container.read(workoutBuilderProvider);
      final section1Id = state.sections[0].id;
      final section2Id = state.sections[1].id;

      notifier.addExercise(section1Id, exercise);
      final itemId =
          container.read(workoutBuilderProvider).sections[0].items[0].id;

      // Move to empty section 2
      notifier.moveItem(
        itemId: itemId,
        fromSectionId: section1Id,
        toSectionId: section2Id,
        targetIndex: 0,
      );

      final finalState = container.read(workoutBuilderProvider);
      expect(finalState.sections[0].items, isEmpty);
      expect(finalState.sections[1].items, hasLength(1));
    });

    test('moveItem clamps target index to valid range', () async {
      // Get an exercise from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Access notifier synchronously after async operation
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();
      notifier.addSection();

      final state = container.read(workoutBuilderProvider);
      final section1Id = state.sections[0].id;
      final section2Id = state.sections[1].id;

      notifier.addExercise(section1Id, exercise);
      final itemId =
          container.read(workoutBuilderProvider).sections[0].items[0].id;

      // Move with out-of-range index (should clamp to 0 for empty section)
      notifier.moveItem(
        itemId: itemId,
        fromSectionId: section1Id,
        toSectionId: section2Id,
        targetIndex: 999, // Way out of range
      );

      final finalState = container.read(workoutBuilderProvider);
      expect(finalState.sections[1].items, hasLength(1));
    });

    test('moveItem preserves item data when moving between sections', () async {
      // Get an exercise from the API first
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Access notifier synchronously after async operation
      final notifier = container.read(workoutBuilderProvider.notifier);
      notifier.addSection();
      notifier.addSection();

      final state = container.read(workoutBuilderProvider);
      final section1Id = state.sections[0].id;
      final section2Id = state.sections[1].id;

      // Add exercise and customize it
      notifier.addExercise(section1Id, exercise);
      final itemId =
          container.read(workoutBuilderProvider).sections[0].items[0].id;
      final setId = container
          .read(workoutBuilderProvider)
          .sections[0]
          .items[0]
          .sets[0]
          .id;

      // Modify the set values
      notifier.updateSetValues(section1Id, itemId, setId,
          weight: 100.0, reps: 12);

      // Move to section 2
      notifier.moveItem(
        itemId: itemId,
        fromSectionId: section1Id,
        toSectionId: section2Id,
        targetIndex: 0,
      );

      // Verify item data is preserved
      final finalState = container.read(workoutBuilderProvider);
      final movedItem = finalState.sections[1].items[0];
      expect(movedItem.exerciseId, equals(exercise.id));
      expect(movedItem.exerciseName, equals(exercise.name));
      expect(movedItem.sets[0].targetWeightKg, equals(100.0));
      expect(movedItem.sets[0].targetReps, equals(12));
    });
  });
}
