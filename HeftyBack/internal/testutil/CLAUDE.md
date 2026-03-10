# Test Utilities

## Files

- `testdb.go` — `NewTestPool(t)` creates isolated pgtestdb per test with auto-migrations
- `testserver.go` — `NewTestServer(t, pool)` creates HTTP test server with all 7 service clients
- `mocks.go` — Mock repository implementations with function fields
- `fixtures.go` — `DefaultTestUser()`, `SeedTestUser()` for test data

## Mock Pattern

```go
type MockFooRepository struct {
    GetByIDFunc func(ctx context.Context, id string) (*Foo, error)
}

var _ repository.FooRepositoryInterface = (*MockFooRepository)(nil)

func (m *MockFooRepository) GetByID(ctx context.Context, id string) (*Foo, error) {
    if m.GetByIDFunc != nil {
        return m.GetByIDFunc(ctx, id)
    }
    return nil, nil  // Default: return nil, nil
}
```

## Rules

- Check `FuncField != nil` before calling — return nil/nil as default
- Compile-time interface check on every mock
- Use `uuid.New().String()[:8]` for unique test emails
- `DefaultTestUser()` generates unique user data per call
- `SeedTestUser(t, pool, user)` inserts and returns the user ID
