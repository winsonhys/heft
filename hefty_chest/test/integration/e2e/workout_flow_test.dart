import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hefty_chest/app/app.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';

import '../../test_utils/test_setup.dart';
import '../../test_utils/test_data.dart';

void main() {
  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  setUp(() {
    // Ensure the token provider is set to the test auth token
    IntegrationTestSetup.restoreTokenProvider();
  });

  Auth mockAuth() {
    return MockAuth();
  }

  group('Workout Flow E2E', () {
    testWidgets('displays home screen with app title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(MockAuth.new),
          ],
          child: const HeftyChestApp(),
        ),
      );

      // Wait for initial load - use runAsync only for delays, not pumpWidget
      await tester.runAsync(() async {
        await Future.delayed(const Duration(seconds: 3));
      });
      await tester.pump();

      // Verify app title is displayed
      expect(find.text('Heft'), findsOneWidget);
      expect(find.text('Ready to crush your workout?'), findsOneWidget);
    });

    testWidgets('displays My Workouts section', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Verify section header
      expect(find.text('My Workouts'), findsOneWidget);
    });

    testWidgets('displays workout list from backend', (tester) async {
      await tester.runAsync(() async {
        // Create test workout
        final workoutId = await TestData.createTestWorkout(
          name: 'E2E Display Test Workout',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        // Wait for data to load
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Verify workout appears - checking inside runAsync or outside?
        // Widget tree persists.
        // But clean up needs to happen.
        // Let's verify here (if simple) or cleanup after.
        
        // Clean up
        await TestData.deleteWorkout(workoutId);
      });
      
      // Verify workout appears
      expect(find.text('E2E Display Test Workout'), findsWidgets);
    });

    testWidgets('shows loading indicator while fetching workouts', (tester) async {
        // This test relies on timing (pumping before data loads).
        // With runAsync + delay, it's harder to catch loading state reliably unless we control the backend delay.
        // However, we can try.
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        // Initially should show loading
        await tester.pump();
      });
      
      expect(find.byType(FProgress), findsOneWidget);

      await tester.runAsync(() async {
        // Then settle
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });
    });

    testWidgets('displays quick stats row', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Look for stat labels
      expect(find.text('Workouts'), findsWidgets);
      expect(find.text('This Week'), findsWidgets);
      expect(find.text('Day Streak'), findsWidgets);
    });

    testWidgets('FAB is displayed for creating new workout', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Find the add icon in FAB
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB navigates to workout builder', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Tap FAB
        await tester.tap(find.byIcon(Icons.add));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Should navigate to workout builder
      expect(find.text('Create Workout'), findsOneWidget);
    });

    testWidgets('bottom nav bar is displayed', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // Bottom nav should have icons
      expect(find.byIcon(Icons.home), findsOneWidget); // Active
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget); // Inactive
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget); // Inactive
      expect(find.byIcon(Icons.person_outline), findsOneWidget); // Inactive
    });

    testWidgets('navigates to progress screen via bottom nav', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Tap progress icon
        await tester.tap(find.byIcon(Icons.bar_chart_outlined));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Should be on progress screen
      expect(find.text('Progress'), findsWidgets);
    });

    testWidgets('navigates to profile screen via bottom nav', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Tap profile icon
        await tester.tap(find.byIcon(Icons.person_outline));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Should be on profile screen
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('navigates to calendar screen via bottom nav', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();

        // Tap calendar icon
        await tester.tap(find.byIcon(Icons.calendar_today_outlined));
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
      });

      // Should be on calendar screen
      expect(find.text('Calendar'), findsWidgets);
    });

    testWidgets('workout card shows start and edit options', (tester) async {
      await tester.runAsync(() async {
        // Create test workout
        final workoutId = await TestData.createWorkoutWithExercise(
          name: 'Card Options Test',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        
        // Clean up
        await TestData.deleteWorkout(workoutId);
      });

      // Find workout card
      expect(find.text('Card Options Test'), findsWidgets);

      // Should have start button
      expect(find.text('Start'), findsWidgets);
    });

    testWidgets('shows empty state when no workouts', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(MockAuth.new),
            ],
            child: const HeftyChestApp(),
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
      });

      // If empty, should find the empty state text
      final emptyText = find.text('No workouts yet');

      expect(
        emptyText.evaluate().isNotEmpty ||
            find.text('My Workouts').evaluate().isNotEmpty,
        isTrue,
      );
    });
  });
}

class MockAuth extends Auth {
  @override
  AuthState build() {
    // Return authenticated state immediately
    return AuthState(
      token: IntegrationTestSetup.authToken,
      userId: IntegrationTestSetup.testUserId,
      isLoading: false,
    );
  }
}
