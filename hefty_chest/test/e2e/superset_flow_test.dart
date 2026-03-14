@Tags(['e2e', 'session'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';

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

  /// Helper: create a superset workout with two exercises in one section.
  ///
  /// Returns the workout ID. Each exercise has [targetSetsPerExercise] target sets.
  Future<String> createSupersetWorkout({
    required String name,
    int targetSetsPerExercise = 2,
  }) async {
    final exercisesResponse = await exerciseClient.listExercises(
      ListExercisesRequest(),
    );
    final exercise1 = exercisesResponse.exercises[0];
    final exercise2 = exercisesResponse.exercises[1];

    final section = CreateWorkoutSection()
      ..name = 'Superset Section'
      ..displayOrder = 1
      ..isSuperset = true;

    final item1 = CreateSectionItem()
      ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
      ..displayOrder = 1
      ..exerciseId = exercise1.id;

    for (int i = 1; i <= targetSetsPerExercise; i++) {
      item1.targetSets.add(CreateTargetSet()
        ..setNumber = i
        ..targetWeightKg = 50.0
        ..targetReps = 10);
    }

    final item2 = CreateSectionItem()
      ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
      ..displayOrder = 2
      ..exerciseId = exercise2.id;

    for (int i = 1; i <= targetSetsPerExercise; i++) {
      item2.targetSets.add(CreateTargetSet()
        ..setNumber = i
        ..targetWeightKg = 40.0
        ..targetReps = 12);
    }

    section.items.addAll([item1, item2]);

    return TestData.createTestWorkout(
      name: name,
      sections: [section],
    );
  }

  group('Superset Flow E2E', () {
    testWidgets('create workout with superset section via API', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Superset Create');

        // Get two exercises
        final exercisesResponse = await exerciseClient.listExercises(
          ListExercisesRequest(),
        );
        final exercise1 = exercisesResponse.exercises[0];
        final exercise2 = exercisesResponse.exercises[1];

        // Create a workout with a superset section containing two exercises
        final section = CreateWorkoutSection()
          ..name = 'Superset Section'
          ..displayOrder = 1
          ..isSuperset = true;

        final item1 = CreateSectionItem()
          ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
          ..displayOrder = 1
          ..exerciseId = exercise1.id;
        item1.targetSets.add(CreateTargetSet()
          ..setNumber = 1
          ..targetWeightKg = 50.0
          ..targetReps = 10);

        final item2 = CreateSectionItem()
          ..itemType = SectionItemType.SECTION_ITEM_TYPE_EXERCISE
          ..displayOrder = 2
          ..exerciseId = exercise2.id;
        item2.targetSets.add(CreateTargetSet()
          ..setNumber = 1
          ..targetWeightKg = 40.0
          ..targetReps = 12);

        section.items.addAll([item1, item2]);

        final workoutId = await TestData.createTestWorkout(
          name: name,
          sections: [section],
        );

        // Verify via GetWorkout that the section has isSuperset == true
        final getResponse = await workoutClient.getWorkout(
          GetWorkoutRequest()..id = workoutId,
        );

        final workout = getResponse.workout;
        expect(workout.sections, hasLength(1));
        expect(workout.sections.first.isSuperset, isTrue);
        expect(workout.sections.first.items, hasLength(2));

        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Verify the workout appears on home screen
        expect(find.text(name), findsOneWidget);
      });
    });

    testWidgets('superset workout starts session correctly', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Superset Session');

        // Create a superset workout with 2 exercises
        final workoutId = await createSupersetWorkout(name: name);

        // Start a session from this workout
        final sessionId = await TestData.startSession(
          workoutTemplateId: workoutId,
        );

        // Get session and verify it has exercises from the superset section
        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );

        final session = sessionResponse.session;
        // Session should have exercises for both items in the superset
        expect(session.exercises, hasLength(greaterThanOrEqualTo(2)));

        // Verify both exercises have the expected exercise IDs
        final exercisesResponse = await exerciseClient.listExercises(
          ListExercisesRequest(),
        );
        final exercise1Id = exercisesResponse.exercises[0].id;
        final exercise2Id = exercisesResponse.exercises[1].id;

        final sessionExerciseIds =
            session.exercises.map((e) => e.exerciseId).toSet();
        expect(sessionExerciseIds, contains(exercise1Id));
        expect(sessionExerciseIds, contains(exercise2Id));

        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Cleanup
        await sessionClient.abandonSession(
          AbandonSessionRequest()..id = sessionId,
        );
      });
    });

    testWidgets('superset section persists after update', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Superset Persist');
        final updatedName = getUniqueName('Superset Updated');

        // Create a superset workout via API
        final workoutId = await createSupersetWorkout(name: name);

        // Verify superset is set before update
        final beforeResponse = await workoutClient.getWorkout(
          GetWorkoutRequest()..id = workoutId,
        );
        expect(beforeResponse.workout.sections.first.isSuperset, isTrue);

        // Update the workout name (without changing sections)
        await workoutClient.updateWorkout(
          UpdateWorkoutRequest()
            ..id = workoutId
            ..name = updatedName
            ..description = beforeResponse.workout.description,
        );

        // Get the workout again and verify isSuperset is still true
        final afterResponse = await workoutClient.getWorkout(
          GetWorkoutRequest()..id = workoutId,
        );

        expect(afterResponse.workout.name, equals(updatedName));
        expect(afterResponse.workout.sections, hasLength(1));
        expect(afterResponse.workout.sections.first.isSuperset, isTrue);
        expect(afterResponse.workout.sections.first.items, hasLength(2));

        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Verify updated name appears on home screen
        expect(find.text(updatedName), findsOneWidget);
      });
    });

    testWidgets('complete superset session syncs all sets', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        final name = getUniqueName('Superset Complete');

        // Create a superset workout with 2 exercises, each with 2 target sets
        final workoutId = await createSupersetWorkout(
          name: name,
          targetSetsPerExercise: 2,
        );

        // Start session
        final startResponse = await sessionClient.startSession(
          StartSessionRequest()..workoutTemplateId = workoutId,
        );
        final session = startResponse.session;

        // Sync all sets as completed
        final syncSets = <SyncSetData>[];
        for (final exercise in session.exercises) {
          for (final set in exercise.sets) {
            syncSets.add(SyncSetData()
              ..id = set.id
              ..weightKg = 50.0
              ..reps = 10
              ..isCompleted = true);
          }
        }

        final syncResponse = await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = session.id
            ..sets.addAll(syncSets),
        );
        expect(syncResponse.success, isTrue);

        // Verify all sets are marked completed
        for (final exercise in syncResponse.session.exercises) {
          for (final set in exercise.sets) {
            expect(set.isCompleted, isTrue);
          }
        }

        // Finish session
        final finishResponse = await sessionClient.finishSession(
          FinishSessionRequest()..id = session.id,
        );

        expect(
          finishResponse.session.status,
          equals(WorkoutStatus.WORKOUT_STATUS_COMPLETED),
        );

        await pumpApp(tester);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Verify session appears in history as completed
        final historyResponse = await sessionClient.listSessions(
          ListSessionsRequest(),
        );
        final completedSession = historyResponse.sessions.firstWhere(
          (s) => s.id == session.id,
        );
        expect(
          completedSession.status,
          equals(WorkoutStatus.WORKOUT_STATUS_COMPLETED),
        );
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
