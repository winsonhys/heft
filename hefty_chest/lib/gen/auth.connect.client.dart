//
//  Generated code. Do not modify.
//  source: auth.proto
//

import "package:connectrpc/connect.dart" as connect;
import "auth.pb.dart" as auth;
import "auth.connect.spec.dart" as specs;

/// AuthService handles authentication
extension type AuthServiceClient (connect.Transport _transport) {
  /// Login authenticates a user by email, creating a new account if needed
  Future<auth.LoginResponse> login(
    auth.LoginRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.login,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
