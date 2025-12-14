import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/client.dart';

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
  final request = GetCalendarMonthRequest()
    ..year = month.year
    ..month = month.month;

  final response = await progressClient.getCalendarMonth(request);

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

/// Provider for workouts available for scheduling
@riverpod
Future<List<WorkoutSummary>> workoutsForScheduling(Ref ref) async {
  final request = ListWorkoutsRequest();

  final response = await workoutClient.listWorkouts(request);
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
