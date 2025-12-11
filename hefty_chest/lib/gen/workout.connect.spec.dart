//
//  Generated code. Do not modify.
//  source: workout.proto
//

import "package:connectrpc/connect.dart" as connect;
import "workout.pb.dart" as workout;

/// WorkoutService handles workout templates
abstract final class WorkoutService {
  /// Fully-qualified name of the WorkoutService service.
  static const name = 'heft.v1.WorkoutService';

  /// List all workout templates for a user
  static const listWorkouts = connect.Spec(
    '/$name/ListWorkouts',
    connect.StreamType.unary,
    workout.ListWorkoutsRequest.new,
    workout.ListWorkoutsResponse.new,
  );

  /// Get a single workout template with full details
  static const getWorkout = connect.Spec(
    '/$name/GetWorkout',
    connect.StreamType.unary,
    workout.GetWorkoutRequest.new,
    workout.GetWorkoutResponse.new,
  );

  /// Create a new workout template
  static const createWorkout = connect.Spec(
    '/$name/CreateWorkout',
    connect.StreamType.unary,
    workout.CreateWorkoutRequest.new,
    workout.CreateWorkoutResponse.new,
  );

  /// Update a workout template
  static const updateWorkout = connect.Spec(
    '/$name/UpdateWorkout',
    connect.StreamType.unary,
    workout.UpdateWorkoutRequest.new,
    workout.UpdateWorkoutResponse.new,
  );

  /// Delete a workout template
  static const deleteWorkout = connect.Spec(
    '/$name/DeleteWorkout',
    connect.StreamType.unary,
    workout.DeleteWorkoutRequest.new,
    workout.DeleteWorkoutResponse.new,
  );

  /// Duplicate a workout template
  static const duplicateWorkout = connect.Spec(
    '/$name/DuplicateWorkout',
    connect.StreamType.unary,
    workout.DuplicateWorkoutRequest.new,
    workout.DuplicateWorkoutResponse.new,
  );
}
