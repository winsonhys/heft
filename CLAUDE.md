# Heft - Workout Tracking Application

## Project Overview

Heft is a full-stack workout tracking application consisting of:
- **HeftyBack/** - Go backend API server
- **hefty_chest/** - Flutter cross-platform mobile app

This is a fitness platform that allows users to create workout templates, follow training programs, track live workout sessions, and monitor their progress over time.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    hefty_chest (Flutter)                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Riverpod  │  │  go_router  │  │  shadcn_flutter UI  │  │
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
│  │  Auth │ User │ Exercise │ Workout │ Program │ Session │ Progress │
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

## Tech Stack Summary

| Component | Backend (HeftyBack) | Frontend (hefty_chest) |
|-----------|---------------------|------------------------|
| Language | Go 1.23 | Dart/Flutter 3.10.3+ |
| API | Connect-RPC | Connect-RPC Client |
| Database | PostgreSQL (Supabase) | - |
| State Mgmt | - | Riverpod 3.0 |
| UI | - | shadcn_flutter |
| Routing | - | go_router |
| Build Tool | Makefile | Flutter CLI |

## Communication Protocol

- **Protocol:** Connect-RPC over HTTP/2
- **Serialization:** Protocol Buffers
- **Schema Location:** Proto files are duplicated in both projects:
  - `HeftyBack/proto/heft/v1/*.proto`
  - `hefty_chest/proto/*.proto`
- **Code Generation:** Buf CLI (`buf generate`)
- **Backend URL:** `http://localhost:8080`

## Quick Start

### Prerequisites
- Go 1.23+
- Flutter SDK 3.10.3+
- PostgreSQL 15+ (or Supabase account)
- Buf CLI (`brew install bufbuild/buf/buf`)
- Docker (for backend tests)

### Backend Setup
```bash
cd HeftyBack
cp .env.example .env              # Configure DATABASE_URL and Supabase keys
make deps                         # Install Go dependencies
make generate                     # Generate proto code
make migrate-up                   # Apply database migrations
make run                          # Start server on :8080
```

### Frontend Setup
```bash
cd hefty_chest
flutter pub get                   # Install dependencies
buf generate                      # Generate proto code
flutter run                       # Run app (connects to localhost:8080)
```

### Run Everything
```bash
# Terminal 1 - Backend
cd HeftyBack && make run

# Terminal 2 - Frontend
cd hefty_chest && flutter run
```

## Development Workflow

### Making Proto Changes
Proto files define the API contract. When modifying:
1. Update `.proto` files in **BOTH** `HeftyBack/proto/` and `hefty_chest/proto/`
2. Run `buf generate` in **BOTH** projects
3. Implement/update handlers in backend
4. Update providers/UI in frontend

### Backend Development
- `make run` - Run server (restart manually for changes)
- `make test` - Run all tests
- `make test-unit` - Fast unit tests (no database)
- `make test-integration` - Full integration tests (needs Docker)

### Frontend Development
- `flutter run` - Run with hot reload
- `flutter test` - Run tests
- `flutter build apk/ios/web` - Build for platform

## Project Structure

```
heft/
├── CLAUDE.md                    # This file (orchestrator)
├── HeftyBack/                   # Go backend
│   ├── CLAUDE.md               # Backend-specific guide
│   ├── cmd/server/             # Entry point
│   ├── internal/               # Application code
│   │   ├── handlers/           # Service implementations
│   │   ├── repository/         # Data access layer
│   │   ├── db/                 # Database connection
│   │   ├── config/             # Configuration
│   │   └── testutil/           # Test helpers
│   ├── proto/heft/v1/          # Proto definitions
│   ├── gen/                    # Generated code
│   ├── migrations/             # SQL migrations
│   └── Makefile                # Build commands
│
└── hefty_chest/                 # Flutter frontend
    ├── CLAUDE.md               # Frontend-specific guide
    ├── lib/
    │   ├── app/                # App config, router
    │   ├── core/               # RPC client, config
    │   ├── features/           # Feature modules (7)
    │   ├── shared/             # Theme, widgets
    │   └── gen/                # Generated proto code
    ├── proto/                  # Proto definitions
    └── pubspec.yaml            # Dependencies
```

## Services Overview

The backend exposes 7 RPC services:

| Service | Purpose | Key Operations |
|---------|---------|----------------|
| AuthService | Authentication | Register, Login, RefreshToken, Logout |
| UserService | User management | GetProfile, UpdateSettings, LogWeight |
| ExerciseService | Exercise library | ListExercises, SearchExercises, CreateExercise |
| WorkoutService | Workout templates | CreateWorkout, AddSection, AddTargetSet |
| ProgramService | Training programs | CreateProgram, AssignWorkout, SetActiveProgram |
| SessionService | Live tracking | StartSession, CompleteSet, FinishSession |
| ProgressService | Analytics | GetDashboard, GetPersonalRecords, GetStreak |

## Testing

### Backend Tests
```bash
cd HeftyBack
docker compose up -d   # Start test PostgreSQL on port 5433
make test              # All tests
make test-unit         # Unit tests only (fast, no DB)
make test-integration  # Integration tests (uses pgtestdb for isolated DBs)
make test-coverage     # Generate coverage report
```

Integration tests use **pgtestdb** with **goosemigrator** to create isolated test databases per test. The `TestServer` provides clients for all 7 services with JWT auth support.

### Frontend Tests
```bash
cd hefty_chest
flutter test           # Run all tests
```

## Environment Configuration

### Backend (.env)
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc...
DATABASE_URL=postgres://postgres:password@db.your-project.supabase.co:5432/postgres
PORT=8080
```

### Frontend
Configuration is in `lib/core/config.dart`:
- `backendUrl`: Backend API URL (default: `http://localhost:8080`)
- `hardcodedUserId`: MVP user ID (will be replaced with auth)

## Common Tasks

### Add a New API Endpoint
1. Define messages and service method in `.proto` files (both projects)
2. `buf generate` in both projects
3. Implement handler in `HeftyBack/internal/handlers/`
4. Add repository method if needed
5. Create provider and UI in frontend

### Add a New Feature Screen
1. Create feature folder in `hefty_chest/lib/features/`
2. Add providers in `providers/` subfolder
3. Add widgets in `widgets/` subfolder
4. Create screen widget
5. Add route in `lib/app/router.dart`

### Run Database Migration
```bash
cd HeftyBack
make migrate-create name=add_new_table  # Create new migration
make migrate-up                          # Apply migrations
make migrate-down                        # Rollback last migration
make migrate-status                      # Check status
```

## Current Status (MVP)

- Authentication: JWT-based auth via AuthService (Register, Login, RefreshToken)
- Environment: Local development only
- CI/CD: Not configured
- Proto sync: Manual (files duplicated, not shared)
