//
//  Generated code. Do not modify.
//  source: session.proto
//

import "package:connectrpc/connect.dart" as connect;
import "session.pb.dart" as session;

/// SessionService handles live workout tracking
abstract final class SessionService {
  /// Fully-qualified name of the SessionService service.
  static const name = 'heft.v1.SessionService';

  /// Start a new workout session
  static const startSession = connect.Spec(
    '/$name/StartSession',
    connect.StreamType.unary,
    session.StartSessionRequest.new,
    session.StartSessionResponse.new,
  );

  /// Get session details
  static const getSession = connect.Spec(
    '/$name/GetSession',
    connect.StreamType.unary,
    session.GetSessionRequest.new,
    session.GetSessionResponse.new,
  );

  /// Sync full session state (periodic sync from client)
  static const syncSession = connect.Spec(
    '/$name/SyncSession',
    connect.StreamType.unary,
    session.SyncSessionRequest.new,
    session.SyncSessionResponse.new,
  );

  /// Finish the workout session
  static const finishSession = connect.Spec(
    '/$name/FinishSession',
    connect.StreamType.unary,
    session.FinishSessionRequest.new,
    session.FinishSessionResponse.new,
  );

  /// Abandon the workout session
  static const abandonSession = connect.Spec(
    '/$name/AbandonSession',
    connect.StreamType.unary,
    session.AbandonSessionRequest.new,
    session.AbandonSessionResponse.new,
  );

  /// List recent sessions
  static const listSessions = connect.Spec(
    '/$name/ListSessions',
    connect.StreamType.unary,
    session.ListSessionsRequest.new,
    session.ListSessionsResponse.new,
  );
}
