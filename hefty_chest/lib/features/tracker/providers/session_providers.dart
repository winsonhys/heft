import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../../core/session_storage.dart';
import '../../home/providers/home_providers.dart';
import '../../progress/providers/progress_providers.dart';
import '../models/session_models.dart';

part 'session_providers.g.dart';

/// Sync status for UI indication
enum SyncStatus { synced, syncing, pending, error }

/// Active session notifier with periodic sync
@riverpod
class ActiveSession extends _$ActiveSession {
  Timer? _syncTimer;
  bool _hasPendingChanges = false;
  SyncStatus _syncStatus = SyncStatus.synced;
  final List<_PendingExercise> _pendingExercises = [];
  final List<String> _deletedSetIds = [];
  final List<String> _deletedExerciseIds = [];

  @override
  AsyncValue<SessionModel?> build() {
    // Cancel timer on dispose
    ref.onDispose(() {
      _syncTimer?.cancel();
    });
    return const AsyncValue.data(null);
  }

  /// Get current sync status
  SyncStatus get syncStatus => _syncStatus;

  /// Start sync timer (call when session is active)
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _performSync();
    });
  }

  /// Stop sync timer
  void _stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Perform sync to server
  Future<void> _performSync() async {
    final session = state.value;
    if (session == null || !_hasPendingChanges) return;

    _syncStatus = SyncStatus.syncing;

    try {
      // Build exercises array for new exercises
      final exercises = <SyncExerciseData>[];
      for (final pending in _pendingExercises) {
        final newExData = NewExerciseData()
          ..exerciseId = pending.exerciseId
          ..displayOrder = pending.displayOrder
          ..sectionName = pending.sectionName
          ..numSets = pending.numSets;
        if (pending.supersetId != null) {
          newExData.supersetId = pending.supersetId!;
        }
        exercises.add(SyncExerciseData()..newExercise = newExData);
      }

      // Build sync request with all sets
      final sets = <SyncSetData>[];
      for (final exercise in session.exercises) {
        // Skip sets for exercises with empty IDs (new exercises - sets will be created by server)
        if (exercise.id.isEmpty) continue;

        for (final set in exercise.sets) {
          final syncSet = SyncSetData()
            ..isCompleted = set.isCompleted
            ..weightKg = set.weightKg
            ..reps = set.reps
            ..timeSeconds = set.timeSeconds
            ..distanceM = set.distanceM
            ..rpe = set.rpe;

          // Use oneof: existing sets have ID, new sets use sessionExerciseId
          if (set.id.isNotEmpty) {
            syncSet.id = set.id;
          } else {
            syncSet.sessionExerciseId = exercise.id;
          }

          if (set.notes.isNotEmpty) {
            syncSet.notes = set.notes;
          }

          sets.add(syncSet);
        }
      }

      final request = SyncSessionRequest()
        ..sessionId = session.id
        ..sets.addAll(sets)
        ..exercises.addAll(exercises)
        ..deletedSetIds.addAll(_deletedSetIds)
        ..deletedExerciseIds.addAll(_deletedExerciseIds);

      final response = await sessionClient.syncSession(request);

      // Clear pending lists since they're now on server
      _pendingExercises.clear();
      _deletedSetIds.clear();
      _deletedExerciseIds.clear();

      // Update local state with server response (gets real IDs for new sets and exercises)
      final updatedSession = SessionModel.fromProto(response.session);
      state = AsyncValue.data(updatedSession);

      _hasPendingChanges = false;
      _syncStatus = SyncStatus.synced;

      // Update local backup with server state (includes real IDs)
      await SessionStorage.saveSession(response.session);
    } catch (e) {
      _syncStatus = SyncStatus.error;
      // Keep _hasPendingChanges = true so we retry on next tick
    }
  }

  /// Start a new session from a workout template
  Future<SessionModel?> startSession({required String workoutTemplateId}) async {
    try {
      state = const AsyncValue.loading();

      final request = StartSessionRequest()
        ..workoutTemplateId = workoutTemplateId;

      final response = await sessionClient.startSession(request);
      final sessionModel = SessionModel.fromProto(response.session);
      state = AsyncValue.data(sessionModel);

      // Save backup and start sync timer
      await SessionStorage.saveSession(response.session);
      _startSyncTimer();

      // Refresh active session provider so floating widget updates immediately
      ref.invalidate(hasActiveSessionProvider);

      return sessionModel;
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) {
        return null;
      }
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Load an existing session (or recover from backup)
  Future<SessionModel?> loadSession({required String sessionId}) async {
    try {
      state = const AsyncValue.loading();

      final request = GetSessionRequest()..id = sessionId;
      final response = await sessionClient.getSession(request);
      final sessionModel = SessionModel.fromProto(response.session);
      state = AsyncValue.data(sessionModel);

      // Save backup and start sync timer
      await SessionStorage.saveSession(response.session);
      _startSyncTimer();

      return sessionModel;
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) {
        return null;
      }
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update a set locally (sync happens automatically via timer)
  void updateSetLocally({
    required String sessionSetId,
    double? weightKg,
    int? reps,
    int? timeSeconds,
    bool? isCompleted,
  }) {
    final currentSession = state.value;
    if (currentSession == null) return;

    int completedDelta = 0;
    bool found = false;

    // Use freezed copyWith for immutable updates
    final updatedSession = currentSession.copyWith(
      exercises: currentSession.exercises.map((exercise) {
        return exercise.copyWith(
          sets: exercise.sets.map((set) {
            if (set.id != sessionSetId) return set;

            found = true;

            // Track completion change
            if (isCompleted != null) {
              if (isCompleted && !set.isCompleted) completedDelta = 1;
              if (!isCompleted && set.isCompleted) completedDelta = -1;
            }

            return set.copyWith(
              weightKg: weightKg ?? set.weightKg,
              reps: reps ?? set.reps,
              timeSeconds: timeSeconds ?? set.timeSeconds,
              isCompleted: isCompleted ?? set.isCompleted,
            );
          }).toList(),
        );
      }).toList(),
    );

    if (found) {
      // Update completed count using copyWith
      final finalSession = updatedSession.copyWith(
        completedSets: (updatedSession.completedSets + completedDelta)
            .clamp(0, updatedSession.totalSets),
      );

      // Mark changes and update state
      _hasPendingChanges = true;
      _syncStatus = SyncStatus.pending;
      state = AsyncValue.data(finalSession);

      // Save to local backup immediately (convert to protobuf)
      SessionStorage.saveSession(finalSession.toProto());
    }
  }

  /// Complete/toggle a set (local-first)
  Future<bool> completeSet({
    required String sessionSetId,
    double? weightKg,
    int? reps,
    int? timeSeconds,
    bool? toggle,
  }) async {
    final currentSession = state.value;
    if (currentSession == null) return false;

    // Find current set state
    bool wasCompleted = false;
    for (final exercise in currentSession.exercises) {
      for (final set in exercise.sets) {
        if (set.id == sessionSetId) {
          wasCompleted = set.isCompleted;
          break;
        }
      }
    }

    // Determine new completion state
    final newCompleted = toggle == true ? !wasCompleted : true;

    // Update locally
    updateSetLocally(
      sessionSetId: sessionSetId,
      weightKg: weightKg,
      reps: reps,
      timeSeconds: timeSeconds,
      isCompleted: newCompleted,
    );

    return false; // PR detection would require server call
  }

  /// Uncomplete a set (toggle off)
  Future<bool> uncompleteSet({required String sessionSetId}) async {
    updateSetLocally(
      sessionSetId: sessionSetId,
      isCompleted: false,
    );
    return false;
  }

  /// Update a set without completing (local-first)
  Future<void> updateSet({
    required String sessionSetId,
    double? weightKg,
    int? reps,
    int? timeSeconds,
  }) async {
    updateSetLocally(
      sessionSetId: sessionSetId,
      weightKg: weightKg,
      reps: reps,
      timeSeconds: timeSeconds,
    );
  }

  /// Add a new set to an exercise (local-first, synced via timer)
  void addSet({required String sessionExerciseId}) {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Find the exercise and create a new set
    final updatedSession = currentSession.copyWith(
      exercises: currentSession.exercises.map((exercise) {
        if (exercise.id != sessionExerciseId) return exercise;

        // Create new set with empty ID (will be assigned by server on sync)
        final newSetNumber = exercise.sets.length + 1;
        final newSet = SessionSetModel(
          id: '', // Empty ID indicates new set
          setNumber: newSetNumber,
        );

        return exercise.copyWith(
          sets: [...exercise.sets, newSet],
        );
      }).toList(),
    );

    // Recalculate totalSets
    final newTotalSets =
        updatedSession.exercises.fold(0, (sum, ex) => sum + ex.sets.length);
    final finalSession = updatedSession.copyWith(totalSets: newTotalSets);

    // Mark changes and update state
    _hasPendingChanges = true;
    _syncStatus = SyncStatus.pending;
    state = AsyncValue.data(finalSession);

    // Save to local backup immediately
    SessionStorage.saveSession(finalSession.toProto());
  }

  /// Add a new exercise to the session (local-first, synced via timer)
  void addExercise({
    required String exerciseId,
    required String exerciseName,
    required ExerciseType exerciseType,
    required String sectionName,
    int numSets = 3,
    String? supersetId,
  }) {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Calculate display order (add at end)
    final displayOrder = currentSession.exercises.length;

    // Create local exercise with empty ID (indicates new exercise)
    final newExercise = SessionExerciseModel(
      id: '', // Empty ID = new exercise
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      exerciseType: exerciseType,
      displayOrder: displayOrder,
      sectionName: sectionName,
      supersetId: supersetId,
      sets: List.generate(
        numSets,
        (i) => SessionSetModel(
          id: '', // Empty ID = new set
          setNumber: i + 1,
        ),
      ),
    );

    // Add to pending exercises list for sync
    _pendingExercises.add(_PendingExercise(
      exerciseId: exerciseId,
      displayOrder: displayOrder,
      sectionName: sectionName,
      numSets: numSets,
      supersetId: supersetId,
    ));

    // Update state with new exercise
    final updatedExercises = [...currentSession.exercises, newExercise];
    final newTotalSets =
        updatedExercises.fold(0, (sum, ex) => sum + ex.sets.length);

    final updatedSession = currentSession.copyWith(
      exercises: updatedExercises,
      totalSets: newTotalSets,
    );

    // Mark changes and update state
    _hasPendingChanges = true;
    _syncStatus = SyncStatus.pending;
    state = AsyncValue.data(updatedSession);

    // Save to local backup immediately
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Delete a set from an exercise (local-first, synced via timer)
  void deleteSet({required String sessionSetId}) {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Track if we found and removed the set
    bool found = false;
    bool wasCompleted = false;

    // Remove the set from the exercise
    final updatedSession = currentSession.copyWith(
      exercises: currentSession.exercises.map((exercise) {
        final setToRemove = exercise.sets.where((s) => s.id == sessionSetId).firstOrNull;
        if (setToRemove == null) return exercise;

        found = true;
        wasCompleted = setToRemove.isCompleted;

        // Add to deletion list if it has a real ID (not a new unsaved set)
        if (sessionSetId.isNotEmpty) {
          _deletedSetIds.add(sessionSetId);
        }

        // Remove the set and renumber remaining sets
        final remainingSets = exercise.sets.where((s) => s.id != sessionSetId).toList();
        return exercise.copyWith(
          sets: remainingSets.asMap().entries.map((entry) {
            return entry.value.copyWith(setNumber: entry.key + 1);
          }).toList(),
        );
      }).toList(),
    );

    if (found) {
      // Recalculate totals
      final newTotalSets = updatedSession.exercises.fold(0, (sum, ex) => sum + ex.sets.length);
      final newCompletedSets = wasCompleted
          ? (updatedSession.completedSets - 1).clamp(0, newTotalSets)
          : updatedSession.completedSets.clamp(0, newTotalSets);

      final finalSession = updatedSession.copyWith(
        totalSets: newTotalSets,
        completedSets: newCompletedSets,
      );

      // Mark changes and update state
      _hasPendingChanges = true;
      _syncStatus = SyncStatus.pending;
      state = AsyncValue.data(finalSession);

      // Save to local backup immediately
      SessionStorage.saveSession(finalSession.toProto());
    }
  }

  /// Delete an exercise from the session (local-first, synced via timer)
  void deleteExercise({required String sessionExerciseId}) {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Find the exercise to delete
    final exerciseToDelete = currentSession.exercises
        .where((e) => e.id == sessionExerciseId)
        .firstOrNull;

    if (exerciseToDelete == null) return;

    // Add to deletion list if it has a real ID
    if (sessionExerciseId.isNotEmpty) {
      _deletedExerciseIds.add(sessionExerciseId);
    }

    // Calculate sets being removed
    final setsToRemove = exerciseToDelete.sets.length;
    final completedSetsToRemove = exerciseToDelete.sets.where((s) => s.isCompleted).length;

    // Remove the exercise and reorder remaining
    final remainingExercises = currentSession.exercises
        .where((e) => e.id != sessionExerciseId)
        .toList();

    final reorderedExercises = remainingExercises.asMap().entries.map((entry) {
      return entry.value.copyWith(displayOrder: entry.key);
    }).toList();

    // Recalculate totals
    final newTotalSets = currentSession.totalSets - setsToRemove;
    final newCompletedSets = (currentSession.completedSets - completedSetsToRemove).clamp(0, newTotalSets);

    final updatedSession = currentSession.copyWith(
      exercises: reorderedExercises,
      totalSets: newTotalSets,
      completedSets: newCompletedSets,
    );

    // Mark changes and update state
    _hasPendingChanges = true;
    _syncStatus = SyncStatus.pending;
    state = AsyncValue.data(updatedSession);

    // Save to local backup immediately
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Delete all exercises in a section (local-first, synced via timer)
  void deleteSection({required String sectionName}) {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Find all exercises in this section
    final exercisesToDelete = currentSession.exercises
        .where((e) => e.sectionName == sectionName)
        .toList();

    if (exercisesToDelete.isEmpty) return;

    // Add all exercise IDs to deletion list (if they have real IDs)
    for (final exercise in exercisesToDelete) {
      if (exercise.id.isNotEmpty) {
        _deletedExerciseIds.add(exercise.id);
      }
    }

    // Calculate sets being removed
    final setsToRemove = exercisesToDelete.fold(0, (sum, ex) => sum + ex.sets.length);
    final completedSetsToRemove = exercisesToDelete.fold(
      0,
      (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length,
    );

    // Remove all exercises in this section and reorder remaining
    final remainingExercises = currentSession.exercises
        .where((e) => e.sectionName != sectionName)
        .toList();

    final reorderedExercises = remainingExercises.asMap().entries.map((entry) {
      return entry.value.copyWith(displayOrder: entry.key);
    }).toList();

    // Recalculate totals
    final newTotalSets = currentSession.totalSets - setsToRemove;
    final newCompletedSets = (currentSession.completedSets - completedSetsToRemove).clamp(0, newTotalSets);

    final updatedSession = currentSession.copyWith(
      exercises: reorderedExercises,
      totalSets: newTotalSets,
      completedSets: newCompletedSets,
    );

    // Mark changes and update state
    _hasPendingChanges = true;
    _syncStatus = SyncStatus.pending;
    state = AsyncValue.data(updatedSession);

    // Save to local backup immediately
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Finish the session
  Future<void> finishSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Stop sync timer
    _stopSyncTimer();

    // Force final sync before finishing
    _hasPendingChanges = true;
    await _performSync();

    try {
      final request = FinishSessionRequest()..id = currentSession.id;
      await sessionClient.finishSession(request);

      // Clear local backup on successful finish
      await SessionStorage.clearSession();

      state = const AsyncValue.data(null);

      // Invalidate progress providers so stats update
      ref.invalidate(progressStatsProvider);
      ref.invalidate(weeklyActivityProvider);
      ref.invalidate(personalRecordsProvider);
      ref.invalidate(dashboardStatsProvider);
      // Refresh active session provider so floating widget updates immediately
      ref.invalidate(hasActiveSessionProvider);
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) {
        return;
      }
      // Keep backup on error
      state = AsyncValue.error(e, st);
    }
  }

  /// Abandon the session
  Future<void> abandonSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    _stopSyncTimer();

    try {
      final request = AbandonSessionRequest()..id = currentSession.id;
      await sessionClient.abandonSession(request);

      // Clear local backup
      await SessionStorage.clearSession();

      state = const AsyncValue.data(null);

      // Refresh active session provider so floating widget updates immediately
      ref.invalidate(hasActiveSessionProvider);
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) {
        return;
      }
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear current session
  void clearSession() {
    _stopSyncTimer();
    state = const AsyncValue.data(null);
  }
}

/// Provider for checking if there's an in-progress session (with backup recovery)
@riverpod
Future<SessionModel?> hasActiveSession(Ref ref) async {
  // First check for local backup
  final hasBackup = await SessionStorage.hasBackup();

  // Then check server for active session
  final request = ListSessionsRequest()
    ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS;

  final response = await sessionClient.listSessions(request);

  if (response.sessions.isEmpty) {
    // No server session - check if we have a backup to recover
    if (hasBackup) {
      final backup = await SessionStorage.loadSession();
      return backup != null ? SessionModel.fromProto(backup) : null;
    }
    return null;
  }

  // Load the full session from server
  final getRequest = GetSessionRequest()..id = response.sessions.first.id;
  final sessionResponse = await sessionClient.getSession(getRequest);
  return SessionModel.fromProto(sessionResponse.session);
}

/// Internal class to track pending exercises for sync
class _PendingExercise {
  final String exerciseId;
  final int displayOrder;
  final String sectionName;
  final int numSets;
  final String? supersetId;

  _PendingExercise({
    required this.exerciseId,
    required this.displayOrder,
    required this.sectionName,
    required this.numSets,
    this.supersetId,
  });
}
