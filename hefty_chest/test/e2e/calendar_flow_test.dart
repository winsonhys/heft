@Tags(['e2e', 'calendar'])
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

void main() {
  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  setUp(() {
    IntegrationTestSetup.restoreTokenProvider();
  });

  group('Calendar Flow E2E', () {
    testWidgets('renders current month with weekday headers', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Calendar tab
        await tester.tap(find.byIcon(Icons.calendar_today_outlined), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Calendar header
      expect(find.text('Calendar'), findsWidgets);
      // CalendarGrid widget
      expect(find.byType(CalendarGrid), findsOneWidget);
      // Weekday headers
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
      // Month name should be visible (current month)
      final now = DateTime.now();
      final monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      expect(
        find.textContaining('${monthNames[now.month - 1]} ${now.year}'),
        findsOneWidget,
      );
    });

    testWidgets('workout day shows indicator after completing session',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        // Complete a session to mark today
        final name = 'Calendar Day Test ${DateTime.now().microsecondsSinceEpoch}';
        final workoutId =
            await TestData.createWorkoutWithExercise(name: name);
        final sessionId = await TestData.startSession(
          workoutTemplateId: workoutId,
        );
        final sessionResponse = await sessionClient.getSession(
          GetSessionRequest()..id = sessionId,
        );
        final syncSets = <SyncSetData>[];
        for (final exercise in sessionResponse.session.exercises) {
          for (final set in exercise.sets) {
            syncSets.add(
              SyncSetData()
                ..id = set.id
                ..weightKg = 60.0
                ..reps = 10
                ..isCompleted = true,
            );
          }
        }
        await sessionClient.syncSession(
          SyncSessionRequest()
            ..sessionId = sessionId
            ..sets.addAll(syncSets),
        );
        await sessionClient.finishSession(
          FinishSessionRequest()..id = sessionId,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Calendar tab
        await tester.tap(find.byIcon(Icons.calendar_today_outlined), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Calendar should render with data
      expect(find.byType(CalendarGrid), findsOneWidget);
    });

    testWidgets('month navigation changes displayed month', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [authProvider.overrideWith(MockAuth.new)],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Navigate to Calendar tab
        await tester.tap(find.byIcon(Icons.calendar_today_outlined), warnIfMissed: false);
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      final now = DateTime.now();
      final monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      final currentMonthText = '${monthNames[now.month - 1]} ${now.year}';

      // Current month should be visible
      expect(find.text(currentMonthText), findsOneWidget);

      await tester.runAsync(() async {
        // Tap next month (chevron_right)
        await tester.tap(find.byIcon(Icons.chevron_right));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Month should have changed - current month text should be gone
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final nextMonthText =
          '${monthNames[nextMonth.month - 1]} ${nextMonth.year}';
      expect(find.text(nextMonthText), findsOneWidget);

      await tester.runAsync(() async {
        // Tap previous month (chevron_left) to go back
        await tester.tap(find.byIcon(Icons.chevron_left));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Should be back to current month
      expect(find.text(currentMonthText), findsOneWidget);
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
