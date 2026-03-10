# Integration Tests

Test full RPC flow against a real database. Requires Docker (`docker compose up -d`).

## Pattern

```go
func TestFooService_Integration(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test in short mode")
    }

    pool := testutil.NewTestPool(t)        // Fresh isolated database
    ts := testutil.NewTestServer(t, pool)  // HTTP server with all clients

    // Seed test data
    testUser := testutil.DefaultTestUser()
    userID := testutil.SeedTestUser(t, pool, testUser)

    t.Run("authenticated request", func(t *testing.T) {
        req := connect.NewRequest(&heftv1.SomeRequest{})
        req.Header().Set("Authorization", ts.AuthHeader(userID))

        resp, err := ts.FooClient.SomeMethod(context.Background(), req)
        // assertions...
    })
}
```

## Rules

- Always guard with `testing.Short()` skip
- Use `testutil.NewTestPool(t)` — creates isolated DB per test, auto-cleanup
- Use `ts.AuthHeader(userID)` for authenticated requests
- Seed data via `testutil.SeedTestUser()` and fixtures — never hardcode UUIDs
- Available clients: `ts.AuthClient`, `ts.UserClient`, `ts.ExerciseClient`, `ts.WorkoutClient`, `ts.ProgramClient`, `ts.SessionClient`, `ts.ProgressClient`

## Run

```bash
docker compose up -d && make test-integration
```
