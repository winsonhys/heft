import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';
import '../../home/providers/home_providers.dart';

part 'program_builder_providers.g.dart';

/// State for the program builder.
///
/// A program is a [startDate] + [durationWeeks] block containing a list of
/// [ProgramWorkoutDraft]s. Each draft holds a workout template plus a set of
/// weekdays (1=Mon..7=Sun) on which it runs.
class ProgramBuilderState {
  final String? id;
  final String name;
  final DateTime startDate;
  final int durationWeeks;
  final List<ProgramWorkoutDraft> workouts;
  final bool isLoading;
  final String? error;

  ProgramBuilderState({
    this.id,
    this.name = '',
    DateTime? startDate,
    this.durationWeeks = 4,
    this.workouts = const [],
    this.isLoading = false,
    this.error,
  }) : startDate = startDate ?? _today();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get endDate => startDate.add(Duration(days: durationWeeks * 7));

  ProgramBuilderState copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    int? durationWeeks,
    List<ProgramWorkoutDraft>? workouts,
    bool? isLoading,
    String? error,
  }) {
    return ProgramBuilderState(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      workouts: workouts ?? this.workouts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// A single workout-on-weekdays assignment within the builder's draft state.
class ProgramWorkoutDraft {
  /// Server-assigned id once saved; null for new entries.
  final String? id;
  final String workoutTemplateId;
  final String workoutName;

  /// ISO weekdays (Mon=1..Sun=7). Always non-empty for a valid draft.
  final Set<int> days;

  const ProgramWorkoutDraft({
    this.id,
    required this.workoutTemplateId,
    required this.workoutName,
    required this.days,
  });

  ProgramWorkoutDraft copyWith({
    String? id,
    String? workoutTemplateId,
    String? workoutName,
    Set<int>? days,
  }) {
    return ProgramWorkoutDraft(
      id: id ?? this.id,
      workoutTemplateId: workoutTemplateId ?? this.workoutTemplateId,
      workoutName: workoutName ?? this.workoutName,
      days: days ?? this.days,
    );
  }
}

/// Maps proto DayOfWeek -> ISO int (Mon=1..Sun=7) and back.
const _isoFromProto = <DayOfWeek, int>{
  DayOfWeek.DAY_OF_WEEK_MONDAY: 1,
  DayOfWeek.DAY_OF_WEEK_TUESDAY: 2,
  DayOfWeek.DAY_OF_WEEK_WEDNESDAY: 3,
  DayOfWeek.DAY_OF_WEEK_THURSDAY: 4,
  DayOfWeek.DAY_OF_WEEK_FRIDAY: 5,
  DayOfWeek.DAY_OF_WEEK_SATURDAY: 6,
  DayOfWeek.DAY_OF_WEEK_SUNDAY: 7,
};
const _protoFromIso = <int, DayOfWeek>{
  1: DayOfWeek.DAY_OF_WEEK_MONDAY,
  2: DayOfWeek.DAY_OF_WEEK_TUESDAY,
  3: DayOfWeek.DAY_OF_WEEK_WEDNESDAY,
  4: DayOfWeek.DAY_OF_WEEK_THURSDAY,
  5: DayOfWeek.DAY_OF_WEEK_FRIDAY,
  6: DayOfWeek.DAY_OF_WEEK_SATURDAY,
  7: DayOfWeek.DAY_OF_WEEK_SUNDAY,
};

int isoFromProtoDay(DayOfWeek d) => _isoFromProto[d] ?? 0;
DayOfWeek protoFromIsoDay(int iso) => _protoFromIso[iso] ?? DayOfWeek.DAY_OF_WEEK_UNSPECIFIED;

String _formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseProgramDate(String s) {
  final parts = s.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

/// Program builder state notifier
@riverpod
class ProgramBuilder extends _$ProgramBuilder {
  @override
  ProgramBuilderState build() => ProgramBuilderState();

  void reset() {
    state = ProgramBuilderState();
  }

  Future<void> loadProgram(String programId) async {
    logProgram.info('Loading program: $programId');
    state = state.copyWith(isLoading: true);
    try {
      final response =
          await programClient.getProgram(GetProgramRequest()..id = programId);
      final program = response.program;

      final drafts = program.workouts
          .map((w) => ProgramWorkoutDraft(
                id: w.id,
                workoutTemplateId: w.workoutTemplateId,
                workoutName: w.workoutName,
                days: w.daysOfWeek
                    .map(isoFromProtoDay)
                    .where((iso) => iso > 0)
                    .toSet(),
              ))
          .toList();

      state = state.copyWith(
        id: program.id,
        name: program.name,
        startDate: parseProgramDate(program.startDate),
        durationWeeks: program.durationWeeks,
        workouts: drafts,
        isLoading: false,
      );
      logProgram.info('Program loaded: ${program.name}');
    } catch (e, st) {
      logProgram.severe('Failed to load program: $programId', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateName(String name) => state = state.copyWith(name: name);

  void setStartDate(DateTime date) => state = state.copyWith(startDate: date);

  void setDurationWeeks(int weeks) =>
      state = state.copyWith(durationWeeks: weeks.clamp(1, 52));

  void addWorkout(ProgramWorkoutDraft draft) {
    state = state.copyWith(workouts: [...state.workouts, draft]);
  }

  void updateWorkoutAt(int index, ProgramWorkoutDraft draft) {
    final next = [...state.workouts];
    next[index] = draft;
    state = state.copyWith(workouts: next);
  }

  void removeWorkoutAt(int index) {
    final next = [...state.workouts]..removeAt(index);
    state = state.copyWith(workouts: next);
  }

  Future<bool> saveProgram() async {
    if (state.name.trim().isEmpty) {
      logProgram.warning('Save rejected: empty program name');
      state = state.copyWith(error: 'Please enter a program name');
      return false;
    }
    if (state.workouts.any((w) => w.days.isEmpty)) {
      state = state.copyWith(error: 'Each workout needs at least one day');
      return false;
    }

    logProgram.info('Saving program: ${state.name}, isNew: ${state.id == null}');
    state = state.copyWith(isLoading: true);

    try {
      final inputs = <ProgramWorkoutInput>[];
      for (var i = 0; i < state.workouts.length; i++) {
        final w = state.workouts[i];
        final input = ProgramWorkoutInput()
          ..workoutTemplateId = w.workoutTemplateId
          ..displayOrder = i;
        for (final iso in (w.days.toList()..sort())) {
          input.daysOfWeek.add(protoFromIsoDay(iso));
        }
        inputs.add(input);
      }

      final startDateStr = _formatDate(state.startDate);

      if (state.id != null) {
        final request = UpdateProgramRequest()
          ..id = state.id!
          ..name = state.name
          ..startDate = startDateStr
          ..durationWeeks = state.durationWeeks
          ..replaceWorkouts = true
          ..workouts.addAll(inputs);
        await programClient.updateProgram(request);
      } else {
        final request = CreateProgramRequest()
          ..name = state.name
          ..startDate = startDateStr
          ..durationWeeks = state.durationWeeks
          ..workouts.addAll(inputs);
        await programClient.createProgram(request);
      }

      ref.invalidate(workoutsForProgramProvider);
      ref.invalidate(dashboardStatsProvider);

      logProgram.info('Program ${state.id != null ? "updated" : "created"}: ${state.name}');
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      logProgram.severe('Failed to save program: ${state.name}', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// Provider for workout templates available in the program builder.
@riverpod
Future<List<WorkoutSummary>> workoutsForProgram(Ref ref) async {
  final response = await workoutClient.listWorkouts(ListWorkoutsRequest());
  return response.workouts;
}
