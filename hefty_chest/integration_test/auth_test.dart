import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:integration_test/integration_test.dart';

import 'test_utils/web_test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await WebTestSetup.waitForBackend();
    await WebTestSetup.resetDatabase();
    // Note: do NOT call authenticateTestUser here — this test
    // exercises the real auth flow without MockAuth.
  });

  group('Auth Flow', () {
    testWidgets('login_redirects_to_home', (tester) async {
      await tester.runAsync(() async {
        // Pump the app WITHOUT MockAuth — uses real auth provider
        await tester.pumpWidget(
          const ProviderScope(child: HeftyChestApp()),
        );
        await Future.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      // Should be on auth screen since not authenticated
      expect(find.text('Continue'), findsOneWidget);

      // Enter email and tap Continue
      await tester.enterText(
        find.byType(EditableText).first,
        WebTestSetup.testUserEmail,
      );
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Continue'));
        await Future.delayed(const Duration(seconds: 2));
      });
      await tester.pump();

      // Should redirect to home screen after login
      await WebTestSetup.waitFor(tester, find.text('Heft'));
      expect(find.text('Heft'), findsOneWidget);
    });
  });
}
