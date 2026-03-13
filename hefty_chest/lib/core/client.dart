// Platform-specific HTTP client (native uses HTTP/2, web uses fetch API)
import 'http.dart'
    if (dart.library.io) 'http_io.dart'
    if (dart.library.js_interop) 'http_web.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as protocol;

import 'config.dart';
import '../gen/auth.connect.client.dart';
import '../gen/user.connect.client.dart';
import '../gen/workout.connect.client.dart';
import '../gen/session.connect.client.dart';
import '../gen/progress.connect.client.dart';
import '../gen/exercise.connect.client.dart';
import '../gen/program.connect.client.dart';

// Re-export the generated protobuf types for convenience
export '../gen/auth.pb.dart';
export '../gen/user.pb.dart';
export '../gen/workout.pb.dart';
export '../gen/session.pb.dart';
export '../gen/progress.pb.dart';
export '../gen/exercise.pb.dart';
export '../gen/program.pb.dart';
export '../gen/common.pb.dart';
export '../gen/common.pbenum.dart';

/// Token provider function type
typedef TokenProvider = String? Function();

/// Global token provider - set by auth provider
TokenProvider? _tokenProvider;

/// Set the token provider function
void setTokenProvider(TokenProvider provider) {
  _tokenProvider = provider;
}

/// Auth interceptor that adds JWT token to requests
Interceptor authInterceptor = <I extends Object, O extends Object>(next) {
  return (req) async {
    final token = _tokenProvider?.call();
    if (token != null) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    return next(req);
  };
};


/// Creates the Connect transport for RPC calls
/// Using JsonCodec instead of ProtoCodec for better web compatibility
/// (ProtoCodec has issues parsing nested Timestamp fields on Flutter web)
protocol.Transport createTransport() {
  return protocol.Transport(
    baseUrl: AppConfig.backendUrl,
    codec: const JsonCodec(),
    httpClient: createHttpClient(),
    interceptors: [authInterceptor],
  );
}

/// Global transport instance
Transport _transport = createTransport();

/// Service clients - use these to make RPC calls
AuthServiceClient authClient = AuthServiceClient(_transport);
UserServiceClient userClient = UserServiceClient(_transport);
WorkoutServiceClient workoutClient = WorkoutServiceClient(_transport);
SessionServiceClient sessionClient = SessionServiceClient(_transport);
ProgressServiceClient progressClient = ProgressServiceClient(_transport);
ExerciseServiceClient exerciseClient = ExerciseServiceClient(_transport);
ProgramServiceClient programClient = ProgramServiceClient(_transport);

/// Replace all clients with a test transport (for use in tests only)
void useTestTransport(Transport transport) {
  _transport = transport;
  authClient = AuthServiceClient(transport);
  userClient = UserServiceClient(transport);
  workoutClient = WorkoutServiceClient(transport);
  sessionClient = SessionServiceClient(transport);
  progressClient = ProgressServiceClient(transport);
  exerciseClient = ExerciseServiceClient(transport);
  programClient = ProgramServiceClient(transport);
}

/// Reset clients back to the real transport (for use in tests only)
void resetTransport() {
  _transport = createTransport();
  authClient = AuthServiceClient(_transport);
  userClient = UserServiceClient(_transport);
  workoutClient = WorkoutServiceClient(_transport);
  sessionClient = SessionServiceClient(_transport);
  progressClient = ProgressServiceClient(_transport);
  exerciseClient = ExerciseServiceClient(_transport);
  programClient = ProgramServiceClient(_transport);
}
