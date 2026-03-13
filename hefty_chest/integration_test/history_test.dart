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

  group('History', () {
    testWidgets('history_shows_completed_sessions', (tester) async {
      final name = WebTestSetup.uniqueName('History Test');

      await tester.runAsync(() async {
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        await TestData.completeSession(workoutTemplateId: workoutId);
      });

      await WebTestSetup.pumpAppAndWait(tester);

      // Navigate to History tab
      await WebTestSetup.navigateToTab(tester, 'History');

      // Verify completed session appears
      await WebTestSetup.waitFor(tester, find.text(name));
      expect(find.text(name), findsOneWidget);
    });

    testWidgets('session_detail_view', (tester) async {
      final name = WebTestSetup.uniqueName('Detail View Test');

      await tester.runAsync(() async {
        final workoutId = await TestData.createWorkoutWithExercise(name: name);
        await TestData.completeSession(workoutTemplateId: workoutId);
      });

      await WebTestSetup.pumpAppAndWait(tester);

      // Navigate to History tab
      await WebTestSetup.navigateToTab(tester, 'History');
      await WebTestSetup.waitFor(tester, find.text(name));

      // Tap the session card to view details
      await tester.tap(find.text(name));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      // Verify detail screen shows set data (50kg x 10 reps)
      expect(find.textContaining('50'), findsWidgets);
      expect(find.textContaining('10'), findsWidgets);
    });
  });
}
