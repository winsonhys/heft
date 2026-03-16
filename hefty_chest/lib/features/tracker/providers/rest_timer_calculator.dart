import '../models/session_models.dart';

/// Static calculator for rest timer logic.
/// Extracted from ActiveSession notifier for modularity.
class RestTimerCalculator {
  RestTimerCalculator._();

  /// Returns info about the completed set's rest duration and next set info
  static ({int restDurationSeconds, String nextExerciseName, int nextSetNumber})?
      getSetCompletionInfo(SessionModel session, String completedSetId) {
    // Find the completed set to get its rest duration
    int restDuration = 0;
    bool foundCompleted = false;

    for (final exercise in session.exercises) {
      for (int i = 0; i < exercise.sets.length; i++) {
        final set = exercise.sets[i];

        if (set.id == completedSetId) {
          restDuration = set.restDurationSeconds;
          foundCompleted = true;
          continue;
        }

        // Find next incomplete set after the completed one
        if (foundCompleted && !set.isCompleted) {
          return (
            restDurationSeconds: restDuration,
            nextExerciseName: exercise.exerciseName,
            nextSetNumber: i + 1,
          );
        }
      }
    }

    // Check from beginning for any incomplete sets
    for (final exercise in session.exercises) {
      for (int i = 0; i < exercise.sets.length; i++) {
        final set = exercise.sets[i];
        if (!set.isCompleted) {
          return (
            restDurationSeconds: restDuration,
            nextExerciseName: exercise.exerciseName,
            nextSetNumber: i + 1,
          );
        }
      }
    }

    return null; // All sets complete
  }

  /// Returns section rest item info when completing a set finishes all sets of an exercise.
  static ({int restDurationSeconds, String nextExerciseName, int nextSetNumber})?
      getExerciseCompletionRestInfo(SessionModel session, String completedSetId) {
    // Find the exercise containing the completed set
    SessionExerciseModel? completedExercise;
    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (set.id == completedSetId) {
          completedExercise = exercise;
          break;
        }
      }
      if (completedExercise != null) break;
    }
    if (completedExercise == null) return null;

    // All sets of this exercise must be completed
    final allCompleted = completedExercise.sets.every((s) => s.isCompleted);
    if (!allCompleted) return null;

    // Find the section's rest item
    final restItem = session.restItems
        .where((ri) =>
            ri.sectionName == completedExercise!.sectionName &&
            ri.restDurationSeconds > 0)
        .firstOrNull;
    if (restItem == null) return null;

    // Find next incomplete set across all exercises for context
    for (final exercise in session.exercises) {
      for (int i = 0; i < exercise.sets.length; i++) {
        if (!exercise.sets[i].isCompleted) {
          return (
            restDurationSeconds: restItem.restDurationSeconds,
            nextExerciseName: exercise.exerciseName,
            nextSetNumber: i + 1,
          );
        }
      }
    }

    return null; // All sets complete, no rest needed
  }

  /// Returns rest info when completing a set finishes a superset round.
  /// A round completes when all exercises in the superset have at least N sets done.
  static ({int restDurationSeconds, String nextExerciseName, int nextSetNumber})?
      getSupersetRoundCompletionInfo(SessionModel session, String completedSetId) {
    // Find the exercise containing the completed set
    SessionExerciseModel? completedExercise;
    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (set.id == completedSetId) {
          completedExercise = exercise;
          break;
        }
      }
      if (completedExercise != null) break;
    }
    if (completedExercise == null) return null;

    // Must be in a superset
    final supersetId = completedExercise.supersetId;
    if (supersetId == null || supersetId.isEmpty) return null;

    // Get all exercises in this superset (need at least 2)
    final supersetExercises = session.exercises
        .where((e) => e.supersetId == supersetId)
        .toList();
    if (supersetExercises.length < 2) return null;

    // Count completed sets per exercise → completedRounds = min(counts)
    final completedCounts = supersetExercises
        .map((e) => e.sets.where((s) => s.isCompleted).length)
        .toList();
    final completedRounds = completedCounts.reduce((a, b) => a < b ? a : b);
    if (completedRounds == 0) return null;

    // This exercise must be the bottleneck (exactly completedRounds completed)
    final thisCompleted =
        completedExercise.sets.where((s) => s.isCompleted).length;
    if (thisCompleted != completedRounds) return null;

    // More rounds must remain
    final maxRounds = supersetExercises
        .map((e) => e.sets.length)
        .reduce((a, b) => a < b ? a : b);
    if (completedRounds >= maxRounds) return null;

    // Find the section's rest item
    final restItem = session.restItems
        .where((ri) =>
            ri.sectionName == completedExercise!.sectionName &&
            ri.restDurationSeconds > 0)
        .firstOrNull;
    if (restItem == null) return null;

    return (
      restDurationSeconds: restItem.restDurationSeconds,
      nextExerciseName: supersetExercises.first.exerciseName,
      nextSetNumber: completedRounds + 1,
    );
  }
}
