# Technology Stack

**Analysis Date:** 2026-03-10

## Languages

**Primary:**
- Go 1.24.0 - Backend API server (`HeftyBack/`)
- Dart 3.10.3+ - Flutter cross-platform frontend (`hefty_chest/`)

**Secondary:**
- SQL - PostgreSQL database schema and migrations

## Runtime

**Backend Environment:**
- Go runtime 1.24.0
- Runs on Linux/Unix (Docker containerized)

**Frontend Environment:**
- Flutter 3.10.3+ SDK
- Dart VM runtime
- Multi-platform support: iOS, Android, macOS, Web

**Package Managers:**
- **Backend:** Go modules (`go mod`)
  - Lockfile: `go.sum` (automatically generated)
- **Frontend:** Pub (Dart package manager, `pubspec.yaml`)
  - Lockfile: `pubspec.lock` (automatically generated)

## Frameworks

**Backend:**
- Connect-RPC v1.16.0 - RPC framework for service definitions and handlers
  - Uses Protocol Buffers for serialization
  - HTTP/2 native support via `golang.org/x/net/http2`

**Frontend:**
- Flutter 3.10.3+ - UI framework for cross-platform mobile/desktop apps
- Riverpod 3.0.3 - State management with code generation
- go_router 17.0.0 - Navigation and routing with code generation
- forui 0.17.0 - Formlabs UI component library (FButton, FTextField, FProgress, etc.)

**Code Generation Tools:**
- Buf CLI - Protocol Buffer management (`buf generate`, `buf lint`)
  - Backend config: `HeftyBack/buf.yaml`, `HeftyBack/buf.gen.yaml`
  - Frontend config: `hefty_chest/buf.yaml`, `hefty_chest/buf.gen.yaml`
- build_runner 2.10.4 - Dart code generation (Riverpod, go_router, Freezed)

## Key Dependencies

**Backend (HeftyBack/go.mod):**

**Critical:**
- connectrpc.com/connect v1.16.0 - RPC protocol implementation
- github.com/jackc/pgx/v5 v5.7.1 - PostgreSQL driver (high-performance)
- github.com/lib/pq v1.10.9 - PostgreSQL driver (legacy fallback)
- golang.org/x/net v0.48.0 - HTTP/2 support (h2c cleartext HTTP/2)

**Authentication:**
- github.com/golang-jwt/jwt/v5 v5.3.0 - JWT token generation and validation

**Database & Testing:**
- github.com/peterldowns/pgtestdb v0.1.1 - Isolated test databases per test
- github.com/peterldowns/pgtestdb/migrators/goosemigrator v0.1.1 - Goose integration for test migrations
- github.com/pressly/goose/v3 v3.22.1 (indirect) - Database migration tool

**Utilities:**
- github.com/google/uuid v1.6.0 - UUID generation (user IDs, session IDs, etc.)
- github.com/joho/godotenv v1.5.1 - .env file loading

**Testing:**
- github.com/stretchr/testify v1.9.0 - Assertion library for tests

**Middleware:**
- github.com/rs/cors v1.10.1 - CORS handler for HTTP requests

**Serialization:**
- google.golang.org/protobuf v1.33.0 - Protocol Buffer compiler and runtime

**Frontend (hefty_chest/pubspec.yaml):**

**Critical:**
- connectrpc ^1.0.0 - Connect-RPC client for Dart
- flutter_riverpod ^3.0.3 - State management
- riverpod_annotation ^3.0.3 - Code generation for providers
- go_router ^17.0.0 - Navigation with code generation
- forui ^0.17.0 - UI component library (dark theme, components)

**UI & Styling:**
- fl_chart ^0.69.0 - Charts for progress visualization (fitness graphs)
- cupertino_icons ^1.0.8 - iOS-style icons

**State Management & Hooks:**
- flutter_hooks ^0.21.3 - React-style hooks for Dart widgets
- hooks_riverpod ^3.0.3 - Integration between hooks and Riverpod

**Serialization & Data:**
- protobuf ^4.2.0 - Protocol Buffer runtime for Dart
- fixnum ^1.1.0 - Fixed-size numeric types for protobuf

**Utilities:**
- http ^1.2.2 - HTTP client for fetch API on web
- uuid ^4.5.1 - UUID generation (temp IDs, section IDs)
- intl ^0.20.0 - Internationalization (date/time formatting)
- equatable ^2.0.7 - Value equality mixin
- shared_preferences ^2.3.3 - Local device storage (sessions, settings)
- logging ^1.3.0 - Structured logging framework

**Immutable Data Structures:**
- freezed_annotation ^3.1.0 - Code generation for immutable classes

**Code Generation (Dev Dependencies):**
- build_runner ^2.10.4 - Code generation runner
- riverpod_generator ^3.0.3 - Generates provider code from @riverpod
- go_router_builder ^4.1.3 - Generates router code from @TypedGoRoute
- freezed ^3.2.3 - Generates immutable classes with copyWith
- mockito ^5.4.4 - Mock generation for testing
- flutter_lints ^6.0.0 - Dart linting rules

**Testing:**
- flutter_test - Built-in Flutter test framework
- integration_test - Built-in Flutter integration test framework

## Configuration

**Backend Environment (.env):**
- `SUPABASE_URL` - Supabase project URL (for future auth integration)
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- `SUPABASE_SERVICE_KEY` - Supabase service role key
- `DATABASE_URL` - PostgreSQL connection string (required)
- `PORT` - Server port (default: 8080)
- `TEST_MODE` - Enable test endpoints (`true`/`false`)

**Backend Build Configuration:**
- `HeftyBack/buf.yaml` - Buf CLI configuration (proto linting)
- `HeftyBack/buf.gen.yaml` - Proto code generation (Go + Connect-RPC)
- `HeftyBack/go.mod` - Go module definition
- `HeftyBack/Makefile` - Build, test, migration commands
- `HeftyBack/docker-compose.yml` - Local dev environment (PostgreSQL 15 + server)

**Frontend Build Configuration:**
- `hefty_chest/pubspec.yaml` - Dart dependencies and metadata
- `hefty_chest/buf.yaml` - Buf CLI configuration (proto linting)
- `hefty_chest/buf.gen.yaml` - Proto code generation (Dart)
- `hefty_chest/Makefile` - Build, test, code generation commands
- `hefty_chest/docker-compose.test.yml` - Integration test environment
- `hefty_chest/analysis_options.yaml` - Dart linting configuration

## Platform Requirements

**Development:**

Backend:
- Go 1.24.0+
- PostgreSQL 15+ or Docker (for postgres:15 image)
- Buf CLI (install: `brew install bufbuild/buf/buf`)
- Git

Frontend:
- Flutter SDK 3.10.3+
- Dart SDK 3.10.3+ (included with Flutter)
- iOS development: Xcode 15+ (macOS)
- Android development: Android Studio + SDK 21+ (any OS)
- Web development: Chrome/Firefox

**Production:**

Backend:
- Container runtime (Docker/Kubernetes)
- PostgreSQL 15+ database (Supabase or self-hosted)
- HTTP/2 capable reverse proxy or load balancer

Frontend:
- iOS 12.0+ (App Store distribution)
- Android 5.0+ (Google Play distribution)
- Modern web browser (Chrome, Safari, Firefox, Edge)

## Build & Deployment

**Backend Build:**
```bash
cd HeftyBack
make setup              # Install dependencies + generate + build
make build             # Compile to bin/server
docker build -t heft-backend:latest .  # Docker image
```

**Frontend Build:**
```bash
cd hefty_chest
flutter pub get        # Install dependencies
flutter pub run build_runner build --delete-conflicting-outputs  # Code generation
flutter build apk      # Android APK
flutter build ios      # iOS app
flutter build web      # Web app
flutter build appbundle  # Android App Bundle (Play Store)
```

**Deployment Targets:**
- Backend: Render (production), Docker containers
- Frontend: App Store (iOS), Google Play (Android), Flutter Web

## Serialization & Protocol

**RPC Protocol:** Connect-RPC over HTTP/2
- Message Format: Protocol Buffers (proto3)
- Codec Options:
  - Backend: ProtoCodec (efficient binary)
  - Frontend: JsonCodec (better web compatibility for nested timestamps)

**Proto Files Location:**
- Backend: `HeftyBack/proto/heft/v1/`
- Frontend: `hefty_chest/proto/`
- Status: Manually duplicated (not shared)

**Generated Code Location:**
- Backend: `HeftyBack/gen/heft/v1/` (Go code + Connect handlers)
- Frontend: `hefty_chest/lib/gen/` (Dart proto files + RPC clients)

---

*Stack analysis: 2026-03-10*
