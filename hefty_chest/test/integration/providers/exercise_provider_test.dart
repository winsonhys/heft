import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/progress/providers/progress_providers.dart';

void main() {
  group('Exercise Provider - Mock Tests', () {
    test('lists exercises via provider', () async {
      final mockExercises = [
        Exercise()
          ..id = 'ex-1'
          ..name = 'Bench Press'
          ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
        Exercise()
          ..id = 'ex-2'
          ..name = 'Deadlift'
          ..exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
      ];

      final container = ProviderContainer(overrides: [
        exercisesListProvider.overrideWith((ref) async => mockExercises),
      ]);

      final exercises = await container.read(exercisesListProvider.future);

      expect(exercises, isNotEmpty);
      expect(exercises.any((e) => e.name == 'Bench Press'), isTrue);

      container.dispose();
    });
  });
}
