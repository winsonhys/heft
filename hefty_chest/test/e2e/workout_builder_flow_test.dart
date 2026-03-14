@Tags(['e2e', 'workout'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/home/widgets/workout_card.dart';

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

  group('Workout Builder Flow E2E', () {
    testWidgets('created workout appears on home screen', (tester) async {
      final name = getUniqueName('Created');

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        // Create workout via API
        await TestData.createWorkoutWithExercise(name: name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Workout should appear on home
      expect(find.text('Heft'), findsOneWidget);
      expect(find.text(name), findsOneWidget);
      // WorkoutCard should be present
      expect(find.byType(WorkoutCard), findsWidgets);
    });

    testWidgets('updated workout name reflects on home', (tester) async {
      final originalName = getUniqueName('Original');
      final updatedName = getUniqueName('Updated');

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final workoutId =
            await TestData.createWorkoutWithExercise(name: originalName);

        // Update workout name via API
        final workout = await workoutClient.getWorkout(
          GetWorkoutRequest()..id = workoutId,
        );
        await workoutClient.updateWorkout(
          UpdateWorkoutRequest()
            ..id = workoutId
            ..name = updatedName
            ..description = workout.workout.description,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Updated name should appear
      expect(find.text(updatedName), findsOneWidget);
      // Original name should be gone
      expect(find.text(originalName), findsNothing);
    });

    testWidgets('delete workout shows confirm dialog', (tester) async {
      final name = getUniqueName('DelW');

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        await TestData.createTestWorkout(name: name);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Tap three-dots menu via GestureDetector.onTap (may be off-screen)
        final workoutCard = find.ancestor(
          of: find.text(name),
          matching: find.byType(WorkoutCard),
        );
        final menuGesture = find.descendant(
          of: workoutCard,
          matching: find.ancestor(
            of: find.byIcon(Icons.more_vert),
            matching: find.byType(GestureDetector),
          ),
        );
        expect(menuGesture, findsWidgets, reason: 'Menu button should be on workout card');
        final menuWidget = tester.widget<GestureDetector>(menuGesture.first);
        menuWidget.onTap?.call();
        await Future.delayed(const Duration(seconds: 1));
        await tester.pump();

        // Tap Delete in bottom sheet via InkWell.onTap
        final deleteInkWell = find.ancestor(
          of: find.text('Delete'),
          matching: find.byType(InkWell),
        );
        expect(deleteInkWell, findsWidgets, reason: 'Delete option should be in context menu');
        final deleteWidget = tester.widget<InkWell>(deleteInkWell.first);
        deleteWidget.onTap?.call();
        await Future.delayed(const Duration(seconds: 1));
        await tester.pump();
      });

      // Delete confirmation dialog
      expect(find.text('Delete Workout'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to delete'),
        findsOneWidget,
      );

      await tester.runAsync(() async {
        // Confirm delete
        await tester.tap(find.text('Delete').last, warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Workout should be gone
      expect(find.text(name), findsNothing);
    });

    testWidgets('duplicate workout via API appears on home', (tester) async {
      final name = getUniqueName('Dup');

      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final workoutId = await TestData.createTestWorkout(name: name);

        // Duplicate via API
        await workoutClient.duplicateWorkout(
          DuplicateWorkoutRequest()..id = workoutId,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Both original and copy should be visible
      expect(find.textContaining(name), findsWidgets);
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
