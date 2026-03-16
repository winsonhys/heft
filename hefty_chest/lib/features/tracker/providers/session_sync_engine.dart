import 'dart:async';

import '../../../core/client.dart';
import '../../../core/logging.dart';
import '../../../core/session_storage.dart';
import '../models/session_models.dart';

/// Sync status for UI indication
enum SyncStatus { synced, syncing, pending, error }

/// Tracks a pending new exercise for sync
class PendingExercise {
  final String exerciseId;
  final int displayOrder;
  final String sectionName;
  final int numSets;
  final String? supersetId;

  PendingExercise({
    required this.exerciseId,
    required this.displayOrder,
    required this.sectionName,
    required this.numSets,
    this.supersetId,
  });
}

/// Manages sync infrastructure for the active session.
/// Owns the sync timer, pending change lists, and sync logic.
class SessionSyncEngine {
  Timer? _syncTimer;
  bool _hasPendingChanges = false;
  SyncStatus _syncStatus = SyncStatus.synced;
  final List<PendingExercise> _pendingExercises = [];
  final List<String> _deletedSetIds = [];
  final List<String> _deletedExerciseIds = [];
  final Set<String> _modifiedExerciseIds = {};
  final Set<String> _modifiedRestItemIds = {};

  /// Get current sync status
  SyncStatus get syncStatus => _syncStatus;

  /// Whether there are pending changes to sync
  bool get hasPendingChanges => _hasPendingChanges;

  /// Access to deleted set IDs (for local state management)
  List<String> get deletedSetIds => _deletedSetIds;

  /// Access to deleted exercise IDs (for local state management)
  List<String> get deletedExerciseIds => _deletedExerciseIds;

  /// Mark that there are pending changes
  void markChanged() {
    _hasPendingChanges = true;
    _syncStatus = SyncStatus.pending;
  }

  /// Add a pending exercise for sync
  void addPendingExercise(PendingExercise exercise) {
    _pendingExercises.add(exercise);
  }

  /// Track a set deletion for sync
  void addDeletedSetId(String id) {
    _deletedSetIds.add(id);
  }

  /// Track an exercise deletion for sync
  void addDeletedExerciseId(String id) {
    _deletedExerciseIds.add(id);
  }

  /// Track a modified exercise for sync
  void addModifiedExerciseId(String id) {
    _modifiedExerciseIds.add(id);
  }

  /// Track a modified rest item for sync
  void addModifiedRestItemId(String id) {
    _modifiedRestItemIds.add(id);
  }

  /// Start the periodic sync timer
  void startSyncTimer(Future<void> Function() onSync) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 2), (_) => onSync());
  }

  /// Stop the sync timer
  void stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Perform sync to server.
  /// Returns the updated session model on success, or null if no sync was needed/failed.
  Future<SessionModel?> performSync(SessionModel session) async {
    if (!_hasPendingChanges) return null;

    logSession.fine('Starting sync for session: ${session.id}');
    _syncStatus = SyncStatus.syncing;

    try {
      // Capture what we're syncing BEFORE the async call to avoid race conditions
      final syncedExercises = List<PendingExercise>.from(_pendingExercises);
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
            updateData.supersetId = '';
          }
          exercises.add(SyncExerciseData()..updateExercise = updateData);
        }
      }

      // Build sync request with all sets
      final sets = <SyncSetData>[];
      for (final exercise in session.exercises) {
        if (exercise.id.isEmpty) continue;

        for (final set in exercise.sets) {
          final syncSet = SyncSetData()
            ..isCompleted = set.isCompleted
            ..weightKg = set.weightKg
            ..reps = set.reps
            ..timeSeconds = set.timeSeconds
            ..distanceM = set.distanceM
            ..rpe = set.rpe;

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

      // Build rest items sync data
      final syncedRestItemIds = Set<String>.from(_modifiedRestItemIds);
      final restItems = <SyncRestItemData>[];
      for (final restItemId in syncedRestItemIds) {
        final restItem = session.restItems.firstWhere(
          (ri) => ri.id == restItemId,
          orElse: () => const SessionRestItemModel(id: '', displayOrder: 0, sectionName: '', restDurationSeconds: 0),
        );
        if (restItem.id.isNotEmpty) {
          restItems.add(SyncRestItemData()
            ..id = restItem.id
            ..isCompleted = restItem.isCompleted);
        }
      }

      final request = SyncSessionRequest()
        ..sessionId = session.id
        ..sets.addAll(sets)
        ..exercises.addAll(exercises)
        ..deletedSetIds.addAll(syncedDeletedSetIds)
        ..deletedExerciseIds.addAll(syncedDeletedExerciseIds)
        ..restItems.addAll(restItems);

      final response = await sessionClient.syncSession(request);

      // Only remove items that were successfully synced
      _pendingExercises.removeWhere((e) => syncedExercises.contains(e));
      _deletedSetIds.removeWhere((id) => syncedDeletedSetIds.contains(id));
      _deletedExerciseIds.removeWhere((id) => syncedDeletedExerciseIds.contains(id));
      _modifiedExerciseIds.removeWhere((id) => syncedModifiedExerciseIds.contains(id));
      _modifiedRestItemIds.removeWhere((id) => syncedRestItemIds.contains(id));

      // Update local state with server response
      var updatedSession = SessionModel.fromProto(response.session);

      // Re-apply any deletions that happened during the sync
      if (_deletedSetIds.isNotEmpty || _deletedExerciseIds.isNotEmpty) {
        updatedSession = applyPendingDeletions(updatedSession);
      }

      // Only mark as synced if no new changes accumulated during sync
      _hasPendingChanges = _pendingExercises.isNotEmpty ||
          _deletedSetIds.isNotEmpty ||
          _deletedExerciseIds.isNotEmpty ||
          _modifiedExerciseIds.isNotEmpty ||
          _modifiedRestItemIds.isNotEmpty;
      _syncStatus = _hasPendingChanges ? SyncStatus.pending : SyncStatus.synced;

      // Update local backup with current state
      await SessionStorage.saveSession(updatedSession.toProto());
      logSession.info('Sync completed for session: ${session.id}');

      return updatedSession;
    } catch (e, st) {
      logSession.severe('Sync failed for session: ${session.id}', e, st);
      _syncStatus = SyncStatus.error;
      // Keep _hasPendingChanges = true so we retry on next tick
      return null;
    }
  }

  /// Apply pending deletions to a session model.
  /// Used when server response doesn't reflect deletions made during sync.
  SessionModel applyPendingDeletions(SessionModel session) {
    return session.copyWith(
      exercises: session.exercises
          .where((e) => !_deletedExerciseIds.contains(e.id))
          .map((e) => e.copyWith(
                sets: e.sets.where((s) => !_deletedSetIds.contains(s.id)).toList(),
              ))
          .toList(),
    );
  }
}
