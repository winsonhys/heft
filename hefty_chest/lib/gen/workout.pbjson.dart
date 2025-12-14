//
//  Generated code. Do not modify.
//  source: workout.proto
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

@$core.Deprecated('Use workoutSummaryDescriptor instead')
const WorkoutSummary$json = {
  '1': 'WorkoutSummary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'total_exercises', '3': 5, '4': 1, '5': 5, '10': 'totalExercises'},
    {'1': 'total_sets', '3': 6, '4': 1, '5': 5, '10': 'totalSets'},
    {'1': 'estimated_duration_minutes', '3': 7, '4': 1, '5': 5, '10': 'estimatedDurationMinutes'},
    {'1': 'is_archived', '3': 8, '4': 1, '5': 8, '10': 'isArchived'},
    {'1': 'created_at', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
  ],
};

/// Descriptor for `WorkoutSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workoutSummaryDescriptor = $convert.base64Decode(
    'Cg5Xb3Jrb3V0U3VtbWFyeRIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlck'
    'lkEhIKBG5hbWUYAyABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9u'
    'EicKD3RvdGFsX2V4ZXJjaXNlcxgFIAEoBVIOdG90YWxFeGVyY2lzZXMSHQoKdG90YWxfc2V0cx'
    'gGIAEoBVIJdG90YWxTZXRzEjwKGmVzdGltYXRlZF9kdXJhdGlvbl9taW51dGVzGAcgASgFUhhl'
    'c3RpbWF0ZWREdXJhdGlvbk1pbnV0ZXMSHwoLaXNfYXJjaGl2ZWQYCCABKAhSCmlzQXJjaGl2ZW'
    'QSOQoKY3JlYXRlZF9hdBgJIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0'
    'ZWRBdBI5Cgp1cGRhdGVkX2F0GAogASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdX'
    'BkYXRlZEF0');

@$core.Deprecated('Use workoutDescriptor instead')
const Workout$json = {
  '1': 'Workout',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'total_exercises', '3': 5, '4': 1, '5': 5, '10': 'totalExercises'},
    {'1': 'total_sets', '3': 6, '4': 1, '5': 5, '10': 'totalSets'},
    {'1': 'estimated_duration_minutes', '3': 7, '4': 1, '5': 5, '10': 'estimatedDurationMinutes'},
    {'1': 'is_archived', '3': 8, '4': 1, '5': 8, '10': 'isArchived'},
    {'1': 'sections', '3': 9, '4': 3, '5': 11, '6': '.heft.v1.WorkoutSection', '10': 'sections'},
    {'1': 'created_at', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
  ],
};

/// Descriptor for `Workout`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workoutDescriptor = $convert.base64Decode(
    'CgdXb3Jrb3V0Eg4KAmlkGAEgASgJUgJpZBIXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSEgoEbm'
    'FtZRgDIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgEIAEoCVILZGVzY3JpcHRpb24SJwoPdG90'
    'YWxfZXhlcmNpc2VzGAUgASgFUg50b3RhbEV4ZXJjaXNlcxIdCgp0b3RhbF9zZXRzGAYgASgFUg'
    'l0b3RhbFNldHMSPAoaZXN0aW1hdGVkX2R1cmF0aW9uX21pbnV0ZXMYByABKAVSGGVzdGltYXRl'
    'ZER1cmF0aW9uTWludXRlcxIfCgtpc19hcmNoaXZlZBgIIAEoCFIKaXNBcmNoaXZlZBIzCghzZW'
    'N0aW9ucxgJIAMoCzIXLmhlZnQudjEuV29ya291dFNlY3Rpb25SCHNlY3Rpb25zEjkKCmNyZWF0'
    'ZWRfYXQYCiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdX'
    'BkYXRlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use workoutSectionDescriptor instead')
const WorkoutSection$json = {
  '1': 'WorkoutSection',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'workout_template_id', '3': 2, '4': 1, '5': 9, '10': 'workoutTemplateId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'display_order', '3': 4, '4': 1, '5': 5, '10': 'displayOrder'},
    {'1': 'is_superset', '3': 5, '4': 1, '5': 8, '10': 'isSuperset'},
    {'1': 'items', '3': 6, '4': 3, '5': 11, '6': '.heft.v1.SectionItem', '10': 'items'},
  ],
};

/// Descriptor for `WorkoutSection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workoutSectionDescriptor = $convert.base64Decode(
    'Cg5Xb3Jrb3V0U2VjdGlvbhIOCgJpZBgBIAEoCVICaWQSLgoTd29ya291dF90ZW1wbGF0ZV9pZB'
    'gCIAEoCVIRd29ya291dFRlbXBsYXRlSWQSEgoEbmFtZRgDIAEoCVIEbmFtZRIjCg1kaXNwbGF5'
    'X29yZGVyGAQgASgFUgxkaXNwbGF5T3JkZXISHwoLaXNfc3VwZXJzZXQYBSABKAhSCmlzU3VwZX'
    'JzZXQSKgoFaXRlbXMYBiADKAsyFC5oZWZ0LnYxLlNlY3Rpb25JdGVtUgVpdGVtcw==');

@$core.Deprecated('Use sectionItemDescriptor instead')
const SectionItem$json = {
  '1': 'SectionItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'section_id', '3': 2, '4': 1, '5': 9, '10': 'sectionId'},
    {'1': 'item_type', '3': 3, '4': 1, '5': 14, '6': '.heft.v1.SectionItemType', '10': 'itemType'},
    {'1': 'display_order', '3': 4, '4': 1, '5': 5, '10': 'displayOrder'},
    {'1': 'exercise_id', '3': 5, '4': 1, '5': 9, '10': 'exerciseId'},
    {'1': 'exercise_name', '3': 6, '4': 1, '5': 9, '10': 'exerciseName'},
    {'1': 'exercise_type', '3': 7, '4': 1, '5': 14, '6': '.heft.v1.ExerciseType', '10': 'exerciseType'},
    {'1': 'target_sets', '3': 8, '4': 3, '5': 11, '6': '.heft.v1.TargetSet', '10': 'targetSets'},
    {'1': 'rest_duration_seconds', '3': 9, '4': 1, '5': 5, '10': 'restDurationSeconds'},
  ],
};

/// Descriptor for `SectionItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sectionItemDescriptor = $convert.base64Decode(
    'CgtTZWN0aW9uSXRlbRIOCgJpZBgBIAEoCVICaWQSHQoKc2VjdGlvbl9pZBgCIAEoCVIJc2VjdG'
    'lvbklkEjUKCWl0ZW1fdHlwZRgDIAEoDjIYLmhlZnQudjEuU2VjdGlvbkl0ZW1UeXBlUghpdGVt'
    'VHlwZRIjCg1kaXNwbGF5X29yZGVyGAQgASgFUgxkaXNwbGF5T3JkZXISHwoLZXhlcmNpc2VfaW'
    'QYBSABKAlSCmV4ZXJjaXNlSWQSIwoNZXhlcmNpc2VfbmFtZRgGIAEoCVIMZXhlcmNpc2VOYW1l'
    'EjoKDWV4ZXJjaXNlX3R5cGUYByABKA4yFS5oZWZ0LnYxLkV4ZXJjaXNlVHlwZVIMZXhlcmNpc2'
    'VUeXBlEjMKC3RhcmdldF9zZXRzGAggAygLMhIuaGVmdC52MS5UYXJnZXRTZXRSCnRhcmdldFNl'
    'dHMSMgoVcmVzdF9kdXJhdGlvbl9zZWNvbmRzGAkgASgFUhNyZXN0RHVyYXRpb25TZWNvbmRz');

@$core.Deprecated('Use targetSetDescriptor instead')
const TargetSet$json = {
  '1': 'TargetSet',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'section_item_id', '3': 2, '4': 1, '5': 9, '10': 'sectionItemId'},
    {'1': 'set_number', '3': 3, '4': 1, '5': 5, '10': 'setNumber'},
    {'1': 'target_weight_kg', '3': 4, '4': 1, '5': 1, '9': 0, '10': 'targetWeightKg', '17': true},
    {'1': 'target_reps', '3': 5, '4': 1, '5': 5, '9': 1, '10': 'targetReps', '17': true},
    {'1': 'target_time_seconds', '3': 6, '4': 1, '5': 5, '9': 2, '10': 'targetTimeSeconds', '17': true},
    {'1': 'target_distance_m', '3': 7, '4': 1, '5': 1, '9': 3, '10': 'targetDistanceM', '17': true},
    {'1': 'is_bodyweight', '3': 8, '4': 1, '5': 8, '10': 'isBodyweight'},
    {'1': 'notes', '3': 9, '4': 1, '5': 9, '10': 'notes'},
  ],
  '8': [
    {'1': '_target_weight_kg'},
    {'1': '_target_reps'},
    {'1': '_target_time_seconds'},
    {'1': '_target_distance_m'},
  ],
};

/// Descriptor for `TargetSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List targetSetDescriptor = $convert.base64Decode(
    'CglUYXJnZXRTZXQSDgoCaWQYASABKAlSAmlkEiYKD3NlY3Rpb25faXRlbV9pZBgCIAEoCVINc2'
    'VjdGlvbkl0ZW1JZBIdCgpzZXRfbnVtYmVyGAMgASgFUglzZXROdW1iZXISLQoQdGFyZ2V0X3dl'
    'aWdodF9rZxgEIAEoAUgAUg50YXJnZXRXZWlnaHRLZ4gBARIkCgt0YXJnZXRfcmVwcxgFIAEoBU'
    'gBUgp0YXJnZXRSZXBziAEBEjMKE3RhcmdldF90aW1lX3NlY29uZHMYBiABKAVIAlIRdGFyZ2V0'
    'VGltZVNlY29uZHOIAQESLwoRdGFyZ2V0X2Rpc3RhbmNlX20YByABKAFIA1IPdGFyZ2V0RGlzdG'
    'FuY2VNiAEBEiMKDWlzX2JvZHl3ZWlnaHQYCCABKAhSDGlzQm9keXdlaWdodBIUCgVub3RlcxgJ'
    'IAEoCVIFbm90ZXNCEwoRX3RhcmdldF93ZWlnaHRfa2dCDgoMX3RhcmdldF9yZXBzQhYKFF90YX'
    'JnZXRfdGltZV9zZWNvbmRzQhQKEl90YXJnZXRfZGlzdGFuY2VfbQ==');

@$core.Deprecated('Use listWorkoutsRequestDescriptor instead')
const ListWorkoutsRequest$json = {
  '1': 'ListWorkoutsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'include_archived', '3': 2, '4': 1, '5': 8, '9': 0, '10': 'includeArchived', '17': true},
    {'1': 'pagination', '3': 3, '4': 1, '5': 11, '6': '.heft.v1.PaginationRequest', '10': 'pagination'},
  ],
  '8': [
    {'1': '_include_archived'},
  ],
};

/// Descriptor for `ListWorkoutsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWorkoutsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0V29ya291dHNSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIuChBpbmNsdW'
    'RlX2FyY2hpdmVkGAIgASgISABSD2luY2x1ZGVBcmNoaXZlZIgBARI6CgpwYWdpbmF0aW9uGAMg'
    'ASgLMhouaGVmdC52MS5QYWdpbmF0aW9uUmVxdWVzdFIKcGFnaW5hdGlvbkITChFfaW5jbHVkZV'
    '9hcmNoaXZlZA==');

@$core.Deprecated('Use listWorkoutsResponseDescriptor instead')
const ListWorkoutsResponse$json = {
  '1': 'ListWorkoutsResponse',
  '2': [
    {'1': 'workouts', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.WorkoutSummary', '10': 'workouts'},
    {'1': 'pagination', '3': 2, '4': 1, '5': 11, '6': '.heft.v1.PaginationResponse', '10': 'pagination'},
  ],
};

/// Descriptor for `ListWorkoutsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWorkoutsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0V29ya291dHNSZXNwb25zZRIzCgh3b3Jrb3V0cxgBIAMoCzIXLmhlZnQudjEuV29ya2'
    '91dFN1bW1hcnlSCHdvcmtvdXRzEjsKCnBhZ2luYXRpb24YAiABKAsyGy5oZWZ0LnYxLlBhZ2lu'
    'YXRpb25SZXNwb25zZVIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use getWorkoutRequestDescriptor instead')
const GetWorkoutRequest$json = {
  '1': 'GetWorkoutRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetWorkoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWorkoutRequestDescriptor = $convert.base64Decode(
    'ChFHZXRXb3Jrb3V0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCVIGdX'
    'Nlcklk');

@$core.Deprecated('Use getWorkoutResponseDescriptor instead')
const GetWorkoutResponse$json = {
  '1': 'GetWorkoutResponse',
  '2': [
    {'1': 'workout', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Workout', '10': 'workout'},
  ],
};

/// Descriptor for `GetWorkoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWorkoutResponseDescriptor = $convert.base64Decode(
    'ChJHZXRXb3Jrb3V0UmVzcG9uc2USKgoHd29ya291dBgBIAEoCzIQLmhlZnQudjEuV29ya291dF'
    'IHd29ya291dA==');

@$core.Deprecated('Use createWorkoutRequestDescriptor instead')
const CreateWorkoutRequest$json = {
  '1': 'CreateWorkoutRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'description', '17': true},
    {'1': 'sections', '3': 4, '4': 3, '5': 11, '6': '.heft.v1.CreateWorkoutSection', '10': 'sections'},
  ],
  '8': [
    {'1': '_description'},
  ],
};

/// Descriptor for `CreateWorkoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWorkoutRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVXb3Jrb3V0UmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSEgoEbmFtZR'
    'gCIAEoCVIEbmFtZRIlCgtkZXNjcmlwdGlvbhgDIAEoCUgAUgtkZXNjcmlwdGlvbogBARI5Cghz'
    'ZWN0aW9ucxgEIAMoCzIdLmhlZnQudjEuQ3JlYXRlV29ya291dFNlY3Rpb25SCHNlY3Rpb25zQg'
    '4KDF9kZXNjcmlwdGlvbg==');

@$core.Deprecated('Use createWorkoutSectionDescriptor instead')
const CreateWorkoutSection$json = {
  '1': 'CreateWorkoutSection',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'display_order', '3': 2, '4': 1, '5': 5, '10': 'displayOrder'},
    {'1': 'is_superset', '3': 3, '4': 1, '5': 8, '10': 'isSuperset'},
    {'1': 'items', '3': 4, '4': 3, '5': 11, '6': '.heft.v1.CreateSectionItem', '10': 'items'},
  ],
};

/// Descriptor for `CreateWorkoutSection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWorkoutSectionDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVXb3Jrb3V0U2VjdGlvbhISCgRuYW1lGAEgASgJUgRuYW1lEiMKDWRpc3BsYXlfb3'
    'JkZXIYAiABKAVSDGRpc3BsYXlPcmRlchIfCgtpc19zdXBlcnNldBgDIAEoCFIKaXNTdXBlcnNl'
    'dBIwCgVpdGVtcxgEIAMoCzIaLmhlZnQudjEuQ3JlYXRlU2VjdGlvbkl0ZW1SBWl0ZW1z');

@$core.Deprecated('Use createSectionItemDescriptor instead')
const CreateSectionItem$json = {
  '1': 'CreateSectionItem',
  '2': [
    {'1': 'item_type', '3': 1, '4': 1, '5': 14, '6': '.heft.v1.SectionItemType', '10': 'itemType'},
    {'1': 'display_order', '3': 2, '4': 1, '5': 5, '10': 'displayOrder'},
    {'1': 'exercise_id', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'exerciseId', '17': true},
    {'1': 'rest_duration_seconds', '3': 4, '4': 1, '5': 5, '9': 1, '10': 'restDurationSeconds', '17': true},
    {'1': 'target_sets', '3': 5, '4': 3, '5': 11, '6': '.heft.v1.CreateTargetSet', '10': 'targetSets'},
  ],
  '8': [
    {'1': '_exercise_id'},
    {'1': '_rest_duration_seconds'},
  ],
};

/// Descriptor for `CreateSectionItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSectionItemDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVTZWN0aW9uSXRlbRI1CglpdGVtX3R5cGUYASABKA4yGC5oZWZ0LnYxLlNlY3Rpb2'
    '5JdGVtVHlwZVIIaXRlbVR5cGUSIwoNZGlzcGxheV9vcmRlchgCIAEoBVIMZGlzcGxheU9yZGVy'
    'EiQKC2V4ZXJjaXNlX2lkGAMgASgJSABSCmV4ZXJjaXNlSWSIAQESNwoVcmVzdF9kdXJhdGlvbl'
    '9zZWNvbmRzGAQgASgFSAFSE3Jlc3REdXJhdGlvblNlY29uZHOIAQESOQoLdGFyZ2V0X3NldHMY'
    'BSADKAsyGC5oZWZ0LnYxLkNyZWF0ZVRhcmdldFNldFIKdGFyZ2V0U2V0c0IOCgxfZXhlcmNpc2'
    'VfaWRCGAoWX3Jlc3RfZHVyYXRpb25fc2Vjb25kcw==');

@$core.Deprecated('Use createTargetSetDescriptor instead')
const CreateTargetSet$json = {
  '1': 'CreateTargetSet',
  '2': [
    {'1': 'set_number', '3': 1, '4': 1, '5': 5, '10': 'setNumber'},
    {'1': 'target_weight_kg', '3': 2, '4': 1, '5': 1, '9': 0, '10': 'targetWeightKg', '17': true},
    {'1': 'target_reps', '3': 3, '4': 1, '5': 5, '9': 1, '10': 'targetReps', '17': true},
    {'1': 'target_time_seconds', '3': 4, '4': 1, '5': 5, '9': 2, '10': 'targetTimeSeconds', '17': true},
    {'1': 'target_distance_m', '3': 5, '4': 1, '5': 1, '9': 3, '10': 'targetDistanceM', '17': true},
    {'1': 'is_bodyweight', '3': 6, '4': 1, '5': 8, '10': 'isBodyweight'},
    {'1': 'notes', '3': 7, '4': 1, '5': 9, '9': 4, '10': 'notes', '17': true},
  ],
  '8': [
    {'1': '_target_weight_kg'},
    {'1': '_target_reps'},
    {'1': '_target_time_seconds'},
    {'1': '_target_distance_m'},
    {'1': '_notes'},
  ],
};

/// Descriptor for `CreateTargetSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTargetSetDescriptor = $convert.base64Decode(
    'Cg9DcmVhdGVUYXJnZXRTZXQSHQoKc2V0X251bWJlchgBIAEoBVIJc2V0TnVtYmVyEi0KEHRhcm'
    'dldF93ZWlnaHRfa2cYAiABKAFIAFIOdGFyZ2V0V2VpZ2h0S2eIAQESJAoLdGFyZ2V0X3JlcHMY'
    'AyABKAVIAVIKdGFyZ2V0UmVwc4gBARIzChN0YXJnZXRfdGltZV9zZWNvbmRzGAQgASgFSAJSEX'
    'RhcmdldFRpbWVTZWNvbmRziAEBEi8KEXRhcmdldF9kaXN0YW5jZV9tGAUgASgBSANSD3Rhcmdl'
    'dERpc3RhbmNlTYgBARIjCg1pc19ib2R5d2VpZ2h0GAYgASgIUgxpc0JvZHl3ZWlnaHQSGQoFbm'
    '90ZXMYByABKAlIBFIFbm90ZXOIAQFCEwoRX3RhcmdldF93ZWlnaHRfa2dCDgoMX3RhcmdldF9y'
    'ZXBzQhYKFF90YXJnZXRfdGltZV9zZWNvbmRzQhQKEl90YXJnZXRfZGlzdGFuY2VfbUIICgZfbm'
    '90ZXM=');

@$core.Deprecated('Use createWorkoutResponseDescriptor instead')
const CreateWorkoutResponse$json = {
  '1': 'CreateWorkoutResponse',
  '2': [
    {'1': 'workout', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Workout', '10': 'workout'},
  ],
};

/// Descriptor for `CreateWorkoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWorkoutResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVXb3Jrb3V0UmVzcG9uc2USKgoHd29ya291dBgBIAEoCzIQLmhlZnQudjEuV29ya2'
    '91dFIHd29ya291dA==');

@$core.Deprecated('Use updateWorkoutRequestDescriptor instead')
const UpdateWorkoutRequest$json = {
  '1': 'UpdateWorkoutRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'name', '17': true},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'description', '17': true},
    {'1': 'is_archived', '3': 5, '4': 1, '5': 8, '9': 2, '10': 'isArchived', '17': true},
    {'1': 'sections', '3': 6, '4': 3, '5': 11, '6': '.heft.v1.CreateWorkoutSection', '10': 'sections'},
  ],
  '8': [
    {'1': '_name'},
    {'1': '_description'},
    {'1': '_is_archived'},
  ],
};

/// Descriptor for `UpdateWorkoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateWorkoutRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVXb3Jrb3V0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCV'
    'IGdXNlcklkEhcKBG5hbWUYAyABKAlIAFIEbmFtZYgBARIlCgtkZXNjcmlwdGlvbhgEIAEoCUgB'
    'UgtkZXNjcmlwdGlvbogBARIkCgtpc19hcmNoaXZlZBgFIAEoCEgCUgppc0FyY2hpdmVkiAEBEj'
    'kKCHNlY3Rpb25zGAYgAygLMh0uaGVmdC52MS5DcmVhdGVXb3Jrb3V0U2VjdGlvblIIc2VjdGlv'
    'bnNCBwoFX25hbWVCDgoMX2Rlc2NyaXB0aW9uQg4KDF9pc19hcmNoaXZlZA==');

@$core.Deprecated('Use updateWorkoutResponseDescriptor instead')
const UpdateWorkoutResponse$json = {
  '1': 'UpdateWorkoutResponse',
  '2': [
    {'1': 'workout', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Workout', '10': 'workout'},
  ],
};

/// Descriptor for `UpdateWorkoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateWorkoutResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVXb3Jrb3V0UmVzcG9uc2USKgoHd29ya291dBgBIAEoCzIQLmhlZnQudjEuV29ya2'
    '91dFIHd29ya291dA==');

@$core.Deprecated('Use deleteWorkoutRequestDescriptor instead')
const DeleteWorkoutRequest$json = {
  '1': 'DeleteWorkoutRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `DeleteWorkoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteWorkoutRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVXb3Jrb3V0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCV'
    'IGdXNlcklk');

@$core.Deprecated('Use deleteWorkoutResponseDescriptor instead')
const DeleteWorkoutResponse$json = {
  '1': 'DeleteWorkoutResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `DeleteWorkoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteWorkoutResponseDescriptor = $convert.base64Decode(
    'ChVEZWxldGVXb3Jrb3V0UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use duplicateWorkoutRequestDescriptor instead')
const DuplicateWorkoutRequest$json = {
  '1': 'DuplicateWorkoutRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'new_name', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'newName', '17': true},
  ],
  '8': [
    {'1': '_new_name'},
  ],
};

/// Descriptor for `DuplicateWorkoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List duplicateWorkoutRequestDescriptor = $convert.base64Decode(
    'ChdEdXBsaWNhdGVXb3Jrb3V0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIA'
    'EoCVIGdXNlcklkEh4KCG5ld19uYW1lGAMgASgJSABSB25ld05hbWWIAQFCCwoJX25ld19uYW1l');

@$core.Deprecated('Use duplicateWorkoutResponseDescriptor instead')
const DuplicateWorkoutResponse$json = {
  '1': 'DuplicateWorkoutResponse',
  '2': [
    {'1': 'workout', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Workout', '10': 'workout'},
  ],
};

/// Descriptor for `DuplicateWorkoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List duplicateWorkoutResponseDescriptor = $convert.base64Decode(
    'ChhEdXBsaWNhdGVXb3Jrb3V0UmVzcG9uc2USKgoHd29ya291dBgBIAEoCzIQLmhlZnQudjEuV2'
    '9ya291dFIHd29ya291dA==');

const $core.Map<$core.String, $core.dynamic> WorkoutServiceBase$json = {
  '1': 'WorkoutService',
  '2': [
    {'1': 'ListWorkouts', '2': '.heft.v1.ListWorkoutsRequest', '3': '.heft.v1.ListWorkoutsResponse'},
    {'1': 'GetWorkout', '2': '.heft.v1.GetWorkoutRequest', '3': '.heft.v1.GetWorkoutResponse'},
    {'1': 'CreateWorkout', '2': '.heft.v1.CreateWorkoutRequest', '3': '.heft.v1.CreateWorkoutResponse'},
    {'1': 'UpdateWorkout', '2': '.heft.v1.UpdateWorkoutRequest', '3': '.heft.v1.UpdateWorkoutResponse'},
    {'1': 'DeleteWorkout', '2': '.heft.v1.DeleteWorkoutRequest', '3': '.heft.v1.DeleteWorkoutResponse'},
    {'1': 'DuplicateWorkout', '2': '.heft.v1.DuplicateWorkoutRequest', '3': '.heft.v1.DuplicateWorkoutResponse'},
  ],
};

@$core.Deprecated('Use workoutServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> WorkoutServiceBase$messageJson = {
  '.heft.v1.ListWorkoutsRequest': ListWorkoutsRequest$json,
  '.heft.v1.PaginationRequest': $2.PaginationRequest$json,
  '.heft.v1.ListWorkoutsResponse': ListWorkoutsResponse$json,
  '.heft.v1.WorkoutSummary': WorkoutSummary$json,
  '.google.protobuf.Timestamp': $1.Timestamp$json,
  '.heft.v1.PaginationResponse': $2.PaginationResponse$json,
  '.heft.v1.GetWorkoutRequest': GetWorkoutRequest$json,
  '.heft.v1.GetWorkoutResponse': GetWorkoutResponse$json,
  '.heft.v1.Workout': Workout$json,
  '.heft.v1.WorkoutSection': WorkoutSection$json,
  '.heft.v1.SectionItem': SectionItem$json,
  '.heft.v1.TargetSet': TargetSet$json,
  '.heft.v1.CreateWorkoutRequest': CreateWorkoutRequest$json,
  '.heft.v1.CreateWorkoutSection': CreateWorkoutSection$json,
  '.heft.v1.CreateSectionItem': CreateSectionItem$json,
  '.heft.v1.CreateTargetSet': CreateTargetSet$json,
  '.heft.v1.CreateWorkoutResponse': CreateWorkoutResponse$json,
  '.heft.v1.UpdateWorkoutRequest': UpdateWorkoutRequest$json,
  '.heft.v1.UpdateWorkoutResponse': UpdateWorkoutResponse$json,
  '.heft.v1.DeleteWorkoutRequest': DeleteWorkoutRequest$json,
  '.heft.v1.DeleteWorkoutResponse': DeleteWorkoutResponse$json,
  '.heft.v1.DuplicateWorkoutRequest': DuplicateWorkoutRequest$json,
  '.heft.v1.DuplicateWorkoutResponse': DuplicateWorkoutResponse$json,
};

/// Descriptor for `WorkoutService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List workoutServiceDescriptor = $convert.base64Decode(
    'Cg5Xb3Jrb3V0U2VydmljZRJLCgxMaXN0V29ya291dHMSHC5oZWZ0LnYxLkxpc3RXb3Jrb3V0c1'
    'JlcXVlc3QaHS5oZWZ0LnYxLkxpc3RXb3Jrb3V0c1Jlc3BvbnNlEkUKCkdldFdvcmtvdXQSGi5o'
    'ZWZ0LnYxLkdldFdvcmtvdXRSZXF1ZXN0GhsuaGVmdC52MS5HZXRXb3Jrb3V0UmVzcG9uc2USTg'
    'oNQ3JlYXRlV29ya291dBIdLmhlZnQudjEuQ3JlYXRlV29ya291dFJlcXVlc3QaHi5oZWZ0LnYx'
    'LkNyZWF0ZVdvcmtvdXRSZXNwb25zZRJOCg1VcGRhdGVXb3Jrb3V0Eh0uaGVmdC52MS5VcGRhdG'
    'VXb3Jrb3V0UmVxdWVzdBoeLmhlZnQudjEuVXBkYXRlV29ya291dFJlc3BvbnNlEk4KDURlbGV0'
    'ZVdvcmtvdXQSHS5oZWZ0LnYxLkRlbGV0ZVdvcmtvdXRSZXF1ZXN0Gh4uaGVmdC52MS5EZWxldG'
    'VXb3Jrb3V0UmVzcG9uc2USVwoQRHVwbGljYXRlV29ya291dBIgLmhlZnQudjEuRHVwbGljYXRl'
    'V29ya291dFJlcXVlc3QaIS5oZWZ0LnYxLkR1cGxpY2F0ZVdvcmtvdXRSZXNwb25zZQ==');

