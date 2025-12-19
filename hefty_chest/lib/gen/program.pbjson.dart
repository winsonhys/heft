//
//  Generated code. Do not modify.
//  source: program.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'common.pbjson.dart' as $2;
import 'google/protobuf/timestamp.pbjson.dart' as $1;
import 'workout.pbjson.dart' as $4;

@$core.Deprecated('Use programSummaryDescriptor instead')
const ProgramSummary$json = {
  '1': 'ProgramSummary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'duration_weeks', '3': 5, '4': 1, '5': 5, '10': 'durationWeeks'},
    {'1': 'duration_days', '3': 6, '4': 1, '5': 5, '10': 'durationDays'},
    {'1': 'total_workout_days', '3': 7, '4': 1, '5': 5, '10': 'totalWorkoutDays'},
    {'1': 'total_rest_days', '3': 8, '4': 1, '5': 5, '10': 'totalRestDays'},
    {'1': 'is_active', '3': 9, '4': 1, '5': 8, '10': 'isActive'},
    {'1': 'is_archived', '3': 10, '4': 1, '5': 8, '10': 'isArchived'},
    {'1': 'created_at', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 12, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
  ],
};

/// Descriptor for `ProgramSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List programSummaryDescriptor = $convert.base64Decode(
    'Cg5Qcm9ncmFtU3VtbWFyeRIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlck'
    'lkEhIKBG5hbWUYAyABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9u'
    'EiUKDmR1cmF0aW9uX3dlZWtzGAUgASgFUg1kdXJhdGlvbldlZWtzEiMKDWR1cmF0aW9uX2RheX'
    'MYBiABKAVSDGR1cmF0aW9uRGF5cxIsChJ0b3RhbF93b3Jrb3V0X2RheXMYByABKAVSEHRvdGFs'
    'V29ya291dERheXMSJgoPdG90YWxfcmVzdF9kYXlzGAggASgFUg10b3RhbFJlc3REYXlzEhsKCW'
    'lzX2FjdGl2ZRgJIAEoCFIIaXNBY3RpdmUSHwoLaXNfYXJjaGl2ZWQYCiABKAhSCmlzQXJjaGl2'
    'ZWQSOQoKY3JlYXRlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZW'
    'F0ZWRBdBI5Cgp1cGRhdGVkX2F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJ'
    'dXBkYXRlZEF0');

@$core.Deprecated('Use programDescriptor instead')
const Program$json = {
  '1': 'Program',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'duration_weeks', '3': 5, '4': 1, '5': 5, '10': 'durationWeeks'},
    {'1': 'duration_days', '3': 6, '4': 1, '5': 5, '10': 'durationDays'},
    {'1': 'total_workout_days', '3': 7, '4': 1, '5': 5, '10': 'totalWorkoutDays'},
    {'1': 'total_rest_days', '3': 8, '4': 1, '5': 5, '10': 'totalRestDays'},
    {'1': 'is_active', '3': 9, '4': 1, '5': 8, '10': 'isActive'},
    {'1': 'is_archived', '3': 10, '4': 1, '5': 8, '10': 'isArchived'},
    {'1': 'days', '3': 11, '4': 3, '5': 11, '6': '.heft.v1.ProgramDay', '10': 'days'},
    {'1': 'created_at', '3': 12, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 13, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
  ],
};

/// Descriptor for `Program`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List programDescriptor = $convert.base64Decode(
    'CgdQcm9ncmFtEg4KAmlkGAEgASgJUgJpZBIXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSEgoEbm'
    'FtZRgDIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgEIAEoCVILZGVzY3JpcHRpb24SJQoOZHVy'
    'YXRpb25fd2Vla3MYBSABKAVSDWR1cmF0aW9uV2Vla3MSIwoNZHVyYXRpb25fZGF5cxgGIAEoBV'
    'IMZHVyYXRpb25EYXlzEiwKEnRvdGFsX3dvcmtvdXRfZGF5cxgHIAEoBVIQdG90YWxXb3Jrb3V0'
    'RGF5cxImCg90b3RhbF9yZXN0X2RheXMYCCABKAVSDXRvdGFsUmVzdERheXMSGwoJaXNfYWN0aX'
    'ZlGAkgASgIUghpc0FjdGl2ZRIfCgtpc19hcmNoaXZlZBgKIAEoCFIKaXNBcmNoaXZlZBInCgRk'
    'YXlzGAsgAygLMhMuaGVmdC52MS5Qcm9ncmFtRGF5UgRkYXlzEjkKCmNyZWF0ZWRfYXQYDCABKA'
    'syGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgN'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use programDayDescriptor instead')
const ProgramDay$json = {
  '1': 'ProgramDay',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'program_id', '3': 2, '4': 1, '5': 9, '10': 'programId'},
    {'1': 'day_number', '3': 3, '4': 1, '5': 5, '10': 'dayNumber'},
    {'1': 'day_type', '3': 4, '4': 1, '5': 14, '6': '.heft.v1.ProgramDayType', '10': 'dayType'},
    {'1': 'workout_template_id', '3': 5, '4': 1, '5': 9, '10': 'workoutTemplateId'},
    {'1': 'workout_name', '3': 6, '4': 1, '5': 9, '10': 'workoutName'},
    {'1': 'custom_name', '3': 7, '4': 1, '5': 9, '10': 'customName'},
  ],
};

/// Descriptor for `ProgramDay`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List programDayDescriptor = $convert.base64Decode(
    'CgpQcm9ncmFtRGF5Eg4KAmlkGAEgASgJUgJpZBIdCgpwcm9ncmFtX2lkGAIgASgJUglwcm9ncm'
    'FtSWQSHQoKZGF5X251bWJlchgDIAEoBVIJZGF5TnVtYmVyEjIKCGRheV90eXBlGAQgASgOMhcu'
    'aGVmdC52MS5Qcm9ncmFtRGF5VHlwZVIHZGF5VHlwZRIuChN3b3Jrb3V0X3RlbXBsYXRlX2lkGA'
    'UgASgJUhF3b3Jrb3V0VGVtcGxhdGVJZBIhCgx3b3Jrb3V0X25hbWUYBiABKAlSC3dvcmtvdXRO'
    'YW1lEh8KC2N1c3RvbV9uYW1lGAcgASgJUgpjdXN0b21OYW1l');

@$core.Deprecated('Use listProgramsRequestDescriptor instead')
const ListProgramsRequest$json = {
  '1': 'ListProgramsRequest',
  '2': [
    {'1': 'include_archived', '3': 1, '4': 1, '5': 8, '9': 0, '10': 'includeArchived', '17': true},
    {'1': 'pagination', '3': 2, '4': 1, '5': 11, '6': '.heft.v1.PaginationRequest', '10': 'pagination'},
  ],
  '8': [
    {'1': '_include_archived'},
  ],
};

/// Descriptor for `ListProgramsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProgramsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0UHJvZ3JhbXNSZXF1ZXN0Ei4KEGluY2x1ZGVfYXJjaGl2ZWQYASABKAhIAFIPaW5jbH'
    'VkZUFyY2hpdmVkiAEBEjoKCnBhZ2luYXRpb24YAiABKAsyGi5oZWZ0LnYxLlBhZ2luYXRpb25S'
    'ZXF1ZXN0UgpwYWdpbmF0aW9uQhMKEV9pbmNsdWRlX2FyY2hpdmVk');

@$core.Deprecated('Use listProgramsResponseDescriptor instead')
const ListProgramsResponse$json = {
  '1': 'ListProgramsResponse',
  '2': [
    {'1': 'programs', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.ProgramSummary', '10': 'programs'},
    {'1': 'pagination', '3': 2, '4': 1, '5': 11, '6': '.heft.v1.PaginationResponse', '10': 'pagination'},
  ],
};

/// Descriptor for `ListProgramsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProgramsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0UHJvZ3JhbXNSZXNwb25zZRIzCghwcm9ncmFtcxgBIAMoCzIXLmhlZnQudjEuUHJvZ3'
    'JhbVN1bW1hcnlSCHByb2dyYW1zEjsKCnBhZ2luYXRpb24YAiABKAsyGy5oZWZ0LnYxLlBhZ2lu'
    'YXRpb25SZXNwb25zZVIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use getProgramRequestDescriptor instead')
const GetProgramRequest$json = {
  '1': 'GetProgramRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetProgramRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProgramRequestDescriptor = $convert.base64Decode(
    'ChFHZXRQcm9ncmFtUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getProgramResponseDescriptor instead')
const GetProgramResponse$json = {
  '1': 'GetProgramResponse',
  '2': [
    {'1': 'program', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Program', '10': 'program'},
  ],
};

/// Descriptor for `GetProgramResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProgramResponseDescriptor = $convert.base64Decode(
    'ChJHZXRQcm9ncmFtUmVzcG9uc2USKgoHcHJvZ3JhbRgBIAEoCzIQLmhlZnQudjEuUHJvZ3JhbV'
    'IHcHJvZ3JhbQ==');

@$core.Deprecated('Use createProgramRequestDescriptor instead')
const CreateProgramRequest$json = {
  '1': 'CreateProgramRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'description', '17': true},
    {'1': 'duration_weeks', '3': 3, '4': 1, '5': 5, '10': 'durationWeeks'},
    {'1': 'duration_days', '3': 4, '4': 1, '5': 5, '10': 'durationDays'},
    {'1': 'days', '3': 5, '4': 3, '5': 11, '6': '.heft.v1.CreateProgramDay', '10': 'days'},
  ],
  '8': [
    {'1': '_description'},
  ],
};

/// Descriptor for `CreateProgramRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProgramRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVQcm9ncmFtUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEiUKC2Rlc2NyaXB0aW'
    '9uGAIgASgJSABSC2Rlc2NyaXB0aW9uiAEBEiUKDmR1cmF0aW9uX3dlZWtzGAMgASgFUg1kdXJh'
    'dGlvbldlZWtzEiMKDWR1cmF0aW9uX2RheXMYBCABKAVSDGR1cmF0aW9uRGF5cxItCgRkYXlzGA'
    'UgAygLMhkuaGVmdC52MS5DcmVhdGVQcm9ncmFtRGF5UgRkYXlzQg4KDF9kZXNjcmlwdGlvbg==');

@$core.Deprecated('Use createProgramDayDescriptor instead')
const CreateProgramDay$json = {
  '1': 'CreateProgramDay',
  '2': [
    {'1': 'day_number', '3': 1, '4': 1, '5': 5, '10': 'dayNumber'},
    {'1': 'day_type', '3': 2, '4': 1, '5': 14, '6': '.heft.v1.ProgramDayType', '10': 'dayType'},
    {'1': 'workout_template_id', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'workoutTemplateId', '17': true},
    {'1': 'custom_name', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'customName', '17': true},
  ],
  '8': [
    {'1': '_workout_template_id'},
    {'1': '_custom_name'},
  ],
};

/// Descriptor for `CreateProgramDay`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProgramDayDescriptor = $convert.base64Decode(
    'ChBDcmVhdGVQcm9ncmFtRGF5Eh0KCmRheV9udW1iZXIYASABKAVSCWRheU51bWJlchIyCghkYX'
    'lfdHlwZRgCIAEoDjIXLmhlZnQudjEuUHJvZ3JhbURheVR5cGVSB2RheVR5cGUSMwoTd29ya291'
    'dF90ZW1wbGF0ZV9pZBgDIAEoCUgAUhF3b3Jrb3V0VGVtcGxhdGVJZIgBARIkCgtjdXN0b21fbm'
    'FtZRgEIAEoCUgBUgpjdXN0b21OYW1liAEBQhYKFF93b3Jrb3V0X3RlbXBsYXRlX2lkQg4KDF9j'
    'dXN0b21fbmFtZQ==');

@$core.Deprecated('Use createProgramResponseDescriptor instead')
const CreateProgramResponse$json = {
  '1': 'CreateProgramResponse',
  '2': [
    {'1': 'program', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Program', '10': 'program'},
  ],
};

/// Descriptor for `CreateProgramResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createProgramResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVQcm9ncmFtUmVzcG9uc2USKgoHcHJvZ3JhbRgBIAEoCzIQLmhlZnQudjEuUHJvZ3'
    'JhbVIHcHJvZ3JhbQ==');

@$core.Deprecated('Use updateProgramRequestDescriptor instead')
const UpdateProgramRequest$json = {
  '1': 'UpdateProgramRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'name', '17': true},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'description', '17': true},
    {'1': 'duration_weeks', '3': 4, '4': 1, '5': 5, '9': 2, '10': 'durationWeeks', '17': true},
    {'1': 'duration_days', '3': 5, '4': 1, '5': 5, '9': 3, '10': 'durationDays', '17': true},
    {'1': 'is_archived', '3': 6, '4': 1, '5': 8, '9': 4, '10': 'isArchived', '17': true},
    {'1': 'days', '3': 7, '4': 3, '5': 11, '6': '.heft.v1.CreateProgramDay', '10': 'days'},
  ],
  '8': [
    {'1': '_name'},
    {'1': '_description'},
    {'1': '_duration_weeks'},
    {'1': '_duration_days'},
    {'1': '_is_archived'},
  ],
};

/// Descriptor for `UpdateProgramRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProgramRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVQcm9ncmFtUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFwoEbmFtZRgCIAEoCUgAUg'
    'RuYW1liAEBEiUKC2Rlc2NyaXB0aW9uGAMgASgJSAFSC2Rlc2NyaXB0aW9uiAEBEioKDmR1cmF0'
    'aW9uX3dlZWtzGAQgASgFSAJSDWR1cmF0aW9uV2Vla3OIAQESKAoNZHVyYXRpb25fZGF5cxgFIA'
    'EoBUgDUgxkdXJhdGlvbkRheXOIAQESJAoLaXNfYXJjaGl2ZWQYBiABKAhIBFIKaXNBcmNoaXZl'
    'ZIgBARItCgRkYXlzGAcgAygLMhkuaGVmdC52MS5DcmVhdGVQcm9ncmFtRGF5UgRkYXlzQgcKBV'
    '9uYW1lQg4KDF9kZXNjcmlwdGlvbkIRCg9fZHVyYXRpb25fd2Vla3NCEAoOX2R1cmF0aW9uX2Rh'
    'eXNCDgoMX2lzX2FyY2hpdmVk');

@$core.Deprecated('Use updateProgramResponseDescriptor instead')
const UpdateProgramResponse$json = {
  '1': 'UpdateProgramResponse',
  '2': [
    {'1': 'program', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Program', '10': 'program'},
  ],
};

/// Descriptor for `UpdateProgramResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateProgramResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVQcm9ncmFtUmVzcG9uc2USKgoHcHJvZ3JhbRgBIAEoCzIQLmhlZnQudjEuUHJvZ3'
    'JhbVIHcHJvZ3JhbQ==');

@$core.Deprecated('Use deleteProgramRequestDescriptor instead')
const DeleteProgramRequest$json = {
  '1': 'DeleteProgramRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteProgramRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteProgramRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVQcm9ncmFtUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteProgramResponseDescriptor instead')
const DeleteProgramResponse$json = {
  '1': 'DeleteProgramResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `DeleteProgramResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteProgramResponseDescriptor = $convert.base64Decode(
    'ChVEZWxldGVQcm9ncmFtUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use setActiveProgramRequestDescriptor instead')
const SetActiveProgramRequest$json = {
  '1': 'SetActiveProgramRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `SetActiveProgramRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setActiveProgramRequestDescriptor = $convert.base64Decode(
    'ChdTZXRBY3RpdmVQcm9ncmFtUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use setActiveProgramResponseDescriptor instead')
const SetActiveProgramResponse$json = {
  '1': 'SetActiveProgramResponse',
  '2': [
    {'1': 'program', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Program', '10': 'program'},
  ],
};

/// Descriptor for `SetActiveProgramResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setActiveProgramResponseDescriptor = $convert.base64Decode(
    'ChhTZXRBY3RpdmVQcm9ncmFtUmVzcG9uc2USKgoHcHJvZ3JhbRgBIAEoCzIQLmhlZnQudjEuUH'
    'JvZ3JhbVIHcHJvZ3JhbQ==');

@$core.Deprecated('Use getTodayWorkoutRequestDescriptor instead')
const GetTodayWorkoutRequest$json = {
  '1': 'GetTodayWorkoutRequest',
};

/// Descriptor for `GetTodayWorkoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTodayWorkoutRequestDescriptor = $convert.base64Decode(
    'ChZHZXRUb2RheVdvcmtvdXRSZXF1ZXN0');

@$core.Deprecated('Use getTodayWorkoutResponseDescriptor instead')
const GetTodayWorkoutResponse$json = {
  '1': 'GetTodayWorkoutResponse',
  '2': [
    {'1': 'has_workout', '3': 1, '4': 1, '5': 8, '10': 'hasWorkout'},
    {'1': 'day_number', '3': 2, '4': 1, '5': 5, '10': 'dayNumber'},
    {'1': 'day_type', '3': 3, '4': 1, '5': 14, '6': '.heft.v1.ProgramDayType', '10': 'dayType'},
    {'1': 'workout', '3': 4, '4': 1, '5': 11, '6': '.heft.v1.Workout', '10': 'workout'},
    {'1': 'program', '3': 5, '4': 1, '5': 11, '6': '.heft.v1.Program', '10': 'program'},
  ],
};

/// Descriptor for `GetTodayWorkoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTodayWorkoutResponseDescriptor = $convert.base64Decode(
    'ChdHZXRUb2RheVdvcmtvdXRSZXNwb25zZRIfCgtoYXNfd29ya291dBgBIAEoCFIKaGFzV29ya2'
    '91dBIdCgpkYXlfbnVtYmVyGAIgASgFUglkYXlOdW1iZXISMgoIZGF5X3R5cGUYAyABKA4yFy5o'
    'ZWZ0LnYxLlByb2dyYW1EYXlUeXBlUgdkYXlUeXBlEioKB3dvcmtvdXQYBCABKAsyEC5oZWZ0Ln'
    'YxLldvcmtvdXRSB3dvcmtvdXQSKgoHcHJvZ3JhbRgFIAEoCzIQLmhlZnQudjEuUHJvZ3JhbVIH'
    'cHJvZ3JhbQ==');

const $core.Map<$core.String, $core.dynamic> ProgramServiceBase$json = {
  '1': 'ProgramService',
  '2': [
    {'1': 'ListPrograms', '2': '.heft.v1.ListProgramsRequest', '3': '.heft.v1.ListProgramsResponse'},
    {'1': 'GetProgram', '2': '.heft.v1.GetProgramRequest', '3': '.heft.v1.GetProgramResponse'},
    {'1': 'CreateProgram', '2': '.heft.v1.CreateProgramRequest', '3': '.heft.v1.CreateProgramResponse'},
    {'1': 'UpdateProgram', '2': '.heft.v1.UpdateProgramRequest', '3': '.heft.v1.UpdateProgramResponse'},
    {'1': 'DeleteProgram', '2': '.heft.v1.DeleteProgramRequest', '3': '.heft.v1.DeleteProgramResponse'},
    {'1': 'SetActiveProgram', '2': '.heft.v1.SetActiveProgramRequest', '3': '.heft.v1.SetActiveProgramResponse'},
    {'1': 'GetTodayWorkout', '2': '.heft.v1.GetTodayWorkoutRequest', '3': '.heft.v1.GetTodayWorkoutResponse'},
  ],
};

@$core.Deprecated('Use programServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ProgramServiceBase$messageJson = {
  '.heft.v1.ListProgramsRequest': ListProgramsRequest$json,
  '.heft.v1.PaginationRequest': $2.PaginationRequest$json,
  '.heft.v1.ListProgramsResponse': ListProgramsResponse$json,
  '.heft.v1.ProgramSummary': ProgramSummary$json,
  '.google.protobuf.Timestamp': $1.Timestamp$json,
  '.heft.v1.PaginationResponse': $2.PaginationResponse$json,
  '.heft.v1.GetProgramRequest': GetProgramRequest$json,
  '.heft.v1.GetProgramResponse': GetProgramResponse$json,
  '.heft.v1.Program': Program$json,
  '.heft.v1.ProgramDay': ProgramDay$json,
  '.heft.v1.CreateProgramRequest': CreateProgramRequest$json,
  '.heft.v1.CreateProgramDay': CreateProgramDay$json,
  '.heft.v1.CreateProgramResponse': CreateProgramResponse$json,
  '.heft.v1.UpdateProgramRequest': UpdateProgramRequest$json,
  '.heft.v1.UpdateProgramResponse': UpdateProgramResponse$json,
  '.heft.v1.DeleteProgramRequest': DeleteProgramRequest$json,
  '.heft.v1.DeleteProgramResponse': DeleteProgramResponse$json,
  '.heft.v1.SetActiveProgramRequest': SetActiveProgramRequest$json,
  '.heft.v1.SetActiveProgramResponse': SetActiveProgramResponse$json,
  '.heft.v1.GetTodayWorkoutRequest': GetTodayWorkoutRequest$json,
  '.heft.v1.GetTodayWorkoutResponse': GetTodayWorkoutResponse$json,
  '.heft.v1.Workout': $4.Workout$json,
  '.heft.v1.WorkoutSection': $4.WorkoutSection$json,
  '.heft.v1.SectionItem': $4.SectionItem$json,
  '.heft.v1.TargetSet': $4.TargetSet$json,
};

/// Descriptor for `ProgramService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List programServiceDescriptor = $convert.base64Decode(
    'Cg5Qcm9ncmFtU2VydmljZRJLCgxMaXN0UHJvZ3JhbXMSHC5oZWZ0LnYxLkxpc3RQcm9ncmFtc1'
    'JlcXVlc3QaHS5oZWZ0LnYxLkxpc3RQcm9ncmFtc1Jlc3BvbnNlEkUKCkdldFByb2dyYW0SGi5o'
    'ZWZ0LnYxLkdldFByb2dyYW1SZXF1ZXN0GhsuaGVmdC52MS5HZXRQcm9ncmFtUmVzcG9uc2USTg'
    'oNQ3JlYXRlUHJvZ3JhbRIdLmhlZnQudjEuQ3JlYXRlUHJvZ3JhbVJlcXVlc3QaHi5oZWZ0LnYx'
    'LkNyZWF0ZVByb2dyYW1SZXNwb25zZRJOCg1VcGRhdGVQcm9ncmFtEh0uaGVmdC52MS5VcGRhdG'
    'VQcm9ncmFtUmVxdWVzdBoeLmhlZnQudjEuVXBkYXRlUHJvZ3JhbVJlc3BvbnNlEk4KDURlbGV0'
    'ZVByb2dyYW0SHS5oZWZ0LnYxLkRlbGV0ZVByb2dyYW1SZXF1ZXN0Gh4uaGVmdC52MS5EZWxldG'
    'VQcm9ncmFtUmVzcG9uc2USVwoQU2V0QWN0aXZlUHJvZ3JhbRIgLmhlZnQudjEuU2V0QWN0aXZl'
    'UHJvZ3JhbVJlcXVlc3QaIS5oZWZ0LnYxLlNldEFjdGl2ZVByb2dyYW1SZXNwb25zZRJUCg9HZX'
    'RUb2RheVdvcmtvdXQSHy5oZWZ0LnYxLkdldFRvZGF5V29ya291dFJlcXVlc3QaIC5oZWZ0LnYx'
    'LkdldFRvZGF5V29ya291dFJlc3BvbnNl');

