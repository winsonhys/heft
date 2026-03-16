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

    testWidgets('calls onComplete immediately when Start Timer tapped',
        (tester) async {
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

      expect(completeCalled, isFalse);

      // Tap "Start Timer" — should call onComplete immediately
      await tester.tap(find.text('Start Timer'));
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

    testWidgets('displays different duration formats correctly',
        (tester) async {
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
