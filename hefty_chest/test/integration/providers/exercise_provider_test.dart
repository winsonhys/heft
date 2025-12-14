import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/progress/providers/progress_providers.dart';

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

  group('ExerciseService Integration', () {
    test('lists exercise categories', () async {
      final response = await exerciseClient.listCategories(
        ListCategoriesRequest(),
      );

      expect(response.categories, isNotEmpty);
      expect(response.categories.length, greaterThanOrEqualTo(8));

      // Check for expected categories from seed data
      final categoryNames = response.categories.map((c) => c.name).toList();
      expect(categoryNames, contains('Chest'));
      expect(categoryNames, contains('Back'));
      expect(categoryNames, contains('Legs'));
      expect(categoryNames, contains('Core'));
    });

    test('lists exercises', () async {
      final request = ListExercisesRequest()..userId = TestData.testUserId;

      final response = await exerciseClient.listExercises(request);

      expect(response.exercises, isNotEmpty);

      // System exercises should exist from seed data
      final exerciseNames = response.exercises.map((e) => e.name).toList();
      expect(exerciseNames, contains('Bench Press'));
      expect(exerciseNames, contains('Deadlift'));
      expect(exerciseNames, contains('Barbell Squats'));
    });

    test('lists exercises via provider', () async {
      final exercises = await container.read(exercisesListProvider.future);

      expect(exercises, isNotEmpty);
      expect(exercises.any((e) => e.name == 'Bench Press'), isTrue);
    });

    test('filters exercises by category', () async {
      // First get the Chest category ID
      final categoriesResponse = await exerciseClient.listCategories(
        ListCategoriesRequest(),
      );
      final chestCategory = categoriesResponse.categories.firstWhere(
        (c) => c.name == 'Chest',
      );

      // List exercises filtered by category
      final request = ListExercisesRequest()
        ..userId = TestData.testUserId
        ..categoryId = chestCategory.id;

      final response = await exerciseClient.listExercises(request);

      expect(response.exercises, isNotEmpty);

      // All returned exercises should be chest exercises
      for (final exercise in response.exercises) {
        expect(exercise.categoryId, equals(chestCategory.id));
      }

      // Should include Bench Press
      expect(
        response.exercises.any((e) => e.name == 'Bench Press'),
        isTrue,
      );
    });

    test('searches exercises by name', () async {
      final request = SearchExercisesRequest()
        ..query = 'bench'
        ..limit = 10;

      final response = await exerciseClient.searchExercises(request);

      expect(response.exercises, isNotEmpty);
      expect(
        response.exercises.first.name.toLowerCase(),
        contains('bench'),
      );
    });

    test('gets single exercise by ID', () async {
      // First list exercises to get an ID
      final listRequest = ListExercisesRequest()..userId = TestData.testUserId;
      final listResponse = await exerciseClient.listExercises(listRequest);
      final exerciseId = listResponse.exercises.first.id;

      // Get single exercise
      final getRequest = GetExerciseRequest()..id = exerciseId;
      final getResponse = await exerciseClient.getExercise(getRequest);

      expect(getResponse.exercise, isNotNull);
      expect(getResponse.exercise.id, equals(exerciseId));
    });

    test('creates custom exercise', () async {
      // Get Chest category ID
      final categoriesResponse = await exerciseClient.listCategories(
        ListCategoriesRequest(),
      );
      final chestCategory = categoriesResponse.categories.firstWhere(
        (c) => c.name == 'Chest',
      );

      final uniqueName =
          'Custom Test Exercise ${DateTime.now().millisecondsSinceEpoch}';

      final request = CreateExerciseRequest()
        ..userId = TestData.testUserId
        ..name = uniqueName
        ..categoryId = chestCategory.id
        ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS
        ..description = 'Created by integration test';

      final response = await exerciseClient.createExercise(request);

      expect(response.exercise.name, equals(uniqueName));
      expect(response.exercise.isSystem, isFalse);
      expect(response.exercise.categoryId, equals(chestCategory.id));
      expect(
        response.exercise.exerciseType,
        equals(ExerciseType.EXERCISE_TYPE_WEIGHT_REPS),
      );

      // Note: Custom exercises may not have a delete endpoint,
      // so they will persist in the test database
    });

    test('lists exercises with different exercise types', () async {
      final request = ListExercisesRequest()..userId = TestData.testUserId;

      final response = await exerciseClient.listExercises(request);

      // Should have various exercise types from seed data
      final types = response.exercises.map((e) => e.exerciseType).toSet();

      expect(types, contains(ExerciseType.EXERCISE_TYPE_WEIGHT_REPS));
      expect(types, contains(ExerciseType.EXERCISE_TYPE_BODYWEIGHT_REPS));
      expect(types, contains(ExerciseType.EXERCISE_TYPE_TIME));
    });
  });
}
