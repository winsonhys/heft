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
    testWidgets('displays rest label with duration', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 90),
          ),
        ),
      );

      // Verify info label with duration
      expect(find.textContaining('Rest'), findsOneWidget);
      expect(find.textContaining('1:30'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);

      // No buttons — timer auto-triggers
      expect(find.text('Start Timer'), findsNothing);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('displays different duration formats correctly',
        (tester) async {
      // Test 30 seconds
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 30),
          ),
        ),
      );
      expect(find.textContaining('0:30'), findsOneWidget);

      // Test 2 minutes (120 seconds)
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 120),
          ),
        ),
      );
      expect(find.textContaining('2:00'), findsOneWidget);

      // Test 3:45 (225 seconds)
      await tester.pumpWidget(
        createTestWidget(
          child: RestItemCard(
            restItem: createMockRestItem(restDurationSeconds: 225),
          ),
        ),
      );
      expect(find.textContaining('3:45'), findsOneWidget);
    });

    group('superset mode', () {
      testWidgets('shows "Rest Between Rounds" label', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: RestItemCard(
              restItem: createMockRestItem(restDurationSeconds: 60),
              isSuperset: true,
            ),
          ),
        );

        expect(find.textContaining('Rest Between Rounds'), findsOneWidget);
        expect(find.textContaining('1:00'), findsOneWidget);
        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      });

      testWidgets('non-superset shows "Rest" label without "Between Rounds"',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: RestItemCard(
              restItem: createMockRestItem(restDurationSeconds: 60),
            ),
          ),
        );

        expect(find.textContaining('Rest'), findsOneWidget);
        expect(find.textContaining('Between Rounds'), findsNothing);
      });
    });
  });
}
