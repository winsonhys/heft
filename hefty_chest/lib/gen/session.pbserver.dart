//
//  Generated code. Do not modify.
//  source: session.proto
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

import 'session.pb.dart' as $6;
import 'session.pbjson.dart';

export 'session.pb.dart';

abstract class SessionServiceBase extends $pb.GeneratedService {
  $async.Future<$6.StartSessionResponse> startSession($pb.ServerContext ctx, $6.StartSessionRequest request);
  $async.Future<$6.GetSessionResponse> getSession($pb.ServerContext ctx, $6.GetSessionRequest request);
  $async.Future<$6.CompleteSetResponse> completeSet($pb.ServerContext ctx, $6.CompleteSetRequest request);
  $async.Future<$6.UpdateSetResponse> updateSet($pb.ServerContext ctx, $6.UpdateSetRequest request);
  $async.Future<$6.AddExerciseResponse> addExercise($pb.ServerContext ctx, $6.AddExerciseRequest request);
  $async.Future<$6.FinishSessionResponse> finishSession($pb.ServerContext ctx, $6.FinishSessionRequest request);
  $async.Future<$6.AbandonSessionResponse> abandonSession($pb.ServerContext ctx, $6.AbandonSessionRequest request);
  $async.Future<$6.ListSessionsResponse> listSessions($pb.ServerContext ctx, $6.ListSessionsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'StartSession': return $6.StartSessionRequest();
      case 'GetSession': return $6.GetSessionRequest();
      case 'CompleteSet': return $6.CompleteSetRequest();
      case 'UpdateSet': return $6.UpdateSetRequest();
      case 'AddExercise': return $6.AddExerciseRequest();
      case 'FinishSession': return $6.FinishSessionRequest();
      case 'AbandonSession': return $6.AbandonSessionRequest();
      case 'ListSessions': return $6.ListSessionsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'StartSession': return this.startSession(ctx, request as $6.StartSessionRequest);
      case 'GetSession': return this.getSession(ctx, request as $6.GetSessionRequest);
      case 'CompleteSet': return this.completeSet(ctx, request as $6.CompleteSetRequest);
      case 'UpdateSet': return this.updateSet(ctx, request as $6.UpdateSetRequest);
      case 'AddExercise': return this.addExercise(ctx, request as $6.AddExerciseRequest);
      case 'FinishSession': return this.finishSession(ctx, request as $6.FinishSessionRequest);
      case 'AbandonSession': return this.abandonSession(ctx, request as $6.AbandonSessionRequest);
      case 'ListSessions': return this.listSessions(ctx, request as $6.ListSessionsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SessionServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => SessionServiceBase$messageJson;
}

