//
//  Generated code. Do not modify.
//  source: progress.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pbenum.dart' as $2;

/// Dashboard stats
class DashboardStats extends $pb.GeneratedMessage {
  factory DashboardStats({
    $core.int? totalWorkouts,
    $core.int? workoutsThisWeek,
    $core.int? currentStreak,
    $core.int? totalVolumeKg,
    $core.int? daysActive,
  }) {
    final $result = create();
    if (totalWorkouts != null) {
      $result.totalWorkouts = totalWorkouts;
    }
    if (workoutsThisWeek != null) {
      $result.workoutsThisWeek = workoutsThisWeek;
    }
    if (currentStreak != null) {
      $result.currentStreak = currentStreak;
    }
    if (totalVolumeKg != null) {
      $result.totalVolumeKg = totalVolumeKg;
    }
    if (daysActive != null) {
      $result.daysActive = daysActive;
    }
    return $result;
  }
  DashboardStats._() : super();
  factory DashboardStats.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DashboardStats.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DashboardStats', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'totalWorkouts', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'workoutsThisWeek', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'currentStreak', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'totalVolumeKg', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'daysActive', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DashboardStats clone() => DashboardStats()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DashboardStats copyWith(void Function(DashboardStats) updates) => super.copyWith((message) => updates(message as DashboardStats)) as DashboardStats;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DashboardStats create() => DashboardStats._();
  DashboardStats createEmptyInstance() => create();
  static $pb.PbList<DashboardStats> createRepeated() => $pb.PbList<DashboardStats>();
  @$core.pragma('dart2js:noInline')
  static DashboardStats getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DashboardStats>(create);
  static DashboardStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalWorkouts => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalWorkouts($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTotalWorkouts() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalWorkouts() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get workoutsThisWeek => $_getIZ(1);
  @$pb.TagNumber(2)
  set workoutsThisWeek($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWorkoutsThisWeek() => $_has(1);
  @$pb.TagNumber(2)
  void clearWorkoutsThisWeek() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get currentStreak => $_getIZ(2);
  @$pb.TagNumber(3)
  set currentStreak($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCurrentStreak() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentStreak() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get totalVolumeKg => $_getIZ(3);
  @$pb.TagNumber(4)
  set totalVolumeKg($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTotalVolumeKg() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalVolumeKg() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get daysActive => $_getIZ(4);
  @$pb.TagNumber(5)
  set daysActive($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDaysActive() => $_has(4);
  @$pb.TagNumber(5)
  void clearDaysActive() => clearField(5);
}

/// Weekly activity day
class WeeklyActivityDay extends $pb.GeneratedMessage {
  factory WeeklyActivityDay({
    $core.String? date,
    $core.String? dayOfWeek,
    $core.int? workoutCount,
    $core.bool? isToday,
  }) {
    final $result = create();
    if (date != null) {
      $result.date = date;
    }
    if (dayOfWeek != null) {
      $result.dayOfWeek = dayOfWeek;
    }
    if (workoutCount != null) {
      $result.workoutCount = workoutCount;
    }
    if (isToday != null) {
      $result.isToday = isToday;
    }
    return $result;
  }
  WeeklyActivityDay._() : super();
  factory WeeklyActivityDay.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WeeklyActivityDay.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WeeklyActivityDay', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aOS(2, _omitFieldNames ? '' : 'dayOfWeek')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'workoutCount', $pb.PbFieldType.O3)
    ..aOB(4, _omitFieldNames ? '' : 'isToday')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WeeklyActivityDay clone() => WeeklyActivityDay()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WeeklyActivityDay copyWith(void Function(WeeklyActivityDay) updates) => super.copyWith((message) => updates(message as WeeklyActivityDay)) as WeeklyActivityDay;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WeeklyActivityDay create() => WeeklyActivityDay._();
  WeeklyActivityDay createEmptyInstance() => create();
  static $pb.PbList<WeeklyActivityDay> createRepeated() => $pb.PbList<WeeklyActivityDay>();
  @$core.pragma('dart2js:noInline')
  static WeeklyActivityDay getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WeeklyActivityDay>(create);
  static WeeklyActivityDay? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get dayOfWeek => $_getSZ(1);
  @$pb.TagNumber(2)
  set dayOfWeek($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDayOfWeek() => $_has(1);
  @$pb.TagNumber(2)
  void clearDayOfWeek() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get workoutCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set workoutCount($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWorkoutCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearWorkoutCount() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isToday => $_getBF(3);
  @$pb.TagNumber(4)
  set isToday($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsToday() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsToday() => clearField(4);
}

/// Personal record
class PersonalRecord extends $pb.GeneratedMessage {
  factory PersonalRecord({
    $core.String? id,
    $core.String? userId,
    $core.String? exerciseId,
    $core.String? exerciseName,
    $core.double? weightKg,
    $core.int? reps,
    $core.int? timeSeconds,
    $core.double? oneRepMaxKg,
    $core.double? volume,
    $core.String? achievedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (exerciseId != null) {
      $result.exerciseId = exerciseId;
    }
    if (exerciseName != null) {
      $result.exerciseName = exerciseName;
    }
    if (weightKg != null) {
      $result.weightKg = weightKg;
    }
    if (reps != null) {
      $result.reps = reps;
    }
    if (timeSeconds != null) {
      $result.timeSeconds = timeSeconds;
    }
    if (oneRepMaxKg != null) {
      $result.oneRepMaxKg = oneRepMaxKg;
    }
    if (volume != null) {
      $result.volume = volume;
    }
    if (achievedAt != null) {
      $result.achievedAt = achievedAt;
    }
    return $result;
  }
  PersonalRecord._() : super();
  factory PersonalRecord.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PersonalRecord.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PersonalRecord', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'exerciseId')
    ..aOS(4, _omitFieldNames ? '' : 'exerciseName')
    ..a<$core.double>(5, _omitFieldNames ? '' : 'weightKg', $pb.PbFieldType.OD)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'reps', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'timeSeconds', $pb.PbFieldType.O3)
    ..a<$core.double>(8, _omitFieldNames ? '' : 'oneRepMaxKg', $pb.PbFieldType.OD)
    ..a<$core.double>(9, _omitFieldNames ? '' : 'volume', $pb.PbFieldType.OD)
    ..aOS(10, _omitFieldNames ? '' : 'achievedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PersonalRecord clone() => PersonalRecord()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PersonalRecord copyWith(void Function(PersonalRecord) updates) => super.copyWith((message) => updates(message as PersonalRecord)) as PersonalRecord;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PersonalRecord create() => PersonalRecord._();
  PersonalRecord createEmptyInstance() => create();
  static $pb.PbList<PersonalRecord> createRepeated() => $pb.PbList<PersonalRecord>();
  @$core.pragma('dart2js:noInline')
  static PersonalRecord getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PersonalRecord>(create);
  static PersonalRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get exerciseId => $_getSZ(2);
  @$pb.TagNumber(3)
  set exerciseId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasExerciseId() => $_has(2);
  @$pb.TagNumber(3)
  void clearExerciseId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get exerciseName => $_getSZ(3);
  @$pb.TagNumber(4)
  set exerciseName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasExerciseName() => $_has(3);
  @$pb.TagNumber(4)
  void clearExerciseName() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get weightKg => $_getN(4);
  @$pb.TagNumber(5)
  set weightKg($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWeightKg() => $_has(4);
  @$pb.TagNumber(5)
  void clearWeightKg() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get reps => $_getIZ(5);
  @$pb.TagNumber(6)
  set reps($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasReps() => $_has(5);
  @$pb.TagNumber(6)
  void clearReps() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get timeSeconds => $_getIZ(6);
  @$pb.TagNumber(7)
  set timeSeconds($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTimeSeconds() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimeSeconds() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get oneRepMaxKg => $_getN(7);
  @$pb.TagNumber(8)
  set oneRepMaxKg($core.double v) { $_setDouble(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasOneRepMaxKg() => $_has(7);
  @$pb.TagNumber(8)
  void clearOneRepMaxKg() => clearField(8);

  @$pb.TagNumber(9)
  $core.double get volume => $_getN(8);
  @$pb.TagNumber(9)
  set volume($core.double v) { $_setDouble(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasVolume() => $_has(8);
  @$pb.TagNumber(9)
  void clearVolume() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get achievedAt => $_getSZ(9);
  @$pb.TagNumber(10)
  set achievedAt($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasAchievedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearAchievedAt() => clearField(10);
}

/// Exercise progress data point
class ExerciseProgressPoint extends $pb.GeneratedMessage {
  factory ExerciseProgressPoint({
    $core.String? date,
    $core.double? bestWeightKg,
    $core.int? bestReps,
    $core.int? bestTimeSeconds,
    $core.double? totalVolumeKg,
    $core.int? totalSets,
  }) {
    final $result = create();
    if (date != null) {
      $result.date = date;
    }
    if (bestWeightKg != null) {
      $result.bestWeightKg = bestWeightKg;
    }
    if (bestReps != null) {
      $result.bestReps = bestReps;
    }
    if (bestTimeSeconds != null) {
      $result.bestTimeSeconds = bestTimeSeconds;
    }
    if (totalVolumeKg != null) {
      $result.totalVolumeKg = totalVolumeKg;
    }
    if (totalSets != null) {
      $result.totalSets = totalSets;
    }
    return $result;
  }
  ExerciseProgressPoint._() : super();
  factory ExerciseProgressPoint.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExerciseProgressPoint.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExerciseProgressPoint', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'bestWeightKg', $pb.PbFieldType.OD)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'bestReps', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'bestTimeSeconds', $pb.PbFieldType.O3)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'totalVolumeKg', $pb.PbFieldType.OD)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'totalSets', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExerciseProgressPoint clone() => ExerciseProgressPoint()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExerciseProgressPoint copyWith(void Function(ExerciseProgressPoint) updates) => super.copyWith((message) => updates(message as ExerciseProgressPoint)) as ExerciseProgressPoint;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExerciseProgressPoint create() => ExerciseProgressPoint._();
  ExerciseProgressPoint createEmptyInstance() => create();
  static $pb.PbList<ExerciseProgressPoint> createRepeated() => $pb.PbList<ExerciseProgressPoint>();
  @$core.pragma('dart2js:noInline')
  static ExerciseProgressPoint getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExerciseProgressPoint>(create);
  static ExerciseProgressPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get bestWeightKg => $_getN(1);
  @$pb.TagNumber(2)
  set bestWeightKg($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBestWeightKg() => $_has(1);
  @$pb.TagNumber(2)
  void clearBestWeightKg() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get bestReps => $_getIZ(2);
  @$pb.TagNumber(3)
  set bestReps($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBestReps() => $_has(2);
  @$pb.TagNumber(3)
  void clearBestReps() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get bestTimeSeconds => $_getIZ(3);
  @$pb.TagNumber(4)
  set bestTimeSeconds($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBestTimeSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearBestTimeSeconds() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get totalVolumeKg => $_getN(4);
  @$pb.TagNumber(5)
  set totalVolumeKg($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalVolumeKg() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalVolumeKg() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get totalSets => $_getIZ(5);
  @$pb.TagNumber(6)
  set totalSets($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTotalSets() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalSets() => clearField(6);
}

/// Exercise progress summary
class ExerciseProgressSummary extends $pb.GeneratedMessage {
  factory ExerciseProgressSummary({
    $core.String? exerciseId,
    $core.String? exerciseName,
    $2.ExerciseType? exerciseType,
    $core.double? startingWeightKg,
    $core.double? currentWeightKg,
    $core.double? maxWeightKg,
    $core.double? improvementPercent,
    $core.int? totalSessions,
    $core.Iterable<ExerciseProgressPoint>? dataPoints,
  }) {
    final $result = create();
    if (exerciseId != null) {
      $result.exerciseId = exerciseId;
    }
    if (exerciseName != null) {
      $result.exerciseName = exerciseName;
    }
    if (exerciseType != null) {
      $result.exerciseType = exerciseType;
    }
    if (startingWeightKg != null) {
      $result.startingWeightKg = startingWeightKg;
    }
    if (currentWeightKg != null) {
      $result.currentWeightKg = currentWeightKg;
    }
    if (maxWeightKg != null) {
      $result.maxWeightKg = maxWeightKg;
    }
    if (improvementPercent != null) {
      $result.improvementPercent = improvementPercent;
    }
    if (totalSessions != null) {
      $result.totalSessions = totalSessions;
    }
    if (dataPoints != null) {
      $result.dataPoints.addAll(dataPoints);
    }
    return $result;
  }
  ExerciseProgressSummary._() : super();
  factory ExerciseProgressSummary.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExerciseProgressSummary.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExerciseProgressSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'exerciseId')
    ..aOS(2, _omitFieldNames ? '' : 'exerciseName')
    ..e<$2.ExerciseType>(3, _omitFieldNames ? '' : 'exerciseType', $pb.PbFieldType.OE, defaultOrMaker: $2.ExerciseType.EXERCISE_TYPE_UNSPECIFIED, valueOf: $2.ExerciseType.valueOf, enumValues: $2.ExerciseType.values)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'startingWeightKg', $pb.PbFieldType.OD)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'currentWeightKg', $pb.PbFieldType.OD)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'maxWeightKg', $pb.PbFieldType.OD)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'improvementPercent', $pb.PbFieldType.OD)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'totalSessions', $pb.PbFieldType.O3)
    ..pc<ExerciseProgressPoint>(9, _omitFieldNames ? '' : 'dataPoints', $pb.PbFieldType.PM, subBuilder: ExerciseProgressPoint.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExerciseProgressSummary clone() => ExerciseProgressSummary()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExerciseProgressSummary copyWith(void Function(ExerciseProgressSummary) updates) => super.copyWith((message) => updates(message as ExerciseProgressSummary)) as ExerciseProgressSummary;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExerciseProgressSummary create() => ExerciseProgressSummary._();
  ExerciseProgressSummary createEmptyInstance() => create();
  static $pb.PbList<ExerciseProgressSummary> createRepeated() => $pb.PbList<ExerciseProgressSummary>();
  @$core.pragma('dart2js:noInline')
  static ExerciseProgressSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExerciseProgressSummary>(create);
  static ExerciseProgressSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get exerciseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set exerciseId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasExerciseId() => $_has(0);
  @$pb.TagNumber(1)
  void clearExerciseId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get exerciseName => $_getSZ(1);
  @$pb.TagNumber(2)
  set exerciseName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasExerciseName() => $_has(1);
  @$pb.TagNumber(2)
  void clearExerciseName() => clearField(2);

  @$pb.TagNumber(3)
  $2.ExerciseType get exerciseType => $_getN(2);
  @$pb.TagNumber(3)
  set exerciseType($2.ExerciseType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasExerciseType() => $_has(2);
  @$pb.TagNumber(3)
  void clearExerciseType() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get startingWeightKg => $_getN(3);
  @$pb.TagNumber(4)
  set startingWeightKg($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStartingWeightKg() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartingWeightKg() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get currentWeightKg => $_getN(4);
  @$pb.TagNumber(5)
  set currentWeightKg($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCurrentWeightKg() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrentWeightKg() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get maxWeightKg => $_getN(5);
  @$pb.TagNumber(6)
  set maxWeightKg($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMaxWeightKg() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxWeightKg() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get improvementPercent => $_getN(6);
  @$pb.TagNumber(7)
  set improvementPercent($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasImprovementPercent() => $_has(6);
  @$pb.TagNumber(7)
  void clearImprovementPercent() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get totalSessions => $_getIZ(7);
  @$pb.TagNumber(8)
  set totalSessions($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalSessions() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalSessions() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<ExerciseProgressPoint> get dataPoints => $_getList(8);
}

/// Calendar day
class CalendarDay extends $pb.GeneratedMessage {
  factory CalendarDay({
    $core.String? date,
    $core.int? workoutCount,
    $core.bool? hasScheduled,
    $core.bool? isRestDay,
    $core.Iterable<CalendarEvent>? events,
  }) {
    final $result = create();
    if (date != null) {
      $result.date = date;
    }
    if (workoutCount != null) {
      $result.workoutCount = workoutCount;
    }
    if (hasScheduled != null) {
      $result.hasScheduled = hasScheduled;
    }
    if (isRestDay != null) {
      $result.isRestDay = isRestDay;
    }
    if (events != null) {
      $result.events.addAll(events);
    }
    return $result;
  }
  CalendarDay._() : super();
  factory CalendarDay.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CalendarDay.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalendarDay', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'workoutCount', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'hasScheduled')
    ..aOB(4, _omitFieldNames ? '' : 'isRestDay')
    ..pc<CalendarEvent>(5, _omitFieldNames ? '' : 'events', $pb.PbFieldType.PM, subBuilder: CalendarEvent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CalendarDay clone() => CalendarDay()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CalendarDay copyWith(void Function(CalendarDay) updates) => super.copyWith((message) => updates(message as CalendarDay)) as CalendarDay;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarDay create() => CalendarDay._();
  CalendarDay createEmptyInstance() => create();
  static $pb.PbList<CalendarDay> createRepeated() => $pb.PbList<CalendarDay>();
  @$core.pragma('dart2js:noInline')
  static CalendarDay getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalendarDay>(create);
  static CalendarDay? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get workoutCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set workoutCount($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWorkoutCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearWorkoutCount() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hasScheduled => $_getBF(2);
  @$pb.TagNumber(3)
  set hasScheduled($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHasScheduled() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasScheduled() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isRestDay => $_getBF(3);
  @$pb.TagNumber(4)
  set isRestDay($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsRestDay() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsRestDay() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<CalendarEvent> get events => $_getList(4);
}

/// Calendar event
class CalendarEvent extends $pb.GeneratedMessage {
  factory CalendarEvent({
    $core.String? id,
    $core.String? type,
    $core.String? name,
    $core.bool? isCompleted,
    $core.String? completedAt,
    $core.int? durationSeconds,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (type != null) {
      $result.type = type;
    }
    if (name != null) {
      $result.name = name;
    }
    if (isCompleted != null) {
      $result.isCompleted = isCompleted;
    }
    if (completedAt != null) {
      $result.completedAt = completedAt;
    }
    if (durationSeconds != null) {
      $result.durationSeconds = durationSeconds;
    }
    return $result;
  }
  CalendarEvent._() : super();
  factory CalendarEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CalendarEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CalendarEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOB(4, _omitFieldNames ? '' : 'isCompleted')
    ..aOS(5, _omitFieldNames ? '' : 'completedAt')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'durationSeconds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CalendarEvent clone() => CalendarEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CalendarEvent copyWith(void Function(CalendarEvent) updates) => super.copyWith((message) => updates(message as CalendarEvent)) as CalendarEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalendarEvent create() => CalendarEvent._();
  CalendarEvent createEmptyInstance() => create();
  static $pb.PbList<CalendarEvent> createRepeated() => $pb.PbList<CalendarEvent>();
  @$core.pragma('dart2js:noInline')
  static CalendarEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalendarEvent>(create);
  static CalendarEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isCompleted => $_getBF(3);
  @$pb.TagNumber(4)
  set isCompleted($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsCompleted() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsCompleted() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get completedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set completedAt($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCompletedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCompletedAt() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get durationSeconds => $_getIZ(5);
  @$pb.TagNumber(6)
  set durationSeconds($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDurationSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearDurationSeconds() => clearField(6);
}

/// GetDashboardStats
class GetDashboardStatsRequest extends $pb.GeneratedMessage {
  factory GetDashboardStatsRequest() => create();
  GetDashboardStatsRequest._() : super();
  factory GetDashboardStatsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDashboardStatsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDashboardStatsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDashboardStatsRequest clone() => GetDashboardStatsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDashboardStatsRequest copyWith(void Function(GetDashboardStatsRequest) updates) => super.copyWith((message) => updates(message as GetDashboardStatsRequest)) as GetDashboardStatsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDashboardStatsRequest create() => GetDashboardStatsRequest._();
  GetDashboardStatsRequest createEmptyInstance() => create();
  static $pb.PbList<GetDashboardStatsRequest> createRepeated() => $pb.PbList<GetDashboardStatsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetDashboardStatsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDashboardStatsRequest>(create);
  static GetDashboardStatsRequest? _defaultInstance;
}

class GetDashboardStatsResponse extends $pb.GeneratedMessage {
  factory GetDashboardStatsResponse({
    DashboardStats? stats,
  }) {
    final $result = create();
    if (stats != null) {
      $result.stats = stats;
    }
    return $result;
  }
  GetDashboardStatsResponse._() : super();
  factory GetDashboardStatsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDashboardStatsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDashboardStatsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<DashboardStats>(1, _omitFieldNames ? '' : 'stats', subBuilder: DashboardStats.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDashboardStatsResponse clone() => GetDashboardStatsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDashboardStatsResponse copyWith(void Function(GetDashboardStatsResponse) updates) => super.copyWith((message) => updates(message as GetDashboardStatsResponse)) as GetDashboardStatsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDashboardStatsResponse create() => GetDashboardStatsResponse._();
  GetDashboardStatsResponse createEmptyInstance() => create();
  static $pb.PbList<GetDashboardStatsResponse> createRepeated() => $pb.PbList<GetDashboardStatsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetDashboardStatsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDashboardStatsResponse>(create);
  static GetDashboardStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DashboardStats get stats => $_getN(0);
  @$pb.TagNumber(1)
  set stats(DashboardStats v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasStats() => $_has(0);
  @$pb.TagNumber(1)
  void clearStats() => clearField(1);
  @$pb.TagNumber(1)
  DashboardStats ensureStats() => $_ensure(0);
}

/// GetWeeklyActivity
class GetWeeklyActivityRequest extends $pb.GeneratedMessage {
  factory GetWeeklyActivityRequest({
    $core.String? weekStart,
  }) {
    final $result = create();
    if (weekStart != null) {
      $result.weekStart = weekStart;
    }
    return $result;
  }
  GetWeeklyActivityRequest._() : super();
  factory GetWeeklyActivityRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWeeklyActivityRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWeeklyActivityRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'weekStart')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWeeklyActivityRequest clone() => GetWeeklyActivityRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWeeklyActivityRequest copyWith(void Function(GetWeeklyActivityRequest) updates) => super.copyWith((message) => updates(message as GetWeeklyActivityRequest)) as GetWeeklyActivityRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWeeklyActivityRequest create() => GetWeeklyActivityRequest._();
  GetWeeklyActivityRequest createEmptyInstance() => create();
  static $pb.PbList<GetWeeklyActivityRequest> createRepeated() => $pb.PbList<GetWeeklyActivityRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWeeklyActivityRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWeeklyActivityRequest>(create);
  static GetWeeklyActivityRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get weekStart => $_getSZ(0);
  @$pb.TagNumber(1)
  set weekStart($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWeekStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearWeekStart() => clearField(1);
}

class GetWeeklyActivityResponse extends $pb.GeneratedMessage {
  factory GetWeeklyActivityResponse({
    $core.Iterable<WeeklyActivityDay>? days,
    $core.int? totalWorkouts,
  }) {
    final $result = create();
    if (days != null) {
      $result.days.addAll(days);
    }
    if (totalWorkouts != null) {
      $result.totalWorkouts = totalWorkouts;
    }
    return $result;
  }
  GetWeeklyActivityResponse._() : super();
  factory GetWeeklyActivityResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWeeklyActivityResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWeeklyActivityResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<WeeklyActivityDay>(1, _omitFieldNames ? '' : 'days', $pb.PbFieldType.PM, subBuilder: WeeklyActivityDay.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalWorkouts', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWeeklyActivityResponse clone() => GetWeeklyActivityResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWeeklyActivityResponse copyWith(void Function(GetWeeklyActivityResponse) updates) => super.copyWith((message) => updates(message as GetWeeklyActivityResponse)) as GetWeeklyActivityResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWeeklyActivityResponse create() => GetWeeklyActivityResponse._();
  GetWeeklyActivityResponse createEmptyInstance() => create();
  static $pb.PbList<GetWeeklyActivityResponse> createRepeated() => $pb.PbList<GetWeeklyActivityResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWeeklyActivityResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWeeklyActivityResponse>(create);
  static GetWeeklyActivityResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<WeeklyActivityDay> get days => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalWorkouts => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalWorkouts($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotalWorkouts() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalWorkouts() => clearField(2);
}

/// GetPersonalRecords
class GetPersonalRecordsRequest extends $pb.GeneratedMessage {
  factory GetPersonalRecordsRequest({
    $core.int? limit,
    $core.String? exerciseId,
  }) {
    final $result = create();
    if (limit != null) {
      $result.limit = limit;
    }
    if (exerciseId != null) {
      $result.exerciseId = exerciseId;
    }
    return $result;
  }
  GetPersonalRecordsRequest._() : super();
  factory GetPersonalRecordsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetPersonalRecordsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPersonalRecordsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'exerciseId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetPersonalRecordsRequest clone() => GetPersonalRecordsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetPersonalRecordsRequest copyWith(void Function(GetPersonalRecordsRequest) updates) => super.copyWith((message) => updates(message as GetPersonalRecordsRequest)) as GetPersonalRecordsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPersonalRecordsRequest create() => GetPersonalRecordsRequest._();
  GetPersonalRecordsRequest createEmptyInstance() => create();
  static $pb.PbList<GetPersonalRecordsRequest> createRepeated() => $pb.PbList<GetPersonalRecordsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetPersonalRecordsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPersonalRecordsRequest>(create);
  static GetPersonalRecordsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get exerciseId => $_getSZ(1);
  @$pb.TagNumber(2)
  set exerciseId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasExerciseId() => $_has(1);
  @$pb.TagNumber(2)
  void clearExerciseId() => clearField(2);
}

class GetPersonalRecordsResponse extends $pb.GeneratedMessage {
  factory GetPersonalRecordsResponse({
    $core.Iterable<PersonalRecord>? records,
  }) {
    final $result = create();
    if (records != null) {
      $result.records.addAll(records);
    }
    return $result;
  }
  GetPersonalRecordsResponse._() : super();
  factory GetPersonalRecordsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetPersonalRecordsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetPersonalRecordsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<PersonalRecord>(1, _omitFieldNames ? '' : 'records', $pb.PbFieldType.PM, subBuilder: PersonalRecord.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetPersonalRecordsResponse clone() => GetPersonalRecordsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetPersonalRecordsResponse copyWith(void Function(GetPersonalRecordsResponse) updates) => super.copyWith((message) => updates(message as GetPersonalRecordsResponse)) as GetPersonalRecordsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPersonalRecordsResponse create() => GetPersonalRecordsResponse._();
  GetPersonalRecordsResponse createEmptyInstance() => create();
  static $pb.PbList<GetPersonalRecordsResponse> createRepeated() => $pb.PbList<GetPersonalRecordsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetPersonalRecordsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetPersonalRecordsResponse>(create);
  static GetPersonalRecordsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PersonalRecord> get records => $_getList(0);
}

/// GetExerciseProgress
class GetExerciseProgressRequest extends $pb.GeneratedMessage {
  factory GetExerciseProgressRequest({
    $core.String? exerciseId,
    $core.int? limit,
  }) {
    final $result = create();
    if (exerciseId != null) {
      $result.exerciseId = exerciseId;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  GetExerciseProgressRequest._() : super();
  factory GetExerciseProgressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetExerciseProgressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetExerciseProgressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'exerciseId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetExerciseProgressRequest clone() => GetExerciseProgressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetExerciseProgressRequest copyWith(void Function(GetExerciseProgressRequest) updates) => super.copyWith((message) => updates(message as GetExerciseProgressRequest)) as GetExerciseProgressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetExerciseProgressRequest create() => GetExerciseProgressRequest._();
  GetExerciseProgressRequest createEmptyInstance() => create();
  static $pb.PbList<GetExerciseProgressRequest> createRepeated() => $pb.PbList<GetExerciseProgressRequest>();
  @$core.pragma('dart2js:noInline')
  static GetExerciseProgressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetExerciseProgressRequest>(create);
  static GetExerciseProgressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get exerciseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set exerciseId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasExerciseId() => $_has(0);
  @$pb.TagNumber(1)
  void clearExerciseId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => clearField(2);
}

class GetExerciseProgressResponse extends $pb.GeneratedMessage {
  factory GetExerciseProgressResponse({
    ExerciseProgressSummary? progress,
  }) {
    final $result = create();
    if (progress != null) {
      $result.progress = progress;
    }
    return $result;
  }
  GetExerciseProgressResponse._() : super();
  factory GetExerciseProgressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetExerciseProgressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetExerciseProgressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<ExerciseProgressSummary>(1, _omitFieldNames ? '' : 'progress', subBuilder: ExerciseProgressSummary.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetExerciseProgressResponse clone() => GetExerciseProgressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetExerciseProgressResponse copyWith(void Function(GetExerciseProgressResponse) updates) => super.copyWith((message) => updates(message as GetExerciseProgressResponse)) as GetExerciseProgressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetExerciseProgressResponse create() => GetExerciseProgressResponse._();
  GetExerciseProgressResponse createEmptyInstance() => create();
  static $pb.PbList<GetExerciseProgressResponse> createRepeated() => $pb.PbList<GetExerciseProgressResponse>();
  @$core.pragma('dart2js:noInline')
  static GetExerciseProgressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetExerciseProgressResponse>(create);
  static GetExerciseProgressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ExerciseProgressSummary get progress => $_getN(0);
  @$pb.TagNumber(1)
  set progress(ExerciseProgressSummary v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProgress() => $_has(0);
  @$pb.TagNumber(1)
  void clearProgress() => clearField(1);
  @$pb.TagNumber(1)
  ExerciseProgressSummary ensureProgress() => $_ensure(0);
}

/// GetCalendarMonth
class GetCalendarMonthRequest extends $pb.GeneratedMessage {
  factory GetCalendarMonthRequest({
    $core.int? year,
    $core.int? month,
  }) {
    final $result = create();
    if (year != null) {
      $result.year = year;
    }
    if (month != null) {
      $result.month = month;
    }
    return $result;
  }
  GetCalendarMonthRequest._() : super();
  factory GetCalendarMonthRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCalendarMonthRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCalendarMonthRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'year', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'month', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCalendarMonthRequest clone() => GetCalendarMonthRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCalendarMonthRequest copyWith(void Function(GetCalendarMonthRequest) updates) => super.copyWith((message) => updates(message as GetCalendarMonthRequest)) as GetCalendarMonthRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCalendarMonthRequest create() => GetCalendarMonthRequest._();
  GetCalendarMonthRequest createEmptyInstance() => create();
  static $pb.PbList<GetCalendarMonthRequest> createRepeated() => $pb.PbList<GetCalendarMonthRequest>();
  @$core.pragma('dart2js:noInline')
  static GetCalendarMonthRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCalendarMonthRequest>(create);
  static GetCalendarMonthRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get year => $_getIZ(0);
  @$pb.TagNumber(1)
  set year($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasYear() => $_has(0);
  @$pb.TagNumber(1)
  void clearYear() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get month => $_getIZ(1);
  @$pb.TagNumber(2)
  set month($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMonth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonth() => clearField(2);
}

class GetCalendarMonthResponse extends $pb.GeneratedMessage {
  factory GetCalendarMonthResponse({
    $core.Iterable<CalendarDay>? days,
    $core.int? totalWorkouts,
    $core.int? totalRestDays,
  }) {
    final $result = create();
    if (days != null) {
      $result.days.addAll(days);
    }
    if (totalWorkouts != null) {
      $result.totalWorkouts = totalWorkouts;
    }
    if (totalRestDays != null) {
      $result.totalRestDays = totalRestDays;
    }
    return $result;
  }
  GetCalendarMonthResponse._() : super();
  factory GetCalendarMonthResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCalendarMonthResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCalendarMonthResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<CalendarDay>(1, _omitFieldNames ? '' : 'days', $pb.PbFieldType.PM, subBuilder: CalendarDay.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalWorkouts', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'totalRestDays', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCalendarMonthResponse clone() => GetCalendarMonthResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCalendarMonthResponse copyWith(void Function(GetCalendarMonthResponse) updates) => super.copyWith((message) => updates(message as GetCalendarMonthResponse)) as GetCalendarMonthResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCalendarMonthResponse create() => GetCalendarMonthResponse._();
  GetCalendarMonthResponse createEmptyInstance() => create();
  static $pb.PbList<GetCalendarMonthResponse> createRepeated() => $pb.PbList<GetCalendarMonthResponse>();
  @$core.pragma('dart2js:noInline')
  static GetCalendarMonthResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCalendarMonthResponse>(create);
  static GetCalendarMonthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CalendarDay> get days => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalWorkouts => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalWorkouts($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotalWorkouts() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalWorkouts() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalRestDays => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalRestDays($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTotalRestDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalRestDays() => clearField(3);
}

/// GetStreak
class GetStreakRequest extends $pb.GeneratedMessage {
  factory GetStreakRequest() => create();
  GetStreakRequest._() : super();
  factory GetStreakRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetStreakRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStreakRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetStreakRequest clone() => GetStreakRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetStreakRequest copyWith(void Function(GetStreakRequest) updates) => super.copyWith((message) => updates(message as GetStreakRequest)) as GetStreakRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStreakRequest create() => GetStreakRequest._();
  GetStreakRequest createEmptyInstance() => create();
  static $pb.PbList<GetStreakRequest> createRepeated() => $pb.PbList<GetStreakRequest>();
  @$core.pragma('dart2js:noInline')
  static GetStreakRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStreakRequest>(create);
  static GetStreakRequest? _defaultInstance;
}

class GetStreakResponse extends $pb.GeneratedMessage {
  factory GetStreakResponse({
    $core.int? currentStreak,
    $core.int? longestStreak,
    $core.String? lastWorkoutDate,
  }) {
    final $result = create();
    if (currentStreak != null) {
      $result.currentStreak = currentStreak;
    }
    if (longestStreak != null) {
      $result.longestStreak = longestStreak;
    }
    if (lastWorkoutDate != null) {
      $result.lastWorkoutDate = lastWorkoutDate;
    }
    return $result;
  }
  GetStreakResponse._() : super();
  factory GetStreakResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetStreakResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStreakResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'currentStreak', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'longestStreak', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'lastWorkoutDate')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetStreakResponse clone() => GetStreakResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetStreakResponse copyWith(void Function(GetStreakResponse) updates) => super.copyWith((message) => updates(message as GetStreakResponse)) as GetStreakResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStreakResponse create() => GetStreakResponse._();
  GetStreakResponse createEmptyInstance() => create();
  static $pb.PbList<GetStreakResponse> createRepeated() => $pb.PbList<GetStreakResponse>();
  @$core.pragma('dart2js:noInline')
  static GetStreakResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStreakResponse>(create);
  static GetStreakResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get currentStreak => $_getIZ(0);
  @$pb.TagNumber(1)
  set currentStreak($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCurrentStreak() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentStreak() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get longestStreak => $_getIZ(1);
  @$pb.TagNumber(2)
  set longestStreak($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLongestStreak() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongestStreak() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get lastWorkoutDate => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastWorkoutDate($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLastWorkoutDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastWorkoutDate() => clearField(3);
}

class ProgressServiceApi {
  $pb.RpcClient _client;
  ProgressServiceApi(this._client);

  $async.Future<GetDashboardStatsResponse> getDashboardStats($pb.ClientContext? ctx, GetDashboardStatsRequest request) =>
    _client.invoke<GetDashboardStatsResponse>(ctx, 'ProgressService', 'GetDashboardStats', request, GetDashboardStatsResponse())
  ;
  $async.Future<GetWeeklyActivityResponse> getWeeklyActivity($pb.ClientContext? ctx, GetWeeklyActivityRequest request) =>
    _client.invoke<GetWeeklyActivityResponse>(ctx, 'ProgressService', 'GetWeeklyActivity', request, GetWeeklyActivityResponse())
  ;
  $async.Future<GetPersonalRecordsResponse> getPersonalRecords($pb.ClientContext? ctx, GetPersonalRecordsRequest request) =>
    _client.invoke<GetPersonalRecordsResponse>(ctx, 'ProgressService', 'GetPersonalRecords', request, GetPersonalRecordsResponse())
  ;
  $async.Future<GetExerciseProgressResponse> getExerciseProgress($pb.ClientContext? ctx, GetExerciseProgressRequest request) =>
    _client.invoke<GetExerciseProgressResponse>(ctx, 'ProgressService', 'GetExerciseProgress', request, GetExerciseProgressResponse())
  ;
  $async.Future<GetCalendarMonthResponse> getCalendarMonth($pb.ClientContext? ctx, GetCalendarMonthRequest request) =>
    _client.invoke<GetCalendarMonthResponse>(ctx, 'ProgressService', 'GetCalendarMonth', request, GetCalendarMonthResponse())
  ;
  $async.Future<GetStreakResponse> getStreak($pb.ClientContext? ctx, GetStreakRequest request) =>
    _client.invoke<GetStreakResponse>(ctx, 'ProgressService', 'GetStreak', request, GetStreakResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
