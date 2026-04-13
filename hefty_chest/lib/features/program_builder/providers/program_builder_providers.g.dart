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

String _$programBuilderHash() => r'825cccccc4aad16905ccf4649c65af36a2b18eb9';

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

/// Provider for workout templates available in the program builder.

@ProviderFor(workoutsForProgram)
const workoutsForProgramProvider = WorkoutsForProgramProvider._();

/// Provider for workout templates available in the program builder.

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
  /// Provider for workout templates available in the program builder.
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
    r'f4cf2df4c20a0cf2fd63581a01865c8605b13df3';
