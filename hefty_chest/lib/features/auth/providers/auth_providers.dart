import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/client.dart';

part 'auth_providers.g.dart';

/// Auth state holding token and user ID
class AuthState {
  final String? token;
  final String? userId;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.token,
    this.userId,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => token != null && userId != null;

  AuthState copyWith({
    String? token,
    String? userId,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Auth state notifier
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  @override
  AuthState build() {
    // Initialize async - load saved auth
    _loadSavedAuth();
    return const AuthState(isLoading: true);
  }

  Future<void> _loadSavedAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userId = prefs.getString(_userIdKey);

      if (token != null && userId != null) {
        state = AuthState(token: token, userId: userId);
      } else {
        state = const AuthState();
      }
    } catch (e) {
      state = const AuthState();
    }
  }

  Future<bool> login(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = LoginRequest()..email = email;
      final response = await authClient.login(request);

      // Save to persistent storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, response.token);
      await prefs.setString(_userIdKey, response.userId);

      state = AuthState(
        token: response.token,
        userId: response.userId,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    state = const AuthState();
  }
}

/// Provider for the current user ID (convenience accessor)
@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(authProvider).userId;
}

/// Provider for auth token (convenience accessor)
@riverpod
String? authToken(Ref ref) {
  return ref.watch(authProvider).token;
}
