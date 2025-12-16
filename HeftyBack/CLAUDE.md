# HeftyBack - Go Backend API

## Tech Stack

| Component | Technology |
|-----------|------------|
| Language | Go 1.23 |
| API Framework | Connect-RPC (connectrpc.com/connect v1.16.0) |
| Database | PostgreSQL via Supabase |
| DB Driver | pgx v5 (github.com/jackc/pgx/v5) |
| Migrations | Goose (pressly/goose/v3) |
| Testing | testify, pgtestdb |
| Proto Tool | Buf CLI |

## Project Structure

```
HeftyBack/
├── cmd/
│   └── server/
│       └── main.go              # Entry point
├── internal/
│   ├── auth/                    # JWT authentication
│   │   ├── jwt.go               # JWT token generation/validation
│   │   ├── jwt_test.go
│   │   └── context.go           # Auth context helpers
│   ├── config/
│   │   └── config.go            # Environment configuration
│   ├── db/
│   │   └── db.go                # Database connection pool
│   ├── handlers/                # Service implementations
│   │   ├── auth.go              # AuthService handler
│   │   ├── auth_test.go
│   │   ├── user.go              # UserService handler
│   │   ├── user_test.go
│   │   ├── exercise.go          # ExerciseService handler
│   │   ├── exercise_test.go
│   │   ├── workout.go           # WorkoutService handler
│   │   ├── workout_test.go
│   │   ├── program.go           # ProgramService handler
│   │   ├── program_test.go
│   │   ├── session.go           # SessionService handler
│   │   ├── session_test.go
│   │   ├── progress.go          # ProgressService handler
│   │   └── progress_test.go
│   ├── repository/              # Data access layer
│   │   ├── interfaces.go        # Repository interfaces
│   │   ├── auth.go
│   │   ├── user.go
│   │   ├── exercise.go
│   │   ├── workout.go
│   │   ├── program.go
│   │   ├── session.go
│   │   └── progress.go
│   ├── middleware/
│   │   ├── logging.go           # Request logging
│   │   ├── auth.go              # JWT auth interceptor
│   │   └── auth_test.go
│   └── testutil/                # Test utilities
│       ├── mocks.go             # Mock implementations
│       ├── testdb.go            # Test database setup (pgtestdb)
│       ├── testserver.go        # Test HTTP server with all clients
│       └── fixtures.go          # Test data fixtures
├── proto/
│   └── heft/v1/                 # Protocol Buffer definitions
│       ├── common.proto
│       ├── auth.proto
│       ├── user.proto
│       ├── exercise.proto
│       ├── workout.proto
│       ├── program.proto
│       ├── session.proto
│       └── progress.proto
├── gen/
│   └── heft/v1/                 # Generated Go code
│       ├── *.pb.go              # Message types
│       └── *connect/*.go        # Connect handlers
├── migrations/
│   └── 00001_initial_schema.sql # Database schema
├── tests/
│   └── integration/             # Integration tests (all 7 services)
│       ├── auth_service_test.go
│       ├── user_service_test.go
│       ├── exercise_service_test.go
│       ├── workout_service_test.go
│       ├── program_service_test.go
│       ├── session_service_test.go
│       └── progress_service_test.go
├── docker-compose.yml           # Test PostgreSQL (port 5433)
├── Makefile                     # Build commands
├── buf.yaml                     # Buf configuration
├── buf.gen.yaml                 # Buf code generation
├── go.mod
└── .env.example
```

## Architecture

### Clean Architecture Pattern

```
HTTP Request
     │
     ▼
┌─────────────────────────────────────────┐
│           Connect-RPC Handler            │
│  (internal/handlers/*.go)               │
│  - Request validation                   │
│  - Business logic                       │
│  - Response mapping                     │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         Repository Interface            │
│  (internal/repository/interfaces.go)    │
│  - Defines data access contract         │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│       Repository Implementation         │
│  (internal/repository/*.go)             │
│  - SQL queries via pgx                  │
│  - Data mapping                         │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│            PostgreSQL                   │
│  (via Supabase)                         │
└─────────────────────────────────────────┘
```

### Dependency Injection

Dependencies are wired in `cmd/server/main.go`:

```go
// Load config
cfg := config.Load()

// Create database pool
pool, err := db.NewPool(ctx, cfg.DatabaseURL)

// Create repositories
userRepo := repository.NewUserRepository(pool)
exerciseRepo := repository.NewExerciseRepository(pool)
// ...

// Create handlers (inject repositories)
userHandler := handlers.NewUserHandler(userRepo)
exerciseHandler := handlers.NewExerciseHandler(exerciseRepo)
// ...

// Register Connect-RPC services
mux.Handle(heftv1connect.NewUserServiceHandler(userHandler))
mux.Handle(heftv1connect.NewExerciseServiceHandler(exerciseHandler))
// ...
```

## Services

### AuthService
- `Register(email, password)` → New user with JWT token
- `Login(email, password)` → JWT token pair (access + refresh)
- `RefreshToken(refresh_token)` → New access token
- `Logout(refresh_token)` → Success

### UserService
- `GetProfile(user_id)` → User profile data
- `UpdateProfile(user_id, display_name, avatar_url)` → Updated profile
- `UpdateSettings(user_id, use_pounds, rest_timer_seconds)` → Updated settings
- `LogWeight(user_id, weight_kg, date, notes)` → Weight log entry
- `GetWeightHistory(user_id, pagination)` → List of weight logs
- `DeleteWeightLog(user_id, log_id)` → Success

### ExerciseService
- `ListExercises(user_id, category_id, exercise_type, pagination)` → Exercise list
- `GetExercise(exercise_id)` → Single exercise
- `CreateExercise(user_id, name, category_id, type, description)` → New exercise
- `ListCategories()` → All categories
- `SearchExercises(query, limit)` → Matching exercises

### WorkoutService
- `ListWorkouts(user_id, pagination)` → Workout templates
- `GetWorkout(workout_id)` → Full workout with sections/sets
- `CreateWorkout(user_id, name, description)` → New template
- `DeleteWorkout(workout_id)` → Success
- `AddSection(workout_id, name, is_superset)` → New section
- `AddSectionItem(section_id, exercise_id | rest_duration)` → New item
- `AddTargetSet(item_id, weight, reps, time, distance)` → New target set

### ProgramService
- `ListPrograms(user_id, pagination)` → Training programs
- `GetProgram(program_id)` → Full program with days
- `CreateProgram(user_id, name, duration_weeks)` → New program
- `AssignWorkout(program_id, day_number, workout_id)` → Updated day
- `SetActiveProgram(user_id, program_id)` → Success
- `GetActiveProgram(user_id)` → Current active program
- `DeleteProgram(program_id)` → Success

### SessionService
- `StartSession(user_id, workout_template_id, program_id?)` → New session
- `GetSession(session_id)` → Session with exercises/sets
- `AddExercise(session_id, exercise_id)` → New session exercise
- `CompleteSet(set_id, weight, reps, time, distance, rpe)` → Updated set
- `UpdateSet(set_id, ...)` → Updated set
- `FinishSession(session_id, notes)` → Completed session
- `AbandonSession(session_id)` → Abandoned session
- `ListSessions(user_id, pagination)` → Session history

### ProgressService
- `GetDashboard(user_id)` → Overview stats
- `GetWeeklyActivity(user_id, week_start)` → Weekly calendar
- `GetPersonalRecords(user_id, pagination)` → PRs list
- `GetExerciseProgress(user_id, exercise_id)` → Exercise-specific progress
- `GetStreak(user_id)` → Current workout streak

## Commands (Makefile)

```bash
# Code Generation
make generate           # Generate proto code via buf

# Build
make build             # Compile to bin/server
make clean             # Remove build artifacts

# Run
make run               # Start server

# Dependencies
make deps              # go mod download
make lint              # Lint proto files

# Database
make migrate-up        # Apply all migrations
make migrate-down      # Rollback last migration
make migrate-status    # Check migration status
make migrate-create name=xxx  # Create new migration

# Testing
make test              # All tests
make test-unit         # Unit tests only (no DB, uses -short)
make test-integration  # Integration tests (needs Docker)
make test-coverage     # Generate HTML coverage report
make test-race         # Run with race detector

# All-in-one
make setup             # deps + generate + build
```

## Testing

### Unit Tests

Located in `internal/handlers/*_test.go`. Pattern:

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
                    return nil, nil  // Not found returns nil, nil
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
            // ... test logic
        })
    }
}
```

Run: `make test-unit`

### Integration Tests

Located in `tests/integration/`. Uses **pgtestdb** for isolated test databases with automatic cleanup.

**Test Infrastructure:**
- `pgtestdb` + `goosemigrator` - Creates fresh isolated database per test
- `TestServer` - HTTP test server with all 7 service clients
- JWT auth support via `AuthHeader(userID)` helper
- Fixtures for seeding test data

**Pattern:**

```go
func TestUserService_Integration_GetProfile(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test in short mode")
    }

    pool := testutil.NewTestPool(t)       // Fresh isolated database
    ts := testutil.NewTestServer(t, pool) // HTTP server with all services

    // Seed test data with unique email
    testUser := testutil.DefaultTestUser()
    userID := testutil.SeedTestUser(t, pool, testUser)

    t.Run("get existing user profile", func(t *testing.T) {
        ctx := context.Background()

        req := connect.NewRequest(&heftv1.GetProfileRequest{})
        req.Header().Set("Authorization", ts.AuthHeader(userID))  // JWT auth

        resp, err := ts.UserClient.GetProfile(ctx, req)

        if err != nil {
            t.Fatalf("unexpected error: %v", err)
        }
        if resp.Msg.User.Id != userID {
            t.Errorf("expected user ID %s, got %s", userID, resp.Msg.User.Id)
        }
    })

    t.Run("unauthenticated request returns error", func(t *testing.T) {
        ctx := context.Background()
        req := connect.NewRequest(&heftv1.GetProfileRequest{})
        // No auth header

        _, err := ts.UserClient.GetProfile(ctx, req)

        var connectErr *connect.Error
        if errors.As(err, &connectErr) && connectErr.Code() != connect.CodeUnauthenticated {
            t.Errorf("expected Unauthenticated error, got %v", connectErr.Code())
        }
    })
}
```

**TestServer clients available:**
- `ts.AuthClient` - AuthService
- `ts.UserClient` - UserService
- `ts.ExerciseClient` - ExerciseService
- `ts.WorkoutClient` - WorkoutService
- `ts.ProgramClient` - ProgramService
- `ts.SessionClient` - SessionService
- `ts.ProgressClient` - ProgressService

**Run:** `docker compose up -d && make test-integration`

### Mock Pattern

Mocks in `internal/testutil/mocks.go`:

```go
type MockUserRepository struct {
    GetProfileFunc    func(ctx context.Context, userID string) (*repository.UserProfile, error)
    UpdateProfileFunc func(ctx context.Context, userID string, params repository.UpdateProfileParams) error
    // ... other functions
}

// Compile-time interface check
var _ repository.UserRepositoryInterface = (*MockUserRepository)(nil)

func (m *MockUserRepository) GetProfile(ctx context.Context, userID string) (*repository.UserProfile, error) {
    return m.GetProfileFunc(ctx, userID)
}
```

## Database Schema

### Core Tables

**Users & Profile:**
- `users` - id, email, password_hash, display_name, avatar_url, use_pounds, rest_timer_seconds
- `weight_logs` - user_id, weight_kg, logged_date, notes

**Exercise Library:**
- `exercise_categories` - id, name, display_order
- `exercises` - id, name, category_id, exercise_type, is_system, created_by, description

**Workout Templates:**
- `workout_templates` - id, user_id, name, description, total_exercises, total_sets, estimated_duration
- `workout_sections` - workout_template_id, name, display_order, is_superset
- `section_items` - section_id, item_type (exercise|rest), exercise_id, rest_duration, display_order
- `exercise_target_sets` - section_item_id, set_number, target_weight, target_reps, target_time, target_distance

**Training Programs:**
- `programs` - id, user_id, name, duration_weeks, is_active, is_archived
- `program_days` - program_id, day_number, day_type (workout|rest|unassigned), workout_template_id

**Workout Sessions:**
- `workout_sessions` - id, user_id, workout_template_id, status (in_progress|completed|abandoned), started_at, completed_at
- `session_exercises` - session_id, exercise_id, display_order
- `session_sets` - session_exercise_id, set_number, weight_kg, reps, is_completed, rpe

**Progress Tracking:**
- `personal_records` - user_id, exercise_id, weight_kg, reps, one_rep_max_kg, achieved_at
- `exercise_history` - user_id, exercise_id, session_id, session_date, best_weight, total_volume

### Exercise Types (enum)
- `weight_reps` - Barbell/dumbbell exercises
- `bodyweight_reps` - Push-ups, pull-ups, etc.
- `time` - Planks, holds
- `distance` - Running, rowing
- `cardio` - General cardio

## Code Patterns

### Repository Interface Pattern

```go
// interfaces.go
type UserRepositoryInterface interface {
    GetProfile(ctx context.Context, userID string) (*UserProfile, error)
    UpdateProfile(ctx context.Context, userID string, params UpdateProfileParams) error
    // ...
}

// user.go
type UserRepository struct {
    pool *pgxpool.Pool
}

var _ UserRepositoryInterface = (*UserRepository)(nil)  // Compile-time check

func NewUserRepository(pool *pgxpool.Pool) *UserRepository {
    return &UserRepository{pool: pool}
}

func (r *UserRepository) GetProfile(ctx context.Context, userID string) (*UserProfile, error) {
    var profile UserProfile
    err := r.pool.QueryRow(ctx, `
        SELECT id, email, display_name, avatar_url, use_pounds, rest_timer_seconds, member_since
        FROM users WHERE id = $1
    `, userID).Scan(&profile.ID, &profile.Email, ...)

    if errors.Is(err, pgx.ErrNoRows) {
        return nil, nil  // Not found = nil, nil (not an error)
    }
    return &profile, err
}
```

### Error Handling Pattern

```go
func (h *UserHandler) GetProfile(ctx context.Context, req *connect.Request[heftv1.GetProfileRequest]) (*connect.Response[heftv1.GetProfileResponse], error) {
    // Validation
    if req.Msg.UserId == "" {
        return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("user_id is required"))
    }

    // Repository call
    profile, err := h.repo.GetProfile(ctx, req.Msg.UserId)
    if err != nil {
        return nil, connect.NewError(connect.CodeInternal, err)
    }
    if profile == nil {
        return nil, connect.NewError(connect.CodeNotFound, errors.New("user not found"))
    }

    // Success
    return connect.NewResponse(&heftv1.GetProfileResponse{
        Profile: mapProfileToProto(profile),
    }), nil
}
```

### User Scoping Pattern

All queries include user_id for data isolation:

```go
// Good - scoped to user
err := r.pool.QueryRow(ctx, `
    SELECT * FROM workout_templates
    WHERE id = $1 AND user_id = $2
`, workoutID, userID).Scan(...)

// Bad - no user scoping (security risk)
err := r.pool.QueryRow(ctx, `
    SELECT * FROM workout_templates WHERE id = $1
`, workoutID).Scan(...)
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgres://user:pass@host:5432/db` |
| `SUPABASE_URL` | Supabase project URL | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | `eyJhbGc...` |
| `SUPABASE_SERVICE_KEY` | Supabase service role key | `eyJhbGc...` |
| `PORT` | Server port (default: 8080) | `8080` |

## Common Tasks

### Add New Endpoint

1. Define in `proto/heft/v1/service.proto`:
```protobuf
service MyService {
    rpc NewMethod(NewMethodRequest) returns (NewMethodResponse);
}

message NewMethodRequest {
    string user_id = 1;
    // ...
}

message NewMethodResponse {
    // ...
}
```

2. Generate code: `make generate`

3. Add repository method in `internal/repository/interfaces.go` and implementation

4. Implement handler in `internal/handlers/myservice.go`:
```go
func (h *MyHandler) NewMethod(ctx context.Context, req *connect.Request[heftv1.NewMethodRequest]) (*connect.Response[heftv1.NewMethodResponse], error) {
    // Implementation
}
```

5. Add tests in `internal/handlers/myservice_test.go`

### Add Database Migration

```bash
make migrate-create name=add_new_column
# Edit migrations/XXXX_add_new_column.sql
make migrate-up
```

Migration file format:
```sql
-- +goose Up
ALTER TABLE users ADD COLUMN new_column TEXT;

-- +goose Down
ALTER TABLE users DROP COLUMN new_column;
```
