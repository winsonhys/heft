@Tags(['e2e', 'workout'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';

import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/home/widgets/workout_card.dart';
import 'package:hefty_chest/features/workout_builder/widgets/builder_section_card.dart';
import 'package:hefty_chest/features/workout_builder/widgets/exercise_search_modal.dart';
import 'package:hefty_chest/features/workout_builder/widgets/set_row_editor.dart';

import '../test_utils/test_setup.dart';
import '../test_utils/test_data.dart';

void main() {
  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  setUp(() {
    IntegrationTestSetup.restoreTokenProvider();
  });

  String getUniqueName(String base) {
    return '$base ${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(MockAuth.new)],
        child: const HeftyChestApp(),
      ),
    );
  }

  /// Navigate to workout builder from home screen.
  /// Handles the runAsync/pump cycles for navigation + builder data loading.
  Future<void> navigateToBuilder(WidgetTester tester) async {
    await tester.runAsync(() async {
      await TestData.abandonAnyActiveSession();
      await pumpApp(tester);
      await Future.delayed(const Duration(seconds: 3));
      await tester.pump();

      final fab = find.byKey(const Key('home_fab'));
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
      }
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();
    });
    // Complete GoRouter navigation
    await tester.pump();
    // Let builder screen providers load data
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();
    });
    await tester.pump();
  }

  group('Workout Builder UI E2E', () {
    testWidgets('navigates to workout builder from FAB', (tester) async {
      await navigateToBuilder(tester);

      expect(find.text('Create Workout'), findsOneWidget);
    });

    testWidgets('builder screen shows default section', (tester) async {
      await navigateToBuilder(tester);

      expect(find.text('Create Workout'), findsOneWidget);
      expect(find.byType(BuilderSectionCard), findsOneWidget);
      expect(find.text('Add Section'), findsOneWidget);
    });

    testWidgets('add exercise via search modal', (tester) async {
      await navigateToBuilder(tester);

      // Tap Exercise add button
      await tester.runAsync(() async {
        final exerciseButton = find.descendant(
          of: find.byType(BuilderSectionCard),
          matching: find.ancestor(
            of: find.text('Exercise'),
            matching: find.byType(GestureDetector),
          ),
        );
        if (exerciseButton.evaluate().isNotEmpty) {
          final widget =
              tester.widget<GestureDetector>(exerciseButton.first);
          widget.onTap?.call();
        }
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });
      await tester.pump();

      expect(find.byType(ExerciseSearchModal), findsOneWidget);
      expect(find.text('Add Exercise'), findsOneWidget);
    });

    testWidgets('add section to workout', (tester) async {
      await navigateToBuilder(tester);

      expect(find.byType(BuilderSectionCard), findsOneWidget);

      // Tap Add Section
      await tester.runAsync(() async {
        final addSectionGesture = find.ancestor(
          of: find.text('Add Section'),
          matching: find.byType(GestureDetector),
        );
        if (addSectionGesture.evaluate().isNotEmpty) {
          final widget =
              tester.widget<GestureDetector>(addSectionGesture.first);
          widget.onTap?.call();
        }
        await Future.delayed(const Duration(seconds: 1));
        await tester.pump();
      });
      await tester.pump();

      expect(find.byType(BuilderSectionCard), findsNWidgets(2));
    });

    testWidgets('set target sets appear for added exercise', (tester) async {
      await navigateToBuilder(tester);

      // Open exercise search modal
      await tester.runAsync(() async {
        final exerciseButton = find.descendant(
          of: find.byType(BuilderSectionCard),
          matching: find.ancestor(
            of: find.text('Exercise'),
            matching: find.byType(GestureDetector),
          ),
        );
        if (exerciseButton.evaluate().isNotEmpty) {
          final widget =
              tester.widget<GestureDetector>(exerciseButton.first);
          widget.onTap?.call();
        }
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });
      await tester.pump();

      // Select first exercise from modal
      await tester.runAsync(() async {
        final modal = find.byType(ExerciseSearchModal);
        if (modal.evaluate().isNotEmpty) {
          final listView = find.descendant(
            of: modal,
            matching: find.byType(ListView),
          );
          if (listView.evaluate().isNotEmpty) {
            final tileTaps = find.descendant(
              of: listView,
              matching: find.byType(GestureDetector),
            );
            if (tileTaps.evaluate().isNotEmpty) {
              final tileWidget =
                  tester.widget<GestureDetector>(tileTaps.first);
              tileWidget.onTap?.call();
            }
          }
        }
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });
      // Extra pump cycles for modal dismiss + state update + render
      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(seconds: 1));
        await tester.pump();
      });
      await tester.pump();

      expect(find.byType(SetRowEditor), findsWidgets);
    });

    testWidgets('save workout and verify on home screen', (tester) async {
      final name = getUniqueName('BuilderSave');

      await navigateToBuilder(tester);

      // Fill in workout and save
      await tester.runAsync(() async {
        final nameField = find.byType(EditableText);
        if (nameField.evaluate().isNotEmpty) {
          await tester.enterText(nameField.first, name);
          await tester.pump();
        }

        final exerciseButton = find.descendant(
          of: find.byType(BuilderSectionCard),
          matching: find.ancestor(
            of: find.text('Exercise'),
            matching: find.byType(GestureDetector),
          ),
        );
        if (exerciseButton.evaluate().isNotEmpty) {
          final widget =
              tester.widget<GestureDetector>(exerciseButton.first);
          widget.onTap?.call();
        }
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        final listView = find.descendant(
          of: find.byType(ExerciseSearchModal),
          matching: find.byType(ListView),
        );
        if (listView.evaluate().isNotEmpty) {
          final tileTaps = find.descendant(
            of: listView,
            matching: find.byType(GestureDetector),
          );
          if (tileTaps.evaluate().isNotEmpty) {
            final tileWidget =
                tester.widget<GestureDetector>(tileTaps.first);
            tileWidget.onTap?.call();
          }
        }
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        final saveIcon = find.byIcon(Icons.save);
        if (saveIcon.evaluate().isNotEmpty) {
          await tester.tap(saveIcon);
        }
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });
      await tester.pump();

      expect(find.text('Heft'), findsOneWidget);
      expect(find.text(name), findsOneWidget);
    });

    testWidgets('edit existing workout loads data', (tester) async {
      final name = getUniqueName('EditLoad');

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        await TestData.createWorkoutWithExercise(name: name);

        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        final workoutCard = find.ancestor(
          of: find.text(name),
          matching: find.byType(WorkoutCard),
        );
        if (workoutCard.evaluate().isNotEmpty) {
          final editButton = find.descendant(
            of: workoutCard,
            matching: find.ancestor(
              of: find.text('Edit'),
              matching: find.byType(GestureDetector),
            ),
          );
          if (editButton.evaluate().isNotEmpty) {
            final widget =
                tester.widget<GestureDetector>(editButton.first);
            widget.onTap?.call();
          }
        }
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // GoRouter navigation completes after exiting runAsync
      await tester.pump();
      // Let builder screen load data
      await tester.runAsync(() async {
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });
      await tester.pump();

      expect(find.text('Edit Workout'), findsOneWidget);
    });
  });
}

class MockAuth extends Auth {
  @override
  AuthState build() => AuthState(
        token: IntegrationTestSetup.authToken,
        userId: IntegrationTestSetup.testUserId,
        isLoading: false,
      );
}
