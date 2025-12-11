//
//  Generated code. Do not modify.
//  source: common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use exerciseTypeDescriptor instead')
const ExerciseType$json = {
  '1': 'ExerciseType',
  '2': [
    {'1': 'EXERCISE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'EXERCISE_TYPE_WEIGHT_REPS', '2': 1},
    {'1': 'EXERCISE_TYPE_BODYWEIGHT_REPS', '2': 2},
    {'1': 'EXERCISE_TYPE_TIME', '2': 3},
    {'1': 'EXERCISE_TYPE_DISTANCE', '2': 4},
    {'1': 'EXERCISE_TYPE_CARDIO', '2': 5},
  ],
};

/// Descriptor for `ExerciseType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List exerciseTypeDescriptor = $convert.base64Decode(
    'CgxFeGVyY2lzZVR5cGUSHQoZRVhFUkNJU0VfVFlQRV9VTlNQRUNJRklFRBAAEh0KGUVYRVJDSV'
    'NFX1RZUEVfV0VJR0hUX1JFUFMQARIhCh1FWEVSQ0lTRV9UWVBFX0JPRFlXRUlHSFRfUkVQUxAC'
    'EhYKEkVYRVJDSVNFX1RZUEVfVElNRRADEhoKFkVYRVJDSVNFX1RZUEVfRElTVEFOQ0UQBBIYCh'
    'RFWEVSQ0lTRV9UWVBFX0NBUkRJTxAF');

@$core.Deprecated('Use workoutStatusDescriptor instead')
const WorkoutStatus$json = {
  '1': 'WorkoutStatus',
  '2': [
    {'1': 'WORKOUT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'WORKOUT_STATUS_IN_PROGRESS', '2': 1},
    {'1': 'WORKOUT_STATUS_COMPLETED', '2': 2},
    {'1': 'WORKOUT_STATUS_ABANDONED', '2': 3},
  ],
};

/// Descriptor for `WorkoutStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List workoutStatusDescriptor = $convert.base64Decode(
    'Cg1Xb3Jrb3V0U3RhdHVzEh4KGldPUktPVVRfU1RBVFVTX1VOU1BFQ0lGSUVEEAASHgoaV09SS0'
    '9VVF9TVEFUVVNfSU5fUFJPR1JFU1MQARIcChhXT1JLT1VUX1NUQVRVU19DT01QTEVURUQQAhIc'
    'ChhXT1JLT1VUX1NUQVRVU19BQkFORE9ORUQQAw==');

@$core.Deprecated('Use programDayTypeDescriptor instead')
const ProgramDayType$json = {
  '1': 'ProgramDayType',
  '2': [
    {'1': 'PROGRAM_DAY_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'PROGRAM_DAY_TYPE_WORKOUT', '2': 1},
    {'1': 'PROGRAM_DAY_TYPE_REST', '2': 2},
    {'1': 'PROGRAM_DAY_TYPE_UNASSIGNED', '2': 3},
  ],
};

/// Descriptor for `ProgramDayType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List programDayTypeDescriptor = $convert.base64Decode(
    'Cg5Qcm9ncmFtRGF5VHlwZRIgChxQUk9HUkFNX0RBWV9UWVBFX1VOU1BFQ0lGSUVEEAASHAoYUF'
    'JPR1JBTV9EQVlfVFlQRV9XT1JLT1VUEAESGQoVUFJPR1JBTV9EQVlfVFlQRV9SRVNUEAISHwob'
    'UFJPR1JBTV9EQVlfVFlQRV9VTkFTU0lHTkVEEAM=');

@$core.Deprecated('Use sectionItemTypeDescriptor instead')
const SectionItemType$json = {
  '1': 'SectionItemType',
  '2': [
    {'1': 'SECTION_ITEM_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SECTION_ITEM_TYPE_EXERCISE', '2': 1},
    {'1': 'SECTION_ITEM_TYPE_REST', '2': 2},
  ],
};

/// Descriptor for `SectionItemType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sectionItemTypeDescriptor = $convert.base64Decode(
    'Cg9TZWN0aW9uSXRlbVR5cGUSIQodU0VDVElPTl9JVEVNX1RZUEVfVU5TUEVDSUZJRUQQABIeCh'
    'pTRUNUSU9OX0lURU1fVFlQRV9FWEVSQ0lTRRABEhoKFlNFQ1RJT05fSVRFTV9UWVBFX1JFU1QQ'
    'Ag==');

@$core.Deprecated('Use paginationRequestDescriptor instead')
const PaginationRequest$json = {
  '1': 'PaginationRequest',
  '2': [
    {'1': 'page', '3': 1, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `PaginationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paginationRequestDescriptor = $convert.base64Decode(
    'ChFQYWdpbmF0aW9uUmVxdWVzdBISCgRwYWdlGAEgASgFUgRwYWdlEhsKCXBhZ2Vfc2l6ZRgCIA'
    'EoBVIIcGFnZVNpemU=');

@$core.Deprecated('Use paginationResponseDescriptor instead')
const PaginationResponse$json = {
  '1': 'PaginationResponse',
  '2': [
    {'1': 'page', '3': 1, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'total_pages', '3': 4, '4': 1, '5': 5, '10': 'totalPages'},
  ],
};

/// Descriptor for `PaginationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paginationResponseDescriptor = $convert.base64Decode(
    'ChJQYWdpbmF0aW9uUmVzcG9uc2USEgoEcGFnZRgBIAEoBVIEcGFnZRIbCglwYWdlX3NpemUYAi'
    'ABKAVSCHBhZ2VTaXplEh8KC3RvdGFsX2NvdW50GAMgASgFUgp0b3RhbENvdW50Eh8KC3RvdGFs'
    'X3BhZ2VzGAQgASgFUgp0b3RhbFBhZ2Vz');

