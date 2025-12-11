//
//  Generated code. Do not modify.
//  source: exercise.proto
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

/// Exercise category
class ExerciseCategory extends $pb.GeneratedMessage {
  factory ExerciseCategory({
    $core.String? id,
    $core.String? name,
    $core.int? displayOrder,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (displayOrder != null) {
      $result.displayOrder = displayOrder;
    }
    return $result;
  }
  ExerciseCategory._() : super();
  factory ExerciseCategory.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExerciseCategory.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExerciseCategory', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'displayOrder', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExerciseCategory clone() => ExerciseCategory()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExerciseCategory copyWith(void Function(ExerciseCategory) updates) => super.copyWith((message) => updates(message as ExerciseCategory)) as ExerciseCategory;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExerciseCategory create() => ExerciseCategory._();
  ExerciseCategory createEmptyInstance() => create();
  static $pb.PbList<ExerciseCategory> createRepeated() => $pb.PbList<ExerciseCategory>();
  @$core.pragma('dart2js:noInline')
  static ExerciseCategory getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExerciseCategory>(create);
  static ExerciseCategory? _defaultInstance;

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
  $core.int get displayOrder => $_getIZ(2);
  @$pb.TagNumber(3)
  set displayOrder($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDisplayOrder() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayOrder() => clearField(3);
}

/// Exercise
class Exercise extends $pb.GeneratedMessage {
  factory Exercise({
    $core.String? id,
    $core.String? name,
    $core.String? categoryId,
    $core.String? categoryName,
    $1.ExerciseType? exerciseType,
    $core.String? description,
    $core.bool? isSystem,
    $core.String? createdBy,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (categoryId != null) {
      $result.categoryId = categoryId;
    }
    if (categoryName != null) {
      $result.categoryName = categoryName;
    }
    if (exerciseType != null) {
      $result.exerciseType = exerciseType;
    }
    if (description != null) {
      $result.description = description;
    }
    if (isSystem != null) {
      $result.isSystem = isSystem;
    }
    if (createdBy != null) {
      $result.createdBy = createdBy;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    return $result;
  }
  Exercise._() : super();
  factory Exercise.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Exercise.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Exercise', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'categoryId')
    ..aOS(4, _omitFieldNames ? '' : 'categoryName')
    ..e<$1.ExerciseType>(5, _omitFieldNames ? '' : 'exerciseType', $pb.PbFieldType.OE, defaultOrMaker: $1.ExerciseType.EXERCISE_TYPE_UNSPECIFIED, valueOf: $1.ExerciseType.valueOf, enumValues: $1.ExerciseType.values)
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOB(7, _omitFieldNames ? '' : 'isSystem')
    ..aOS(8, _omitFieldNames ? '' : 'createdBy')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'updatedAt', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Exercise clone() => Exercise()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Exercise copyWith(void Function(Exercise) updates) => super.copyWith((message) => updates(message as Exercise)) as Exercise;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Exercise create() => Exercise._();
  Exercise createEmptyInstance() => create();
  static $pb.PbList<Exercise> createRepeated() => $pb.PbList<Exercise>();
  @$core.pragma('dart2js:noInline')
  static Exercise getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Exercise>(create);
  static Exercise? _defaultInstance;

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
  $core.String get categoryId => $_getSZ(2);
  @$pb.TagNumber(3)
  set categoryId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCategoryId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategoryId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get categoryName => $_getSZ(3);
  @$pb.TagNumber(4)
  set categoryName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCategoryName() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategoryName() => clearField(4);

  @$pb.TagNumber(5)
  $1.ExerciseType get exerciseType => $_getN(4);
  @$pb.TagNumber(5)
  set exerciseType($1.ExerciseType v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasExerciseType() => $_has(4);
  @$pb.TagNumber(5)
  void clearExerciseType() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isSystem => $_getBF(6);
  @$pb.TagNumber(7)
  set isSystem($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasIsSystem() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsSystem() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get createdBy => $_getSZ(7);
  @$pb.TagNumber(8)
  set createdBy($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasCreatedBy() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedBy() => clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(9)
  set createdAt($0.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureCreatedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.Timestamp get updatedAt => $_getN(9);
  @$pb.TagNumber(10)
  set updatedAt($0.Timestamp v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasUpdatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearUpdatedAt() => clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureUpdatedAt() => $_ensure(9);
}

/// ListExercises
class ListExercisesRequest extends $pb.GeneratedMessage {
  factory ListExercisesRequest({
    $core.String? categoryId,
    $1.ExerciseType? exerciseType,
    $core.bool? systemOnly,
    $core.String? userId,
    $1.PaginationRequest? pagination,
  }) {
    final $result = create();
    if (categoryId != null) {
      $result.categoryId = categoryId;
    }
    if (exerciseType != null) {
      $result.exerciseType = exerciseType;
    }
    if (systemOnly != null) {
      $result.systemOnly = systemOnly;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (pagination != null) {
      $result.pagination = pagination;
    }
    return $result;
  }
  ListExercisesRequest._() : super();
  factory ListExercisesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListExercisesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListExercisesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'categoryId')
    ..e<$1.ExerciseType>(2, _omitFieldNames ? '' : 'exerciseType', $pb.PbFieldType.OE, defaultOrMaker: $1.ExerciseType.EXERCISE_TYPE_UNSPECIFIED, valueOf: $1.ExerciseType.valueOf, enumValues: $1.ExerciseType.values)
    ..aOB(3, _omitFieldNames ? '' : 'systemOnly')
    ..aOS(4, _omitFieldNames ? '' : 'userId')
    ..aOM<$1.PaginationRequest>(5, _omitFieldNames ? '' : 'pagination', subBuilder: $1.PaginationRequest.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListExercisesRequest clone() => ListExercisesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListExercisesRequest copyWith(void Function(ListExercisesRequest) updates) => super.copyWith((message) => updates(message as ListExercisesRequest)) as ListExercisesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListExercisesRequest create() => ListExercisesRequest._();
  ListExercisesRequest createEmptyInstance() => create();
  static $pb.PbList<ListExercisesRequest> createRepeated() => $pb.PbList<ListExercisesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListExercisesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListExercisesRequest>(create);
  static ListExercisesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get categoryId => $_getSZ(0);
  @$pb.TagNumber(1)
  set categoryId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCategoryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCategoryId() => clearField(1);

  @$pb.TagNumber(2)
  $1.ExerciseType get exerciseType => $_getN(1);
  @$pb.TagNumber(2)
  set exerciseType($1.ExerciseType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasExerciseType() => $_has(1);
  @$pb.TagNumber(2)
  void clearExerciseType() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get systemOnly => $_getBF(2);
  @$pb.TagNumber(3)
  set systemOnly($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSystemOnly() => $_has(2);
  @$pb.TagNumber(3)
  void clearSystemOnly() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get userId => $_getSZ(3);
  @$pb.TagNumber(4)
  set userId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserId() => clearField(4);

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

class ListExercisesResponse extends $pb.GeneratedMessage {
  factory ListExercisesResponse({
    $core.Iterable<Exercise>? exercises,
    $1.PaginationResponse? pagination,
  }) {
    final $result = create();
    if (exercises != null) {
      $result.exercises.addAll(exercises);
    }
    if (pagination != null) {
      $result.pagination = pagination;
    }
    return $result;
  }
  ListExercisesResponse._() : super();
  factory ListExercisesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListExercisesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListExercisesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<Exercise>(1, _omitFieldNames ? '' : 'exercises', $pb.PbFieldType.PM, subBuilder: Exercise.create)
    ..aOM<$1.PaginationResponse>(2, _omitFieldNames ? '' : 'pagination', subBuilder: $1.PaginationResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListExercisesResponse clone() => ListExercisesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListExercisesResponse copyWith(void Function(ListExercisesResponse) updates) => super.copyWith((message) => updates(message as ListExercisesResponse)) as ListExercisesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListExercisesResponse create() => ListExercisesResponse._();
  ListExercisesResponse createEmptyInstance() => create();
  static $pb.PbList<ListExercisesResponse> createRepeated() => $pb.PbList<ListExercisesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListExercisesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListExercisesResponse>(create);
  static ListExercisesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Exercise> get exercises => $_getList(0);

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

/// GetExercise
class GetExerciseRequest extends $pb.GeneratedMessage {
  factory GetExerciseRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetExerciseRequest._() : super();
  factory GetExerciseRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetExerciseRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetExerciseRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetExerciseRequest clone() => GetExerciseRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetExerciseRequest copyWith(void Function(GetExerciseRequest) updates) => super.copyWith((message) => updates(message as GetExerciseRequest)) as GetExerciseRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetExerciseRequest create() => GetExerciseRequest._();
  GetExerciseRequest createEmptyInstance() => create();
  static $pb.PbList<GetExerciseRequest> createRepeated() => $pb.PbList<GetExerciseRequest>();
  @$core.pragma('dart2js:noInline')
  static GetExerciseRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetExerciseRequest>(create);
  static GetExerciseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GetExerciseResponse extends $pb.GeneratedMessage {
  factory GetExerciseResponse({
    Exercise? exercise,
  }) {
    final $result = create();
    if (exercise != null) {
      $result.exercise = exercise;
    }
    return $result;
  }
  GetExerciseResponse._() : super();
  factory GetExerciseResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetExerciseResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetExerciseResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Exercise>(1, _omitFieldNames ? '' : 'exercise', subBuilder: Exercise.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetExerciseResponse clone() => GetExerciseResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetExerciseResponse copyWith(void Function(GetExerciseResponse) updates) => super.copyWith((message) => updates(message as GetExerciseResponse)) as GetExerciseResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetExerciseResponse create() => GetExerciseResponse._();
  GetExerciseResponse createEmptyInstance() => create();
  static $pb.PbList<GetExerciseResponse> createRepeated() => $pb.PbList<GetExerciseResponse>();
  @$core.pragma('dart2js:noInline')
  static GetExerciseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetExerciseResponse>(create);
  static GetExerciseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Exercise get exercise => $_getN(0);
  @$pb.TagNumber(1)
  set exercise(Exercise v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasExercise() => $_has(0);
  @$pb.TagNumber(1)
  void clearExercise() => clearField(1);
  @$pb.TagNumber(1)
  Exercise ensureExercise() => $_ensure(0);
}

/// CreateExercise
class CreateExerciseRequest extends $pb.GeneratedMessage {
  factory CreateExerciseRequest({
    $core.String? userId,
    $core.String? name,
    $core.String? categoryId,
    $1.ExerciseType? exerciseType,
    $core.String? description,
  }) {
    final $result = create();
    if (userId != null) {
      $result.userId = userId;
    }
    if (name != null) {
      $result.name = name;
    }
    if (categoryId != null) {
      $result.categoryId = categoryId;
    }
    if (exerciseType != null) {
      $result.exerciseType = exerciseType;
    }
    if (description != null) {
      $result.description = description;
    }
    return $result;
  }
  CreateExerciseRequest._() : super();
  factory CreateExerciseRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateExerciseRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateExerciseRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'categoryId')
    ..e<$1.ExerciseType>(4, _omitFieldNames ? '' : 'exerciseType', $pb.PbFieldType.OE, defaultOrMaker: $1.ExerciseType.EXERCISE_TYPE_UNSPECIFIED, valueOf: $1.ExerciseType.valueOf, enumValues: $1.ExerciseType.values)
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateExerciseRequest clone() => CreateExerciseRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateExerciseRequest copyWith(void Function(CreateExerciseRequest) updates) => super.copyWith((message) => updates(message as CreateExerciseRequest)) as CreateExerciseRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateExerciseRequest create() => CreateExerciseRequest._();
  CreateExerciseRequest createEmptyInstance() => create();
  static $pb.PbList<CreateExerciseRequest> createRepeated() => $pb.PbList<CreateExerciseRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateExerciseRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateExerciseRequest>(create);
  static CreateExerciseRequest? _defaultInstance;

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
  $core.String get categoryId => $_getSZ(2);
  @$pb.TagNumber(3)
  set categoryId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCategoryId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategoryId() => clearField(3);

  @$pb.TagNumber(4)
  $1.ExerciseType get exerciseType => $_getN(3);
  @$pb.TagNumber(4)
  set exerciseType($1.ExerciseType v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasExerciseType() => $_has(3);
  @$pb.TagNumber(4)
  void clearExerciseType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => clearField(5);
}

class CreateExerciseResponse extends $pb.GeneratedMessage {
  factory CreateExerciseResponse({
    Exercise? exercise,
  }) {
    final $result = create();
    if (exercise != null) {
      $result.exercise = exercise;
    }
    return $result;
  }
  CreateExerciseResponse._() : super();
  factory CreateExerciseResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateExerciseResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateExerciseResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<Exercise>(1, _omitFieldNames ? '' : 'exercise', subBuilder: Exercise.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateExerciseResponse clone() => CreateExerciseResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateExerciseResponse copyWith(void Function(CreateExerciseResponse) updates) => super.copyWith((message) => updates(message as CreateExerciseResponse)) as CreateExerciseResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateExerciseResponse create() => CreateExerciseResponse._();
  CreateExerciseResponse createEmptyInstance() => create();
  static $pb.PbList<CreateExerciseResponse> createRepeated() => $pb.PbList<CreateExerciseResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateExerciseResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateExerciseResponse>(create);
  static CreateExerciseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Exercise get exercise => $_getN(0);
  @$pb.TagNumber(1)
  set exercise(Exercise v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasExercise() => $_has(0);
  @$pb.TagNumber(1)
  void clearExercise() => clearField(1);
  @$pb.TagNumber(1)
  Exercise ensureExercise() => $_ensure(0);
}

/// ListCategories
class ListCategoriesRequest extends $pb.GeneratedMessage {
  factory ListCategoriesRequest() => create();
  ListCategoriesRequest._() : super();
  factory ListCategoriesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListCategoriesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCategoriesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListCategoriesRequest clone() => ListCategoriesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListCategoriesRequest copyWith(void Function(ListCategoriesRequest) updates) => super.copyWith((message) => updates(message as ListCategoriesRequest)) as ListCategoriesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCategoriesRequest create() => ListCategoriesRequest._();
  ListCategoriesRequest createEmptyInstance() => create();
  static $pb.PbList<ListCategoriesRequest> createRepeated() => $pb.PbList<ListCategoriesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListCategoriesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListCategoriesRequest>(create);
  static ListCategoriesRequest? _defaultInstance;
}

class ListCategoriesResponse extends $pb.GeneratedMessage {
  factory ListCategoriesResponse({
    $core.Iterable<ExerciseCategory>? categories,
  }) {
    final $result = create();
    if (categories != null) {
      $result.categories.addAll(categories);
    }
    return $result;
  }
  ListCategoriesResponse._() : super();
  factory ListCategoriesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListCategoriesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCategoriesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<ExerciseCategory>(1, _omitFieldNames ? '' : 'categories', $pb.PbFieldType.PM, subBuilder: ExerciseCategory.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListCategoriesResponse clone() => ListCategoriesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListCategoriesResponse copyWith(void Function(ListCategoriesResponse) updates) => super.copyWith((message) => updates(message as ListCategoriesResponse)) as ListCategoriesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCategoriesResponse create() => ListCategoriesResponse._();
  ListCategoriesResponse createEmptyInstance() => create();
  static $pb.PbList<ListCategoriesResponse> createRepeated() => $pb.PbList<ListCategoriesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListCategoriesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListCategoriesResponse>(create);
  static ListCategoriesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ExerciseCategory> get categories => $_getList(0);
}

/// SearchExercises
class SearchExercisesRequest extends $pb.GeneratedMessage {
  factory SearchExercisesRequest({
    $core.String? query,
    $core.String? userId,
    $core.int? limit,
  }) {
    final $result = create();
    if (query != null) {
      $result.query = query;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  SearchExercisesRequest._() : super();
  factory SearchExercisesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchExercisesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchExercisesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SearchExercisesRequest clone() => SearchExercisesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SearchExercisesRequest copyWith(void Function(SearchExercisesRequest) updates) => super.copyWith((message) => updates(message as SearchExercisesRequest)) as SearchExercisesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchExercisesRequest create() => SearchExercisesRequest._();
  SearchExercisesRequest createEmptyInstance() => create();
  static $pb.PbList<SearchExercisesRequest> createRepeated() => $pb.PbList<SearchExercisesRequest>();
  @$core.pragma('dart2js:noInline')
  static SearchExercisesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchExercisesRequest>(create);
  static SearchExercisesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => clearField(3);
}

class SearchExercisesResponse extends $pb.GeneratedMessage {
  factory SearchExercisesResponse({
    $core.Iterable<Exercise>? exercises,
  }) {
    final $result = create();
    if (exercises != null) {
      $result.exercises.addAll(exercises);
    }
    return $result;
  }
  SearchExercisesResponse._() : super();
  factory SearchExercisesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SearchExercisesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SearchExercisesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<Exercise>(1, _omitFieldNames ? '' : 'exercises', $pb.PbFieldType.PM, subBuilder: Exercise.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SearchExercisesResponse clone() => SearchExercisesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SearchExercisesResponse copyWith(void Function(SearchExercisesResponse) updates) => super.copyWith((message) => updates(message as SearchExercisesResponse)) as SearchExercisesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchExercisesResponse create() => SearchExercisesResponse._();
  SearchExercisesResponse createEmptyInstance() => create();
  static $pb.PbList<SearchExercisesResponse> createRepeated() => $pb.PbList<SearchExercisesResponse>();
  @$core.pragma('dart2js:noInline')
  static SearchExercisesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SearchExercisesResponse>(create);
  static SearchExercisesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Exercise> get exercises => $_getList(0);
}

class ExerciseServiceApi {
  $pb.RpcClient _client;
  ExerciseServiceApi(this._client);

  $async.Future<ListExercisesResponse> listExercises($pb.ClientContext? ctx, ListExercisesRequest request) =>
    _client.invoke<ListExercisesResponse>(ctx, 'ExerciseService', 'ListExercises', request, ListExercisesResponse())
  ;
  $async.Future<GetExerciseResponse> getExercise($pb.ClientContext? ctx, GetExerciseRequest request) =>
    _client.invoke<GetExerciseResponse>(ctx, 'ExerciseService', 'GetExercise', request, GetExerciseResponse())
  ;
  $async.Future<CreateExerciseResponse> createExercise($pb.ClientContext? ctx, CreateExerciseRequest request) =>
    _client.invoke<CreateExerciseResponse>(ctx, 'ExerciseService', 'CreateExercise', request, CreateExerciseResponse())
  ;
  $async.Future<ListCategoriesResponse> listCategories($pb.ClientContext? ctx, ListCategoriesRequest request) =>
    _client.invoke<ListCategoriesResponse>(ctx, 'ExerciseService', 'ListCategories', request, ListCategoriesResponse())
  ;
  $async.Future<SearchExercisesResponse> searchExercises($pb.ClientContext? ctx, SearchExercisesRequest request) =>
    _client.invoke<SearchExercisesResponse>(ctx, 'ExerciseService', 'SearchExercises', request, SearchExercisesResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
