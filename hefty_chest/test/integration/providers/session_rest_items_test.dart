import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Session Rest Items - Mock Tests', () {
    test('completeRestItem via provider updates local state', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        // Set mock session with rest items
        const mockSession = SessionModel(
          id: 'mock-session-1',
          workoutTemplateId: 'mock-workout-1',
          name: 'Mock Workout',
          exercises: [],
          restItems: [
            SessionRestItemModel(
              id: 'rest-1',
              displayOrder: 1,
              sectionName: 'Main',
              restDurationSeconds: 90,
            ),
          ],
        );
        notifier.state = const AsyncValue.data(mockSession);

        // Complete rest item via provider method
        notifier.completeRestItem(restItemId: 'rest-1');

        // Check local state is updated
        final updatedSession = container.read(activeSessionProvider).value;
        expect(updatedSession, isNotNull);
        final updatedRestItem = updatedSession!.restItems.firstWhere(
          (r) => r.id == 'rest-1',
        );
        expect(updatedRestItem.isCompleted, isTrue);
      } finally {
        subscription.close();
        container.dispose();
      }
    });

    test('completeRestItem toggle via provider', () async {
      final container = ProviderContainer();
      final subscription =
          container.listen(activeSessionProvider, (_, _) {});

      try {
        final notifier = container.read(activeSessionProvider.notifier);

        // Set mock session with rest items
        const mockSession = SessionModel(
          id: 'mock-session-1',
          workoutTemplateId: 'mock-workout-1',
          name: 'Mock Workout',
          exercises: [],
          restItems: [
            SessionRestItemModel(
              id: 'rest-1',
              displayOrder: 1,
              sectionName: 'Main',
              restDurationSeconds: 90,
            ),
          ],
        );
        notifier.state = const AsyncValue.data(mockSession);

        // Complete rest item
        notifier.completeRestItem(restItemId: 'rest-1');

        // Verify completed
        var currentSession = container.read(activeSessionProvider).value;
        expect(currentSession!.restItems.first.isCompleted, isTrue);

        // Toggle back to incomplete
        notifier.completeRestItem(restItemId: 'rest-1', toggle: true);

        // Verify uncompleted
        currentSession = container.read(activeSessionProvider).value;
        expect(currentSession!.restItems.first.isCompleted, isFalse);
      } finally {
        subscription.close();
        container.dispose();
      }
    });
  });
}
