# External Integrations

**Analysis Date:** 2026-03-10

## APIs & External Services

**Authentication (Future Integration):**
- Supabase Auth - Planned but not yet implemented
  - Environment Variables: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_KEY`
  - Status: MVP uses JWT-based auth (manual login with email)
  - Backend extracts user_id from JWT claims on each request

**Internal RPC Services:**
- Connect-RPC - Custom protocol for frontend-backend communication
  - 7 services exposed: Auth, User, Exercise, Workout, Program, Session, Progress
  - See Backend Services section below

## Data Storage

**Databases:**
- PostgreSQL 15+
  - Provider: Supabase (production) or self-hosted
  - Connection: Via pgx driver (`github.com/jackc/pgx/v5`)
  - Environment Variable: `DATABASE_URL`
  - Connection String Format: `postgres://user:pass@host:port/db?sslmode=disable`
  - Port: 5433 (local development), 5432 (Supabase)

**Tables (Primary Data):**
- Users: `users`, `weight_logs`
- Exercises: `exercise_categories`, `exercises`
- Workouts: `workout_templates`, `workout_sections`, `section_items`, `exercise_target_sets`
- Training Programs: `programs`, `program_days`
- Sessions: `workout_sessions`, `session_exercises`, `session_sets`
- Progress: `personal_records`, `exercise_history`

**File Storage:**
- Local filesystem only - No cloud storage integration (avatars/media stored as URLs in database)

**Caching:**
- None - Direct database queries, no Redis or memcached

**Local Storage (Frontend):**
- shared_preferences ^2.3.3
  - Used for: Storing JWT token, local session backup/recovery
  - Platform: Native iOS/Android preferences, browser localStorage on web

## Authentication & Identity

**Auth Provider:**
- Custom JWT implementation (Backend-managed)
  - JWT Library: `github.com/golang-jwt/jwt/v5`
  - Location: `HeftyBack/internal/auth/jwt.go`

**Auth Flow:**
1. Frontend calls `AuthService.Login(email)` with email
2. Backend creates/retrieves user, generates JWT token
3. Frontend stores token in `shared_preferences`
4. Frontend sets token via `setTokenProvider()` in `lib/core/client.dart`
5. Auth interceptor adds `Authorization: Bearer <token>` header to all requests
6. Backend middleware validates token and extracts user_id via `UserIDFromContext()`

**JWT Configuration:**
- Algorithm: HS256 (symmetric key)
- Expiration: Configurable via `JWTExpirationHours` (default likely 24-72 hours)
- Secret Key: Loaded from environment (hardcoded in development)
- User ID Claim: Stored in JWT claims, extracted server-side

**User Scoping:**
- All API endpoints require JWT authentication (except Login)
- User ID is ALWAYS extracted from token claims, never from request body
- All queries scoped to user via user_id check for data isolation

**Token Management:**
- Token stored in: `shared_preferences` (frontend)
- Token refresh: Not implemented (token used until expiry)
- Logout: Token cleared from `shared_preferences`

## Monitoring & Observability

**Error Tracking:**
- None - No Sentry, Rollbar, or Bugsnag integration

**Logs:**
- Backend: stdout/stderr via `log` package
  - Accessed via Docker logs or application logs
  - Middleware logs requests with duration and status
- Frontend: `logging` package 1.3.0
  - Pre-defined loggers for each feature (logAuth, logSession, logWorkout, etc.)
  - Output to console (debug mode)

**Structured Logging Setup:**
```dart
// lib/core/logging.dart - Pre-defined loggers
final logAuth = Logger('heft.auth');
final logSession = Logger('heft.session');
final logWorkout = Logger('heft.workout');
// ... 9 loggers total (one per feature)
```

**Health Check Endpoint:**
- `GET /health` - Returns 200 OK if server is running
- Used by Docker healthchecks and Kubernetes liveness probes

## CI/CD & Deployment

**Hosting:**

Backend:
- Render (production: `https://heft-backend.onrender.com`)
- Docker containers (local development: `docker compose up -d`)

Frontend:
- App Store (iOS)
- Google Play (Android)
- Flutter Web (browser)

**CI/CD Pipeline:**
- Not configured
- Manual deployment process currently

**Docker:**

Development:
- `HeftyBack/docker-compose.yml` - Starts backend + PostgreSQL 15
  - Backend service: Builds Dockerfile, runs on :8080
  - PostgreSQL service: postgres:15 on :5433, persistent volume `pgdata`
  - Health checks on both services

Testing (Frontend):
- `hefty_chest/docker-compose.test.yml` - Backend + PostgreSQL for integration tests
  - PostgreSQL: tmpfs (non-persistent) for test isolation
  - Backend: TEST_MODE=true enables `/test/reset` endpoint
  - Health checks ensure services are ready before tests

**Environment Variables (Deployment):**

Backend (.env):
```
DATABASE_URL=postgres://user:pass@host:5432/db
SUPABASE_URL=https://project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...
PORT=8080
TEST_MODE=false  # Only true in test environments
```

Frontend (`lib/core/config.dart`):
```dart
static const String backendUrl = 'http://localhost:8080';  // or production URL
```

## Webhooks & Callbacks

**Incoming Webhooks:**
- None - No webhook endpoints exposed

**Outgoing Webhooks:**
- None - No external services called via webhooks

## Database Migrations

**Tool:** Goose v3.22.1
- Location: `HeftyBack/migrations/`
- Format: SQL with Up/Down statements
- Commands:
  ```bash
  make migrate-up       # Apply pending migrations
  make migrate-down     # Rollback last migration
  make migrate-status   # Show migration status
  make migrate-create name=xxx  # Create new migration
  ```

**Test Database Setup:**
- pgtestdb v0.1.1 - Creates isolated test databases per test
- goosemigrator - Runs migrations on isolated test databases
- Each test gets fresh database, auto-cleanup on test completion

## Proto/RPC Schema Management

**Protocol Buffers (Proto3):**
- Shared between backend and frontend via Connect-RPC
- Schema files duplicated in both projects (manual sync required)

**Backend Services (7 total):**

| Service | Purpose | Key Methods |
|---------|---------|------------|
| AuthService | Authentication | `Login(email)` |
| UserService | User profiles & settings | `GetProfile`, `UpdateProfile`, `LogWeight` |
| ExerciseService | Exercise library | `ListExercises`, `CreateExercise`, `SearchExercises` |
| WorkoutService | Workout templates | `CreateWorkout`, `UpdateWorkout`, `DuplicateWorkout` |
| ProgramService | Training programs | `CreateProgram`, `AssignWorkout`, `SetActiveProgram` |
| SessionService | Live workout tracking | `StartSession`, `SyncSession`, `FinishSession` |
| ProgressService | Analytics & PRs | `GetDashboardStats`, `GetPersonalRecords`, `GetStreak` |

**Code Generation:**

Backend:
- Buf CLI generates: Go message types + Connect-RPC handlers
- Config: `HeftyBack/buf.gen.yaml` (plugins: protocolbuffers/go + connectrpc/go)
- Output: `HeftyBack/gen/heft/v1/`
- Command: `make generate` (runs `buf generate`)

Frontend:
- Buf CLI generates: Dart message types + RPC client classes
- Config: `hefty_chest/buf.gen.yaml`
- Output: `hefty_chest/lib/gen/`
- Post-generation: `flutter pub run build_runner build` for router + providers
- Command: `make generate` (runs both buf + build_runner)

**Proto Sync Process:**
1. Update `.proto` files in `HeftyBack/proto/heft/v1/`
2. Copy to `hefty_chest/proto/`
3. Run `buf generate` in both projects
4. Implement handler in backend
5. Update providers/UI in frontend

## Test Database Reset

**Endpoint:** `POST /test/reset`
- Available only when `TEST_MODE=true` environment variable is set
- Clears all user data (keeps system exercises)
- Truncates tables in foreign key order:
  - Sessions, Progress → Workouts → Programs → Templates → Custom Exercises → Weight Logs
- Used by integration tests to reset state between test runs
- **Never enabled in production**

## Deployment Configuration

**Backend (Render):**
- URL: `https://heft-backend.onrender.com`
- Environment variables configured in Render dashboard
- Automatic deployment from git (if configured)

**Frontend:**
- Local builds for iOS/Android (.ipa, .apk)
- App Store and Google Play distribution (manual for now)

---

*Integration audit: 2026-03-10*
