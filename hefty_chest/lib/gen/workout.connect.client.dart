//
//  Generated code. Do not modify.
//  source: workout.proto
//

import "package:connectrpc/connect.dart" as connect;
import "workout.pb.dart" as workout;
import "workout.connect.spec.dart" as specs;

/// WorkoutService handles workout templates
extension type WorkoutServiceClient (connect.Transport _transport) {
  /// List all workout templates for a user
  Future<workout.ListWorkoutsResponse> listWorkouts(
    workout.ListWorkoutsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WorkoutService.listWorkouts,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a single workout template with full details
  Future<workout.GetWorkoutResponse> getWorkout(
    workout.GetWorkoutRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WorkoutService.getWorkout,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a new workout template
  Future<workout.CreateWorkoutResponse> createWorkout(
    workout.CreateWorkoutRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WorkoutService.createWorkout,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Update a workout template
  Future<workout.UpdateWorkoutResponse> updateWorkout(
    workout.UpdateWorkoutRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WorkoutService.updateWorkout,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Delete a workout template
  Future<workout.DeleteWorkoutResponse> deleteWorkout(
    workout.DeleteWorkoutRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WorkoutService.deleteWorkout,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Duplicate a workout template
  Future<workout.DuplicateWorkoutResponse> duplicateWorkout(
    workout.DuplicateWorkoutRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WorkoutService.duplicateWorkout,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
