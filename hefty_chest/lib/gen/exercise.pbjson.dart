//
//  Generated code. Do not modify.
//  source: exercise.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'common.pbjson.dart' as $1;
import 'google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use exerciseCategoryDescriptor instead')
const ExerciseCategory$json = {
  '1': 'ExerciseCategory',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'display_order', '3': 3, '4': 1, '5': 5, '10': 'displayOrder'},
  ],
};

/// Descriptor for `ExerciseCategory`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exerciseCategoryDescriptor = $convert.base64Decode(
    'ChBFeGVyY2lzZUNhdGVnb3J5Eg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEi'
    'MKDWRpc3BsYXlfb3JkZXIYAyABKAVSDGRpc3BsYXlPcmRlcg==');

@$core.Deprecated('Use exerciseDescriptor instead')
const Exercise$json = {
  '1': 'Exercise',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'category_id', '3': 3, '4': 1, '5': 9, '10': 'categoryId'},
    {'1': 'category_name', '3': 4, '4': 1, '5': 9, '10': 'categoryName'},
    {'1': 'exercise_type', '3': 5, '4': 1, '5': 14, '6': '.heft.v1.ExerciseType', '10': 'exerciseType'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'is_system', '3': 7, '4': 1, '5': 8, '10': 'isSystem'},
    {'1': 'created_by', '3': 8, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
  ],
};

/// Descriptor for `Exercise`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exerciseDescriptor = $convert.base64Decode(
    'CghFeGVyY2lzZRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIfCgtjYXRlZ2'
    '9yeV9pZBgDIAEoCVIKY2F0ZWdvcnlJZBIjCg1jYXRlZ29yeV9uYW1lGAQgASgJUgxjYXRlZ29y'
    'eU5hbWUSOgoNZXhlcmNpc2VfdHlwZRgFIAEoDjIVLmhlZnQudjEuRXhlcmNpc2VUeXBlUgxleG'
    'VyY2lzZVR5cGUSIAoLZGVzY3JpcHRpb24YBiABKAlSC2Rlc2NyaXB0aW9uEhsKCWlzX3N5c3Rl'
    'bRgHIAEoCFIIaXNTeXN0ZW0SHQoKY3JlYXRlZF9ieRgIIAEoCVIJY3JlYXRlZEJ5EjkKCmNyZW'
    'F0ZWRfYXQYCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoK'
    'dXBkYXRlZF9hdBgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA'
    '==');

@$core.Deprecated('Use listExercisesRequestDescriptor instead')
const ListExercisesRequest$json = {
  '1': 'ListExercisesRequest',
  '2': [
    {'1': 'category_id', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'categoryId', '17': true},
    {'1': 'exercise_type', '3': 2, '4': 1, '5': 14, '6': '.heft.v1.ExerciseType', '9': 1, '10': 'exerciseType', '17': true},
    {'1': 'system_only', '3': 3, '4': 1, '5': 8, '9': 2, '10': 'systemOnly', '17': true},
    {'1': 'user_id', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'userId', '17': true},
    {'1': 'pagination', '3': 5, '4': 1, '5': 11, '6': '.heft.v1.PaginationRequest', '10': 'pagination'},
  ],
  '8': [
    {'1': '_category_id'},
    {'1': '_exercise_type'},
    {'1': '_system_only'},
    {'1': '_user_id'},
  ],
};

/// Descriptor for `ListExercisesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listExercisesRequestDescriptor = $convert.base64Decode(
    'ChRMaXN0RXhlcmNpc2VzUmVxdWVzdBIkCgtjYXRlZ29yeV9pZBgBIAEoCUgAUgpjYXRlZ29yeU'
    'lkiAEBEj8KDWV4ZXJjaXNlX3R5cGUYAiABKA4yFS5oZWZ0LnYxLkV4ZXJjaXNlVHlwZUgBUgxl'
    'eGVyY2lzZVR5cGWIAQESJAoLc3lzdGVtX29ubHkYAyABKAhIAlIKc3lzdGVtT25seYgBARIcCg'
    'd1c2VyX2lkGAQgASgJSANSBnVzZXJJZIgBARI6CgpwYWdpbmF0aW9uGAUgASgLMhouaGVmdC52'
    'MS5QYWdpbmF0aW9uUmVxdWVzdFIKcGFnaW5hdGlvbkIOCgxfY2F0ZWdvcnlfaWRCEAoOX2V4ZX'
    'JjaXNlX3R5cGVCDgoMX3N5c3RlbV9vbmx5QgoKCF91c2VyX2lk');

@$core.Deprecated('Use listExercisesResponseDescriptor instead')
const ListExercisesResponse$json = {
  '1': 'ListExercisesResponse',
  '2': [
    {'1': 'exercises', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.Exercise', '10': 'exercises'},
    {'1': 'pagination', '3': 2, '4': 1, '5': 11, '6': '.heft.v1.PaginationResponse', '10': 'pagination'},
  ],
};

/// Descriptor for `ListExercisesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listExercisesResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0RXhlcmNpc2VzUmVzcG9uc2USLwoJZXhlcmNpc2VzGAEgAygLMhEuaGVmdC52MS5FeG'
    'VyY2lzZVIJZXhlcmNpc2VzEjsKCnBhZ2luYXRpb24YAiABKAsyGy5oZWZ0LnYxLlBhZ2luYXRp'
    'b25SZXNwb25zZVIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use getExerciseRequestDescriptor instead')
const GetExerciseRequest$json = {
  '1': 'GetExerciseRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetExerciseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getExerciseRequestDescriptor = $convert.base64Decode(
    'ChJHZXRFeGVyY2lzZVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getExerciseResponseDescriptor instead')
const GetExerciseResponse$json = {
  '1': 'GetExerciseResponse',
  '2': [
    {'1': 'exercise', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Exercise', '10': 'exercise'},
  ],
};

/// Descriptor for `GetExerciseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getExerciseResponseDescriptor = $convert.base64Decode(
    'ChNHZXRFeGVyY2lzZVJlc3BvbnNlEi0KCGV4ZXJjaXNlGAEgASgLMhEuaGVmdC52MS5FeGVyY2'
    'lzZVIIZXhlcmNpc2U=');

@$core.Deprecated('Use createExerciseRequestDescriptor instead')
const CreateExerciseRequest$json = {
  '1': 'CreateExerciseRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'category_id', '3': 3, '4': 1, '5': 9, '10': 'categoryId'},
    {'1': 'exercise_type', '3': 4, '4': 1, '5': 14, '6': '.heft.v1.ExerciseType', '10': 'exerciseType'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'description', '17': true},
  ],
  '8': [
    {'1': '_description'},
  ],
};

/// Descriptor for `CreateExerciseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createExerciseRequestDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVFeGVyY2lzZVJlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhIKBG5hbW'
    'UYAiABKAlSBG5hbWUSHwoLY2F0ZWdvcnlfaWQYAyABKAlSCmNhdGVnb3J5SWQSOgoNZXhlcmNp'
    'c2VfdHlwZRgEIAEoDjIVLmhlZnQudjEuRXhlcmNpc2VUeXBlUgxleGVyY2lzZVR5cGUSJQoLZG'
    'VzY3JpcHRpb24YBSABKAlIAFILZGVzY3JpcHRpb26IAQFCDgoMX2Rlc2NyaXB0aW9u');

@$core.Deprecated('Use createExerciseResponseDescriptor instead')
const CreateExerciseResponse$json = {
  '1': 'CreateExerciseResponse',
  '2': [
    {'1': 'exercise', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Exercise', '10': 'exercise'},
  ],
};

/// Descriptor for `CreateExerciseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createExerciseResponseDescriptor = $convert.base64Decode(
    'ChZDcmVhdGVFeGVyY2lzZVJlc3BvbnNlEi0KCGV4ZXJjaXNlGAEgASgLMhEuaGVmdC52MS5FeG'
    'VyY2lzZVIIZXhlcmNpc2U=');

@$core.Deprecated('Use listCategoriesRequestDescriptor instead')
const ListCategoriesRequest$json = {
  '1': 'ListCategoriesRequest',
};

/// Descriptor for `ListCategoriesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCategoriesRequestDescriptor = $convert.base64Decode(
    'ChVMaXN0Q2F0ZWdvcmllc1JlcXVlc3Q=');

@$core.Deprecated('Use listCategoriesResponseDescriptor instead')
const ListCategoriesResponse$json = {
  '1': 'ListCategoriesResponse',
  '2': [
    {'1': 'categories', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.ExerciseCategory', '10': 'categories'},
  ],
};

/// Descriptor for `ListCategoriesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCategoriesResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0Q2F0ZWdvcmllc1Jlc3BvbnNlEjkKCmNhdGVnb3JpZXMYASADKAsyGS5oZWZ0LnYxLk'
    'V4ZXJjaXNlQ2F0ZWdvcnlSCmNhdGVnb3JpZXM=');

@$core.Deprecated('Use searchExercisesRequestDescriptor instead')
const SearchExercisesRequest$json = {
  '1': 'SearchExercisesRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'userId', '17': true},
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '9': 1, '10': 'limit', '17': true},
  ],
  '8': [
    {'1': '_user_id'},
    {'1': '_limit'},
  ],
};

/// Descriptor for `SearchExercisesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchExercisesRequestDescriptor = $convert.base64Decode(
    'ChZTZWFyY2hFeGVyY2lzZXNSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRIcCgd1c2VyX2'
    'lkGAIgASgJSABSBnVzZXJJZIgBARIZCgVsaW1pdBgDIAEoBUgBUgVsaW1pdIgBAUIKCghfdXNl'
    'cl9pZEIICgZfbGltaXQ=');

@$core.Deprecated('Use searchExercisesResponseDescriptor instead')
const SearchExercisesResponse$json = {
  '1': 'SearchExercisesResponse',
  '2': [
    {'1': 'exercises', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.Exercise', '10': 'exercises'},
  ],
};

/// Descriptor for `SearchExercisesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchExercisesResponseDescriptor = $convert.base64Decode(
    'ChdTZWFyY2hFeGVyY2lzZXNSZXNwb25zZRIvCglleGVyY2lzZXMYASADKAsyES5oZWZ0LnYxLk'
    'V4ZXJjaXNlUglleGVyY2lzZXM=');

const $core.Map<$core.String, $core.dynamic> ExerciseServiceBase$json = {
  '1': 'ExerciseService',
  '2': [
    {'1': 'ListExercises', '2': '.heft.v1.ListExercisesRequest', '3': '.heft.v1.ListExercisesResponse'},
    {'1': 'GetExercise', '2': '.heft.v1.GetExerciseRequest', '3': '.heft.v1.GetExerciseResponse'},
    {'1': 'CreateExercise', '2': '.heft.v1.CreateExerciseRequest', '3': '.heft.v1.CreateExerciseResponse'},
    {'1': 'ListCategories', '2': '.heft.v1.ListCategoriesRequest', '3': '.heft.v1.ListCategoriesResponse'},
    {'1': 'SearchExercises', '2': '.heft.v1.SearchExercisesRequest', '3': '.heft.v1.SearchExercisesResponse'},
  ],
};

@$core.Deprecated('Use exerciseServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ExerciseServiceBase$messageJson = {
  '.heft.v1.ListExercisesRequest': ListExercisesRequest$json,
  '.heft.v1.PaginationRequest': $1.PaginationRequest$json,
  '.heft.v1.ListExercisesResponse': ListExercisesResponse$json,
  '.heft.v1.Exercise': Exercise$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.heft.v1.PaginationResponse': $1.PaginationResponse$json,
  '.heft.v1.GetExerciseRequest': GetExerciseRequest$json,
  '.heft.v1.GetExerciseResponse': GetExerciseResponse$json,
  '.heft.v1.CreateExerciseRequest': CreateExerciseRequest$json,
  '.heft.v1.CreateExerciseResponse': CreateExerciseResponse$json,
  '.heft.v1.ListCategoriesRequest': ListCategoriesRequest$json,
  '.heft.v1.ListCategoriesResponse': ListCategoriesResponse$json,
  '.heft.v1.ExerciseCategory': ExerciseCategory$json,
  '.heft.v1.SearchExercisesRequest': SearchExercisesRequest$json,
  '.heft.v1.SearchExercisesResponse': SearchExercisesResponse$json,
};

/// Descriptor for `ExerciseService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List exerciseServiceDescriptor = $convert.base64Decode(
    'Cg9FeGVyY2lzZVNlcnZpY2USTgoNTGlzdEV4ZXJjaXNlcxIdLmhlZnQudjEuTGlzdEV4ZXJjaX'
    'Nlc1JlcXVlc3QaHi5oZWZ0LnYxLkxpc3RFeGVyY2lzZXNSZXNwb25zZRJICgtHZXRFeGVyY2lz'
    'ZRIbLmhlZnQudjEuR2V0RXhlcmNpc2VSZXF1ZXN0GhwuaGVmdC52MS5HZXRFeGVyY2lzZVJlc3'
    'BvbnNlElEKDkNyZWF0ZUV4ZXJjaXNlEh4uaGVmdC52MS5DcmVhdGVFeGVyY2lzZVJlcXVlc3Qa'
    'Hy5oZWZ0LnYxLkNyZWF0ZUV4ZXJjaXNlUmVzcG9uc2USUQoOTGlzdENhdGVnb3JpZXMSHi5oZW'
    'Z0LnYxLkxpc3RDYXRlZ29yaWVzUmVxdWVzdBofLmhlZnQudjEuTGlzdENhdGVnb3JpZXNSZXNw'
    'b25zZRJUCg9TZWFyY2hFeGVyY2lzZXMSHy5oZWZ0LnYxLlNlYXJjaEV4ZXJjaXNlc1JlcXVlc3'
    'QaIC5oZWZ0LnYxLlNlYXJjaEV4ZXJjaXNlc1Jlc3BvbnNl');

