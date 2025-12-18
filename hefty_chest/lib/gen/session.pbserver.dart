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

import 'session.pb.dart' as $7;
import 'session.pbjson.dart';

export 'session.pb.dart';

abstract class SessionServiceBase extends $pb.GeneratedService {
  $async.Future<$7.StartSessionResponse> startSession($pb.ServerContext ctx, $7.StartSessionRequest request);
  $async.Future<$7.GetSessionResponse> getSession($pb.ServerContext ctx, $7.GetSessionRequest request);
  $async.Future<$7.SyncSessionResponse> syncSession($pb.ServerContext ctx, $7.SyncSessionRequest request);
  $async.Future<$7.AddExerciseResponse> addExercise($pb.ServerContext ctx, $7.AddExerciseRequest request);
  $async.Future<$7.FinishSessionResponse> finishSession($pb.ServerContext ctx, $7.FinishSessionRequest request);
  $async.Future<$7.AbandonSessionResponse> abandonSession($pb.ServerContext ctx, $7.AbandonSessionRequest request);
  $async.Future<$7.ListSessionsResponse> listSessions($pb.ServerContext ctx, $7.ListSessionsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'StartSession': return $7.StartSessionRequest();
      case 'GetSession': return $7.GetSessionRequest();
      case 'SyncSession': return $7.SyncSessionRequest();
      case 'AddExercise': return $7.AddExerciseRequest();
      case 'FinishSession': return $7.FinishSessionRequest();
      case 'AbandonSession': return $7.AbandonSessionRequest();
      case 'ListSessions': return $7.ListSessionsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'StartSession': return this.startSession(ctx, request as $7.StartSessionRequest);
      case 'GetSession': return this.getSession(ctx, request as $7.GetSessionRequest);
      case 'SyncSession': return this.syncSession(ctx, request as $7.SyncSessionRequest);
      case 'AddExercise': return this.addExercise(ctx, request as $7.AddExerciseRequest);
      case 'FinishSession': return this.finishSession(ctx, request as $7.FinishSessionRequest);
      case 'AbandonSession': return this.abandonSession(ctx, request as $7.AbandonSessionRequest);
      case 'ListSessions': return this.listSessions(ctx, request as $7.ListSessionsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SessionServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => SessionServiceBase$messageJson;
}

