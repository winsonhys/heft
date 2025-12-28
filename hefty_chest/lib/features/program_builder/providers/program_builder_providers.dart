import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';
import '../../home/providers/home_providers.dart';

part 'program_builder_providers.g.dart';

/// State for the program builder
class ProgramBuilderState {
  final String? id;
  final String name;
  final int durationWeeks;
  final int durationDays;
  final Map<int, DayAssignment> dayAssignments;
  final bool isLoading;
  final String? error;

  const ProgramBuilderState({
    this.id,
    this.name = '',
    this.durationWeeks = 4,
    this.durationDays = 0,
    this.dayAssignments = const {},
    this.isLoading = false,
    this.error,
  });

  int get totalDays => durationWeeks * 7 + durationDays;
  int get totalWeeks => (totalDays / 7).ceil();
  int get workoutDays => dayAssignments.values
      .where((a) => a.type == DayAssignmentType.workout)
      .length;
  int get restDays =>
      dayAssignments.values.where((a) => a.type == DayAssignmentType.rest).length;

  ProgramBuilderState copyWith({
    String? id,
    String? name,
    int? durationWeeks,
    int? durationDays,
    Map<int, DayAssignment>? dayAssignments,
    bool? isLoading,
    String? error,
  }) {
    return ProgramBuilderState(
      id: id ?? this.id,
      name: name ?? this.name,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      durationDays: durationDays ?? this.durationDays,
      dayAssignments: dayAssignments ?? this.dayAssignments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

enum DayAssignmentType { workout, rest }

/// Day assignment (workout or rest)
class DayAssignment {
  final DayAssignmentType type;
  final String? workoutId;
  final String? workoutName;

  const DayAssignment({
    required this.type,
    this.workoutId,
    this.workoutName,
  });

  factory DayAssignment.workout(String workoutId, String workoutName) {
    return DayAssignment(
      type: DayAssignmentType.workout,
      workoutId: workoutId,
      workoutName: workoutName,
    );
  }

  factory DayAssignment.rest() {
    return const DayAssignment(type: DayAssignmentType.rest);
  }
}

/// Program builder state notifier
@riverpod
class ProgramBuilder extends _$ProgramBuilder {
  @override
  ProgramBuilderState build() => const ProgramBuilderState();

  void reset() {
    state = const ProgramBuilderState();
  }

  Future<void> loadProgram(String programId) async {
    logProgram.info('Loading program: $programId');
    state = state.copyWith(isLoading: true);
    try {
      final request = GetProgramRequest()..id = programId;

      final response = await programClient.getProgram(request);
      final program = response.program;

      // Convert program days to assignments map
      final assignments = <int, DayAssignment>{};
      for (final day in program.days) {
        if (day.dayType == ProgramDayType.PROGRAM_DAY_TYPE_REST) {
          assignments[day.dayNumber] = DayAssignment.rest();
        } else if (day.dayType == ProgramDayType.PROGRAM_DAY_TYPE_WORKOUT &&
            day.workoutTemplateId.isNotEmpty) {
          assignments[day.dayNumber] = DayAssignment.workout(
            day.workoutTemplateId,
            day.workoutName,
          );
        }
      }

      state = state.copyWith(
        id: program.id,
        name: program.name,
        durationWeeks: program.durationWeeks,
        durationDays: program.durationDays,
        dayAssignments: assignments,
        isLoading: false,
      );
      logProgram.info('Program loaded: ${program.name}');
    } catch (e, st) {
      logProgram.severe('Failed to load program: $programId', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void setDuration(int weeks, int days) {
    // Clamp values
    weeks = weeks.clamp(1, 52);
    days = days.clamp(0, 6);

    // Remove assignments beyond new duration
    final newTotalDays = weeks * 7 + days;
    final newAssignments = Map<int, DayAssignment>.from(state.dayAssignments);
    newAssignments.removeWhere((dayNum, _) => dayNum > newTotalDays);

    state = state.copyWith(
      durationWeeks: weeks,
      durationDays: days,
      dayAssignments: newAssignments,
    );
  }

  void assignWorkout(int dayNumber, String workoutId, String workoutName) {
    final newAssignments = Map<int, DayAssignment>.from(state.dayAssignments);
    newAssignments[dayNumber] = DayAssignment.workout(workoutId, workoutName);
    state = state.copyWith(dayAssignments: newAssignments);
  }

  void assignRest(int dayNumber) {
    final newAssignments = Map<int, DayAssignment>.from(state.dayAssignments);
    newAssignments[dayNumber] = DayAssignment.rest();
    state = state.copyWith(dayAssignments: newAssignments);
  }

  void clearDay(int dayNumber) {
    final newAssignments = Map<int, DayAssignment>.from(state.dayAssignments);
    newAssignments.remove(dayNumber);
    state = state.copyWith(dayAssignments: newAssignments);
  }

  void fillWeekWithRest(int weekNumber) {
    final startDay = (weekNumber - 1) * 7 + 1;
    final endDay = (startDay + 6).clamp(1, state.totalDays);

    final newAssignments = Map<int, DayAssignment>.from(state.dayAssignments);
    for (int day = startDay; day <= endDay; day++) {
      if (!newAssignments.containsKey(day)) {
        newAssignments[day] = DayAssignment.rest();
      }
    }
    state = state.copyWith(dayAssignments: newAssignments);
  }

  void clearWeek(int weekNumber) {
    final startDay = (weekNumber - 1) * 7 + 1;
    final endDay = (startDay + 6).clamp(1, state.totalDays);

    final newAssignments = Map<int, DayAssignment>.from(state.dayAssignments);
    for (int day = startDay; day <= endDay; day++) {
      newAssignments.remove(day);
    }
    state = state.copyWith(dayAssignments: newAssignments);
  }

  Future<bool> saveProgram() async {
    if (state.name.isEmpty) {
      logProgram.warning('Save rejected: empty program name');
      state = state.copyWith(error: 'Please enter a program name');
      return false;
    }

    logProgram.info('Saving program: ${state.name}, isNew: ${state.id == null}');
    state = state.copyWith(isLoading: true);

    try {
      // Both Create and Update use CreateProgramDay
      final createDays = <CreateProgramDay>[];
      for (final entry in state.dayAssignments.entries) {
        final day = CreateProgramDay()..dayNumber = entry.key;

        if (entry.value.type == DayAssignmentType.rest) {
          day.dayType = ProgramDayType.PROGRAM_DAY_TYPE_REST;
        } else {
          day
            ..dayType = ProgramDayType.PROGRAM_DAY_TYPE_WORKOUT
            ..workoutTemplateId = entry.value.workoutId ?? '';
        }

        createDays.add(day);
      }

      if (state.id != null) {
        // Update existing program
        final request = UpdateProgramRequest()
          ..id = state.id!
          ..name = state.name
          ..durationWeeks = state.durationWeeks
          ..durationDays = state.durationDays
          ..days.addAll(createDays);

        await programClient.updateProgram(request);
      } else {
        // Create new program
        final request = CreateProgramRequest()
          ..name = state.name
          ..durationWeeks = state.durationWeeks
          ..durationDays = state.durationDays
          ..days.addAll(createDays);

        await programClient.createProgram(request);
      }

      // Invalidate related providers
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

/// Notifier for current week being viewed
@riverpod
class CurrentWeek extends _$CurrentWeek {
  @override
  int build() => 1;

  void setWeek(int week) => state = week;

  void nextWeek() => state = state + 1;

  void previousWeek() {
    if (state > 1) state = state - 1;
  }

  void reset() => state = 1;
}

/// Provider for workouts available in the program
@riverpod
Future<List<WorkoutSummary>> workoutsForProgram(Ref ref) async {
  final request = ListWorkoutsRequest();

  final response = await workoutClient.listWorkouts(request);
  return response.workouts;
}
