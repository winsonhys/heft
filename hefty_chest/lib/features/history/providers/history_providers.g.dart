// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching completed workout sessions

@ProviderFor(sessionHistory)
const sessionHistoryProvider = SessionHistoryProvider._();

/// Provider for fetching completed workout sessions

final class SessionHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SessionSummary>>,
          List<SessionSummary>,
          FutureOr<List<SessionSummary>>
        >
    with
        $FutureModifier<List<SessionSummary>>,
        $FutureProvider<List<SessionSummary>> {
  /// Provider for fetching completed workout sessions
  const SessionHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<SessionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SessionSummary>> create(Ref ref) {
    return sessionHistory(ref);
  }
}

String _$sessionHistoryHash() => r'44966b5758559e8aaf7629a010a54e0176884368';

/// Provider for fetching full session details

@ProviderFor(sessionDetail)
const sessionDetailProvider = SessionDetailFamily._();

/// Provider for fetching full session details

final class SessionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionModel>,
          SessionModel,
          FutureOr<SessionModel>
        >
    with $FutureModifier<SessionModel>, $FutureProvider<SessionModel> {
  /// Provider for fetching full session details
  const SessionDetailProvider._({
    required SessionDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionDetailHash();

  @override
  String toString() {
    return r'sessionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SessionModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SessionModel> create(Ref ref) {
    final argument = this.argument as String;
    return sessionDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionDetailHash() => r'91dc55cfe9983a796219c6924cdff4420ef7634d';

/// Provider for fetching full session details

final class SessionDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SessionModel>, String> {
  const SessionDetailFamily._()
    : super(
        retry: null,
        name: r'sessionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching full session details

  SessionDetailProvider call(String sessionId) =>
      SessionDetailProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionDetailProvider';
}
