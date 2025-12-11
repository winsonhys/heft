//
//  Generated code. Do not modify.
//  source: progress.proto
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

import 'progress.pb.dart' as $5;
import 'progress.pbjson.dart';

export 'progress.pb.dart';

abstract class ProgressServiceBase extends $pb.GeneratedService {
  $async.Future<$5.GetDashboardStatsResponse> getDashboardStats($pb.ServerContext ctx, $5.GetDashboardStatsRequest request);
  $async.Future<$5.GetWeeklyActivityResponse> getWeeklyActivity($pb.ServerContext ctx, $5.GetWeeklyActivityRequest request);
  $async.Future<$5.GetPersonalRecordsResponse> getPersonalRecords($pb.ServerContext ctx, $5.GetPersonalRecordsRequest request);
  $async.Future<$5.GetExerciseProgressResponse> getExerciseProgress($pb.ServerContext ctx, $5.GetExerciseProgressRequest request);
  $async.Future<$5.GetCalendarMonthResponse> getCalendarMonth($pb.ServerContext ctx, $5.GetCalendarMonthRequest request);
  $async.Future<$5.GetStreakResponse> getStreak($pb.ServerContext ctx, $5.GetStreakRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetDashboardStats': return $5.GetDashboardStatsRequest();
      case 'GetWeeklyActivity': return $5.GetWeeklyActivityRequest();
      case 'GetPersonalRecords': return $5.GetPersonalRecordsRequest();
      case 'GetExerciseProgress': return $5.GetExerciseProgressRequest();
      case 'GetCalendarMonth': return $5.GetCalendarMonthRequest();
      case 'GetStreak': return $5.GetStreakRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetDashboardStats': return this.getDashboardStats(ctx, request as $5.GetDashboardStatsRequest);
      case 'GetWeeklyActivity': return this.getWeeklyActivity(ctx, request as $5.GetWeeklyActivityRequest);
      case 'GetPersonalRecords': return this.getPersonalRecords(ctx, request as $5.GetPersonalRecordsRequest);
      case 'GetExerciseProgress': return this.getExerciseProgress(ctx, request as $5.GetExerciseProgressRequest);
      case 'GetCalendarMonth': return this.getCalendarMonth(ctx, request as $5.GetCalendarMonthRequest);
      case 'GetStreak': return this.getStreak(ctx, request as $5.GetStreakRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ProgressServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ProgressServiceBase$messageJson;
}

