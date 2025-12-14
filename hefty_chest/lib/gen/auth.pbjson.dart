//
//  Generated code. Do not modify.
//  source: auth.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSFAoFZW1haWwYASABKAlSBWVtYWls');

@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = {
  '1': 'LoginResponse',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'is_new_user', '3': 3, '4': 1, '5': 8, '10': 'isNewUser'},
    {'1': 'expires_at', '3': 4, '4': 1, '5': 3, '10': 'expiresAt'},
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode(
    'Cg1Mb2dpblJlc3BvbnNlEhQKBXRva2VuGAEgASgJUgV0b2tlbhIXCgd1c2VyX2lkGAIgASgJUg'
    'Z1c2VySWQSHgoLaXNfbmV3X3VzZXIYAyABKAhSCWlzTmV3VXNlchIdCgpleHBpcmVzX2F0GAQg'
    'ASgDUglleHBpcmVzQXQ=');

const $core.Map<$core.String, $core.dynamic> AuthServiceBase$json = {
  '1': 'AuthService',
  '2': [
    {'1': 'Login', '2': '.heft.v1.LoginRequest', '3': '.heft.v1.LoginResponse'},
  ],
};

@$core.Deprecated('Use authServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> AuthServiceBase$messageJson = {
  '.heft.v1.LoginRequest': LoginRequest$json,
  '.heft.v1.LoginResponse': LoginResponse$json,
};

/// Descriptor for `AuthService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List authServiceDescriptor = $convert.base64Decode(
    'CgtBdXRoU2VydmljZRI2CgVMb2dpbhIVLmhlZnQudjEuTG9naW5SZXF1ZXN0GhYuaGVmdC52MS'
    '5Mb2dpblJlc3BvbnNl');

