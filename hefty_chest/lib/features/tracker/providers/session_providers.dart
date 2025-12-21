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
      // Build sync request with all sets
      final sets = <SyncSetData>[];
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          final syncSet = SyncSetData()
            ..setId = set.id
            ..isCompleted = set.isCompleted
            ..weightKg = set.weightKg
            ..reps = set.reps
            ..timeSeconds = set.timeSeconds
            ..distanceM = set.distanceM
            ..rpe = set.rpe;

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

      // Update local backup (convert to protobuf for storage)
      await SessionStorage.saveSession(session.toProto());
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

  /// Recover session from local backup
  Future<SessionModel?> recoverFromBackup() async {
    try {
      final backup = await SessionStorage.loadSession();
      if (backup == null) return null;

      // Verify session still exists on server
      final request = GetSessionRequest()..id = backup.id;
      try {
        final response = await sessionClient.getSession(request);

        // Server has data - use server version
        final sessionModel = SessionModel.fromProto(response.session);
        state = AsyncValue.data(sessionModel);
        await SessionStorage.saveSession(response.session);
        _startSyncTimer();
        return sessionModel;
      } catch (e) {
        // Server error - use backup as fallback
        final backupModel = SessionModel.fromProto(backup);
        state = AsyncValue.data(backupModel);
        _hasPendingChanges = true;
        _startSyncTimer();
        return backupModel;
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
