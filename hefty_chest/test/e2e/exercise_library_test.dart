@Tags(['e2e', 'misc'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/workout_builder/widgets/exercise_search_modal.dart';

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

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(MockAuth.new)],
        child: const HeftyChestApp(),
      ),
    );
  }

  group('Exercise Library E2E', () {
    testWidgets('exercise list loads from backend', (tester) async {
      await tester.runAsync(() async {
        final response = await exerciseClient.listExercises(
          ListExercisesRequest(),
        );

        expect(response.exercises, isNotEmpty);
      });
    });

    testWidgets('search exercises by name returns results', (tester) async {
      await tester.runAsync(() async {
        // Get exercises to pick a known name
        final allResponse = await exerciseClient.listExercises(
          ListExercisesRequest(),
        );
        final exerciseName = allResponse.exercises.first.name;

        // Search using that name
        final searchResponse = await exerciseClient.searchExercises(
          SearchExercisesRequest()..query = exerciseName,
        );

        expect(searchResponse.exercises, isNotEmpty);
        expect(
          searchResponse.exercises.any((e) => e.name == exerciseName),
          isTrue,
        );
      });
    });

    testWidgets('search with nonsense term returns empty results',
        (tester) async {
      await tester.runAsync(() async {
        final searchResponse = await exerciseClient.searchExercises(
          SearchExercisesRequest()
            ..query =
                'xyznonexistent${DateTime.now().microsecondsSinceEpoch}',
        );

        expect(searchResponse.exercises, isEmpty);
      });
    });

    testWidgets('exercise search modal opens from workout builder',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        await pumpApp(tester);

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Tap FAB
        final fab = find.byKey(const Key('home_fab'));
        if (fab.evaluate().isNotEmpty) {
          await tester.tap(fab);
        }
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();

        // Verify we're on the workout builder screen
        expect(find.text('Create Workout'), findsOneWidget);

        // Find the 'Exercise' button via GestureDetector and invoke onTap
        // The button may be off-screen, so use the GestureDetector pattern
        final exerciseButton = find.ancestor(
          of: find.text('Exercise'),
          matching: find.byType(GestureDetector),
        );
        if (exerciseButton.evaluate().isNotEmpty) {
          final widget =
              tester.widget<GestureDetector>(exerciseButton.first);
          widget.onTap?.call();
        }

        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Verify ExerciseSearchModal appeared
      expect(find.byType(ExerciseSearchModal), findsOneWidget);
    });

    testWidgets('exercises have category information', (tester) async {
      await tester.runAsync(() async {
        final response = await exerciseClient.listExercises(
          ListExercisesRequest(),
        );

        expect(response.exercises, isNotEmpty);

        // Verify that exercises have category information populated
        final hasCategory = response.exercises.any(
          (e) => e.categoryName.isNotEmpty || e.categoryId.isNotEmpty,
        );
        expect(hasCategory, isTrue);
      });
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
