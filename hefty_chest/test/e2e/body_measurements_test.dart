@Tags(['e2e', 'profile'])
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

  group('Body Measurements E2E', () {
    testWidgets('log body weight measurement', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        // TODO: When body measurements feature is implemented:
        // 1. Navigate to body measurements screen
        // 2. Enter weight: 75.5 kg
        // 3. Save measurement
        // 4. Verify measurement appears in history list
        // 5. Verify value persists via API (measurementClient.listMeasurements)
        fail('Not implemented');
      });
    }, skip: true /* Feature not implemented yet */);

    testWidgets('log body fat percentage', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        // TODO: When body measurements feature is implemented:
        // 1. Navigate to body measurements screen
        // 2. Select body fat percentage measurement type
        // 3. Enter body fat: 15.0%
        // 4. Save measurement
        // 5. Verify it appears in measurement history with correct type and value
        fail('Not implemented');
      });
    }, skip: true /* Feature not implemented yet */);

    testWidgets('log circumference measurement', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        // TODO: When body measurements feature is implemented:
        // 1. Navigate to body measurements screen
        // 2. Select circumference measurement type (e.g., chest, waist, arm)
        // 3. Enter circumference value: 40.0 cm
        // 4. Save measurement
        // 5. Verify type and value persist via API
        fail('Not implemented');
      });
    }, skip: true /* Feature not implemented yet */);

    testWidgets('measurement history shows entries in order', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        // TODO: When body measurements feature is implemented:
        // 1. Navigate to body measurements screen
        // 2. Log multiple measurements over different times
        // 3. Open measurement history list
        // 4. Verify entries are sorted newest-first
        // 5. Verify each entry shows correct date, type, and value
        fail('Not implemented');
      });
    }, skip: true /* Feature not implemented yet */);

    testWidgets('delete measurement entry', (tester) async {
      await tester.runAsync(() async {
        await TestData.abandonAnyActiveSession();
        // TODO: When body measurements feature is implemented:
        // 1. Navigate to body measurements screen
        // 2. Log a measurement (e.g., weight: 80.0 kg)
        // 3. Verify it appears in history
        // 4. Delete the measurement entry
        // 5. Verify it is removed from history list
        fail('Not implemented');
      });
    }, skip: true /* Feature not implemented yet */);
  });
}
