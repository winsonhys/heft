import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';
import '../../../core/session_storage.dart';
import '../../home/providers/home_providers.dart';
import '../../progress/providers/progress_providers.dart';
import '../models/session_models.dart';
import 'rest_timer_calculator.dart';
import 'session_sync_engine.dart';

export 'session_sync_engine.dart' show SyncStatus;

part 'session_providers.g.dart';

/// Active session notifier with periodic sync
@riverpod
class ActiveSession extends _$ActiveSession {
  final SessionSyncEngine _syncEngine = SessionSyncEngine();

  @override
  AsyncValue<SessionModel?> build() {
    ref.onDispose(() {
      _syncEngine.stopSyncTimer();
    });
    return const AsyncValue.data(null);
  }

  /// Get current sync status
  SyncStatus get syncStatus => _syncEngine.syncStatus;

  /// Perform sync (called by timer and cleanup)
  Future<void> _performSync() async {
    final session = state.value;
    if (session == null) return;

    final updatedSession = await _syncEngine.performSync(session);
    if (updatedSession != null) {
      state = AsyncValue.data(updatedSession);
    }
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
      _syncEngine.startSyncTimer(_performSync);

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
        if (localTimestamp.isAfter(serverSession.updatedAt!)) {
          sessionToUse = SessionModel.fromProto(localBackup);
          needsSync = true;
          logSession.warning('Local backup newer than server, will sync changes');
        } else {
          sessionToUse = serverSession;
          await SessionStorage.saveSession(response.session);
        }
      } else {
        sessionToUse = serverSession;
        await SessionStorage.saveSession(response.session);
      }

      state = AsyncValue.data(sessionToUse);
      _syncEngine.startSyncTimer(_performSync);

      if (needsSync) {
        _syncEngine.markChanged();
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
        _syncEngine.startSyncTimer(_performSync);
        _syncEngine.markChanged();
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

    final updatedSession = currentSession.copyWith(
      exercises: currentSession.exercises.map((exercise) {
        return exercise.copyWith(
          sets: exercise.sets.map((set) {
            if (set.id != sessionSetId) return set;

            found = true;

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
      final finalSession = updatedSession.copyWith(
        completedSets: (updatedSession.completedSets + completedDelta)
            .clamp(0, updatedSession.totalSets),
      );

      _syncEngine.markChanged();
      state = AsyncValue.data(finalSession);
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

    bool wasCompleted = false;
    for (final exercise in currentSession.exercises) {
      for (final set in exercise.sets) {
        if (set.id == sessionSetId) {
          wasCompleted = set.isCompleted;
          break;
        }
      }
    }

    final newCompleted = toggle == true ? !wasCompleted : true;

    updateSetLocally(
      sessionSetId: sessionSetId,
      weightKg: weightKg,
      reps: reps,
      timeSeconds: timeSeconds,
      isCompleted: newCompleted,
    );

    return false;
  }

  /// Uncomplete a set (toggle off)
  Future<bool> uncompleteSet({required String sessionSetId}) async {
    updateSetLocally(sessionSetId: sessionSetId, isCompleted: false);
    return false;
  }

  /// Complete/toggle a rest item (local-first)
  void completeRestItem({
    required String restItemId,
    bool toggle = false,
  }) {
    final currentSession = state.value;
    if (currentSession == null) return;

    final restItem = currentSession.restItems.firstWhere(
      (ri) => ri.id == restItemId,
      orElse: () => const SessionRestItemModel(id: '', displayOrder: 0, sectionName: '', restDurationSeconds: 0),
    );
    if (restItem.id.isEmpty) return;

    final newCompleted = toggle ? !restItem.isCompleted : true;

    final updatedRestItems = currentSession.restItems.map((ri) {
      if (ri.id != restItemId) return ri;
      return ri.copyWith(
        isCompleted: newCompleted,
        completedAt: newCompleted ? DateTime.now() : null,
      );
    }).toList();

    final updatedSession = currentSession.copyWith(restItems: updatedRestItems);

    _syncEngine.addModifiedRestItemId(restItemId);
    _syncEngine.markChanged();
    state = AsyncValue.data(updatedSession);
    SessionStorage.saveSession(updatedSession.toProto());
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

    final updatedSession = currentSession.copyWith(
      exercises: currentSession.exercises.map((exercise) {
        if (exercise.id != sessionExerciseId) return exercise;

        final newSetNumber = exercise.sets.length + 1;
        final newSet = SessionSetModel(id: '', setNumber: newSetNumber);

        return exercise.copyWith(sets: [...exercise.sets, newSet]);
      }).toList(),
    );

    final newTotalSets =
        updatedSession.exercises.fold(0, (sum, ex) => sum + ex.sets.length);
    final finalSession = updatedSession.copyWith(totalSets: newTotalSets);

    _syncEngine.markChanged();
    state = AsyncValue.data(finalSession);
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

    final displayOrder = currentSession.exercises.length;

    final newExercise = SessionExerciseModel(
      id: '',
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      exerciseType: exerciseType,
      displayOrder: displayOrder,
      sectionName: sectionName,
      supersetId: supersetId,
      sets: List.generate(
        numSets,
        (i) => SessionSetModel(id: '', setNumber: i + 1),
      ),
    );

    _syncEngine.addPendingExercise(PendingExercise(
      exerciseId: exerciseId,
      displayOrder: displayOrder,
      sectionName: sectionName,
      numSets: numSets,
      supersetId: supersetId,
    ));

    final updatedExercises = [...currentSession.exercises, newExercise];
    final newTotalSets =
        updatedExercises.fold(0, (sum, ex) => sum + ex.sets.length);

    final updatedSession = currentSession.copyWith(
      exercises: updatedExercises,
      totalSets: newTotalSets,
    );

    _syncEngine.markChanged();
    state = AsyncValue.data(updatedSession);
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Delete a set from an exercise (local-first, synced via timer)
  void deleteSet({required String sessionSetId}) {
    final currentSession = state.value;
    if (currentSession == null) return;

    bool found = false;
    bool wasCompleted = false;

    final updatedSession = currentSession.copyWith(
      exercises: currentSession.exercises.map((exercise) {
        final setToRemove = exercise.sets.where((s) => s.id == sessionSetId).firstOrNull;
        if (setToRemove == null) return exercise;

        found = true;
        wasCompleted = setToRemove.isCompleted;

        if (sessionSetId.isNotEmpty) {
          _syncEngine.addDeletedSetId(sessionSetId);
        }

        final remainingSets = exercise.sets.where((s) => s.id != sessionSetId).toList();
        return exercise.copyWith(
          sets: remainingSets.asMap().entries.map((entry) {
            return entry.value.copyWith(setNumber: entry.key + 1);
          }).toList(),
        );
      }).toList(),
    );

    if (found) {
      final newTotalSets = updatedSession.exercises.fold(0, (sum, ex) => sum + ex.sets.length);
      final newCompletedSets = wasCompleted
          ? (updatedSession.completedSets - 1).clamp(0, newTotalSets)
          : updatedSession.completedSets.clamp(0, newTotalSets);

      final finalSession = updatedSession.copyWith(
        totalSets: newTotalSets,
        completedSets: newCompletedSets,
      );

      _syncEngine.markChanged();
      state = AsyncValue.data(finalSession);
      SessionStorage.saveSession(finalSession.toProto());
    }
  }

  /// Delete an exercise from the session (local-first, synced via timer)
  void deleteExercise({required String sessionExerciseId}) {
    final currentSession = state.value;
    if (currentSession == null) return;

    logSession.fine('Deleting exercise: $sessionExerciseId');

    final exerciseToDelete = currentSession.exercises
        .where((e) => e.id == sessionExerciseId)
        .firstOrNull;

    if (exerciseToDelete == null) return;

    if (sessionExerciseId.isNotEmpty) {
      _syncEngine.addDeletedExerciseId(sessionExerciseId);
    }

    final setsToRemove = exerciseToDelete.sets.length;
    final completedSetsToRemove = exerciseToDelete.sets.where((s) => s.isCompleted).length;

    final remainingExercises = currentSession.exercises
        .where((e) => e.id != sessionExerciseId)
        .toList();

    final reorderedExercises = remainingExercises.asMap().entries.map((entry) {
      return entry.value.copyWith(displayOrder: entry.key);
    }).toList();

    final newTotalSets = currentSession.totalSets - setsToRemove;
    final newCompletedSets = (currentSession.completedSets - completedSetsToRemove).clamp(0, newTotalSets);

    final updatedSession = currentSession.copyWith(
      exercises: reorderedExercises,
      totalSets: newTotalSets,
      completedSets: newCompletedSets,
    );

    _syncEngine.markChanged();
    state = AsyncValue.data(updatedSession);
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Delete all exercises in a section (local-first, synced via timer)
  void deleteSection({required String sectionName}) {
    final currentSession = state.value;
    if (currentSession == null) return;

    final exercisesToDelete = currentSession.exercises
        .where((e) => e.sectionName == sectionName)
        .toList();

    if (exercisesToDelete.isEmpty) return;

    for (final exercise in exercisesToDelete) {
      if (exercise.id.isNotEmpty) {
        _syncEngine.addDeletedExerciseId(exercise.id);
      }
    }

    final setsToRemove = exercisesToDelete.fold(0, (sum, ex) => sum + ex.sets.length);
    final completedSetsToRemove = exercisesToDelete.fold(
      0,
      (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length,
    );

    final remainingExercises = currentSession.exercises
        .where((e) => e.sectionName != sectionName)
        .toList();

    final reorderedExercises = remainingExercises.asMap().entries.map((entry) {
      return entry.value.copyWith(displayOrder: entry.key);
    }).toList();

    final newTotalSets = currentSession.totalSets - setsToRemove;
    final newCompletedSets = (currentSession.completedSets - completedSetsToRemove).clamp(0, newTotalSets);

    final updatedSession = currentSession.copyWith(
      exercises: reorderedExercises,
      totalSets: newTotalSets,
      completedSets: newCompletedSets,
    );

    _syncEngine.markChanged();
    state = AsyncValue.data(updatedSession);
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

    final exerciseIndex = currentSession.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = currentSession.exercises[exerciseIndex];

    if (exercise.id.isNotEmpty) {
      _syncEngine.addModifiedExerciseId(exercise.id);
    }

    final updatedExercise = exercise.copyWith(sectionName: toSectionName);

    final exercises = List<SessionExerciseModel>.from(currentSession.exercises);
    exercises.removeAt(exerciseIndex);

    final adjustedIndex = exerciseIndex < targetIndex ? targetIndex - 1 : targetIndex;
    final insertIndex = adjustedIndex.clamp(0, exercises.length);
    exercises.insert(insertIndex, updatedExercise);

    final reorderedExercises = exercises.asMap().entries.map((entry) {
      return entry.value.copyWith(displayOrder: entry.key);
    }).toList();

    final updatedSession = currentSession.copyWith(exercises: reorderedExercises);

    _syncEngine.markChanged();
    state = AsyncValue.data(updatedSession);
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Toggle superset for all exercises in a section (local-first, synced via timer)
  void toggleSectionSuperset({required String sectionName}) {
    final currentSession = state.value;
    if (currentSession == null) return;

    final sectionExercises = currentSession.exercises
        .where((e) => e.sectionName == sectionName)
        .toList();

    if (sectionExercises.isEmpty) return;

    for (final exercise in sectionExercises) {
      if (exercise.id.isNotEmpty) {
        _syncEngine.addModifiedExerciseId(exercise.id);
      }
    }

    final hasSuperset = sectionExercises.any((e) => e.supersetId != null);
    final newSupersetId = hasSuperset ? null : const Uuid().v4();

    final updatedExercises = currentSession.exercises.map((exercise) {
      if (exercise.sectionName != sectionName) return exercise;
      return exercise.copyWith(supersetId: newSupersetId);
    }).toList();

    final updatedSession = currentSession.copyWith(exercises: updatedExercises);

    _syncEngine.markChanged();
    state = AsyncValue.data(updatedSession);
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Create a new section and move an exercise into it (local-first, synced via timer)
  void createNewSectionWithExercise({
    required String exerciseId,
    required String sectionName,
  }) {
    final currentSession = state.value;
    if (currentSession == null) return;

    final exerciseIndex = currentSession.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = currentSession.exercises[exerciseIndex];

    if (exercise.id.isNotEmpty) {
      _syncEngine.addModifiedExerciseId(exercise.id);
    }

    final updatedExercise = exercise.copyWith(sectionName: sectionName);

    final exercises = List<SessionExerciseModel>.from(currentSession.exercises);
    exercises.removeAt(exerciseIndex);
    exercises.add(updatedExercise);

    final reorderedExercises = exercises.asMap().entries.map((entry) {
      return entry.value.copyWith(displayOrder: entry.key);
    }).toList();

    final updatedSession = currentSession.copyWith(exercises: reorderedExercises);

    _syncEngine.markChanged();
    state = AsyncValue.data(updatedSession);
    SessionStorage.saveSession(updatedSession.toProto());
  }

  /// Finish the session
  Future<void> finishSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    logSession.info('Finishing session: ${currentSession.id}');

    _syncEngine.stopSyncTimer();

    // Force final sync before finishing
    _syncEngine.markChanged();
    await _performSync();

    try {
      final request = FinishSessionRequest()..id = currentSession.id;
      await sessionClient.finishSession(request);

      await SessionStorage.clearSession();

      state = const AsyncValue.data(null);

      ref.invalidate(progressStatsProvider);
      ref.invalidate(weeklyActivityProvider);
      ref.invalidate(personalRecordsProvider);
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(hasActiveSessionProvider);
      logSession.info('Session finished successfully: ${currentSession.id}');
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) {
        return;
      }
      logSession.severe('Failed to finish session: ${currentSession.id}', e, st);
      state = AsyncValue.error(e, st);
    }
  }

  /// Abandon the session
  Future<void> abandonSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    logSession.info('Abandoning session: ${currentSession.id}');

    _syncEngine.stopSyncTimer();

    try {
      final request = AbandonSessionRequest()..id = currentSession.id;
      await sessionClient.abandonSession(request);

      await SessionStorage.clearSession();

      state = const AsyncValue.data(null);

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
  Future<void> cleanup() async {
    logSession.fine('Cleanup initiated, forcing sync');
    if (_syncEngine.hasPendingChanges) {
      await _performSync();
    }
    _syncEngine.stopSyncTimer();
  }

  /// Clear current session
  void clearSession() {
    _syncEngine.stopSyncTimer();
    state = const AsyncValue.data(null);
  }

  /// Returns info about the completed set's rest duration and next set info
  ({int restDurationSeconds, String nextExerciseName, int nextSetNumber})?
      getSetCompletionInfo(String completedSetId) {
    final session = state.value;
    if (session == null) return null;
    return RestTimerCalculator.getSetCompletionInfo(session, completedSetId);
  }

  /// Returns section rest item info when completing a set finishes all sets of an exercise.
  ({int restDurationSeconds, String nextExerciseName, int nextSetNumber})?
      getExerciseCompletionRestInfo(String completedSetId) {
    final session = state.value;
    if (session == null) return null;
    return RestTimerCalculator.getExerciseCompletionRestInfo(session, completedSetId);
  }

  /// Returns rest info when completing a set finishes a superset round.
  ({int restDurationSeconds, String nextExerciseName, int nextSetNumber})?
      getSupersetRoundCompletionInfo(String completedSetId) {
    final session = state.value;
    if (session == null) return null;
    return RestTimerCalculator.getSupersetRoundCompletionInfo(session, completedSetId);
  }
}

/// Provider for checking if there's an in-progress session (with backup recovery)
@riverpod
Future<SessionModel?> hasActiveSession(Ref ref) async {
  final hasBackup = await SessionStorage.hasBackup();

  final request = ListSessionsRequest()
    ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS;

  final response = await sessionClient.listSessions(request);

  if (response.sessions.isEmpty) {
    if (hasBackup) {
      final backup = await SessionStorage.loadSession();
      return backup != null ? SessionModel.fromProto(backup) : null;
    }
    return null;
  }

  final getRequest = GetSessionRequest()..id = response.sessions.first.id;
  final sessionResponse = await sessionClient.getSession(getRequest);
  return SessionModel.fromProto(sessionResponse.session);
}
