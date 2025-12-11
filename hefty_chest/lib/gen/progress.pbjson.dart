//
//  Generated code. Do not modify.
//  source: progress.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use dashboardStatsDescriptor instead')
const DashboardStats$json = {
  '1': 'DashboardStats',
  '2': [
    {'1': 'total_workouts', '3': 1, '4': 1, '5': 5, '10': 'totalWorkouts'},
    {'1': 'workouts_this_week', '3': 2, '4': 1, '5': 5, '10': 'workoutsThisWeek'},
    {'1': 'current_streak', '3': 3, '4': 1, '5': 5, '10': 'currentStreak'},
    {'1': 'total_volume_kg', '3': 4, '4': 1, '5': 5, '10': 'totalVolumeKg'},
    {'1': 'days_active', '3': 5, '4': 1, '5': 5, '10': 'daysActive'},
  ],
};

/// Descriptor for `DashboardStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardStatsDescriptor = $convert.base64Decode(
    'Cg5EYXNoYm9hcmRTdGF0cxIlCg50b3RhbF93b3Jrb3V0cxgBIAEoBVINdG90YWxXb3Jrb3V0cx'
    'IsChJ3b3Jrb3V0c190aGlzX3dlZWsYAiABKAVSEHdvcmtvdXRzVGhpc1dlZWsSJQoOY3VycmVu'
    'dF9zdHJlYWsYAyABKAVSDWN1cnJlbnRTdHJlYWsSJgoPdG90YWxfdm9sdW1lX2tnGAQgASgFUg'
    '10b3RhbFZvbHVtZUtnEh8KC2RheXNfYWN0aXZlGAUgASgFUgpkYXlzQWN0aXZl');

@$core.Deprecated('Use weeklyActivityDayDescriptor instead')
const WeeklyActivityDay$json = {
  '1': 'WeeklyActivityDay',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'day_of_week', '3': 2, '4': 1, '5': 9, '10': 'dayOfWeek'},
    {'1': 'workout_count', '3': 3, '4': 1, '5': 5, '10': 'workoutCount'},
    {'1': 'is_today', '3': 4, '4': 1, '5': 8, '10': 'isToday'},
  ],
};

/// Descriptor for `WeeklyActivityDay`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List weeklyActivityDayDescriptor = $convert.base64Decode(
    'ChFXZWVrbHlBY3Rpdml0eURheRISCgRkYXRlGAEgASgJUgRkYXRlEh4KC2RheV9vZl93ZWVrGA'
    'IgASgJUglkYXlPZldlZWsSIwoNd29ya291dF9jb3VudBgDIAEoBVIMd29ya291dENvdW50EhkK'
    'CGlzX3RvZGF5GAQgASgIUgdpc1RvZGF5');

@$core.Deprecated('Use personalRecordDescriptor instead')
const PersonalRecord$json = {
  '1': 'PersonalRecord',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'exercise_id', '3': 3, '4': 1, '5': 9, '10': 'exerciseId'},
    {'1': 'exercise_name', '3': 4, '4': 1, '5': 9, '10': 'exerciseName'},
    {'1': 'weight_kg', '3': 5, '4': 1, '5': 1, '10': 'weightKg'},
    {'1': 'reps', '3': 6, '4': 1, '5': 5, '10': 'reps'},
    {'1': 'time_seconds', '3': 7, '4': 1, '5': 5, '10': 'timeSeconds'},
    {'1': 'one_rep_max_kg', '3': 8, '4': 1, '5': 1, '10': 'oneRepMaxKg'},
    {'1': 'volume', '3': 9, '4': 1, '5': 1, '10': 'volume'},
    {'1': 'achieved_at', '3': 10, '4': 1, '5': 9, '10': 'achievedAt'},
  ],
};

/// Descriptor for `PersonalRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List personalRecordDescriptor = $convert.base64Decode(
    'Cg5QZXJzb25hbFJlY29yZBIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlck'
    'lkEh8KC2V4ZXJjaXNlX2lkGAMgASgJUgpleGVyY2lzZUlkEiMKDWV4ZXJjaXNlX25hbWUYBCAB'
    'KAlSDGV4ZXJjaXNlTmFtZRIbCgl3ZWlnaHRfa2cYBSABKAFSCHdlaWdodEtnEhIKBHJlcHMYBi'
    'ABKAVSBHJlcHMSIQoMdGltZV9zZWNvbmRzGAcgASgFUgt0aW1lU2Vjb25kcxIjCg5vbmVfcmVw'
    'X21heF9rZxgIIAEoAVILb25lUmVwTWF4S2cSFgoGdm9sdW1lGAkgASgBUgZ2b2x1bWUSHwoLYW'
    'NoaWV2ZWRfYXQYCiABKAlSCmFjaGlldmVkQXQ=');

@$core.Deprecated('Use exerciseProgressPointDescriptor instead')
const ExerciseProgressPoint$json = {
  '1': 'ExerciseProgressPoint',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'best_weight_kg', '3': 2, '4': 1, '5': 1, '10': 'bestWeightKg'},
    {'1': 'best_reps', '3': 3, '4': 1, '5': 5, '10': 'bestReps'},
    {'1': 'best_time_seconds', '3': 4, '4': 1, '5': 5, '10': 'bestTimeSeconds'},
    {'1': 'total_volume_kg', '3': 5, '4': 1, '5': 1, '10': 'totalVolumeKg'},
    {'1': 'total_sets', '3': 6, '4': 1, '5': 5, '10': 'totalSets'},
  ],
};

/// Descriptor for `ExerciseProgressPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exerciseProgressPointDescriptor = $convert.base64Decode(
    'ChVFeGVyY2lzZVByb2dyZXNzUG9pbnQSEgoEZGF0ZRgBIAEoCVIEZGF0ZRIkCg5iZXN0X3dlaW'
    'dodF9rZxgCIAEoAVIMYmVzdFdlaWdodEtnEhsKCWJlc3RfcmVwcxgDIAEoBVIIYmVzdFJlcHMS'
    'KgoRYmVzdF90aW1lX3NlY29uZHMYBCABKAVSD2Jlc3RUaW1lU2Vjb25kcxImCg90b3RhbF92b2'
    'x1bWVfa2cYBSABKAFSDXRvdGFsVm9sdW1lS2cSHQoKdG90YWxfc2V0cxgGIAEoBVIJdG90YWxT'
    'ZXRz');

@$core.Deprecated('Use exerciseProgressSummaryDescriptor instead')
const ExerciseProgressSummary$json = {
  '1': 'ExerciseProgressSummary',
  '2': [
    {'1': 'exercise_id', '3': 1, '4': 1, '5': 9, '10': 'exerciseId'},
    {'1': 'exercise_name', '3': 2, '4': 1, '5': 9, '10': 'exerciseName'},
    {'1': 'exercise_type', '3': 3, '4': 1, '5': 14, '6': '.heft.v1.ExerciseType', '10': 'exerciseType'},
    {'1': 'starting_weight_kg', '3': 4, '4': 1, '5': 1, '10': 'startingWeightKg'},
    {'1': 'current_weight_kg', '3': 5, '4': 1, '5': 1, '10': 'currentWeightKg'},
    {'1': 'max_weight_kg', '3': 6, '4': 1, '5': 1, '10': 'maxWeightKg'},
    {'1': 'improvement_percent', '3': 7, '4': 1, '5': 1, '10': 'improvementPercent'},
    {'1': 'total_sessions', '3': 8, '4': 1, '5': 5, '10': 'totalSessions'},
    {'1': 'data_points', '3': 9, '4': 3, '5': 11, '6': '.heft.v1.ExerciseProgressPoint', '10': 'dataPoints'},
  ],
};

/// Descriptor for `ExerciseProgressSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exerciseProgressSummaryDescriptor = $convert.base64Decode(
    'ChdFeGVyY2lzZVByb2dyZXNzU3VtbWFyeRIfCgtleGVyY2lzZV9pZBgBIAEoCVIKZXhlcmNpc2'
    'VJZBIjCg1leGVyY2lzZV9uYW1lGAIgASgJUgxleGVyY2lzZU5hbWUSOgoNZXhlcmNpc2VfdHlw'
    'ZRgDIAEoDjIVLmhlZnQudjEuRXhlcmNpc2VUeXBlUgxleGVyY2lzZVR5cGUSLAoSc3RhcnRpbm'
    'dfd2VpZ2h0X2tnGAQgASgBUhBzdGFydGluZ1dlaWdodEtnEioKEWN1cnJlbnRfd2VpZ2h0X2tn'
    'GAUgASgBUg9jdXJyZW50V2VpZ2h0S2cSIgoNbWF4X3dlaWdodF9rZxgGIAEoAVILbWF4V2VpZ2'
    'h0S2cSLwoTaW1wcm92ZW1lbnRfcGVyY2VudBgHIAEoAVISaW1wcm92ZW1lbnRQZXJjZW50EiUK'
    'DnRvdGFsX3Nlc3Npb25zGAggASgFUg10b3RhbFNlc3Npb25zEj8KC2RhdGFfcG9pbnRzGAkgAy'
    'gLMh4uaGVmdC52MS5FeGVyY2lzZVByb2dyZXNzUG9pbnRSCmRhdGFQb2ludHM=');

@$core.Deprecated('Use calendarDayDescriptor instead')
const CalendarDay$json = {
  '1': 'CalendarDay',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'workout_count', '3': 2, '4': 1, '5': 5, '10': 'workoutCount'},
    {'1': 'has_scheduled', '3': 3, '4': 1, '5': 8, '10': 'hasScheduled'},
    {'1': 'is_rest_day', '3': 4, '4': 1, '5': 8, '10': 'isRestDay'},
    {'1': 'events', '3': 5, '4': 3, '5': 11, '6': '.heft.v1.CalendarEvent', '10': 'events'},
  ],
};

/// Descriptor for `CalendarDay`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarDayDescriptor = $convert.base64Decode(
    'CgtDYWxlbmRhckRheRISCgRkYXRlGAEgASgJUgRkYXRlEiMKDXdvcmtvdXRfY291bnQYAiABKA'
    'VSDHdvcmtvdXRDb3VudBIjCg1oYXNfc2NoZWR1bGVkGAMgASgIUgxoYXNTY2hlZHVsZWQSHgoL'
    'aXNfcmVzdF9kYXkYBCABKAhSCWlzUmVzdERheRIuCgZldmVudHMYBSADKAsyFi5oZWZ0LnYxLk'
    'NhbGVuZGFyRXZlbnRSBmV2ZW50cw==');

@$core.Deprecated('Use calendarEventDescriptor instead')
const CalendarEvent$json = {
  '1': 'CalendarEvent',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'is_completed', '3': 4, '4': 1, '5': 8, '10': 'isCompleted'},
    {'1': 'completed_at', '3': 5, '4': 1, '5': 9, '10': 'completedAt'},
    {'1': 'duration_seconds', '3': 6, '4': 1, '5': 5, '10': 'durationSeconds'},
  ],
};

/// Descriptor for `CalendarEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calendarEventDescriptor = $convert.base64Decode(
    'Cg1DYWxlbmRhckV2ZW50Eg4KAmlkGAEgASgJUgJpZBISCgR0eXBlGAIgASgJUgR0eXBlEhIKBG'
    '5hbWUYAyABKAlSBG5hbWUSIQoMaXNfY29tcGxldGVkGAQgASgIUgtpc0NvbXBsZXRlZBIhCgxj'
    'b21wbGV0ZWRfYXQYBSABKAlSC2NvbXBsZXRlZEF0EikKEGR1cmF0aW9uX3NlY29uZHMYBiABKA'
    'VSD2R1cmF0aW9uU2Vjb25kcw==');

@$core.Deprecated('Use getDashboardStatsRequestDescriptor instead')
const GetDashboardStatsRequest$json = {
  '1': 'GetDashboardStatsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetDashboardStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDashboardStatsRequestDescriptor = $convert.base64Decode(
    'ChhHZXREYXNoYm9hcmRTdGF0c1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklk');

@$core.Deprecated('Use getDashboardStatsResponseDescriptor instead')
const GetDashboardStatsResponse$json = {
  '1': 'GetDashboardStatsResponse',
  '2': [
    {'1': 'stats', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.DashboardStats', '10': 'stats'},
  ],
};

/// Descriptor for `GetDashboardStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDashboardStatsResponseDescriptor = $convert.base64Decode(
    'ChlHZXREYXNoYm9hcmRTdGF0c1Jlc3BvbnNlEi0KBXN0YXRzGAEgASgLMhcuaGVmdC52MS5EYX'
    'NoYm9hcmRTdGF0c1IFc3RhdHM=');

@$core.Deprecated('Use getWeeklyActivityRequestDescriptor instead')
const GetWeeklyActivityRequest$json = {
  '1': 'GetWeeklyActivityRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'week_start', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'weekStart', '17': true},
  ],
  '8': [
    {'1': '_week_start'},
  ],
};

/// Descriptor for `GetWeeklyActivityRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWeeklyActivityRequestDescriptor = $convert.base64Decode(
    'ChhHZXRXZWVrbHlBY3Rpdml0eVJlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEiIKCn'
    'dlZWtfc3RhcnQYAiABKAlIAFIJd2Vla1N0YXJ0iAEBQg0KC193ZWVrX3N0YXJ0');

@$core.Deprecated('Use getWeeklyActivityResponseDescriptor instead')
const GetWeeklyActivityResponse$json = {
  '1': 'GetWeeklyActivityResponse',
  '2': [
    {'1': 'days', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.WeeklyActivityDay', '10': 'days'},
    {'1': 'total_workouts', '3': 2, '4': 1, '5': 5, '10': 'totalWorkouts'},
  ],
};

/// Descriptor for `GetWeeklyActivityResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWeeklyActivityResponseDescriptor = $convert.base64Decode(
    'ChlHZXRXZWVrbHlBY3Rpdml0eVJlc3BvbnNlEi4KBGRheXMYASADKAsyGi5oZWZ0LnYxLldlZW'
    'tseUFjdGl2aXR5RGF5UgRkYXlzEiUKDnRvdGFsX3dvcmtvdXRzGAIgASgFUg10b3RhbFdvcmtv'
    'dXRz');

@$core.Deprecated('Use getPersonalRecordsRequestDescriptor instead')
const GetPersonalRecordsRequest$json = {
  '1': 'GetPersonalRecordsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '9': 0, '10': 'limit', '17': true},
    {'1': 'exercise_id', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'exerciseId', '17': true},
  ],
  '8': [
    {'1': '_limit'},
    {'1': '_exercise_id'},
  ],
};

/// Descriptor for `GetPersonalRecordsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPersonalRecordsRequestDescriptor = $convert.base64Decode(
    'ChlHZXRQZXJzb25hbFJlY29yZHNSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIZCg'
    'VsaW1pdBgCIAEoBUgAUgVsaW1pdIgBARIkCgtleGVyY2lzZV9pZBgDIAEoCUgBUgpleGVyY2lz'
    'ZUlkiAEBQggKBl9saW1pdEIOCgxfZXhlcmNpc2VfaWQ=');

@$core.Deprecated('Use getPersonalRecordsResponseDescriptor instead')
const GetPersonalRecordsResponse$json = {
  '1': 'GetPersonalRecordsResponse',
  '2': [
    {'1': 'records', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.PersonalRecord', '10': 'records'},
  ],
};

/// Descriptor for `GetPersonalRecordsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPersonalRecordsResponseDescriptor = $convert.base64Decode(
    'ChpHZXRQZXJzb25hbFJlY29yZHNSZXNwb25zZRIxCgdyZWNvcmRzGAEgAygLMhcuaGVmdC52MS'
    '5QZXJzb25hbFJlY29yZFIHcmVjb3Jkcw==');

@$core.Deprecated('Use getExerciseProgressRequestDescriptor instead')
const GetExerciseProgressRequest$json = {
  '1': 'GetExerciseProgressRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'exercise_id', '3': 2, '4': 1, '5': 9, '10': 'exerciseId'},
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '9': 0, '10': 'limit', '17': true},
  ],
  '8': [
    {'1': '_limit'},
  ],
};

/// Descriptor for `GetExerciseProgressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getExerciseProgressRequestDescriptor = $convert.base64Decode(
    'ChpHZXRFeGVyY2lzZVByb2dyZXNzUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSHw'
    'oLZXhlcmNpc2VfaWQYAiABKAlSCmV4ZXJjaXNlSWQSGQoFbGltaXQYAyABKAVIAFIFbGltaXSI'
    'AQFCCAoGX2xpbWl0');

@$core.Deprecated('Use getExerciseProgressResponseDescriptor instead')
const GetExerciseProgressResponse$json = {
  '1': 'GetExerciseProgressResponse',
  '2': [
    {'1': 'progress', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.ExerciseProgressSummary', '10': 'progress'},
  ],
};

/// Descriptor for `GetExerciseProgressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getExerciseProgressResponseDescriptor = $convert.base64Decode(
    'ChtHZXRFeGVyY2lzZVByb2dyZXNzUmVzcG9uc2USPAoIcHJvZ3Jlc3MYASABKAsyIC5oZWZ0Ln'
    'YxLkV4ZXJjaXNlUHJvZ3Jlc3NTdW1tYXJ5Ughwcm9ncmVzcw==');

@$core.Deprecated('Use getCalendarMonthRequestDescriptor instead')
const GetCalendarMonthRequest$json = {
  '1': 'GetCalendarMonthRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'year', '3': 2, '4': 1, '5': 5, '10': 'year'},
    {'1': 'month', '3': 3, '4': 1, '5': 5, '10': 'month'},
  ],
};

/// Descriptor for `GetCalendarMonthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCalendarMonthRequestDescriptor = $convert.base64Decode(
    'ChdHZXRDYWxlbmRhck1vbnRoUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSEgoEeW'
    'VhchgCIAEoBVIEeWVhchIUCgVtb250aBgDIAEoBVIFbW9udGg=');

@$core.Deprecated('Use getCalendarMonthResponseDescriptor instead')
const GetCalendarMonthResponse$json = {
  '1': 'GetCalendarMonthResponse',
  '2': [
    {'1': 'days', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.CalendarDay', '10': 'days'},
    {'1': 'total_workouts', '3': 2, '4': 1, '5': 5, '10': 'totalWorkouts'},
    {'1': 'total_rest_days', '3': 3, '4': 1, '5': 5, '10': 'totalRestDays'},
  ],
};

/// Descriptor for `GetCalendarMonthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCalendarMonthResponseDescriptor = $convert.base64Decode(
    'ChhHZXRDYWxlbmRhck1vbnRoUmVzcG9uc2USKAoEZGF5cxgBIAMoCzIULmhlZnQudjEuQ2FsZW'
    '5kYXJEYXlSBGRheXMSJQoOdG90YWxfd29ya291dHMYAiABKAVSDXRvdGFsV29ya291dHMSJgoP'
    'dG90YWxfcmVzdF9kYXlzGAMgASgFUg10b3RhbFJlc3REYXlz');

@$core.Deprecated('Use getStreakRequestDescriptor instead')
const GetStreakRequest$json = {
  '1': 'GetStreakRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetStreakRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStreakRequestDescriptor = $convert.base64Decode(
    'ChBHZXRTdHJlYWtSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use getStreakResponseDescriptor instead')
const GetStreakResponse$json = {
  '1': 'GetStreakResponse',
  '2': [
    {'1': 'current_streak', '3': 1, '4': 1, '5': 5, '10': 'currentStreak'},
    {'1': 'longest_streak', '3': 2, '4': 1, '5': 5, '10': 'longestStreak'},
    {'1': 'last_workout_date', '3': 3, '4': 1, '5': 9, '10': 'lastWorkoutDate'},
  ],
};

/// Descriptor for `GetStreakResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStreakResponseDescriptor = $convert.base64Decode(
    'ChFHZXRTdHJlYWtSZXNwb25zZRIlCg5jdXJyZW50X3N0cmVhaxgBIAEoBVINY3VycmVudFN0cm'
    'VhaxIlCg5sb25nZXN0X3N0cmVhaxgCIAEoBVINbG9uZ2VzdFN0cmVhaxIqChFsYXN0X3dvcmtv'
    'dXRfZGF0ZRgDIAEoCVIPbGFzdFdvcmtvdXREYXRl');

const $core.Map<$core.String, $core.dynamic> ProgressServiceBase$json = {
  '1': 'ProgressService',
  '2': [
    {'1': 'GetDashboardStats', '2': '.heft.v1.GetDashboardStatsRequest', '3': '.heft.v1.GetDashboardStatsResponse'},
    {'1': 'GetWeeklyActivity', '2': '.heft.v1.GetWeeklyActivityRequest', '3': '.heft.v1.GetWeeklyActivityResponse'},
    {'1': 'GetPersonalRecords', '2': '.heft.v1.GetPersonalRecordsRequest', '3': '.heft.v1.GetPersonalRecordsResponse'},
    {'1': 'GetExerciseProgress', '2': '.heft.v1.GetExerciseProgressRequest', '3': '.heft.v1.GetExerciseProgressResponse'},
    {'1': 'GetCalendarMonth', '2': '.heft.v1.GetCalendarMonthRequest', '3': '.heft.v1.GetCalendarMonthResponse'},
    {'1': 'GetStreak', '2': '.heft.v1.GetStreakRequest', '3': '.heft.v1.GetStreakResponse'},
  ],
};

@$core.Deprecated('Use progressServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ProgressServiceBase$messageJson = {
  '.heft.v1.GetDashboardStatsRequest': GetDashboardStatsRequest$json,
  '.heft.v1.GetDashboardStatsResponse': GetDashboardStatsResponse$json,
  '.heft.v1.DashboardStats': DashboardStats$json,
  '.heft.v1.GetWeeklyActivityRequest': GetWeeklyActivityRequest$json,
  '.heft.v1.GetWeeklyActivityResponse': GetWeeklyActivityResponse$json,
  '.heft.v1.WeeklyActivityDay': WeeklyActivityDay$json,
  '.heft.v1.GetPersonalRecordsRequest': GetPersonalRecordsRequest$json,
  '.heft.v1.GetPersonalRecordsResponse': GetPersonalRecordsResponse$json,
  '.heft.v1.PersonalRecord': PersonalRecord$json,
  '.heft.v1.GetExerciseProgressRequest': GetExerciseProgressRequest$json,
  '.heft.v1.GetExerciseProgressResponse': GetExerciseProgressResponse$json,
  '.heft.v1.ExerciseProgressSummary': ExerciseProgressSummary$json,
  '.heft.v1.ExerciseProgressPoint': ExerciseProgressPoint$json,
  '.heft.v1.GetCalendarMonthRequest': GetCalendarMonthRequest$json,
  '.heft.v1.GetCalendarMonthResponse': GetCalendarMonthResponse$json,
  '.heft.v1.CalendarDay': CalendarDay$json,
  '.heft.v1.CalendarEvent': CalendarEvent$json,
  '.heft.v1.GetStreakRequest': GetStreakRequest$json,
  '.heft.v1.GetStreakResponse': GetStreakResponse$json,
};

/// Descriptor for `ProgressService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List progressServiceDescriptor = $convert.base64Decode(
    'Cg9Qcm9ncmVzc1NlcnZpY2USWgoRR2V0RGFzaGJvYXJkU3RhdHMSIS5oZWZ0LnYxLkdldERhc2'
    'hib2FyZFN0YXRzUmVxdWVzdBoiLmhlZnQudjEuR2V0RGFzaGJvYXJkU3RhdHNSZXNwb25zZRJa'
    'ChFHZXRXZWVrbHlBY3Rpdml0eRIhLmhlZnQudjEuR2V0V2Vla2x5QWN0aXZpdHlSZXF1ZXN0Gi'
    'IuaGVmdC52MS5HZXRXZWVrbHlBY3Rpdml0eVJlc3BvbnNlEl0KEkdldFBlcnNvbmFsUmVjb3Jk'
    'cxIiLmhlZnQudjEuR2V0UGVyc29uYWxSZWNvcmRzUmVxdWVzdBojLmhlZnQudjEuR2V0UGVyc2'
    '9uYWxSZWNvcmRzUmVzcG9uc2USYAoTR2V0RXhlcmNpc2VQcm9ncmVzcxIjLmhlZnQudjEuR2V0'
    'RXhlcmNpc2VQcm9ncmVzc1JlcXVlc3QaJC5oZWZ0LnYxLkdldEV4ZXJjaXNlUHJvZ3Jlc3NSZX'
    'Nwb25zZRJXChBHZXRDYWxlbmRhck1vbnRoEiAuaGVmdC52MS5HZXRDYWxlbmRhck1vbnRoUmVx'
    'dWVzdBohLmhlZnQudjEuR2V0Q2FsZW5kYXJNb250aFJlc3BvbnNlEkIKCUdldFN0cmVhaxIZLm'
    'hlZnQudjEuR2V0U3RyZWFrUmVxdWVzdBoaLmhlZnQudjEuR2V0U3RyZWFrUmVzcG9uc2U=');

