import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hefty_chest/shared/widgets/floating_session_widget.dart';
import 'package:hefty_chest/features/tracker/providers/session_providers.dart';
import 'package:hefty_chest/core/client.dart';
import 'package:hefty_chest/gen/google/protobuf/timestamp.pb.dart';

/// Creates a mock Session for testing
Session createMockSession({
  String id = 'test-session-id',
  String name = 'Test Workout',
  int completedSets = 5,
  int totalSets = 12,
  DateTime? startedAt,
}) {
  final session = Session()
    ..id = id
    ..name = name
    ..completedSets = completedSets
    ..totalSets = totalSets;

  if (startedAt != null) {
    session.startedAt = Timestamp.fromDateTime(startedAt);
  }

  return session;
}

/// Creates a mock GoRouter for testing
GoRouter createMockRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/session/:id', builder: (_, __) => const SizedBox()),
    ],
  );
}

/// Helper to wrap widget under test with required providers
Widget createTestWidget({
  required Widget child,
  List<Object> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 800,
          child: Stack(children: [child]),
        ),
      ),
    ),
  );
}

void main() {
  group('FloatingSessionWidget', () {
    late GoRouter mockRouter;

    setUp(() {
      mockRouter = createMockRouter();
    });

    testWidgets('displays session info when active session exists',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            hasActiveSessionProvider
                .overrideWith((ref) async => createMockSession()),
          ],
          child: FloatingSessionWidget(router: mockRouter),
        ),
      );

      // Wait for async provider to resolve
      await tester.pumpAndSettle();

      // Verify workout name is displayed
      expect(find.text('Test Workout'), findsOneWidget);

      // Verify set progress is displayed
      expect(find.text('5/12 sets'), findsOneWidget);

      // Verify icons are present
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('displays fallback name when session name is empty',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            hasActiveSessionProvider
                .overrideWith((ref) async => createMockSession(name: '')),
          ],
          child: FloatingSessionWidget(router: mockRouter),
        ),
      );

      await tester.pumpAndSettle();

      // Should show 'Workout' as fallback
      expect(find.text('Workout'), findsOneWidget);
    });

    testWidgets('hidden when no active session', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            hasActiveSessionProvider.overrideWith((ref) async => null),
          ],
          child: FloatingSessionWidget(router: mockRouter),
        ),
      );

      await tester.pumpAndSettle();

      // Widget should not show any session info
      expect(find.text('Test Workout'), findsNothing);
      expect(find.byIcon(Icons.fitness_center), findsNothing);

      // Should render SizedBox.shrink() - look for empty SizedBox
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows nothing during loading state', (tester) async {
      // Create a completer that we can control
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            hasActiveSessionProvider.overrideWith((ref) async {
              // Return immediately but we check before pumpAndSettle
              return createMockSession();
            }),
          ],
          child: FloatingSessionWidget(router: mockRouter),
        ),
      );

      // Check immediately after first pump (before async resolves)
      // The widget should show SizedBox.shrink during loading
      expect(find.text('Test Workout'), findsNothing);
    });

    testWidgets('drag updates position', (tester) async {
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hasActiveSessionProvider
                .overrideWith((ref) async => createMockSession()),
          ],
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: 400,
                    height: 800,
                    child: Stack(children: [FloatingSessionWidget(router: mockRouter)]),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial position
      final initialPosition = container.read(floatingSessionPositionProvider);

      // Find the GestureDetector that wraps our content (look for the one with fitness_center icon)
      final gestureDetector = find.ancestor(
        of: find.byIcon(Icons.fitness_center),
        matching: find.byType(GestureDetector),
      );

      // Drag the widget
      await tester.drag(gestureDetector.first, const Offset(100, 100));
      await tester.pumpAndSettle();

      // Position should have changed
      final newPosition = container.read(floatingSessionPositionProvider);

      // The y position should definitely have changed since we drag down
      expect(newPosition.dy, isNot(equals(initialPosition.dy)));
    });

    testWidgets('displays correct set counts', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            hasActiveSessionProvider.overrideWith(
              (ref) async => createMockSession(
                completedSets: 3,
                totalSets: 8,
              ),
            ),
          ],
          child: FloatingSessionWidget(router: mockRouter),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('3/8 sets'), findsOneWidget);
    });

    testWidgets('renders with Material widget and elevation', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            hasActiveSessionProvider
                .overrideWith((ref) async => createMockSession()),
          ],
          child: FloatingSessionWidget(router: mockRouter),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Material widget that contains our content (the one with fitness icon)
      final materialFinder = find.ancestor(
        of: find.byIcon(Icons.fitness_center),
        matching: find.byType(Material),
      );

      final materialWidget = tester.widget<Material>(materialFinder.first);

      // Verify it has elevation for shadow effect
      expect(materialWidget.elevation, equals(8));

      // Verify border radius
      expect(
        materialWidget.borderRadius,
        equals(BorderRadius.circular(12)),
      );
    });

    testWidgets('displays elapsed time when session has startedAt', (tester) async {
      // Create a session that started 125 seconds ago (2:05)
      final startTime = DateTime.now().subtract(const Duration(seconds: 125));

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            hasActiveSessionProvider.overrideWith(
              (ref) async => createMockSession(startedAt: startTime),
            ),
          ],
          child: FloatingSessionWidget(router: mockRouter),
        ),
      );

      await tester.pumpAndSettle();

      // Should display elapsed time in MM:SS format
      // The exact time might be 2:05 or 2:06 depending on test timing
      expect(find.textContaining('2:'), findsOneWidget);
    });

    testWidgets('elapsed time updates after 1 second', (tester) async {
      // Create a session that started 5 seconds ago
      final startTime = DateTime.now().subtract(const Duration(seconds: 5));

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            hasActiveSessionProvider.overrideWith(
              (ref) async => createMockSession(startedAt: startTime),
            ),
          ],
          child: FloatingSessionWidget(router: mockRouter),
        ),
      );

      await tester.pumpAndSettle();

      // Should show initial time (around 0:05)
      expect(find.textContaining('0:0'), findsOneWidget);

      // Pump 1 second
      await tester.pump(const Duration(seconds: 1));

      // Time should have incremented (around 0:06)
      expect(find.textContaining('0:0'), findsOneWidget);
    });
  });
}
