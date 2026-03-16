import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper to create a superset session with configurable set counts and completions.
SessionModel createSupersetSession({
  int exerciseASetCount = 3,
  int exerciseBSetCount = 3,
  int exerciseACompleted = 0,
  int exerciseBCompleted = 0,
  int restDurationSeconds = 60,
  bool includeRestItem = true,
}) {
  return SessionModel(
    id: 'session-1',
    workoutTemplateId: 'template-1',
    name: 'Superset Workout',
    exercises: [
      SessionExerciseModel(
        id: 'ex-a',
        exerciseId: 'exercise-a',
        exerciseName: 'Bench Press',
        sectionName: 'Main',
        supersetId: 'superset-1',
        displayOrder: 0,
        sets: List.generate(
          exerciseASetCount,
          (i) => SessionSetModel(
            id: 'set-a-${i + 1}',
            setNumber: i + 1,
            isCompleted: i < exerciseACompleted,
          ),
        ),
      ),
      SessionExerciseModel(
        id: 'ex-b',
        exerciseId: 'exercise-b',
        exerciseName: 'Bent Over Row',
        sectionName: 'Main',
        supersetId: 'superset-1',
        displayOrder: 1,
        sets: List.generate(
          exerciseBSetCount,
          (i) => SessionSetModel(
            id: 'set-b-${i + 1}',
            setNumber: i + 1,
            isCompleted: i < exerciseBCompleted,
          ),
        ),
      ),
    ],
    restItems: includeRestItem
        ? [
            SessionRestItemModel(
              id: 'rest-1',
              displayOrder: 2,
              sectionName: 'Main',
              restDurationSeconds: restDurationSeconds,
            ),
          ]
        : [],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('getSupersetRoundCompletionInfo', () {
    test('returns rest info when round completes (A1, B1 done)', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        // A: 1 completed, B: 1 completed → round 1 done
        // B was the bottleneck (just completed to match)
        notifier.state = AsyncValue.data(createSupersetSession(
          exerciseACompleted: 1,
          exerciseBCompleted: 1,
        ));

        final info = notifier.getSupersetRoundCompletionInfo('set-b-1');
        expect(info, isNotNull);
        expect(info!.restDurationSeconds, 60);
        expect(info.nextExerciseName, 'Bench Press');
        expect(info.nextSetNumber, 2); // Next round = 1 + 1
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('returns null when set completes but round not finished', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        // A: 1 completed, B: 0 completed → round not done yet
        notifier.state = AsyncValue.data(createSupersetSession(
          exerciseACompleted: 1,
          exerciseBCompleted: 0,
        ));

        final info = notifier.getSupersetRoundCompletionInfo('set-a-1');
        expect(info, isNull);
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('returns null after last round (no rest after final round)', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        // Both exercises: all 3 sets completed → round 3 = maxRounds, no rest
        notifier.state = AsyncValue.data(createSupersetSession(
          exerciseACompleted: 3,
          exerciseBCompleted: 3,
        ));

        final info = notifier.getSupersetRoundCompletionInfo('set-b-3');
        expect(info, isNull);
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('returns null for non-superset exercise', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        // Exercise with no supersetId
        const session = SessionModel(
          id: 'session-1',
          workoutTemplateId: 'template-1',
          name: 'Regular Workout',
          exercises: [
            SessionExerciseModel(
              id: 'ex-solo',
              exerciseId: 'exercise-solo',
              exerciseName: 'Squats',
              sectionName: 'Legs',
              displayOrder: 0,
              sets: [
                SessionSetModel(id: 'set-solo-1', setNumber: 1, isCompleted: true),
              ],
            ),
          ],
        );
        notifier.state = const AsyncValue.data(session);

        final info = notifier.getSupersetRoundCompletionInfo('set-solo-1');
        expect(info, isNull);
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('returns null when no rest item in section', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        notifier.state = AsyncValue.data(createSupersetSession(
          exerciseACompleted: 1,
          exerciseBCompleted: 1,
          includeRestItem: false,
        ));

        final info = notifier.getSupersetRoundCompletionInfo('set-b-1');
        expect(info, isNull);
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('handles different set counts (maxRounds = min)', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        // A has 3 sets, B has 5 sets → maxRounds = 3
        // Both have 2 completed → round 2 done, round 3 remains
        notifier.state = AsyncValue.data(createSupersetSession(
          exerciseASetCount: 3,
          exerciseBSetCount: 5,
          exerciseACompleted: 2,
          exerciseBCompleted: 2,
        ));

        final info = notifier.getSupersetRoundCompletionInfo('set-a-2');
        expect(info, isNotNull);
        expect(info!.restDurationSeconds, 60);
        expect(info.nextSetNumber, 3); // Round 2 + 1
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('returns null when non-bottleneck exercise completes set', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        // A: 2 completed, B: 1 completed → min = 1
        // A is NOT the bottleneck (has 2, min is 1)
        notifier.state = AsyncValue.data(createSupersetSession(
          exerciseACompleted: 2,
          exerciseBCompleted: 1,
        ));

        final info = notifier.getSupersetRoundCompletionInfo('set-a-2');
        expect(info, isNull);
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('round 2 triggers rest correctly', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        // A: 2 completed, B: 2 completed → round 2 done
        notifier.state = AsyncValue.data(createSupersetSession(
          exerciseACompleted: 2,
          exerciseBCompleted: 2,
          restDurationSeconds: 90,
        ));

        final info = notifier.getSupersetRoundCompletionInfo('set-b-2');
        expect(info, isNotNull);
        expect(info!.restDurationSeconds, 90);
        expect(info.nextExerciseName, 'Bench Press');
        expect(info.nextSetNumber, 3); // Round 2 + 1
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('returns null for unknown set ID', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        notifier.state = AsyncValue.data(createSupersetSession(
          exerciseACompleted: 1,
          exerciseBCompleted: 1,
        ));

        final info = notifier.getSupersetRoundCompletionInfo('nonexistent-set');
        expect(info, isNull);
      } finally {
        subscription.close();
        container.dispose();
      }
    });
  });

  group('getExerciseCompletionRestInfo', () {
    test('returns rest info when all sets of exercise are completed', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        const session = SessionModel(
          id: 'session-1',
          workoutTemplateId: 'template-1',
          name: 'Test Workout',
          exercises: [
            SessionExerciseModel(
              id: 'ex-a',
              exerciseId: 'exercise-a',
              exerciseName: 'Bench Press',
              sectionName: 'Main',
              displayOrder: 0,
              sets: [
                SessionSetModel(id: 'set-a-1', setNumber: 1, isCompleted: true),
                SessionSetModel(id: 'set-a-2', setNumber: 2, isCompleted: true),
                SessionSetModel(id: 'set-a-3', setNumber: 3, isCompleted: true),
              ],
            ),
            SessionExerciseModel(
              id: 'ex-b',
              exerciseId: 'exercise-b',
              exerciseName: 'Rows',
              sectionName: 'Main',
              displayOrder: 1,
              sets: [
                SessionSetModel(id: 'set-b-1', setNumber: 1),
                SessionSetModel(id: 'set-b-2', setNumber: 2),
              ],
            ),
          ],
          restItems: [
            SessionRestItemModel(
              id: 'rest-1',
              displayOrder: 2,
              sectionName: 'Main',
              restDurationSeconds: 120,
            ),
          ],
        );
        notifier.state = const AsyncValue.data(session);

        final info = notifier.getExerciseCompletionRestInfo('set-a-3');
        expect(info, isNotNull);
        expect(info!.restDurationSeconds, 120);
        expect(info.nextExerciseName, 'Rows');
        expect(info.nextSetNumber, 1);
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('returns null when not all sets are completed', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        const session = SessionModel(
          id: 'session-1',
          workoutTemplateId: 'template-1',
          name: 'Test Workout',
          exercises: [
            SessionExerciseModel(
              id: 'ex-a',
              exerciseId: 'exercise-a',
              exerciseName: 'Bench Press',
              sectionName: 'Main',
              displayOrder: 0,
              sets: [
                SessionSetModel(id: 'set-a-1', setNumber: 1, isCompleted: true),
                SessionSetModel(id: 'set-a-2', setNumber: 2),
              ],
            ),
          ],
          restItems: [
            SessionRestItemModel(
              id: 'rest-1',
              displayOrder: 1,
              sectionName: 'Main',
              restDurationSeconds: 60,
            ),
          ],
        );
        notifier.state = const AsyncValue.data(session);

        final info = notifier.getExerciseCompletionRestInfo('set-a-1');
        expect(info, isNull);
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('returns null when no rest item in section', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        const session = SessionModel(
          id: 'session-1',
          workoutTemplateId: 'template-1',
          name: 'Test Workout',
          exercises: [
            SessionExerciseModel(
              id: 'ex-a',
              exerciseId: 'exercise-a',
              exerciseName: 'Bench Press',
              sectionName: 'Main',
              displayOrder: 0,
              sets: [
                SessionSetModel(id: 'set-a-1', setNumber: 1, isCompleted: true),
              ],
            ),
          ],
        );
        notifier.state = const AsyncValue.data(session);

        final info = notifier.getExerciseCompletionRestInfo('set-a-1');
        expect(info, isNull);
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('returns null when all exercises are fully completed', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        const session = SessionModel(
          id: 'session-1',
          workoutTemplateId: 'template-1',
          name: 'Test Workout',
          exercises: [
            SessionExerciseModel(
              id: 'ex-a',
              exerciseId: 'exercise-a',
              exerciseName: 'Bench Press',
              sectionName: 'Main',
              displayOrder: 0,
              sets: [
                SessionSetModel(id: 'set-a-1', setNumber: 1, isCompleted: true),
              ],
            ),
          ],
          restItems: [
            SessionRestItemModel(
              id: 'rest-1',
              displayOrder: 1,
              sectionName: 'Main',
              restDurationSeconds: 60,
            ),
          ],
        );
        notifier.state = const AsyncValue.data(session);

        // All sets done, no next set → no rest needed
        final info = notifier.getExerciseCompletionRestInfo('set-a-1');
        expect(info, isNull);
      } finally {
        subscription.close();
        container.dispose();
      }
    });
  });
}
