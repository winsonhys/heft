import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hefty_chest/app/app.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HeftyChestApp(),
      ),
    );

    // Verify the app renders
    expect(find.byType(HeftyChestApp), findsOneWidget);
  });
}
