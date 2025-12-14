//
//  Generated code. Do not modify.
//  source: auth.proto
//

import "package:connectrpc/connect.dart" as connect;
import "auth.pb.dart" as auth;

/// AuthService handles authentication
abstract final class AuthService {
  /// Fully-qualified name of the AuthService service.
  static const name = 'heft.v1.AuthService';

  /// Login authenticates a user by email, creating a new account if needed
  static const login = connect.Spec(
    '/$name/Login',
    connect.StreamType.unary,
    auth.LoginRequest.new,
    auth.LoginResponse.new,
  );
}
