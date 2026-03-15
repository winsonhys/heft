# Testing

## Backend Unit Tests

Located in `internal/handlers/*_test.go`. Use table-driven tests with mock repositories.

### Pattern

```go
func TestUserHandler_GetProfile(t *testing.T) {
    tests := []struct {
        name        string
        userID      string
        mockSetup   func(*testutil.MockUserRepository)
        wantErr     bool
        wantErrCode connect.Code
    }{
        {
            name:   "success",
            userID: "valid-uuid",
            mockSetup: func(m *testutil.MockUserRepository) {
                m.GetProfileFunc = func(ctx context.Context, userID string) (*repository.UserProfile, error) {
                    return &repository.UserProfile{ID: userID, DisplayName: "Test"}, nil
                }
            },
            wantErr: false,
        },
        {
            name:   "not found",
            userID: "missing-uuid",
            mockSetup: func(m *testutil.MockUserRepository) {
                m.GetProfileFunc = func(ctx context.Context, userID string) (*repository.UserProfile, error) {
                    return nil, nil
                }
            },
            wantErr:     true,
            wantErrCode: connect.CodeNotFound,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mock := &testutil.MockUserRepository{}
            tt.mockSetup(mock)
            handler := handlers.NewUserHandler(mock)
            // test logic...
        })
    }
}
```

Run: `make test-unit`

### Mock Pattern

Mocks live in `internal/testutil/mocks.go`:

```go
type MockUserRepository struct {
    GetProfileFunc    func(ctx context.Context, userID string) (*repository.UserProfile, error)
    UpdateProfileFunc func(ctx context.Context, userID string, params repository.UpdateProfileParams) error
}

var _ repository.UserRepositoryInterface = (*MockUserRepository)(nil)

func (m *MockUserRepository) GetProfile(ctx context.Context, userID string) (*repository.UserProfile, error) {
    return m.GetProfileFunc(ctx, userID)
}
```

## Backend Integration Tests

Located in `tests/integration/`. Use **pgtestdb** for isolated test databases with automatic cleanup.

### Infrastructure

- `pgtestdb` + `goosemigrator` → Fresh isolated database per test
- `TestServer` → HTTP test server with all 7 service clients
- JWT auth support via `AuthHeader(userID)` helper
- Fixtures in `internal/testutil/fixtures.go`

### Pattern

```go
func TestUserService_Integration(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test in short mode")
    }

    pool := testutil.NewTestPool(t)
    ts := testutil.NewTestServer(t, pool)

    testUser := testutil.DefaultTestUser()
    userID := testutil.SeedTestUser(t, pool, testUser)

    t.Run("get existing user profile", func(t *testing.T) {
        ctx := context.Background()
        req := connect.NewRequest(&heftv1.GetProfileRequest{})
        req.Header().Set("Authorization", ts.AuthHeader(userID))

        resp, err := ts.UserClient.GetProfile(ctx, req)
        if err != nil {
            t.Fatalf("unexpected error: %v", err)
        }
        if resp.Msg.User.Id != userID {
            t.Errorf("expected user ID %s, got %s", userID, resp.Msg.User.Id)
        }
    })
}
```

### Available Test Clients

- `ts.AuthClient`
- `ts.UserClient`
- `ts.ExerciseClient`
- `ts.WorkoutClient`
- `ts.ProgramClient`
- `ts.SessionClient`
- `ts.ProgressClient`

Run: `docker compose up -d && make test-integration`

### Test Reset Endpoint

When `TEST_MODE=true`: `POST /test/reset` clears all user data. Used by integration tests. **Never enabled in production.**

## Frontend Tests

### Widget Tests

Located in `test/widgets/`. Standard Flutter widget testing.

### Provider Contract Tests

Located in `test/integration/providers/`. Test providers against an in-memory fake backend
(`test/test_utils/fake_backend.dart`) using `FakeTransportBuilder`. No Docker or live backend needed.
Runs automatically in the Claude stop hook.

### Test Data Helpers (`test/test_utils/test_data.dart`)

```dart
final workoutId = await TestData.createTestWorkout(name: 'Test Workout');
final workoutId = await TestData.createWorkoutWithExercise();
final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

// Cleanup
await TestData.deleteWorkout(workoutId);
await TestData.abandonSession(sessionId);
```

### E2E Tests

Located in `test/e2e/`. Full user flow tests (workout creation → session tracking).

### Auto-Dispose Testing Rule

`@riverpod` providers auto-dispose by default. Keep alive during async operations:

```dart
final subscription = container.listen(myProvider, (_, __) {});
try {
  await container.read(myProvider.notifier).asyncMethod();
  // assertions...
} finally {
  subscription.close();
}
```

Without this, the provider disposes during `await`, causing null returns or disposal errors.

Run frontend tests: `flutter test`
Run e2e tests: `./run_e2e_tests.sh` (from project root)

## Test Commands Summary

```bash
# Backend
make test                  # All tests
make test-unit             # Unit only (fast, no DB)
make test-integration      # Integration (needs Docker)
make test-coverage         # HTML coverage report
make test-race             # Race condition detection

# Frontend
flutter test               # All tests
./run_e2e_tests.sh          # E2E (needs Docker, run from project root)
```

## E2E Test Patterns

E2E tests run the full `HeftyChestApp` against a live Docker backend. Located in `hefty_chest/test/e2e/`.

### Anti-Patterns (Banned)

**Silent skip guard** — test "passes" when widget doesn't render:
```dart
// BANNED — silently skips the tap if widget missing
if (finder.evaluate().isNotEmpty) {
  await tester.tap(finder);
}

// CORRECT — fails immediately with diagnostics
expect(finder, findsOneWidget, reason: 'Expected save icon');
await tester.tap(finder);
```

**Ambiguous finders for tappable widgets:**
```dart
// FRAGILE — breaks when duplicate save icons exist
await tester.tap(find.byIcon(Icons.save));

// ROBUST — unambiguous
await tester.tap(find.byKey(const Key('workout_builder_save')));
```

### GoRouter Navigation Timing

Navigation triggered inside `tester.runAsync()` doesn't complete until `tester.pump()` is called OUTSIDE `runAsync`:

```dart
await tester.runAsync(() async {
  await tester.tap(fab);
  await Future.delayed(const Duration(seconds: 2));
  await tester.pump();
});
// Navigation completes here
await tester.pump();
expect(find.text('Create Workout'), findsOneWidget);
```

### pumpWidget Placement

`pumpWidget()` must be called INSIDE `tester.runAsync()`. forui widgets use KeepAlive timers internally — calling `pumpWidget()` outside `runAsync` leaves these timers pending, causing test failures.

```dart
// CORRECT
await tester.runAsync(() async {
  await tester.pumpWidget(app);
  await Future.delayed(const Duration(seconds: 3));
  await tester.pump();
});

// WRONG — pending timer failures
await tester.pumpWidget(app);
await tester.runAsync(() async { ... });
```

### Route Animation Timing

GoRouter `push()` and `go()` have different pump requirements:

| Method | Animation | Pump Required |
|---|---|---|
| `context.go('/route')` | None (replaces stack) | `await tester.pump()` |
| `context.push('/route')` | Transition animation | `await tester.pump(const Duration(seconds: 1))` |

Without `pump(Duration)` after `push()`, the transition animation is still in progress and GoRouter throws a route lifecycle assertion.

### Off-Screen Widgets

FHeaderAction suffixes (save, discard, finish) render at x~975, outside the 800×600 test viewport. Invoke `onTap` directly:

```dart
final widget = tester.widget<GestureDetector>(finder);
widget.onTap?.call();
```

Or use the `tapOffScreen()` helper from `test/test_utils/test_helpers.dart`.

**forui FHeaderAction exception:** `FHeaderAction` uses `FTappable` internally, not `GestureDetector`. The `tapOffScreen()` helper won't find a `GestureDetector` ancestor. Instead, invoke `onPress` directly:

```dart
final action = tester.widget<FHeaderAction>(finder);
action.onPress?.call();
```

### Widget Keys for E2E

| Key | Widget | File |
|---|---|---|
| `home_fab` | Home FAB | `home_screen.dart` |
| `calendar_add_program` | Calendar add icon | `calendar_screen.dart` |
| `workout_builder_save` | Save icon | `workout_builder_screen.dart` |
| `program_builder_save` | Save icon | `program_builder_screen.dart` |
| `tracker_discard` | Discard button | `tracker_screen.dart` |
| `tracker_finish` | Finish button | `tracker_screen.dart` |
| `workout_card_start` | Start button | `workout_card.dart` |
| `workout_card_edit` | Edit button | `workout_card.dart` |
| `tracker_back` | Back button | `tracker_screen.dart` |

### E2E Test Tags

Tests are tagged by feature area. Run a subset with `--tags`:

```bash
flutter test test/e2e/ --tags session
```

| Tag | Test File(s) |
|---|---|
| `session` | `session_flow_test.dart` |
| `workout` | `workout_builder_ui_test.dart`, `workout_flow_test.dart` |
| `program` | `program_builder_ui_test.dart` |
| `progress` | `progress_screen_test.dart` |
| `profile` | `profile_screen_test.dart` |
| `calendar` | `calendar_screen_test.dart` |
| `misc` | `exercise_library_test.dart` |

Note: there are no `tracker`, `exercise`, or `tools` tags.
