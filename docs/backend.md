# Backend Reference

Detailed reference for HeftyBack. For quick rules, see `HeftyBack/CLAUDE.md`.

## Project Structure

```
HeftyBack/
├── cmd/server/main.go              # Entry point, DI wiring
├── internal/
│   ├── auth/
│   │   ├── jwt.go                  # JWT token generation/validation
│   │   ├── jwt_test.go
│   │   └── context.go              # Auth context helpers (UserIDFromContext)
│   ├── config/config.go            # Environment configuration
│   ├── db/db.go                    # Database connection pool
│   ├── handlers/                   # Service implementations
│   │   ├── errors.go               # handleDBError, isUserFKViolation
│   │   ├── auth.go                 # AuthService
│   │   ├── user.go                 # UserService
│   │   ├── exercise.go             # ExerciseService
│   │   ├── workout.go              # WorkoutService
│   │   ├── program.go              # ProgramService
│   │   ├── session.go              # SessionService
│   │   ├── progress.go             # ProgressService
│   │   └── *_test.go               # Unit tests for each
│   ├── repository/                 # Data access layer
│   │   ├── interfaces.go           # All repository interfaces
│   │   ├── auth.go, user.go, ...   # Implementations
│   ├── middleware/
│   │   ├── auth.go                 # JWT interceptor
│   │   ├── auth_test.go
│   │   └── logging.go              # Request logging
│   └── testutil/
│       ├── mocks.go                # Mock repository implementations
│       ├── testdb.go               # pgtestdb setup
│       ├── testserver.go           # HTTP test server with all clients
│       └── fixtures.go             # Test data seeding
├── proto/heft/v1/*.proto           # Proto definitions
├── gen/heft/v1/                    # Generated Go code (never edit)
├── migrations/                     # SQL migrations (goose)
├── tests/integration/              # Integration tests
├── docker-compose.yml              # PostgreSQL (port 5433)
├── Makefile                        # Build commands
└── .env.example                    # Environment template
```

## Services API

### AuthService
- `Login(email)` → JWT token + user (creates new user if doesn't exist)

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
- `ListWorkouts(pagination)` → Workout templates
- `GetWorkout(workout_id)` → Full workout with sections/sets
- `CreateWorkout(name, description)` → New template
- `UpdateWorkout(workout_id, name, description, sections)` → Updated workout
- `DuplicateWorkout(workout_id, new_name?)` → Copy with new ID
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
- `StartSession(workout_template_id, program_id?)` → New session (409 if active session exists)
- `GetSession(session_id)` → Session with exercises/sets
- `SyncSession(session_id, sets, exercises, deleted_set_ids, deleted_exercise_ids)` → Synced
  - `sets`: `SyncSetInput` using oneof (`existing_set_id` OR `new_set`)
  - `exercises`: New exercises (with `superset_id` support)
- `FinishSession(session_id, notes)` → Completed session
- `AbandonSession(session_id)` → Abandoned session
- `ListSessions(pagination)` → Session history

### ProgressService
- `GetDashboardStats()` → Overview (total workouts, streak, etc.)
- `GetCalendarMonth(year, month)` → Monthly activity
- `GetWeeklyActivity(week_start)` → Weekly calendar
- `GetPersonalRecords(pagination)` → PRs list
- `GetExerciseProgress(exercise_id)` → Exercise-specific progress
- `GetStreak()` → Current workout streak

## Database Schema

### Users & Profile
- `users` — id, email, password_hash, display_name, avatar_url, use_pounds, rest_timer_seconds
- `weight_logs` — user_id, weight_kg, logged_date, notes

### Exercise Library
- `exercise_categories` — id, name, display_order
- `exercises` — id, name, category_id, exercise_type, is_system, created_by, description

### Workout Templates
- `workout_templates` — id, user_id, name, description, is_archived
  - `total_exercises`, `total_sets`, `estimated_duration_minutes` computed via subqueries (not stored)
- `workout_sections` — workout_template_id, name, display_order, is_superset
- `section_items` — section_id, item_type (exercise|rest), exercise_id, rest_duration, display_order
- `exercise_target_sets` — section_item_id, set_number, target_weight, target_reps, target_time, target_distance, rest_duration_seconds

### Training Programs
- `programs` — id, user_id, name, duration_weeks, is_active, is_archived
- `program_days` — program_id, day_number, day_type (workout|rest|unassigned), workout_template_id

### Workout Sessions
- `workout_sessions` — id, user_id, workout_template_id, status (in_progress|completed|abandoned), started_at, completed_at
- `session_exercises` — session_id, exercise_id, display_order, superset_id (UUID grouping)
- `session_sets` — session_exercise_id, set_number, weight_kg, reps, is_completed, rpe

### Progress Tracking
- `personal_records` — user_id, exercise_id, weight_kg, reps, one_rep_max_kg, achieved_at
- `exercise_history` — user_id, exercise_id, session_id, session_date, best_weight, total_volume

### Exercise Types (enum)
- `weight_reps` — Barbell/dumbbell
- `bodyweight_reps` — Push-ups, pull-ups
- `time` — Planks, holds
- `distance` — Running, rowing
- `cardio` — General cardio

### Superset Support
- `superset_id` in `session_exercises` groups exercises in same superset
- Generated as UUID when starting session from template with `is_superset = true` sections
- Frontend uses this for superset badge display and grouping

## Middleware

### Auth Middleware (`internal/middleware/auth.go`)
- Validates Bearer tokens from `Authorization` header
- Extracts user ID from JWT claims → adds to context
- Skips auth for public endpoints (Login)

### Logging Middleware (`internal/middleware/logging.go`)
- Logs method, duration, status for each request

Registration in `cmd/server/main.go`:
```go
interceptors := connect.WithInterceptors(
    middleware.NewLoggingInterceptor(),
    middleware.NewAuthInterceptor(jwtSecret, publicPaths),
)
```

## Environment Variables

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous key |
| `SUPABASE_SERVICE_KEY` | Supabase service role key |
| `PORT` | Server port (default: 8080) |

## Makefile Commands

```bash
make generate           # Generate proto code via buf
make build              # Compile to bin/server
make run                # Start server
make deps               # go mod download
make lint               # Lint proto files
make clean              # Remove build artifacts
make setup              # deps + generate + build

make migrate-up         # Apply all migrations
make migrate-down       # Rollback last migration
make migrate-status     # Check migration status
make migrate-create name=xxx  # Create new migration

make test               # All tests
make test-unit          # Unit tests (no DB, -short flag)
make test-integration   # Integration tests (needs Docker)
make test-coverage      # HTML coverage report
make test-race          # Race detector
```
