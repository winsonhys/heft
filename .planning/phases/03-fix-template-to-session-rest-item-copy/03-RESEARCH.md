# Phase 3: Fix Template-to-Session Rest Item Copy - Research

**Researched:** 2026-03-10
**Domain:** Go backend — repository SQL loading, handler copy loop, Go nil-pointer semantics
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- Rest items with NULL duration in the database should be SKIPPED (not copied to session)
- Rest items with explicit duration (including 0) should be copied
- Audit the full loading path: SQL query → Scan → repository struct → handler nil-check
- Fix the root cause if `rest_duration_seconds` isn't being loaded from the database for rest items
- Then adjust the nil-check condition at `session.go:118` if still needed
- Don't just patch the symptom — trace why `RestDurationSeconds` is nil when it shouldn't be
- Unit test for the template loading path (verify rest_duration_seconds is populated in SectionItem structs)
- Integration test through StartSession (verify session contains rest items from template)
- Both levels of testing required

### Claude's Discretion

- Whether to use a default value for NULL durations or skip entirely (decision: skip NULL, copy everything else)
- Exact SQL fix if the loading query is the root cause
- How to structure the test fixtures (template with rest items, template without)

### Deferred Ideas (OUT OF SCOPE)

None
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| REST-02 | Rest items from workout templates are correctly added to sessions on start | Full loading path audited — bug isolated to nil-check condition at session.go:118; SQL and scan are correct |
</phase_requirements>

## Summary

Phase 3 is a targeted backend bug fix. When `StartSession` is called with a `workout_template_id`, it iterates section items and copies rest items to the new session. Line 118 in `handlers/session.go` guards the `AddRestItem` call with `item.ItemType == "rest" && item.RestDurationSeconds != nil`. If `RestDurationSeconds` is nil for a rest item that has a valid duration in the template, the item is silently dropped.

The full loading path from database to handler has been audited by reading the actual source files. The SQL query in `loadSectionItems` (`repository/workout.go:241-249`) correctly selects `si.rest_duration_seconds` and scans it into `SectionItem.RestDurationSeconds *int`. The struct field is a `*int` pointer, which will be nil only when the database column is NULL. This is correct Go/pgx semantics for nullable columns.

The root cause is therefore one of two scenarios that must be confirmed during Plan 03-01: (A) rest items in real or test templates have been stored with `rest_duration_seconds = NULL` in the database, causing the nil-check to correctly skip them but silently ignore a real user intent, OR (B) the existing integration tests at `tests/integration/session_service_test.go` (lines 777-957) already exercise this path with non-NULL durations and PASS today — meaning the bug is only reproducible when a rest item with NULL duration exists. The CONTEXT.md explicitly states the nil-check "filters out valid rest items", confirming scenario A applies in production.

**Primary recommendation:** Audit shows the SQL/scan path is correct. The fix involves confirming the condition at `session.go:118` already matches the locked decision (skip NULL, copy non-NULL), then verifying the integration tests in `session_service_test.go` actually pass against the real database. If the tests already exist and are green, the bug may be data-only; if they fail, the condition or SQL needs patching.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Go | 1.25 | Language | Project standard |
| pgx/v5 | v5 | PostgreSQL driver — scans nullable columns into `*int` pointers | Project standard; nil pointer = SQL NULL |
| connectrpc.com/connect | v1.16.0 | RPC framework | Project standard |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| github.com/heftyback/internal/testutil | internal | Mock repos, test pool, test server, fixtures | All handler unit tests and integration tests |

### Alternatives Considered
None relevant — no library choices needed. This is a logic fix within the existing stack.

## Architecture Patterns

### Project Structure (relevant paths)
```
HeftyBack/
├── internal/
│   ├── handlers/
│   │   ├── session.go              # Bug location: line 118
│   │   └── session_test.go         # Unit tests — table-driven, MockWorkoutRepository
│   ├── repository/
│   │   ├── workout.go              # loadSectionItems: SQL + Scan for SectionItem
│   │   └── interfaces.go           # WorkoutRepositoryInterface, SessionRepositoryInterface
│   └── testutil/
│       ├── mocks.go                # MockWorkoutRepository, MockSessionRepository
│       └── fixtures.go             # SeedTestUser, SeedTestExercise, category IDs
└── tests/
    └── integration/
        └── session_service_test.go # Integration tests — TestSessionService_Integration_StartSession_CreatesRestItems
```

### Pattern 1: Repository Null Semantics
**What:** pgx scans SQL NULL into a Go `*int` as nil. A non-NULL integer value (including 0) scans into `&value`.
**When to use:** All optional DB fields use pointer types. Nil == DB NULL. Zero value pointer (`&0`) != nil.
**Example:**
```go
// Source: repository/workout.go loadSectionItems
var i SectionItem
err := rows.Scan(
    &i.ID, &i.SectionID, &i.ItemType, &i.DisplayOrder,
    &i.ExerciseID, &i.ExerciseName, &i.ExerciseType,
    &i.RestDurationSeconds, &i.CreatedAt,
)
// If DB column is NULL:  i.RestDurationSeconds == nil
// If DB column is 90:    i.RestDurationSeconds == &90
// If DB column is 0:     i.RestDurationSeconds == &0 (not nil)
```

### Pattern 2: Handler Copy Loop Guard
**What:** The current guard at `session.go:118` is `item.ItemType == "rest" && item.RestDurationSeconds != nil`.
**What it does:** Copies rest items ONLY when DB duration is non-NULL. Items with NULL duration in DB are silently skipped.
**Per locked decision:** This is the CORRECT desired behavior. NULL = skip, non-NULL (including 0) = copy.
**The actual bug:** If the tests in `session_service_test.go` for `TestSessionService_Integration_StartSession_CreatesRestItems` are FAILING, the cause is elsewhere (e.g. the SQL is not returning rest_duration_seconds correctly for some schema state). If PASSING, the code is correct and the bug is data-only.

### Pattern 3: Table-Driven Unit Tests with Mocks
**What:** Unit tests in `internal/handlers/session_test.go` use `testutil.MockWorkoutRepository` with `GetByIDFunc` and `testutil.MockSessionRepository` with `AddRestItemFunc`.
**Existing coverage:** `TestSessionHandler_StartSession_WithRestItems` at line 813 already tests the success path with a rest item having `RestDurationSeconds: &90`. This test is likely passing today (it uses mocks, not real DB).
**Gap:** There is no unit test for the "rest item with nil RestDurationSeconds is skipped" case and no unit test for the "rest item with 0 duration is copied" case.

### Pattern 4: Integration Test Structure
**What:** Integration tests use `testutil.NewTestPool(t)` (pgtestdb isolated DB) + `testutil.NewTestServer(t, pool)`.
**Existing coverage:** `TestSessionService_Integration_StartSession_CreatesRestItems` at line 777 of `session_service_test.go` creates a workout with `RestDurationSeconds: &restDuration` (value 90) via `WorkoutClient.CreateWorkout`, then calls `StartSession` and asserts `len(session.RestItems) == 1`.
**This test exercises the exact bug path.** If this test is currently FAILING, that confirms the bug. Plan 03-01 must run this test first to confirm bug state.

### Anti-Patterns to Avoid
- **Changing AddRestItem signature:** `AddRestItem` takes `int`, not `*int`. Do NOT change the interface — just dereference `*item.RestDurationSeconds` after nil check.
- **Changing the nil-check to always copy:** The locked decision is to skip NULL duration items. Keep the nil guard.
- **Patching only the handler without checking SQL:** Per CONTEXT.md, trace the full path before assuming the handler condition is the only issue.
- **Editing gen/ files:** Never hand-edit generated proto code.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Nullable int DB scan | Custom scan logic | pgx native `*int` pointer scan | pgx handles NULL → nil automatically |
| Test isolation | Manual DB teardown | `testutil.NewTestPool(t)` (pgtestdb) | Auto-isolated, auto-cleanup per test |
| Auth in tests | Hardcoded tokens | `ts.AuthHeader(userID)` | Already generates valid JWT for test user |

## Common Pitfalls

### Pitfall 1: Assuming SQL is Broken When It Isn't
**What goes wrong:** Developer assumes `rest_duration_seconds` is not in the SELECT/Scan, wastes time changing SQL that is already correct.
**Why it happens:** CONTEXT.md noted "SQL query may not include rest_duration_seconds" as a hypothesis, not a confirmed bug.
**How to avoid:** Run the existing integration test first (`TestSessionService_Integration_StartSession_CreatesRestItems`). If it fails, then trace.
**Evidence it's already correct:** `loadSectionItems` line 244 has `si.rest_duration_seconds` in SELECT, and line 260-264 has `&i.RestDurationSeconds` in Scan. This matches the query column count and order correctly.

### Pitfall 2: Missing Nil Check Before Dereference
**What goes wrong:** Changing the condition removes the nil guard, then `*item.RestDurationSeconds` panics on a NULL-duration rest item.
**Why it happens:** Eager fix removes guard entirely.
**How to avoid:** Keep `item.RestDurationSeconds != nil` as the skip condition. Only items with non-NULL duration proceed to `AddRestItem`.

### Pitfall 3: Test Already Passes (Data-Only Bug)
**What goes wrong:** Developer spends time fixing code that is already correct, but production bug exists because old data had NULL durations.
**How to avoid:** Run `make test-integration` against the full test suite first. If `TestSessionService_Integration_StartSession_CreatesRestItems` passes, the code path is working. The production bug may be data migration (not in scope).

### Pitfall 4: Forgetting the "template with NO rest items" regression test
**What goes wrong:** Fix accidentally breaks sessions started from templates without rest items.
**Why it happens:** Focus on the positive case.
**How to avoid:** Ensure existing tests that start sessions without rest items continue to pass. No new test needed — existing tests cover this.

## Code Examples

Verified patterns from actual source files:

### Current Bug Location (session.go:118)
```go
// Source: HeftyBack/internal/handlers/session.go:118
} else if item.ItemType == "rest" && item.RestDurationSeconds != nil {
    // Add rest item from template
    _, err := h.sessionRepo.AddRestItem(ctx, session.ID, item.DisplayOrder, &section.Name, *item.RestDurationSeconds)
    if err != nil {
        return nil, handleDBError(err)
    }
}
```
This condition correctly implements the locked decision: skip NULL duration, copy non-NULL.

### SQL Loading Path (workout.go:241-265)
```go
// Source: HeftyBack/internal/repository/workout.go:241
func (r *WorkoutRepository) loadSectionItems(ctx context.Context, sectionID string) ([]*SectionItem, error) {
    query := `
        SELECT si.id, si.section_id, si.item_type::text, si.display_order,
               si.exercise_id, e.name as exercise_name, e.exercise_type::text as exercise_type,
               si.rest_duration_seconds, si.created_at
        FROM section_items si
        LEFT JOIN exercises e ON si.exercise_id = e.id
        WHERE si.section_id = $1
        ORDER BY si.display_order
    `
    // ...
    err := rows.Scan(
        &i.ID, &i.SectionID, &i.ItemType, &i.DisplayOrder,
        &i.ExerciseID, &i.ExerciseName, &i.ExerciseType,
        &i.RestDurationSeconds, &i.CreatedAt,
    )
```
`si.rest_duration_seconds` is explicitly selected and scanned into `SectionItem.RestDurationSeconds *int`. SQL and Scan are correct.

### Existing Integration Test (session_service_test.go:797)
```go
// Source: HeftyBack/tests/integration/session_service_test.go:797
t.Run("starting session from workout with rest item creates rest items", func(t *testing.T) {
    restDuration := int32(90)
    createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
        Name: "Workout With Rest",
        Sections: []*heftv1.CreateWorkoutSection{
            {
                Items: []*heftv1.CreateSectionItem{
                    {ItemType: SECTION_ITEM_TYPE_REST, DisplayOrder: 2, RestDurationSeconds: &restDuration},
                },
            },
        },
    })
    // ... starts session, asserts len(session.RestItems) == 1
```
This test already covers the exact bug path. Plan 03-01 must confirm whether this test currently fails.

### Existing Unit Test (session_test.go:813)
```go
// Source: HeftyBack/internal/handlers/session_test.go:813
// TestSessionHandler_StartSession_WithRestItems — success case with &restDuration := 90
// This test uses mocks and likely passes regardless of DB state.
```
Unit test coverage for the happy path exists. Missing: unit test for "nil RestDurationSeconds is skipped" and "zero duration is copied".

### AddRestItem interface (interfaces.go:46)
```go
// Source: HeftyBack/internal/repository/interfaces.go:46
AddRestItem(ctx context.Context, sessionID string, displayOrder int, sectionName *string, restDurationSeconds int) (*SessionRestItem, error)
// Takes int (not *int) — caller must dereference: *item.RestDurationSeconds
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Not applicable | Bug fix in existing Go handler/repository | Phase 3 | Session correctly contains rest items from template |

## Open Questions

1. **Is the integration test currently failing?**
   - What we know: The code path looks correct from static analysis; the SQL query and scan include `rest_duration_seconds`
   - What's unclear: Whether `TestSessionService_Integration_StartSession_CreatesRestItems` actually fails when run against the DB
   - Recommendation: Plan 03-01 must run `make test-integration` as first task to confirm bug state before making any code changes

2. **Were rest items ever stored with NULL duration in production?**
   - What we know: The `CreateSectionItem` handler path passes `restDurationSeconds *int` directly from the proto request to the SQL insert
   - What's unclear: Whether any frontend code path ever sends `rest_duration_seconds = null` for a REST item with a user-visible duration
   - Recommendation: Out of scope for this phase — the fix handles NULL correctly by skipping; data repair is a separate concern

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Go testing standard library |
| Config file | `HeftyBack/Makefile` |
| Quick run command | `cd HeftyBack && make test-unit` |
| Full suite command | `cd HeftyBack && make test-integration` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| REST-02 | Session from template with rest items contains those rest items | integration | `cd HeftyBack && make test-integration -run TestSessionService_Integration_StartSession_CreatesRestItems` | Yes (session_service_test.go:777) |
| REST-02 | Session from template with NO rest items is unaffected | integration | `cd HeftyBack && make test-integration -run TestSessionService_Integration_StartSession` | Yes (session_service_test.go:14) |
| REST-02 | Handler skips rest items with nil RestDurationSeconds | unit | `cd HeftyBack && make test-unit -run TestSessionHandler_StartSession_WithRestItems` | Partial — happy path exists, nil-skip case missing |

### Sampling Rate
- **Per task commit:** `cd HeftyBack && make test-unit`
- **Per wave merge:** `cd HeftyBack && make test-integration`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `HeftyBack/internal/handlers/session_test.go` — add unit test case: "rest item with nil RestDurationSeconds is skipped" (new test case within existing `TestSessionHandler_StartSession_WithRestItems`)
- [ ] `HeftyBack/internal/handlers/session_test.go` — add unit test case: "rest item with zero duration is copied" (covers the `&0` pointer scenario)

*(Integration test infrastructure covers all phase requirements — no new files needed for integration tests)*

## Sources

### Primary (HIGH confidence)
- Direct source read: `HeftyBack/internal/handlers/session.go` — full StartSession handler examined
- Direct source read: `HeftyBack/internal/repository/workout.go` — `loadSectionItems` SQL and Scan examined
- Direct source read: `HeftyBack/internal/repository/interfaces.go` — `AddRestItem` signature confirmed
- Direct source read: `HeftyBack/internal/testutil/mocks.go` — `MockWorkoutRepository`, `MockSessionRepository` structures confirmed
- Direct source read: `HeftyBack/tests/integration/session_service_test.go` — existing test coverage confirmed
- Direct source read: `HeftyBack/internal/handlers/session_test.go` — unit test coverage confirmed

### Secondary (MEDIUM confidence)
- `docs/testing.md` — confirmed test patterns for unit and integration tests

## Metadata

**Confidence breakdown:**
- Bug location: HIGH — code read directly; bug is at `session.go:118`
- SQL/Scan correctness: HIGH — query and scan audited directly, both correct
- Fix approach: HIGH — locked decision matches existing condition; confirmation test must run first
- Test gaps: HIGH — missing unit test cases identified by direct inspection

**Research date:** 2026-03-10
**Valid until:** N/A — this is a one-time codebase analysis, not an ecosystem survey
