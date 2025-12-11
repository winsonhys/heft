//
//  Generated code. Do not modify.
//  source: session.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'common.pbenum.dart' as $1;
import 'google/protobuf/timestamp.pb.dart' as $0;

/// Workout session
class Session extends $pb.GeneratedMessage {
  factory Session({
    $core.String? id,
    $core.String? userId,
    $core.String? workoutTemplateId,
    $core.String? programId,
    $core.int? programDayNumber,
    $core.String? name,
    $1.WorkoutStatus? status,
    $0.Timestamp? startedAt,
    $0.Timestamp? completedAt,
    $core.int? durationSeconds,
    $core.int? totalSets,
    $core.int? completedSets,
    $core.String? notes,
    $core.Iterable<SessionExercise>? exercises,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (workoutTemplateId != null) {
      $result.workoutTemplateId = workoutTemplateId;
    }
    if (programId != null) {
      $result.programId = programId;
    }
    if (programDayNumber != null) {
      $result.programDayNumber = programDayNumber;
    }
    if (name != null) {
      $result.name = name;
    }
    if (status != null) {
      $result.status = status;
    }
    if (startedAt != null) {
      $result.startedAt = startedAt;
    }
    if (completedAt != null) {
      $result.completedAt = completedAt;
    }
    if (durationSeconds != null) {
      $result.durationSeconds = durationSeconds;
    }
    if (totalSets != null) {
      $result.totalSets = totalSets;
    }
    if (completedSets != null) {
      $result.completedSets = completedSets;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (exercises != null) {
      $result.exercises.addAll(exercises);
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    return $result;
  }
  Session._() : super();
  factory Session.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Session.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Session', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'workoutTemplateId')
    ..aOS(4, _omitFieldNames ? '' : 'programId')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'programDayNumber', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..e<$1.WorkoutStatus>(7, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: $1.WorkoutStatus.WORKOUT_STATUS_UNSPECIFIED, valueOf: $1.WorkoutStatus.valueOf, enumValues: $1.WorkoutStatus.values)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'startedAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'completedAt', subBuilder: $0.Timestamp.create)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'durationSeconds', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'totalSets', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'completedSets', $pb.PbFieldType.O3)
    ..aOS(13, _omitFieldNames ? '' : 'notes')
    ..pc<SessionExercise>(14, _omitFieldNames ? '' : 'exercises', $pb.PbFieldType.PM, subBuilder: SessionExercise.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'updatedAt', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Session clone() => Session()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Session copyWith(void Function(Session) updates) => super.copyWith((message) => updates(message as Session)) as Session;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Session create() => Session._();
  Session createEmptyInstance() => create();
  static $pb.PbList<Session> createRepeated() => $pb.PbList<Session>();
  @$core.pragma('dart2js:noInline')
  static Session getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Session>(create);
  static Session? _defaultInstance;

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
  $core.String get workoutTemplateId => $_getSZ(2);
  @$pb.TagNumber(3)
  set workoutTemplateId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWorkoutTemplateId() => $_has(2);
  @$pb.TagNumber(3)
  void clearWorkoutTemplateId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get programId => $_getSZ(3);
  @$pb.TagNumber(4)
  set programId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasProgramId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProgramId() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get programDayNumber => $_getIZ(4);
  @$pb.TagNumber(5)
  set programDayNumber($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasProgramDayNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearProgramDayNumber() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => clearField(6);

  @$pb.TagNumber(7)
  $1.WorkoutStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status($1.WorkoutStatus v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get startedAt => $_getN(7);
  @$pb.TagNumber(8)
  set startedAt($0.Timestamp v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStartedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearStartedAt() => clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureStartedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Timestamp get completedAt => $_getN(8);
  @$pb.TagNumber(9)
  set completedAt($0.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasCompletedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCompletedAt() => clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureCompletedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.int get durationSeconds => $_getIZ(9);
  @$pb.TagNumber(10)
  set durationSeconds($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasDurationSeconds() => $_has(9);
  @$pb.TagNumber(10)
  void clearDurationSeconds() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get totalSets => $_getIZ(10);
  @$pb.TagNumber(11)
  set totalSets($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasTotalSets() => $_has(10);
  @$pb.TagNumber(11)
  void clearTotalSets() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get completedSets => $_getIZ(11);
  @$pb.TagNumber(12)
  set completedSets($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasCompletedSets() => $_has(11);
  @$pb.TagNumber(12)
  void clearCompletedSets() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get notes => $_getSZ(12);
  @$pb.TagNumber(13)
  set notes($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasNotes() => $_has(12);
  @$pb.TagNumber(13)
  void clearNotes() => clearField(13);

  @$pb.TagNumber(14)
  $core.List<SessionExercise> get exercises => $_getList(13);

  @$pb.TagNumber(15)
  $0.Timestamp get createdAt => $_getN(14);
  @$pb.TagNumber(15)
  set createdAt($0.Timestamp v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearCreatedAt() => clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureCreatedAt() => $_ensure(14);

  @$pb.TagNumber(16)
  $0.Timestamp get updatedAt => $_getN(15);
  @$pb.TagNumber(16)
  set updatedAt($0.Timestamp v) { setField(16, v); }
  @$pb.TagNumber(16)
  $core.bool hasUpdatedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearUpdatedAt() => clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureUpdatedAt() => $_ensure(15);
}

/// Session exercise
class SessionExercise extends $pb.GeneratedMessage {
  factory SessionExercise({
    $core.String? id,
    $core.String? sessionId,
    $core.String? exerciseId,
    $core.String? exerciseName,
    $1.ExerciseType? exerciseType,
    $core.int? displayOrder,
    $core.String? sectionName,
    $core.String? notes,
    $core.Iterable<SessionSet>? sets,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (exerciseId != null) {
      $result.exerciseId = exerciseId;
    }
    if (exerciseName != null) {
      $result.exerciseName = exerciseName;
    }
    if (exerciseType != null) {
      $result.exerciseType = exerciseType;
    }
    if (displayOrder != null) {
      $result.displayOrder = displayOrder;
    }
    if (sectionName != null) {
      $result.sectionName = sectionName;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (sets != null) {
      $result.sets.addAll(sets);
    }
    return $result;
  }
  SessionExercise._() : super();
  factory SessionExercise.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SessionExercise.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SessionExercise', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'sessionId')
    ..aOS(3, _omitFieldNames ? '' : 'exerciseId')
    ..aOS(4, _omitFieldNames ? '' : 'exerciseName')
    ..e<$1.ExerciseType>(5, _omitFieldNames ? '' : 'exerciseType', $pb.PbFieldType.OE, defaultOrMaker: $1.ExerciseType.EXERCISE_TYPE_UNSPECIFIED, valueOf: $1.ExerciseType.valueOf, enumValues: $1.ExerciseType.values)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'displayOrder', $pb.PbFieldType.O3)
    ..aOS(7, _omitFieldNames ? '' : 'sectionName')
    ..aOS(8, _omitFieldNames ? '' : 'notes')
    ..pc<SessionSet>(9, _omitFieldNames ? '' : 'sets', $pb.PbFieldType.PM, subBuilder: SessionSet.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SessionExercise clone() => SessionExercise()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SessionExercise copyWith(void Function(SessionExercise) updates) => super.copyWith((message) => updates(message as SessionExercise)) as SessionExercise;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionExercise create() => SessionExercise._();
  SessionExercise createEmptyInstance() => create();
  static $pb.PbList<SessionExercise> createRepeated() => $pb.PbList<SessionExercise>();
  @$core.pragma('dart2js:noInline')
  static SessionExercise getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionExercise>(create);
  static SessionExercise? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get sessionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sessionId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSessionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSessionId() => clearField(2);

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
  $1.ExerciseType get exerciseType => $_getN(4);
  @$pb.TagNumber(5)
  set exerciseType($1.ExerciseType v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasExerciseType() => $_has(4);
  @$pb.TagNumber(5)
  void clearExerciseType() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get displayOrder => $_getIZ(5);
  @$pb.TagNumber(6)
  set displayOrder($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDisplayOrder() => $_has(5);
  @$pb.TagNumber(6)
  void clearDisplayOrder() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get sectionName => $_getSZ(6);
  @$pb.TagNumber(7)
  set sectionName($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSectionName() => $_has(6);
  @$pb.TagNumber(7)
  void clearSectionName() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get notes => $_getSZ(7);
  @$pb.TagNumber(8)
  set notes($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasNotes() => $_has(7);
  @$pb.TagNumber(8)
  void clearNotes() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<SessionSet> get sets => $_getList(8);
}

/// Session set
class SessionSet extends $pb.GeneratedMessage {
  factory SessionSet({
    $core.String? id,
    $core.String? sessionExerciseId,
    $core.int? setNumber,
    $core.double? weightKg,
    $core.int? reps,
    $core.int? timeSeconds,
    $core.double? distanceM,
    $core.bool? isBodyweight,
    $core.bool? isCompleted,
    $0.Timestamp? completedAt,
    $core.double? targetWeightKg,
    $core.int? targetReps,
    $core.int? targetTimeSeconds,
    $core.double? rpe,
    $core.String? notes,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (sessionExerciseId != null) {
      $result.sessionExerciseId = sessionExerciseId;
    }
    if (setNumber != null) {
      $result.setNumber = setNumber;
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
    if (distanceM != null) {
      $result.distanceM = distanceM;
    }
    if (isBodyweight != null) {
      $result.isBodyweight = isBodyweight;
    }
    if (isCompleted != null) {
      $result.isCompleted = isCompleted;
    }
    if (completedAt != null) {
      $result.completedAt = completedAt;
    }
    if (targetWeightKg != null) {
      $result.targetWeightKg = targetWeightKg;
    }
    if (targetReps != null) {
      $result.targetReps = targetReps;
    }
    if (targetTimeSeconds != null) {
      $result.targetTimeSeconds = targetTimeSeconds;
    }
    if (rpe != null) {
      $result.rpe = rpe;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    return $result;
  }
  SessionSet._() : super();
  factory SessionSet.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SessionSet.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SessionSet', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'sessionExerciseId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'setNumber', $pb.PbFieldType.O3)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'weightKg', $pb.PbFieldType.OD)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'reps', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'timeSeconds', $pb.PbFieldType.O3)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'distanceM', $pb.PbFieldType.OD)
    ..aOB(8, _omitFieldNames ? '' : 'isBodyweight')
    ..aOB(9, _omitFieldNames ? '' : 'isCompleted')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'completedAt', subBuilder: $0.Timestamp.create)
    ..a<$core.double>(11, _omitFieldNames ? '' : 'targetWeightKg', $pb.PbFieldType.OD)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'targetReps', $pb.PbFieldType.O3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'targetTimeSeconds', $pb.PbFieldType.O3)
    ..a<$core.double>(14, _omitFieldNames ? '' : 'rpe', $pb.PbFieldType.OD)
    ..aOS(15, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SessionSet clone() => SessionSet()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SessionSet copyWith(void Function(SessionSet) updates) => super.copyWith((message) => updates(message as SessionSet)) as SessionSet;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionSet create() => SessionSet._();
  SessionSet createEmptyInstance() => create();
  static $pb.PbList<SessionSet> createRepeated() => $pb.PbList<SessionSet>();
  @$core.pragma('dart2js:noInline')
  static SessionSet getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionSet>(create);
  static SessionSet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get sessionExerciseId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sessionExerciseId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSessionExerciseId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSessionExerciseId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get setNumber => $_getIZ(2);
  @$pb.TagNumber(3)
  set setNumber($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSetNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearSetNumber() => clearField(3);

  /// Actual performance
  @$pb.TagNumber(4)
  $core.double get weightKg => $_getN(3);
  @$pb.TagNumber(4)
  set weightKg($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWeightKg() => $_has(3);
  @$pb.TagNumber(4)
  void clearWeightKg() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get reps => $_getIZ(4);
  @$pb.TagNumber(5)
  set reps($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReps() => $_has(4);
  @$pb.TagNumber(5)
  void clearReps() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get timeSeconds => $_getIZ(5);
  @$pb.TagNumber(6)
  set timeSeconds($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTimeSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimeSeconds() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get distanceM => $_getN(6);
  @$pb.TagNumber(7)
  set distanceM($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasDistanceM() => $_has(6);
  @$pb.TagNumber(7)
  void clearDistanceM() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isBodyweight => $_getBF(7);
  @$pb.TagNumber(8)
  set isBodyweight($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIsBodyweight() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsBodyweight() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isCompleted => $_getBF(8);
  @$pb.TagNumber(9)
  set isCompleted($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasIsCompleted() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsCompleted() => clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get completedAt => $_getN(9);
  @$pb.TagNumber(10)
  set completedAt($0.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasCompletedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCompletedAt() => clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCompletedAt() => $_ensure(9);

  /// Targets (copied from template)
  @$pb.TagNumber(11)
  $core.double get targetWeightKg => $_getN(10);
  @$pb.TagNumber(11)
  set targetWeightKg($core.double v) { $_setDouble(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasTargetWeightKg() => $_has(10);
  @$pb.TagNumber(11)
  void clearTargetWeightKg() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get targetReps => $_getIZ(11);
  @$pb.TagNumber(12)
  set targetReps($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasTargetReps() => $_has(11);
  @$pb.TagNumber(12)
  void clearTargetReps() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get targetTimeSeconds => $_getIZ(12);
  @$pb.TagNumber(13)
  set targetTimeSeconds($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasTargetTimeSeconds() => $_has(12);
  @$pb.TagNumber(13)
  void clearTargetTimeSeconds() => clearField(13);

  @$pb.TagNumber(14)
  $core.double get rpe => $_getN(13);
  @$pb.TagNumber(14)
  set rpe($core.double v) { $_setDouble(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasRpe() => $_has(13);
  @$pb.TagNumber(14)
  void clearRpe() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get notes => $_getSZ(14);
  @$pb.TagNumber(15)
  set notes($core.String v) { $_setString(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasNotes() => $_has(14);
  @$pb.TagNumber(15)
  void clearNotes() => clearField(15);
}

/// Session summary for lists
class SessionSummary extends $pb.GeneratedMessage {
  factory SessionSummary({
    $core.String? id,
    $core.String? userId,
    $core.String? name,
    $1.WorkoutStatus? status,
    $0.Timestamp? startedAt,
    $0.Timestamp? completedAt,
    $core.int? durationSeconds,
    $core.int? totalSets,
    $core.int? completedSets,
    $core.String? templateName,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (status != null) {
      $result.status = status;
    }
    if (startedAt != null) {
      $result.startedAt = startedAt;
    }
    if (completedAt != null) {
      $result.completedAt = completedAt;
    }
    if (durationSeconds != null) {
      $result.durationSeconds = durationSeconds;
    }
    if (totalSets != null) {
      $result.totalSets = totalSets;
    }
    if (completedSets != null) {
      $result.completedSets = completedSets;
    }
    if (templateName != null) {
      $result.templateName = templateName;
    }
    return $result;
  }
  SessionSummary._() : super();
  factory SessionSummary.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SessionSummary.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SessionSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..e<$1.WorkoutStatus>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: $1.WorkoutStatus.WORKOUT_STATUS_UNSPECIFIED, valueOf: $1.WorkoutStatus.valueOf, enumValues: $1.WorkoutStatus.values)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'startedAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'completedAt', subBuilder: $0.Timestamp.create)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'durationSeconds', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'totalSets', $pb.PbFieldType.O3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'completedSets', $pb.PbFieldType.O3)
    ..aOS(10, _omitFieldNames ? '' : 'templateName')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SessionSummary clone() => SessionSummary()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SessionSummary copyWith(void Function(SessionSummary) updates) => super.copyWith((message) => updates(message as SessionSummary)) as SessionSummary;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionSummary create() => SessionSummary._();
  SessionSummary createEmptyInstance() => create();
  static $pb.PbList<SessionSummary> createRepeated() => $pb.PbList<SessionSummary>();
  @$core.pragma('dart2js:noInline')
  static SessionSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionSummary>(create);
  static SessionSummary? _defaultInstance;

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
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $1.WorkoutStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status($1.WorkoutStatus v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get startedAt => $_getN(4);
  @$pb.TagNumber(5)
  set startedAt($0.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStartedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartedAt() => clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureStartedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Timestamp get completedAt => $_getN(5);
  @$pb.TagNumber(6)
  set completedAt($0.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCompletedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCompletedAt() => clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCompletedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.int get durationSeconds => $_getIZ(6);
  @$pb.TagNumber(7)
  set durationSeconds($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasDurationSeconds() => $_has(6);
  @$pb.TagNumber(7)
  void clearDurationSeconds() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get totalSets => $_getIZ(7);
  @$pb.TagNumber(8)
  set totalSets($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalSets() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalSets() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get completedSets => $_getIZ(8);
  @$pb.TagNumber(9)
  set completedSets($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasCompletedSets() => $_has(8);
  @$pb.TagNumber(9)
  void clearCompletedSets() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get templateName => $_getSZ(9);
  @$pb.TagNumber(10)
  set templateName($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasTemplateName() => $_has(9);
  @$pb.TagNumber(10)
  void clearTemplateName() => clearField(10);
}

/// StartSession
class StartSessionRequest extends $pb.GeneratedMessage {
  factory StartSessionRequest({
    $core.String? userId,
    $core.String? workoutTemplateId,
    $core.String? programId,
    $core.int? programDayNumber,
    $core.String? name,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (workoutTemplateId != null) {
      $result.workoutTemplateId = workoutTemplateId;
    }
    if (programId != null) {
      $result.programId = programId;
    }
    if (programDayNumber != null) {
      $result.programDayNumber = programDayNumber;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  StartSessionRequest._() : super();
  factory StartSessionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartSessionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartSessionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'workoutTemplateId')
    ..aOS(3, _omitFieldNames ? '' : 'programId')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'programDayNumber', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartSessionRequest clone() => StartSessionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartSessionRequest copyWith(void Function(StartSessionRequest) updates) => super.copyWith((message) => updates(message as StartSessionRequest)) as StartSessionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartSessionRequest create() => StartSessionRequest._();
  StartSessionRequest createEmptyInstance() => create();
  static $pb.PbList<StartSessionRequest> createRepeated() => $pb.PbList<StartSessionRequest>();
  @$core.pragma('dart2js:noInline')
  static StartSessionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartSessionRequest>(create);
  static StartSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get workoutTemplateId => $_getSZ(1);
  @$pb.TagNumber(2)
  set workoutTemplateId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWorkoutTemplateId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWorkoutTemplateId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get programId => $_getSZ(2);
  @$pb.TagNumber(3)
  set programId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProgramId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProgramId() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get programDayNumber => $_getIZ(3);
  @$pb.TagNumber(4)
  set programDayNumber($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasProgramDayNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearProgramDayNumber() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => clearField(5);
}

class StartSessionResponse extends $pb.GeneratedMessage {
  factory StartSessionResponse({
    Session? session,
  }) {
    final $result = create();
    if (session != null) {
      $result.session = session;
    }
    return $result;
  }
  StartSessionResponse._() : super();
  factory StartSessionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartSessionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartSessionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Session>(1, _omitFieldNames ? '' : 'session', subBuilder: Session.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartSessionResponse clone() => StartSessionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartSessionResponse copyWith(void Function(StartSessionResponse) updates) => super.copyWith((message) => updates(message as StartSessionResponse)) as StartSessionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartSessionResponse create() => StartSessionResponse._();
  StartSessionResponse createEmptyInstance() => create();
  static $pb.PbList<StartSessionResponse> createRepeated() => $pb.PbList<StartSessionResponse>();
  @$core.pragma('dart2js:noInline')
  static StartSessionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartSessionResponse>(create);
  static StartSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Session get session => $_getN(0);
  @$pb.TagNumber(1)
  set session(Session v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => clearField(1);
  @$pb.TagNumber(1)
  Session ensureSession() => $_ensure(0);
}

/// GetSession
class GetSessionRequest extends $pb.GeneratedMessage {
  factory GetSessionRequest({
    $core.String? id,
    $core.String? userId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    return $result;
  }
  GetSessionRequest._() : super();
  factory GetSessionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSessionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSessionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSessionRequest clone() => GetSessionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSessionRequest copyWith(void Function(GetSessionRequest) updates) => super.copyWith((message) => updates(message as GetSessionRequest)) as GetSessionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSessionRequest create() => GetSessionRequest._();
  GetSessionRequest createEmptyInstance() => create();
  static $pb.PbList<GetSessionRequest> createRepeated() => $pb.PbList<GetSessionRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSessionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSessionRequest>(create);
  static GetSessionRequest? _defaultInstance;

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
}

class GetSessionResponse extends $pb.GeneratedMessage {
  factory GetSessionResponse({
    Session? session,
  }) {
    final $result = create();
    if (session != null) {
      $result.session = session;
    }
    return $result;
  }
  GetSessionResponse._() : super();
  factory GetSessionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSessionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSessionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Session>(1, _omitFieldNames ? '' : 'session', subBuilder: Session.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSessionResponse clone() => GetSessionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSessionResponse copyWith(void Function(GetSessionResponse) updates) => super.copyWith((message) => updates(message as GetSessionResponse)) as GetSessionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSessionResponse create() => GetSessionResponse._();
  GetSessionResponse createEmptyInstance() => create();
  static $pb.PbList<GetSessionResponse> createRepeated() => $pb.PbList<GetSessionResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSessionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSessionResponse>(create);
  static GetSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Session get session => $_getN(0);
  @$pb.TagNumber(1)
  set session(Session v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => clearField(1);
  @$pb.TagNumber(1)
  Session ensureSession() => $_ensure(0);
}

/// CompleteSet
class CompleteSetRequest extends $pb.GeneratedMessage {
  factory CompleteSetRequest({
    $core.String? sessionSetId,
    $core.String? userId,
    $core.double? weightKg,
    $core.int? reps,
    $core.int? timeSeconds,
    $core.double? distanceM,
    $core.double? rpe,
    $core.String? notes,
  }) {
    final $result = create();
    if (sessionSetId != null) {
      $result.sessionSetId = sessionSetId;
    }
    if (userId != null) {
      $result.userId = userId;
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
    if (distanceM != null) {
      $result.distanceM = distanceM;
    }
    if (rpe != null) {
      $result.rpe = rpe;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    return $result;
  }
  CompleteSetRequest._() : super();
  factory CompleteSetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CompleteSetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CompleteSetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionSetId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'weightKg', $pb.PbFieldType.OD)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'reps', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'timeSeconds', $pb.PbFieldType.O3)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'distanceM', $pb.PbFieldType.OD)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'rpe', $pb.PbFieldType.OD)
    ..aOS(8, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CompleteSetRequest clone() => CompleteSetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CompleteSetRequest copyWith(void Function(CompleteSetRequest) updates) => super.copyWith((message) => updates(message as CompleteSetRequest)) as CompleteSetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompleteSetRequest create() => CompleteSetRequest._();
  CompleteSetRequest createEmptyInstance() => create();
  static $pb.PbList<CompleteSetRequest> createRepeated() => $pb.PbList<CompleteSetRequest>();
  @$core.pragma('dart2js:noInline')
  static CompleteSetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CompleteSetRequest>(create);
  static CompleteSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionSetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionSetId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionSetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionSetId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get weightKg => $_getN(2);
  @$pb.TagNumber(3)
  set weightKg($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWeightKg() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeightKg() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get reps => $_getIZ(3);
  @$pb.TagNumber(4)
  set reps($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReps() => $_has(3);
  @$pb.TagNumber(4)
  void clearReps() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get timeSeconds => $_getIZ(4);
  @$pb.TagNumber(5)
  set timeSeconds($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimeSeconds() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimeSeconds() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get distanceM => $_getN(5);
  @$pb.TagNumber(6)
  set distanceM($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDistanceM() => $_has(5);
  @$pb.TagNumber(6)
  void clearDistanceM() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get rpe => $_getN(6);
  @$pb.TagNumber(7)
  set rpe($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasRpe() => $_has(6);
  @$pb.TagNumber(7)
  void clearRpe() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get notes => $_getSZ(7);
  @$pb.TagNumber(8)
  set notes($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasNotes() => $_has(7);
  @$pb.TagNumber(8)
  void clearNotes() => clearField(8);
}

class CompleteSetResponse extends $pb.GeneratedMessage {
  factory CompleteSetResponse({
    SessionSet? set,
    $core.bool? isPersonalRecord,
  }) {
    final $result = create();
    if (set != null) {
      $result.set = set;
    }
    if (isPersonalRecord != null) {
      $result.isPersonalRecord = isPersonalRecord;
    }
    return $result;
  }
  CompleteSetResponse._() : super();
  factory CompleteSetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CompleteSetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CompleteSetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<SessionSet>(1, _omitFieldNames ? '' : 'set', subBuilder: SessionSet.create)
    ..aOB(2, _omitFieldNames ? '' : 'isPersonalRecord')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CompleteSetResponse clone() => CompleteSetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CompleteSetResponse copyWith(void Function(CompleteSetResponse) updates) => super.copyWith((message) => updates(message as CompleteSetResponse)) as CompleteSetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompleteSetResponse create() => CompleteSetResponse._();
  CompleteSetResponse createEmptyInstance() => create();
  static $pb.PbList<CompleteSetResponse> createRepeated() => $pb.PbList<CompleteSetResponse>();
  @$core.pragma('dart2js:noInline')
  static CompleteSetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CompleteSetResponse>(create);
  static CompleteSetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionSet get set => $_getN(0);
  @$pb.TagNumber(1)
  set set(SessionSet v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSet() => $_has(0);
  @$pb.TagNumber(1)
  void clearSet() => clearField(1);
  @$pb.TagNumber(1)
  SessionSet ensureSet() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get isPersonalRecord => $_getBF(1);
  @$pb.TagNumber(2)
  set isPersonalRecord($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsPersonalRecord() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsPersonalRecord() => clearField(2);
}

/// UpdateSet
class UpdateSetRequest extends $pb.GeneratedMessage {
  factory UpdateSetRequest({
    $core.String? sessionSetId,
    $core.String? userId,
    $core.double? weightKg,
    $core.int? reps,
    $core.int? timeSeconds,
    $core.double? distanceM,
    $core.bool? isCompleted,
    $core.double? rpe,
    $core.String? notes,
  }) {
    final $result = create();
    if (sessionSetId != null) {
      $result.sessionSetId = sessionSetId;
    }
    if (userId != null) {
      $result.userId = userId;
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
    if (distanceM != null) {
      $result.distanceM = distanceM;
    }
    if (isCompleted != null) {
      $result.isCompleted = isCompleted;
    }
    if (rpe != null) {
      $result.rpe = rpe;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    return $result;
  }
  UpdateSetRequest._() : super();
  factory UpdateSetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateSetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateSetRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionSetId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'weightKg', $pb.PbFieldType.OD)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'reps', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'timeSeconds', $pb.PbFieldType.O3)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'distanceM', $pb.PbFieldType.OD)
    ..aOB(7, _omitFieldNames ? '' : 'isCompleted')
    ..a<$core.double>(8, _omitFieldNames ? '' : 'rpe', $pb.PbFieldType.OD)
    ..aOS(9, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateSetRequest clone() => UpdateSetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateSetRequest copyWith(void Function(UpdateSetRequest) updates) => super.copyWith((message) => updates(message as UpdateSetRequest)) as UpdateSetRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSetRequest create() => UpdateSetRequest._();
  UpdateSetRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateSetRequest> createRepeated() => $pb.PbList<UpdateSetRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateSetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateSetRequest>(create);
  static UpdateSetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionSetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionSetId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionSetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionSetId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get weightKg => $_getN(2);
  @$pb.TagNumber(3)
  set weightKg($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWeightKg() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeightKg() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get reps => $_getIZ(3);
  @$pb.TagNumber(4)
  set reps($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReps() => $_has(3);
  @$pb.TagNumber(4)
  void clearReps() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get timeSeconds => $_getIZ(4);
  @$pb.TagNumber(5)
  set timeSeconds($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimeSeconds() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimeSeconds() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get distanceM => $_getN(5);
  @$pb.TagNumber(6)
  set distanceM($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDistanceM() => $_has(5);
  @$pb.TagNumber(6)
  void clearDistanceM() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isCompleted => $_getBF(6);
  @$pb.TagNumber(7)
  set isCompleted($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasIsCompleted() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsCompleted() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get rpe => $_getN(7);
  @$pb.TagNumber(8)
  set rpe($core.double v) { $_setDouble(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasRpe() => $_has(7);
  @$pb.TagNumber(8)
  void clearRpe() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get notes => $_getSZ(8);
  @$pb.TagNumber(9)
  set notes($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasNotes() => $_has(8);
  @$pb.TagNumber(9)
  void clearNotes() => clearField(9);
}

class UpdateSetResponse extends $pb.GeneratedMessage {
  factory UpdateSetResponse({
    SessionSet? set,
  }) {
    final $result = create();
    if (set != null) {
      $result.set = set;
    }
    return $result;
  }
  UpdateSetResponse._() : super();
  factory UpdateSetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateSetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateSetResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<SessionSet>(1, _omitFieldNames ? '' : 'set', subBuilder: SessionSet.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateSetResponse clone() => UpdateSetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateSetResponse copyWith(void Function(UpdateSetResponse) updates) => super.copyWith((message) => updates(message as UpdateSetResponse)) as UpdateSetResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSetResponse create() => UpdateSetResponse._();
  UpdateSetResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateSetResponse> createRepeated() => $pb.PbList<UpdateSetResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateSetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateSetResponse>(create);
  static UpdateSetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionSet get set => $_getN(0);
  @$pb.TagNumber(1)
  set set(SessionSet v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSet() => $_has(0);
  @$pb.TagNumber(1)
  void clearSet() => clearField(1);
  @$pb.TagNumber(1)
  SessionSet ensureSet() => $_ensure(0);
}

/// AddExercise
class AddExerciseRequest extends $pb.GeneratedMessage {
  factory AddExerciseRequest({
    $core.String? sessionId,
    $core.String? userId,
    $core.String? exerciseId,
    $core.int? displayOrder,
    $core.String? sectionName,
    $core.int? numSets,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (exerciseId != null) {
      $result.exerciseId = exerciseId;
    }
    if (displayOrder != null) {
      $result.displayOrder = displayOrder;
    }
    if (sectionName != null) {
      $result.sectionName = sectionName;
    }
    if (numSets != null) {
      $result.numSets = numSets;
    }
    return $result;
  }
  AddExerciseRequest._() : super();
  factory AddExerciseRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddExerciseRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddExerciseRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'exerciseId')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'displayOrder', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'sectionName')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'numSets', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddExerciseRequest clone() => AddExerciseRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddExerciseRequest copyWith(void Function(AddExerciseRequest) updates) => super.copyWith((message) => updates(message as AddExerciseRequest)) as AddExerciseRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddExerciseRequest create() => AddExerciseRequest._();
  AddExerciseRequest createEmptyInstance() => create();
  static $pb.PbList<AddExerciseRequest> createRepeated() => $pb.PbList<AddExerciseRequest>();
  @$core.pragma('dart2js:noInline')
  static AddExerciseRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddExerciseRequest>(create);
  static AddExerciseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => clearField(1);

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
  $core.int get displayOrder => $_getIZ(3);
  @$pb.TagNumber(4)
  set displayOrder($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDisplayOrder() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayOrder() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get sectionName => $_getSZ(4);
  @$pb.TagNumber(5)
  set sectionName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSectionName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSectionName() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get numSets => $_getIZ(5);
  @$pb.TagNumber(6)
  set numSets($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasNumSets() => $_has(5);
  @$pb.TagNumber(6)
  void clearNumSets() => clearField(6);
}

class AddExerciseResponse extends $pb.GeneratedMessage {
  factory AddExerciseResponse({
    SessionExercise? exercise,
  }) {
    final $result = create();
    if (exercise != null) {
      $result.exercise = exercise;
    }
    return $result;
  }
  AddExerciseResponse._() : super();
  factory AddExerciseResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddExerciseResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddExerciseResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<SessionExercise>(1, _omitFieldNames ? '' : 'exercise', subBuilder: SessionExercise.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddExerciseResponse clone() => AddExerciseResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddExerciseResponse copyWith(void Function(AddExerciseResponse) updates) => super.copyWith((message) => updates(message as AddExerciseResponse)) as AddExerciseResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddExerciseResponse create() => AddExerciseResponse._();
  AddExerciseResponse createEmptyInstance() => create();
  static $pb.PbList<AddExerciseResponse> createRepeated() => $pb.PbList<AddExerciseResponse>();
  @$core.pragma('dart2js:noInline')
  static AddExerciseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddExerciseResponse>(create);
  static AddExerciseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionExercise get exercise => $_getN(0);
  @$pb.TagNumber(1)
  set exercise(SessionExercise v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasExercise() => $_has(0);
  @$pb.TagNumber(1)
  void clearExercise() => clearField(1);
  @$pb.TagNumber(1)
  SessionExercise ensureExercise() => $_ensure(0);
}

/// FinishSession
class FinishSessionRequest extends $pb.GeneratedMessage {
  factory FinishSessionRequest({
    $core.String? id,
    $core.String? userId,
    $core.String? notes,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    return $result;
  }
  FinishSessionRequest._() : super();
  factory FinishSessionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FinishSessionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FinishSessionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FinishSessionRequest clone() => FinishSessionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FinishSessionRequest copyWith(void Function(FinishSessionRequest) updates) => super.copyWith((message) => updates(message as FinishSessionRequest)) as FinishSessionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FinishSessionRequest create() => FinishSessionRequest._();
  FinishSessionRequest createEmptyInstance() => create();
  static $pb.PbList<FinishSessionRequest> createRepeated() => $pb.PbList<FinishSessionRequest>();
  @$core.pragma('dart2js:noInline')
  static FinishSessionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FinishSessionRequest>(create);
  static FinishSessionRequest? _defaultInstance;

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
  $core.String get notes => $_getSZ(2);
  @$pb.TagNumber(3)
  set notes($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNotes() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotes() => clearField(3);
}

class FinishSessionResponse extends $pb.GeneratedMessage {
  factory FinishSessionResponse({
    Session? session,
  }) {
    final $result = create();
    if (session != null) {
      $result.session = session;
    }
    return $result;
  }
  FinishSessionResponse._() : super();
  factory FinishSessionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FinishSessionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FinishSessionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Session>(1, _omitFieldNames ? '' : 'session', subBuilder: Session.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FinishSessionResponse clone() => FinishSessionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FinishSessionResponse copyWith(void Function(FinishSessionResponse) updates) => super.copyWith((message) => updates(message as FinishSessionResponse)) as FinishSessionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FinishSessionResponse create() => FinishSessionResponse._();
  FinishSessionResponse createEmptyInstance() => create();
  static $pb.PbList<FinishSessionResponse> createRepeated() => $pb.PbList<FinishSessionResponse>();
  @$core.pragma('dart2js:noInline')
  static FinishSessionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FinishSessionResponse>(create);
  static FinishSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Session get session => $_getN(0);
  @$pb.TagNumber(1)
  set session(Session v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearSession() => clearField(1);
  @$pb.TagNumber(1)
  Session ensureSession() => $_ensure(0);
}

/// AbandonSession
class AbandonSessionRequest extends $pb.GeneratedMessage {
  factory AbandonSessionRequest({
    $core.String? id,
    $core.String? userId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    return $result;
  }
  AbandonSessionRequest._() : super();
  factory AbandonSessionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AbandonSessionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AbandonSessionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AbandonSessionRequest clone() => AbandonSessionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AbandonSessionRequest copyWith(void Function(AbandonSessionRequest) updates) => super.copyWith((message) => updates(message as AbandonSessionRequest)) as AbandonSessionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AbandonSessionRequest create() => AbandonSessionRequest._();
  AbandonSessionRequest createEmptyInstance() => create();
  static $pb.PbList<AbandonSessionRequest> createRepeated() => $pb.PbList<AbandonSessionRequest>();
  @$core.pragma('dart2js:noInline')
  static AbandonSessionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AbandonSessionRequest>(create);
  static AbandonSessionRequest? _defaultInstance;

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
}

class AbandonSessionResponse extends $pb.GeneratedMessage {
  factory AbandonSessionResponse({
    $core.bool? success,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    return $result;
  }
  AbandonSessionResponse._() : super();
  factory AbandonSessionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AbandonSessionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AbandonSessionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AbandonSessionResponse clone() => AbandonSessionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AbandonSessionResponse copyWith(void Function(AbandonSessionResponse) updates) => super.copyWith((message) => updates(message as AbandonSessionResponse)) as AbandonSessionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AbandonSessionResponse create() => AbandonSessionResponse._();
  AbandonSessionResponse createEmptyInstance() => create();
  static $pb.PbList<AbandonSessionResponse> createRepeated() => $pb.PbList<AbandonSessionResponse>();
  @$core.pragma('dart2js:noInline')
  static AbandonSessionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AbandonSessionResponse>(create);
  static AbandonSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);
}

/// ListSessions
class ListSessionsRequest extends $pb.GeneratedMessage {
  factory ListSessionsRequest({
    $core.String? userId,
    $1.WorkoutStatus? status,
    $core.String? startDate,
    $core.String? endDate,
    $1.PaginationRequest? pagination,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (startDate != null) {
      $result.startDate = startDate;
    }
    if (endDate != null) {
      $result.endDate = endDate;
    }
    if (pagination != null) {
      $result.pagination = pagination;
    }
    return $result;
  }
  ListSessionsRequest._() : super();
  factory ListSessionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSessionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSessionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..e<$1.WorkoutStatus>(2, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: $1.WorkoutStatus.WORKOUT_STATUS_UNSPECIFIED, valueOf: $1.WorkoutStatus.valueOf, enumValues: $1.WorkoutStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'startDate')
    ..aOS(4, _omitFieldNames ? '' : 'endDate')
    ..aOM<$1.PaginationRequest>(5, _omitFieldNames ? '' : 'pagination', subBuilder: $1.PaginationRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSessionsRequest clone() => ListSessionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSessionsRequest copyWith(void Function(ListSessionsRequest) updates) => super.copyWith((message) => updates(message as ListSessionsRequest)) as ListSessionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSessionsRequest create() => ListSessionsRequest._();
  ListSessionsRequest createEmptyInstance() => create();
  static $pb.PbList<ListSessionsRequest> createRepeated() => $pb.PbList<ListSessionsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSessionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSessionsRequest>(create);
  static ListSessionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $1.WorkoutStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status($1.WorkoutStatus v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get startDate => $_getSZ(2);
  @$pb.TagNumber(3)
  set startDate($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStartDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartDate() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get endDate => $_getSZ(3);
  @$pb.TagNumber(4)
  set endDate($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEndDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndDate() => clearField(4);

  @$pb.TagNumber(5)
  $1.PaginationRequest get pagination => $_getN(4);
  @$pb.TagNumber(5)
  set pagination($1.PaginationRequest v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPagination() => $_has(4);
  @$pb.TagNumber(5)
  void clearPagination() => clearField(5);
  @$pb.TagNumber(5)
  $1.PaginationRequest ensurePagination() => $_ensure(4);
}

class ListSessionsResponse extends $pb.GeneratedMessage {
  factory ListSessionsResponse({
    $core.Iterable<SessionSummary>? sessions,
    $1.PaginationResponse? pagination,
  }) {
    final $result = create();
    if (sessions != null) {
      $result.sessions.addAll(sessions);
    }
    if (pagination != null) {
      $result.pagination = pagination;
    }
    return $result;
  }
  ListSessionsResponse._() : super();
  factory ListSessionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSessionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSessionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<SessionSummary>(1, _omitFieldNames ? '' : 'sessions', $pb.PbFieldType.PM, subBuilder: SessionSummary.create)
    ..aOM<$1.PaginationResponse>(2, _omitFieldNames ? '' : 'pagination', subBuilder: $1.PaginationResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSessionsResponse clone() => ListSessionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSessionsResponse copyWith(void Function(ListSessionsResponse) updates) => super.copyWith((message) => updates(message as ListSessionsResponse)) as ListSessionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSessionsResponse create() => ListSessionsResponse._();
  ListSessionsResponse createEmptyInstance() => create();
  static $pb.PbList<ListSessionsResponse> createRepeated() => $pb.PbList<ListSessionsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSessionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSessionsResponse>(create);
  static ListSessionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SessionSummary> get sessions => $_getList(0);

  @$pb.TagNumber(2)
  $1.PaginationResponse get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($1.PaginationResponse v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => clearField(2);
  @$pb.TagNumber(2)
  $1.PaginationResponse ensurePagination() => $_ensure(1);
}

class SessionServiceApi {
  $pb.RpcClient _client;
  SessionServiceApi(this._client);

  $async.Future<StartSessionResponse> startSession($pb.ClientContext? ctx, StartSessionRequest request) =>
    _client.invoke<StartSessionResponse>(ctx, 'SessionService', 'StartSession', request, StartSessionResponse())
  ;
  $async.Future<GetSessionResponse> getSession($pb.ClientContext? ctx, GetSessionRequest request) =>
    _client.invoke<GetSessionResponse>(ctx, 'SessionService', 'GetSession', request, GetSessionResponse())
  ;
  $async.Future<CompleteSetResponse> completeSet($pb.ClientContext? ctx, CompleteSetRequest request) =>
    _client.invoke<CompleteSetResponse>(ctx, 'SessionService', 'CompleteSet', request, CompleteSetResponse())
  ;
  $async.Future<UpdateSetResponse> updateSet($pb.ClientContext? ctx, UpdateSetRequest request) =>
    _client.invoke<UpdateSetResponse>(ctx, 'SessionService', 'UpdateSet', request, UpdateSetResponse())
  ;
  $async.Future<AddExerciseResponse> addExercise($pb.ClientContext? ctx, AddExerciseRequest request) =>
    _client.invoke<AddExerciseResponse>(ctx, 'SessionService', 'AddExercise', request, AddExerciseResponse())
  ;
  $async.Future<FinishSessionResponse> finishSession($pb.ClientContext? ctx, FinishSessionRequest request) =>
    _client.invoke<FinishSessionResponse>(ctx, 'SessionService', 'FinishSession', request, FinishSessionResponse())
  ;
  $async.Future<AbandonSessionResponse> abandonSession($pb.ClientContext? ctx, AbandonSessionRequest request) =>
    _client.invoke<AbandonSessionResponse>(ctx, 'SessionService', 'AbandonSession', request, AbandonSessionResponse())
  ;
  $async.Future<ListSessionsResponse> listSessions($pb.ClientContext? ctx, ListSessionsRequest request) =>
    _client.invoke<ListSessionsResponse>(ctx, 'SessionService', 'ListSessions', request, ListSessionsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
