# HeftyBack — Backend Harness

Go API server. Connect-RPC over HTTP/2 with PostgreSQL (Supabase).

## Boundary Rules

Non-negotiable. Violations are bugs.

- **Handlers** (`internal/handlers/`) → Business logic + validation. Import repositories via interface. Never import `pgx`.
- **Repositories** (`internal/repository/`) → SQL queries only. Never import handler types. Always scope by `user_id`.
- **Middleware** (`internal/middleware/`) → Cross-cutting concerns (auth, logging). No business logic.
- **Generated code** (`gen/`) → Never hand-edit. Regenerate: `make generate`.

Dependency flow: `proto → config → repository → handlers → middleware → cmd/server`

## File Map

| Need to... | Look at |
|---|---|
| Add/modify an endpoint | `internal/handlers/{service}.go` |
| Add/modify a query | `internal/repository/{service}.go` |
| Change an interface | `internal/repository/interfaces.go` |
| Add a migration | `migrations/` → `make migrate-create name=xxx` |
| Change proto schema | `proto/heft/v1/*.proto` → `make generate` |
| Wire a new service | `cmd/server/main.go` |
| Add middleware | `internal/middleware/` |
| Write unit tests | `internal/handlers/{service}_test.go` |
| Write integration tests | `tests/integration/{service}_test.go` |
| Add test fixtures | `internal/testutil/fixtures.go` |
| Add mock methods | `internal/testutil/mocks.go` |

## Error Handling — Mechanical Rule

ALL handler errors use this exact pattern:

```go
// Validation → CodeInvalidArgument
if req.Msg.Field == "" {
    return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("field is required"))
}

// Not found → CodeNotFound
if result == nil {
    return nil, connect.NewError(connect.CodeNotFound, errors.New("resource not found"))
}

// DB errors → handleDBError() (FK violations → CodePermissionDenied)
if err != nil {
    return nil, handleDBError(err)
}
```

Codes: `Unauthenticated` (401) | `PermissionDenied` (403) | `InvalidArgument` (400) | `NotFound` (404) | `AlreadyExists` (409) | `Internal` (500)

## Auth — Mechanical Rule

User ID from JWT context. NEVER from request body.

```go
userID, ok := auth.UserIDFromContext(ctx)
if !ok {
    return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("user not authenticated"))
}
```

## User Scoping — Mechanical Rule

ALL queries on user data include user_id:

```go
// CORRECT
WHERE id = $1 AND user_id = $2

// WRONG — security vulnerability
WHERE id = $1
```

## Repository Pattern — Mechanical Rule

```go
// 1. Define interface in interfaces.go
type FooRepositoryInterface interface {
    GetFoo(ctx context.Context, userID, fooID string) (*Foo, error)
}

// 2. Implement in foo.go
type FooRepository struct { pool *pgxpool.Pool }
var _ FooRepositoryInterface = (*FooRepository)(nil)  // Compile-time check

// 3. Not found = nil, nil (not an error)
if errors.Is(err, pgx.ErrNoRows) {
    return nil, nil
}
```

## Commands

```bash
docker compose up -d              # Start server + PostgreSQL (port 5433)
make run                          # Run server directly
make test                         # All tests
make test-unit                    # Unit tests (no DB, fast)
make test-integration             # Integration tests (needs Docker)
make generate                     # Regenerate proto code
make migrate-create name=xxx      # New migration
make migrate-up                   # Apply migrations
make migrate-down                 # Rollback last
```

## Deep Reference

- Full services API, DB schema, DI wiring: `docs/backend.md`
- Testing infrastructure and patterns: `docs/testing.md`
- Architecture layers and data flow: `docs/architecture.md`
- Error codes and conventions: `docs/conventions.md`
