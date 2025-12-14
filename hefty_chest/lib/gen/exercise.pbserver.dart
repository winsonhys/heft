//
//  Generated code. Do not modify.
//  source: exercise.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'exercise.pb.dart' as $3;
import 'exercise.pbjson.dart';

export 'exercise.pb.dart';

abstract class ExerciseServiceBase extends $pb.GeneratedService {
  $async.Future<$3.ListExercisesResponse> listExercises($pb.ServerContext ctx, $3.ListExercisesRequest request);
  $async.Future<$3.GetExerciseResponse> getExercise($pb.ServerContext ctx, $3.GetExerciseRequest request);
  $async.Future<$3.CreateExerciseResponse> createExercise($pb.ServerContext ctx, $3.CreateExerciseRequest request);
  $async.Future<$3.ListCategoriesResponse> listCategories($pb.ServerContext ctx, $3.ListCategoriesRequest request);
  $async.Future<$3.SearchExercisesResponse> searchExercises($pb.ServerContext ctx, $3.SearchExercisesRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListExercises': return $3.ListExercisesRequest();
      case 'GetExercise': return $3.GetExerciseRequest();
      case 'CreateExercise': return $3.CreateExerciseRequest();
      case 'ListCategories': return $3.ListCategoriesRequest();
      case 'SearchExercises': return $3.SearchExercisesRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListExercises': return this.listExercises(ctx, request as $3.ListExercisesRequest);
      case 'GetExercise': return this.getExercise(ctx, request as $3.GetExerciseRequest);
      case 'CreateExercise': return this.createExercise(ctx, request as $3.CreateExerciseRequest);
      case 'ListCategories': return this.listCategories(ctx, request as $3.ListCategoriesRequest);
      case 'SearchExercises': return this.searchExercises(ctx, request as $3.SearchExercisesRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ExerciseServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ExerciseServiceBase$messageJson;
}

