import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/client.dart';
import '../../../core/config.dart';

/// Active session notifier
class ActiveSessionNotifier extends Notifier<AsyncValue<Session?>> {
  @override
  AsyncValue<Session?> build() => const AsyncValue.data(null);

  /// Start a new session from a workout template
  Future<Session?> startSession({required String workoutTemplateId}) async {
    try {
      state = const AsyncValue.loading();

      final request = StartSessionRequest()
        ..userId = AppConfig.hardcodedUserId
        ..workoutTemplateId = workoutTemplateId;

      final response = await sessionClient.startSession(request);
      state = AsyncValue.data(response.session);
      return response.session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Load an existing session
  Future<Session?> loadSession({required String sessionId}) async {
    try {
      state = const AsyncValue.loading();

      final request = GetSessionRequest()
        ..id = sessionId
        ..userId = AppConfig.hardcodedUserId;

      final response = await sessionClient.getSession(request);
      state = AsyncValue.data(response.session);
      return response.session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Complete a set
  Future<bool> completeSet({
    required String sessionSetId,
    double? weightKg,
    int? reps,
    int? timeSeconds,
  }) async {
    try {
      final request = CompleteSetRequest()
        ..sessionSetId = sessionSetId
        ..userId = AppConfig.hardcodedUserId;

      if (weightKg != null) {
        request.weightKg = weightKg;
      }
      if (reps != null) {
        request.reps = reps;
      }
      if (timeSeconds != null) {
        request.timeSeconds = timeSeconds;
      }

      final response = await sessionClient.completeSet(request);

      // Reload the full session to get updated state
      final currentSession = state.value;
      if (currentSession != null) {
        await loadSession(sessionId: currentSession.id);
      }

      return response.isPersonalRecord;
    } catch (e) {
      return false;
    }
  }

  /// Update a set without completing
  Future<void> updateSet({
    required String sessionSetId,
    double? weightKg,
    int? reps,
    int? timeSeconds,
  }) async {
    try {
      final request = UpdateSetRequest()
        ..sessionSetId = sessionSetId
        ..userId = AppConfig.hardcodedUserId;

      if (weightKg != null) {
        request.weightKg = weightKg;
      }
      if (reps != null) {
        request.reps = reps;
      }
      if (timeSeconds != null) {
        request.timeSeconds = timeSeconds;
      }

      await sessionClient.updateSet(request);

      // Reload the full session to get updated state
      final currentSession = state.value;
      if (currentSession != null) {
        await loadSession(sessionId: currentSession.id);
      }
    } catch (e) {
      // Ignore errors for now
    }
  }

  /// Finish the session
  Future<void> finishSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    try {
      final request = FinishSessionRequest()
        ..id = currentSession.id
        ..userId = AppConfig.hardcodedUserId;

      await sessionClient.finishSession(request);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Abandon the session
  Future<void> abandonSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    try {
      final request = AbandonSessionRequest()
        ..id = currentSession.id
        ..userId = AppConfig.hardcodedUserId;

      await sessionClient.abandonSession(request);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear current session
  void clearSession() {
    state = const AsyncValue.data(null);
  }
}

final activeSessionProvider =
    NotifierProvider<ActiveSessionNotifier, AsyncValue<Session?>>(
        ActiveSessionNotifier.new);

/// Provider for checking if there's an in-progress session
final hasActiveSessionProvider = FutureProvider<Session?>((ref) async {
  final request = ListSessionsRequest()
    ..userId = AppConfig.hardcodedUserId
    ..status = WorkoutStatus.WORKOUT_STATUS_IN_PROGRESS;

  final response = await sessionClient.listSessions(request);

  if (response.sessions.isEmpty) return null;

  // Load the full session
  final getRequest = GetSessionRequest()
    ..id = response.sessions.first.id
    ..userId = AppConfig.hardcodedUserId;

  final sessionResponse = await sessionClient.getSession(getRequest);
  return sessionResponse.session;
});
