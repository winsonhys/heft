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

import 'common.pb.dart' as $2;
import 'common.pbenum.dart' as $2;
import 'google/protobuf/timestamp.pb.dart' as $1;

/// Workout session
class Session extends $pb.GeneratedMessage {
  factory Session({
    $core.String? id,
    $core.String? userId,
    $core.String? workoutTemplateId,
    $core.String? programId,
    $core.int? programDayNumber,
    $core.String? name,
    $2.WorkoutStatus? status,
    $1.Timestamp? startedAt,
    $1.Timestamp? completedAt,
    $core.int? durationSeconds,
    $core.int? totalSets,
    $core.int? completedSets,
    $core.String? notes,
    $core.Iterable<SessionExercise>? exercises,
    $1.Timestamp? createdAt,
    $1.Timestamp? updatedAt,
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
    ..e<$2.WorkoutStatus>(7, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: $2.WorkoutStatus.WORKOUT_STATUS_UNSPECIFIED, valueOf: $2.WorkoutStatus.valueOf, enumValues: $2.WorkoutStatus.values)
    ..aOM<$1.Timestamp>(8, _omitFieldNames ? '' : 'startedAt', subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'completedAt', subBuilder: $1.Timestamp.create)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'durationSeconds', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'totalSets', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'completedSets', $pb.PbFieldType.O3)
    ..aOS(13, _omitFieldNames ? '' : 'notes')
    ..pc<SessionExercise>(14, _omitFieldNames ? '' : 'exercises', $pb.PbFieldType.PM, subBuilder: SessionExercise.create)
    ..aOM<$1.Timestamp>(15, _omitFieldNames ? '' : 'createdAt', subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(16, _omitFieldNames ? '' : 'updatedAt', subBuilder: $1.Timestamp.create)
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
  $2.WorkoutStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status($2.WorkoutStatus v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => clearField(7);

  @$pb.TagNumber(8)
  $1.Timestamp get startedAt => $_getN(7);
  @$pb.TagNumber(8)
  set startedAt($1.Timestamp v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasStartedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearStartedAt() => clearField(8);
  @$pb.TagNumber(8)
  $1.Timestamp ensureStartedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $1.Timestamp get completedAt => $_getN(8);
  @$pb.TagNumber(9)
  set completedAt($1.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasCompletedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCompletedAt() => clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensureCompletedAt() => $_ensure(8);

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
  $1.Timestamp get createdAt => $_getN(14);
  @$pb.TagNumber(15)
  set createdAt($1.Timestamp v) { setField(15, v); }
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearCreatedAt() => clearField(15);
  @$pb.TagNumber(15)
  $1.Timestamp ensureCreatedAt() => $_ensure(14);

  @$pb.TagNumber(16)
  $1.Timestamp get updatedAt => $_getN(15);
  @$pb.TagNumber(16)
  set updatedAt($1.Timestamp v) { setField(16, v); }
  @$pb.TagNumber(16)
  $core.bool hasUpdatedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearUpdatedAt() => clearField(16);
  @$pb.TagNumber(16)
  $1.Timestamp ensureUpdatedAt() => $_ensure(15);
}

/// Session exercise
class SessionExercise extends $pb.GeneratedMessage {
  factory SessionExercise({
    $core.String? id,
    $core.String? sessionId,
    $core.String? exerciseId,
    $core.String? exerciseName,
    $2.ExerciseType? exerciseType,
    $core.int? displayOrder,
    $core.String? sectionName,
    $core.String? notes,
    $core.Iterable<SessionSet>? sets,
    $core.String? supersetId,
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
    if (supersetId != null) {
      $result.supersetId = supersetId;
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
    ..e<$2.ExerciseType>(5, _omitFieldNames ? '' : 'exerciseType', $pb.PbFieldType.OE, defaultOrMaker: $2.ExerciseType.EXERCISE_TYPE_UNSPECIFIED, valueOf: $2.ExerciseType.valueOf, enumValues: $2.ExerciseType.values)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'displayOrder', $pb.PbFieldType.O3)
    ..aOS(7, _omitFieldNames ? '' : 'sectionName')
    ..aOS(8, _omitFieldNames ? '' : 'notes')
    ..pc<SessionSet>(9, _omitFieldNames ? '' : 'sets', $pb.PbFieldType.PM, subBuilder: SessionSet.create)
    ..aOS(10, _omitFieldNames ? '' : 'supersetId')
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
  $2.ExerciseType get exerciseType => $_getN(4);
  @$pb.TagNumber(5)
  set exerciseType($2.ExerciseType v) { setField(5, v); }
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

  @$pb.TagNumber(10)
  $core.String get supersetId => $_getSZ(9);
  @$pb.TagNumber(10)
  set supersetId($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasSupersetId() => $_has(9);
  @$pb.TagNumber(10)
  void clearSupersetId() => clearField(10);
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
    $1.Timestamp? completedAt,
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
    ..aOM<$1.Timestamp>(10, _omitFieldNames ? '' : 'completedAt', subBuilder: $1.Timestamp.create)
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
  $1.Timestamp get completedAt => $_getN(9);
  @$pb.TagNumber(10)
  set completedAt($1.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasCompletedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCompletedAt() => clearField(10);
  @$pb.TagNumber(10)
  $1.Timestamp ensureCompletedAt() => $_ensure(9);

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
    $2.WorkoutStatus? status,
    $1.Timestamp? startedAt,
    $1.Timestamp? completedAt,
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
    ..e<$2.WorkoutStatus>(4, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: $2.WorkoutStatus.WORKOUT_STATUS_UNSPECIFIED, valueOf: $2.WorkoutStatus.valueOf, enumValues: $2.WorkoutStatus.values)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'startedAt', subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'completedAt', subBuilder: $1.Timestamp.create)
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
  $2.WorkoutStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status($2.WorkoutStatus v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => clearField(4);

  @$pb.TagNumber(5)
  $1.Timestamp get startedAt => $_getN(4);
  @$pb.TagNumber(5)
  set startedAt($1.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStartedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartedAt() => clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureStartedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $1.Timestamp get completedAt => $_getN(5);
  @$pb.TagNumber(6)
  set completedAt($1.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCompletedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCompletedAt() => clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureCompletedAt() => $_ensure(5);

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
    $core.String? workoutTemplateId,
    $core.String? programId,
    $core.int? programDayNumber,
    $core.String? name,
  }) {
    final $result = create();
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
    ..aOS(1, _omitFieldNames ? '' : 'workoutTemplateId')
    ..aOS(2, _omitFieldNames ? '' : 'programId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'programDayNumber', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'name')
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
  $core.String get workoutTemplateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set workoutTemplateId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWorkoutTemplateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkoutTemplateId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get programId => $_getSZ(1);
  @$pb.TagNumber(2)
  set programId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProgramId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProgramId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get programDayNumber => $_getIZ(2);
  @$pb.TagNumber(3)
  set programDayNumber($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasProgramDayNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearProgramDayNumber() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => clearField(4);
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
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetSessionRequest._() : super();
  factory GetSessionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSessionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSessionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
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

/// SyncSession - Periodic full session state sync
class SyncSessionRequest extends $pb.GeneratedMessage {
  factory SyncSessionRequest({
    $core.String? sessionId,
    $core.Iterable<SyncSetData>? sets,
    $core.Iterable<SyncExerciseData>? exercises,
    $core.Iterable<$core.String>? deletedSetIds,
    $core.Iterable<$core.String>? deletedExerciseIds,
  }) {
    final $result = create();
    if (sessionId != null) {
      $result.sessionId = sessionId;
    }
    if (sets != null) {
      $result.sets.addAll(sets);
    }
    if (exercises != null) {
      $result.exercises.addAll(exercises);
    }
    if (deletedSetIds != null) {
      $result.deletedSetIds.addAll(deletedSetIds);
    }
    if (deletedExerciseIds != null) {
      $result.deletedExerciseIds.addAll(deletedExerciseIds);
    }
    return $result;
  }
  SyncSessionRequest._() : super();
  factory SyncSessionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncSessionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncSessionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..pc<SyncSetData>(2, _omitFieldNames ? '' : 'sets', $pb.PbFieldType.PM, subBuilder: SyncSetData.create)
    ..pc<SyncExerciseData>(3, _omitFieldNames ? '' : 'exercises', $pb.PbFieldType.PM, subBuilder: SyncExerciseData.create)
    ..pPS(4, _omitFieldNames ? '' : 'deletedSetIds')
    ..pPS(5, _omitFieldNames ? '' : 'deletedExerciseIds')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncSessionRequest clone() => SyncSessionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncSessionRequest copyWith(void Function(SyncSessionRequest) updates) => super.copyWith((message) => updates(message as SyncSessionRequest)) as SyncSessionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncSessionRequest create() => SyncSessionRequest._();
  SyncSessionRequest createEmptyInstance() => create();
  static $pb.PbList<SyncSessionRequest> createRepeated() => $pb.PbList<SyncSessionRequest>();
  @$core.pragma('dart2js:noInline')
  static SyncSessionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncSessionRequest>(create);
  static SyncSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<SyncSetData> get sets => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<SyncExerciseData> get exercises => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<$core.String> get deletedSetIds => $_getList(3);

  @$pb.TagNumber(5)
  $core.List<$core.String> get deletedExerciseIds => $_getList(4);
}

enum SyncSetData_SetIdentifier {
  id, 
  sessionExerciseId, 
  notSet
}

class SyncSetData extends $pb.GeneratedMessage {
  factory SyncSetData({
    $core.String? id,
    $core.double? weightKg,
    $core.int? reps,
    $core.int? timeSeconds,
    $core.double? distanceM,
    $core.bool? isCompleted,
    $core.double? rpe,
    $core.String? notes,
    $core.String? sessionExerciseId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
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
    if (sessionExerciseId != null) {
      $result.sessionExerciseId = sessionExerciseId;
    }
    return $result;
  }
  SyncSetData._() : super();
  factory SyncSetData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncSetData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, SyncSetData_SetIdentifier> _SyncSetData_SetIdentifierByTag = {
    1 : SyncSetData_SetIdentifier.id,
    9 : SyncSetData_SetIdentifier.sessionExerciseId,
    0 : SyncSetData_SetIdentifier.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncSetData', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..oo(0, [1, 9])
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'weightKg', $pb.PbFieldType.OD)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'reps', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'timeSeconds', $pb.PbFieldType.O3)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'distanceM', $pb.PbFieldType.OD)
    ..aOB(6, _omitFieldNames ? '' : 'isCompleted')
    ..a<$core.double>(7, _omitFieldNames ? '' : 'rpe', $pb.PbFieldType.OD)
    ..aOS(8, _omitFieldNames ? '' : 'notes')
    ..aOS(9, _omitFieldNames ? '' : 'sessionExerciseId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncSetData clone() => SyncSetData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncSetData copyWith(void Function(SyncSetData) updates) => super.copyWith((message) => updates(message as SyncSetData)) as SyncSetData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncSetData create() => SyncSetData._();
  SyncSetData createEmptyInstance() => create();
  static $pb.PbList<SyncSetData> createRepeated() => $pb.PbList<SyncSetData>();
  @$core.pragma('dart2js:noInline')
  static SyncSetData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncSetData>(create);
  static SyncSetData? _defaultInstance;

  SyncSetData_SetIdentifier whichSetIdentifier() => _SyncSetData_SetIdentifierByTag[$_whichOneof(0)]!;
  void clearSetIdentifier() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get weightKg => $_getN(1);
  @$pb.TagNumber(2)
  set weightKg($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWeightKg() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeightKg() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get reps => $_getIZ(2);
  @$pb.TagNumber(3)
  set reps($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReps() => $_has(2);
  @$pb.TagNumber(3)
  void clearReps() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get timeSeconds => $_getIZ(3);
  @$pb.TagNumber(4)
  set timeSeconds($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimeSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimeSeconds() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get distanceM => $_getN(4);
  @$pb.TagNumber(5)
  set distanceM($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDistanceM() => $_has(4);
  @$pb.TagNumber(5)
  void clearDistanceM() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isCompleted => $_getBF(5);
  @$pb.TagNumber(6)
  set isCompleted($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsCompleted() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsCompleted() => clearField(6);

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

  @$pb.TagNumber(9)
  $core.String get sessionExerciseId => $_getSZ(8);
  @$pb.TagNumber(9)
  set sessionExerciseId($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSessionExerciseId() => $_has(8);
  @$pb.TagNumber(9)
  void clearSessionExerciseId() => clearField(9);
}

enum SyncExerciseData_ExerciseIdentifier {
  id, 
  newExercise, 
  notSet
}

class SyncExerciseData extends $pb.GeneratedMessage {
  factory SyncExerciseData({
    $core.String? id,
    NewExerciseData? newExercise,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (newExercise != null) {
      $result.newExercise = newExercise;
    }
    return $result;
  }
  SyncExerciseData._() : super();
  factory SyncExerciseData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncExerciseData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, SyncExerciseData_ExerciseIdentifier> _SyncExerciseData_ExerciseIdentifierByTag = {
    1 : SyncExerciseData_ExerciseIdentifier.id,
    2 : SyncExerciseData_ExerciseIdentifier.newExercise,
    0 : SyncExerciseData_ExerciseIdentifier.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncExerciseData', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<NewExerciseData>(2, _omitFieldNames ? '' : 'newExercise', subBuilder: NewExerciseData.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncExerciseData clone() => SyncExerciseData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncExerciseData copyWith(void Function(SyncExerciseData) updates) => super.copyWith((message) => updates(message as SyncExerciseData)) as SyncExerciseData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncExerciseData create() => SyncExerciseData._();
  SyncExerciseData createEmptyInstance() => create();
  static $pb.PbList<SyncExerciseData> createRepeated() => $pb.PbList<SyncExerciseData>();
  @$core.pragma('dart2js:noInline')
  static SyncExerciseData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncExerciseData>(create);
  static SyncExerciseData? _defaultInstance;

  SyncExerciseData_ExerciseIdentifier whichExerciseIdentifier() => _SyncExerciseData_ExerciseIdentifierByTag[$_whichOneof(0)]!;
  void clearExerciseIdentifier() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  NewExerciseData get newExercise => $_getN(1);
  @$pb.TagNumber(2)
  set newExercise(NewExerciseData v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasNewExercise() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewExercise() => clearField(2);
  @$pb.TagNumber(2)
  NewExerciseData ensureNewExercise() => $_ensure(1);
}

class NewExerciseData extends $pb.GeneratedMessage {
  factory NewExerciseData({
    $core.String? exerciseId,
    $core.int? displayOrder,
    $core.String? sectionName,
    $core.int? numSets,
    $core.String? supersetId,
  }) {
    final $result = create();
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
    if (supersetId != null) {
      $result.supersetId = supersetId;
    }
    return $result;
  }
  NewExerciseData._() : super();
  factory NewExerciseData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NewExerciseData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NewExerciseData', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'exerciseId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'displayOrder', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'sectionName')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'numSets', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'supersetId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NewExerciseData clone() => NewExerciseData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NewExerciseData copyWith(void Function(NewExerciseData) updates) => super.copyWith((message) => updates(message as NewExerciseData)) as NewExerciseData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NewExerciseData create() => NewExerciseData._();
  NewExerciseData createEmptyInstance() => create();
  static $pb.PbList<NewExerciseData> createRepeated() => $pb.PbList<NewExerciseData>();
  @$core.pragma('dart2js:noInline')
  static NewExerciseData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NewExerciseData>(create);
  static NewExerciseData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get exerciseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set exerciseId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasExerciseId() => $_has(0);
  @$pb.TagNumber(1)
  void clearExerciseId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get displayOrder => $_getIZ(1);
  @$pb.TagNumber(2)
  set displayOrder($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisplayOrder() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayOrder() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get sectionName => $_getSZ(2);
  @$pb.TagNumber(3)
  set sectionName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSectionName() => $_has(2);
  @$pb.TagNumber(3)
  void clearSectionName() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get numSets => $_getIZ(3);
  @$pb.TagNumber(4)
  set numSets($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNumSets() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumSets() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get supersetId => $_getSZ(4);
  @$pb.TagNumber(5)
  set supersetId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSupersetId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSupersetId() => clearField(5);
}

class SyncSessionResponse extends $pb.GeneratedMessage {
  factory SyncSessionResponse({
    Session? session,
    $core.bool? success,
  }) {
    final $result = create();
    if (session != null) {
      $result.session = session;
    }
    if (success != null) {
      $result.success = success;
    }
    return $result;
  }
  SyncSessionResponse._() : super();
  factory SyncSessionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncSessionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncSessionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Session>(1, _omitFieldNames ? '' : 'session', subBuilder: Session.create)
    ..aOB(2, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncSessionResponse clone() => SyncSessionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncSessionResponse copyWith(void Function(SyncSessionResponse) updates) => super.copyWith((message) => updates(message as SyncSessionResponse)) as SyncSessionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncSessionResponse create() => SyncSessionResponse._();
  SyncSessionResponse createEmptyInstance() => create();
  static $pb.PbList<SyncSessionResponse> createRepeated() => $pb.PbList<SyncSessionResponse>();
  @$core.pragma('dart2js:noInline')
  static SyncSessionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncSessionResponse>(create);
  static SyncSessionResponse? _defaultInstance;

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

  @$pb.TagNumber(2)
  $core.bool get success => $_getBF(1);
  @$pb.TagNumber(2)
  set success($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSuccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearSuccess() => clearField(2);
}

/// FinishSession
class FinishSessionRequest extends $pb.GeneratedMessage {
  factory FinishSessionRequest({
    $core.String? id,
    $core.String? notes,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
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
    ..aOS(2, _omitFieldNames ? '' : 'notes')
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
  $core.String get notes => $_getSZ(1);
  @$pb.TagNumber(2)
  set notes($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNotes() => $_has(1);
  @$pb.TagNumber(2)
  void clearNotes() => clearField(2);
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
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  AbandonSessionRequest._() : super();
  factory AbandonSessionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AbandonSessionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AbandonSessionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
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
    $2.WorkoutStatus? status,
    $core.String? startDate,
    $core.String? endDate,
    $2.PaginationRequest? pagination,
  }) {
    final $result = create();
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
    ..e<$2.WorkoutStatus>(1, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: $2.WorkoutStatus.WORKOUT_STATUS_UNSPECIFIED, valueOf: $2.WorkoutStatus.valueOf, enumValues: $2.WorkoutStatus.values)
    ..aOS(2, _omitFieldNames ? '' : 'startDate')
    ..aOS(3, _omitFieldNames ? '' : 'endDate')
    ..aOM<$2.PaginationRequest>(4, _omitFieldNames ? '' : 'pagination', subBuilder: $2.PaginationRequest.create)
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
  $2.WorkoutStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status($2.WorkoutStatus v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get startDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set startDate($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartDate() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get endDate => $_getSZ(2);
  @$pb.TagNumber(3)
  set endDate($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEndDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndDate() => clearField(3);

  @$pb.TagNumber(4)
  $2.PaginationRequest get pagination => $_getN(3);
  @$pb.TagNumber(4)
  set pagination($2.PaginationRequest v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasPagination() => $_has(3);
  @$pb.TagNumber(4)
  void clearPagination() => clearField(4);
  @$pb.TagNumber(4)
  $2.PaginationRequest ensurePagination() => $_ensure(3);
}

class ListSessionsResponse extends $pb.GeneratedMessage {
  factory ListSessionsResponse({
    $core.Iterable<SessionSummary>? sessions,
    $2.PaginationResponse? pagination,
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
    ..aOM<$2.PaginationResponse>(2, _omitFieldNames ? '' : 'pagination', subBuilder: $2.PaginationResponse.create)
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
  $2.PaginationResponse get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($2.PaginationResponse v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => clearField(2);
  @$pb.TagNumber(2)
  $2.PaginationResponse ensurePagination() => $_ensure(1);
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
  $async.Future<SyncSessionResponse> syncSession($pb.ClientContext? ctx, SyncSessionRequest request) =>
    _client.invoke<SyncSessionResponse>(ctx, 'SessionService', 'SyncSession', request, SyncSessionResponse())
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
