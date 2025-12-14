// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_builder_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Program builder state notifier

@ProviderFor(ProgramBuilder)
const programBuilderProvider = ProgramBuilderProvider._();

/// Program builder state notifier
final class ProgramBuilderProvider
    extends $NotifierProvider<ProgramBuilder, ProgramBuilderState> {
  /// Program builder state notifier
  const ProgramBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programBuilderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programBuilderHash();

  @$internal
  @override
  ProgramBuilder create() => ProgramBuilder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramBuilderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramBuilderState>(value),
    );
  }
}

String _$programBuilderHash() => r'6b55b74d67491f8ab036de6a08a0c65b0647aae6';

/// Program builder state notifier

abstract class _$ProgramBuilder extends $Notifier<ProgramBuilderState> {
  ProgramBuilderState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProgramBuilderState, ProgramBuilderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProgramBuilderState, ProgramBuilderState>,
              ProgramBuilderState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Notifier for current week being viewed

@ProviderFor(CurrentWeek)
const currentWeekProvider = CurrentWeekProvider._();

/// Notifier for current week being viewed
final class CurrentWeekProvider extends $NotifierProvider<CurrentWeek, int> {
  /// Notifier for current week being viewed
  const CurrentWeekProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentWeekProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentWeekHash();

  @$internal
  @override
  CurrentWeek create() => CurrentWeek();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$currentWeekHash() => r'b31eb5eeec2ee458e70cc327512033d71e44c38d';

/// Notifier for current week being viewed

abstract class _$CurrentWeek extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for workouts available in the program

@ProviderFor(workoutsForProgram)
const workoutsForProgramProvider = WorkoutsForProgramProvider._();

/// Provider for workouts available in the program

final class WorkoutsForProgramProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSummary>>,
          List<WorkoutSummary>,
          FutureOr<List<WorkoutSummary>>
        >
    with
        $FutureModifier<List<WorkoutSummary>>,
        $FutureProvider<List<WorkoutSummary>> {
  /// Provider for workouts available in the program
  const WorkoutsForProgramProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutsForProgramProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutsForProgramHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSummary>> create(Ref ref) {
    return workoutsForProgram(ref);
  }
}

String _$workoutsForProgramHash() =>
    r'f1efff6c9f9e160c2545c0d6960ce7f8b0362fb8';
