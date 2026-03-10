import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/features/tracker/widgets/rest_item_card.dart';

/// Creates a mock SessionRestItemModel for testing
SessionRestItemModel createMockRestItem({
  String id = 'test-rest-item-id',
  int displayOrder = 0,
  String sectionName = 'Section A',
  int restDurationSeconds = 90,
  bool isCompleted = false,
  DateTime? completedAt,
}) {
  return SessionRestItemModel(
    id: id,
    displayOrder: displayOrder,
    sectionName: sectionName,
    restDurationSeconds: restDurationSeconds,
    isCompleted: isCompleted,
    completedAt: completedAt,
  );
}

/// Helper to wrap widget under test with required providers
Widget createTestWidget({
  required Widget child,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

void main() {
  group('RestItemCard', () {
    testWidgets('displays rest item with duration', (tester) async {
      bool completeCalled = false;
      bool skipCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 90),
            onComplete: () => completeCalled = true,
            onSkip: () => skipCalled = true,
          ),
        ),
      );

      // Verify "Rest" label is displayed
      expect(find.text('Rest'), findsOneWidget);

      // Verify duration is displayed (90 seconds = "1:30")
      expect(find.text('1:30'), findsOneWidget);

      // Verify timer icon is present
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);

      // Verify buttons are present
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Start Timer'), findsOneWidget);

      // Callbacks should not have been called yet
      expect(completeCalled, isFalse);
      expect(skipCalled, isFalse);
    });

    testWidgets('shows completed state with checkmark', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(
              isCompleted: true,
              restDurationSeconds: 60,
            ),
            onComplete: () {},
            onSkip: () {},
          ),
        ),
      );

      // Verify checkmark icon is displayed
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Verify undo icon is displayed
      expect(find.byIcon(Icons.undo), findsOneWidget);

      // Verify text has strikethrough styling (compact view)
      final textFinder = find.textContaining('Rest (1:00)');
      expect(textFinder, findsOneWidget);

      // Timer button should not be present
      expect(find.text('Start Timer'), findsNothing);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('timer starts on button tap', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 10),
            onComplete: () {},
            onSkip: () {},
          ),
        ),
      );

      // Initially shows "Start Timer"
      expect(find.text('Start Timer'), findsOneWidget);
      expect(find.text('Done'), findsNothing);

      // Tap "Start Timer" button
      await tester.tap(find.text('Start Timer'));
      await tester.pump();

      // Button should now say "Done"
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Start Timer'), findsNothing);

      // Should show "Time remaining" subtitle
      expect(find.text('Time remaining'), findsOneWidget);
    });

    testWidgets('timer counts down each second', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 5),
            onComplete: () {},
            onSkip: () {},
          ),
        ),
      );

      // Start the timer
      await tester.tap(find.text('Start Timer'));
      await tester.pump();

      // Initial display should show "0:05"
      expect(find.text('0:05'), findsOneWidget);

      // Pump 1 second
      await tester.pump(const Duration(seconds: 1));

      // Should now show "0:04"
      expect(find.text('0:04'), findsOneWidget);

      // Pump another second
      await tester.pump(const Duration(seconds: 1));

      // Should now show "0:03"
      expect(find.text('0:03'), findsOneWidget);
    });

    testWidgets('calls onComplete when timer finishes', (tester) async {
      bool completeCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 2),
            onComplete: () => completeCalled = true,
            onSkip: () {},
          ),
        ),
      );

      // Start the timer
      await tester.tap(find.text('Start Timer'));
      await tester.pump();

      expect(completeCalled, isFalse);

      // Tick 1: 2->1, timer still running
      await tester.pump(const Duration(seconds: 1));
      expect(completeCalled, isFalse);

      // Tick 2: 1->0, 0:00 is displayed but onComplete not yet fired
      await tester.pump(const Duration(seconds: 1));
      expect(completeCalled, isFalse);

      // Tick 3: <= 0 condition fires onComplete
      await tester.pump(const Duration(seconds: 1));
      expect(completeCalled, isTrue);
    });

    testWidgets('calls onComplete when Done button tapped', (tester) async {
      bool completeCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 60),
            onComplete: () => completeCalled = true,
            onSkip: () {},
          ),
        ),
      );

      // Start the timer
      await tester.tap(find.text('Start Timer'));
      await tester.pump();

      expect(completeCalled, isFalse);

      // Tap "Done" to complete early
      await tester.tap(find.text('Done'));
      await tester.pump();

      expect(completeCalled, isTrue);
    });

    testWidgets('calls onSkip on Skip button tap', (tester) async {
      bool skipCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(),
            onComplete: () {},
            onSkip: () => skipCalled = true,
          ),
        ),
      );

      expect(skipCalled, isFalse);

      // Tap Skip button
      await tester.tap(find.text('Skip'));
      await tester.pump();

      expect(skipCalled, isTrue);
    });

    testWidgets('undo button calls onSkip to toggle back', (tester) async {
      bool skipCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(isCompleted: true),
            onComplete: () {},
            onSkip: () => skipCalled = true,
          ),
        ),
      );

      expect(skipCalled, isFalse);

      // Find and tap undo icon
      await tester.tap(find.byIcon(Icons.undo));
      await tester.pump();

      expect(skipCalled, isTrue);
    });

    testWidgets('skip stops running timer', (tester) async {
      bool skipCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 30),
            onComplete: () {},
            onSkip: () => skipCalled = true,
          ),
        ),
      );

      // Start the timer
      await tester.tap(find.text('Start Timer'));
      await tester.pump();

      // Verify timer is running
      expect(find.text('Done'), findsOneWidget);

      // Tap Skip while timer is running
      await tester.tap(find.text('Skip'));
      await tester.pump();

      expect(skipCalled, isTrue);
    });

    // RestTimerSheet already uses <= 0 (rest_timer_sheet.dart line 47) and is the
    // reference implementation. Both timer widgets now share the same termination semantics.
    testWidgets('shows 0:00 before calling onComplete', (tester) async {
      bool completeCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 2),
            onComplete: () => completeCalled = true,
            onSkip: () {},
          ),
        ),
      );

      // Start the timer
      await tester.tap(find.text('Start Timer'));
      await tester.pump();

      // Tick 1: 2 -> 1
      await tester.pump(const Duration(seconds: 1));
      expect(completeCalled, isFalse);
      expect(find.text('0:01'), findsOneWidget);

      // Tick 2: 1 -> 0, display shows 0:00
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('0:00'), findsOneWidget);
      expect(completeCalled, isFalse);

      // Tick 3: <= 0 fires onComplete
      await tester.pump(const Duration(seconds: 1));
      expect(completeCalled, isTrue);
    });

    testWidgets('displays different duration formats correctly', (tester) async {
      // Test 30 seconds
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 30),
            onComplete: () {},
            onSkip: () {},
          ),
        ),
      );

      expect(find.text('0:30'), findsOneWidget);

      // Test 2 minutes (120 seconds)
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 120),
            onComplete: () {},
            onSkip: () {},
          ),
        ),
      );

      expect(find.text('2:00'), findsOneWidget);

      // Test 3:45 (225 seconds)
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 225),
            onComplete: () {},
            onSkip: () {},
          ),
        ),
      );

      expect(find.text('3:45'), findsOneWidget);
    });
  });
}
