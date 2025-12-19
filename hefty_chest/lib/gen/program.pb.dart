//
//  Generated code. Do not modify.
//  source: program.proto
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
import 'workout.pb.dart' as $4;

/// Program summary
class ProgramSummary extends $pb.GeneratedMessage {
  factory ProgramSummary({
    $core.String? id,
    $core.String? userId,
    $core.String? name,
    $core.String? description,
    $core.int? durationWeeks,
    $core.int? durationDays,
    $core.int? totalWorkoutDays,
    $core.int? totalRestDays,
    $core.bool? isActive,
    $core.bool? isArchived,
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
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (durationWeeks != null) {
      $result.durationWeeks = durationWeeks;
    }
    if (durationDays != null) {
      $result.durationDays = durationDays;
    }
    if (totalWorkoutDays != null) {
      $result.totalWorkoutDays = totalWorkoutDays;
    }
    if (totalRestDays != null) {
      $result.totalRestDays = totalRestDays;
    }
    if (isActive != null) {
      $result.isActive = isActive;
    }
    if (isArchived != null) {
      $result.isArchived = isArchived;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    return $result;
  }
  ProgramSummary._() : super();
  factory ProgramSummary.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProgramSummary.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProgramSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'durationWeeks', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'durationDays', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'totalWorkoutDays', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'totalRestDays', $pb.PbFieldType.O3)
    ..aOB(9, _omitFieldNames ? '' : 'isActive')
    ..aOB(10, _omitFieldNames ? '' : 'isArchived')
    ..aOM<$1.Timestamp>(11, _omitFieldNames ? '' : 'createdAt', subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(12, _omitFieldNames ? '' : 'updatedAt', subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProgramSummary clone() => ProgramSummary()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProgramSummary copyWith(void Function(ProgramSummary) updates) => super.copyWith((message) => updates(message as ProgramSummary)) as ProgramSummary;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProgramSummary create() => ProgramSummary._();
  ProgramSummary createEmptyInstance() => create();
  static $pb.PbList<ProgramSummary> createRepeated() => $pb.PbList<ProgramSummary>();
  @$core.pragma('dart2js:noInline')
  static ProgramSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProgramSummary>(create);
  static ProgramSummary? _defaultInstance;

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
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get durationWeeks => $_getIZ(4);
  @$pb.TagNumber(5)
  set durationWeeks($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDurationWeeks() => $_has(4);
  @$pb.TagNumber(5)
  void clearDurationWeeks() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get durationDays => $_getIZ(5);
  @$pb.TagNumber(6)
  set durationDays($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDurationDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearDurationDays() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get totalWorkoutDays => $_getIZ(6);
  @$pb.TagNumber(7)
  set totalWorkoutDays($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalWorkoutDays() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalWorkoutDays() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get totalRestDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set totalRestDays($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalRestDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalRestDays() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isActive => $_getBF(8);
  @$pb.TagNumber(9)
  set isActive($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasIsActive() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsActive() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isArchived => $_getBF(9);
  @$pb.TagNumber(10)
  set isArchived($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasIsArchived() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsArchived() => clearField(10);

  @$pb.TagNumber(11)
  $1.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(11)
  set createdAt($1.Timestamp v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => clearField(11);
  @$pb.TagNumber(11)
  $1.Timestamp ensureCreatedAt() => $_ensure(10);

  @$pb.TagNumber(12)
  $1.Timestamp get updatedAt => $_getN(11);
  @$pb.TagNumber(12)
  set updatedAt($1.Timestamp v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasUpdatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdatedAt() => clearField(12);
  @$pb.TagNumber(12)
  $1.Timestamp ensureUpdatedAt() => $_ensure(11);
}

/// Program with full details
class Program extends $pb.GeneratedMessage {
  factory Program({
    $core.String? id,
    $core.String? userId,
    $core.String? name,
    $core.String? description,
    $core.int? durationWeeks,
    $core.int? durationDays,
    $core.int? totalWorkoutDays,
    $core.int? totalRestDays,
    $core.bool? isActive,
    $core.bool? isArchived,
    $core.Iterable<ProgramDay>? days,
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
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (durationWeeks != null) {
      $result.durationWeeks = durationWeeks;
    }
    if (durationDays != null) {
      $result.durationDays = durationDays;
    }
    if (totalWorkoutDays != null) {
      $result.totalWorkoutDays = totalWorkoutDays;
    }
    if (totalRestDays != null) {
      $result.totalRestDays = totalRestDays;
    }
    if (isActive != null) {
      $result.isActive = isActive;
    }
    if (isArchived != null) {
      $result.isArchived = isArchived;
    }
    if (days != null) {
      $result.days.addAll(days);
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    return $result;
  }
  Program._() : super();
  factory Program.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Program.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Program', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'durationWeeks', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'durationDays', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'totalWorkoutDays', $pb.PbFieldType.O3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'totalRestDays', $pb.PbFieldType.O3)
    ..aOB(9, _omitFieldNames ? '' : 'isActive')
    ..aOB(10, _omitFieldNames ? '' : 'isArchived')
    ..pc<ProgramDay>(11, _omitFieldNames ? '' : 'days', $pb.PbFieldType.PM, subBuilder: ProgramDay.create)
    ..aOM<$1.Timestamp>(12, _omitFieldNames ? '' : 'createdAt', subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(13, _omitFieldNames ? '' : 'updatedAt', subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Program clone() => Program()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Program copyWith(void Function(Program) updates) => super.copyWith((message) => updates(message as Program)) as Program;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Program create() => Program._();
  Program createEmptyInstance() => create();
  static $pb.PbList<Program> createRepeated() => $pb.PbList<Program>();
  @$core.pragma('dart2js:noInline')
  static Program getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Program>(create);
  static Program? _defaultInstance;

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
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get durationWeeks => $_getIZ(4);
  @$pb.TagNumber(5)
  set durationWeeks($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDurationWeeks() => $_has(4);
  @$pb.TagNumber(5)
  void clearDurationWeeks() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get durationDays => $_getIZ(5);
  @$pb.TagNumber(6)
  set durationDays($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDurationDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearDurationDays() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get totalWorkoutDays => $_getIZ(6);
  @$pb.TagNumber(7)
  set totalWorkoutDays($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalWorkoutDays() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalWorkoutDays() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get totalRestDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set totalRestDays($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTotalRestDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalRestDays() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isActive => $_getBF(8);
  @$pb.TagNumber(9)
  set isActive($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasIsActive() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsActive() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isArchived => $_getBF(9);
  @$pb.TagNumber(10)
  set isArchived($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasIsArchived() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsArchived() => clearField(10);

  @$pb.TagNumber(11)
  $core.List<ProgramDay> get days => $_getList(10);

  @$pb.TagNumber(12)
  $1.Timestamp get createdAt => $_getN(11);
  @$pb.TagNumber(12)
  set createdAt($1.Timestamp v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasCreatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearCreatedAt() => clearField(12);
  @$pb.TagNumber(12)
  $1.Timestamp ensureCreatedAt() => $_ensure(11);

  @$pb.TagNumber(13)
  $1.Timestamp get updatedAt => $_getN(12);
  @$pb.TagNumber(13)
  set updatedAt($1.Timestamp v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasUpdatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearUpdatedAt() => clearField(13);
  @$pb.TagNumber(13)
  $1.Timestamp ensureUpdatedAt() => $_ensure(12);
}

/// Program day
class ProgramDay extends $pb.GeneratedMessage {
  factory ProgramDay({
    $core.String? id,
    $core.String? programId,
    $core.int? dayNumber,
    $2.ProgramDayType? dayType,
    $core.String? workoutTemplateId,
    $core.String? workoutName,
    $core.String? customName,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (programId != null) {
      $result.programId = programId;
    }
    if (dayNumber != null) {
      $result.dayNumber = dayNumber;
    }
    if (dayType != null) {
      $result.dayType = dayType;
    }
    if (workoutTemplateId != null) {
      $result.workoutTemplateId = workoutTemplateId;
    }
    if (workoutName != null) {
      $result.workoutName = workoutName;
    }
    if (customName != null) {
      $result.customName = customName;
    }
    return $result;
  }
  ProgramDay._() : super();
  factory ProgramDay.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProgramDay.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProgramDay', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'programId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'dayNumber', $pb.PbFieldType.O3)
    ..e<$2.ProgramDayType>(4, _omitFieldNames ? '' : 'dayType', $pb.PbFieldType.OE, defaultOrMaker: $2.ProgramDayType.PROGRAM_DAY_TYPE_UNSPECIFIED, valueOf: $2.ProgramDayType.valueOf, enumValues: $2.ProgramDayType.values)
    ..aOS(5, _omitFieldNames ? '' : 'workoutTemplateId')
    ..aOS(6, _omitFieldNames ? '' : 'workoutName')
    ..aOS(7, _omitFieldNames ? '' : 'customName')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProgramDay clone() => ProgramDay()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProgramDay copyWith(void Function(ProgramDay) updates) => super.copyWith((message) => updates(message as ProgramDay)) as ProgramDay;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProgramDay create() => ProgramDay._();
  ProgramDay createEmptyInstance() => create();
  static $pb.PbList<ProgramDay> createRepeated() => $pb.PbList<ProgramDay>();
  @$core.pragma('dart2js:noInline')
  static ProgramDay getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProgramDay>(create);
  static ProgramDay? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get programId => $_getSZ(1);
  @$pb.TagNumber(2)
  set programId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProgramId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProgramId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get dayNumber => $_getIZ(2);
  @$pb.TagNumber(3)
  set dayNumber($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDayNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearDayNumber() => clearField(3);

  @$pb.TagNumber(4)
  $2.ProgramDayType get dayType => $_getN(3);
  @$pb.TagNumber(4)
  set dayType($2.ProgramDayType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasDayType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDayType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get workoutTemplateId => $_getSZ(4);
  @$pb.TagNumber(5)
  set workoutTemplateId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWorkoutTemplateId() => $_has(4);
  @$pb.TagNumber(5)
  void clearWorkoutTemplateId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get workoutName => $_getSZ(5);
  @$pb.TagNumber(6)
  set workoutName($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasWorkoutName() => $_has(5);
  @$pb.TagNumber(6)
  void clearWorkoutName() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get customName => $_getSZ(6);
  @$pb.TagNumber(7)
  set customName($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasCustomName() => $_has(6);
  @$pb.TagNumber(7)
  void clearCustomName() => clearField(7);
}

/// ListPrograms
class ListProgramsRequest extends $pb.GeneratedMessage {
  factory ListProgramsRequest({
    $core.bool? includeArchived,
    $2.PaginationRequest? pagination,
  }) {
    final $result = create();
    if (includeArchived != null) {
      $result.includeArchived = includeArchived;
    }
    if (pagination != null) {
      $result.pagination = pagination;
    }
    return $result;
  }
  ListProgramsRequest._() : super();
  factory ListProgramsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListProgramsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListProgramsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'includeArchived')
    ..aOM<$2.PaginationRequest>(2, _omitFieldNames ? '' : 'pagination', subBuilder: $2.PaginationRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListProgramsRequest clone() => ListProgramsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListProgramsRequest copyWith(void Function(ListProgramsRequest) updates) => super.copyWith((message) => updates(message as ListProgramsRequest)) as ListProgramsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProgramsRequest create() => ListProgramsRequest._();
  ListProgramsRequest createEmptyInstance() => create();
  static $pb.PbList<ListProgramsRequest> createRepeated() => $pb.PbList<ListProgramsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListProgramsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListProgramsRequest>(create);
  static ListProgramsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get includeArchived => $_getBF(0);
  @$pb.TagNumber(1)
  set includeArchived($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIncludeArchived() => $_has(0);
  @$pb.TagNumber(1)
  void clearIncludeArchived() => clearField(1);

  @$pb.TagNumber(2)
  $2.PaginationRequest get pagination => $_getN(1);
  @$pb.TagNumber(2)
  set pagination($2.PaginationRequest v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPagination() => $_has(1);
  @$pb.TagNumber(2)
  void clearPagination() => clearField(2);
  @$pb.TagNumber(2)
  $2.PaginationRequest ensurePagination() => $_ensure(1);
}

class ListProgramsResponse extends $pb.GeneratedMessage {
  factory ListProgramsResponse({
    $core.Iterable<ProgramSummary>? programs,
    $2.PaginationResponse? pagination,
  }) {
    final $result = create();
    if (programs != null) {
      $result.programs.addAll(programs);
    }
    if (pagination != null) {
      $result.pagination = pagination;
    }
    return $result;
  }
  ListProgramsResponse._() : super();
  factory ListProgramsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListProgramsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListProgramsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<ProgramSummary>(1, _omitFieldNames ? '' : 'programs', $pb.PbFieldType.PM, subBuilder: ProgramSummary.create)
    ..aOM<$2.PaginationResponse>(2, _omitFieldNames ? '' : 'pagination', subBuilder: $2.PaginationResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListProgramsResponse clone() => ListProgramsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListProgramsResponse copyWith(void Function(ListProgramsResponse) updates) => super.copyWith((message) => updates(message as ListProgramsResponse)) as ListProgramsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProgramsResponse create() => ListProgramsResponse._();
  ListProgramsResponse createEmptyInstance() => create();
  static $pb.PbList<ListProgramsResponse> createRepeated() => $pb.PbList<ListProgramsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListProgramsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListProgramsResponse>(create);
  static ListProgramsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ProgramSummary> get programs => $_getList(0);

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

/// GetProgram
class GetProgramRequest extends $pb.GeneratedMessage {
  factory GetProgramRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetProgramRequest._() : super();
  factory GetProgramRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetProgramRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetProgramRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetProgramRequest clone() => GetProgramRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetProgramRequest copyWith(void Function(GetProgramRequest) updates) => super.copyWith((message) => updates(message as GetProgramRequest)) as GetProgramRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProgramRequest create() => GetProgramRequest._();
  GetProgramRequest createEmptyInstance() => create();
  static $pb.PbList<GetProgramRequest> createRepeated() => $pb.PbList<GetProgramRequest>();
  @$core.pragma('dart2js:noInline')
  static GetProgramRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProgramRequest>(create);
  static GetProgramRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GetProgramResponse extends $pb.GeneratedMessage {
  factory GetProgramResponse({
    Program? program,
  }) {
    final $result = create();
    if (program != null) {
      $result.program = program;
    }
    return $result;
  }
  GetProgramResponse._() : super();
  factory GetProgramResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetProgramResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetProgramResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Program>(1, _omitFieldNames ? '' : 'program', subBuilder: Program.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetProgramResponse clone() => GetProgramResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetProgramResponse copyWith(void Function(GetProgramResponse) updates) => super.copyWith((message) => updates(message as GetProgramResponse)) as GetProgramResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProgramResponse create() => GetProgramResponse._();
  GetProgramResponse createEmptyInstance() => create();
  static $pb.PbList<GetProgramResponse> createRepeated() => $pb.PbList<GetProgramResponse>();
  @$core.pragma('dart2js:noInline')
  static GetProgramResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProgramResponse>(create);
  static GetProgramResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Program get program => $_getN(0);
  @$pb.TagNumber(1)
  set program(Program v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProgram() => $_has(0);
  @$pb.TagNumber(1)
  void clearProgram() => clearField(1);
  @$pb.TagNumber(1)
  Program ensureProgram() => $_ensure(0);
}

/// CreateProgram
class CreateProgramRequest extends $pb.GeneratedMessage {
  factory CreateProgramRequest({
    $core.String? name,
    $core.String? description,
    $core.int? durationWeeks,
    $core.int? durationDays,
    $core.Iterable<CreateProgramDay>? days,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (durationWeeks != null) {
      $result.durationWeeks = durationWeeks;
    }
    if (durationDays != null) {
      $result.durationDays = durationDays;
    }
    if (days != null) {
      $result.days.addAll(days);
    }
    return $result;
  }
  CreateProgramRequest._() : super();
  factory CreateProgramRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateProgramRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateProgramRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'durationWeeks', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'durationDays', $pb.PbFieldType.O3)
    ..pc<CreateProgramDay>(5, _omitFieldNames ? '' : 'days', $pb.PbFieldType.PM, subBuilder: CreateProgramDay.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateProgramRequest clone() => CreateProgramRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateProgramRequest copyWith(void Function(CreateProgramRequest) updates) => super.copyWith((message) => updates(message as CreateProgramRequest)) as CreateProgramRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProgramRequest create() => CreateProgramRequest._();
  CreateProgramRequest createEmptyInstance() => create();
  static $pb.PbList<CreateProgramRequest> createRepeated() => $pb.PbList<CreateProgramRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateProgramRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateProgramRequest>(create);
  static CreateProgramRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get durationWeeks => $_getIZ(2);
  @$pb.TagNumber(3)
  set durationWeeks($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDurationWeeks() => $_has(2);
  @$pb.TagNumber(3)
  void clearDurationWeeks() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get durationDays => $_getIZ(3);
  @$pb.TagNumber(4)
  set durationDays($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDurationDays() => $_has(3);
  @$pb.TagNumber(4)
  void clearDurationDays() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<CreateProgramDay> get days => $_getList(4);
}

class CreateProgramDay extends $pb.GeneratedMessage {
  factory CreateProgramDay({
    $core.int? dayNumber,
    $2.ProgramDayType? dayType,
    $core.String? workoutTemplateId,
    $core.String? customName,
  }) {
    final $result = create();
    if (dayNumber != null) {
      $result.dayNumber = dayNumber;
    }
    if (dayType != null) {
      $result.dayType = dayType;
    }
    if (workoutTemplateId != null) {
      $result.workoutTemplateId = workoutTemplateId;
    }
    if (customName != null) {
      $result.customName = customName;
    }
    return $result;
  }
  CreateProgramDay._() : super();
  factory CreateProgramDay.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateProgramDay.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateProgramDay', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'dayNumber', $pb.PbFieldType.O3)
    ..e<$2.ProgramDayType>(2, _omitFieldNames ? '' : 'dayType', $pb.PbFieldType.OE, defaultOrMaker: $2.ProgramDayType.PROGRAM_DAY_TYPE_UNSPECIFIED, valueOf: $2.ProgramDayType.valueOf, enumValues: $2.ProgramDayType.values)
    ..aOS(3, _omitFieldNames ? '' : 'workoutTemplateId')
    ..aOS(4, _omitFieldNames ? '' : 'customName')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateProgramDay clone() => CreateProgramDay()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateProgramDay copyWith(void Function(CreateProgramDay) updates) => super.copyWith((message) => updates(message as CreateProgramDay)) as CreateProgramDay;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProgramDay create() => CreateProgramDay._();
  CreateProgramDay createEmptyInstance() => create();
  static $pb.PbList<CreateProgramDay> createRepeated() => $pb.PbList<CreateProgramDay>();
  @$core.pragma('dart2js:noInline')
  static CreateProgramDay getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateProgramDay>(create);
  static CreateProgramDay? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get dayNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set dayNumber($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDayNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearDayNumber() => clearField(1);

  @$pb.TagNumber(2)
  $2.ProgramDayType get dayType => $_getN(1);
  @$pb.TagNumber(2)
  set dayType($2.ProgramDayType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDayType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDayType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get workoutTemplateId => $_getSZ(2);
  @$pb.TagNumber(3)
  set workoutTemplateId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWorkoutTemplateId() => $_has(2);
  @$pb.TagNumber(3)
  void clearWorkoutTemplateId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get customName => $_getSZ(3);
  @$pb.TagNumber(4)
  set customName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCustomName() => $_has(3);
  @$pb.TagNumber(4)
  void clearCustomName() => clearField(4);
}

class CreateProgramResponse extends $pb.GeneratedMessage {
  factory CreateProgramResponse({
    Program? program,
  }) {
    final $result = create();
    if (program != null) {
      $result.program = program;
    }
    return $result;
  }
  CreateProgramResponse._() : super();
  factory CreateProgramResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateProgramResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateProgramResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Program>(1, _omitFieldNames ? '' : 'program', subBuilder: Program.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateProgramResponse clone() => CreateProgramResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateProgramResponse copyWith(void Function(CreateProgramResponse) updates) => super.copyWith((message) => updates(message as CreateProgramResponse)) as CreateProgramResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateProgramResponse create() => CreateProgramResponse._();
  CreateProgramResponse createEmptyInstance() => create();
  static $pb.PbList<CreateProgramResponse> createRepeated() => $pb.PbList<CreateProgramResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateProgramResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateProgramResponse>(create);
  static CreateProgramResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Program get program => $_getN(0);
  @$pb.TagNumber(1)
  set program(Program v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProgram() => $_has(0);
  @$pb.TagNumber(1)
  void clearProgram() => clearField(1);
  @$pb.TagNumber(1)
  Program ensureProgram() => $_ensure(0);
}

/// UpdateProgram
class UpdateProgramRequest extends $pb.GeneratedMessage {
  factory UpdateProgramRequest({
    $core.String? id,
    $core.String? name,
    $core.String? description,
    $core.int? durationWeeks,
    $core.int? durationDays,
    $core.bool? isArchived,
    $core.Iterable<CreateProgramDay>? days,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (durationWeeks != null) {
      $result.durationWeeks = durationWeeks;
    }
    if (durationDays != null) {
      $result.durationDays = durationDays;
    }
    if (isArchived != null) {
      $result.isArchived = isArchived;
    }
    if (days != null) {
      $result.days.addAll(days);
    }
    return $result;
  }
  UpdateProgramRequest._() : super();
  factory UpdateProgramRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateProgramRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateProgramRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'durationWeeks', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'durationDays', $pb.PbFieldType.O3)
    ..aOB(6, _omitFieldNames ? '' : 'isArchived')
    ..pc<CreateProgramDay>(7, _omitFieldNames ? '' : 'days', $pb.PbFieldType.PM, subBuilder: CreateProgramDay.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateProgramRequest clone() => UpdateProgramRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateProgramRequest copyWith(void Function(UpdateProgramRequest) updates) => super.copyWith((message) => updates(message as UpdateProgramRequest)) as UpdateProgramRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProgramRequest create() => UpdateProgramRequest._();
  UpdateProgramRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateProgramRequest> createRepeated() => $pb.PbList<UpdateProgramRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateProgramRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProgramRequest>(create);
  static UpdateProgramRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get durationWeeks => $_getIZ(3);
  @$pb.TagNumber(4)
  set durationWeeks($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDurationWeeks() => $_has(3);
  @$pb.TagNumber(4)
  void clearDurationWeeks() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get durationDays => $_getIZ(4);
  @$pb.TagNumber(5)
  set durationDays($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDurationDays() => $_has(4);
  @$pb.TagNumber(5)
  void clearDurationDays() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isArchived => $_getBF(5);
  @$pb.TagNumber(6)
  set isArchived($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsArchived() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsArchived() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<CreateProgramDay> get days => $_getList(6);
}

class UpdateProgramResponse extends $pb.GeneratedMessage {
  factory UpdateProgramResponse({
    Program? program,
  }) {
    final $result = create();
    if (program != null) {
      $result.program = program;
    }
    return $result;
  }
  UpdateProgramResponse._() : super();
  factory UpdateProgramResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateProgramResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateProgramResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Program>(1, _omitFieldNames ? '' : 'program', subBuilder: Program.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateProgramResponse clone() => UpdateProgramResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateProgramResponse copyWith(void Function(UpdateProgramResponse) updates) => super.copyWith((message) => updates(message as UpdateProgramResponse)) as UpdateProgramResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProgramResponse create() => UpdateProgramResponse._();
  UpdateProgramResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateProgramResponse> createRepeated() => $pb.PbList<UpdateProgramResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateProgramResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProgramResponse>(create);
  static UpdateProgramResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Program get program => $_getN(0);
  @$pb.TagNumber(1)
  set program(Program v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProgram() => $_has(0);
  @$pb.TagNumber(1)
  void clearProgram() => clearField(1);
  @$pb.TagNumber(1)
  Program ensureProgram() => $_ensure(0);
}

/// DeleteProgram
class DeleteProgramRequest extends $pb.GeneratedMessage {
  factory DeleteProgramRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DeleteProgramRequest._() : super();
  factory DeleteProgramRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteProgramRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteProgramRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteProgramRequest clone() => DeleteProgramRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteProgramRequest copyWith(void Function(DeleteProgramRequest) updates) => super.copyWith((message) => updates(message as DeleteProgramRequest)) as DeleteProgramRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteProgramRequest create() => DeleteProgramRequest._();
  DeleteProgramRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteProgramRequest> createRepeated() => $pb.PbList<DeleteProgramRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteProgramRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteProgramRequest>(create);
  static DeleteProgramRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class DeleteProgramResponse extends $pb.GeneratedMessage {
  factory DeleteProgramResponse({
    $core.bool? success,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    return $result;
  }
  DeleteProgramResponse._() : super();
  factory DeleteProgramResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteProgramResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteProgramResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteProgramResponse clone() => DeleteProgramResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteProgramResponse copyWith(void Function(DeleteProgramResponse) updates) => super.copyWith((message) => updates(message as DeleteProgramResponse)) as DeleteProgramResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteProgramResponse create() => DeleteProgramResponse._();
  DeleteProgramResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteProgramResponse> createRepeated() => $pb.PbList<DeleteProgramResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteProgramResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteProgramResponse>(create);
  static DeleteProgramResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);
}

/// SetActiveProgram
class SetActiveProgramRequest extends $pb.GeneratedMessage {
  factory SetActiveProgramRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  SetActiveProgramRequest._() : super();
  factory SetActiveProgramRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetActiveProgramRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetActiveProgramRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetActiveProgramRequest clone() => SetActiveProgramRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetActiveProgramRequest copyWith(void Function(SetActiveProgramRequest) updates) => super.copyWith((message) => updates(message as SetActiveProgramRequest)) as SetActiveProgramRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetActiveProgramRequest create() => SetActiveProgramRequest._();
  SetActiveProgramRequest createEmptyInstance() => create();
  static $pb.PbList<SetActiveProgramRequest> createRepeated() => $pb.PbList<SetActiveProgramRequest>();
  @$core.pragma('dart2js:noInline')
  static SetActiveProgramRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetActiveProgramRequest>(create);
  static SetActiveProgramRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class SetActiveProgramResponse extends $pb.GeneratedMessage {
  factory SetActiveProgramResponse({
    Program? program,
  }) {
    final $result = create();
    if (program != null) {
      $result.program = program;
    }
    return $result;
  }
  SetActiveProgramResponse._() : super();
  factory SetActiveProgramResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetActiveProgramResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetActiveProgramResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Program>(1, _omitFieldNames ? '' : 'program', subBuilder: Program.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetActiveProgramResponse clone() => SetActiveProgramResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetActiveProgramResponse copyWith(void Function(SetActiveProgramResponse) updates) => super.copyWith((message) => updates(message as SetActiveProgramResponse)) as SetActiveProgramResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetActiveProgramResponse create() => SetActiveProgramResponse._();
  SetActiveProgramResponse createEmptyInstance() => create();
  static $pb.PbList<SetActiveProgramResponse> createRepeated() => $pb.PbList<SetActiveProgramResponse>();
  @$core.pragma('dart2js:noInline')
  static SetActiveProgramResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetActiveProgramResponse>(create);
  static SetActiveProgramResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Program get program => $_getN(0);
  @$pb.TagNumber(1)
  set program(Program v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProgram() => $_has(0);
  @$pb.TagNumber(1)
  void clearProgram() => clearField(1);
  @$pb.TagNumber(1)
  Program ensureProgram() => $_ensure(0);
}

/// GetTodayWorkout
class GetTodayWorkoutRequest extends $pb.GeneratedMessage {
  factory GetTodayWorkoutRequest() => create();
  GetTodayWorkoutRequest._() : super();
  factory GetTodayWorkoutRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTodayWorkoutRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTodayWorkoutRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTodayWorkoutRequest clone() => GetTodayWorkoutRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTodayWorkoutRequest copyWith(void Function(GetTodayWorkoutRequest) updates) => super.copyWith((message) => updates(message as GetTodayWorkoutRequest)) as GetTodayWorkoutRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTodayWorkoutRequest create() => GetTodayWorkoutRequest._();
  GetTodayWorkoutRequest createEmptyInstance() => create();
  static $pb.PbList<GetTodayWorkoutRequest> createRepeated() => $pb.PbList<GetTodayWorkoutRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTodayWorkoutRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTodayWorkoutRequest>(create);
  static GetTodayWorkoutRequest? _defaultInstance;
}

class GetTodayWorkoutResponse extends $pb.GeneratedMessage {
  factory GetTodayWorkoutResponse({
    $core.bool? hasWorkout,
    $core.int? dayNumber,
    $2.ProgramDayType? dayType,
    $4.Workout? workout_4,
    Program? program,
  }) {
    final $result = create();
    if (hasWorkout != null) {
      $result.hasWorkout = hasWorkout;
    }
    if (dayNumber != null) {
      $result.dayNumber = dayNumber;
    }
    if (dayType != null) {
      $result.dayType = dayType;
    }
    if (workout_4 != null) {
      $result.workout_4 = workout_4;
    }
    if (program != null) {
      $result.program = program;
    }
    return $result;
  }
  GetTodayWorkoutResponse._() : super();
  factory GetTodayWorkoutResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTodayWorkoutResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTodayWorkoutResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hasWorkout')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'dayNumber', $pb.PbFieldType.O3)
    ..e<$2.ProgramDayType>(3, _omitFieldNames ? '' : 'dayType', $pb.PbFieldType.OE, defaultOrMaker: $2.ProgramDayType.PROGRAM_DAY_TYPE_UNSPECIFIED, valueOf: $2.ProgramDayType.valueOf, enumValues: $2.ProgramDayType.values)
    ..aOM<$4.Workout>(4, _omitFieldNames ? '' : 'workout', subBuilder: $4.Workout.create)
    ..aOM<Program>(5, _omitFieldNames ? '' : 'program', subBuilder: Program.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTodayWorkoutResponse clone() => GetTodayWorkoutResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTodayWorkoutResponse copyWith(void Function(GetTodayWorkoutResponse) updates) => super.copyWith((message) => updates(message as GetTodayWorkoutResponse)) as GetTodayWorkoutResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTodayWorkoutResponse create() => GetTodayWorkoutResponse._();
  GetTodayWorkoutResponse createEmptyInstance() => create();
  static $pb.PbList<GetTodayWorkoutResponse> createRepeated() => $pb.PbList<GetTodayWorkoutResponse>();
  @$core.pragma('dart2js:noInline')
  static GetTodayWorkoutResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTodayWorkoutResponse>(create);
  static GetTodayWorkoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get hasWorkout => $_getBF(0);
  @$pb.TagNumber(1)
  set hasWorkout($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHasWorkout() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasWorkout() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get dayNumber => $_getIZ(1);
  @$pb.TagNumber(2)
  set dayNumber($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDayNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearDayNumber() => clearField(2);

  @$pb.TagNumber(3)
  $2.ProgramDayType get dayType => $_getN(2);
  @$pb.TagNumber(3)
  set dayType($2.ProgramDayType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasDayType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDayType() => clearField(3);

  @$pb.TagNumber(4)
  $4.Workout get workout_4 => $_getN(3);
  @$pb.TagNumber(4)
  set workout_4($4.Workout v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasWorkout_4() => $_has(3);
  @$pb.TagNumber(4)
  void clearWorkout_4() => clearField(4);
  @$pb.TagNumber(4)
  $4.Workout ensureWorkout_4() => $_ensure(3);

  @$pb.TagNumber(5)
  Program get program => $_getN(4);
  @$pb.TagNumber(5)
  set program(Program v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasProgram() => $_has(4);
  @$pb.TagNumber(5)
  void clearProgram() => clearField(5);
  @$pb.TagNumber(5)
  Program ensureProgram() => $_ensure(4);
}

class ProgramServiceApi {
  $pb.RpcClient _client;
  ProgramServiceApi(this._client);

  $async.Future<ListProgramsResponse> listPrograms($pb.ClientContext? ctx, ListProgramsRequest request) =>
    _client.invoke<ListProgramsResponse>(ctx, 'ProgramService', 'ListPrograms', request, ListProgramsResponse())
  ;
  $async.Future<GetProgramResponse> getProgram($pb.ClientContext? ctx, GetProgramRequest request) =>
    _client.invoke<GetProgramResponse>(ctx, 'ProgramService', 'GetProgram', request, GetProgramResponse())
  ;
  $async.Future<CreateProgramResponse> createProgram($pb.ClientContext? ctx, CreateProgramRequest request) =>
    _client.invoke<CreateProgramResponse>(ctx, 'ProgramService', 'CreateProgram', request, CreateProgramResponse())
  ;
  $async.Future<UpdateProgramResponse> updateProgram($pb.ClientContext? ctx, UpdateProgramRequest request) =>
    _client.invoke<UpdateProgramResponse>(ctx, 'ProgramService', 'UpdateProgram', request, UpdateProgramResponse())
  ;
  $async.Future<DeleteProgramResponse> deleteProgram($pb.ClientContext? ctx, DeleteProgramRequest request) =>
    _client.invoke<DeleteProgramResponse>(ctx, 'ProgramService', 'DeleteProgram', request, DeleteProgramResponse())
  ;
  $async.Future<SetActiveProgramResponse> setActiveProgram($pb.ClientContext? ctx, SetActiveProgramRequest request) =>
    _client.invoke<SetActiveProgramResponse>(ctx, 'ProgramService', 'SetActiveProgram', request, SetActiveProgramResponse())
  ;
  $async.Future<GetTodayWorkoutResponse> getTodayWorkout($pb.ClientContext? ctx, GetTodayWorkoutRequest request) =>
    _client.invoke<GetTodayWorkoutResponse>(ctx, 'ProgramService', 'GetTodayWorkout', request, GetTodayWorkoutResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
