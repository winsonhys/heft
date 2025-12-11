//
//  Generated code. Do not modify.
//  source: progress.proto
//

import "package:connectrpc/connect.dart" as connect;
import "progress.pb.dart" as progress;

/// ProgressService handles analytics and progress tracking
abstract final class ProgressService {
  /// Fully-qualified name of the ProgressService service.
  static const name = 'heft.v1.ProgressService';

  /// Get dashboard stats
  static const getDashboardStats = connect.Spec(
    '/$name/GetDashboardStats',
    connect.StreamType.unary,
    progress.GetDashboardStatsRequest.new,
    progress.GetDashboardStatsResponse.new,
  );

  /// Get weekly activity data
  static const getWeeklyActivity = connect.Spec(
    '/$name/GetWeeklyActivity',
    connect.StreamType.unary,
    progress.GetWeeklyActivityRequest.new,
    progress.GetWeeklyActivityResponse.new,
  );

  /// Get personal records
  static const getPersonalRecords = connect.Spec(
    '/$name/GetPersonalRecords',
    connect.StreamType.unary,
    progress.GetPersonalRecordsRequest.new,
    progress.GetPersonalRecordsResponse.new,
  );

  /// Get exercise progress over time
  static const getExerciseProgress = connect.Spec(
    '/$name/GetExerciseProgress',
    connect.StreamType.unary,
    progress.GetExerciseProgressRequest.new,
    progress.GetExerciseProgressResponse.new,
  );

  /// Get calendar month data
  static const getCalendarMonth = connect.Spec(
    '/$name/GetCalendarMonth',
    connect.StreamType.unary,
    progress.GetCalendarMonthRequest.new,
    progress.GetCalendarMonthResponse.new,
  );

  /// Get current streak
  static const getStreak = connect.Spec(
    '/$name/GetStreak',
    connect.StreamType.unary,
    progress.GetStreakRequest.new,
    progress.GetStreakResponse.new,
  );
}
