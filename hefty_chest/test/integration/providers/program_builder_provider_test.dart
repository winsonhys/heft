import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/program_builder/providers/program_builder_providers.dart';

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

  group('ProgramBuilder State Management', () {
    test('initial state has defaults', () {
      final state = container.read(programBuilderProvider);

      expect(state.id, isNull);
      expect(state.name, isEmpty);
      expect(state.durationWeeks, equals(4)); // Default 4 weeks
      expect(state.durationDays, equals(0));
      expect(state.dayAssignments, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('computed totalDays is correct', () {
      final notifier = container.read(programBuilderProvider.notifier);

      // Default is 4 weeks = 28 days
      expect(container.read(programBuilderProvider).totalDays, equals(28));

      notifier.setDuration(2, 3); // 2 weeks + 3 days
      expect(container.read(programBuilderProvider).totalDays, equals(17));
    });

    test('updateName updates state', () {
      final notifier = container.read(programBuilderProvider.notifier);

      notifier.updateName('My Program');

      final state = container.read(programBuilderProvider);
      expect(state.name, equals('My Program'));
    });

    test('setDuration updates weeks and days', () {
      final notifier = container.read(programBuilderProvider.notifier);

      notifier.setDuration(8, 5);

      final state = container.read(programBuilderProvider);
      expect(state.durationWeeks, equals(8));
      expect(state.durationDays, equals(5));
    });

    test('setDuration clamps to valid range', () {
      final notifier = container.read(programBuilderProvider.notifier);

      // Min weeks = 1
      notifier.setDuration(0, 0);
      expect(container.read(programBuilderProvider).durationWeeks, equals(1));

      // Max weeks = 52
      notifier.setDuration(100, 0);
      expect(container.read(programBuilderProvider).durationWeeks, equals(52));

      // Days clamped to 0-6
      notifier.setDuration(4, 10);
      expect(container.read(programBuilderProvider).durationDays, equals(6));
    });

    test('setDuration removes out-of-range assignments', () {
      final notifier = container.read(programBuilderProvider.notifier);

      // Start with 4 weeks (28 days)
      notifier.assignRest(25);
      notifier.assignRest(28);

      expect(container.read(programBuilderProvider).dayAssignments, hasLength(2));

      // Reduce to 2 weeks (14 days) - day 25 and 28 should be removed
      notifier.setDuration(2, 0);

      final state = container.read(programBuilderProvider);
      expect(state.dayAssignments, isEmpty);
    });

    test('assignWorkout assigns to day', () async {
      // Create a workout first (before accessing notifier)
      final workoutId = await TestData.createTestWorkout(name: 'Program Workout');

      // Now access and use the notifier synchronously
      final notifier = container.read(programBuilderProvider.notifier);
      notifier.assignWorkout(1, workoutId, 'Program Workout');

      final state = container.read(programBuilderProvider);
      expect(state.dayAssignments.containsKey(1), isTrue);
      expect(state.dayAssignments[1]!.type, equals(DayAssignmentType.workout));
      expect(state.dayAssignments[1]!.workoutId, equals(workoutId));
      expect(state.dayAssignments[1]!.workoutName, equals('Program Workout'));

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });

    test('assignRest assigns rest day', () {
      final notifier = container.read(programBuilderProvider.notifier);

      notifier.assignRest(1);

      final state = container.read(programBuilderProvider);
      expect(state.dayAssignments.containsKey(1), isTrue);
      expect(state.dayAssignments[1]!.type, equals(DayAssignmentType.rest));
      expect(state.dayAssignments[1]!.workoutId, isNull);
    });

    test('clearDay removes assignment', () {
      final notifier = container.read(programBuilderProvider.notifier);

      notifier.assignRest(1);
      expect(container.read(programBuilderProvider).dayAssignments.containsKey(1), isTrue);

      notifier.clearDay(1);

      final state = container.read(programBuilderProvider);
      expect(state.dayAssignments.containsKey(1), isFalse);
    });

    test('fillWeekWithRest fills empty days only', () async {
      // Create workout first (before accessing notifier)
      final workoutId = await TestData.createTestWorkout(name: 'Week Fill Test');

      // Now access and use the notifier synchronously
      final notifier = container.read(programBuilderProvider.notifier);
      notifier.assignWorkout(3, workoutId, 'Week Fill Test');

      // Fill week 1 with rest (days 1-7)
      notifier.fillWeekWithRest(1);

      final state = container.read(programBuilderProvider);

      // Day 3 should still have workout
      expect(state.dayAssignments[3]!.type, equals(DayAssignmentType.workout));

      // Other days should have rest
      expect(state.dayAssignments[1]!.type, equals(DayAssignmentType.rest));
      expect(state.dayAssignments[2]!.type, equals(DayAssignmentType.rest));
      expect(state.dayAssignments[4]!.type, equals(DayAssignmentType.rest));
      expect(state.dayAssignments[5]!.type, equals(DayAssignmentType.rest));
      expect(state.dayAssignments[6]!.type, equals(DayAssignmentType.rest));
      expect(state.dayAssignments[7]!.type, equals(DayAssignmentType.rest));

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });

    test('clearWeek removes all assignments in week', () {
      final notifier = container.read(programBuilderProvider.notifier);

      // Fill week 1
      for (int day = 1; day <= 7; day++) {
        notifier.assignRest(day);
      }
      // Also add assignment in week 2
      notifier.assignRest(10);

      expect(container.read(programBuilderProvider).dayAssignments, hasLength(8));

      // Clear week 1 only
      notifier.clearWeek(1);

      final state = container.read(programBuilderProvider);
      expect(state.dayAssignments, hasLength(1)); // Only day 10 remains
      expect(state.dayAssignments.containsKey(10), isTrue);
    });

    test('workoutDays and restDays computed correctly', () async {
      // Create workout first (before accessing notifier)
      final workoutId = await TestData.createTestWorkout(name: 'Count Test');

      // Now access and use the notifier synchronously
      final notifier = container.read(programBuilderProvider.notifier);
      notifier.assignWorkout(1, workoutId, 'Count Test');
      notifier.assignWorkout(3, workoutId, 'Count Test');
      notifier.assignRest(2);
      notifier.assignRest(4);
      notifier.assignRest(5);

      final state = container.read(programBuilderProvider);
      expect(state.workoutDays, equals(2));
      expect(state.restDays, equals(3));

      await TestData.deleteWorkout(workoutId);
    });

    test('reset clears state', () async {
      // Create workout first (before accessing notifier)
      final workoutId = await TestData.createTestWorkout(name: 'Reset Test');

      // Now access and use the notifier synchronously
      final notifier = container.read(programBuilderProvider.notifier);
      notifier.updateName('Test Program');
      notifier.setDuration(6, 2);
      notifier.assignWorkout(1, workoutId, 'Reset Test');

      // Verify state is not empty
      expect(container.read(programBuilderProvider).name, isNotEmpty);

      notifier.reset();

      final state = container.read(programBuilderProvider);
      expect(state.name, isEmpty);
      expect(state.durationWeeks, equals(4)); // Back to default
      expect(state.dayAssignments, isEmpty);
      expect(state.id, isNull);

      await TestData.deleteWorkout(workoutId);
    });
  });

  group('CurrentWeek Notifier', () {
    test('initial week is 1', () {
      final week = container.read(currentWeekProvider);
      expect(week, equals(1));
    });

    test('setWeek changes week', () {
      final notifier = container.read(currentWeekProvider.notifier);

      notifier.setWeek(5);

      expect(container.read(currentWeekProvider), equals(5));
    });

    test('nextWeek increments', () {
      final notifier = container.read(currentWeekProvider.notifier);

      notifier.nextWeek();

      expect(container.read(currentWeekProvider), equals(2));

      notifier.nextWeek();

      expect(container.read(currentWeekProvider), equals(3));
    });

    test('previousWeek decrements with floor at 1', () {
      final notifier = container.read(currentWeekProvider.notifier);

      notifier.setWeek(3);
      notifier.previousWeek();

      expect(container.read(currentWeekProvider), equals(2));

      notifier.previousWeek();
      expect(container.read(currentWeekProvider), equals(1));

      // Should not go below 1
      notifier.previousWeek();
      expect(container.read(currentWeekProvider), equals(1));
    });

    test('reset returns to 1', () {
      final notifier = container.read(currentWeekProvider.notifier);

      notifier.setWeek(10);
      expect(container.read(currentWeekProvider), equals(10));

      notifier.reset();

      expect(container.read(currentWeekProvider), equals(1));
    });
  });

  group('ProgramBuilder API Integration', () {
    test('loadProgram populates state from API', () async {
      // Create a program via API first
      final programId = await TestData.createTestProgram(
        name: 'Load Test Program',
        durationWeeks: 6,
      );

      // Keep provider alive during async operations
      final subscription = container.listen(programBuilderProvider, (_, _) {});

      try {
        final notifier = container.read(programBuilderProvider.notifier);
        await notifier.loadProgram(programId);

        final state = container.read(programBuilderProvider);
        expect(state.id, equals(programId));
        expect(state.name, equals('Load Test Program'));
        expect(state.durationWeeks, equals(6));
        expect(state.isLoading, isFalse);
      } finally {
        subscription.close();
        // Clean up
        await TestData.deleteProgram(programId);
      }
    });

    test('saveProgram creates new program', () async {
      final uniqueName = 'Save Test ${DateTime.now().millisecondsSinceEpoch}';

      // Keep provider alive during async operations
      final subscription = container.listen(programBuilderProvider, (_, _) {});

      String? createdProgramId;
      try {
        final notifier = container.read(programBuilderProvider.notifier);

        // Build program synchronously
        notifier.updateName(uniqueName);
        notifier.setDuration(3, 0);
        notifier.assignRest(1);
        notifier.assignRest(7);

        // Save (async)
        final success = await notifier.saveProgram();

        expect(success, isTrue);
        expect(container.read(programBuilderProvider).isLoading, isFalse);

        // Verify program was created by listing
        final listResponse = await programClient.listPrograms(
          ListProgramsRequest(),
        );

        final created = listResponse.programs.where((p) => p.name == uniqueName);
        expect(created, isNotEmpty);
        createdProgramId = created.first.id;
      } finally {
        subscription.close();
        // Clean up
        if (createdProgramId != null) {
          await TestData.deleteProgram(createdProgramId);
        }
      }
    });

    test('saveProgram validates name required', () async {
      // Keep provider alive
      final subscription = container.listen(programBuilderProvider, (_, _) {});

      try {
        final notifier = container.read(programBuilderProvider.notifier);

        // Don't set name
        notifier.assignRest(1);

        final success = await notifier.saveProgram();

        expect(success, isFalse);
        expect(container.read(programBuilderProvider).error, isNotNull);
      } finally {
        subscription.close();
      }
    });

    test('workoutsForProgram lists available workouts', () async {
      // Create a workout first
      final workoutId = await TestData.createTestWorkout(
        name: 'Available for Program',
      );

      final workouts = await container.read(workoutsForProgramProvider.future);

      expect(workouts, isNotEmpty);
      expect(workouts.any((w) => w.id == workoutId), isTrue);

      // Clean up
      await TestData.deleteWorkout(workoutId);
    });
  });
}
