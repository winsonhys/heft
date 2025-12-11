//
//  Generated code. Do not modify.
//  source: user.proto
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

import 'user.pb.dart' as $7;
import 'user.pbjson.dart';

export 'user.pb.dart';

abstract class UserServiceBase extends $pb.GeneratedService {
  $async.Future<$7.GetProfileResponse> getProfile($pb.ServerContext ctx, $7.GetProfileRequest request);
  $async.Future<$7.UpdateProfileResponse> updateProfile($pb.ServerContext ctx, $7.UpdateProfileRequest request);
  $async.Future<$7.UpdateSettingsResponse> updateSettings($pb.ServerContext ctx, $7.UpdateSettingsRequest request);
  $async.Future<$7.LogWeightResponse> logWeight($pb.ServerContext ctx, $7.LogWeightRequest request);
  $async.Future<$7.GetWeightHistoryResponse> getWeightHistory($pb.ServerContext ctx, $7.GetWeightHistoryRequest request);
  $async.Future<$7.DeleteWeightLogResponse> deleteWeightLog($pb.ServerContext ctx, $7.DeleteWeightLogRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetProfile': return $7.GetProfileRequest();
      case 'UpdateProfile': return $7.UpdateProfileRequest();
      case 'UpdateSettings': return $7.UpdateSettingsRequest();
      case 'LogWeight': return $7.LogWeightRequest();
      case 'GetWeightHistory': return $7.GetWeightHistoryRequest();
      case 'DeleteWeightLog': return $7.DeleteWeightLogRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetProfile': return this.getProfile(ctx, request as $7.GetProfileRequest);
      case 'UpdateProfile': return this.updateProfile(ctx, request as $7.UpdateProfileRequest);
      case 'UpdateSettings': return this.updateSettings(ctx, request as $7.UpdateSettingsRequest);
      case 'LogWeight': return this.logWeight(ctx, request as $7.LogWeightRequest);
      case 'GetWeightHistory': return this.getWeightHistory(ctx, request as $7.GetWeightHistoryRequest);
      case 'DeleteWeightLog': return this.deleteWeightLog(ctx, request as $7.DeleteWeightLogRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => UserServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => UserServiceBase$messageJson;
}

