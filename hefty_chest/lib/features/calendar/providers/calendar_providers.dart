import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';

part 'calendar_providers.g.dart';

/// Notifier for current month being viewed
@riverpod
class CurrentMonth extends _$CurrentMonth {
  @override
  DateTime build() => DateTime.now();

  void setMonth(DateTime month) => state = month;

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void goToToday() {
    state = DateTime.now();
  }
}

/// Notifier for selected day in calendar
@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  DateTime? build() => null;

  void selectDay(DateTime? day) => state = day;

  void clearSelection() => state = null;
}

/// Calendar data for the current month
@riverpod
Future<CalendarData> currentCalendarData(Ref ref) async {
  final currentMonth = ref.watch(currentMonthProvider);
  return ref.watch(calendarMonthProvider(currentMonth).future);
}

/// Calendar month data provider
@riverpod
Future<CalendarData> calendarMonth(Ref ref, DateTime month) async {
  logCalendar.fine('Fetching calendar for ${month.year}-${month.month.toString().padLeft(2, '0')}');
  final request = GetCalendarMonthRequest()
    ..year = month.year
    ..month = month.month;

  final response = await progressClient.getCalendarMonth(request);
  logCalendar.fine('Calendar data fetched');

  // Extract upcoming items from today onwards
  final now = DateTime.now();
  final todayStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final upcoming = <UpcomingItem>[];
  for (final day in response.days) {
    if (day.date.compareTo(todayStr) >= 0) {
      for (final event in day.events) {
        if (!event.isCompleted) {
          upcoming.add(UpcomingItem(
            date: day.date,
            name: event.name,
            type: event.type,
          ));
        }
      }
    }
    if (upcoming.length >= 3) break;
  }

  return CalendarData(
    days: response.days,
    upcoming: upcoming,
  );
}

/// Provider for the user's currently active program (or null), with workouts
/// loaded. The calendar uses this to render the weekly schedule on each cell.
@riverpod
Future<Program?> activeProgram(Ref ref) async {
  final list = await programClient.listPrograms(ListProgramsRequest());
  for (final p in list.programs) {
    if (p.isActive) {
      final full = await programClient.getProgram(GetProgramRequest()..id = p.id);
      return full.program;
    }
  }
  return null;
}

/// Returns scheduled program-workouts for [date] given an active program.
/// Empty if no active program, or if [date] is outside the program window.
List<ProgramWorkout> scheduledWorkoutsFor(Program? program, DateTime date) {
  if (program == null) return const [];
  final start = _parseDate(program.startDate);
  final end = start.add(Duration(days: program.durationWeeks * 7));
  final day = DateTime(date.year, date.month, date.day);
  if (day.isBefore(start) || !day.isBefore(end)) return const [];
  final iso = day.weekday; // Mon=1..Sun=7 in Dart, matches our ISO model
  final dayProto = _isoToProto(iso);
  return program.workouts
      .where((w) => w.daysOfWeek.contains(dayProto))
      .toList();
}

DateTime _parseDate(String s) {
  final parts = s.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

DayOfWeek _isoToProto(int iso) {
  switch (iso) {
    case 1:
      return DayOfWeek.DAY_OF_WEEK_MONDAY;
    case 2:
      return DayOfWeek.DAY_OF_WEEK_TUESDAY;
    case 3:
      return DayOfWeek.DAY_OF_WEEK_WEDNESDAY;
    case 4:
      return DayOfWeek.DAY_OF_WEEK_THURSDAY;
    case 5:
      return DayOfWeek.DAY_OF_WEEK_FRIDAY;
    case 6:
      return DayOfWeek.DAY_OF_WEEK_SATURDAY;
    case 7:
      return DayOfWeek.DAY_OF_WEEK_SUNDAY;
    default:
      return DayOfWeek.DAY_OF_WEEK_UNSPECIFIED;
  }
}

/// Provider for workouts available for scheduling
@riverpod
Future<List<WorkoutSummary>> workoutsForScheduling(Ref ref) async {
  logCalendar.fine('Fetching workouts for scheduling');
  final request = ListWorkoutsRequest();

  final response = await workoutClient.listWorkouts(request);
  logCalendar.fine('Fetched ${response.workouts.length} workouts for scheduling');
  return response.workouts;
}

/// Data class for calendar
class CalendarData {
  final List<CalendarDay> days;
  final List<UpcomingItem> upcoming;

  CalendarData({
    required this.days,
    required this.upcoming,
  });
}

/// Upcoming workout/event item
class UpcomingItem {
  final String date;
  final String name;
  final String type;

  UpcomingItem({
    required this.date,
    required this.name,
    required this.type,
  });
}
