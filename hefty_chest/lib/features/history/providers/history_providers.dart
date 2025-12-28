import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';
import '../../tracker/models/session_models.dart';

part 'history_providers.g.dart';

/// Provider for fetching completed workout sessions
@riverpod
Future<List<SessionSummary>> sessionHistory(Ref ref) async {
  logHistory.fine('Fetching session history');
  final request = ListSessionsRequest()
    ..status = WorkoutStatus.WORKOUT_STATUS_COMPLETED
    ..pagination = (PaginationRequest()..pageSize = 50);

  final response = await sessionClient.listSessions(request);
  logHistory.fine('Fetched ${response.sessions.length} sessions');
  return response.sessions;
}

/// Provider for fetching full session details
@riverpod
Future<SessionModel> sessionDetail(Ref ref, String sessionId) async {
  logHistory.fine('Fetching session detail: $sessionId');
  final request = GetSessionRequest()..id = sessionId;
  final response = await sessionClient.getSession(request);
  logHistory.fine('Session detail fetched');
  return SessionModel.fromProto(response.session);
}
