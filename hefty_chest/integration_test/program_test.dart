import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:integration_test/integration_test.dart';

import 'test_utils/test_data.dart';
import 'test_utils/web_test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await WebTestSetup.waitForBackend();
    await WebTestSetup.resetDatabase();
    await WebTestSetup.authenticateTestUser();
  });

  setUp(() async {
    WebTestSetup.restoreTokenProvider();
    await TestData.abandonAnyActiveSession();
  });

  group('Program', () {
    testWidgets('create_program', (tester) async {
      await WebTestSetup.pumpAppAndWait(tester);

      // Navigate to Calendar tab (has + button for program builder)
      await WebTestSetup.navigateToTab(tester, 'Calendar');

      // Tap the + icon to go to program builder
      final addIcon = find.byIcon(Icons.add);
      if (addIcon.evaluate().isNotEmpty) {
        await tester.tap(addIcon.first);
        await tester.runAsync(() async {
          await Future.delayed(const Duration(seconds: 1));
        });
        await tester.pump();

        // Enter program name
        final nameFields = find.byType(EditableText);
        if (nameFields.evaluate().isNotEmpty) {
          await tester.enterText(
            nameFields.first,
            WebTestSetup.uniqueName('Test Program'),
          );
          await tester.pump();
        }

        // Save the program
        final saveButton = find.byIcon(Icons.check);
        if (saveButton.evaluate().isNotEmpty) {
          await tester.runAsync(() async {
            await tester.tap(saveButton.first);
            await Future.delayed(const Duration(seconds: 1));
          });
          await tester.pump(const Duration(seconds: 1));
        }
      }
    });

    testWidgets('today_workout_from_active_program', (tester) async {
      final workoutName = WebTestSetup.uniqueName('Program Workout');

      await tester.runAsync(() async {
        // Create a workout
        final workoutId = await TestData.createWorkoutWithExercise(
          name: workoutName,
        );

        // Create a program with day 1 assigned to the workout
        final createResponse = await programClient.createProgram(
          CreateProgramRequest()
            ..name = 'Active Test Program'
            ..durationWeeks = 1
            ..durationDays = 7
            ..days.add(
              CreateProgramDay()
                ..dayNumber = 1
                ..dayType = ProgramDayType.PROGRAM_DAY_TYPE_WORKOUT
                ..workoutTemplateId = workoutId,
            ),
        );

        // Set as active program
        await programClient.setActiveProgram(
          SetActiveProgramRequest()..id = createResponse.program.id,
        );
      });

      await WebTestSetup.pumpAppAndWait(tester);

      // Verify TodayWorkoutCard appears on home screen
      await WebTestSetup.waitFor(tester, find.textContaining('Day 1'));
      expect(find.textContaining('Day 1'), findsOneWidget);

      // Should have a Start button
      expect(find.text('Start'), findsWidgets);
    });
  });
}
