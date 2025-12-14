//
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'google/protobuf/timestamp.pbjson.dart' as $1;

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '10': 'email'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'use_pounds', '3': 5, '4': 1, '5': 8, '10': 'usePounds'},
    {'1': 'rest_timer_seconds', '3': 6, '4': 1, '5': 5, '10': 'restTimerSeconds'},
    {'1': 'member_since', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'memberSince'},
    {'1': 'created_at', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgJUgJpZBIUCgVlbWFpbBgCIAEoCVIFZW1haWwSIQoMZGlzcGxheV'
    '9uYW1lGAMgASgJUgtkaXNwbGF5TmFtZRIdCgphdmF0YXJfdXJsGAQgASgJUglhdmF0YXJVcmwS'
    'HQoKdXNlX3BvdW5kcxgFIAEoCFIJdXNlUG91bmRzEiwKEnJlc3RfdGltZXJfc2Vjb25kcxgGIA'
    'EoBVIQcmVzdFRpbWVyU2Vjb25kcxI9CgxtZW1iZXJfc2luY2UYByABKAsyGi5nb29nbGUucHJv'
    'dG9idWYuVGltZXN0YW1wUgttZW1iZXJTaW5jZRI5CgpjcmVhdGVkX2F0GAggASgLMhouZ29vZ2'
    'xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYCSABKAsyGi5n'
    'b29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use weightLogDescriptor instead')
const WeightLog$json = {
  '1': 'WeightLog',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'weight_kg', '3': 3, '4': 1, '5': 1, '10': 'weightKg'},
    {'1': 'logged_date', '3': 4, '4': 1, '5': 9, '10': 'loggedDate'},
    {'1': 'notes', '3': 5, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `WeightLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List weightLogDescriptor = $convert.base64Decode(
    'CglXZWlnaHRMb2cSDgoCaWQYASABKAlSAmlkEhcKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBIbCg'
    'l3ZWlnaHRfa2cYAyABKAFSCHdlaWdodEtnEh8KC2xvZ2dlZF9kYXRlGAQgASgJUgpsb2dnZWRE'
    'YXRlEhQKBW5vdGVzGAUgASgJUgVub3RlcxI5CgpjcmVhdGVkX2F0GAYgASgLMhouZ29vZ2xlLn'
    'Byb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use userSettingsDescriptor instead')
const UserSettings$json = {
  '1': 'UserSettings',
  '2': [
    {'1': 'use_pounds', '3': 1, '4': 1, '5': 8, '10': 'usePounds'},
    {'1': 'rest_timer_seconds', '3': 2, '4': 1, '5': 5, '10': 'restTimerSeconds'},
  ],
};

/// Descriptor for `UserSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userSettingsDescriptor = $convert.base64Decode(
    'CgxVc2VyU2V0dGluZ3MSHQoKdXNlX3BvdW5kcxgBIAEoCFIJdXNlUG91bmRzEiwKEnJlc3RfdG'
    'ltZXJfc2Vjb25kcxgCIAEoBVIQcmVzdFRpbWVyU2Vjb25kcw==');

@$core.Deprecated('Use getProfileRequestDescriptor instead')
const GetProfileRequest$json = {
  '1': 'GetProfileRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProfileRequestDescriptor = $convert.base64Decode(
    'ChFHZXRQcm9maWxlUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQ=');

@$core.Deprecated('Use getProfileResponseDescriptor instead')
const GetProfileResponse$json = {
  '1': 'GetProfileResponse',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.User', '10': 'user'},
  ],
};

/// Descriptor for `GetProfileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProfileResponseDescriptor = $convert.base64Decode(
    'ChJHZXRQcm9maWxlUmVzcG9uc2USIQoEdXNlchgBIAEoCzINLmhlZnQudjEuVXNlclIEdXNlcg'
    '==');

@$core.Deprecated('Use updateProfileRequestDescriptor instead')
const UpdateProfileRequest$json = {
  '1': 'UpdateProfileRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'displayName', '17': true},
    {'1': 'avatar_url', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'avatarUrl', '17': true},
  ],
  '8': [
    {'1': '_display_name'},
    {'1': '_avatar_url'},
  ],
};

/// Descriptor for `UpdateProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProfileRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVQcm9maWxlUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSJgoMZGlzcG'
    'xheV9uYW1lGAIgASgJSABSC2Rpc3BsYXlOYW1liAEBEiIKCmF2YXRhcl91cmwYAyABKAlIAVIJ'
    'YXZhdGFyVXJsiAEBQg8KDV9kaXNwbGF5X25hbWVCDQoLX2F2YXRhcl91cmw=');

@$core.Deprecated('Use updateProfileResponseDescriptor instead')
const UpdateProfileResponse$json = {
  '1': 'UpdateProfileResponse',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.User', '10': 'user'},
  ],
};

/// Descriptor for `UpdateProfileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProfileResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVQcm9maWxlUmVzcG9uc2USIQoEdXNlchgBIAEoCzINLmhlZnQudjEuVXNlclIEdX'
    'Nlcg==');

@$core.Deprecated('Use updateSettingsRequestDescriptor instead')
const UpdateSettingsRequest$json = {
  '1': 'UpdateSettingsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'use_pounds', '3': 2, '4': 1, '5': 8, '9': 0, '10': 'usePounds', '17': true},
    {'1': 'rest_timer_seconds', '3': 3, '4': 1, '5': 5, '9': 1, '10': 'restTimerSeconds', '17': true},
  ],
  '8': [
    {'1': '_use_pounds'},
    {'1': '_rest_timer_seconds'},
  ],
};

/// Descriptor for `UpdateSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingsRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVTZXR0aW5nc1JlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEiIKCnVzZV'
    '9wb3VuZHMYAiABKAhIAFIJdXNlUG91bmRziAEBEjEKEnJlc3RfdGltZXJfc2Vjb25kcxgDIAEo'
    'BUgBUhByZXN0VGltZXJTZWNvbmRziAEBQg0KC191c2VfcG91bmRzQhUKE19yZXN0X3RpbWVyX3'
    'NlY29uZHM=');

@$core.Deprecated('Use updateSettingsResponseDescriptor instead')
const UpdateSettingsResponse$json = {
  '1': 'UpdateSettingsResponse',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.User', '10': 'user'},
  ],
};

/// Descriptor for `UpdateSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSettingsResponseDescriptor = $convert.base64Decode(
    'ChZVcGRhdGVTZXR0aW5nc1Jlc3BvbnNlEiEKBHVzZXIYASABKAsyDS5oZWZ0LnYxLlVzZXJSBH'
    'VzZXI=');

@$core.Deprecated('Use logWeightRequestDescriptor instead')
const LogWeightRequest$json = {
  '1': 'LogWeightRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'weight_kg', '3': 2, '4': 1, '5': 1, '10': 'weightKg'},
    {'1': 'logged_date', '3': 3, '4': 1, '5': 9, '10': 'loggedDate'},
    {'1': 'notes', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'notes', '17': true},
  ],
  '8': [
    {'1': '_notes'},
  ],
};

/// Descriptor for `LogWeightRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logWeightRequestDescriptor = $convert.base64Decode(
    'ChBMb2dXZWlnaHRSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCgl3ZWlnaHRfa2'
    'cYAiABKAFSCHdlaWdodEtnEh8KC2xvZ2dlZF9kYXRlGAMgASgJUgpsb2dnZWREYXRlEhkKBW5v'
    'dGVzGAQgASgJSABSBW5vdGVziAEBQggKBl9ub3Rlcw==');

@$core.Deprecated('Use logWeightResponseDescriptor instead')
const LogWeightResponse$json = {
  '1': 'LogWeightResponse',
  '2': [
    {'1': 'weight_log', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.WeightLog', '10': 'weightLog'},
  ],
};

/// Descriptor for `LogWeightResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logWeightResponseDescriptor = $convert.base64Decode(
    'ChFMb2dXZWlnaHRSZXNwb25zZRIxCgp3ZWlnaHRfbG9nGAEgASgLMhIuaGVmdC52MS5XZWlnaH'
    'RMb2dSCXdlaWdodExvZw==');

@$core.Deprecated('Use getWeightHistoryRequestDescriptor instead')
const GetWeightHistoryRequest$json = {
  '1': 'GetWeightHistoryRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'start_date', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'startDate', '17': true},
    {'1': 'end_date', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'endDate', '17': true},
    {'1': 'limit', '3': 4, '4': 1, '5': 5, '9': 2, '10': 'limit', '17': true},
  ],
  '8': [
    {'1': '_start_date'},
    {'1': '_end_date'},
    {'1': '_limit'},
  ],
};

/// Descriptor for `GetWeightHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWeightHistoryRequestDescriptor = $convert.base64Decode(
    'ChdHZXRXZWlnaHRIaXN0b3J5UmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSIgoKc3'
    'RhcnRfZGF0ZRgCIAEoCUgAUglzdGFydERhdGWIAQESHgoIZW5kX2RhdGUYAyABKAlIAVIHZW5k'
    'RGF0ZYgBARIZCgVsaW1pdBgEIAEoBUgCUgVsaW1pdIgBAUINCgtfc3RhcnRfZGF0ZUILCglfZW'
    '5kX2RhdGVCCAoGX2xpbWl0');

@$core.Deprecated('Use getWeightHistoryResponseDescriptor instead')
const GetWeightHistoryResponse$json = {
  '1': 'GetWeightHistoryResponse',
  '2': [
    {'1': 'weight_logs', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.WeightLog', '10': 'weightLogs'},
  ],
};

/// Descriptor for `GetWeightHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWeightHistoryResponseDescriptor = $convert.base64Decode(
    'ChhHZXRXZWlnaHRIaXN0b3J5UmVzcG9uc2USMwoLd2VpZ2h0X2xvZ3MYASADKAsyEi5oZWZ0Ln'
    'YxLldlaWdodExvZ1IKd2VpZ2h0TG9ncw==');

@$core.Deprecated('Use deleteWeightLogRequestDescriptor instead')
const DeleteWeightLogRequest$json = {
  '1': 'DeleteWeightLogRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `DeleteWeightLogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteWeightLogRequestDescriptor = $convert.base64Decode(
    'ChZEZWxldGVXZWlnaHRMb2dSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIXCgd1c2VyX2lkGAIgAS'
    'gJUgZ1c2VySWQ=');

@$core.Deprecated('Use deleteWeightLogResponseDescriptor instead')
const DeleteWeightLogResponse$json = {
  '1': 'DeleteWeightLogResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `DeleteWeightLogResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteWeightLogResponseDescriptor = $convert.base64Decode(
    'ChdEZWxldGVXZWlnaHRMb2dSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNz');

const $core.Map<$core.String, $core.dynamic> UserServiceBase$json = {
  '1': 'UserService',
  '2': [
    {'1': 'GetProfile', '2': '.heft.v1.GetProfileRequest', '3': '.heft.v1.GetProfileResponse'},
    {'1': 'UpdateProfile', '2': '.heft.v1.UpdateProfileRequest', '3': '.heft.v1.UpdateProfileResponse'},
    {'1': 'UpdateSettings', '2': '.heft.v1.UpdateSettingsRequest', '3': '.heft.v1.UpdateSettingsResponse'},
    {'1': 'LogWeight', '2': '.heft.v1.LogWeightRequest', '3': '.heft.v1.LogWeightResponse'},
    {'1': 'GetWeightHistory', '2': '.heft.v1.GetWeightHistoryRequest', '3': '.heft.v1.GetWeightHistoryResponse'},
    {'1': 'DeleteWeightLog', '2': '.heft.v1.DeleteWeightLogRequest', '3': '.heft.v1.DeleteWeightLogResponse'},
  ],
};

@$core.Deprecated('Use userServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> UserServiceBase$messageJson = {
  '.heft.v1.GetProfileRequest': GetProfileRequest$json,
  '.heft.v1.GetProfileResponse': GetProfileResponse$json,
  '.heft.v1.User': User$json,
  '.google.protobuf.Timestamp': $1.Timestamp$json,
  '.heft.v1.UpdateProfileRequest': UpdateProfileRequest$json,
  '.heft.v1.UpdateProfileResponse': UpdateProfileResponse$json,
  '.heft.v1.UpdateSettingsRequest': UpdateSettingsRequest$json,
  '.heft.v1.UpdateSettingsResponse': UpdateSettingsResponse$json,
  '.heft.v1.LogWeightRequest': LogWeightRequest$json,
  '.heft.v1.LogWeightResponse': LogWeightResponse$json,
  '.heft.v1.WeightLog': WeightLog$json,
  '.heft.v1.GetWeightHistoryRequest': GetWeightHistoryRequest$json,
  '.heft.v1.GetWeightHistoryResponse': GetWeightHistoryResponse$json,
  '.heft.v1.DeleteWeightLogRequest': DeleteWeightLogRequest$json,
  '.heft.v1.DeleteWeightLogResponse': DeleteWeightLogResponse$json,
};

/// Descriptor for `UserService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List userServiceDescriptor = $convert.base64Decode(
    'CgtVc2VyU2VydmljZRJFCgpHZXRQcm9maWxlEhouaGVmdC52MS5HZXRQcm9maWxlUmVxdWVzdB'
    'obLmhlZnQudjEuR2V0UHJvZmlsZVJlc3BvbnNlEk4KDVVwZGF0ZVByb2ZpbGUSHS5oZWZ0LnYx'
    'LlVwZGF0ZVByb2ZpbGVSZXF1ZXN0Gh4uaGVmdC52MS5VcGRhdGVQcm9maWxlUmVzcG9uc2USUQ'
    'oOVXBkYXRlU2V0dGluZ3MSHi5oZWZ0LnYxLlVwZGF0ZVNldHRpbmdzUmVxdWVzdBofLmhlZnQu'
    'djEuVXBkYXRlU2V0dGluZ3NSZXNwb25zZRJCCglMb2dXZWlnaHQSGS5oZWZ0LnYxLkxvZ1dlaW'
    'dodFJlcXVlc3QaGi5oZWZ0LnYxLkxvZ1dlaWdodFJlc3BvbnNlElcKEEdldFdlaWdodEhpc3Rv'
    'cnkSIC5oZWZ0LnYxLkdldFdlaWdodEhpc3RvcnlSZXF1ZXN0GiEuaGVmdC52MS5HZXRXZWlnaH'
    'RIaXN0b3J5UmVzcG9uc2USVAoPRGVsZXRlV2VpZ2h0TG9nEh8uaGVmdC52MS5EZWxldGVXZWln'
    'aHRMb2dSZXF1ZXN0GiAuaGVmdC52MS5EZWxldGVXZWlnaHRMb2dSZXNwb25zZQ==');

