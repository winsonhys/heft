@Tags(['e2e', 'progress'])
library;

import 'package:flutter_test/flutter_test.dart';

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

  group('Previous Values & Rep Ranges E2E', () {
    testWidgets('tracker shows previous session weight and reps',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        // TODO: When previous values feature is implemented:
        // 1. Create workout and complete session with 60kg x 10 reps
        // 2. Start new session for same workout
        // 3. Navigate to tracker
        // 4. Verify previous values hint shows "60 kg x 10"
        fail('Not implemented');
      });
    }, skip: true /* Feature not implemented yet */);

    testWidgets('previous values update after each session', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        // TODO: When previous values feature is implemented:
        // 1. Create workout and complete first session with 60kg x 10 reps
        // 2. Complete second session with 70kg x 8 reps
        // 3. Start third session for same workout
        // 4. Navigate to tracker
        // 5. Verify previous values show most recent session data: "70 kg x 8"
        fail('Not implemented');
      });
    }, skip: true /* Feature not implemented yet */);

    testWidgets('target rep range displays on set row', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        // TODO: When target rep range feature is implemented:
        // 1. Create workout with target rep range (e.g., 8-12)
        // 2. Start session for that workout
        // 3. Navigate to tracker
        // 4. Verify tracker shows the rep range text (e.g., "8-12 reps")
        fail('Not implemented');
      });
    }, skip: true /* Feature not implemented yet */);

    testWidgets('previous values work across different exercises',
        (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        // TODO: When previous values feature is implemented:
        // 1. Create workout with multiple exercises
        // 2. Complete session with different weights per exercise
        //    (e.g., Bench Press 80kg x 10, Squat 100kg x 8)
        // 3. Start new session for same workout
        // 4. Navigate to tracker
        // 5. Verify each exercise shows its own previous values
        //    (Bench Press hint: "80 kg x 10", Squat hint: "100 kg x 8")
        fail('Not implemented');
      });
    }, skip: true /* Feature not implemented yet */);
  });
}
