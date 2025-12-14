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

import 'workout.pb.dart' as $4;
import 'workout.pbjson.dart';

export 'workout.pb.dart';

abstract class WorkoutServiceBase extends $pb.GeneratedService {
  $async.Future<$4.ListWorkoutsResponse> listWorkouts($pb.ServerContext ctx, $4.ListWorkoutsRequest request);
  $async.Future<$4.GetWorkoutResponse> getWorkout($pb.ServerContext ctx, $4.GetWorkoutRequest request);
  $async.Future<$4.CreateWorkoutResponse> createWorkout($pb.ServerContext ctx, $4.CreateWorkoutRequest request);
  $async.Future<$4.UpdateWorkoutResponse> updateWorkout($pb.ServerContext ctx, $4.UpdateWorkoutRequest request);
  $async.Future<$4.DeleteWorkoutResponse> deleteWorkout($pb.ServerContext ctx, $4.DeleteWorkoutRequest request);
  $async.Future<$4.DuplicateWorkoutResponse> duplicateWorkout($pb.ServerContext ctx, $4.DuplicateWorkoutRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListWorkouts': return $4.ListWorkoutsRequest();
      case 'GetWorkout': return $4.GetWorkoutRequest();
      case 'CreateWorkout': return $4.CreateWorkoutRequest();
      case 'UpdateWorkout': return $4.UpdateWorkoutRequest();
      case 'DeleteWorkout': return $4.DeleteWorkoutRequest();
      case 'DuplicateWorkout': return $4.DuplicateWorkoutRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListWorkouts': return this.listWorkouts(ctx, request as $4.ListWorkoutsRequest);
      case 'GetWorkout': return this.getWorkout(ctx, request as $4.GetWorkoutRequest);
      case 'CreateWorkout': return this.createWorkout(ctx, request as $4.CreateWorkoutRequest);
      case 'UpdateWorkout': return this.updateWorkout(ctx, request as $4.UpdateWorkoutRequest);
      case 'DeleteWorkout': return this.deleteWorkout(ctx, request as $4.DeleteWorkoutRequest);
      case 'DuplicateWorkout': return this.duplicateWorkout(ctx, request as $4.DuplicateWorkoutRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WorkoutServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WorkoutServiceBase$messageJson;
}

