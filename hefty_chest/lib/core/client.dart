import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as protocol;

import 'config.dart';
import '../gen/user.connect.client.dart';
import '../gen/workout.connect.client.dart';
import '../gen/session.connect.client.dart';
import '../gen/progress.connect.client.dart';
import '../gen/exercise.connect.client.dart';
import '../gen/program.connect.client.dart';

// Re-export the generated protobuf types for convenience
export '../gen/user.pb.dart';
export '../gen/workout.pb.dart';
export '../gen/session.pb.dart';
export '../gen/progress.pb.dart';
export '../gen/exercise.pb.dart';
export '../gen/program.pb.dart';
export '../gen/common.pb.dart';
export '../gen/common.pbenum.dart';

/// Creates the Connect transport for RPC calls
protocol.Transport createTransport() {
  return protocol.Transport(
    baseUrl: AppConfig.backendUrl,
    codec: const ProtoCodec(),
    httpClient: createHttpClient(),
  );
}

/// Global transport instance
final _transport = createTransport();

/// Service clients - use these to make RPC calls
final userClient = UserServiceClient(_transport);
final workoutClient = WorkoutServiceClient(_transport);
final sessionClient = SessionServiceClient(_transport);
final progressClient = ProgressServiceClient(_transport);
final exerciseClient = ExerciseServiceClient(_transport);
final programClient = ProgramServiceClient(_transport);
