# E2E Tests

Full end-to-end tests that run the real `HeftyChestApp` against a live backend (Docker Compose).

## Harness Engineering Rules

Mechanical rules. Violations are bugs — they cause silent false passes.

### 1. Never silently skip taps

Every tap MUST be preceded by `expect(finder, findsOneWidget)`. The pattern `if (x.evaluate().isNotEmpty) { tap }` is **banned**.

```dart
// CORRECT
expect(finder, findsOneWidget, reason: 'Save icon should be visible');
await tester.tap(finder);

// WRONG — test "passes" when widget doesn't render
if (finder.evaluate().isNotEmpty) {
  await tester.tap(finder);
}
```

Use `safeTap()` from `test_helpers.dart` to enforce this in one call.

### 2. Find tappable widgets by Key

Use `find.byKey(const Key('screen_component'))`. Key naming: `{screen}_{component}` snake_case.

```dart
// CORRECT
await tester.tap(find.byKey(const Key('workout_builder_save')));

// WRONG — ambiguous when duplicate icons exist
await tester.tap(find.byIcon(Icons.save));
```

Available keys: `home_fab`, `calendar_add_program`, `workout_builder_save`, `program_builder_save`, `tracker_discard`, `tracker_finish`, `tracker_back`, `workout_card_start`, `workout_card_edit`

### 3. Pump after runAsync for navigation

GoRouter navigation from `tester.tap()` inside `runAsync` only completes after `await tester.pump()` OUTSIDE `runAsync`. Put assertions about the destination screen outside runAsync.

```dart
// CORRECT
await tester.runAsync(() async {
  await tester.tap(finder);
  await Future.delayed(const Duration(seconds: 2));
  await tester.pump();
});
await tester.pump(); // Navigation completes HERE
expect(find.text('Create Workout'), findsOneWidget); // Assert HERE

// WRONG — navigation hasn't completed yet
await tester.runAsync(() async {
  await tester.tap(finder);
  await Future.delayed(const Duration(seconds: 2));
  await tester.pump();
  expect(find.text('Create Workout'), findsOneWidget); // May fail!
});
```

### 4. Handle off-screen widgets

FHeaderAction suffixes render at x~975 in 800×600 test viewport. Use `onTap?.call()` for off-screen taps or `warnIfMissed: false`.

```dart
// CORRECT — invoke onTap directly for off-screen widgets
tapOffScreen(tester, find.byKey(const Key('workout_builder_save')));

// CORRECT — manual pattern
final widget = tester.widget<GestureDetector>(finder);
widget.onTap?.call();

// WRONG — silently misses off-screen widgets
await tester.tap(finder); // no-op if widget is outside viewport
```

**forui FHeaderAction exception:** `FHeaderAction` uses `FTappable` internally, not `GestureDetector`. The `tapOffScreen()` helper won't work because it looks for `GestureDetector`. Instead, invoke `onPress` directly:

```dart
// CORRECT — FHeaderAction uses onPress, not onTap
final action = tester.widget<FHeaderAction>(finder);
action.onPress?.call();

// WRONG — FHeaderAction wraps FTappable, not GestureDetector
tapOffScreen(tester, finder); // Fails: no GestureDetector ancestor
```

### 5. Fail fast with diagnostics

Add `reason:` to expect calls. For navigation tests, print widget types on screen before critical assertions.

```dart
// CORRECT
expect(find.text('Create Workout'), findsOneWidget,
    reason: 'Should navigate to workout builder after tapping FAB');

// WRONG — "Expected 1, found 0" gives no debugging context
expect(find.text('Create Workout'), findsOneWidget);
```

### 6. pumpWidget inside runAsync

`pumpWidget()` must be called INSIDE `tester.runAsync()`. Calling it outside leaves pending KeepAlive timers from forui widgets that cause test failures.

```dart
// CORRECT — pumpWidget inside runAsync
await tester.runAsync(() async {
  await tester.pumpWidget(app);
  await Future.delayed(const Duration(seconds: 3));
  await tester.pump();
});

// WRONG — pending timer failures from forui KeepAlive
await tester.pumpWidget(app);
await tester.runAsync(() async {
  await Future.delayed(const Duration(seconds: 3));
  await tester.pump();
});
```

### 7. pump(Duration) for route animations

GoRouter `push()` triggers route transition animations that require `pump(Duration)` to complete. `go()` replaces the route stack without animation and only needs `pump()`.

```dart
// After push() — needs pump(Duration) for animation
context.push('/workout/builder');
await tester.pump(const Duration(seconds: 1));

// After go() — no animation, just pump()
context.go('/');
await tester.pump();
```

Without `pump(Duration)` after `push()`, you get a route lifecycle assertion error because the transition animation is still in progress.

## Test Helpers (`test/test_utils/test_helpers.dart`)

| Helper | Use |
|---|---|
| `safeTap(tester, finder)` | expect + tap — never silently skip |
| `tapByKey(tester, key)` | find by Key + expect + tap |
| `tapOffScreen(tester, finder)` | invoke onTap directly for off-screen widgets |
| `waitForWidget(tester, finder)` | poll with fail-after-timeout |

## Prerequisites

- Backend running at `localhost:8080` with `TEST_MODE=true`
- Start with: `./dev.sh` or `docker compose up`
- Run with: `./run_e2e_tests.sh` from project root (handles DB reset)

## Test Infrastructure

All E2E tests share the same setup pattern:

```dart
setUpAll(() async {
  await IntegrationTestSetup.waitForBackend();   // Poll /health
  await IntegrationTestSetup.resetDatabase();     // POST /test/reset
  await IntegrationTestSetup.authenticateTestUser(); // Login → JWT token
});

setUp(() {
  IntegrationTestSetup.restoreTokenProvider(); // Re-set token (app overrides it)
});
```

Auth is handled by overriding `authProvider` with a `MockAuth` that returns the real JWT token — the backend is real, only the auth UI is bypassed.

Async pattern: All tests use `tester.runAsync()` with `Future.delayed` for timing since real network calls don't work with `pumpAndSettle()`.

## Test Data Helpers (`test_utils/test_data.dart`)

| Helper | What it creates |
|---|---|
| `createTestWorkout()` | Empty workout template |
| `createWorkoutWithExercise()` | Workout + 1 section + 1 exercise + 2 target sets |
| `createWorkoutWithRestDuration()` | Workout + 1 exercise + 2 target sets with rest duration |
| `createWorkoutWithRestItem()` | Workout + 1 exercise + 1 rest item |
| `startSession()` | Live session from a workout template |
| `abandonAnyActiveSession()` | Cleanup: abandons all in-progress sessions |

## E2E Test Tags

Tests are tagged by feature area. Run a subset with `--tags`:

```bash
flutter test test/e2e/ --tags session
```

| Tag | Test File |
|---|---|
| `session` | `session_flow_test.dart` |
| `workout` | `workout_builder_ui_test.dart`, `workout_flow_test.dart` |
| `program` | `program_builder_ui_test.dart` |
| `progress` | `progress_screen_test.dart` |
| `profile` | `profile_screen_test.dart` |
| `calendar` | `calendar_screen_test.dart` |
| `misc` | `exercise_library_test.dart` |

Note: there are no `tracker`, `exercise`, or `tools` tags.
