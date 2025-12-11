//
//  Generated code. Do not modify.
//  source: workout.proto
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

import 'workout.pb.dart' as $3;
import 'workout.pbjson.dart';

export 'workout.pb.dart';

abstract class WorkoutServiceBase extends $pb.GeneratedService {
  $async.Future<$3.ListWorkoutsResponse> listWorkouts($pb.ServerContext ctx, $3.ListWorkoutsRequest request);
  $async.Future<$3.GetWorkoutResponse> getWorkout($pb.ServerContext ctx, $3.GetWorkoutRequest request);
  $async.Future<$3.CreateWorkoutResponse> createWorkout($pb.ServerContext ctx, $3.CreateWorkoutRequest request);
  $async.Future<$3.UpdateWorkoutResponse> updateWorkout($pb.ServerContext ctx, $3.UpdateWorkoutRequest request);
  $async.Future<$3.DeleteWorkoutResponse> deleteWorkout($pb.ServerContext ctx, $3.DeleteWorkoutRequest request);
  $async.Future<$3.DuplicateWorkoutResponse> duplicateWorkout($pb.ServerContext ctx, $3.DuplicateWorkoutRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListWorkouts': return $3.ListWorkoutsRequest();
      case 'GetWorkout': return $3.GetWorkoutRequest();
      case 'CreateWorkout': return $3.CreateWorkoutRequest();
      case 'UpdateWorkout': return $3.UpdateWorkoutRequest();
      case 'DeleteWorkout': return $3.DeleteWorkoutRequest();
      case 'DuplicateWorkout': return $3.DuplicateWorkoutRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListWorkouts': return this.listWorkouts(ctx, request as $3.ListWorkoutsRequest);
      case 'GetWorkout': return this.getWorkout(ctx, request as $3.GetWorkoutRequest);
      case 'CreateWorkout': return this.createWorkout(ctx, request as $3.CreateWorkoutRequest);
      case 'UpdateWorkout': return this.updateWorkout(ctx, request as $3.UpdateWorkoutRequest);
      case 'DeleteWorkout': return this.deleteWorkout(ctx, request as $3.DeleteWorkoutRequest);
      case 'DuplicateWorkout': return this.duplicateWorkout(ctx, request as $3.DuplicateWorkoutRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WorkoutServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WorkoutServiceBase$messageJson;
}

