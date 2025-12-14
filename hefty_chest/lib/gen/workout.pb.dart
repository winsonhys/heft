//
//  Generated code. Do not modify.
//  source: workout.proto
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

/// Workout template (summary)
class WorkoutSummary extends $pb.GeneratedMessage {
  factory WorkoutSummary({
    $core.String? id,
    $core.String? userId,
    $core.String? name,
    $core.String? description,
    $core.int? totalExercises,
    $core.int? totalSets,
    $core.int? estimatedDurationMinutes,
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
    if (totalExercises != null) {
      $result.totalExercises = totalExercises;
    }
    if (totalSets != null) {
      $result.totalSets = totalSets;
    }
    if (estimatedDurationMinutes != null) {
      $result.estimatedDurationMinutes = estimatedDurationMinutes;
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
  WorkoutSummary._() : super();
  factory WorkoutSummary.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WorkoutSummary.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkoutSummary', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'totalExercises', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'totalSets', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'estimatedDurationMinutes', $pb.PbFieldType.O3)
    ..aOB(8, _omitFieldNames ? '' : 'isArchived')
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'createdAt', subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(10, _omitFieldNames ? '' : 'updatedAt', subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WorkoutSummary clone() => WorkoutSummary()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WorkoutSummary copyWith(void Function(WorkoutSummary) updates) => super.copyWith((message) => updates(message as WorkoutSummary)) as WorkoutSummary;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkoutSummary create() => WorkoutSummary._();
  WorkoutSummary createEmptyInstance() => create();
  static $pb.PbList<WorkoutSummary> createRepeated() => $pb.PbList<WorkoutSummary>();
  @$core.pragma('dart2js:noInline')
  static WorkoutSummary getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkoutSummary>(create);
  static WorkoutSummary? _defaultInstance;

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
  $core.int get totalExercises => $_getIZ(4);
  @$pb.TagNumber(5)
  set totalExercises($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalExercises() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalExercises() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get totalSets => $_getIZ(5);
  @$pb.TagNumber(6)
  set totalSets($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTotalSets() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalSets() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get estimatedDurationMinutes => $_getIZ(6);
  @$pb.TagNumber(7)
  set estimatedDurationMinutes($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasEstimatedDurationMinutes() => $_has(6);
  @$pb.TagNumber(7)
  void clearEstimatedDurationMinutes() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isArchived => $_getBF(7);
  @$pb.TagNumber(8)
  set isArchived($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIsArchived() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsArchived() => clearField(8);

  @$pb.TagNumber(9)
  $1.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(9)
  set createdAt($1.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensureCreatedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $1.Timestamp get updatedAt => $_getN(9);
  @$pb.TagNumber(10)
  set updatedAt($1.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasUpdatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearUpdatedAt() => clearField(10);
  @$pb.TagNumber(10)
  $1.Timestamp ensureUpdatedAt() => $_ensure(9);
}

/// Workout template (full details)
class Workout extends $pb.GeneratedMessage {
  factory Workout({
    $core.String? id,
    $core.String? userId,
    $core.String? name,
    $core.String? description,
    $core.int? totalExercises,
    $core.int? totalSets,
    $core.int? estimatedDurationMinutes,
    $core.bool? isArchived,
    $core.Iterable<WorkoutSection>? sections,
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
    if (totalExercises != null) {
      $result.totalExercises = totalExercises;
    }
    if (totalSets != null) {
      $result.totalSets = totalSets;
    }
    if (estimatedDurationMinutes != null) {
      $result.estimatedDurationMinutes = estimatedDurationMinutes;
    }
    if (isArchived != null) {
      $result.isArchived = isArchived;
    }
    if (sections != null) {
      $result.sections.addAll(sections);
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    return $result;
  }
  Workout._() : super();
  factory Workout.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Workout.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Workout', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'totalExercises', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'totalSets', $pb.PbFieldType.O3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'estimatedDurationMinutes', $pb.PbFieldType.O3)
    ..aOB(8, _omitFieldNames ? '' : 'isArchived')
    ..pc<WorkoutSection>(9, _omitFieldNames ? '' : 'sections', $pb.PbFieldType.PM, subBuilder: WorkoutSection.create)
    ..aOM<$1.Timestamp>(10, _omitFieldNames ? '' : 'createdAt', subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(11, _omitFieldNames ? '' : 'updatedAt', subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Workout clone() => Workout()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Workout copyWith(void Function(Workout) updates) => super.copyWith((message) => updates(message as Workout)) as Workout;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Workout create() => Workout._();
  Workout createEmptyInstance() => create();
  static $pb.PbList<Workout> createRepeated() => $pb.PbList<Workout>();
  @$core.pragma('dart2js:noInline')
  static Workout getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Workout>(create);
  static Workout? _defaultInstance;

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
  $core.int get totalExercises => $_getIZ(4);
  @$pb.TagNumber(5)
  set totalExercises($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalExercises() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalExercises() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get totalSets => $_getIZ(5);
  @$pb.TagNumber(6)
  set totalSets($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTotalSets() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalSets() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get estimatedDurationMinutes => $_getIZ(6);
  @$pb.TagNumber(7)
  set estimatedDurationMinutes($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasEstimatedDurationMinutes() => $_has(6);
  @$pb.TagNumber(7)
  void clearEstimatedDurationMinutes() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isArchived => $_getBF(7);
  @$pb.TagNumber(8)
  set isArchived($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIsArchived() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsArchived() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<WorkoutSection> get sections => $_getList(8);

  @$pb.TagNumber(10)
  $1.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($1.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => clearField(10);
  @$pb.TagNumber(10)
  $1.Timestamp ensureCreatedAt() => $_ensure(9);

  @$pb.TagNumber(11)
  $1.Timestamp get updatedAt => $_getN(10);
  @$pb.TagNumber(11)
  set updatedAt($1.Timestamp v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasUpdatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearUpdatedAt() => clearField(11);
  @$pb.TagNumber(11)
  $1.Timestamp ensureUpdatedAt() => $_ensure(10);
}

/// Workout section
class WorkoutSection extends $pb.GeneratedMessage {
  factory WorkoutSection({
    $core.String? id,
    $core.String? workoutTemplateId,
    $core.String? name,
    $core.int? displayOrder,
    $core.bool? isSuperset,
    $core.Iterable<SectionItem>? items,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (workoutTemplateId != null) {
      $result.workoutTemplateId = workoutTemplateId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (displayOrder != null) {
      $result.displayOrder = displayOrder;
    }
    if (isSuperset != null) {
      $result.isSuperset = isSuperset;
    }
    if (items != null) {
      $result.items.addAll(items);
    }
    return $result;
  }
  WorkoutSection._() : super();
  factory WorkoutSection.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WorkoutSection.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WorkoutSection', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'workoutTemplateId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'displayOrder', $pb.PbFieldType.O3)
    ..aOB(5, _omitFieldNames ? '' : 'isSuperset')
    ..pc<SectionItem>(6, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: SectionItem.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WorkoutSection clone() => WorkoutSection()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WorkoutSection copyWith(void Function(WorkoutSection) updates) => super.copyWith((message) => updates(message as WorkoutSection)) as WorkoutSection;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WorkoutSection create() => WorkoutSection._();
  WorkoutSection createEmptyInstance() => create();
  static $pb.PbList<WorkoutSection> createRepeated() => $pb.PbList<WorkoutSection>();
  @$core.pragma('dart2js:noInline')
  static WorkoutSection getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WorkoutSection>(create);
  static WorkoutSection? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get workoutTemplateId => $_getSZ(1);
  @$pb.TagNumber(2)
  set workoutTemplateId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWorkoutTemplateId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWorkoutTemplateId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get displayOrder => $_getIZ(3);
  @$pb.TagNumber(4)
  set displayOrder($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDisplayOrder() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayOrder() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isSuperset => $_getBF(4);
  @$pb.TagNumber(5)
  set isSuperset($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsSuperset() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsSuperset() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<SectionItem> get items => $_getList(5);
}

/// Section item (exercise or rest)
class SectionItem extends $pb.GeneratedMessage {
  factory SectionItem({
    $core.String? id,
    $core.String? sectionId,
    $2.SectionItemType? itemType,
    $core.int? displayOrder,
    $core.String? exerciseId,
    $core.String? exerciseName,
    $2.ExerciseType? exerciseType,
    $core.Iterable<TargetSet>? targetSets,
    $core.int? restDurationSeconds,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (sectionId != null) {
      $result.sectionId = sectionId;
    }
    if (itemType != null) {
      $result.itemType = itemType;
    }
    if (displayOrder != null) {
      $result.displayOrder = displayOrder;
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
    if (targetSets != null) {
      $result.targetSets.addAll(targetSets);
    }
    if (restDurationSeconds != null) {
      $result.restDurationSeconds = restDurationSeconds;
    }
    return $result;
  }
  SectionItem._() : super();
  factory SectionItem.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SectionItem.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SectionItem', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'sectionId')
    ..e<$2.SectionItemType>(3, _omitFieldNames ? '' : 'itemType', $pb.PbFieldType.OE, defaultOrMaker: $2.SectionItemType.SECTION_ITEM_TYPE_UNSPECIFIED, valueOf: $2.SectionItemType.valueOf, enumValues: $2.SectionItemType.values)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'displayOrder', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'exerciseId')
    ..aOS(6, _omitFieldNames ? '' : 'exerciseName')
    ..e<$2.ExerciseType>(7, _omitFieldNames ? '' : 'exerciseType', $pb.PbFieldType.OE, defaultOrMaker: $2.ExerciseType.EXERCISE_TYPE_UNSPECIFIED, valueOf: $2.ExerciseType.valueOf, enumValues: $2.ExerciseType.values)
    ..pc<TargetSet>(8, _omitFieldNames ? '' : 'targetSets', $pb.PbFieldType.PM, subBuilder: TargetSet.create)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'restDurationSeconds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SectionItem clone() => SectionItem()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SectionItem copyWith(void Function(SectionItem) updates) => super.copyWith((message) => updates(message as SectionItem)) as SectionItem;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SectionItem create() => SectionItem._();
  SectionItem createEmptyInstance() => create();
  static $pb.PbList<SectionItem> createRepeated() => $pb.PbList<SectionItem>();
  @$core.pragma('dart2js:noInline')
  static SectionItem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SectionItem>(create);
  static SectionItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get sectionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sectionId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSectionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSectionId() => clearField(2);

  @$pb.TagNumber(3)
  $2.SectionItemType get itemType => $_getN(2);
  @$pb.TagNumber(3)
  set itemType($2.SectionItemType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasItemType() => $_has(2);
  @$pb.TagNumber(3)
  void clearItemType() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get displayOrder => $_getIZ(3);
  @$pb.TagNumber(4)
  set displayOrder($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDisplayOrder() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayOrder() => clearField(4);

  /// For exercise items
  @$pb.TagNumber(5)
  $core.String get exerciseId => $_getSZ(4);
  @$pb.TagNumber(5)
  set exerciseId($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExerciseId() => $_has(4);
  @$pb.TagNumber(5)
  void clearExerciseId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get exerciseName => $_getSZ(5);
  @$pb.TagNumber(6)
  set exerciseName($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasExerciseName() => $_has(5);
  @$pb.TagNumber(6)
  void clearExerciseName() => clearField(6);

  @$pb.TagNumber(7)
  $2.ExerciseType get exerciseType => $_getN(6);
  @$pb.TagNumber(7)
  set exerciseType($2.ExerciseType v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasExerciseType() => $_has(6);
  @$pb.TagNumber(7)
  void clearExerciseType() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<TargetSet> get targetSets => $_getList(7);

  /// For rest items
  @$pb.TagNumber(9)
  $core.int get restDurationSeconds => $_getIZ(8);
  @$pb.TagNumber(9)
  set restDurationSeconds($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasRestDurationSeconds() => $_has(8);
  @$pb.TagNumber(9)
  void clearRestDurationSeconds() => clearField(9);
}

/// Target set for exercise
class TargetSet extends $pb.GeneratedMessage {
  factory TargetSet({
    $core.String? id,
    $core.String? sectionItemId,
    $core.int? setNumber,
    $core.double? targetWeightKg,
    $core.int? targetReps,
    $core.int? targetTimeSeconds,
    $core.double? targetDistanceM,
    $core.bool? isBodyweight,
    $core.String? notes,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (sectionItemId != null) {
      $result.sectionItemId = sectionItemId;
    }
    if (setNumber != null) {
      $result.setNumber = setNumber;
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
    if (targetDistanceM != null) {
      $result.targetDistanceM = targetDistanceM;
    }
    if (isBodyweight != null) {
      $result.isBodyweight = isBodyweight;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    return $result;
  }
  TargetSet._() : super();
  factory TargetSet.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TargetSet.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TargetSet', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'sectionItemId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'setNumber', $pb.PbFieldType.O3)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'targetWeightKg', $pb.PbFieldType.OD)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'targetReps', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'targetTimeSeconds', $pb.PbFieldType.O3)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'targetDistanceM', $pb.PbFieldType.OD)
    ..aOB(8, _omitFieldNames ? '' : 'isBodyweight')
    ..aOS(9, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TargetSet clone() => TargetSet()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TargetSet copyWith(void Function(TargetSet) updates) => super.copyWith((message) => updates(message as TargetSet)) as TargetSet;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TargetSet create() => TargetSet._();
  TargetSet createEmptyInstance() => create();
  static $pb.PbList<TargetSet> createRepeated() => $pb.PbList<TargetSet>();
  @$core.pragma('dart2js:noInline')
  static TargetSet getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TargetSet>(create);
  static TargetSet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get sectionItemId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sectionItemId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSectionItemId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSectionItemId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get setNumber => $_getIZ(2);
  @$pb.TagNumber(3)
  set setNumber($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSetNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearSetNumber() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get targetWeightKg => $_getN(3);
  @$pb.TagNumber(4)
  set targetWeightKg($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTargetWeightKg() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetWeightKg() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get targetReps => $_getIZ(4);
  @$pb.TagNumber(5)
  set targetReps($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTargetReps() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetReps() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get targetTimeSeconds => $_getIZ(5);
  @$pb.TagNumber(6)
  set targetTimeSeconds($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTargetTimeSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearTargetTimeSeconds() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get targetDistanceM => $_getN(6);
  @$pb.TagNumber(7)
  set targetDistanceM($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTargetDistanceM() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetDistanceM() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isBodyweight => $_getBF(7);
  @$pb.TagNumber(8)
  set isBodyweight($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasIsBodyweight() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsBodyweight() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get notes => $_getSZ(8);
  @$pb.TagNumber(9)
  set notes($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasNotes() => $_has(8);
  @$pb.TagNumber(9)
  void clearNotes() => clearField(9);
}

/// ListWorkouts
class ListWorkoutsRequest extends $pb.GeneratedMessage {
  factory ListWorkoutsRequest({
    $core.String? userId,
    $core.bool? includeArchived,
    $2.PaginationRequest? pagination,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (includeArchived != null) {
      $result.includeArchived = includeArchived;
    }
    if (pagination != null) {
      $result.pagination = pagination;
    }
    return $result;
  }
  ListWorkoutsRequest._() : super();
  factory ListWorkoutsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListWorkoutsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWorkoutsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOB(2, _omitFieldNames ? '' : 'includeArchived')
    ..aOM<$2.PaginationRequest>(3, _omitFieldNames ? '' : 'pagination', subBuilder: $2.PaginationRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListWorkoutsRequest clone() => ListWorkoutsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListWorkoutsRequest copyWith(void Function(ListWorkoutsRequest) updates) => super.copyWith((message) => updates(message as ListWorkoutsRequest)) as ListWorkoutsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListWorkoutsRequest create() => ListWorkoutsRequest._();
  ListWorkoutsRequest createEmptyInstance() => create();
  static $pb.PbList<ListWorkoutsRequest> createRepeated() => $pb.PbList<ListWorkoutsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListWorkoutsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWorkoutsRequest>(create);
  static ListWorkoutsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeArchived => $_getBF(1);
  @$pb.TagNumber(2)
  set includeArchived($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIncludeArchived() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeArchived() => clearField(2);

  @$pb.TagNumber(3)
  $2.PaginationRequest get pagination => $_getN(2);
  @$pb.TagNumber(3)
  set pagination($2.PaginationRequest v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPagination() => $_has(2);
  @$pb.TagNumber(3)
  void clearPagination() => clearField(3);
  @$pb.TagNumber(3)
  $2.PaginationRequest ensurePagination() => $_ensure(2);
}

class ListWorkoutsResponse extends $pb.GeneratedMessage {
  factory ListWorkoutsResponse({
    $core.Iterable<WorkoutSummary>? workouts,
    $2.PaginationResponse? pagination,
  }) {
    final $result = create();
    if (workouts != null) {
      $result.workouts.addAll(workouts);
    }
    if (pagination != null) {
      $result.pagination = pagination;
    }
    return $result;
  }
  ListWorkoutsResponse._() : super();
  factory ListWorkoutsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListWorkoutsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWorkoutsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<WorkoutSummary>(1, _omitFieldNames ? '' : 'workouts', $pb.PbFieldType.PM, subBuilder: WorkoutSummary.create)
    ..aOM<$2.PaginationResponse>(2, _omitFieldNames ? '' : 'pagination', subBuilder: $2.PaginationResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListWorkoutsResponse clone() => ListWorkoutsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListWorkoutsResponse copyWith(void Function(ListWorkoutsResponse) updates) => super.copyWith((message) => updates(message as ListWorkoutsResponse)) as ListWorkoutsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListWorkoutsResponse create() => ListWorkoutsResponse._();
  ListWorkoutsResponse createEmptyInstance() => create();
  static $pb.PbList<ListWorkoutsResponse> createRepeated() => $pb.PbList<ListWorkoutsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListWorkoutsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWorkoutsResponse>(create);
  static ListWorkoutsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<WorkoutSummary> get workouts => $_getList(0);

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

/// GetWorkout
class GetWorkoutRequest extends $pb.GeneratedMessage {
  factory GetWorkoutRequest({
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
  GetWorkoutRequest._() : super();
  factory GetWorkoutRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWorkoutRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWorkoutRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWorkoutRequest clone() => GetWorkoutRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWorkoutRequest copyWith(void Function(GetWorkoutRequest) updates) => super.copyWith((message) => updates(message as GetWorkoutRequest)) as GetWorkoutRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWorkoutRequest create() => GetWorkoutRequest._();
  GetWorkoutRequest createEmptyInstance() => create();
  static $pb.PbList<GetWorkoutRequest> createRepeated() => $pb.PbList<GetWorkoutRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWorkoutRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWorkoutRequest>(create);
  static GetWorkoutRequest? _defaultInstance;

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

class GetWorkoutResponse extends $pb.GeneratedMessage {
  factory GetWorkoutResponse({
    Workout? workout,
  }) {
    final $result = create();
    if (workout != null) {
      $result.workout = workout;
    }
    return $result;
  }
  GetWorkoutResponse._() : super();
  factory GetWorkoutResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWorkoutResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWorkoutResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Workout>(1, _omitFieldNames ? '' : 'workout', subBuilder: Workout.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWorkoutResponse clone() => GetWorkoutResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWorkoutResponse copyWith(void Function(GetWorkoutResponse) updates) => super.copyWith((message) => updates(message as GetWorkoutResponse)) as GetWorkoutResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWorkoutResponse create() => GetWorkoutResponse._();
  GetWorkoutResponse createEmptyInstance() => create();
  static $pb.PbList<GetWorkoutResponse> createRepeated() => $pb.PbList<GetWorkoutResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWorkoutResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWorkoutResponse>(create);
  static GetWorkoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Workout get workout => $_getN(0);
  @$pb.TagNumber(1)
  set workout(Workout v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWorkout() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkout() => clearField(1);
  @$pb.TagNumber(1)
  Workout ensureWorkout() => $_ensure(0);
}

/// CreateWorkout
class CreateWorkoutRequest extends $pb.GeneratedMessage {
  factory CreateWorkoutRequest({
    $core.String? userId,
    $core.String? name,
    $core.String? description,
    $core.Iterable<CreateWorkoutSection>? sections,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (sections != null) {
      $result.sections.addAll(sections);
    }
    return $result;
  }
  CreateWorkoutRequest._() : super();
  factory CreateWorkoutRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWorkoutRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWorkoutRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..pc<CreateWorkoutSection>(4, _omitFieldNames ? '' : 'sections', $pb.PbFieldType.PM, subBuilder: CreateWorkoutSection.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWorkoutRequest clone() => CreateWorkoutRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWorkoutRequest copyWith(void Function(CreateWorkoutRequest) updates) => super.copyWith((message) => updates(message as CreateWorkoutRequest)) as CreateWorkoutRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWorkoutRequest create() => CreateWorkoutRequest._();
  CreateWorkoutRequest createEmptyInstance() => create();
  static $pb.PbList<CreateWorkoutRequest> createRepeated() => $pb.PbList<CreateWorkoutRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateWorkoutRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWorkoutRequest>(create);
  static CreateWorkoutRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

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
  $core.List<CreateWorkoutSection> get sections => $_getList(3);
}

class CreateWorkoutSection extends $pb.GeneratedMessage {
  factory CreateWorkoutSection({
    $core.String? name,
    $core.int? displayOrder,
    $core.bool? isSuperset,
    $core.Iterable<CreateSectionItem>? items,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (displayOrder != null) {
      $result.displayOrder = displayOrder;
    }
    if (isSuperset != null) {
      $result.isSuperset = isSuperset;
    }
    if (items != null) {
      $result.items.addAll(items);
    }
    return $result;
  }
  CreateWorkoutSection._() : super();
  factory CreateWorkoutSection.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWorkoutSection.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWorkoutSection', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'displayOrder', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'isSuperset')
    ..pc<CreateSectionItem>(4, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: CreateSectionItem.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWorkoutSection clone() => CreateWorkoutSection()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWorkoutSection copyWith(void Function(CreateWorkoutSection) updates) => super.copyWith((message) => updates(message as CreateWorkoutSection)) as CreateWorkoutSection;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWorkoutSection create() => CreateWorkoutSection._();
  CreateWorkoutSection createEmptyInstance() => create();
  static $pb.PbList<CreateWorkoutSection> createRepeated() => $pb.PbList<CreateWorkoutSection>();
  @$core.pragma('dart2js:noInline')
  static CreateWorkoutSection getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWorkoutSection>(create);
  static CreateWorkoutSection? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get displayOrder => $_getIZ(1);
  @$pb.TagNumber(2)
  set displayOrder($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisplayOrder() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayOrder() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isSuperset => $_getBF(2);
  @$pb.TagNumber(3)
  set isSuperset($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsSuperset() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsSuperset() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<CreateSectionItem> get items => $_getList(3);
}

class CreateSectionItem extends $pb.GeneratedMessage {
  factory CreateSectionItem({
    $2.SectionItemType? itemType,
    $core.int? displayOrder,
    $core.String? exerciseId,
    $core.int? restDurationSeconds,
    $core.Iterable<CreateTargetSet>? targetSets,
  }) {
    final $result = create();
    if (itemType != null) {
      $result.itemType = itemType;
    }
    if (displayOrder != null) {
      $result.displayOrder = displayOrder;
    }
    if (exerciseId != null) {
      $result.exerciseId = exerciseId;
    }
    if (restDurationSeconds != null) {
      $result.restDurationSeconds = restDurationSeconds;
    }
    if (targetSets != null) {
      $result.targetSets.addAll(targetSets);
    }
    return $result;
  }
  CreateSectionItem._() : super();
  factory CreateSectionItem.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSectionItem.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSectionItem', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..e<$2.SectionItemType>(1, _omitFieldNames ? '' : 'itemType', $pb.PbFieldType.OE, defaultOrMaker: $2.SectionItemType.SECTION_ITEM_TYPE_UNSPECIFIED, valueOf: $2.SectionItemType.valueOf, enumValues: $2.SectionItemType.values)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'displayOrder', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'exerciseId')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'restDurationSeconds', $pb.PbFieldType.O3)
    ..pc<CreateTargetSet>(5, _omitFieldNames ? '' : 'targetSets', $pb.PbFieldType.PM, subBuilder: CreateTargetSet.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSectionItem clone() => CreateSectionItem()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSectionItem copyWith(void Function(CreateSectionItem) updates) => super.copyWith((message) => updates(message as CreateSectionItem)) as CreateSectionItem;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSectionItem create() => CreateSectionItem._();
  CreateSectionItem createEmptyInstance() => create();
  static $pb.PbList<CreateSectionItem> createRepeated() => $pb.PbList<CreateSectionItem>();
  @$core.pragma('dart2js:noInline')
  static CreateSectionItem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSectionItem>(create);
  static CreateSectionItem? _defaultInstance;

  @$pb.TagNumber(1)
  $2.SectionItemType get itemType => $_getN(0);
  @$pb.TagNumber(1)
  set itemType($2.SectionItemType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasItemType() => $_has(0);
  @$pb.TagNumber(1)
  void clearItemType() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get displayOrder => $_getIZ(1);
  @$pb.TagNumber(2)
  set displayOrder($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisplayOrder() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayOrder() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get exerciseId => $_getSZ(2);
  @$pb.TagNumber(3)
  set exerciseId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasExerciseId() => $_has(2);
  @$pb.TagNumber(3)
  void clearExerciseId() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get restDurationSeconds => $_getIZ(3);
  @$pb.TagNumber(4)
  set restDurationSeconds($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRestDurationSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearRestDurationSeconds() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<CreateTargetSet> get targetSets => $_getList(4);
}

class CreateTargetSet extends $pb.GeneratedMessage {
  factory CreateTargetSet({
    $core.int? setNumber,
    $core.double? targetWeightKg,
    $core.int? targetReps,
    $core.int? targetTimeSeconds,
    $core.double? targetDistanceM,
    $core.bool? isBodyweight,
    $core.String? notes,
  }) {
    final $result = create();
    if (setNumber != null) {
      $result.setNumber = setNumber;
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
    if (targetDistanceM != null) {
      $result.targetDistanceM = targetDistanceM;
    }
    if (isBodyweight != null) {
      $result.isBodyweight = isBodyweight;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    return $result;
  }
  CreateTargetSet._() : super();
  factory CreateTargetSet.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateTargetSet.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateTargetSet', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'setNumber', $pb.PbFieldType.O3)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'targetWeightKg', $pb.PbFieldType.OD)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'targetReps', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'targetTimeSeconds', $pb.PbFieldType.O3)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'targetDistanceM', $pb.PbFieldType.OD)
    ..aOB(6, _omitFieldNames ? '' : 'isBodyweight')
    ..aOS(7, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateTargetSet clone() => CreateTargetSet()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateTargetSet copyWith(void Function(CreateTargetSet) updates) => super.copyWith((message) => updates(message as CreateTargetSet)) as CreateTargetSet;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTargetSet create() => CreateTargetSet._();
  CreateTargetSet createEmptyInstance() => create();
  static $pb.PbList<CreateTargetSet> createRepeated() => $pb.PbList<CreateTargetSet>();
  @$core.pragma('dart2js:noInline')
  static CreateTargetSet getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateTargetSet>(create);
  static CreateTargetSet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get setNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set setNumber($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSetNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSetNumber() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get targetWeightKg => $_getN(1);
  @$pb.TagNumber(2)
  set targetWeightKg($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTargetWeightKg() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetWeightKg() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get targetReps => $_getIZ(2);
  @$pb.TagNumber(3)
  set targetReps($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTargetReps() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetReps() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get targetTimeSeconds => $_getIZ(3);
  @$pb.TagNumber(4)
  set targetTimeSeconds($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTargetTimeSeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetTimeSeconds() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get targetDistanceM => $_getN(4);
  @$pb.TagNumber(5)
  set targetDistanceM($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTargetDistanceM() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetDistanceM() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isBodyweight => $_getBF(5);
  @$pb.TagNumber(6)
  set isBodyweight($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsBodyweight() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsBodyweight() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get notes => $_getSZ(6);
  @$pb.TagNumber(7)
  set notes($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasNotes() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotes() => clearField(7);
}

class CreateWorkoutResponse extends $pb.GeneratedMessage {
  factory CreateWorkoutResponse({
    Workout? workout,
  }) {
    final $result = create();
    if (workout != null) {
      $result.workout = workout;
    }
    return $result;
  }
  CreateWorkoutResponse._() : super();
  factory CreateWorkoutResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWorkoutResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWorkoutResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Workout>(1, _omitFieldNames ? '' : 'workout', subBuilder: Workout.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWorkoutResponse clone() => CreateWorkoutResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWorkoutResponse copyWith(void Function(CreateWorkoutResponse) updates) => super.copyWith((message) => updates(message as CreateWorkoutResponse)) as CreateWorkoutResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWorkoutResponse create() => CreateWorkoutResponse._();
  CreateWorkoutResponse createEmptyInstance() => create();
  static $pb.PbList<CreateWorkoutResponse> createRepeated() => $pb.PbList<CreateWorkoutResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateWorkoutResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWorkoutResponse>(create);
  static CreateWorkoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Workout get workout => $_getN(0);
  @$pb.TagNumber(1)
  set workout(Workout v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWorkout() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkout() => clearField(1);
  @$pb.TagNumber(1)
  Workout ensureWorkout() => $_ensure(0);
}

/// UpdateWorkout
class UpdateWorkoutRequest extends $pb.GeneratedMessage {
  factory UpdateWorkoutRequest({
    $core.String? id,
    $core.String? userId,
    $core.String? name,
    $core.String? description,
    $core.bool? isArchived,
    $core.Iterable<CreateWorkoutSection>? sections,
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
    if (isArchived != null) {
      $result.isArchived = isArchived;
    }
    if (sections != null) {
      $result.sections.addAll(sections);
    }
    return $result;
  }
  UpdateWorkoutRequest._() : super();
  factory UpdateWorkoutRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateWorkoutRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateWorkoutRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOB(5, _omitFieldNames ? '' : 'isArchived')
    ..pc<CreateWorkoutSection>(6, _omitFieldNames ? '' : 'sections', $pb.PbFieldType.PM, subBuilder: CreateWorkoutSection.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateWorkoutRequest clone() => UpdateWorkoutRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateWorkoutRequest copyWith(void Function(UpdateWorkoutRequest) updates) => super.copyWith((message) => updates(message as UpdateWorkoutRequest)) as UpdateWorkoutRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateWorkoutRequest create() => UpdateWorkoutRequest._();
  UpdateWorkoutRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateWorkoutRequest> createRepeated() => $pb.PbList<UpdateWorkoutRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateWorkoutRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateWorkoutRequest>(create);
  static UpdateWorkoutRequest? _defaultInstance;

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
  $core.bool get isArchived => $_getBF(4);
  @$pb.TagNumber(5)
  set isArchived($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsArchived() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsArchived() => clearField(5);

  /// For full update, include sections
  @$pb.TagNumber(6)
  $core.List<CreateWorkoutSection> get sections => $_getList(5);
}

class UpdateWorkoutResponse extends $pb.GeneratedMessage {
  factory UpdateWorkoutResponse({
    Workout? workout,
  }) {
    final $result = create();
    if (workout != null) {
      $result.workout = workout;
    }
    return $result;
  }
  UpdateWorkoutResponse._() : super();
  factory UpdateWorkoutResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateWorkoutResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateWorkoutResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Workout>(1, _omitFieldNames ? '' : 'workout', subBuilder: Workout.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateWorkoutResponse clone() => UpdateWorkoutResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateWorkoutResponse copyWith(void Function(UpdateWorkoutResponse) updates) => super.copyWith((message) => updates(message as UpdateWorkoutResponse)) as UpdateWorkoutResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateWorkoutResponse create() => UpdateWorkoutResponse._();
  UpdateWorkoutResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateWorkoutResponse> createRepeated() => $pb.PbList<UpdateWorkoutResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateWorkoutResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateWorkoutResponse>(create);
  static UpdateWorkoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Workout get workout => $_getN(0);
  @$pb.TagNumber(1)
  set workout(Workout v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWorkout() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkout() => clearField(1);
  @$pb.TagNumber(1)
  Workout ensureWorkout() => $_ensure(0);
}

/// DeleteWorkout
class DeleteWorkoutRequest extends $pb.GeneratedMessage {
  factory DeleteWorkoutRequest({
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
  DeleteWorkoutRequest._() : super();
  factory DeleteWorkoutRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteWorkoutRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteWorkoutRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteWorkoutRequest clone() => DeleteWorkoutRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteWorkoutRequest copyWith(void Function(DeleteWorkoutRequest) updates) => super.copyWith((message) => updates(message as DeleteWorkoutRequest)) as DeleteWorkoutRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteWorkoutRequest create() => DeleteWorkoutRequest._();
  DeleteWorkoutRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteWorkoutRequest> createRepeated() => $pb.PbList<DeleteWorkoutRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteWorkoutRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteWorkoutRequest>(create);
  static DeleteWorkoutRequest? _defaultInstance;

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

class DeleteWorkoutResponse extends $pb.GeneratedMessage {
  factory DeleteWorkoutResponse({
    $core.bool? success,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    return $result;
  }
  DeleteWorkoutResponse._() : super();
  factory DeleteWorkoutResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteWorkoutResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteWorkoutResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteWorkoutResponse clone() => DeleteWorkoutResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteWorkoutResponse copyWith(void Function(DeleteWorkoutResponse) updates) => super.copyWith((message) => updates(message as DeleteWorkoutResponse)) as DeleteWorkoutResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteWorkoutResponse create() => DeleteWorkoutResponse._();
  DeleteWorkoutResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteWorkoutResponse> createRepeated() => $pb.PbList<DeleteWorkoutResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteWorkoutResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteWorkoutResponse>(create);
  static DeleteWorkoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);
}

/// DuplicateWorkout
class DuplicateWorkoutRequest extends $pb.GeneratedMessage {
  factory DuplicateWorkoutRequest({
    $core.String? id,
    $core.String? userId,
    $core.String? newName,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (newName != null) {
      $result.newName = newName;
    }
    return $result;
  }
  DuplicateWorkoutRequest._() : super();
  factory DuplicateWorkoutRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DuplicateWorkoutRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DuplicateWorkoutRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'newName')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DuplicateWorkoutRequest clone() => DuplicateWorkoutRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DuplicateWorkoutRequest copyWith(void Function(DuplicateWorkoutRequest) updates) => super.copyWith((message) => updates(message as DuplicateWorkoutRequest)) as DuplicateWorkoutRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DuplicateWorkoutRequest create() => DuplicateWorkoutRequest._();
  DuplicateWorkoutRequest createEmptyInstance() => create();
  static $pb.PbList<DuplicateWorkoutRequest> createRepeated() => $pb.PbList<DuplicateWorkoutRequest>();
  @$core.pragma('dart2js:noInline')
  static DuplicateWorkoutRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DuplicateWorkoutRequest>(create);
  static DuplicateWorkoutRequest? _defaultInstance;

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
  $core.String get newName => $_getSZ(2);
  @$pb.TagNumber(3)
  set newName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNewName() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewName() => clearField(3);
}

class DuplicateWorkoutResponse extends $pb.GeneratedMessage {
  factory DuplicateWorkoutResponse({
    Workout? workout,
  }) {
    final $result = create();
    if (workout != null) {
      $result.workout = workout;
    }
    return $result;
  }
  DuplicateWorkoutResponse._() : super();
  factory DuplicateWorkoutResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DuplicateWorkoutResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DuplicateWorkoutResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Workout>(1, _omitFieldNames ? '' : 'workout', subBuilder: Workout.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DuplicateWorkoutResponse clone() => DuplicateWorkoutResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DuplicateWorkoutResponse copyWith(void Function(DuplicateWorkoutResponse) updates) => super.copyWith((message) => updates(message as DuplicateWorkoutResponse)) as DuplicateWorkoutResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DuplicateWorkoutResponse create() => DuplicateWorkoutResponse._();
  DuplicateWorkoutResponse createEmptyInstance() => create();
  static $pb.PbList<DuplicateWorkoutResponse> createRepeated() => $pb.PbList<DuplicateWorkoutResponse>();
  @$core.pragma('dart2js:noInline')
  static DuplicateWorkoutResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DuplicateWorkoutResponse>(create);
  static DuplicateWorkoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Workout get workout => $_getN(0);
  @$pb.TagNumber(1)
  set workout(Workout v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWorkout() => $_has(0);
  @$pb.TagNumber(1)
  void clearWorkout() => clearField(1);
  @$pb.TagNumber(1)
  Workout ensureWorkout() => $_ensure(0);
}

class WorkoutServiceApi {
  $pb.RpcClient _client;
  WorkoutServiceApi(this._client);

  $async.Future<ListWorkoutsResponse> listWorkouts($pb.ClientContext? ctx, ListWorkoutsRequest request) =>
    _client.invoke<ListWorkoutsResponse>(ctx, 'WorkoutService', 'ListWorkouts', request, ListWorkoutsResponse())
  ;
  $async.Future<GetWorkoutResponse> getWorkout($pb.ClientContext? ctx, GetWorkoutRequest request) =>
    _client.invoke<GetWorkoutResponse>(ctx, 'WorkoutService', 'GetWorkout', request, GetWorkoutResponse())
  ;
  $async.Future<CreateWorkoutResponse> createWorkout($pb.ClientContext? ctx, CreateWorkoutRequest request) =>
    _client.invoke<CreateWorkoutResponse>(ctx, 'WorkoutService', 'CreateWorkout', request, CreateWorkoutResponse())
  ;
  $async.Future<UpdateWorkoutResponse> updateWorkout($pb.ClientContext? ctx, UpdateWorkoutRequest request) =>
    _client.invoke<UpdateWorkoutResponse>(ctx, 'WorkoutService', 'UpdateWorkout', request, UpdateWorkoutResponse())
  ;
  $async.Future<DeleteWorkoutResponse> deleteWorkout($pb.ClientContext? ctx, DeleteWorkoutRequest request) =>
    _client.invoke<DeleteWorkoutResponse>(ctx, 'WorkoutService', 'DeleteWorkout', request, DeleteWorkoutResponse())
  ;
  $async.Future<DuplicateWorkoutResponse> duplicateWorkout($pb.ClientContext? ctx, DuplicateWorkoutRequest request) =>
    _client.invoke<DuplicateWorkoutResponse>(ctx, 'WorkoutService', 'DuplicateWorkout', request, DuplicateWorkoutResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
