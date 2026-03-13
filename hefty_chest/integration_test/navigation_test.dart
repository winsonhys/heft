import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_utils/web_test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await WebTestSetup.waitForBackend();
    await WebTestSetup.resetDatabase();
    await WebTestSetup.authenticateTestUser();
  });

  setUp(() {
    WebTestSetup.restoreTokenProvider();
  });

  group('Navigation', () {
    testWidgets('bottom_nav_tab_switching', (tester) async {
      await WebTestSetup.pumpAppAndWait(tester);

      // Verify we start on Home
      expect(find.text('Heft'), findsOneWidget);

      // Tap History tab
      await WebTestSetup.navigateToTab(tester, 'History');
      expect(find.text('History'), findsWidgets); // header + tab label

      // Tap Progress tab
      await WebTestSetup.navigateToTab(tester, 'Progress');
      expect(find.text('Progress'), findsWidgets);

      // Tap Calendar tab
      await WebTestSetup.navigateToTab(tester, 'Calendar');
      expect(find.text('Calendar'), findsWidgets);

      // Tap Profile tab
      await WebTestSetup.navigateToTab(tester, 'Profile');
      expect(find.text('Profile'), findsWidgets);

      // Tap Home tab to return
      await WebTestSetup.navigateToTab(tester, 'Home');
      expect(find.text('Heft'), findsOneWidget);
    });

    testWidgets('fab_navigates_to_workout_builder', (tester) async {
      await WebTestSetup.pumpAppAndWait(tester);

      // Tap the FAB (+) button on home screen
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(seconds: 1));

      // Verify workout builder screen
      expect(find.text('Create Workout'), findsOneWidget);
    });
  });
}
