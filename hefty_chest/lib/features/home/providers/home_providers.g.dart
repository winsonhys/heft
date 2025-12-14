// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the list of workouts

@ProviderFor(workoutList)
const workoutListProvider = WorkoutListProvider._();

/// Provider for the list of workouts

final class WorkoutListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSummary>>,
          List<WorkoutSummary>,
          FutureOr<List<WorkoutSummary>>
        >
    with
        $FutureModifier<List<WorkoutSummary>>,
        $FutureProvider<List<WorkoutSummary>> {
  /// Provider for the list of workouts
  const WorkoutListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutListHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSummary>> create(Ref ref) {
    return workoutList(ref);
  }
}

String _$workoutListHash() => r'b8421099180a83bdbd9f4ab32a8382b27632bff8';

/// Provider for dashboard statistics

@ProviderFor(dashboardStats)
const dashboardStatsProvider = DashboardStatsProvider._();

/// Provider for dashboard statistics

final class DashboardStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardStats>,
          DashboardStats,
          FutureOr<DashboardStats>
        >
    with $FutureModifier<DashboardStats>, $FutureProvider<DashboardStats> {
  /// Provider for dashboard statistics
  const DashboardStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStatsHash();

  @$internal
  @override
  $FutureProviderElement<DashboardStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardStats> create(Ref ref) {
    return dashboardStats(ref);
  }
}

String _$dashboardStatsHash() => r'ee2a5be02a51c155ebf645632f088e14c81cbe96';

/// Provider for a single workout detail

@ProviderFor(workoutDetail)
const workoutDetailProvider = WorkoutDetailFamily._();

/// Provider for a single workout detail

final class WorkoutDetailProvider
    extends $FunctionalProvider<AsyncValue<Workout>, Workout, FutureOr<Workout>>
    with $FutureModifier<Workout>, $FutureProvider<Workout> {
  /// Provider for a single workout detail
  const WorkoutDetailProvider._({
    required WorkoutDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutDetailHash();

  @override
  String toString() {
    return r'workoutDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Workout> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Workout> create(Ref ref) {
    final argument = this.argument as String;
    return workoutDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutDetailHash() => r'ccf9b0ed0e0d2d364583c015bbd7d1c26fdeb773';

/// Provider for a single workout detail

final class WorkoutDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Workout>, String> {
  const WorkoutDetailFamily._()
    : super(
        retry: null,
        name: r'workoutDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for a single workout detail

  WorkoutDetailProvider call(String workoutId) =>
      WorkoutDetailProvider._(argument: workoutId, from: this);

  @override
  String toString() => r'workoutDetailProvider';
}
