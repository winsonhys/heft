//
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/timestamp.pb.dart' as $1;

/// User profile
class User extends $pb.GeneratedMessage {
  factory User({
    $core.String? id,
    $core.String? email,
    $core.String? displayName,
    $core.String? avatarUrl,
    $core.bool? usePounds,
    $core.int? restTimerSeconds,
    $1.Timestamp? memberSince,
    $1.Timestamp? createdAt,
    $1.Timestamp? updatedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (email != null) {
      $result.email = email;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    if (usePounds != null) {
      $result.usePounds = usePounds;
    }
    if (restTimerSeconds != null) {
      $result.restTimerSeconds = restTimerSeconds;
    }
    if (memberSince != null) {
      $result.memberSince = memberSince;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    return $result;
  }
  User._() : super();
  factory User.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory User.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'User', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'email')
    ..aOS(3, _omitFieldNames ? '' : 'displayName')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOB(5, _omitFieldNames ? '' : 'usePounds')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'restTimerSeconds', $pb.PbFieldType.O3)
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'memberSince', subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(8, _omitFieldNames ? '' : 'createdAt', subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'updatedAt', subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  User clone() => User()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  User copyWith(void Function(User) updates) => super.copyWith((message) => updates(message as User)) as User;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  User createEmptyInstance() => create();
  static $pb.PbList<User> createRepeated() => $pb.PbList<User>();
  @$core.pragma('dart2js:noInline')
  static User getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get email => $_getSZ(1);
  @$pb.TagNumber(2)
  set email($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEmail() => $_has(1);
  @$pb.TagNumber(2)
  void clearEmail() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get usePounds => $_getBF(4);
  @$pb.TagNumber(5)
  set usePounds($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUsePounds() => $_has(4);
  @$pb.TagNumber(5)
  void clearUsePounds() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get restTimerSeconds => $_getIZ(5);
  @$pb.TagNumber(6)
  set restTimerSeconds($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasRestTimerSeconds() => $_has(5);
  @$pb.TagNumber(6)
  void clearRestTimerSeconds() => clearField(6);

  @$pb.TagNumber(7)
  $1.Timestamp get memberSince => $_getN(6);
  @$pb.TagNumber(7)
  set memberSince($1.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasMemberSince() => $_has(6);
  @$pb.TagNumber(7)
  void clearMemberSince() => clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureMemberSince() => $_ensure(6);

  @$pb.TagNumber(8)
  $1.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($1.Timestamp v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => clearField(8);
  @$pb.TagNumber(8)
  $1.Timestamp ensureCreatedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $1.Timestamp get updatedAt => $_getN(8);
  @$pb.TagNumber(9)
  set updatedAt($1.Timestamp v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasUpdatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdatedAt() => clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensureUpdatedAt() => $_ensure(8);
}

/// Weight log entry
class WeightLog extends $pb.GeneratedMessage {
  factory WeightLog({
    $core.String? id,
    $core.String? userId,
    $core.double? weightKg,
    $core.String? loggedDate,
    $core.String? notes,
    $1.Timestamp? createdAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (weightKg != null) {
      $result.weightKg = weightKg;
    }
    if (loggedDate != null) {
      $result.loggedDate = loggedDate;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  WeightLog._() : super();
  factory WeightLog.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WeightLog.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WeightLog', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'weightKg', $pb.PbFieldType.OD)
    ..aOS(4, _omitFieldNames ? '' : 'loggedDate')
    ..aOS(5, _omitFieldNames ? '' : 'notes')
    ..aOM<$1.Timestamp>(6, _omitFieldNames ? '' : 'createdAt', subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WeightLog clone() => WeightLog()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WeightLog copyWith(void Function(WeightLog) updates) => super.copyWith((message) => updates(message as WeightLog)) as WeightLog;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WeightLog create() => WeightLog._();
  WeightLog createEmptyInstance() => create();
  static $pb.PbList<WeightLog> createRepeated() => $pb.PbList<WeightLog>();
  @$core.pragma('dart2js:noInline')
  static WeightLog getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WeightLog>(create);
  static WeightLog? _defaultInstance;

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
  $core.double get weightKg => $_getN(2);
  @$pb.TagNumber(3)
  set weightKg($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWeightKg() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeightKg() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get loggedDate => $_getSZ(3);
  @$pb.TagNumber(4)
  set loggedDate($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLoggedDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearLoggedDate() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get notes => $_getSZ(4);
  @$pb.TagNumber(5)
  set notes($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNotes() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotes() => clearField(5);

  @$pb.TagNumber(6)
  $1.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(6)
  set createdAt($1.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => clearField(6);
  @$pb.TagNumber(6)
  $1.Timestamp ensureCreatedAt() => $_ensure(5);
}

/// User settings
class UserSettings extends $pb.GeneratedMessage {
  factory UserSettings({
    $core.bool? usePounds,
    $core.int? restTimerSeconds,
  }) {
    final $result = create();
    if (usePounds != null) {
      $result.usePounds = usePounds;
    }
    if (restTimerSeconds != null) {
      $result.restTimerSeconds = restTimerSeconds;
    }
    return $result;
  }
  UserSettings._() : super();
  factory UserSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserSettings', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'usePounds')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'restTimerSeconds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserSettings clone() => UserSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserSettings copyWith(void Function(UserSettings) updates) => super.copyWith((message) => updates(message as UserSettings)) as UserSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserSettings create() => UserSettings._();
  UserSettings createEmptyInstance() => create();
  static $pb.PbList<UserSettings> createRepeated() => $pb.PbList<UserSettings>();
  @$core.pragma('dart2js:noInline')
  static UserSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserSettings>(create);
  static UserSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get usePounds => $_getBF(0);
  @$pb.TagNumber(1)
  set usePounds($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUsePounds() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsePounds() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get restTimerSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set restTimerSeconds($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRestTimerSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearRestTimerSeconds() => clearField(2);
}

/// GetProfile
class GetProfileRequest extends $pb.GeneratedMessage {
  factory GetProfileRequest() => create();
  GetProfileRequest._() : super();
  factory GetProfileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetProfileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetProfileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetProfileRequest clone() => GetProfileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetProfileRequest copyWith(void Function(GetProfileRequest) updates) => super.copyWith((message) => updates(message as GetProfileRequest)) as GetProfileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProfileRequest create() => GetProfileRequest._();
  GetProfileRequest createEmptyInstance() => create();
  static $pb.PbList<GetProfileRequest> createRepeated() => $pb.PbList<GetProfileRequest>();
  @$core.pragma('dart2js:noInline')
  static GetProfileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProfileRequest>(create);
  static GetProfileRequest? _defaultInstance;
}

class GetProfileResponse extends $pb.GeneratedMessage {
  factory GetProfileResponse({
    User? user,
  }) {
    final $result = create();
    if (user != null) {
      $result.user = user;
    }
    return $result;
  }
  GetProfileResponse._() : super();
  factory GetProfileResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetProfileResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetProfileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<User>(1, _omitFieldNames ? '' : 'user', subBuilder: User.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetProfileResponse clone() => GetProfileResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetProfileResponse copyWith(void Function(GetProfileResponse) updates) => super.copyWith((message) => updates(message as GetProfileResponse)) as GetProfileResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProfileResponse create() => GetProfileResponse._();
  GetProfileResponse createEmptyInstance() => create();
  static $pb.PbList<GetProfileResponse> createRepeated() => $pb.PbList<GetProfileResponse>();
  @$core.pragma('dart2js:noInline')
  static GetProfileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetProfileResponse>(create);
  static GetProfileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  User get user => $_getN(0);
  @$pb.TagNumber(1)
  set user(User v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => clearField(1);
  @$pb.TagNumber(1)
  User ensureUser() => $_ensure(0);
}

/// UpdateProfile
class UpdateProfileRequest extends $pb.GeneratedMessage {
  factory UpdateProfileRequest({
    $core.String? displayName,
    $core.String? avatarUrl,
  }) {
    final $result = create();
    if (displayName != null) {
      $result.displayName = displayName;
    }
    if (avatarUrl != null) {
      $result.avatarUrl = avatarUrl;
    }
    return $result;
  }
  UpdateProfileRequest._() : super();
  factory UpdateProfileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateProfileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateProfileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'displayName')
    ..aOS(2, _omitFieldNames ? '' : 'avatarUrl')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateProfileRequest clone() => UpdateProfileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateProfileRequest copyWith(void Function(UpdateProfileRequest) updates) => super.copyWith((message) => updates(message as UpdateProfileRequest)) as UpdateProfileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProfileRequest create() => UpdateProfileRequest._();
  UpdateProfileRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateProfileRequest> createRepeated() => $pb.PbList<UpdateProfileRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateProfileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProfileRequest>(create);
  static UpdateProfileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get displayName => $_getSZ(0);
  @$pb.TagNumber(1)
  set displayName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDisplayName() => $_has(0);
  @$pb.TagNumber(1)
  void clearDisplayName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get avatarUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set avatarUrl($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAvatarUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearAvatarUrl() => clearField(2);
}

class UpdateProfileResponse extends $pb.GeneratedMessage {
  factory UpdateProfileResponse({
    User? user,
  }) {
    final $result = create();
    if (user != null) {
      $result.user = user;
    }
    return $result;
  }
  UpdateProfileResponse._() : super();
  factory UpdateProfileResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateProfileResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateProfileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<User>(1, _omitFieldNames ? '' : 'user', subBuilder: User.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateProfileResponse clone() => UpdateProfileResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateProfileResponse copyWith(void Function(UpdateProfileResponse) updates) => super.copyWith((message) => updates(message as UpdateProfileResponse)) as UpdateProfileResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateProfileResponse create() => UpdateProfileResponse._();
  UpdateProfileResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateProfileResponse> createRepeated() => $pb.PbList<UpdateProfileResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateProfileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateProfileResponse>(create);
  static UpdateProfileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  User get user => $_getN(0);
  @$pb.TagNumber(1)
  set user(User v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => clearField(1);
  @$pb.TagNumber(1)
  User ensureUser() => $_ensure(0);
}

/// UpdateSettings
class UpdateSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateSettingsRequest({
    $core.bool? usePounds,
    $core.int? restTimerSeconds,
  }) {
    final $result = create();
    if (usePounds != null) {
      $result.usePounds = usePounds;
    }
    if (restTimerSeconds != null) {
      $result.restTimerSeconds = restTimerSeconds;
    }
    return $result;
  }
  UpdateSettingsRequest._() : super();
  factory UpdateSettingsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateSettingsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateSettingsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'usePounds')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'restTimerSeconds', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateSettingsRequest clone() => UpdateSettingsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateSettingsRequest copyWith(void Function(UpdateSettingsRequest) updates) => super.copyWith((message) => updates(message as UpdateSettingsRequest)) as UpdateSettingsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSettingsRequest create() => UpdateSettingsRequest._();
  UpdateSettingsRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateSettingsRequest> createRepeated() => $pb.PbList<UpdateSettingsRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateSettingsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateSettingsRequest>(create);
  static UpdateSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get usePounds => $_getBF(0);
  @$pb.TagNumber(1)
  set usePounds($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUsePounds() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsePounds() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get restTimerSeconds => $_getIZ(1);
  @$pb.TagNumber(2)
  set restTimerSeconds($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRestTimerSeconds() => $_has(1);
  @$pb.TagNumber(2)
  void clearRestTimerSeconds() => clearField(2);
}

class UpdateSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateSettingsResponse({
    User? user,
  }) {
    final $result = create();
    if (user != null) {
      $result.user = user;
    }
    return $result;
  }
  UpdateSettingsResponse._() : super();
  factory UpdateSettingsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateSettingsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateSettingsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<User>(1, _omitFieldNames ? '' : 'user', subBuilder: User.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateSettingsResponse clone() => UpdateSettingsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateSettingsResponse copyWith(void Function(UpdateSettingsResponse) updates) => super.copyWith((message) => updates(message as UpdateSettingsResponse)) as UpdateSettingsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSettingsResponse create() => UpdateSettingsResponse._();
  UpdateSettingsResponse createEmptyInstance() => create();
  static $pb.PbList<UpdateSettingsResponse> createRepeated() => $pb.PbList<UpdateSettingsResponse>();
  @$core.pragma('dart2js:noInline')
  static UpdateSettingsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateSettingsResponse>(create);
  static UpdateSettingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  User get user => $_getN(0);
  @$pb.TagNumber(1)
  set user(User v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => clearField(1);
  @$pb.TagNumber(1)
  User ensureUser() => $_ensure(0);
}

/// LogWeight
class LogWeightRequest extends $pb.GeneratedMessage {
  factory LogWeightRequest({
    $core.double? weightKg,
    $core.String? loggedDate,
    $core.String? notes,
  }) {
    final $result = create();
    if (weightKg != null) {
      $result.weightKg = weightKg;
    }
    if (loggedDate != null) {
      $result.loggedDate = loggedDate;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    return $result;
  }
  LogWeightRequest._() : super();
  factory LogWeightRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LogWeightRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LogWeightRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'weightKg', $pb.PbFieldType.OD)
    ..aOS(2, _omitFieldNames ? '' : 'loggedDate')
    ..aOS(3, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LogWeightRequest clone() => LogWeightRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LogWeightRequest copyWith(void Function(LogWeightRequest) updates) => super.copyWith((message) => updates(message as LogWeightRequest)) as LogWeightRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogWeightRequest create() => LogWeightRequest._();
  LogWeightRequest createEmptyInstance() => create();
  static $pb.PbList<LogWeightRequest> createRepeated() => $pb.PbList<LogWeightRequest>();
  @$core.pragma('dart2js:noInline')
  static LogWeightRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogWeightRequest>(create);
  static LogWeightRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get weightKg => $_getN(0);
  @$pb.TagNumber(1)
  set weightKg($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWeightKg() => $_has(0);
  @$pb.TagNumber(1)
  void clearWeightKg() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get loggedDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set loggedDate($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLoggedDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearLoggedDate() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get notes => $_getSZ(2);
  @$pb.TagNumber(3)
  set notes($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNotes() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotes() => clearField(3);
}

class LogWeightResponse extends $pb.GeneratedMessage {
  factory LogWeightResponse({
    WeightLog? weightLog,
  }) {
    final $result = create();
    if (weightLog != null) {
      $result.weightLog = weightLog;
    }
    return $result;
  }
  LogWeightResponse._() : super();
  factory LogWeightResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LogWeightResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LogWeightResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOM<WeightLog>(1, _omitFieldNames ? '' : 'weightLog', subBuilder: WeightLog.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LogWeightResponse clone() => LogWeightResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LogWeightResponse copyWith(void Function(LogWeightResponse) updates) => super.copyWith((message) => updates(message as LogWeightResponse)) as LogWeightResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogWeightResponse create() => LogWeightResponse._();
  LogWeightResponse createEmptyInstance() => create();
  static $pb.PbList<LogWeightResponse> createRepeated() => $pb.PbList<LogWeightResponse>();
  @$core.pragma('dart2js:noInline')
  static LogWeightResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogWeightResponse>(create);
  static LogWeightResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WeightLog get weightLog => $_getN(0);
  @$pb.TagNumber(1)
  set weightLog(WeightLog v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWeightLog() => $_has(0);
  @$pb.TagNumber(1)
  void clearWeightLog() => clearField(1);
  @$pb.TagNumber(1)
  WeightLog ensureWeightLog() => $_ensure(0);
}

/// GetWeightHistory
class GetWeightHistoryRequest extends $pb.GeneratedMessage {
  factory GetWeightHistoryRequest({
    $core.String? startDate,
    $core.String? endDate,
    $core.int? limit,
  }) {
    final $result = create();
    if (startDate != null) {
      $result.startDate = startDate;
    }
    if (endDate != null) {
      $result.endDate = endDate;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  GetWeightHistoryRequest._() : super();
  factory GetWeightHistoryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWeightHistoryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWeightHistoryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'startDate')
    ..aOS(2, _omitFieldNames ? '' : 'endDate')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWeightHistoryRequest clone() => GetWeightHistoryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWeightHistoryRequest copyWith(void Function(GetWeightHistoryRequest) updates) => super.copyWith((message) => updates(message as GetWeightHistoryRequest)) as GetWeightHistoryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWeightHistoryRequest create() => GetWeightHistoryRequest._();
  GetWeightHistoryRequest createEmptyInstance() => create();
  static $pb.PbList<GetWeightHistoryRequest> createRepeated() => $pb.PbList<GetWeightHistoryRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWeightHistoryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWeightHistoryRequest>(create);
  static GetWeightHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get startDate => $_getSZ(0);
  @$pb.TagNumber(1)
  set startDate($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStartDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartDate() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get endDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set endDate($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEndDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndDate() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => clearField(3);
}

class GetWeightHistoryResponse extends $pb.GeneratedMessage {
  factory GetWeightHistoryResponse({
    $core.Iterable<WeightLog>? weightLogs,
  }) {
    final $result = create();
    if (weightLogs != null) {
      $result.weightLogs.addAll(weightLogs);
    }
    return $result;
  }
  GetWeightHistoryResponse._() : super();
  factory GetWeightHistoryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWeightHistoryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWeightHistoryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..pc<WeightLog>(1, _omitFieldNames ? '' : 'weightLogs', $pb.PbFieldType.PM, subBuilder: WeightLog.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWeightHistoryResponse clone() => GetWeightHistoryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWeightHistoryResponse copyWith(void Function(GetWeightHistoryResponse) updates) => super.copyWith((message) => updates(message as GetWeightHistoryResponse)) as GetWeightHistoryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWeightHistoryResponse create() => GetWeightHistoryResponse._();
  GetWeightHistoryResponse createEmptyInstance() => create();
  static $pb.PbList<GetWeightHistoryResponse> createRepeated() => $pb.PbList<GetWeightHistoryResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWeightHistoryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWeightHistoryResponse>(create);
  static GetWeightHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<WeightLog> get weightLogs => $_getList(0);
}

/// DeleteWeightLog
class DeleteWeightLogRequest extends $pb.GeneratedMessage {
  factory DeleteWeightLogRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DeleteWeightLogRequest._() : super();
  factory DeleteWeightLogRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteWeightLogRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteWeightLogRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteWeightLogRequest clone() => DeleteWeightLogRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteWeightLogRequest copyWith(void Function(DeleteWeightLogRequest) updates) => super.copyWith((message) => updates(message as DeleteWeightLogRequest)) as DeleteWeightLogRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteWeightLogRequest create() => DeleteWeightLogRequest._();
  DeleteWeightLogRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteWeightLogRequest> createRepeated() => $pb.PbList<DeleteWeightLogRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteWeightLogRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteWeightLogRequest>(create);
  static DeleteWeightLogRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class DeleteWeightLogResponse extends $pb.GeneratedMessage {
  factory DeleteWeightLogResponse({
    $core.bool? success,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    return $result;
  }
  DeleteWeightLogResponse._() : super();
  factory DeleteWeightLogResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteWeightLogResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteWeightLogResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'heft.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteWeightLogResponse clone() => DeleteWeightLogResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteWeightLogResponse copyWith(void Function(DeleteWeightLogResponse) updates) => super.copyWith((message) => updates(message as DeleteWeightLogResponse)) as DeleteWeightLogResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteWeightLogResponse create() => DeleteWeightLogResponse._();
  DeleteWeightLogResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteWeightLogResponse> createRepeated() => $pb.PbList<DeleteWeightLogResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteWeightLogResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteWeightLogResponse>(create);
  static DeleteWeightLogResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);
}

class UserServiceApi {
  $pb.RpcClient _client;
  UserServiceApi(this._client);

  $async.Future<GetProfileResponse> getProfile($pb.ClientContext? ctx, GetProfileRequest request) =>
    _client.invoke<GetProfileResponse>(ctx, 'UserService', 'GetProfile', request, GetProfileResponse())
  ;
  $async.Future<UpdateProfileResponse> updateProfile($pb.ClientContext? ctx, UpdateProfileRequest request) =>
    _client.invoke<UpdateProfileResponse>(ctx, 'UserService', 'UpdateProfile', request, UpdateProfileResponse())
  ;
  $async.Future<UpdateSettingsResponse> updateSettings($pb.ClientContext? ctx, UpdateSettingsRequest request) =>
    _client.invoke<UpdateSettingsResponse>(ctx, 'UserService', 'UpdateSettings', request, UpdateSettingsResponse())
  ;
  $async.Future<LogWeightResponse> logWeight($pb.ClientContext? ctx, LogWeightRequest request) =>
    _client.invoke<LogWeightResponse>(ctx, 'UserService', 'LogWeight', request, LogWeightResponse())
  ;
  $async.Future<GetWeightHistoryResponse> getWeightHistory($pb.ClientContext? ctx, GetWeightHistoryRequest request) =>
    _client.invoke<GetWeightHistoryResponse>(ctx, 'UserService', 'GetWeightHistory', request, GetWeightHistoryResponse())
  ;
  $async.Future<DeleteWeightLogResponse> deleteWeightLog($pb.ClientContext? ctx, DeleteWeightLogRequest request) =>
    _client.invoke<DeleteWeightLogResponse>(ctx, 'UserService', 'DeleteWeightLog', request, DeleteWeightLogResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
