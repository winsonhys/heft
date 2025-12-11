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

import 'program.pb.dart' as $4;
import 'program.pbjson.dart';

export 'program.pb.dart';

abstract class ProgramServiceBase extends $pb.GeneratedService {
  $async.Future<$4.ListProgramsResponse> listPrograms($pb.ServerContext ctx, $4.ListProgramsRequest request);
  $async.Future<$4.GetProgramResponse> getProgram($pb.ServerContext ctx, $4.GetProgramRequest request);
  $async.Future<$4.CreateProgramResponse> createProgram($pb.ServerContext ctx, $4.CreateProgramRequest request);
  $async.Future<$4.UpdateProgramResponse> updateProgram($pb.ServerContext ctx, $4.UpdateProgramRequest request);
  $async.Future<$4.DeleteProgramResponse> deleteProgram($pb.ServerContext ctx, $4.DeleteProgramRequest request);
  $async.Future<$4.SetActiveProgramResponse> setActiveProgram($pb.ServerContext ctx, $4.SetActiveProgramRequest request);
  $async.Future<$4.GetTodayWorkoutResponse> getTodayWorkout($pb.ServerContext ctx, $4.GetTodayWorkoutRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListPrograms': return $4.ListProgramsRequest();
      case 'GetProgram': return $4.GetProgramRequest();
      case 'CreateProgram': return $4.CreateProgramRequest();
      case 'UpdateProgram': return $4.UpdateProgramRequest();
      case 'DeleteProgram': return $4.DeleteProgramRequest();
      case 'SetActiveProgram': return $4.SetActiveProgramRequest();
      case 'GetTodayWorkout': return $4.GetTodayWorkoutRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListPrograms': return this.listPrograms(ctx, request as $4.ListProgramsRequest);
      case 'GetProgram': return this.getProgram(ctx, request as $4.GetProgramRequest);
      case 'CreateProgram': return this.createProgram(ctx, request as $4.CreateProgramRequest);
      case 'UpdateProgram': return this.updateProgram(ctx, request as $4.UpdateProgramRequest);
      case 'DeleteProgram': return this.deleteProgram(ctx, request as $4.DeleteProgramRequest);
      case 'SetActiveProgram': return this.setActiveProgram(ctx, request as $4.SetActiveProgramRequest);
      case 'GetTodayWorkout': return this.getTodayWorkout(ctx, request as $4.GetTodayWorkoutRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ProgramServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ProgramServiceBase$messageJson;
}

