import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';
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
  final Set<String> _modifiedExerciseIds = {}; // Track exercises with updated properties

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

    logSession.fine('Starting sync for session: ${session.id}');
    _syncStatus = SyncStatus.syncing;

    try {
      // Capture what we're syncing BEFORE the async call to avoid race conditions
      // (user might delete something while sync is in progress)
      final syncedExercises = List<_PendingExercise>.from(_pendingExercises);
      final syncedDeletedSetIds = List<String>.from(_deletedSetIds);
      final syncedDeletedExerciseIds = List<String>.from(_deletedExerciseIds);
      final syncedModifiedExerciseIds = Set<String>.from(_modifiedExerciseIds);

      // Build exercises array for new exercises and updates
      final exercises = <SyncExerciseData>[];

      // Add new exercises
      for (final pending in syncedExercises) {
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

      // Add updates for modified existing exercises
      for (final exerciseId in syncedModifiedExerciseIds) {
        final exercise = session.exercises.firstWhere(
          (e) => e.id == exerciseId,
          orElse: () => const SessionExerciseModel(id: '', exerciseId: '', exerciseName: '', exerciseType: ExerciseType.EXERCISE_TYPE_UNSPECIFIED, displayOrder: 0, sectionName: '', sets: []),
        );
        if (exercise.id.isNotEmpty) {
          final updateData = UpdateExerciseData()
            ..id = exercise.id
            ..sectionName = exercise.sectionName
            ..displayOrder = exercise.displayOrder;
          if (exercise.supersetId != null && exercise.supersetId!.isNotEmpty) {
            updateData.supersetId = exercise.supersetId!;
          } else {
            // Empty string signals clearing the superset
            updateData.supersetId = '';
          }
          exercises.add(SyncExerciseData()..updateExercise = updateData);
        }
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
        ..deletedSetIds.addAll(syncedDeletedSetIds)
        ..deletedExerciseIds.addAll(syncedDeletedExerciseIds);

      final response = await sessionClient.syncSession(request);

      // Only remove items that were successfully synced (not ALL items)
      // This prevents losing deletions that happened during the async call
      _pendingExercises.removeWhere((e) => syncedExercises.contains(e));
      _deletedSetIds.removeWhere((id) => syncedDeletedSetIds.contains(id));
      _deletedExerciseIds.removeWhere((id) => syncedDeletedExerciseIds.contains(id));
      _modifiedExerciseIds.removeWhere((id) => syncedModifiedExerciseIds.contains(id));

      // Update local state with server response (gets real IDs for new sets and exercises)
      var updatedSession = SessionModel.fromProto(response.session);

      // Re-apply any deletions that happened during the sync
      // The server response won't know about these yet
      if (_deletedSetIds.isNotEmpty || _deletedExerciseIds.isNotEmpty) {
        updatedSession = _applyPendingDeletions(updatedSession);
      }

      state = AsyncValue.data(updatedSession);

      // Only mark as synced if no new changes accumulated during sync
      _hasPendingChanges = _pendingExercises.isNotEmpty ||
          _deletedSetIds.isNotEmpty ||
          _deletedExerciseIds.isNotEmpty ||
          _modifiedExerciseIds.isNotEmpty;
      _syncStatus = _hasPendingChanges ? SyncStatus.pending : SyncStatus.synced;

      // Update local backup with current state
      await SessionStorage.saveSession(updatedSession.toProto());
      logSession.info('Sync completed for session: ${session.id}');
    } catch (e, st) {
      logSession.severe('Sync failed for session: ${session.id}', e, st);
      _syncStatus = SyncStatus.error;
      // Keep _hasPendingChanges = true so we retry on next tick
    }
  }

  /// Apply pending deletions to a session model
  /// Used when server response doesn't reflect deletions made during sync
  SessionModel _applyPendingDeletions(SessionModel session) {
    return session.copyWith(
      exercises: session.exercises
          .where((e) => !_deletedExerciseIds.contains(e.id))
          .map((e) => e.copyWith(
                sets: e.sets.where((s) => !_deletedSetIds.contains(s.id)).toList(),
              ))
          .toList(),
    );
  }

  /// Start a new session - either from template or empty
  Future<SessionModel?> startSession({String? workoutTemplateId, String? name}) async {
    logSession.info('Starting session - template: $workoutTemplateId, name: $name');
    try {
      state = const AsyncValue.loading();

      final request = StartSessionRequest();
      if (workoutTemplateId != null) {
        request.workoutTemplateId = workoutTemplateId;
      }
      if (name != null) {
        request.name = name;
      }

      final response = await sessionClient.startSession(request);
      final sessionModel = SessionModel.fromProto(response.session);
      state = AsyncValue.data(sessionModel);

      // Save backup and start sync timer
      await SessionStorage.saveSession(response.session);
      _startSyncTimer();

      // Refresh active session provider so floating widget updates immediately
      ref.invalidate(hasActiveSessionProvider);

      logSession.info('Session started successfully: ${sessionModel.id}');
      return sessionModel;
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) {
        logSession.fine('startSession cancelled - provider disposed');
        return null;
      }
      logSession.severe('Failed to start session', e, st);
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Load an existing session (or recover from backup)
  /// Compares local backup with server and uses whichever is newer
  Future<SessionModel?> loadSession({required String sessionId}) async {
    logSession.info('Loading session: $sessionId');
    try {
      state = const AsyncValue.loading();

      // Load both local backup and server session
      final localBackup = await SessionStorage.loadSession();
      final localTimestamp = await SessionStorage.getBackupTimestamp();

      final request = GetSessionRequest()..id = sessionId;
      final response = await sessionClient.getSession(request);
      final serverSession = SessionModel.fromProto(response.session);

      // Determine which is newer
      SessionModel sessionToUse;
      bool needsSync = false;

      if (localBackup != null &&
          localBackup.id == sessionId &&
          localTimestamp != null &&
          serverSession.updatedAt != null) {
        // Compare timestamps
        if (localTimestamp.isAfter(serverSession.updatedAt!)) {
          // Local is newer - use local backup
          sessionToUse = SessionModel.fromProto(localBackup);
          needsSync = true; // Need to sync local changes to server
          logSession.warning('Local backup newer than server, will sync changes');
        } else {
          // Server is newer - use server
          sessionToUse = serverSession;
          // Update local backup with server data
          await SessionStorage.saveSession(response.session);
        }
      } else {
        // No matching local backup or no timestamps to compare - use server
        sessionToUse = serverSession;
        await SessionStorage.saveSession(response.session);
      }

      state = AsyncValue.data(sessionToUse);
      _startSyncTimer();

      // If we used local backup, mark as pending to trigger sync
      if (needsSync) {
        _hasPendingChanges = true;
        _syncStatus = SyncStatus.pending;
      }

      logSession.info('Session loaded: $sessionId');
      return sessionToUse;
    } catch (e, st) {
      // Network error - try to load from local backup
      logSession.warning('Network error loading session, trying local backup');
      final localBackup = await SessionStorage.loadSession();
      if (localBackup != null && localBackup.id == sessionId) {
        final sessionModel = SessionModel.fromProto(localBackup);
        state = AsyncValue.data(sessionModel);
        _startSyncTimer();
        _hasPendingChanges = true; // Will try to sync when network is back
        logSession.info('Recovered session from local backup: $sessionId');
        return sessionModel;
      }

      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) {
        return null;
      }
      logSession.severe('Failed to load session: $sessionId', e, st);
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
      logSession.fine('Set updated locally: $sessionSetId');
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

    logSession.fine('Adding exercise: $exerciseName to section: $sectionName');

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

    logSession.fine('Deleting exercise: $sessionExerciseId');

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

  /// Move an exercise to a different section and/or position (local-first, synced via timer)
  void moveExercise({
    required String exerciseId,
    required String toSectionName,
    required int targetIndex,
  }) {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Find the exercise to move
    final exerciseIndex = currentSession.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = currentSession.exercises[exerciseIndex];

    // Track this exercise as modified (if it has a real ID)
    if (exercise.id.isNotEmpty) {
      _modifiedExerciseIds.add(exercise.id);
    }

    // Create updated exercise with new section name
    final updatedExercise = exercise.copyWith(sectionName: toSectionName);

    // Remove from current position and insert at target
    final exercises = List<SessionExerciseModel>.from(currentSession.exercises);
    exercises.removeAt(exerciseIndex);

    // Adjust target index if needed (if moving from before target)
    final adjustedIndex = exerciseIndex < targetIndex ? targetIndex - 1 : targetIndex;
    final insertIndex = adjustedIndex.clamp(0, exercises.length);
    exercises.insert(insertIndex, updatedExercise);

    // Reorder displayOrder for all exercises
    final reorderedExercises = exercises.asMap().entries.map((entry) {
      return entry.value.copyWith(displayOrder: entry.key);
    }).toList();

    final updatedSession = currentSession.copyWith(exercises: reorderedExercises);

    // Mark changes and update state
    _hasPendingChanges = true;
    _syncStatus = SyncStatus.pending;
    state = AsyncValue.data(updatedSession);

    // Save to local backup immediately
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Toggle superset for all exercises in a section (local-first, synced via timer)
  void toggleSectionSuperset({required String sectionName}) {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Find all exercises in this section
    final sectionExercises = currentSession.exercises
        .where((e) => e.sectionName == sectionName)
        .toList();

    if (sectionExercises.isEmpty) return;

    // Track all exercises in this section as modified (if they have real IDs)
    for (final exercise in sectionExercises) {
      if (exercise.id.isNotEmpty) {
        _modifiedExerciseIds.add(exercise.id);
      }
    }

    // Check if any exercise in this section has a superset ID
    final hasSuperset = sectionExercises.any((e) => e.supersetId != null);

    // If has superset, remove it; otherwise create new one
    final newSupersetId = hasSuperset ? null : const Uuid().v4();

    // Update all exercises in section with new supersetId
    final updatedExercises = currentSession.exercises.map((exercise) {
      if (exercise.sectionName != sectionName) return exercise;
      return exercise.copyWith(supersetId: newSupersetId);
    }).toList();

    final updatedSession = currentSession.copyWith(exercises: updatedExercises);

    // Mark changes and update state
    _hasPendingChanges = true;
    _syncStatus = SyncStatus.pending;
    state = AsyncValue.data(updatedSession);

    // Save to local backup immediately
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Create a new section and move an exercise into it (local-first, synced via timer)
  void createNewSectionWithExercise({
    required String exerciseId,
    required String sectionName,
  }) {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Find the exercise to move
    final exerciseIndex = currentSession.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = currentSession.exercises[exerciseIndex];

    // Track this exercise as modified (if it has a real ID)
    if (exercise.id.isNotEmpty) {
      _modifiedExerciseIds.add(exercise.id);
    }

    // Update exercise with new section name
    final updatedExercise = exercise.copyWith(sectionName: sectionName);

    // Remove from current position and add at end
    final exercises = List<SessionExerciseModel>.from(currentSession.exercises);
    exercises.removeAt(exerciseIndex);
    exercises.add(updatedExercise);

    // Reorder displayOrder for all exercises
    final reorderedExercises = exercises.asMap().entries.map((entry) {
      return entry.value.copyWith(displayOrder: entry.key);
    }).toList();

    final updatedSession = currentSession.copyWith(exercises: reorderedExercises);

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

    logSession.info('Finishing session: ${currentSession.id}');

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
      logSession.info('Session finished successfully: ${currentSession.id}');
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) {
        return;
      }
      logSession.severe('Failed to finish session: ${currentSession.id}', e, st);
      // Keep backup on error
      state = AsyncValue.error(e, st);
    }
  }

  /// Abandon the session
  Future<void> abandonSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    logSession.info('Abandoning session: ${currentSession.id}');

    _stopSyncTimer();

    try {
      final request = AbandonSessionRequest()..id = currentSession.id;
      await sessionClient.abandonSession(request);

      // Clear local backup
      await SessionStorage.clearSession();

      state = const AsyncValue.data(null);

      // Refresh active session provider so floating widget updates immediately
      ref.invalidate(hasActiveSessionProvider);
      logSession.info('Session abandoned: ${currentSession.id}');
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) {
        return;
      }
      logSession.severe('Failed to abandon session: ${currentSession.id}', e, st);
      state = AsyncValue.error(e, st);
    }
  }

  /// Force sync any pending changes and stop the timer
  /// Call before navigating away from tracker screen
  Future<void> cleanup() async {
    logSession.fine('Cleanup initiated, forcing sync');
    if (_hasPendingChanges) {
      await _performSync();
    }
    _stopSyncTimer();
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
