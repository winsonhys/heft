// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for user profile

@ProviderFor(userProfile)
const userProfileProvider = UserProfileProvider._();

/// Provider for user profile

final class UserProfileProvider
    extends $FunctionalProvider<AsyncValue<User>, User, FutureOr<User>>
    with $FutureModifier<User>, $FutureProvider<User> {
  /// Provider for user profile
  const UserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @$internal
  @override
  $FutureProviderElement<User> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<User> create(Ref ref) {
    return userProfile(ref);
  }
}

String _$userProfileHash() => r'6cd267b6b80baa889eabe66f94552d1f8daf0a9c';

/// Provider for profile stats (from dashboard stats)

@ProviderFor(profileStats)
const profileStatsProvider = ProfileStatsProvider._();

/// Provider for profile stats (from dashboard stats)

final class ProfileStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardStats>,
          DashboardStats,
          FutureOr<DashboardStats>
        >
    with $FutureModifier<DashboardStats>, $FutureProvider<DashboardStats> {
  /// Provider for profile stats (from dashboard stats)
  const ProfileStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileStatsHash();

  @$internal
  @override
  $FutureProviderElement<DashboardStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardStats> create(Ref ref) {
    return profileStats(ref);
  }
}

String _$profileStatsHash() => r'd40ab5099832364a40b8ce0c4b660641b7fee899';

/// Notifier for user settings

@ProviderFor(UserSettings)
const userSettingsProvider = UserSettingsProvider._();

/// Notifier for user settings
final class UserSettingsProvider
    extends $AsyncNotifierProvider<UserSettings, User> {
  /// Notifier for user settings
  const UserSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSettingsHash();

  @$internal
  @override
  UserSettings create() => UserSettings();
}

String _$userSettingsHash() => r'7025ef959b271fac2b890ca0d06117840647b949';

/// Notifier for user settings

abstract class _$UserSettings extends $AsyncNotifier<User> {
  FutureOr<User> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<User>, User>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<User>, User>,
              AsyncValue<User>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
