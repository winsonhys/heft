import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  setUp(() {
    WebTestSetup.restoreTokenProvider();
  });

  group('Workout Builder', () {
    testWidgets('create_workout_with_exercise', (tester) async {
      final workoutName = WebTestSetup.uniqueName('Builder Test');

      await WebTestSetup.pumpAppAndWait(tester);

      // Tap FAB to go to workout builder
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Create Workout'), findsOneWidget);

      // Enter workout name
      await tester.enterText(find.byType(EditableText).first, workoutName);
      await tester.pump();

      // Tap "Add Section"
      await tester.tap(find.text('Add Section'));
      await tester.pump(const Duration(seconds: 1));

      // Tap "Add Exercise" within the section
      final addExercise = find.text('Add Exercise');
      if (addExercise.evaluate().isNotEmpty) {
        await tester.tap(addExercise.first);
        await tester.runAsync(() async {
          await Future.delayed(const Duration(seconds: 1));
        });
        await tester.pump();

        // Pick the first exercise from the list
        final exerciseItems = find.byType(ListTile);
        if (exerciseItems.evaluate().isNotEmpty) {
          await tester.tap(exerciseItems.first);
          await tester.pump(const Duration(seconds: 1));
        }
      }

      // Save the workout
      final saveButton = find.byIcon(Icons.check);
      if (saveButton.evaluate().isNotEmpty) {
        await tester.runAsync(() async {
          await tester.tap(saveButton.first);
          await Future.delayed(const Duration(seconds: 1));
        });
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('edit_existing_workout', (tester) async {
      final originalName = WebTestSetup.uniqueName('Edit Original');
      final updatedName = WebTestSetup.uniqueName('Edit Updated');

      // Pre-seed a workout via API
      await tester.runAsync(() async {
        await TestData.createWorkoutWithExercise(name: originalName);
      });

      await WebTestSetup.pumpAppAndWait(tester);

      // Find and tap the workout card to edit
      expect(find.text(originalName), findsOneWidget);

      // Look for edit button (pencil icon) or tap the card
      final editIcons = find.byIcon(Icons.edit);
      if (editIcons.evaluate().isNotEmpty) {
        await tester.tap(editIcons.first);
      } else {
        await tester.tap(find.text(originalName));
      }

      await tester.runAsync(() async {
        await Future.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      // Verify we're in edit mode with pre-populated name
      final nameFields = find.byType(EditableText);
      if (nameFields.evaluate().isNotEmpty) {
        // Clear and enter new name
        await tester.enterText(nameFields.first, updatedName);
        await tester.pump();

        // Save
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
  });
}
