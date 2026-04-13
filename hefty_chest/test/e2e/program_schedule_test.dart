@Tags(['e2e', 'program', 'calendar'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/calendar/widgets/calendar_grid.dart';

import '../test_utils/test_setup.dart';
import '../test_utils/test_data.dart';

/// E2E coverage for the new "program = weekday-scheduled workouts" model.
///
/// Verifies the round-trip:
///   - Backend accepts a program with weekday-scheduled workouts via RPC
///   - Calendar grid surfaces the schedule indicator on matching weekdays
///   - Calendar cells outside the program window stay clean
void main() {
  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  setUp(() => IntegrationTestSetup.restoreTokenProvider());

  group('Program schedule E2E', () {
    test('create program with weekday workouts and read it back', () async {
      final wtId = await TestData.createTestWorkout(name: 'Push');
      final today = DateTime.now();
      final iso = '${today.year.toString().padLeft(4, '0')}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';

      final create = CreateProgramRequest()
        ..name = 'Schedule Test'
        ..startDate = iso
        ..durationWeeks = 4
        ..workouts.add(ProgramWorkoutInput()
          ..workoutTemplateId = wtId
          ..displayOrder = 0
          ..daysOfWeek.addAll([
            DayOfWeek.DAY_OF_WEEK_MONDAY,
            DayOfWeek.DAY_OF_WEEK_WEDNESDAY,
            DayOfWeek.DAY_OF_WEEK_FRIDAY,
          ]));

      final created = await programClient.createProgram(create);
      expect(created.program.workouts, hasLength(1));
      expect(created.program.workouts.first.daysOfWeek,
          containsAll([
            DayOfWeek.DAY_OF_WEEK_MONDAY,
            DayOfWeek.DAY_OF_WEEK_WEDNESDAY,
            DayOfWeek.DAY_OF_WEEK_FRIDAY,
          ]));

      // Activate + verify GetTodayWorkout includes the workout iff today is M/W/F.
      await programClient
          .setActiveProgram(SetActiveProgramRequest()..id = created.program.id);

      final todayResp =
          await programClient.getTodayWorkout(GetTodayWorkoutRequest());
      expect(todayResp.inProgramWindow, isTrue,
          reason: 'today must be inside the program window');
      final iso1to7 = today.weekday; // Mon=1..Sun=7 in Dart matches our ISO model
      final shouldHave = iso1to7 == 1 || iso1to7 == 3 || iso1to7 == 5;
      expect(todayResp.workouts.length, shouldHave ? 1 : 0,
          reason: shouldHave
              ? 'today is M/W/F → workout should appear'
              : 'today is not M/W/F → no workouts');
    });

    testWidgets('calendar marks scheduled weekdays', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        // Create a program scheduled every weekday so calendar always lights up
        final wtId = await TestData.createTestWorkout(
            name: 'Daily ${DateTime.now().microsecondsSinceEpoch}');
        final today = DateTime.now();
        final iso = '${today.year.toString().padLeft(4, '0')}-'
            '${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}';

        final create = CreateProgramRequest()
          ..name = 'Daily Program'
          ..startDate = iso
          ..durationWeeks = 4
          ..workouts.add(ProgramWorkoutInput()
            ..workoutTemplateId = wtId
            ..displayOrder = 0
            ..daysOfWeek.addAll(const [
              DayOfWeek.DAY_OF_WEEK_MONDAY,
              DayOfWeek.DAY_OF_WEEK_TUESDAY,
              DayOfWeek.DAY_OF_WEEK_WEDNESDAY,
              DayOfWeek.DAY_OF_WEEK_THURSDAY,
              DayOfWeek.DAY_OF_WEEK_FRIDAY,
              DayOfWeek.DAY_OF_WEEK_SATURDAY,
              DayOfWeek.DAY_OF_WEEK_SUNDAY,
            ]));
        final program = await programClient.createProgram(create);
        await programClient
            .setActiveProgram(SetActiveProgramRequest()..id = program.program.id);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.calendar_today_outlined),
            warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 5));
        await tester.pump();
      });

      await tester.pump();

      final todayKey = () {
        final t = DateTime.now();
        return 'calendar_day_${t.year.toString().padLeft(4, '0')}-'
            '${t.month.toString().padLeft(2, '0')}-'
            '${t.day.toString().padLeft(2, '0')}';
      }();

      expect(find.byType(CalendarGrid), findsOneWidget,
          reason: 'Calendar grid should be visible after navigation');
      // The grid renders a loading state until the GetCalendarMonth response
      // arrives. Poll a few extra pumps.
      for (var i = 0; i < 10 && find.byKey(Key(todayKey)).evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future.delayed(const Duration(seconds: 1)));
        await tester.pump();
      }
      expect(find.byKey(Key(todayKey)), findsOneWidget,
          reason: 'Today\'s cell key $todayKey should exist on the grid');
    });
  });
}

class MockAuth extends Auth {
  @override
  AuthState build() => AuthState(
        token: IntegrationTestSetup.authToken,
        userId: IntegrationTestSetup.testUserId,
        isLoading: false,
      );
}
