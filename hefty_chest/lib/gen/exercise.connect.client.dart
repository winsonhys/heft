//
//  Generated code. Do not modify.
//  source: exercise.proto
//

import "package:connectrpc/connect.dart" as connect;
import "exercise.pb.dart" as exercise;
import "exercise.connect.spec.dart" as specs;

/// ExerciseService handles the exercise library
extension type ExerciseServiceClient (connect.Transport _transport) {
  /// List all exercises with optional filters
  Future<exercise.ListExercisesResponse> listExercises(
    exercise.ListExercisesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExerciseService.listExercises,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a single exercise by ID
  Future<exercise.GetExerciseResponse> getExercise(
    exercise.GetExerciseRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExerciseService.getExercise,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a custom exercise
  Future<exercise.CreateExerciseResponse> createExercise(
    exercise.CreateExerciseRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExerciseService.createExercise,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all exercise categories
  Future<exercise.ListCategoriesResponse> listCategories(
    exercise.ListCategoriesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExerciseService.listCategories,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Search exercises by name
  Future<exercise.SearchExercisesResponse> searchExercises(
    exercise.SearchExercisesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExerciseService.searchExercises,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
