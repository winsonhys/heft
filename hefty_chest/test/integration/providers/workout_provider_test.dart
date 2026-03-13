import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/home/providers/home_providers.dart';

void main() {
  group('Workout Provider - Mock Tests', () {
    test('lists workouts via provider', () async {
      final mockWorkouts = [
        WorkoutSummary()
          ..id = 'w-1'
          ..name = 'Provider Test Workout',
      ];

      final container = ProviderContainer(overrides: [
        workoutListProvider.overrideWith((ref) async => mockWorkouts),
      ]);

      final workouts = await container.read(workoutListProvider.future);

      expect(workouts, isNotEmpty);
      expect(workouts.any((w) => w.id == 'w-1'), isTrue);

      container.dispose();
    });

    test('gets workout detail via provider', () async {
      final mockWorkout = Workout()
        ..id = 'w-1'
        ..name = 'Integration Test Workout';

      final container = ProviderContainer(overrides: [
        workoutDetailProvider.overrideWith(
          (ref, workoutId) async => mockWorkout,
        ),
      ]);

      final workout = await container.read(
        workoutDetailProvider('w-1').future,
      );

      expect(workout.id, equals('w-1'));
      expect(workout.name, equals('Integration Test Workout'));

      container.dispose();
    });
  });
}
