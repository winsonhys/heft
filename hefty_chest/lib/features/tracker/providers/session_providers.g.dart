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
    extends $NotifierProvider<ActiveSession, AsyncValue<Session?>> {
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
  Override overrideWithValue(AsyncValue<Session?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Session?>>(value),
    );
  }
}

String _$activeSessionHash() => r'a647359ff262dc0e6e3528861af6bfa4423df860';

/// Active session notifier with periodic sync

abstract class _$ActiveSession extends $Notifier<AsyncValue<Session?>> {
  AsyncValue<Session?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Session?>, AsyncValue<Session?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Session?>, AsyncValue<Session?>>,
              AsyncValue<Session?>,
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
        $FunctionalProvider<AsyncValue<Session?>, Session?, FutureOr<Session?>>
    with $FutureModifier<Session?>, $FutureProvider<Session?> {
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
  $FutureProviderElement<Session?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Session?> create(Ref ref) {
    return hasActiveSession(ref);
  }
}

String _$hasActiveSessionHash() => r'f8d08eb2c122c7e8a2add8f495c6bb244bbb1f09';
