import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';

part 'profile_providers.g.dart';

/// Provider for user profile
@riverpod
Future<User> userProfile(Ref ref) async {
  final request = GetProfileRequest();

  final response = await userClient.getProfile(request);
  return response.user;
}

/// Provider for profile stats (from dashboard stats)
@riverpod
Future<DashboardStats> profileStats(Ref ref) async {
  final request = GetDashboardStatsRequest();

  final response = await progressClient.getDashboardStats(request);
  return response.stats;
}

/// Notifier for user settings
@riverpod
class UserSettings extends _$UserSettings {
  @override
  FutureOr<User> build() async {
    final request = GetProfileRequest();
    final response = await userClient.getProfile(request);
    return response.user;
  }

  Future<void> updateSettings({
    bool? usePounds,
    int? restTimerSeconds,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    logProfile.info('Updating settings: usePounds=$usePounds, restTimer=$restTimerSeconds');
    state = const AsyncValue.loading();
    try {
      final request = UpdateSettingsRequest();

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
      logProfile.info('Settings updated successfully');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      logProfile.severe('Failed to update settings', e, st);
    }
  }
}
