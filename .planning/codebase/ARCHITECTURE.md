# Architecture

**Analysis Date:** 2026-03-10

## Pattern Overview

**Overall:** Three-tier Clean Architecture with Connect-RPC microservice API and Flutter client. The architecture enforces strict separation between handlers (business logic), repositories (data access), and the database layer. Dependency injection wires components in the main server file.

**Key Characteristics:**
- Clean Architecture with isolated layers (handlers → repositories → database)
- Connect-RPC for type-safe HTTP/2 communication with protobuf serialization
- Feature-first modular design on frontend (Flutter)
- JWT-based authentication via middleware interceptor
- Repository pattern abstracts all data access with interface definitions
- Immutable state management on frontend (Riverpod + Freezed models)
- User scoping enforced at all database query levels (multitenancy via JWT)

## Layers

**Handler Layer (Request/Response):**
- Purpose: Process API requests, validate input, orchestrate business logic, handle errors
- Location: `HeftyBack/internal/handlers/`
- Contains: RPC service implementations (7 services with 70+ methods)
- Depends on: Repository interfaces, JWT auth context, error handlers
- Used by: Connect-RPC HTTP server, middleware

**Repository Layer (Data Access):**
- Purpose: Abstract all database queries, return domain models, enforce user scoping
- Location: `HeftyBack/internal/repository/`
- Contains: Interface definitions (`interfaces.go`), SQL implementations for 7 repositories
- Depends on: pgx database pool, domain models
- Used by: Handlers exclusively

**Database Layer (Persistence):**
- Purpose: Store and retrieve data via PostgreSQL (Supabase)
- Location: Supabase PostgreSQL instance, migrations in `HeftyBack/migrations/`
- Contains: 15 core tables with proper FK relationships, transaction support
- Depends on: pgx v5 connection pool
- Used by: Repository implementations

**Middleware Layer (Cross-Cutting Concerns):**
- Purpose: Apply auth, logging, CORS to all requests
- Location: `HeftyBack/internal/middleware/`
- Contains: Auth interceptor (validates JWT, adds userID to context), logging interceptor
- Depends on: JWT manager, logger
- Used by: HTTP server in main.go

**Config & Infrastructure:**
- Purpose: Initialize dependencies and manage configuration
- Location: `HeftyBack/internal/config/`, `HeftyBack/internal/db/`, `HeftyBack/internal/auth/`
- Contains: Environment loading, database pool creation, JWT token generation/validation
- Depends on: Environment variables, pgx driver
- Used by: main.go entry point

---

**Frontend (Flutter):**
- Purpose: Present UI, manage client state, communicate with backend
- Location: `hefty_chest/lib/`
- Contains: Feature screens, providers (state management), widgets, routing
- Depends on: Connect-RPC clients, Riverpod for state, go_router for navigation
- Used by: Users via mobile/web app

## Data Flow

**Authenticated Request Flow (most endpoints):**

1. HTTP/2 request arrives at `http://localhost:8080/heft.v1.ServiceName/MethodName`
2. **Auth Middleware** (`middleware/auth.go`):
   - Extracts Bearer token from `Authorization` header
   - Validates token with JWT manager
   - Extracts userID from claims
   - Adds userID to context: `auth.ContextWithUserID(ctx, userID)`
3. **Handler** (e.g., `handlers/user.go`):
   - Retrieves userID from context: `auth.UserIDFromContext(ctx)`
   - Validates request message (required fields)
   - Calls repository method with userID (enforces data isolation)
4. **Repository** (e.g., `repository/user.go`):
   - Executes SQL query with userID in WHERE clause
   - Maps database rows to domain model structs
   - Returns model or nil (not nil, error for 404s)
5. **Database** (Supabase PostgreSQL):
   - Executes parameterized query
   - Returns results
6. **Handler** (continued):
   - Maps domain model to protobuf response
   - Returns `connect.Response` with status 200
7. HTTP response sent back to client with protobuf payload

**Example: GetProfile Request**
```
Client Request:
  GET /heft.v1.UserService/GetProfile
  Authorization: Bearer eyJhbGc...
  (empty body - user_id extracted from JWT)
  ↓
Auth Middleware:
  Validates token, extracts user_id "user-123"
  ctx = ContextWithUserID(ctx, "user-123")
  ↓
UserHandler.GetProfile():
  userID, _ := UserIDFromContext(ctx)  // "user-123"
  user, _ := repo.GetByID(ctx, userID)
  ↓
UserRepository.GetByID():
  SELECT * FROM users WHERE id = $1 AND ... // userID scoped
  ↓
Response: {user: {id: "user-123", email: "..."}}, status 200
```

**Login Request (public endpoint - no auth required):**
```
Client Request:
  POST /heft.v1.AuthService/Login
  {email: "user@example.com"}
  ↓
Auth Middleware:
  Checks publicProcedures map, skips auth
  ↓
AuthHandler.Login():
  user := repo.GetByEmail(ctx, email)
  if user == nil: user := repo.Create(ctx, email)  // New user auto-created
  token := jwtManager.GenerateToken(user.ID)
  ↓
Response: {token: "eyJhbGc...", user_id: "user-123", is_new_user: true}
```

**Session Sync Flow (complex multi-operation):**
```
Client calls: sessionClient.SyncSession(session_id, sets, exercises, delete_ids)
  ↓
SessionHandler.SyncSession():
  userID := UserIDFromContext(ctx)
  For each new set: repo.AddSet(ctx, session_id, ...)
  For each sync input:
    if SetID is empty: Create new set via AddSet()
    else: Update existing set via SyncSets()
  For each exercise to delete: repo.DeleteExercises(ctx, ...)
  ↓
Response: Updated session with all changes applied
```

**State Management (Frontend):**
- **Riverpod Provider** watches data state:
  ```dart
  @riverpod
  Future<List<Workout>> workoutList(Ref ref) async {
    final response = await workoutClient.listWorkouts(ListWorkoutsRequest());
    return response.workouts;  // Backend extracts user_id from JWT
  }
  ```
- **Widget** watches provider:
  ```dart
  final workouts = ref.watch(workoutListProvider);
  workouts.when(
    loading: () => CircularProgressIndicator(),
    error: (e, st) => ErrorWidget(),
    data: (workouts) => ListView(children: workouts),
  );
  ```
- **Notifier Provider** manages mutable state:
  ```dart
  @riverpod
  class SessionBuilder extends _$SessionBuilder {
    Future<void> sync() async {
      await sessionClient.syncSession(syncRequest);
      // Automatically invalidate workoutListProvider to refresh
      ref.invalidate(workoutListProvider);
    }
  }
  ```

## Key Abstractions

**Repository Interface Pattern:**
- Purpose: Define contract for data access, enable mocking in tests
- Examples: `UserRepositoryInterface`, `WorkoutRepositoryInterface`, `SessionRepositoryInterface`
- Location: `HeftyBack/internal/repository/interfaces.go`
- Pattern: Go interface with all CRUD methods, compile-time check via `var _ Interface = (*Implementation)(nil)`
- Benefits: Handlers don't depend on SQL, easy to mock/stub in tests

**Handler Pattern:**
- Purpose: Implement RPC service methods, orchestrate business logic
- Examples: `handlers/user.go`, `handlers/workout.go`, `handlers/session.go`
- Pattern: Struct with repo field, NewXHandler factory, methods matching RPC signatures
- Responsibilities: Input validation, context extraction, error handling, response mapping

**Domain Models:**
- Purpose: Represent data structures in application layer (maps from DB rows and to proto)
- Examples: `User`, `WorkoutTemplate`, `WorkoutSession` from repository package
- Pattern: Simple structs with exported fields (no methods), optional pointers for nullable DB columns
- Used by: Repositories (return), handlers (map to proto)

**Proto Message Pattern:**
- Purpose: Define RPC service contracts and data structures
- Examples: `heftv1.LoginRequest`, `heftv1.WorkoutTemplate`, `heftv1.SessionExercise`
- Pattern: Separate .proto file per domain (auth.proto, workout.proto, session.proto)
- Generated: `HeftyBack/gen/heft/v1/*.pb.go` and client code, plus `hefty_chest/lib/gen/*`

**Session Models (Frontend - Freezed):**
- Purpose: Immutable representation of session state with automatic copyWith()
- Examples: `SessionModel`, `SessionExerciseModel`, `SessionSetModel`
- Location: `hefty_chest/lib/features/tracker/models/session_models.dart`
- Pattern: @freezed classes with fromProto/toProto conversion
- Benefits: Type-safe state updates, compile-time null safety, deep copy generation

**Provider Pattern (Frontend - Riverpod):**
- Purpose: Manage async data and mutable state
- Variants:
  - `@riverpod Future<T>` - Data loading (read-only)
  - `@riverpod class X extends _$X` - Mutable state notifier (read-write)
  - `@riverpod T` - Computed/derived state
- Benefits: Automatic caching, dependency tracking, disposal, error handling

## Entry Points

**Backend (`HeftyBack/cmd/server/main.go`):**
- Location: `HeftyBack/cmd/server/main.go`
- Triggers: `go run ./cmd/server` or binary execution
- Responsibilities:
  1. Load environment config (`config.Load()`)
  2. Initialize database pool (`db.New(ctx)`)
  3. Create JWT manager (`auth.NewJWTManager()`)
  4. Instantiate 7 repositories (user, exercise, workout, program, session, progress, auth)
  5. Instantiate 7 handlers, injecting repositories
  6. Create middleware interceptors (auth, logging)
  7. Register Connect-RPC service handlers with mux
  8. Setup CORS handler
  9. Start HTTP/2 server with h2c (cleartext HTTP/2) on `:8080`
  10. Graceful shutdown on SIGINT/SIGTERM

**Frontend (`hefty_chest/lib/main.dart` → `lib/app/app.dart`):**
- Location: `hefty_chest/lib/main.dart`
- Triggers: `flutter run`
- Entry point `main()`:
  1. Initialize logging via `setupLogging()`
  2. Check stored auth token via SharedPreferences
  3. Run `HeftyChestApp()`
- `HeftyChestApp` responsibilities:
  1. Setup `authProvider` with token provider callback
  2. Create `GoRouter` with ref for auth guard
  3. Build Material app with FTheme
  4. Return `MaterialApp.router` with router config
  5. Watch auth state and refresh router on changes

**Key Init Sequence:**
```
Backend:
  config.Load() → db.New() → Create repos → Create handlers →
  Register services → Start server

Frontend:
  main() → setupLogging() → HeftyChestApp → authProvider.build() →
  Load saved token → Create router → Build app
```

## Error Handling

**Strategy:** Layered error handling with conversion to appropriate Connect gRPC error codes. Database errors are caught at handler layer and mapped to HTTP status codes.

**Handler Layer Error Handling:**
```go
// Validation errors
if req.Msg.UserId == "" {
    return nil, connect.NewError(connect.CodeInvalidArgument,
        errors.New("user_id is required"))
}

// Database errors via handleDBError()
user, err := h.repo.GetByID(ctx, userID)
if err != nil {
    return nil, handleDBError(err)  // Converts SQL errors to appropriate codes
}

// Not found (repository returns nil, nil for missing records)
if user == nil {
    return nil, connect.NewError(connect.CodeNotFound,
        errors.New("user not found"))
}

// Conflict errors (e.g., user has active session)
if user.ActiveSessionID != "" {
    return nil, connect.NewError(connect.CodeAlreadyExists,
        errors.New("user has active session"))
}
```

**Error Code Mapping (`internal/handlers/errors.go`):**
- `CodeUnauthenticated` (401) - Missing/invalid auth token (middleware)
- `CodePermissionDenied` (403) - User FK violation (user doesn't exist in DB)
- `CodeInvalidArgument` (400) - Missing required fields, bad input
- `CodeNotFound` (404) - Resource not found (ID doesn't exist or not owned by user)
- `CodeAlreadyExists` (409) - Resource already exists (user has active session)
- `CodeInternal` (500) - Database errors, server errors

**Patterns:**
- Database errors from pgx are caught and converted to Connect errors
- Foreign key violations return 403 (tells frontend to send user to auth)
- Transactions wrap multi-operation changes (all succeed or all rollback)
- No error details leaked in responses (info only in server logs)

**Frontend Error Handling:**
```dart
// In provider
@riverpod
Future<WorkoutList> workoutList(Ref ref) async {
  try {
    final response = await workoutClient.listWorkouts(request);
    return response.workouts;
  } catch (e, st) {
    logWorkout.severe('Failed to load workouts', e, st);
    rethrow;  // Riverpod handles error state
  }
}

// In widget
workouts.when(
  loading: () => FProgress(),
  error: (err, st) {
    logWorkout.severe('Error in UI', err, st);
    return FButton(
      onPress: () => ref.refresh(workoutListProvider),
      child: Text('Retry: $err'),
    );
  },
  data: (workouts) => ListView(...),
);
```

## Cross-Cutting Concerns

**Logging:**
- Backend: `log` package, structured logging in middleware and error handling
- Frontend: `logging` package with pre-defined loggers per feature (logWorkout, logSession, etc.)
- Pattern: Log at SEVERE (errors), INFO (important ops), FINE (debug details)

**Validation:**
- Backend: Request message validation in handlers (required fields, format checks like email regex)
- Frontend: Real-time validation in text fields (min length, pattern matching for email)
- Strategy: Fail fast with CodeInvalidArgument before touching database

**Authentication:**
- Backend: JWT validation in auth middleware, user ID extracted and added to context
- Frontend: Token stored in SharedPreferences, included in all requests via auth interceptor
- Strategy: No user_id in request bodies; backend derives from JWT to prevent spoofing

**User Scoping (Multitenancy):**
- All queries include user_id in WHERE clause: `WHERE id = $1 AND user_id = $2`
- Handlers extract user_id from JWT context, never from request
- Repository methods accept user_id parameter for explicit scoping
- Example: Cannot query another user's workout because WHERE clause filters by (id, user_id)

**Database Consistency:**
- Foreign keys enforce referential integrity
- Migrations use goose for versioning and rollback
- Transactions for multi-table operations (e.g., session sync updates sets, exercises, etc.)
- Test database isolation via pgtestdb (fresh DB per test, auto-cleanup)

---

*Architecture analysis: 2026-03-10*
