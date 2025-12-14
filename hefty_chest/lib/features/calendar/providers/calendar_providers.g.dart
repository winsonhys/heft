// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for current month being viewed

@ProviderFor(CurrentMonth)
const currentMonthProvider = CurrentMonthProvider._();

/// Notifier for current month being viewed
final class CurrentMonthProvider
    extends $NotifierProvider<CurrentMonth, DateTime> {
  /// Notifier for current month being viewed
  const CurrentMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentMonthHash();

  @$internal
  @override
  CurrentMonth create() => CurrentMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$currentMonthHash() => r'82202db5ce13e825ef119a3de1fcfccc34224b52';

/// Notifier for current month being viewed

abstract class _$CurrentMonth extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Notifier for selected day in calendar

@ProviderFor(SelectedDay)
const selectedDayProvider = SelectedDayProvider._();

/// Notifier for selected day in calendar
final class SelectedDayProvider
    extends $NotifierProvider<SelectedDay, DateTime?> {
  /// Notifier for selected day in calendar
  const SelectedDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDayHash();

  @$internal
  @override
  SelectedDay create() => SelectedDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$selectedDayHash() => r'dd0b85d38a51abde9bc96a43329e51eff2254af3';

/// Notifier for selected day in calendar

abstract class _$SelectedDay extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Calendar data for the current month

@ProviderFor(currentCalendarData)
const currentCalendarDataProvider = CurrentCalendarDataProvider._();

/// Calendar data for the current month

final class CurrentCalendarDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<CalendarData>,
          CalendarData,
          FutureOr<CalendarData>
        >
    with $FutureModifier<CalendarData>, $FutureProvider<CalendarData> {
  /// Calendar data for the current month
  const CurrentCalendarDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentCalendarDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentCalendarDataHash();

  @$internal
  @override
  $FutureProviderElement<CalendarData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CalendarData> create(Ref ref) {
    return currentCalendarData(ref);
  }
}

String _$currentCalendarDataHash() =>
    r'974ddd5a8c50aa18c99aac7e1d3c11389e82ffc5';

/// Calendar month data provider

@ProviderFor(calendarMonth)
const calendarMonthProvider = CalendarMonthFamily._();

/// Calendar month data provider

final class CalendarMonthProvider
    extends
        $FunctionalProvider<
          AsyncValue<CalendarData>,
          CalendarData,
          FutureOr<CalendarData>
        >
    with $FutureModifier<CalendarData>, $FutureProvider<CalendarData> {
  /// Calendar month data provider
  const CalendarMonthProvider._({
    required CalendarMonthFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'calendarMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarMonthHash();

  @override
  String toString() {
    return r'calendarMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CalendarData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CalendarData> create(Ref ref) {
    final argument = this.argument as DateTime;
    return calendarMonth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarMonthHash() => r'abe0e7ec924ccbc73bbf9d5d476e0b5d66561212';

/// Calendar month data provider

final class CalendarMonthFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CalendarData>, DateTime> {
  const CalendarMonthFamily._()
    : super(
        retry: null,
        name: r'calendarMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Calendar month data provider

  CalendarMonthProvider call(DateTime month) =>
      CalendarMonthProvider._(argument: month, from: this);

  @override
  String toString() => r'calendarMonthProvider';
}

/// Provider for workouts available for scheduling

@ProviderFor(workoutsForScheduling)
const workoutsForSchedulingProvider = WorkoutsForSchedulingProvider._();

/// Provider for workouts available for scheduling

final class WorkoutsForSchedulingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSummary>>,
          List<WorkoutSummary>,
          FutureOr<List<WorkoutSummary>>
        >
    with
        $FutureModifier<List<WorkoutSummary>>,
        $FutureProvider<List<WorkoutSummary>> {
  /// Provider for workouts available for scheduling
  const WorkoutsForSchedulingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutsForSchedulingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutsForSchedulingHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSummary>> create(Ref ref) {
    return workoutsForScheduling(ref);
  }
}

String _$workoutsForSchedulingHash() =>
    r'49eef20aa95976b199c71c69d2e938566e2fcba1';
