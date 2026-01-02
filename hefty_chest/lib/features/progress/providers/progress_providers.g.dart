// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for dashboard stats

@ProviderFor(progressStats)
const progressStatsProvider = ProgressStatsProvider._();

/// Provider for dashboard stats

final class ProgressStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardStats>,
          DashboardStats,
          FutureOr<DashboardStats>
        >
    with $FutureModifier<DashboardStats>, $FutureProvider<DashboardStats> {
  /// Provider for dashboard stats
  const ProgressStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressStatsHash();

  @$internal
  @override
  $FutureProviderElement<DashboardStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardStats> create(Ref ref) {
    return progressStats(ref);
  }
}

String _$progressStatsHash() => r'c83f176cebf8cab22b0aba782b81a6c0444fd98e';

/// Provider for weekly activity data

@ProviderFor(weeklyActivity)
const weeklyActivityProvider = WeeklyActivityProvider._();

/// Provider for weekly activity data

final class WeeklyActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeeklyActivityDay>>,
          List<WeeklyActivityDay>,
          FutureOr<List<WeeklyActivityDay>>
        >
    with
        $FutureModifier<List<WeeklyActivityDay>>,
        $FutureProvider<List<WeeklyActivityDay>> {
  /// Provider for weekly activity data
  const WeeklyActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyActivityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyActivityHash();

  @$internal
  @override
  $FutureProviderElement<List<WeeklyActivityDay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WeeklyActivityDay>> create(Ref ref) {
    return weeklyActivity(ref);
  }
}

String _$weeklyActivityHash() => r'55e981901131018120e082e7fcd2623f390c343d';

/// Provider for personal records (limit to 5 recent)

@ProviderFor(personalRecords)
const personalRecordsProvider = PersonalRecordsProvider._();

/// Provider for personal records (limit to 5 recent)

final class PersonalRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PersonalRecord>>,
          List<PersonalRecord>,
          FutureOr<List<PersonalRecord>>
        >
    with
        $FutureModifier<List<PersonalRecord>>,
        $FutureProvider<List<PersonalRecord>> {
  /// Provider for personal records (limit to 5 recent)
  const PersonalRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalRecordsHash();

  @$internal
  @override
  $FutureProviderElement<List<PersonalRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PersonalRecord>> create(Ref ref) {
    return personalRecords(ref);
  }
}

String _$personalRecordsHash() => r'620e52d56da56598410241ebe074b51f5f589c1c';

/// Notifier for selected exercise ID for progress chart

@ProviderFor(SelectedExerciseId)
const selectedExerciseIdProvider = SelectedExerciseIdProvider._();

/// Notifier for selected exercise ID for progress chart
final class SelectedExerciseIdProvider
    extends $NotifierProvider<SelectedExerciseId, String?> {
  /// Notifier for selected exercise ID for progress chart
  const SelectedExerciseIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedExerciseIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedExerciseIdHash();

  @$internal
  @override
  SelectedExerciseId create() => SelectedExerciseId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedExerciseIdHash() =>
    r'7ac0d1e26b1ca8cd7347a8414b20f09e6df81efd';

/// Notifier for selected exercise ID for progress chart

abstract class _$SelectedExerciseId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for exercise progress data

@ProviderFor(exerciseProgress)
const exerciseProgressProvider = ExerciseProgressFamily._();

/// Provider for exercise progress data

final class ExerciseProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExerciseProgressSummary?>,
          ExerciseProgressSummary?,
          FutureOr<ExerciseProgressSummary?>
        >
    with
        $FutureModifier<ExerciseProgressSummary?>,
        $FutureProvider<ExerciseProgressSummary?> {
  /// Provider for exercise progress data
  const ExerciseProgressProvider._({
    required ExerciseProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseProgressHash();

  @override
  String toString() {
    return r'exerciseProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ExerciseProgressSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExerciseProgressSummary?> create(Ref ref) {
    final argument = this.argument as String;
    return exerciseProgress(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseProgressHash() => r'b50ebcbc03e5f53803d7513243615c6a8f5c3946';

/// Provider for exercise progress data

final class ExerciseProgressFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ExerciseProgressSummary?>, String> {
  const ExerciseProgressFamily._()
    : super(
        retry: null,
        name: r'exerciseProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for exercise progress data

  ExerciseProgressProvider call(String exerciseId) =>
      ExerciseProgressProvider._(argument: exerciseId, from: this);

  @override
  String toString() => r'exerciseProgressProvider';
}

/// Provider for list of exercises (for exercise selector)

@ProviderFor(exercisesList)
const exercisesListProvider = ExercisesListProvider._();

/// Provider for list of exercises (for exercise selector)

final class ExercisesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Exercise>>,
          List<Exercise>,
          FutureOr<List<Exercise>>
        >
    with $FutureModifier<List<Exercise>>, $FutureProvider<List<Exercise>> {
  /// Provider for list of exercises (for exercise selector)
  const ExercisesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exercisesListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exercisesListHash();

  @$internal
  @override
  $FutureProviderElement<List<Exercise>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Exercise>> create(Ref ref) {
    return exercisesList(ref);
  }
}

String _$exercisesListHash() => r'c44c1109fb331c2b2b5b2f89b9e51d83ae290fd6';

/// Computed provider for current exercise progress based on selected exercise

@ProviderFor(currentExerciseProgress)
const currentExerciseProgressProvider = CurrentExerciseProgressProvider._();

/// Computed provider for current exercise progress based on selected exercise

final class CurrentExerciseProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExerciseProgressSummary?>,
          ExerciseProgressSummary?,
          FutureOr<ExerciseProgressSummary?>
        >
    with
        $FutureModifier<ExerciseProgressSummary?>,
        $FutureProvider<ExerciseProgressSummary?> {
  /// Computed provider for current exercise progress based on selected exercise
  const CurrentExerciseProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentExerciseProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentExerciseProgressHash();

  @$internal
  @override
  $FutureProviderElement<ExerciseProgressSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExerciseProgressSummary?> create(Ref ref) {
    return currentExerciseProgress(ref);
  }
}

String _$currentExerciseProgressHash() =>
    r'5e9faccfe70470868881ac1eff6167a8dfffb2a1';
