import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';
import 'package:hefty_chest/gen/common.pbenum.dart';
import 'package:hefty_chest/shared/widgets/floating_session_widget.dart';

/// Mock ActiveSession notifier for testing
class MockActiveSession extends ActiveSession {
  final SessionModel? _mockSession;

  MockActiveSession(this._mockSession);

  @override
  AsyncValue<SessionModel?> build() => AsyncValue.data(_mockSession);
}

/// Creates a mock SessionModel for testing
SessionModel createMockSession({
  String id = 'test-session-id',
  String name = 'Test Workout',
  int completedSets = 3,
  int totalSets = 10,
  List<SessionExerciseModel>? exercises,
}) {
  return SessionModel(
    id: id,
    workoutTemplateId: 'test-workout-id',
    name: name,
    exercises: exercises ?? [],
    completedSets: completedSets,
    totalSets: totalSets,
  );
}

/// Creates a mock SessionExerciseModel for testing
SessionExerciseModel createMockExercise({
  String id = 'exercise-1',
  String exerciseId = 'ex-1',
  String exerciseName = 'Bench Press',
  String sectionName = 'Main Workout',
  ExerciseType exerciseType = ExerciseType.EXERCISE_TYPE_WEIGHT_REPS,
  List<SessionSetModel>? sets,
  String notes = '',
}) {
  return SessionExerciseModel(
    id: id,
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    sectionName: sectionName,
    exerciseType: exerciseType,
    notes: notes,
    sets: sets ?? [
      const SessionSetModel(
        id: 'set-1',
        setNumber: 1,
        weightKg: 60.0,
        reps: 10,
        isCompleted: true,
      ),
      const SessionSetModel(
        id: 'set-2',
        setNumber: 2,
        weightKg: 60.0,
        reps: 10,
        isCompleted: false,
      ),
    ],
  );
}

/// Helper to wrap widget with FTheme
Widget wrapWithTheme(Widget child) {
  return MaterialApp(
    home: FTheme(
      data: FThemes.zinc.dark,
      child: Scaffold(body: child),
    ),
  );
}

/// Helper to wrap widget with FTheme and ProviderScope
Widget wrapWithThemeAndProvider(Widget child, {SessionModel? mockSession}) {
  return ProviderScope(
    overrides: [
      activeSessionProvider.overrideWith(() => MockActiveSession(mockSession)),
    ],
    child: MaterialApp(
      home: FTheme(
        data: FThemes.zinc.dark,
        child: Scaffold(body: child),
      ),
    ),
  );
}

/// Creates a session with exercises that have the specified completed/total sets
SessionModel createSessionWithSets(int completedSets, int totalSets) {
  final sets = <SessionSetModel>[];
  for (var i = 0; i < totalSets; i++) {
    sets.add(SessionSetModel(
      id: 'set-$i',
      setNumber: i + 1,
      isCompleted: i < completedSets,
    ));
  }
  return SessionModel(
    id: 'test-session',
    workoutTemplateId: 'test-workout',
    name: 'Test',
    exercises: [
      SessionExerciseModel(
        id: 'ex-1',
        exerciseId: 'ex-1',
        exerciseName: 'Test Exercise',
        sectionName: 'Main',
        sets: sets,
      ),
    ],
    completedSets: completedSets,
    totalSets: totalSets,
  );
}

/// Mock ActiveSession notifier that tracks addExercise calls
class TrackingActiveSession extends ActiveSession {
  final SessionModel _session;
  final List<Map<String, dynamic>> addExerciseCalls = [];
  bool abandonSessionCalled = false;

  TrackingActiveSession(this._session);

  @override
  AsyncValue<SessionModel?> build() => AsyncValue.data(_session);

  @override
  Future<SessionModel?> loadSession({required String sessionId}) async {
    state = AsyncValue.data(_session);
    return _session;
  }

  @override
  void addExercise({
    required String exerciseId,
    required String exerciseName,
    required ExerciseType exerciseType,
    required String sectionName,
    int numSets = 3,
    String? supersetId,
  }) {
    addExerciseCalls.add({
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'exerciseType': exerciseType,
      'sectionName': sectionName,
      'numSets': numSets,
      'supersetId': supersetId,
    });
  }

  @override
  Future<void> abandonSession() async {
    abandonSessionCalled = true;
    state = const AsyncValue.data(null);
  }
}

/// Safe mock for FloatingWidgetVisible that handles disposal gracefully
class SafeFloatingWidgetVisible extends FloatingWidgetVisible {
  bool _isMounted = true;

  @override
  bool build() {
    ref.onDispose(() => _isMounted = false);
    return true;
  }

  @override
  void hide() {
    if (_isMounted) state = false;
  }

  @override
  void show() {
    if (_isMounted) state = true;
  }
}
