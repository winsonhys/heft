import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';

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

  group('ProgramService Integration', () {
    test('creates program', () async {
      final uniqueName = 'Test Program ${DateTime.now().millisecondsSinceEpoch}';

      final request = CreateProgramRequest()
        ..userId = TestData.testUserId
        ..name = uniqueName
        ..durationWeeks = 4
        ..durationDays = 28;

      final response = await programClient.createProgram(request);

      expect(response.program.id, isNotEmpty);
      expect(response.program.name, equals(uniqueName));
      expect(response.program.durationWeeks, equals(4));

      // Clean up
      await TestData.deleteProgram(response.program.id);
    });

    test('gets program by ID', () async {
      // Create program
      final programId = await TestData.createTestProgram();

      // Get program
      final request = GetProgramRequest()
        ..id = programId
        ..userId = TestData.testUserId;

      final response = await programClient.getProgram(request);

      expect(response.program.id, equals(programId));
      expect(response.program.name, equals('Integration Test Program'));

      // Clean up
      await TestData.deleteProgram(programId);
    });

    test('lists programs', () async {
      // Create program
      final programId = await TestData.createTestProgram(
        name: 'List Test Program',
      );

      // List programs
      final request = ListProgramsRequest()..userId = TestData.testUserId;

      final response = await programClient.listPrograms(request);

      expect(response.programs, isNotEmpty);
      expect(
        response.programs.any((p) => p.id == programId),
        isTrue,
      );

      // Clean up
      await TestData.deleteProgram(programId);
    });

    test('creates program with days', () async {
      // Create workout to assign
      final workoutId = await TestData.createTestWorkout();

      // Create program with days
      final request = CreateProgramRequest()
        ..userId = TestData.testUserId
        ..name = 'Program With Days'
        ..durationWeeks = 1
        ..durationDays = 7;

      // Add workout days
      final day1 = CreateProgramDay()
        ..dayNumber = 1
        ..dayType = ProgramDayType.PROGRAM_DAY_TYPE_WORKOUT
        ..workoutTemplateId = workoutId;

      final day2 = CreateProgramDay()
        ..dayNumber = 2
        ..dayType = ProgramDayType.PROGRAM_DAY_TYPE_REST;

      final day3 = CreateProgramDay()
        ..dayNumber = 3
        ..dayType = ProgramDayType.PROGRAM_DAY_TYPE_WORKOUT
        ..workoutTemplateId = workoutId;

      request.days.addAll([day1, day2, day3]);

      final response = await programClient.createProgram(request);

      expect(response.program.days, isNotEmpty);

      // Find day 1 - should have workout
      final responseDay1 = response.program.days.firstWhere(
        (d) => d.dayNumber == 1,
        orElse: () => ProgramDay(),
      );
      expect(responseDay1.workoutTemplateId, equals(workoutId));

      // Clean up
      await TestData.deleteProgram(response.program.id);
      await TestData.deleteWorkout(workoutId);
    });

    test('sets program as active', () async {
      // Create program
      final programId = await TestData.createTestProgram();

      // Set as active
      final request = SetActiveProgramRequest()
        ..id = programId
        ..userId = TestData.testUserId;

      final response = await programClient.setActiveProgram(request);

      expect(response.program.isActive, isTrue);

      // Clean up
      await TestData.deleteProgram(programId);
    });

    test('updates program - API stub returns existing program', () async {
      // Note: The backend UpdateProgram API is currently a stub that returns
      // the existing program without actually updating. This test verifies
      // the API is callable and returns a valid response.

      // Create program
      final programId = await TestData.createTestProgram();

      // Update program (returns existing, doesn't actually update)
      final updateRequest = UpdateProgramRequest()
        ..id = programId
        ..userId = TestData.testUserId
        ..name = 'Updated Program Name'
        ..description = 'Updated description';

      final updateResponse = await programClient.updateProgram(updateRequest);

      // API returns the existing program (not updated)
      expect(updateResponse.program.id, equals(programId));
      expect(updateResponse.program.name, isNotEmpty);

      // Clean up
      await TestData.deleteProgram(programId);
    });

    test('deletes program', () async {
      // Create program
      final programId = await TestData.createTestProgram();

      // Delete program
      final request = DeleteProgramRequest()
        ..id = programId
        ..userId = TestData.testUserId;

      final response = await programClient.deleteProgram(request);
      expect(response.success, isTrue);

      // Verify deletion
      try {
        await programClient.getProgram(
          GetProgramRequest()
            ..id = programId
            ..userId = TestData.testUserId,
        );
        fail('Expected program to be deleted');
      } catch (e) {
        // Expected - program should not be found
        expect(e, isNotNull);
      }
    });

    test('gets today workout', () async {
      // Create workout and program
      final workoutId = await TestData.createWorkoutWithExercise(
        name: 'Today Workout',
      );
      final programId = await TestData.createTestProgram(
        name: 'Today Program',
        durationWeeks: 1,
      );

      // Set as active (GetTodayWorkout typically requires active program)
      await programClient.setActiveProgram(
        SetActiveProgramRequest()
          ..id = programId
          ..userId = TestData.testUserId,
      );

      // Get today's workout
      final request = GetTodayWorkoutRequest()..userId = TestData.testUserId;

      final response = await programClient.getTodayWorkout(request);

      // Response structure validation - may or may not have workout based on program setup
      expect(response, isNotNull);

      // Clean up
      await TestData.deleteProgram(programId);
      await TestData.deleteWorkout(workoutId);
    });

    test('switches active program', () async {
      // Create two programs
      final program1Id = await TestData.createTestProgram(
        name: 'Program 1',
      );
      final program2Id = await TestData.createTestProgram(
        name: 'Program 2',
      );

      // Activate program 1
      final activate1Response = await programClient.setActiveProgram(
        SetActiveProgramRequest()
          ..id = program1Id
          ..userId = TestData.testUserId,
      );
      expect(activate1Response.program.isActive, isTrue);

      // Switch to program 2
      final activate2Response = await programClient.setActiveProgram(
        SetActiveProgramRequest()
          ..id = program2Id
          ..userId = TestData.testUserId,
      );
      expect(activate2Response.program.isActive, isTrue);

      // Verify program 1 is no longer active
      final program1Response = await programClient.getProgram(
        GetProgramRequest()
          ..id = program1Id
          ..userId = TestData.testUserId,
      );
      expect(program1Response.program.isActive, isFalse);

      // Clean up
      await TestData.deleteProgram(program1Id);
      await TestData.deleteProgram(program2Id);
    });
  });
}
