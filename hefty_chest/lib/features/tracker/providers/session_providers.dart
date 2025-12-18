import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../../core/session_storage.dart';
import '../../home/providers/home_providers.dart';
import '../../progress/providers/progress_providers.dart';

part 'session_providers.g.dart';

/// Sync status for UI indication
enum SyncStatus { synced, syncing, pending, error }

/// Active session notifier with periodic sync
@riverpod
class ActiveSession extends _$ActiveSession {
  Timer? _syncTimer;
  bool _hasPendingChanges = false;
  SyncStatus _syncStatus = SyncStatus.synced;

  @override
  AsyncValue<Session?> build() {
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
      // Build sync request with all sets
      final sets = <SyncSetData>[];
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          final syncSet = SyncSetData()
            ..setId = set.id
            ..isCompleted = set.isCompleted;

          if (set.hasWeightKg()) {
            syncSet.weightKg = set.weightKg;
          }
          if (set.hasReps()) {
            syncSet.reps = set.reps;
          }
          if (set.hasTimeSeconds()) {
            syncSet.timeSeconds = set.timeSeconds;
          }
          if (set.hasDistanceM()) {
            syncSet.distanceM = set.distanceM;
          }
          if (set.hasRpe()) {
            syncSet.rpe = set.rpe;
          }
          if (set.notes.isNotEmpty) {
            syncSet.notes = set.notes;
          }

          sets.add(syncSet);
        }
      }

      final request = SyncSessionRequest()
        ..sessionId = session.id
        ..sets.addAll(sets);

      await sessionClient.syncSession(request);

      _hasPendingChanges = false;
      _syncStatus = SyncStatus.synced;

      // Update local backup
      await SessionStorage.saveSession(session);
    } catch (e) {
      _syncStatus = SyncStatus.error;
      // Keep _hasPendingChanges = true so we retry on next tick
    }
  }

  /// Start a new session from a workout template
  Future<Session?> startSession({required String workoutTemplateId}) async {
    try {
      state = const AsyncValue.loading();

      final request = StartSessionRequest()
        ..workoutTemplateId = workoutTemplateId;

      final response = await sessionClient.startSession(request);
      state = AsyncValue.data(response.session);

      // Save backup and start sync timer
      await SessionStorage.saveSession(response.session);
      _startSyncTimer();

      // Refresh active session provider so floating widget updates immediately
      await ref.refresh(hasActiveSessionProvider.future);

      return response.session;
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) return null;
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Load an existing session (or recover from backup)
  Future<Session?> loadSession({required String sessionId}) async {
    try {
      state = const AsyncValue.loading();

      final request = GetSessionRequest()..id = sessionId;
      final response = await sessionClient.getSession(request);
      state = AsyncValue.data(response.session);

      // Save backup and start sync timer
      await SessionStorage.saveSession(response.session);
      _startSyncTimer();

      return response.session;
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) return null;
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Recover session from local backup
  Future<Session?> recoverFromBackup() async {
    try {
      final backup = await SessionStorage.loadSession();
      if (backup == null) return null;

      // Verify session still exists on server
      final request = GetSessionRequest()..id = backup.id;
      try {
        final response = await sessionClient.getSession(request);

        // Server has data - use server version
        state = AsyncValue.data(response.session);
        await SessionStorage.saveSession(response.session);
        _startSyncTimer();
        return response.session;
      } catch (e) {
        // Server error - use backup as fallback
        state = AsyncValue.data(backup);
        _hasPendingChanges = true;
        _startSyncTimer();
        return backup;
      }
    } catch (e) {
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

    // Find and update the set in-place
    bool found = false;
    int completedDelta = 0;

    for (final exercise in currentSession.exercises) {
      for (var i = 0; i < exercise.sets.length; i++) {
        if (exercise.sets[i].id == sessionSetId) {
          final oldCompleted = exercise.sets[i].isCompleted;

          if (weightKg != null) exercise.sets[i].weightKg = weightKg;
          if (reps != null) exercise.sets[i].reps = reps;
          if (timeSeconds != null) exercise.sets[i].timeSeconds = timeSeconds;
          if (isCompleted != null) exercise.sets[i].isCompleted = isCompleted;

          // Track completion change
          if (isCompleted != null) {
            if (isCompleted && !oldCompleted) completedDelta = 1;
            if (!isCompleted && oldCompleted) completedDelta = -1;
          }

          found = true;
          break;
        }
      }
      if (found) break;
    }

    if (found) {
      // Update completed count
      currentSession.completedSets =
          (currentSession.completedSets + completedDelta)
              .clamp(0, currentSession.totalSets);

      // Mark changes and update state
      _hasPendingChanges = true;
      _syncStatus = SyncStatus.pending;
      state = AsyncValue.data(currentSession);

      // Save to local backup immediately
      SessionStorage.saveSession(currentSession);
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
      await ref.refresh(hasActiveSessionProvider.future);
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) return;
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
      await ref.refresh(hasActiveSessionProvider.future);
    } catch (e, st) {
      if (e.toString().contains('disposed') ||
          e.toString().contains('UnmountedRefException')) return;
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
Future<Session?> hasActiveSession(Ref ref) async {
  // First check for local backup
  final hasBackup = await SessionStorage.hasBackup();

  // Then check server for active session
  final request = ListSessionsRequest()
    ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS;

  final response = await sessionClient.listSessions(request);

  if (response.sessions.isEmpty) {
    // No server session - check if we have a backup to recover
    if (hasBackup) {
      return await SessionStorage.loadSession();
    }
    return null;
  }

  // Load the full session from server
  final getRequest = GetSessionRequest()..id = response.sessions.first.id;
  final sessionResponse = await sessionClient.getSession(getRequest);
  return sessionResponse.session;
}
