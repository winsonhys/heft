# Testing Patterns

**Analysis Date:** 2026-03-10

## Backend Testing (Go)

### Test Framework

**Runner:**
- Go's built-in `testing` package
- Config: `Makefile` with test commands

**Assertion Library:**
- `github.com/stretchr/testify` (v1.9.0)
- Used for `assert`, `require`, and test suite patterns

**Run Commands:**
```bash
make test              # Run all tests (unit + integration)
make test-unit        # Fast unit tests only (no database)
make test-integration # Integration tests (requires Docker)
make test-coverage    # Generate HTML coverage report
make test-race        # Run with race detector
```

### Unit Tests

**Location:**
- Co-located with source: `{package}/{name}_test.go`
- Example: `internal/handlers/user_test.go` tests `user.go`

**Package Convention:**
- Use `package_test` suffix to test from outside the package (recommended)
- Examples: `handlers_test`, `middleware_test`

**Test Structure Pattern:**

```go
// file: internal/handlers/user_test.go
package handlers_test

import (
    "context"
    "testing"

    "connectrpc.com/connect"

    heftv1 "github.com/heftyback/gen/heft/v1"
    "github.com/heftyback/internal/handlers"
    "github.com/heftyback/internal/testutil"
)

func TestUserHandler_GetProfile(t *testing.T) {
    tests := []struct {
        name        string
        userID      string
        withAuth    bool
        mockSetup   func(*testutil.MockUserRepository)
        wantErr     bool
        wantErrCode connect.Code
    }{
        {
            name:     "success - user found",
            userID:   "user-123",
            withAuth: true,
            mockSetup: func(m *testutil.MockUserRepository) {
                m.GetByIDFunc = func(ctx context.Context, id string) (*repository.User, error) {
                    return &repository.User{ID: id, Email: "test@example.com"}, nil
                }
            },
            wantErr: false,
        },
        {
            name:     "error - not authenticated",
            userID:   "",
            withAuth: false,
            mockSetup: func(m *testutil.MockUserRepository) {},
            wantErr:     true,
            wantErrCode: connect.CodeUnauthenticated,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockRepo := &testutil.MockUserRepository{}
            tt.mockSetup(mockRepo)

            handler := handlers.NewUserHandler(mockRepo)
            ctx := context.Background()
            if tt.withAuth {
                ctx = auth.ContextWithUserID(ctx, tt.userID)
            }

            req := connect.NewRequest(&heftv1.GetProfileRequest{})
            resp, err := handler.GetProfile(ctx, req)

            if tt.wantErr {
                require.Error(t, err)
                var connectErr *connect.Error
                require.True(t, errors.As(err, &connectErr))
                assert.Equal(t, tt.wantErrCode, connectErr.Code())
            } else {
                require.NoError(t, err)
                require.NotNil(t, resp)
                assert.Equal(t, tt.userID, resp.Msg.User.Id)
            }
        })
    }
}
```

**Key Patterns:**
- Table-driven tests using struct slice with subtests
- `t.Run(tt.name, func(t *testing.T) {...})` for named subtests
- Mock setup in closure: `mockSetup func(*MockRepo)`
- Context with user ID for auth: `auth.ContextWithUserID(ctx, userID)`
- Error type assertions: `var connectErr *connect.Error; errors.As(err, &connectErr)`

### Integration Tests

**Location:**
- Separate directory: `tests/integration/`
- File pattern: `{service}_service_test.go` (e.g., `user_service_test.go`)
- All 7 services tested: auth, user, exercise, workout, program, session, progress

**Test Isolation:**
- Uses `pgtestdb` library (github.com/peterldowns/pgtestdb v0.1.1)
- Each test gets an isolated PostgreSQL database
- Automatic migrations via `goosemigrator`
- Automatic cleanup after test completes

**Test Server Infrastructure:**

Located in `internal/testutil/`:
- `testdb.go` - Database setup with pgtestdb
- `testserver.go` - HTTP test server with all 7 service clients
- `mocks.go` - Mock repository implementations
- `fixtures.go` - Test data helpers

**Test Server Clients:**
```go
// Available on *testutil.TestServer
ts.AuthClient      // AuthService client
ts.UserClient      // UserService client
ts.ExerciseClient  // ExerciseService client
ts.WorkoutClient   // WorkoutService client
ts.ProgramClient   // ProgramService client
ts.SessionClient   // SessionService client
ts.ProgressClient  // ProgressService client
```

**AuthHeader Helper:**
```go
// Add JWT auth to request
req.Header().Set("Authorization", ts.AuthHeader(userID))
```

**Integration Test Pattern:**

```go
// file: tests/integration/user_service_test.go
package integration_test

import (
    "context"
    "testing"

    "connectrpc.com/connect"
    heftv1 "github.com/heftyback/gen/heft/v1"
    "github.com/heftyback/internal/testutil"
)

func TestUserService_Integration_GetProfile(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test in short mode")
    }

    // Create isolated test database
    pool := testutil.NewTestPool(t)

    // Create test server with all service clients
    ts := testutil.NewTestServer(t, pool)

    // Seed test data
    testUser := testutil.DefaultTestUser()
    userID := testutil.SeedTestUser(t, pool, testUser)

    t.Run("get existing user profile", func(t *testing.T) {
        ctx := context.Background()

        // Create request with JWT auth
        req := connect.NewRequest(&heftv1.GetProfileRequest{})
        req.Header().Set("Authorization", ts.AuthHeader(userID))

        resp, err := ts.UserClient.GetProfile(ctx, req)

        require.NoError(t, err)
        require.NotNil(t, resp)
        assert.Equal(t, userID, resp.Msg.User.Id)
        assert.Equal(t, testUser.Email, resp.Msg.User.Email)
    })

    t.Run("unauthenticated request returns error", func(t *testing.T) {
        ctx := context.Background()
        req := connect.NewRequest(&heftv1.GetProfileRequest{})
        // No auth header

        _, err := ts.UserClient.GetProfile(ctx, req)

        var connectErr *connect.Error
        require.True(t, errors.As(err, &connectErr))
        assert.Equal(t, connect.CodeUnauthenticated, connectErr.Code())
    })
}
```

**Key Patterns:**
- Skip if short mode: `if testing.Short() { t.Skip(...) }`
- Create fresh database: `pool := testutil.NewTestPool(t)`
- Create test server: `ts := testutil.NewTestServer(t, pool)`
- Seed test data: `userID := testutil.SeedTestUser(t, pool, testUser)`
- Add auth header: `req.Header().Set("Authorization", ts.AuthHeader(userID))`
- Assert Connect error codes: `connectErr.Code() == connect.CodeUnauth...`

### Mocking

**Framework:** Custom mock pattern in `internal/testutil/mocks.go`

**Mock Pattern:**

```go
// file: internal/testutil/mocks.go
type MockUserRepository struct {
    GetByIDFunc         func(ctx context.Context, id string) (*repository.User, error)
    UpdateProfileFunc   func(ctx context.Context, id string, displayName, avatarURL *string) (*User, error)
    LogWeightFunc       func(ctx context.Context, userID string, weightKg float64, loggedDate time.Time, notes *string) (*WeightLog, error)
    // ... more functions
}

// Compile-time interface compliance check
var _ repository.UserRepositoryInterface = (*MockUserRepository)(nil)

// Implement each interface method
func (m *MockUserRepository) GetByID(ctx context.Context, id string) (*repository.User, error) {
    return m.GetByIDFunc(ctx, id)
}

func (m *MockUserRepository) UpdateProfile(ctx context.Context, id string, displayName, avatarURL *string) (*User, error) {
    return m.UpdateProfileFunc(ctx, id, displayName, avatarURL)
}

// ... implement other methods
```

**Mock Usage in Tests:**

```go
func TestExample(t *testing.T) {
    mockRepo := &testutil.MockUserRepository{}

    // Set up behavior
    mockRepo.GetByIDFunc = func(ctx context.Context, id string) (*repository.User, error) {
        if id == "valid-id" {
            return &repository.User{ID: id, Email: "test@example.com"}, nil
        }
        return nil, nil  // Not found
    }

    // Use mock in handler
    handler := handlers.NewUserHandler(mockRepo)
    resp, err := handler.GetProfile(ctx, req)

    // Assertions
    require.NoError(t, err)
    assert.Equal(t, "valid-id", resp.Msg.User.Id)
}
```

**What to Mock:**
- Repository interface implementations (database calls)
- External service clients (if used)

**What NOT to Mock:**
- Handler logic (test actual behavior)
- Error conversion helpers
- Context manipulation

### Fixtures

**Location:** `internal/testutil/fixtures.go`

**Patterns:**

```go
// Default fixtures
func DefaultTestUser() *TestUser {
    return &TestUser{
        Email:       "test@example.com",
        DisplayName: "Test User",
        UsePounds:   false,
    }
}

// Seed data into database
func SeedTestUser(t *testing.T, pool *pgxpool.Pool, user *TestUser) string {
    // Insert and return ID
    return userID
}

// Create test workout
func SeedTestWorkout(t *testing.T, pool *pgxpool.Pool, userID, name string) string {
    // Insert and return workout ID
    return workoutID
}
```

**Coverage:**
- Requirements: Not formally enforced, but aim for > 80%
- View coverage: `make test-coverage` generates HTML report
- Critical paths: Auth, session handling, data mutations

---

## Frontend Testing (Dart/Flutter)

### Test Framework

**Runner:**
- Flutter's built-in test runner
- Config: `pubspec.yaml` dev dependencies

**Assertion Library:**
- `package:flutter_test` (included with Flutter SDK)
- Uses `expect(actual, matcher)` pattern

**Mocking:**
- `mockito` (v5.4.4) for code-generated mocks
- Custom mock notifiers for Riverpod testing

**Run Commands:**
```bash
flutter test                # Run all tests
flutter test --coverage     # Generate coverage report
flutter test test/unit/     # Run specific directory
```

### Widget Tests

**Location:**
- Co-located or in `test/widgets/` directory
- File pattern: `{widget_name}_test.dart`
- Examples: `tracker_screen_test.dart`, `workout_builder_screen_test.dart`

**Test Structure Pattern:**

```dart
// file: test/widgets/workout_builder_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hefty_chest/features/workout_builder/workout_builder_screen.dart';
import 'package:hefty_chest/features/workout_builder/providers/workout_builder_providers.dart';

/// Test notifier that provides controlled state without API calls
class TestWorkoutBuilder extends WorkoutBuilder {
  final WorkoutBuilderState initialState;

  TestWorkoutBuilder(this.initialState);

  @override
  WorkoutBuilderState build() => initialState;

  @override
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  @override
  Future<bool> saveWorkout() async {
    return true;
  }
}

/// Create test widget with provider overrides
Widget createTestWidget({
  required Widget child,
  WorkoutBuilderState? builderState,
}) {
  final state = builderState ?? const WorkoutBuilderState();
  return ProviderScope(
    overrides: [
      workoutBuilderProvider.overrideWith(() => TestWorkoutBuilder(state)),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('WorkoutBuilderScreen', () {
    testWidgets('renders Create mode when workoutId is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const WorkoutBuilderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assertions
      expect(find.text('Create Workout'), findsOneWidget);
      expect(find.text('Add Section'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('updates name when TextField is edited', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const WorkoutBuilderScreen(),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Leg Day');
      await tester.pumpAndSettle();

      expect(find.text('Leg Day'), findsOneWidget);
    });
  });
}
```

**Key Patterns:**
- Custom test notifier extending provider notifier
- Provider overrides in `ProviderScope`
- `tester.pumpWidget()` to render widget
- `tester.pumpAndSettle()` to wait for animations
- `tester.enterText()` to simulate user input
- `find.byType()`, `find.text()`, `find.byIcon()` for widget finding

### Provider Integration Tests

**Location:**
- `test/integration/providers/` directory
- File pattern: `{provider_name}_test.dart`
- Examples: `auth_provider_test.dart`, `session_provider_test.dart`

**Test Infrastructure:**

Located in `test/test_utils/`:
- `test_setup.dart` - Backend setup, auth helpers
- `test_data.dart` - Test data creation/cleanup

**Test Setup Pattern:**

```dart
// file: test/test_utils/test_setup.dart
class IntegrationTestSetup {
  // Wait for backend to be ready
  static Future<void> waitForBackend() async {
    // Polls backend health endpoint with timeout
  }

  // Reset database state
  static Future<void> resetDatabase() async {
    // Calls /test/reset endpoint on backend
  }

  // Authenticate test user
  static Future<void> authenticateTestUser() async {
    // Logs in test user and sets auth state
  }

  // Create Riverpod container for testing
  static ProviderContainer createContainer() {
    return ProviderContainer();
  }

  // Get test user ID
  static String get testUserId => _testUserId;
}
```

**Integration Test Pattern:**

```dart
// file: test/integration/providers/auth_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hefty_chest/features/auth/providers/auth_providers.dart';
import '../../test_utils/test_setup.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await IntegrationTestSetup.waitForBackend();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    container = IntegrationTestSetup.createContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthService Integration', () {
    test('login creates new user and returns token', () async {
      final authNotifier = container.read(authProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final email = 'test-${DateTime.now().millisecondsSinceEpoch}@example.com';
      final success = await authNotifier.login(email);

      expect(success, isTrue);
      expect(container.read(authProvider).isAuthenticated, isTrue);
      expect(container.read(authProvider).token, isNotEmpty);
    });

    test('login fails with invalid email', () async {
      final authNotifier = container.read(authProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await authNotifier.login('invalid-email');

      expect(success, isFalse);
      expect(container.read(authProvider).error, isNotNull);
    });
  });
}
```

**Key Patterns:**
- `setUpAll()` for one-time setup (backend health check)
- `setUp()` creates fresh container for each test
- `tearDown()` disposes container
- `container.read(provider)` to read current state
- `container.read(provider.notifier)` to get notifier for mutations
- Unique test data (email with timestamp) to avoid collisions

### Auto-Dispose Provider Testing

**Critical Pattern - Keep providers alive during async operations:**

```dart
test('async operation with auto-dispose provider', () async {
  // Auto-dispose providers are garbage collected after no listeners
  // Use container.listen() to keep alive during test

  final subscription = container.listen(
    myAutoDisposeProvider,
    (previous, next) {},  // Optional callback
  );

  try {
    final notifier = container.read(myAutoDisposeProvider.notifier);
    await notifier.someAsyncMethod();

    // Assertions
    expect(container.read(myAutoDisposeProvider).hasData, isTrue);
  } finally {
    subscription.close();
  }
});
```

**Why This Matters:**
- Default `@riverpod` generates auto-dispose providers
- Unused providers are garbage collected
- During `await`, the provider may be collected before the operation completes
- Without `listen()`, the provider may throw "provider was disposed" error
- Always use `listen()` for auto-dispose providers in async tests

### Mocking

**Pattern - Custom test notifiers:**

```dart
class TestSessionProvider extends SessionNotifier {
  final SessionState initialState;

  TestSessionProvider(this.initialState);

  @override
  SessionState build() => initialState;

  @override
  Future<void> startSession(String workoutId) async {
    // Test implementation without API calls
    state = state.copyWith(
      sessionId: 'test-session-123',
      isLoading: false,
    );
  }
}

// Use in test
final container = ProviderContainer(
  overrides: [
    sessionProvider.overrideWith(
      () => TestSessionProvider(initialState),
    ),
  ],
);
```

**Mockito Pattern (less common, for complex mocks):**

```dart
import 'package:mockito/mockito.dart';

class MockUserRepository extends Mock implements UserRepository {}

test('example with mockito', () {
  final mockRepo = MockUserRepository();

  when(mockRepo.getUser('user-1')).thenAnswer(
    (_) async => User(id: 'user-1', name: 'Test User'),
  );

  expect(await mockRepo.getUser('user-1'), isNotNull);
});
```

**What to Mock:**
- API clients (via provider overrides)
- Shared preferences (use mock initial values)
- Platform channels (if used)

**What NOT to Mock:**
- Riverpod logic itself
- State management (test actual notifiers)
- Dart SDK libraries

### Fixtures and Test Data

**Location:** `test/test_utils/test_data.dart`

**Patterns:**

```dart
class TestData {
  /// Create a test workout with unique name
  static Future<String> createTestWorkout({
    String? name,
    String? userId,
  }) async {
    final workoutName = name ?? 'Test Workout ${DateTime.now().millisecondsSinceEpoch}';
    // Call API to create workout
    return workoutId;
  }

  /// Create workout with exercise section
  static Future<String> createWorkoutWithExercise({
    String? userId,
  }) async {
    final workoutId = await createTestWorkout();
    // Add exercise to workout
    return workoutId;
  }

  /// Start a session from workout
  static Future<String> startSession({
    required String workoutTemplateId,
    String? userId,
  }) async {
    // Call SessionService.startSession
    return sessionId;
  }

  /// Clean up: delete workout
  static Future<void> deleteWorkout(String workoutId) async {
    // Call API to delete
  }

  /// Clean up: abandon session
  static Future<void> abandonSession(String sessionId) async {
    // Call API to abandon
  }
}
```

**Usage in Tests:**

```dart
test('create and use workout', () async {
  final workoutId = await TestData.createTestWorkout(
    name: 'Test Leg Day',
  );

  try {
    // Use workout
    final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

    // Test session operations
  } finally {
    // Clean up
    await TestData.abandonSession(sessionId);
    await TestData.deleteWorkout(workoutId);
  }
});
```

### Coverage

**Requirements:** Not formally enforced

**View Coverage:**
```bash
flutter test --coverage
# Generates coverage/lcov.info
```

**Critical Paths to Test:**
- Auth flow (login, logout, persistence)
- Session creation and sync
- Provider state mutations
- Error handling and UI feedback

---

## E2E Tests (Dart/Flutter)

**Location:** `test/e2e/`

**Examples:**
- `workout_flow_test.dart` - Full workflow: create workout, start session, track
- `session_flow_test.dart` - Session operations: start, sync, finish

**Pattern:**

```dart
void main() {
  late ProviderContainer container;

  setUpAll(() async {
    await IntegrationTestSetup.waitForBackend();
    await IntegrationTestSetup.resetDatabase();
    await IntegrationTestSetup.authenticateTestUser();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    container = IntegrationTestSetup.createContainer();
  });

  group('E2E - Workout Flow', () {
    test('complete flow: create workout, start session, track', () async {
      // 1. Create workout
      final workoutId = await TestData.createTestWorkout();

      // 2. Start session
      final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

      // 3. Read session from provider
      final session = container.read(sessionProvider(sessionId)).value;
      expect(session, isNotNull);
      expect(session!.workoutTemplateId, equals(workoutId));

      // 4. Sync completed sets
      final notifier = container.read(sessionProvider(sessionId).notifier);
      await notifier.updateSetCompletion(exerciseId, setId, true);

      // 5. Finish session
      await notifier.finishSession(notes: 'Great workout');

      // Cleanup
      await TestData.deleteWorkout(workoutId);
    });
  });
}
```

---

## Running Tests

### Backend

```bash
# All tests (requires Docker)
cd HeftyBack && docker compose up -d && make test

# Unit tests only (no Docker needed, fast)
make test-unit

# Integration tests
make test-integration

# With race detection
make test-race

# Coverage report
make test-coverage
# Open coverage/coverage.html
```

### Frontend

```bash
# All tests
cd hefty_chest && flutter test

# Specific test file
flutter test test/widgets/workout_builder_screen_test.dart

# Watch mode (with file watcher)
flutter test --watch

# With coverage
flutter test --coverage

# Integration tests (from project root)
./run_e2e_tests.sh
```

---

## Test Organization Summary

| Test Type | Backend | Frontend |
|-----------|---------|----------|
| Unit Tests | `internal/handlers/*_test.go` | `test/widgets/` or co-located |
| Integration Tests | `tests/integration/*_test.go` with pgtestdb | `test/integration/providers/` |
| E2E Tests | N/A (full stack via integration tests) | `test/e2e/` |
| Mocking | Custom pattern in `testutil/` | Custom notifiers + Mockito |
| Test Data | Fixtures in `testutil/fixtures.go` | Helpers in `test/test_utils/test_data.dart` |
| Coverage | `make test-coverage` | `flutter test --coverage` |

---

*Testing analysis: 2026-03-10*
