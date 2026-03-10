# Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    hefty_chest (Flutter)                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Riverpod  │  │  go_router  │  │     forui UI        │  │
│  │   (State)   │  │  (Routing)  │  │    (Components)     │  │
│  └──────┬──────┘  └─────────────┘  └─────────────────────┘  │
│         │                                                    │
│  ┌──────▼──────────────────────────────────────────────┐    │
│  │           Connect-RPC Client (lib/gen/)              │    │
│  └──────────────────────────┬───────────────────────────┘    │
└─────────────────────────────┼───────────────────────────────┘
                              │ HTTP/2 + Protobuf
┌─────────────────────────────▼───────────────────────────────┐
│                    HeftyBack (Go)                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Connect-RPC Services (7)                │    │
│  │  Auth │ User │ Exercise │ Workout │ Program │        │    │
│  │  Session │ Progress                                  │    │
│  └──────────────────────────┬──────────────────────────┘    │
│                             │                                │
│  ┌──────────────────────────▼──────────────────────────┐    │
│  │           Repository Layer (interfaces)              │    │
│  └──────────────────────────┬──────────────────────────┘    │
│                             │                                │
│  ┌──────────────────────────▼──────────────────────────┐    │
│  │              PostgreSQL (Supabase)                   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Communication Protocol

- **Protocol:** Connect-RPC over HTTP/2
- **Serialization:** Protocol Buffers
- **Schema Location:** Proto files are duplicated in both projects:
  - `HeftyBack/proto/heft/v1/*.proto`
  - `hefty_chest/proto/*.proto`
- **Code Generation:** Buf CLI (`buf generate`)
- **Backend URL:**
  - Debug: `http://localhost:8080`
  - Release: `https://heft-backend.onrender.com`

## Backend Layer Architecture

```
HTTP Request
     │
     ▼
┌─────────────────────────────────────────┐
│        Middleware (auth, logging)        │  ← Cross-cutting only
│  internal/middleware/                    │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│        Connect-RPC Handler              │  ← Business logic + validation
│  internal/handlers/{service}.go         │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│        Repository Interface             │  ← Contract between layers
│  internal/repository/interfaces.go      │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│        Repository Implementation        │  ← SQL via pgx
│  internal/repository/{service}.go       │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│        PostgreSQL (Supabase)            │
└─────────────────────────────────────────┘
```

**Layer rules:**
- Handlers import repository interfaces, never `pgx`
- Repositories import `pgx`, never handler types
- Middleware never contains business logic
- Generated code (`gen/`) is never hand-edited

## Frontend Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  App Layer (lib/app/)                                        │
│  Router config, app widget. Imports feature screens.         │
├─────────────────────────────────────────────────────────────┤
│  Feature Layer (lib/features/*/)                             │
│  Self-contained modules: screen + providers + widgets.       │
│  Features NEVER import from other features.                  │
├─────────────────────────────────────────────────────────────┤
│  Shared Layer (lib/shared/)                                  │
│  Reusable widgets, theme, colors. Never imports features.    │
├─────────────────────────────────────────────────────────────┤
│  Core Layer (lib/core/)                                      │
│  RPC clients, config, logging. Never imports features/shared.│
├─────────────────────────────────────────────────────────────┤
│  Generated Layer (lib/gen/)                                  │
│  Proto-generated types and clients. Never hand-edited.       │
└─────────────────────────────────────────────────────────────┘
```

**Dependency flow:** `gen → core → shared → features → app`

Each feature follows this structure:
```
lib/features/{name}/
├── {name}_screen.dart          # Main screen widget
├── providers/
│   └── {name}_providers.dart   # Riverpod providers
└── widgets/
    └── {widget}.dart           # Feature-specific widgets
```

## Data Flow

### Frontend → Backend

```
User Action
  → Widget calls ref.read(provider.notifier).method()
    → Provider calls RPC client (e.g., workoutClient.createWorkout())
      → Connect-RPC serializes to Protobuf
        → HTTP/2 request with Bearer JWT token
          → Backend middleware validates JWT, extracts userID
            → Handler receives request + userID from context
              → Repository executes SQL query (scoped by userID)
                → Response flows back through same layers
```

### Authentication Flow

```
1. User enters email → authClient.login(email)
2. Backend creates/finds user → returns JWT token + user ID
3. Token stored in SharedPreferences
4. Token provider set → all subsequent API calls include Authorization header
5. Backend middleware validates token on every request
6. userID extracted from JWT claims → injected into context
7. Handlers use auth.UserIDFromContext(ctx) — never trust client-sent userID
```

## Dependency Injection (Backend)

All wiring happens in `cmd/server/main.go`:

```go
cfg := config.Load()
pool, _ := db.NewPool(ctx, cfg.DatabaseURL)

// Repositories
userRepo := repository.NewUserRepository(pool)
exerciseRepo := repository.NewExerciseRepository(pool)
// ... one per service

// Handlers (inject repository interfaces)
userHandler := handlers.NewUserHandler(userRepo)
exerciseHandler := handlers.NewExerciseHandler(exerciseRepo)
// ...

// Register Connect-RPC services
mux.Handle(heftv1connect.NewUserServiceHandler(userHandler))
mux.Handle(heftv1connect.NewExerciseServiceHandler(exerciseHandler))
// ...
```

## Services

7 RPC services exposed by the backend:

| Service | Purpose | Key Operations |
|---------|---------|----------------|
| AuthService | Authentication | Login (creates user if new) |
| UserService | User management | GetProfile, UpdateSettings, LogWeight |
| ExerciseService | Exercise library | ListExercises, SearchExercises, CreateExercise |
| WorkoutService | Workout templates | CreateWorkout, UpdateWorkout, DuplicateWorkout |
| ProgramService | Training programs | CreateProgram, AssignWorkout, SetActiveProgram |
| SessionService | Live tracking | StartSession, SyncSession, FinishSession |
| ProgressService | Analytics | GetDashboardStats, GetPersonalRecords, GetStreak |

## Environment Configuration

### Backend (.env)

```bash
DATABASE_URL=postgres://user:pass@host:5432/db
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...
PORT=8080
```

### Frontend (lib/core/config.dart)

```dart
static const String backendUrl = 'http://localhost:8080';
```

## Current Status (MVP)

- Authentication: JWT-based via AuthService
- Environment: Local dev + Production on Render
- CI/CD: Not configured
- Proto sync: Manual (files duplicated, not shared)
