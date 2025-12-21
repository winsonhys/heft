// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active session notifier with periodic sync

@ProviderFor(ActiveSession)
const activeSessionProvider = ActiveSessionProvider._();

/// Active session notifier with periodic sync
final class ActiveSessionProvider
    extends $NotifierProvider<ActiveSession, AsyncValue<SessionModel?>> {
  /// Active session notifier with periodic sync
  const ActiveSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSessionHash();

  @$internal
  @override
  ActiveSession create() => ActiveSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SessionModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SessionModel?>>(value),
    );
  }
}

String _$activeSessionHash() => r'a45a528be9f098b286ac5dacc32ca9b7eac2a47b';

/// Active session notifier with periodic sync

abstract class _$ActiveSession extends $Notifier<AsyncValue<SessionModel?>> {
  AsyncValue<SessionModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<SessionModel?>, AsyncValue<SessionModel?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SessionModel?>, AsyncValue<SessionModel?>>,
              AsyncValue<SessionModel?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for checking if there's an in-progress session (with backup recovery)

@ProviderFor(hasActiveSession)
const hasActiveSessionProvider = HasActiveSessionProvider._();

/// Provider for checking if there's an in-progress session (with backup recovery)

final class HasActiveSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionModel?>,
          SessionModel?,
          FutureOr<SessionModel?>
        >
    with $FutureModifier<SessionModel?>, $FutureProvider<SessionModel?> {
  /// Provider for checking if there's an in-progress session (with backup recovery)
  const HasActiveSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasActiveSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasActiveSessionHash();

  @$internal
  @override
  $FutureProviderElement<SessionModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SessionModel?> create(Ref ref) {
    return hasActiveSession(ref);
  }
}

String _$hasActiveSessionHash() => r'6efd9432112404ab297f9cbbef9a2f56eff081d6';
