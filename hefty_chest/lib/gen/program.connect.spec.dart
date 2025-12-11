//
//  Generated code. Do not modify.
//  source: program.proto
//

import "package:connectrpc/connect.dart" as connect;
import "program.pb.dart" as program;

/// ProgramService handles training programs
abstract final class ProgramService {
  /// Fully-qualified name of the ProgramService service.
  static const name = 'heft.v1.ProgramService';

  /// List all programs for a user
  static const listPrograms = connect.Spec(
    '/$name/ListPrograms',
    connect.StreamType.unary,
    program.ListProgramsRequest.new,
    program.ListProgramsResponse.new,
  );

  /// Get a single program with full details
  static const getProgram = connect.Spec(
    '/$name/GetProgram',
    connect.StreamType.unary,
    program.GetProgramRequest.new,
    program.GetProgramResponse.new,
  );

  /// Create a new program
  static const createProgram = connect.Spec(
    '/$name/CreateProgram',
    connect.StreamType.unary,
    program.CreateProgramRequest.new,
    program.CreateProgramResponse.new,
  );

  /// Update a program
  static const updateProgram = connect.Spec(
    '/$name/UpdateProgram',
    connect.StreamType.unary,
    program.UpdateProgramRequest.new,
    program.UpdateProgramResponse.new,
  );

  /// Delete a program
  static const deleteProgram = connect.Spec(
    '/$name/DeleteProgram',
    connect.StreamType.unary,
    program.DeleteProgramRequest.new,
    program.DeleteProgramResponse.new,
  );

  /// Set a program as active (deactivates others)
  static const setActiveProgram = connect.Spec(
    '/$name/SetActiveProgram',
    connect.StreamType.unary,
    program.SetActiveProgramRequest.new,
    program.SetActiveProgramResponse.new,
  );

  /// Get today's workout based on active program
  static const getTodayWorkout = connect.Spec(
    '/$name/GetTodayWorkout',
    connect.StreamType.unary,
    program.GetTodayWorkoutRequest.new,
    program.GetTodayWorkoutResponse.new,
  );
}
