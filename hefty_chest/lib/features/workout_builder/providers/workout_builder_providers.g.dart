// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_builder_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Workout builder state notifier

@ProviderFor(WorkoutBuilder)
const workoutBuilderProvider = WorkoutBuilderProvider._();

/// Workout builder state notifier
final class WorkoutBuilderProvider
    extends $NotifierProvider<WorkoutBuilder, WorkoutBuilderState> {
  /// Workout builder state notifier
  const WorkoutBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutBuilderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutBuilderHash();

  @$internal
  @override
  WorkoutBuilder create() => WorkoutBuilder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutBuilderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutBuilderState>(value),
    );
  }
}

String _$workoutBuilderHash() => r'db2ef277d9e158f01dc7ba69dae5448532e519c2';

/// Workout builder state notifier

abstract class _$WorkoutBuilder extends $Notifier<WorkoutBuilderState> {
  WorkoutBuilderState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<WorkoutBuilderState, WorkoutBuilderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkoutBuilderState, WorkoutBuilderState>,
              WorkoutBuilderState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for exercise list in the search modal

@ProviderFor(exerciseList)
const exerciseListProvider = ExerciseListProvider._();

/// Provider for exercise list in the search modal

final class ExerciseListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Exercise>>,
          List<Exercise>,
          FutureOr<List<Exercise>>
        >
    with $FutureModifier<List<Exercise>>, $FutureProvider<List<Exercise>> {
  /// Provider for exercise list in the search modal
  const ExerciseListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseListHash();

  @$internal
  @override
  $FutureProviderElement<List<Exercise>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Exercise>> create(Ref ref) {
    return exerciseList(ref);
  }
}

String _$exerciseListHash() => r'98ad13eafa40515054a5109a5b5c434ea3482ebb';

/// Notifier for exercise search query

@ProviderFor(ExerciseSearchQuery)
const exerciseSearchQueryProvider = ExerciseSearchQueryProvider._();

/// Notifier for exercise search query
final class ExerciseSearchQueryProvider
    extends $NotifierProvider<ExerciseSearchQuery, String> {
  /// Notifier for exercise search query
  const ExerciseSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseSearchQueryHash();

  @$internal
  @override
  ExerciseSearchQuery create() => ExerciseSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$exerciseSearchQueryHash() =>
    r'632de343ca7c54677eea496725be40cd6a6a9279';

/// Notifier for exercise search query

abstract class _$ExerciseSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Filtered exercises based on search

@ProviderFor(filteredExercises)
const filteredExercisesProvider = FilteredExercisesProvider._();

/// Filtered exercises based on search

final class FilteredExercisesProvider
    extends $FunctionalProvider<List<Exercise>, List<Exercise>, List<Exercise>>
    with $Provider<List<Exercise>> {
  /// Filtered exercises based on search
  const FilteredExercisesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredExercisesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredExercisesHash();

  @$internal
  @override
  $ProviderElement<List<Exercise>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Exercise> create(Ref ref) {
    return filteredExercises(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Exercise> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Exercise>>(value),
    );
  }
}

String _$filteredExercisesHash() => r'84173a97e3107c5672b0c21ecf04bd51a5c057b3';

/// Remote search provider - calls backend searchExercises API

@ProviderFor(searchExercisesRemote)
const searchExercisesRemoteProvider = SearchExercisesRemoteFamily._();

/// Remote search provider - calls backend searchExercises API

final class SearchExercisesRemoteProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Exercise>>,
          List<Exercise>,
          FutureOr<List<Exercise>>
        >
    with $FutureModifier<List<Exercise>>, $FutureProvider<List<Exercise>> {
  /// Remote search provider - calls backend searchExercises API
  const SearchExercisesRemoteProvider._({
    required SearchExercisesRemoteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchExercisesRemoteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchExercisesRemoteHash();

  @override
  String toString() {
    return r'searchExercisesRemoteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Exercise>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Exercise>> create(Ref ref) {
    final argument = this.argument as String;
    return searchExercisesRemote(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchExercisesRemoteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchExercisesRemoteHash() =>
    r'bfa5b61d51f4a333d620cf0e28b5e178fd803368';

/// Remote search provider - calls backend searchExercises API

final class SearchExercisesRemoteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Exercise>>, String> {
  const SearchExercisesRemoteFamily._()
    : super(
        retry: null,
        name: r'searchExercisesRemoteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Remote search provider - calls backend searchExercises API

  SearchExercisesRemoteProvider call(String query) =>
      SearchExercisesRemoteProvider._(argument: query, from: this);

  @override
  String toString() => r'searchExercisesRemoteProvider';
}
