//
//  Generated code. Do not modify.
//  source: progress.proto
//

import "package:connectrpc/connect.dart" as connect;
import "progress.pb.dart" as progress;
import "progress.connect.spec.dart" as specs;

/// ProgressService handles analytics and progress tracking
extension type ProgressServiceClient (connect.Transport _transport) {
  /// Get dashboard stats
  Future<progress.GetDashboardStatsResponse> getDashboardStats(
    progress.GetDashboardStatsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProgressService.getDashboardStats,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get weekly activity data
  Future<progress.GetWeeklyActivityResponse> getWeeklyActivity(
    progress.GetWeeklyActivityRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProgressService.getWeeklyActivity,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get personal records
  Future<progress.GetPersonalRecordsResponse> getPersonalRecords(
    progress.GetPersonalRecordsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProgressService.getPersonalRecords,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get exercise progress over time
  Future<progress.GetExerciseProgressResponse> getExerciseProgress(
    progress.GetExerciseProgressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProgressService.getExerciseProgress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get calendar month data
  Future<progress.GetCalendarMonthResponse> getCalendarMonth(
    progress.GetCalendarMonthRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProgressService.getCalendarMonth,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get current streak
  Future<progress.GetStreakResponse> getStreak(
    progress.GetStreakRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ProgressService.getStreak,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
