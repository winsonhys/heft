// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floating_session_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stores the floating widget's position (persists across route changes)

@ProviderFor(FloatingSessionPosition)
const floatingSessionPositionProvider = FloatingSessionPositionProvider._();

/// Stores the floating widget's position (persists across route changes)
final class FloatingSessionPositionProvider
    extends $NotifierProvider<FloatingSessionPosition, Offset> {
  /// Stores the floating widget's position (persists across route changes)
  const FloatingSessionPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'floatingSessionPositionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$floatingSessionPositionHash();

  @$internal
  @override
  FloatingSessionPosition create() => FloatingSessionPosition();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Offset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Offset>(value),
    );
  }
}

String _$floatingSessionPositionHash() =>
    r'caf4bc9b68c6f81635b4b900457ac2b88933c053';

/// Stores the floating widget's position (persists across route changes)

abstract class _$FloatingSessionPosition extends $Notifier<Offset> {
  Offset build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Offset, Offset>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Offset, Offset>,
              Offset,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Controls floating widget visibility (hidden on tracker screen)

@ProviderFor(FloatingWidgetVisible)
const floatingWidgetVisibleProvider = FloatingWidgetVisibleProvider._();

/// Controls floating widget visibility (hidden on tracker screen)
final class FloatingWidgetVisibleProvider
    extends $NotifierProvider<FloatingWidgetVisible, bool> {
  /// Controls floating widget visibility (hidden on tracker screen)
  const FloatingWidgetVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'floatingWidgetVisibleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$floatingWidgetVisibleHash();

  @$internal
  @override
  FloatingWidgetVisible create() => FloatingWidgetVisible();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$floatingWidgetVisibleHash() =>
    r'cfcfe1e77fb93673119a203964439e478ca14754';

/// Controls floating widget visibility (hidden on tracker screen)

abstract class _$FloatingWidgetVisible extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
