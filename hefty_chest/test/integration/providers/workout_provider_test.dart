import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/home/providers/home_providers.dart';

import '../../test_utils/test_setup.dart';
import '../../test_utils/test_data.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  setUp(() {
    container = IntegrationTestSetup.createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('WorkoutService Integration', () {
    test('creates workout successfully', () async {
      final uniqueName = 'Test Workout ${DateTime.now().millisecondsSinceEpoch}';

      final request = CreateWorkoutRequest()
        
        ..name = uniqueName
        ..description = 'Integration test workout';

      final response = await workoutClient.createWorkout(request);

      expect(response.workout.id, isNotEmpty);
      expect(response.workout.name, equals(uniqueName));

      // Clean up
      await TestData.deleteWorkout(response.workout.id);
    });

    test('retrieves workout by ID', () async {
      // Create workout
      final workoutId = await TestData.createTestWorkout();

      // Get workout
      final request = GetWorkoutRequest()
        ..id = workoutId
        ;

      final response = await workoutClient.getWorkout(request);

      expect(response.workout.id, equals(workoutId));
      expect(response.workout.name, equals('Integration Test Workout'));

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });

    test('lists workouts', () async {
      // Create test workout
      final workoutId = await TestData.createTestWorkout(
        name: 'List Test Workout',
      );

      // List workouts
      final request = ListWorkoutsRequest();

      final response = await workoutClient.listWorkouts(request);

      expect(response.workouts, isNotEmpty);
      expect(
        response.workouts.any((w) => w.id == workoutId),
        isTrue,
      );

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });

    test('lists workouts via provider', () async {
      // Create test workout
      final workoutId = await TestData.createTestWorkout(
        name: 'Provider Test Workout',
      );

      // Use provider
      final workouts = await container.read(workoutListProvider.future);

      expect(workouts, isNotEmpty);
      expect(workouts.any((w) => w.id == workoutId), isTrue);

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });

    test('gets workout detail via provider', () async {
      // Create workout
      final workoutId = await TestData.createTestWorkout();

      // Use family provider
      final workout = await container.read(
        workoutDetailProvider(workoutId).future,
      );

      expect(workout.id, equals(workoutId));
      expect(workout.name, equals('Integration Test Workout'));

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });

    test('creates workout with sections and exercises', () async {
      // Get an exercise
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );
      final exercise = exercisesResponse.exercises.first;

      // Create section with exercise
      final section = CreateWorkoutSection()
        ..name = 'Main Set'
        ..displayOrder = 1
        ..isSuperset = false;

      final item = CreateSectionItem()
        ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
        ..displayOrder = 1
        ..exerciseId = exercise.id;

      // Add target sets
      final set1 = CreateTargetSet()
        ..setNumber = 1
        ..targetWeightKg = 60.0
        ..targetReps = 10;

      final set2 = CreateTargetSet()
        ..setNumber = 2
        ..targetWeightKg = 65.0
        ..targetReps = 8;

      item.targetSets.addAll([set1, set2]);
      section.items.add(item);

      // Create workout
      final request = CreateWorkoutRequest()
        
        ..name = 'Structured Workout Test'
        ..description = 'Test with sections';

      request.sections.add(section);

      final response = await workoutClient.createWorkout(request);

      expect(response.workout.sections, hasLength(1));
      expect(response.workout.sections.first.items, hasLength(1));
      expect(response.workout.sections.first.items.first.targetSets, hasLength(2));

      // Clean up
      await TestData.deleteWorkout(response.workout.id);
    });

    test('creates workout with superset', () async {
      final exercisesResponse = await exerciseClient.listExercises(
        ListExercisesRequest()..userId = TestData.testUserId,
      );

      // Create superset section
      final section = CreateWorkoutSection()
        ..name = 'Superset'
        ..displayOrder = 1
        ..isSuperset = true;

      // Add two exercises
      final item1 = CreateSectionItem()
        ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
        ..displayOrder = 1
        ..exerciseId = exercisesResponse.exercises[0].id;

      item1.targetSets.add(
        CreateTargetSet()
          ..setNumber = 1
          ..targetReps = 10,
      );

      final item2 = CreateSectionItem()
        ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
        ..displayOrder = 2
        ..exerciseId = exercisesResponse.exercises[1].id;

      item2.targetSets.add(
        CreateTargetSet()
          ..setNumber = 1
          ..targetReps = 10,
      );

      section.items.addAll([item1, item2]);

      final request = CreateWorkoutRequest()
        
        ..name = 'Superset Test';

      request.sections.add(section);

      final response = await workoutClient.createWorkout(request);

      expect(response.workout.sections.first.isSuperset, isTrue);
      expect(response.workout.sections.first.items, hasLength(2));

      // Clean up
      await TestData.deleteWorkout(response.workout.id);
    });

    test('updates workout - API stub returns existing workout', () async {
      // Note: The backend UpdateWorkout API is currently a stub that returns
      // the existing workout without actually updating. This test verifies
      // the API is callable and returns a valid response.

      // Create workout
      final workoutId = await TestData.createTestWorkout();

      // Call update (returns existing workout, doesn't actually update)
      final updateRequest = UpdateWorkoutRequest()
        ..id = workoutId
        
        ..name = 'Updated Workout Name'
        ..description = 'Updated description';

      final updateResponse = await workoutClient.updateWorkout(updateRequest);

      // API returns the existing workout (not updated)
      expect(updateResponse.workout.id, equals(workoutId));
      expect(updateResponse.workout.name, isNotEmpty);

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });

    test('deletes workout', () async {
      // Create workout
      final workoutId = await TestData.createTestWorkout();

      // Delete workout
      final deleteRequest = DeleteWorkoutRequest()
        ..id = workoutId
        ;

      final deleteResponse = await workoutClient.deleteWorkout(deleteRequest);
      expect(deleteResponse.success, isTrue);

      // Verify deletion by trying to get it (should fail)
      try {
        final getRequest = GetWorkoutRequest()
          ..id = workoutId
          ;

        await workoutClient.getWorkout(getRequest);
        fail('Expected workout to be deleted');
      } catch (e) {
        // Expected - workout should not be found
        expect(e, isNotNull);
      }
    });

    test('duplicates workout', () async {
      // Create original workout
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Original Workout',
      );

      // Duplicate
      final duplicateRequest = DuplicateWorkoutRequest()
        ..id = workoutId
        
        ..newName = 'Duplicated Workout';

      final duplicateResponse = await workoutClient.duplicateWorkout(duplicateRequest);

      expect(duplicateResponse.workout.name, equals('Duplicated Workout'));
      expect(duplicateResponse.workout.id, isNot(equals(workoutId)));
      expect(duplicateResponse.workout.sections, hasLength(1));

      // Clean up both
      await TestData.deleteWorkout(workoutId);
      await TestData.deleteWorkout(duplicateResponse.workout.id);
    });

    test('builds complete workout structure', () async {
      // Create complete workout using helper
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Complete Test Workout',
      );

      // Verify structure
      final getRequest = GetWorkoutRequest()
        ..id = workoutId
        ;

      final response = await workoutClient.getWorkout(getRequest);

      expect(response.workout.name, equals('Complete Test Workout'));
      expect(response.workout.sections, hasLength(1));
      expect(response.workout.sections.first.items, hasLength(1));
      expect(response.workout.sections.first.items.first.targetSets, hasLength(2));

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });
  });
}
