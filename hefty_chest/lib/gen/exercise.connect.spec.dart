//
//  Generated code. Do not modify.
//  source: exercise.proto
//

import "package:connectrpc/connect.dart" as connect;
import "exercise.pb.dart" as exercise;

/// ExerciseService handles the exercise library
abstract final class ExerciseService {
  /// Fully-qualified name of the ExerciseService service.
  static const name = 'heft.v1.ExerciseService';

  /// List all exercises with optional filters
  static const listExercises = connect.Spec(
    '/$name/ListExercises',
    connect.StreamType.unary,
    exercise.ListExercisesRequest.new,
    exercise.ListExercisesResponse.new,
  );

  /// Get a single exercise by ID
  static const getExercise = connect.Spec(
    '/$name/GetExercise',
    connect.StreamType.unary,
    exercise.GetExerciseRequest.new,
    exercise.GetExerciseResponse.new,
  );

  /// Create a custom exercise
  static const createExercise = connect.Spec(
    '/$name/CreateExercise',
    connect.StreamType.unary,
    exercise.CreateExerciseRequest.new,
    exercise.CreateExerciseResponse.new,
  );

  /// List all exercise categories
  static const listCategories = connect.Spec(
    '/$name/ListCategories',
    connect.StreamType.unary,
    exercise.ListCategoriesRequest.new,
    exercise.ListCategoriesResponse.new,
  );

  /// Search exercises by name
  static const searchExercises = connect.Spec(
    '/$name/SearchExercises',
    connect.StreamType.unary,
    exercise.SearchExercisesRequest.new,
    exercise.SearchExercisesResponse.new,
  );
}
