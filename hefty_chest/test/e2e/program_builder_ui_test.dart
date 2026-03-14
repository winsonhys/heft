@Tags(['e2e', 'program'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import 'package:hefty_chest/features/program_builder/program_builder_screen.dart';
import 'package:hefty_chest/features/program_builder/widgets/duration_selector.dart';
import 'package:hefty_chest/features/program_builder/widgets/week_navigation.dart';
import 'package:hefty_chest/features/program_builder/widgets/day_card.dart';
import 'package:hefty_chest/features/program_builder/widgets/program_summary_card.dart';

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

  String getUniqueName(String base) {
    return '$base ${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(MockAuth.new)],
        child: const HeftyChestApp(),
      ),
    );
  }

  /// Navigate from home to Calendar tab, then tap add icon.
  /// Must be called inside runAsync. Navigation completes after
  /// exiting runAsync and calling pump().
  Future<void> navigateToProgramBuilder(WidgetTester tester) async {
    await TestData.abandonAnyActiveSession();
    await pumpApp(tester);

    await Future.delayed(const Duration(seconds: 3));
    await tester.pump();

    // Navigate to Calendar tab
    await tester.tap(
      find.byIcon(Icons.calendar_today_outlined),
      warnIfMissed: false,
    );
    await Future.delayed(const Duration(seconds: 3));
    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));
    await tester.pump();

    // Tap the add icon in the Calendar header to open program builder
    final addIcon = find.byKey(const Key('calendar_add_program'));
    if (addIcon.evaluate().isNotEmpty) {
      await tester.tap(addIcon);
    }
    await Future.delayed(const Duration(seconds: 2));
    await tester.pump();
  }

  group('Program Builder UI E2E', () {
    testWidgets('navigates to program builder', (tester) async {
      await tester.runAsync(() async {
        await navigateToProgramBuilder(tester);
      });

      // GoRouter navigation completes after exiting runAsync
      await tester.pump();

      expect(find.text('Create Program'), findsOneWidget);
      expect(find.byType(ProgramBuilderScreen), findsOneWidget);
    });

    testWidgets('duration selector is present', (tester) async {
      await tester.runAsync(() async {
        await navigateToProgramBuilder(tester);
      });

      await tester.pump();

      expect(find.text('Create Program'), findsOneWidget);
      expect(find.byType(DurationSelector), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('4 weeks'), findsOneWidget);
      expect(find.text('6 weeks'), findsOneWidget);
      expect(find.text('8 weeks'), findsOneWidget);
      expect(find.text('12 weeks'), findsOneWidget);
    });

    testWidgets('week navigation renders with correct week', (tester) async {
      await tester.runAsync(() async {
        await navigateToProgramBuilder(tester);
      });

      await tester.pump();

      expect(find.text('Create Program'), findsOneWidget);
      expect(find.byType(WeekNavigation), findsOneWidget);
      expect(find.text('Week 1'), findsOneWidget);
      expect(find.text('of 4 weeks'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('day cards render for current week', (tester) async {
      await tester.runAsync(() async {
        await navigateToProgramBuilder(tester);
      });

      await tester.pump();

      expect(find.text('Create Program'), findsOneWidget);

      final dayCards = find.byType(DayCard);
      expect(dayCards, findsNWidgets(7));

      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Day 7'), findsOneWidget);

      expect(find.byType(ProgramSummaryCard), findsOneWidget);
      expect(find.text('Total Days'), findsOneWidget);
      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('Rest'), findsOneWidget);
      expect(find.text('Unassigned'), findsOneWidget);
    });

    testWidgets('fill rest days button works', (tester) async {
      // Phase 1: Navigate to program builder
      await tester.runAsync(() async {
        await navigateToProgramBuilder(tester);
      });
      await tester.pump();

      // Phase 2: Tap fill rest button
      await tester.runAsync(() async {
        final fillRestGesture = find.ancestor(
          of: find.text('Fill empty with rest'),
          matching: find.byType(GestureDetector),
        );
        if (fillRestGesture.evaluate().isNotEmpty) {
          final widget =
              tester.widget<GestureDetector>(fillRestGesture.first);
          widget.onTap?.call();
        }
        await Future.delayed(const Duration(seconds: 1));
        await tester.pump();
      });

      await tester.pump();

      final restTexts = find.text('Rest');
      expect(restTexts.evaluate().isNotEmpty, isTrue);

      final bedtimeIcons = find.byIcon(Icons.bedtime);
      expect(bedtimeIcons.evaluate().isNotEmpty, isTrue);

      expect(find.byType(ProgramSummaryCard), findsOneWidget);
    });

    testWidgets('save program and verify via API', (tester) async {
      final name = getUniqueName('BuilderProg');

      // Phase 1: Navigate to program builder
      await tester.runAsync(() async {
        await navigateToProgramBuilder(tester);
      });
      await tester.pump();

      // Phase 2: Fill in name and save
      await tester.runAsync(() async {
        final nameField = find.byType(EditableText);
        if (nameField.evaluate().isNotEmpty) {
          await tester.enterText(nameField.first, name);
          await tester.pump();
        }

        final saveIcon = find.byIcon(Icons.save);
        if (saveIcon.evaluate().isNotEmpty) {
          await tester.tap(saveIcon);
        }
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Verify program was created via API
      late bool found;
      String? programId;
      await tester.runAsync(() async {
        final listResponse = await programClient.listPrograms(
          ListProgramsRequest(),
        );

        final match = listResponse.programs.where((p) => p.name == name);
        found = match.isNotEmpty;
        if (found) {
          programId = match.first.id;
        }
      });

      expect(found, isTrue);

      // Cleanup: delete the program
      await tester.runAsync(() async {
        if (programId != null) {
          await programClient.deleteProgram(
            DeleteProgramRequest()..id = programId!,
          );
        }
      });
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
