//
//  Generated code. Do not modify.
//  source: user.proto
//

import "package:connectrpc/connect.dart" as connect;
import "user.pb.dart" as user;

/// UserService handles user profiles, settings, and weight tracking
abstract final class UserService {
  /// Fully-qualified name of the UserService service.
  static const name = 'heft.v1.UserService';

  /// Get user profile
  static const getProfile = connect.Spec(
    '/$name/GetProfile',
    connect.StreamType.unary,
    user.GetProfileRequest.new,
    user.GetProfileResponse.new,
  );

  /// Update user profile
  static const updateProfile = connect.Spec(
    '/$name/UpdateProfile',
    connect.StreamType.unary,
    user.UpdateProfileRequest.new,
    user.UpdateProfileResponse.new,
  );

  /// Update user settings
  static const updateSettings = connect.Spec(
    '/$name/UpdateSettings',
    connect.StreamType.unary,
    user.UpdateSettingsRequest.new,
    user.UpdateSettingsResponse.new,
  );

  /// Log body weight
  static const logWeight = connect.Spec(
    '/$name/LogWeight',
    connect.StreamType.unary,
    user.LogWeightRequest.new,
    user.LogWeightResponse.new,
  );

  /// Get weight history
  static const getWeightHistory = connect.Spec(
    '/$name/GetWeightHistory',
    connect.StreamType.unary,
    user.GetWeightHistoryRequest.new,
    user.GetWeightHistoryResponse.new,
  );

  /// Delete a weight log entry
  static const deleteWeightLog = connect.Spec(
    '/$name/DeleteWeightLog',
    connect.StreamType.unary,
    user.DeleteWeightLogRequest.new,
    user.DeleteWeightLogResponse.new,
  );
}
