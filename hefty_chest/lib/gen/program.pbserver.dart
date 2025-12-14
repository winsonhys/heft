//
//  Generated code. Do not modify.
//  source: program.proto
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

import 'program.pb.dart' as $5;
import 'program.pbjson.dart';

export 'program.pb.dart';

abstract class ProgramServiceBase extends $pb.GeneratedService {
  $async.Future<$5.ListProgramsResponse> listPrograms($pb.ServerContext ctx, $5.ListProgramsRequest request);
  $async.Future<$5.GetProgramResponse> getProgram($pb.ServerContext ctx, $5.GetProgramRequest request);
  $async.Future<$5.CreateProgramResponse> createProgram($pb.ServerContext ctx, $5.CreateProgramRequest request);
  $async.Future<$5.UpdateProgramResponse> updateProgram($pb.ServerContext ctx, $5.UpdateProgramRequest request);
  $async.Future<$5.DeleteProgramResponse> deleteProgram($pb.ServerContext ctx, $5.DeleteProgramRequest request);
  $async.Future<$5.SetActiveProgramResponse> setActiveProgram($pb.ServerContext ctx, $5.SetActiveProgramRequest request);
  $async.Future<$5.GetTodayWorkoutResponse> getTodayWorkout($pb.ServerContext ctx, $5.GetTodayWorkoutRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListPrograms': return $5.ListProgramsRequest();
      case 'GetProgram': return $5.GetProgramRequest();
      case 'CreateProgram': return $5.CreateProgramRequest();
      case 'UpdateProgram': return $5.UpdateProgramRequest();
      case 'DeleteProgram': return $5.DeleteProgramRequest();
      case 'SetActiveProgram': return $5.SetActiveProgramRequest();
      case 'GetTodayWorkout': return $5.GetTodayWorkoutRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListPrograms': return this.listPrograms(ctx, request as $5.ListProgramsRequest);
      case 'GetProgram': return this.getProgram(ctx, request as $5.GetProgramRequest);
      case 'CreateProgram': return this.createProgram(ctx, request as $5.CreateProgramRequest);
      case 'UpdateProgram': return this.updateProgram(ctx, request as $5.UpdateProgramRequest);
      case 'DeleteProgram': return this.deleteProgram(ctx, request as $5.DeleteProgramRequest);
      case 'SetActiveProgram': return this.setActiveProgram(ctx, request as $5.SetActiveProgramRequest);
      case 'GetTodayWorkout': return this.getTodayWorkout(ctx, request as $5.GetTodayWorkoutRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ProgramServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ProgramServiceBase$messageJson;
}

