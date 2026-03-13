import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_utils/test_data.dart';
import 'test_utils/web_test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await WebTestSetup.waitForBackend();
    await WebTestSetup.resetDatabase();
    await WebTestSetup.authenticateTestUser();
  });

  setUp(() async {
    WebTestSetup.restoreTokenProvider();
    await TestData.abandonAnyActiveSession();
  });

  group('Progress', () {
    testWidgets('progress_dashboard_loads', (tester) async {
      await tester.runAsync(() async {
        final workoutId = await TestData.createWorkoutWithExercise(
          name: WebTestSetup.uniqueName('Progress Data'),
        );
        await TestData.completeSession(workoutTemplateId: workoutId);
      });

      await WebTestSetup.pumpAppAndWait(tester);

      // Navigate to Progress tab
      await WebTestSetup.navigateToTab(tester, 'Progress');

      // Verify Progress header
      expect(find.text('Progress'), findsWidgets);

      // Verify Weekly Activity section
      await WebTestSetup.waitFor(tester, find.text('Weekly Activity'));
      expect(find.text('Weekly Activity'), findsOneWidget);

      // Verify Recent PRs section
      expect(find.text('Recent PRs'), findsOneWidget);
    });
  });
}
