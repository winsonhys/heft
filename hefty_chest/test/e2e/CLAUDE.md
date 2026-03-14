# E2E Tests

Full end-to-end tests that run the real `HeftyChestApp` against a live backend (Docker Compose).

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

## Flow: workout_flow_test.dart

Home screen and navigation tests. No session mutation.

1. **Home screen renders** — app title "Heft", subtitle "Ready to crush your workout?"
2. **My Workouts section** — section header visible
3. **Workout list from backend** — creates workout via API, verifies it appears in list
4. **Loading indicator** — `FProgress` shown before data loads
5. **Quick stats row** — "Workouts", "This Week", "Day Streak" labels
6. **FAB displayed** — add icon for creating new workout
7. **FAB → workout builder** — tapping FAB navigates to "Create Workout" screen
8. **Bottom nav bar** — home, bar_chart, calendar, person icons present
9. **Bottom nav → Progress** — tapping chart icon shows Progress screen
10. **Bottom nav → Profile** — tapping person icon shows Profile screen
11. **Bottom nav → Calendar** — tapping calendar icon shows Calendar screen
12. **Workout card actions** — card shows "Start" button
13. **Empty state** — "No workouts yet" or "My Workouts" shown when list empty

## Flow: session_flow_test.dart

### Session Flow group

Workout session lifecycle — start, track, navigate, persist.

1. **Start session from card** — tap "Start" on workout card → navigates to tracker
2. **Tracker shows exercise info** — start session via API, resume into tracker, verify Scaffold renders
3. **Complete workout** — start session from card, verify tracker loads (skeletal — no full completion via UI)
4. **Tracker set completion UI** — start session, navigate to tracker, verify Scaffold renders
5. **Navigate back from tracker** — tap back chevron → returns to home ("Heft" visible)
6. **Session data persists** — start session via API, complete a set via `syncSession`, verify `isCompleted` via `getSession`

### Session Interaction E2E group

Core workout interaction loop — UI-level text entry, set completion, rest timer, progress tracking.

1. **Enter weight/reps, complete set** — enter "60" kg and "8" reps via FTextField, tap completion circle → check icon appears
2. **Rest timer appears** — complete set on workout with rest duration → RestTimerSheet shows with countdown "1:00" and "Skip" button
3. **Rest timer next exercise info** — complete first set → rest timer shows "Next: {exercise} - Set 2"
4. **Complete all sets, verify progress** — complete both sets → ProgressHeader shows "2 / 2 sets" and "100% complete"

### Rest Items E2E group

Rest item interactions within a session.

1. **Rest items display** — tracker shows "Rest" label, "1:00" duration, "Start Timer" and "Skip" buttons
2. **Skip rest item** — tap "Skip" → shows check icon and undo icon (completed state)
3. **Start rest timer** — tap "Start Timer" → button changes to "Done", shows "Time remaining"
4. **Rest completion persists** — complete rest via `syncSession` API, verify `isCompleted` and `completedAt` via `getSession`
5. **Undo completed rest** — complete via API, tap undo icon → "Start Timer" reappears
6. **Full session flow with rest** — API-driven: start session → sync all sets + rest items → finish session → verify `WORKOUT_STATUS_COMPLETED` in history

### Progress Update E2E group

1. **Completing session updates stats** — get initial `totalWorkouts` count, complete a full session (sync all sets + finish), verify count incremented by 1
