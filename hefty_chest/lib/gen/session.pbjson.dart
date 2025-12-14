//
//  Generated code. Do not modify.
//  source: session.proto
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

@$core.Deprecated('Use sessionDescriptor instead')
const Session$json = {
  '1': 'Session',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'workout_template_id', '3': 3, '4': 1, '5': 9, '10': 'workoutTemplateId'},
    {'1': 'program_id', '3': 4, '4': 1, '5': 9, '10': 'programId'},
    {'1': 'program_day_number', '3': 5, '4': 1, '5': 5, '10': 'programDayNumber'},
    {'1': 'name', '3': 6, '4': 1, '5': 9, '10': 'name'},
    {'1': 'status', '3': 7, '4': 1, '5': 14, '6': '.heft.v1.WorkoutStatus', '10': 'status'},
    {'1': 'started_at', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'startedAt'},
    {'1': 'completed_at', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'completedAt'},
    {'1': 'duration_seconds', '3': 10, '4': 1, '5': 5, '10': 'durationSeconds'},
    {'1': 'total_sets', '3': 11, '4': 1, '5': 5, '10': 'totalSets'},
    {'1': 'completed_sets', '3': 12, '4': 1, '5': 5, '10': 'completedSets'},
    {'1': 'notes', '3': 13, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'exercises', '3': 14, '4': 3, '5': 11, '6': '.heft.v1.SessionExercise', '10': 'exercises'},
    {'1': 'created_at', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 16, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
  ],
};

/// Descriptor for `Session`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionDescriptor = $convert.base64Decode(
    'CgdTZXNzaW9uEg4KAmlkGAEgASgJUgJpZBIXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSLgoTd2'
    '9ya291dF90ZW1wbGF0ZV9pZBgDIAEoCVIRd29ya291dFRlbXBsYXRlSWQSHQoKcHJvZ3JhbV9p'
    'ZBgEIAEoCVIJcHJvZ3JhbUlkEiwKEnByb2dyYW1fZGF5X251bWJlchgFIAEoBVIQcHJvZ3JhbU'
    'RheU51bWJlchISCgRuYW1lGAYgASgJUgRuYW1lEi4KBnN0YXR1cxgHIAEoDjIWLmhlZnQudjEu'
    'V29ya291dFN0YXR1c1IGc3RhdHVzEjkKCnN0YXJ0ZWRfYXQYCCABKAsyGi5nb29nbGUucHJvdG'
    '9idWYuVGltZXN0YW1wUglzdGFydGVkQXQSPQoMY29tcGxldGVkX2F0GAkgASgLMhouZ29vZ2xl'
    'LnByb3RvYnVmLlRpbWVzdGFtcFILY29tcGxldGVkQXQSKQoQZHVyYXRpb25fc2Vjb25kcxgKIA'
    'EoBVIPZHVyYXRpb25TZWNvbmRzEh0KCnRvdGFsX3NldHMYCyABKAVSCXRvdGFsU2V0cxIlCg5j'
    'b21wbGV0ZWRfc2V0cxgMIAEoBVINY29tcGxldGVkU2V0cxIUCgVub3RlcxgNIAEoCVIFbm90ZX'
    'MSNgoJZXhlcmNpc2VzGA4gAygLMhguaGVmdC52MS5TZXNzaW9uRXhlcmNpc2VSCWV4ZXJjaXNl'
    'cxI5CgpjcmVhdGVkX2F0GA8gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYX'
    'RlZEF0EjkKCnVwZGF0ZWRfYXQYECABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1'
    'cGRhdGVkQXQ=');

@$core.Deprecated('Use sessionExerciseDescriptor instead')
const SessionExercise$json = {
  '1': 'SessionExercise',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'session_id', '3': 2, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'exercise_id', '3': 3, '4': 1, '5': 9, '10': 'exerciseId'},
    {'1': 'exercise_name', '3': 4, '4': 1, '5': 9, '10': 'exerciseName'},
    {'1': 'exercise_type', '3': 5, '4': 1, '5': 14, '6': '.heft.v1.ExerciseType', '10': 'exerciseType'},
    {'1': 'display_order', '3': 6, '4': 1, '5': 5, '10': 'displayOrder'},
    {'1': 'section_name', '3': 7, '4': 1, '5': 9, '10': 'sectionName'},
    {'1': 'notes', '3': 8, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'sets', '3': 9, '4': 3, '5': 11, '6': '.heft.v1.SessionSet', '10': 'sets'},
  ],
};

/// Descriptor for `SessionExercise`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionExerciseDescriptor = $convert.base64Decode(
    'Cg9TZXNzaW9uRXhlcmNpc2USDgoCaWQYASABKAlSAmlkEh0KCnNlc3Npb25faWQYAiABKAlSCX'
    'Nlc3Npb25JZBIfCgtleGVyY2lzZV9pZBgDIAEoCVIKZXhlcmNpc2VJZBIjCg1leGVyY2lzZV9u'
    'YW1lGAQgASgJUgxleGVyY2lzZU5hbWUSOgoNZXhlcmNpc2VfdHlwZRgFIAEoDjIVLmhlZnQudj'
    'EuRXhlcmNpc2VUeXBlUgxleGVyY2lzZVR5cGUSIwoNZGlzcGxheV9vcmRlchgGIAEoBVIMZGlz'
    'cGxheU9yZGVyEiEKDHNlY3Rpb25fbmFtZRgHIAEoCVILc2VjdGlvbk5hbWUSFAoFbm90ZXMYCC'
    'ABKAlSBW5vdGVzEicKBHNldHMYCSADKAsyEy5oZWZ0LnYxLlNlc3Npb25TZXRSBHNldHM=');

@$core.Deprecated('Use sessionSetDescriptor instead')
const SessionSet$json = {
  '1': 'SessionSet',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'session_exercise_id', '3': 2, '4': 1, '5': 9, '10': 'sessionExerciseId'},
    {'1': 'set_number', '3': 3, '4': 1, '5': 5, '10': 'setNumber'},
    {'1': 'weight_kg', '3': 4, '4': 1, '5': 1, '9': 0, '10': 'weightKg', '17': true},
    {'1': 'reps', '3': 5, '4': 1, '5': 5, '9': 1, '10': 'reps', '17': true},
    {'1': 'time_seconds', '3': 6, '4': 1, '5': 5, '9': 2, '10': 'timeSeconds', '17': true},
    {'1': 'distance_m', '3': 7, '4': 1, '5': 1, '9': 3, '10': 'distanceM', '17': true},
    {'1': 'is_bodyweight', '3': 8, '4': 1, '5': 8, '10': 'isBodyweight'},
    {'1': 'is_completed', '3': 9, '4': 1, '5': 8, '10': 'isCompleted'},
    {'1': 'completed_at', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'completedAt'},
    {'1': 'target_weight_kg', '3': 11, '4': 1, '5': 1, '9': 4, '10': 'targetWeightKg', '17': true},
    {'1': 'target_reps', '3': 12, '4': 1, '5': 5, '9': 5, '10': 'targetReps', '17': true},
    {'1': 'target_time_seconds', '3': 13, '4': 1, '5': 5, '9': 6, '10': 'targetTimeSeconds', '17': true},
    {'1': 'rpe', '3': 14, '4': 1, '5': 1, '9': 7, '10': 'rpe', '17': true},
    {'1': 'notes', '3': 15, '4': 1, '5': 9, '10': 'notes'},
  ],
  '8': [
    {'1': '_weight_kg'},
    {'1': '_reps'},
    {'1': '_time_seconds'},
    {'1': '_distance_m'},
    {'1': '_target_weight_kg'},
    {'1': '_target_reps'},
    {'1': '_target_time_seconds'},
    {'1': '_rpe'},
  ],
};

/// Descriptor for `SessionSet`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionSetDescriptor = $convert.base64Decode(
    'CgpTZXNzaW9uU2V0Eg4KAmlkGAEgASgJUgJpZBIuChNzZXNzaW9uX2V4ZXJjaXNlX2lkGAIgAS'
    'gJUhFzZXNzaW9uRXhlcmNpc2VJZBIdCgpzZXRfbnVtYmVyGAMgASgFUglzZXROdW1iZXISIAoJ'
    'd2VpZ2h0X2tnGAQgASgBSABSCHdlaWdodEtniAEBEhcKBHJlcHMYBSABKAVIAVIEcmVwc4gBAR'
    'ImCgx0aW1lX3NlY29uZHMYBiABKAVIAlILdGltZVNlY29uZHOIAQESIgoKZGlzdGFuY2VfbRgH'
    'IAEoAUgDUglkaXN0YW5jZU2IAQESIwoNaXNfYm9keXdlaWdodBgIIAEoCFIMaXNCb2R5d2VpZ2'
    'h0EiEKDGlzX2NvbXBsZXRlZBgJIAEoCFILaXNDb21wbGV0ZWQSPQoMY29tcGxldGVkX2F0GAog'
    'ASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILY29tcGxldGVkQXQSLQoQdGFyZ2V0X3'
    'dlaWdodF9rZxgLIAEoAUgEUg50YXJnZXRXZWlnaHRLZ4gBARIkCgt0YXJnZXRfcmVwcxgMIAEo'
    'BUgFUgp0YXJnZXRSZXBziAEBEjMKE3RhcmdldF90aW1lX3NlY29uZHMYDSABKAVIBlIRdGFyZ2'
    'V0VGltZVNlY29uZHOIAQESFQoDcnBlGA4gASgBSAdSA3JwZYgBARIUCgVub3RlcxgPIAEoCVIF'
    'bm90ZXNCDAoKX3dlaWdodF9rZ0IHCgVfcmVwc0IPCg1fdGltZV9zZWNvbmRzQg0KC19kaXN0YW'
    '5jZV9tQhMKEV90YXJnZXRfd2VpZ2h0X2tnQg4KDF90YXJnZXRfcmVwc0IWChRfdGFyZ2V0X3Rp'
    'bWVfc2Vjb25kc0IGCgRfcnBl');

@$core.Deprecated('Use sessionSummaryDescriptor instead')
const SessionSummary$json = {
  '1': 'SessionSummary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'status', '3': 4, '4': 1, '5': 14, '6': '.heft.v1.WorkoutStatus', '10': 'status'},
    {'1': 'started_at', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'startedAt'},
    {'1': 'completed_at', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'completedAt'},
    {'1': 'duration_seconds', '3': 7, '4': 1, '5': 5, '10': 'durationSeconds'},
    {'1': 'total_sets', '3': 8, '4': 1, '5': 5, '10': 'totalSets'},
    {'1': 'completed_sets', '3': 9, '4': 1, '5': 5, '10': 'completedSets'},
    {'1': 'template_name', '3': 10, '4': 1, '5': 9, '10': 'templateName'},
  ],
};

/// Descriptor for `SessionSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionSummaryDescriptor = $convert.base64Decode(
    'Cg5TZXNzaW9uU3VtbWFyeRIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCVIGdXNlck'
    'lkEhIKBG5hbWUYAyABKAlSBG5hbWUSLgoGc3RhdHVzGAQgASgOMhYuaGVmdC52MS5Xb3Jrb3V0'
    'U3RhdHVzUgZzdGF0dXMSOQoKc3RhcnRlZF9hdBgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW'
    '1lc3RhbXBSCXN0YXJ0ZWRBdBI9Cgxjb21wbGV0ZWRfYXQYBiABKAsyGi5nb29nbGUucHJvdG9i'
    'dWYuVGltZXN0YW1wUgtjb21wbGV0ZWRBdBIpChBkdXJhdGlvbl9zZWNvbmRzGAcgASgFUg9kdX'
    'JhdGlvblNlY29uZHMSHQoKdG90YWxfc2V0cxgIIAEoBVIJdG90YWxTZXRzEiUKDmNvbXBsZXRl'
    'ZF9zZXRzGAkgASgFUg1jb21wbGV0ZWRTZXRzEiMKDXRlbXBsYXRlX25hbWUYCiABKAlSDHRlbX'
    'BsYXRlTmFtZQ==');

@$core.Deprecated('Use startSessionRequestDescriptor instead')
const StartSessionRequest$json = {
  '1': 'StartSessionRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'workout_template_id', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'workoutTemplateId', '17': true},
    {'1': 'program_id', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'programId', '17': true},
    {'1': 'program_day_number', '3': 4, '4': 1, '5': 5, '9': 2, '10': 'programDayNumber', '17': true},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '9': 3, '10': 'name', '17': true},
  ],
  '8': [
    {'1': '_workout_template_id'},
    {'1': '_program_id'},
    {'1': '_program_day_number'},
    {'1': '_name'},
  ],
};

/// Descriptor for `StartSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startSessionRequestDescriptor = $convert.base64Decode(
    'ChNTdGFydFNlc3Npb25SZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIzChN3b3Jrb3'
    'V0X3RlbXBsYXRlX2lkGAIgASgJSABSEXdvcmtvdXRUZW1wbGF0ZUlkiAEBEiIKCnByb2dyYW1f'
    'aWQYAyABKAlIAVIJcHJvZ3JhbUlkiAEBEjEKEnByb2dyYW1fZGF5X251bWJlchgEIAEoBUgCUh'
    'Bwcm9ncmFtRGF5TnVtYmVyiAEBEhcKBG5hbWUYBSABKAlIA1IEbmFtZYgBAUIWChRfd29ya291'
    'dF90ZW1wbGF0ZV9pZEINCgtfcHJvZ3JhbV9pZEIVChNfcHJvZ3JhbV9kYXlfbnVtYmVyQgcKBV'
    '9uYW1l');

@$core.Deprecated('Use startSessionResponseDescriptor instead')
const StartSessionResponse$json = {
  '1': 'StartSessionResponse',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Session', '10': 'session'},
  ],
};

/// Descriptor for `StartSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startSessionResponseDescriptor = $convert.base64Decode(
    'ChRTdGFydFNlc3Npb25SZXNwb25zZRIqCgdzZXNzaW9uGAEgASgLMhAuaGVmdC52MS5TZXNzaW'
    '9uUgdzZXNzaW9u');

@$core.Deprecated('Use getSessionRequestDescriptor instead')
const GetSessionRequest$json = {
  '1': 'GetSessionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionRequestDescriptor = $convert.base64Decode(
    'ChFHZXRTZXNzaW9uUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCVIGdX'
    'Nlcklk');

@$core.Deprecated('Use getSessionResponseDescriptor instead')
const GetSessionResponse$json = {
  '1': 'GetSessionResponse',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Session', '10': 'session'},
  ],
};

/// Descriptor for `GetSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSessionResponseDescriptor = $convert.base64Decode(
    'ChJHZXRTZXNzaW9uUmVzcG9uc2USKgoHc2Vzc2lvbhgBIAEoCzIQLmhlZnQudjEuU2Vzc2lvbl'
    'IHc2Vzc2lvbg==');

@$core.Deprecated('Use completeSetRequestDescriptor instead')
const CompleteSetRequest$json = {
  '1': 'CompleteSetRequest',
  '2': [
    {'1': 'session_set_id', '3': 1, '4': 1, '5': 9, '10': 'sessionSetId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'weight_kg', '3': 3, '4': 1, '5': 1, '9': 0, '10': 'weightKg', '17': true},
    {'1': 'reps', '3': 4, '4': 1, '5': 5, '9': 1, '10': 'reps', '17': true},
    {'1': 'time_seconds', '3': 5, '4': 1, '5': 5, '9': 2, '10': 'timeSeconds', '17': true},
    {'1': 'distance_m', '3': 6, '4': 1, '5': 1, '9': 3, '10': 'distanceM', '17': true},
    {'1': 'rpe', '3': 7, '4': 1, '5': 1, '9': 4, '10': 'rpe', '17': true},
    {'1': 'notes', '3': 8, '4': 1, '5': 9, '9': 5, '10': 'notes', '17': true},
  ],
  '8': [
    {'1': '_weight_kg'},
    {'1': '_reps'},
    {'1': '_time_seconds'},
    {'1': '_distance_m'},
    {'1': '_rpe'},
    {'1': '_notes'},
  ],
};

/// Descriptor for `CompleteSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List completeSetRequestDescriptor = $convert.base64Decode(
    'ChJDb21wbGV0ZVNldFJlcXVlc3QSJAoOc2Vzc2lvbl9zZXRfaWQYASABKAlSDHNlc3Npb25TZX'
    'RJZBIXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSIAoJd2VpZ2h0X2tnGAMgASgBSABSCHdlaWdo'
    'dEtniAEBEhcKBHJlcHMYBCABKAVIAVIEcmVwc4gBARImCgx0aW1lX3NlY29uZHMYBSABKAVIAl'
    'ILdGltZVNlY29uZHOIAQESIgoKZGlzdGFuY2VfbRgGIAEoAUgDUglkaXN0YW5jZU2IAQESFQoD'
    'cnBlGAcgASgBSARSA3JwZYgBARIZCgVub3RlcxgIIAEoCUgFUgVub3Rlc4gBAUIMCgpfd2VpZ2'
    'h0X2tnQgcKBV9yZXBzQg8KDV90aW1lX3NlY29uZHNCDQoLX2Rpc3RhbmNlX21CBgoEX3JwZUII'
    'CgZfbm90ZXM=');

@$core.Deprecated('Use completeSetResponseDescriptor instead')
const CompleteSetResponse$json = {
  '1': 'CompleteSetResponse',
  '2': [
    {'1': 'set', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.SessionSet', '10': 'set'},
    {'1': 'is_personal_record', '3': 2, '4': 1, '5': 8, '10': 'isPersonalRecord'},
  ],
};

/// Descriptor for `CompleteSetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List completeSetResponseDescriptor = $convert.base64Decode(
    'ChNDb21wbGV0ZVNldFJlc3BvbnNlEiUKA3NldBgBIAEoCzITLmhlZnQudjEuU2Vzc2lvblNldF'
    'IDc2V0EiwKEmlzX3BlcnNvbmFsX3JlY29yZBgCIAEoCFIQaXNQZXJzb25hbFJlY29yZA==');

@$core.Deprecated('Use updateSetRequestDescriptor instead')
const UpdateSetRequest$json = {
  '1': 'UpdateSetRequest',
  '2': [
    {'1': 'session_set_id', '3': 1, '4': 1, '5': 9, '10': 'sessionSetId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'weight_kg', '3': 3, '4': 1, '5': 1, '9': 0, '10': 'weightKg', '17': true},
    {'1': 'reps', '3': 4, '4': 1, '5': 5, '9': 1, '10': 'reps', '17': true},
    {'1': 'time_seconds', '3': 5, '4': 1, '5': 5, '9': 2, '10': 'timeSeconds', '17': true},
    {'1': 'distance_m', '3': 6, '4': 1, '5': 1, '9': 3, '10': 'distanceM', '17': true},
    {'1': 'is_completed', '3': 7, '4': 1, '5': 8, '9': 4, '10': 'isCompleted', '17': true},
    {'1': 'rpe', '3': 8, '4': 1, '5': 1, '9': 5, '10': 'rpe', '17': true},
    {'1': 'notes', '3': 9, '4': 1, '5': 9, '9': 6, '10': 'notes', '17': true},
  ],
  '8': [
    {'1': '_weight_kg'},
    {'1': '_reps'},
    {'1': '_time_seconds'},
    {'1': '_distance_m'},
    {'1': '_is_completed'},
    {'1': '_rpe'},
    {'1': '_notes'},
  ],
};

/// Descriptor for `UpdateSetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSetRequestDescriptor = $convert.base64Decode(
    'ChBVcGRhdGVTZXRSZXF1ZXN0EiQKDnNlc3Npb25fc2V0X2lkGAEgASgJUgxzZXNzaW9uU2V0SW'
    'QSFwoHdXNlcl9pZBgCIAEoCVIGdXNlcklkEiAKCXdlaWdodF9rZxgDIAEoAUgAUgh3ZWlnaHRL'
    'Z4gBARIXCgRyZXBzGAQgASgFSAFSBHJlcHOIAQESJgoMdGltZV9zZWNvbmRzGAUgASgFSAJSC3'
    'RpbWVTZWNvbmRziAEBEiIKCmRpc3RhbmNlX20YBiABKAFIA1IJZGlzdGFuY2VNiAEBEiYKDGlz'
    'X2NvbXBsZXRlZBgHIAEoCEgEUgtpc0NvbXBsZXRlZIgBARIVCgNycGUYCCABKAFIBVIDcnBliA'
    'EBEhkKBW5vdGVzGAkgASgJSAZSBW5vdGVziAEBQgwKCl93ZWlnaHRfa2dCBwoFX3JlcHNCDwoN'
    'X3RpbWVfc2Vjb25kc0INCgtfZGlzdGFuY2VfbUIPCg1faXNfY29tcGxldGVkQgYKBF9ycGVCCA'
    'oGX25vdGVz');

@$core.Deprecated('Use updateSetResponseDescriptor instead')
const UpdateSetResponse$json = {
  '1': 'UpdateSetResponse',
  '2': [
    {'1': 'set', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.SessionSet', '10': 'set'},
  ],
};

/// Descriptor for `UpdateSetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSetResponseDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVTZXRSZXNwb25zZRIlCgNzZXQYASABKAsyEy5oZWZ0LnYxLlNlc3Npb25TZXRSA3'
    'NldA==');

@$core.Deprecated('Use addExerciseRequestDescriptor instead')
const AddExerciseRequest$json = {
  '1': 'AddExerciseRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'exercise_id', '3': 3, '4': 1, '5': 9, '10': 'exerciseId'},
    {'1': 'display_order', '3': 4, '4': 1, '5': 5, '10': 'displayOrder'},
    {'1': 'section_name', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'sectionName', '17': true},
    {'1': 'num_sets', '3': 6, '4': 1, '5': 5, '10': 'numSets'},
  ],
  '8': [
    {'1': '_section_name'},
  ],
};

/// Descriptor for `AddExerciseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addExerciseRequestDescriptor = $convert.base64Decode(
    'ChJBZGRFeGVyY2lzZVJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEhcKB3'
    'VzZXJfaWQYAiABKAlSBnVzZXJJZBIfCgtleGVyY2lzZV9pZBgDIAEoCVIKZXhlcmNpc2VJZBIj'
    'Cg1kaXNwbGF5X29yZGVyGAQgASgFUgxkaXNwbGF5T3JkZXISJgoMc2VjdGlvbl9uYW1lGAUgAS'
    'gJSABSC3NlY3Rpb25OYW1liAEBEhkKCG51bV9zZXRzGAYgASgFUgdudW1TZXRzQg8KDV9zZWN0'
    'aW9uX25hbWU=');

@$core.Deprecated('Use addExerciseResponseDescriptor instead')
const AddExerciseResponse$json = {
  '1': 'AddExerciseResponse',
  '2': [
    {'1': 'exercise', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.SessionExercise', '10': 'exercise'},
  ],
};

/// Descriptor for `AddExerciseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addExerciseResponseDescriptor = $convert.base64Decode(
    'ChNBZGRFeGVyY2lzZVJlc3BvbnNlEjQKCGV4ZXJjaXNlGAEgASgLMhguaGVmdC52MS5TZXNzaW'
    '9uRXhlcmNpc2VSCGV4ZXJjaXNl');

@$core.Deprecated('Use finishSessionRequestDescriptor instead')
const FinishSessionRequest$json = {
  '1': 'FinishSessionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'notes', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'notes', '17': true},
  ],
  '8': [
    {'1': '_notes'},
  ],
};

/// Descriptor for `FinishSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List finishSessionRequestDescriptor = $convert.base64Decode(
    'ChRGaW5pc2hTZXNzaW9uUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFwoHdXNlcl9pZBgCIAEoCV'
    'IGdXNlcklkEhkKBW5vdGVzGAMgASgJSABSBW5vdGVziAEBQggKBl9ub3Rlcw==');

@$core.Deprecated('Use finishSessionResponseDescriptor instead')
const FinishSessionResponse$json = {
  '1': 'FinishSessionResponse',
  '2': [
    {'1': 'session', '3': 1, '4': 1, '5': 11, '6': '.heft.v1.Session', '10': 'session'},
  ],
};

/// Descriptor for `FinishSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List finishSessionResponseDescriptor = $convert.base64Decode(
    'ChVGaW5pc2hTZXNzaW9uUmVzcG9uc2USKgoHc2Vzc2lvbhgBIAEoCzIQLmhlZnQudjEuU2Vzc2'
    'lvblIHc2Vzc2lvbg==');

@$core.Deprecated('Use abandonSessionRequestDescriptor instead')
const AbandonSessionRequest$json = {
  '1': 'AbandonSessionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `AbandonSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List abandonSessionRequestDescriptor = $convert.base64Decode(
    'ChVBYmFuZG9uU2Vzc2lvblJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhcKB3VzZXJfaWQYAiABKA'
    'lSBnVzZXJJZA==');

@$core.Deprecated('Use abandonSessionResponseDescriptor instead')
const AbandonSessionResponse$json = {
  '1': 'AbandonSessionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `AbandonSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List abandonSessionResponseDescriptor = $convert.base64Decode(
    'ChZBYmFuZG9uU2Vzc2lvblJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3M=');

@$core.Deprecated('Use listSessionsRequestDescriptor instead')
const ListSessionsRequest$json = {
  '1': 'ListSessionsRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'status', '3': 2, '4': 1, '5': 14, '6': '.heft.v1.WorkoutStatus', '9': 0, '10': 'status', '17': true},
    {'1': 'start_date', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'startDate', '17': true},
    {'1': 'end_date', '3': 4, '4': 1, '5': 9, '9': 2, '10': 'endDate', '17': true},
    {'1': 'pagination', '3': 5, '4': 1, '5': 11, '6': '.heft.v1.PaginationRequest', '10': 'pagination'},
  ],
  '8': [
    {'1': '_status'},
    {'1': '_start_date'},
    {'1': '_end_date'},
  ],
};

/// Descriptor for `ListSessionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSessionsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0U2Vzc2lvbnNSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIzCgZzdGF0dX'
    'MYAiABKA4yFi5oZWZ0LnYxLldvcmtvdXRTdGF0dXNIAFIGc3RhdHVziAEBEiIKCnN0YXJ0X2Rh'
    'dGUYAyABKAlIAVIJc3RhcnREYXRliAEBEh4KCGVuZF9kYXRlGAQgASgJSAJSB2VuZERhdGWIAQ'
    'ESOgoKcGFnaW5hdGlvbhgFIAEoCzIaLmhlZnQudjEuUGFnaW5hdGlvblJlcXVlc3RSCnBhZ2lu'
    'YXRpb25CCQoHX3N0YXR1c0INCgtfc3RhcnRfZGF0ZUILCglfZW5kX2RhdGU=');

@$core.Deprecated('Use listSessionsResponseDescriptor instead')
const ListSessionsResponse$json = {
  '1': 'ListSessionsResponse',
  '2': [
    {'1': 'sessions', '3': 1, '4': 3, '5': 11, '6': '.heft.v1.SessionSummary', '10': 'sessions'},
    {'1': 'pagination', '3': 2, '4': 1, '5': 11, '6': '.heft.v1.PaginationResponse', '10': 'pagination'},
  ],
};

/// Descriptor for `ListSessionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSessionsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0U2Vzc2lvbnNSZXNwb25zZRIzCghzZXNzaW9ucxgBIAMoCzIXLmhlZnQudjEuU2Vzc2'
    'lvblN1bW1hcnlSCHNlc3Npb25zEjsKCnBhZ2luYXRpb24YAiABKAsyGy5oZWZ0LnYxLlBhZ2lu'
    'YXRpb25SZXNwb25zZVIKcGFnaW5hdGlvbg==');

const $core.Map<$core.String, $core.dynamic> SessionServiceBase$json = {
  '1': 'SessionService',
  '2': [
    {'1': 'StartSession', '2': '.heft.v1.StartSessionRequest', '3': '.heft.v1.StartSessionResponse'},
    {'1': 'GetSession', '2': '.heft.v1.GetSessionRequest', '3': '.heft.v1.GetSessionResponse'},
    {'1': 'CompleteSet', '2': '.heft.v1.CompleteSetRequest', '3': '.heft.v1.CompleteSetResponse'},
    {'1': 'UpdateSet', '2': '.heft.v1.UpdateSetRequest', '3': '.heft.v1.UpdateSetResponse'},
    {'1': 'AddExercise', '2': '.heft.v1.AddExerciseRequest', '3': '.heft.v1.AddExerciseResponse'},
    {'1': 'FinishSession', '2': '.heft.v1.FinishSessionRequest', '3': '.heft.v1.FinishSessionResponse'},
    {'1': 'AbandonSession', '2': '.heft.v1.AbandonSessionRequest', '3': '.heft.v1.AbandonSessionResponse'},
    {'1': 'ListSessions', '2': '.heft.v1.ListSessionsRequest', '3': '.heft.v1.ListSessionsResponse'},
  ],
};

@$core.Deprecated('Use sessionServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> SessionServiceBase$messageJson = {
  '.heft.v1.StartSessionRequest': StartSessionRequest$json,
  '.heft.v1.StartSessionResponse': StartSessionResponse$json,
  '.heft.v1.Session': Session$json,
  '.google.protobuf.Timestamp': $1.Timestamp$json,
  '.heft.v1.SessionExercise': SessionExercise$json,
  '.heft.v1.SessionSet': SessionSet$json,
  '.heft.v1.GetSessionRequest': GetSessionRequest$json,
  '.heft.v1.GetSessionResponse': GetSessionResponse$json,
  '.heft.v1.CompleteSetRequest': CompleteSetRequest$json,
  '.heft.v1.CompleteSetResponse': CompleteSetResponse$json,
  '.heft.v1.UpdateSetRequest': UpdateSetRequest$json,
  '.heft.v1.UpdateSetResponse': UpdateSetResponse$json,
  '.heft.v1.AddExerciseRequest': AddExerciseRequest$json,
  '.heft.v1.AddExerciseResponse': AddExerciseResponse$json,
  '.heft.v1.FinishSessionRequest': FinishSessionRequest$json,
  '.heft.v1.FinishSessionResponse': FinishSessionResponse$json,
  '.heft.v1.AbandonSessionRequest': AbandonSessionRequest$json,
  '.heft.v1.AbandonSessionResponse': AbandonSessionResponse$json,
  '.heft.v1.ListSessionsRequest': ListSessionsRequest$json,
  '.heft.v1.PaginationRequest': $2.PaginationRequest$json,
  '.heft.v1.ListSessionsResponse': ListSessionsResponse$json,
  '.heft.v1.SessionSummary': SessionSummary$json,
  '.heft.v1.PaginationResponse': $2.PaginationResponse$json,
};

/// Descriptor for `SessionService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List sessionServiceDescriptor = $convert.base64Decode(
    'Cg5TZXNzaW9uU2VydmljZRJLCgxTdGFydFNlc3Npb24SHC5oZWZ0LnYxLlN0YXJ0U2Vzc2lvbl'
    'JlcXVlc3QaHS5oZWZ0LnYxLlN0YXJ0U2Vzc2lvblJlc3BvbnNlEkUKCkdldFNlc3Npb24SGi5o'
    'ZWZ0LnYxLkdldFNlc3Npb25SZXF1ZXN0GhsuaGVmdC52MS5HZXRTZXNzaW9uUmVzcG9uc2USSA'
    'oLQ29tcGxldGVTZXQSGy5oZWZ0LnYxLkNvbXBsZXRlU2V0UmVxdWVzdBocLmhlZnQudjEuQ29t'
    'cGxldGVTZXRSZXNwb25zZRJCCglVcGRhdGVTZXQSGS5oZWZ0LnYxLlVwZGF0ZVNldFJlcXVlc3'
    'QaGi5oZWZ0LnYxLlVwZGF0ZVNldFJlc3BvbnNlEkgKC0FkZEV4ZXJjaXNlEhsuaGVmdC52MS5B'
    'ZGRFeGVyY2lzZVJlcXVlc3QaHC5oZWZ0LnYxLkFkZEV4ZXJjaXNlUmVzcG9uc2USTgoNRmluaX'
    'NoU2Vzc2lvbhIdLmhlZnQudjEuRmluaXNoU2Vzc2lvblJlcXVlc3QaHi5oZWZ0LnYxLkZpbmlz'
    'aFNlc3Npb25SZXNwb25zZRJRCg5BYmFuZG9uU2Vzc2lvbhIeLmhlZnQudjEuQWJhbmRvblNlc3'
    'Npb25SZXF1ZXN0Gh8uaGVmdC52MS5BYmFuZG9uU2Vzc2lvblJlc3BvbnNlEksKDExpc3RTZXNz'
    'aW9ucxIcLmhlZnQudjEuTGlzdFNlc3Npb25zUmVxdWVzdBodLmhlZnQudjEuTGlzdFNlc3Npb2'
    '5zUmVzcG9uc2U=');

