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

  group('Profile', () {
    testWidgets('profile_shows_user_info_and_settings', (tester) async {
      await WebTestSetup.pumpAppAndWait(tester);

      // Navigate to Profile tab
      await WebTestSetup.navigateToTab(tester, 'Profile');

      // Verify Profile header
      expect(find.text('Profile'), findsWidgets);

      // Verify member info is displayed
      await WebTestSetup.waitFor(tester, find.textContaining('Member since'));
      expect(find.textContaining('Member since'), findsOneWidget);

      // Verify Settings section
      expect(find.text('Settings'), findsOneWidget);

      // Verify unit toggle (KG/LBS)
      expect(find.text('Weight Unit'), findsOneWidget);
      expect(find.text('KG'), findsOneWidget);
    });
  });
}
