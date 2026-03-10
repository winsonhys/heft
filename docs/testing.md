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

### Provider Integration Tests

Located in `test/integration/providers/`. Test each provider against a real backend.

```dart
setUpAll(() async {
  await IntegrationTestSetup.waitForBackend();
  await IntegrationTestSetup.resetDatabase();
  await IntegrationTestSetup.authenticateTestUser();
});

final container = IntegrationTestSetup.createContainer();
final userId = IntegrationTestSetup.testUserId;
```

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

Located in `test/integration/e2e/`. Full user flow tests (workout creation → session tracking).

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
Run integration tests: `./scripts/run_integration_tests.sh`

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
./scripts/run_integration_tests.sh  # Integration (needs Docker)
```
