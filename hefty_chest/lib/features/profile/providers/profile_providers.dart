import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/client.dart';
import '../../../core/config.dart';

/// Provider for user profile
final userProfileProvider = FutureProvider<User>((ref) async {
  final request = GetProfileRequest()
    ..userId = AppConfig.hardcodedUserId;

  final response = await userClient.getProfile(request);
  return response.user;
});

/// Provider for profile stats (from dashboard stats)
final profileStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final request = GetDashboardStatsRequest()
    ..userId = AppConfig.hardcodedUserId;

  final response = await progressClient.getDashboardStats(request);
  return response.stats;
});

/// Notifier for user settings
class UserSettingsNotifier extends Notifier<AsyncValue<User>> {
  @override
  AsyncValue<User> build() {
    _loadUser();
    return const AsyncValue.loading();
  }

  Future<void> _loadUser() async {
    try {
      final request = GetProfileRequest()
        ..userId = AppConfig.hardcodedUserId;
      final response = await userClient.getProfile(request);
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings({
    bool? usePounds,
    int? restTimerSeconds,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final request = UpdateSettingsRequest()
        ..userId = AppConfig.hardcodedUserId;

      if (usePounds != null) {
        request.usePounds = usePounds;
      }
      if (restTimerSeconds != null) {
        request.restTimerSeconds = restTimerSeconds;
      }

      final response = await userClient.updateSettings(request);
      state = AsyncValue.data(response.user);

      // Invalidate the profile provider so it refreshes
      ref.invalidate(userProfileProvider);
    } catch (e, st) {
      // Revert to current state on error
      state = AsyncValue.error(e, st);
    }
  }
}

final userSettingsProvider =
    NotifierProvider<UserSettingsNotifier, AsyncValue<User>>(
        UserSettingsNotifier.new);
