import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../tracker/models/session_models.dart';

part 'history_providers.g.dart';

/// Provider for fetching completed workout sessions
@riverpod
Future<List<SessionSummary>> sessionHistory(Ref ref) async {
  final request = ListSessionsRequest()
    ..status = WorkoutStatus.WORKOUT_STATUS_COMPLETED
    ..pagination = (PaginationRequest()..pageSize = 50);

  final response = await sessionClient.listSessions(request);
  return response.sessions;
}

/// Provider for fetching full session details
@riverpod
Future<SessionModel> sessionDetail(Ref ref, String sessionId) async {
  final request = GetSessionRequest()..id = sessionId;
  final response = await sessionClient.getSession(request);
  return SessionModel.fromProto(response.session);
}
