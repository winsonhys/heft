import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hefty_chest/features/tracker/models/session_models.dart';
import 'package:hefty_chest/features/tracker/widgets/set_row.dart';

/// Helper to wrap widget with FTheme (required for FTextField)
Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: FTheme(
      data: FThemes.zinc.dark,
      child: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    ),
  );
}

/// Creates a mock SessionSetModel for testing
SessionSetModel createMockSet({
  String id = 'test-set-id',
  int setNumber = 1,
  double weightKg = 0,
  int reps = 0,
  int restDurationSeconds = 0,
  bool isCompleted = false,
  double targetWeightKg = 0,
  int targetReps = 0,
}) {
  return SessionSetModel(
    id: id,
    setNumber: setNumber,
    weightKg: weightKg,
    reps: reps,
    restDurationSeconds: restDurationSeconds,
    isCompleted: isCompleted,
    targetWeightKg: targetWeightKg,
    targetReps: targetReps,
  );
}

void main() {
  group('SetRow rest duration indicator', () {
    testWidgets('shows rest indicator when restDurationSeconds > 0',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: SetRow(
            set: createMockSet(restDurationSeconds: 60),
            onComplete: (_, __, ___, ____) {},
          ),
        ),
      );

      // Timer icon should be present
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);

      // Duration text "1:00" should be displayed
      expect(find.text('1:00'), findsOneWidget);
    });

    testWidgets('hides rest indicator when restDurationSeconds is 0',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: SetRow(
            set: createMockSet(restDurationSeconds: 0),
            onComplete: (_, __, ___, ____) {},
          ),
        ),
      );

      // Timer icon should not be present
      expect(find.byIcon(Icons.timer_outlined), findsNothing);
    });

    testWidgets('formats rest duration correctly', (tester) async {
      // 90 seconds = "1:30"
      await tester.pumpWidget(
        createTestWidget(
          child: SetRow(
            set: createMockSet(restDurationSeconds: 90),
            onComplete: (_, __, ___, ____) {},
          ),
        ),
      );
      expect(find.text('1:30'), findsOneWidget);

      // 30 seconds = "0:30"
      await tester.pumpWidget(
        createTestWidget(
          child: SetRow(
            set: createMockSet(restDurationSeconds: 30),
            onComplete: (_, __, ___, ____) {},
          ),
        ),
      );
      expect(find.text('0:30'), findsOneWidget);

      // 120 seconds = "2:00"
      await tester.pumpWidget(
        createTestWidget(
          child: SetRow(
            set: createMockSet(restDurationSeconds: 120),
            onComplete: (_, __, ___, ____) {},
          ),
        ),
      );
      expect(find.text('2:00'), findsOneWidget);
    });
  });
}
