// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active session notifier

@ProviderFor(ActiveSession)
const activeSessionProvider = ActiveSessionProvider._();

/// Active session notifier
final class ActiveSessionProvider
    extends $NotifierProvider<ActiveSession, AsyncValue<Session?>> {
  /// Active session notifier
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

String _$activeSessionHash() => r'637ad69e39215d33fb1b7ae91b1bb874196b59f3';

/// Active session notifier

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

/// Provider for checking if there's an in-progress session

@ProviderFor(hasActiveSession)
const hasActiveSessionProvider = HasActiveSessionProvider._();

/// Provider for checking if there's an in-progress session

final class HasActiveSessionProvider
    extends
        $FunctionalProvider<AsyncValue<Session?>, Session?, FutureOr<Session?>>
    with $FutureModifier<Session?>, $FutureProvider<Session?> {
  /// Provider for checking if there's an in-progress session
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

String _$hasActiveSessionHash() => r'ad6ed86a99be9566d1e69e3c61f537b2b8cfd7d3';
