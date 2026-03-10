# Phase 02: Fix UpdateProgram Handler - Research

**Researched:** 2026-03-10
**Domain:** Go backend — repository pattern, pgx SQL, Connect-RPC handler
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

None — no locked decisions in CONTEXT.md.

### Claude's Discretion

- Which fields are updatable (name, description, duration_weeks, duration_days, and/or days)
- Whether updating a program also replaces its days or just updates metadata
- SQL update strategy (partial update vs full replacement)
- Whether to add UpdateDay/DeleteDay methods or keep scope to program metadata only

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| PROG-04 | UpdateProgram handler applies changes to the database | Interface method + SQL UPDATE + handler wiring all mapped out below |
</phase_requirements>

## Summary

The UpdateProgram handler at `handlers/program.go:148-168` is a complete stub. It fetches the program with `GetByID`, verifies it exists, then returns the unmodified program without calling any write operation. The fix requires three coordinated changes: add `Update` to `ProgramRepositoryInterface`, implement the SQL in `ProgramRepository`, and replace the stub body with a real call.

The `UpdateProgramRequest` proto (already generated) carries optional fields: `name`, `description`, `duration_weeks`, `duration_days`, `is_archived`, and a `days` repeated field. Research recommendation: update all scalar metadata fields (name, description, duration_weeks, duration_days, is_archived) in one SQL statement, and also replace days using the delete-then-insert pattern already established by `CreateProgram`. This keeps the interface minimal (one `Update` method) while fully satisfying the proto contract.

The existing test infrastructure — `MockProgramRepository`, table-driven unit tests in `program_test.go`, and `testutil` mock patterns — is ready to extend. The existing `TestProgramHandler_UpdateProgram` test suite only tests the stub behaviour; the tests must be rewritten to assert the `Update` method is called and that changed fields are reflected in the response.

**Primary recommendation:** Add `Update(ctx, id, userID string, name *string, description **string, durationWeeks, durationDays *int, isArchived *bool, days []*UpdateProgramDay) (*Program, error)` to the interface, implement with a single SQL UPDATE + delete-then-insert for days, wire the handler to call it, then reload with `GetByID` to return the full updated record.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| pgx/v5 | v5 (already in go.mod) | PostgreSQL driver, `RETURNING` clause, `pgx.ErrNoRows` | Project standard; all existing repositories use it |
| connectrpc/connect | v1.16.0 | Error wrapping (`connect.NewError`) | Project standard; all handlers use it |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| testify/assert + require | already in go.mod | Test assertions | All existing unit tests use it |

**No new dependencies required.** This phase only adds within the existing stack.

## Architecture Patterns

### Recommended Project Structure

No structural changes. All changes are within existing files:

```
HeftyBack/internal/
├── repository/
│   ├── interfaces.go        # Add Update method to ProgramRepositoryInterface
│   └── program.go           # Add Update implementation
├── handlers/
│   └── program.go           # Replace stub body in UpdateProgram
└── testutil/
    └── mocks.go             # Add UpdateFunc field + method to MockProgramRepository
```

### Pattern 1: Interface-First, Compile-Time Check

**What:** Declare the method signature in `interfaces.go` before writing the implementation. The compile-time check `var _ ProgramRepositoryInterface = (*ProgramRepository)(nil)` (already present at line 101 of interfaces.go) will fail to compile until the implementation exists.

**When to use:** Every new repository method in this project. Mechanical rule from CLAUDE.md.

**Example (existing compile-time check):**
```go
// Source: HeftyBack/internal/repository/interfaces.go:101
var _ ProgramRepositoryInterface = (*ProgramRepository)(nil)
```

### Pattern 2: UPDATE with RETURNING

**What:** Issue a single `UPDATE ... SET ... WHERE id = $1 AND user_id = $2 RETURNING ...` to apply changes and retrieve the updated row atomically. No separate SELECT needed for the scalar fields.

**When to use:** Any mutation that must return the updated record. `SetActive` in program.go uses this pattern already.

**Example (SetActive, same file):**
```go
// Source: HeftyBack/internal/repository/program.go:207-224
query := `
    UPDATE programs
    SET is_active = TRUE, updated_at = CURRENT_TIMESTAMP
    WHERE id = $1 AND user_id = $2
    RETURNING id, user_id, name, description, duration_weeks, duration_days,
              total_workout_days, total_rest_days, is_active, is_archived, created_at, updated_at
`
var p Program
err = r.pool.QueryRow(ctx, query, id, userID).Scan(
    &p.ID, &p.UserID, &p.Name, &p.Description, &p.DurationWeeks, &p.DurationDays,
    &p.TotalWorkoutDays, &p.TotalRestDays, &p.IsActive, &p.IsArchived, &p.CreatedAt, &p.UpdatedAt,
)
```

### Pattern 3: Days Replacement (delete-then-insert)

**What:** When `days` is supplied in the request (len > 0), delete all existing `program_days` rows for that program, then insert the new ones using the existing `CreateDay` method. When `days` is empty/nil, leave days untouched.

**When to use:** When updating a program's schedule. The `program_days` table has `ON DELETE CASCADE` from the program but NOT from individual day updates — there is no UPDATE path for days in the current schema; delete+insert is the only clean approach.

**Why this approach:**
- `CreateProgram` already uses the same insert loop via `CreateDay`
- The `UNIQUE(program_id, day_number)` constraint on `program_days` makes partial updates without delete ambiguous
- The `total_workout_days` and `total_rest_days` columns on `programs` are computed counts that need to stay in sync — delete+insert keeps them consistent if we also recompute them in the UPDATE

### Pattern 4: Handler Sequence

**What:** The established handler sequence is: auth check → validate required fields → call repository → not-found check → return proto.

**When to use:** Every handler. Codified in `HeftyBack/internal/handlers/CLAUDE.md`.

**Example (GetProgram follows this exactly):**
```go
// Source: HeftyBack/internal/handlers/program.go:77-97
userID, ok := auth.UserIDFromContext(ctx)
if !ok { return nil, connect.NewError(connect.CodeUnauthenticated, ...) }
if req.Msg.Id == "" { return nil, connect.NewError(connect.CodeInvalidArgument, ...) }
program, err := h.programRepo.GetByID(ctx, req.Msg.Id, userID)
if err != nil { return nil, handleDBError(err) }
if program == nil { return nil, connect.NewError(connect.CodeNotFound, ...) }
return connect.NewResponse(&heftv1.GetProgramResponse{Program: programToProto(program)}), nil
```

**For UpdateProgram,** the sequence is: auth → validate id → call `Update` → not-found check → reload with `GetByID` → return. The reload is needed because `Update` returns scalar fields only; days are loaded by `GetByID`.

### Pattern 5: Nil Pointer for Optional Fields

**What:** Repository method parameters use pointer types (`*string`, `*int`, `*bool`) for optional fields. The SQL uses `COALESCE($N, existing_col)` or passes the pointer directly since pgx handles nil pointers as SQL NULL — which means the caller must pass current value when they don't want to change a field.

**When to use:** All optional-update parameters.

**Recommended approach for `Update` signature:** Accept Go pointer types for each optional proto field. The handler extracts them from `req.Msg.Name` (already `*string` in proto optional fields). This maps cleanly with no extra logic.

### Anti-Patterns to Avoid

- **Calling `GetByID` before `Update` to "verify existence" then calling `Update`:** The stub already does this. The fix removes the redundant pre-check. `Update` with `WHERE id = $1 AND user_id = $2` will naturally return `pgx.ErrNoRows` if the record doesn't exist — handle it as `nil, nil` (not found) per project pattern.
- **Hand-editing `gen/` files:** Proto is not changing in this phase; do not touch generated code.
- **Missing user_id scope in SQL:** Golden Principle #3. The UPDATE must include `WHERE user_id = $N`.
- **Importing pgx in handlers:** Golden Principle #4. Handler calls interface method only.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Optional field merging | Custom merge/patch logic | Direct SQL SET with the new value (caller sends what to set) | pgx handles nil pointers; COALESCE adds complexity with no benefit |
| Days update | In-place UPDATE per day | Delete existing rows + re-insert via CreateDay | UNIQUE constraint on (program_id, day_number) makes partial update fragile |
| Not-found detection after UPDATE | Separate SELECT before UPDATE | Return `nil, nil` when QueryRow returns `pgx.ErrNoRows` | Project pattern; consistent with GetByID |
| Response construction | Re-scan after UPDATE | Call `GetByID` after `Update` returns non-nil | Days are not returned by the UPDATE — GetByID loads them via `loadDays` |

**Key insight:** The delete-then-insert for days is the only safe path given the UNIQUE constraint and the need to recompute `total_workout_days` / `total_rest_days`.

## Common Pitfalls

### Pitfall 1: Not Reloading After Update

**What goes wrong:** Handler calls `Update` (which doesn't load days) and returns the partial `Program` struct, so `days` is nil in the response.

**Why it happens:** The `UPDATE ... RETURNING` only touches the `programs` table. Days live in `program_days` and are loaded separately by `loadDays`.

**How to avoid:** After a successful `Update` call, call `GetByID` to reload the full record with days — exactly as `SetActiveProgram` and `CreateProgram` do.

**Warning signs:** Response proto has empty `days` array even though days exist in DB.

### Pitfall 2: Forgetting to Update the Mock

**What goes wrong:** `MockProgramRepository` in `testutil/mocks.go` doesn't have an `UpdateFunc` field. After adding `Update` to the interface, the compile-time check `var _ ProgramRepositoryInterface = (*MockProgramRepository)(nil)` will fail.

**Why it happens:** The mock must implement every method in the interface.

**How to avoid:** Add `UpdateFunc` field + `Update` method to `MockProgramRepository` in the same PR as the interface change.

### Pitfall 3: total_workout_days and total_rest_days Drift

**What goes wrong:** After replacing days, the `programs.total_workout_days` and `programs.total_rest_days` counts no longer match the actual `program_days` rows.

**Why it happens:** These are denormalized counts, not computed columns. `CreateDay` doesn't update them automatically.

**How to avoid:** When days are replaced, recount from the new day list before writing the UPDATE SQL for the program — or include a subquery. The simplest approach: compute counts from the `days` slice in Go before calling Update, pass them as parameters, and include them in the SET clause.

### Pitfall 4: Existing UpdateProgram Tests Describe Stub Behaviour

**What goes wrong:** The existing `TestProgramHandler_UpdateProgram` success case asserts the returned name equals "Existing Program" — the unchanged value — because the stub never applies changes. These tests will pass even if Update is wired incorrectly unless a new test case asserts the changed name is returned.

**Why it happens:** Tests were written for stub, not for real implementation.

**How to avoid:** Replace the "success - returns existing program" case with "success - updates name, returns updated program" that verifies the new name comes back. Add a "success - no days in request, days unchanged" case and a "success - replaces days" case.

### Pitfall 5: days Replacement When No Days Sent

**What goes wrong:** Handler passes an empty slice as `days` arg and the repository unconditionally deletes and re-inserts zero days, wiping the program's schedule.

**Why it happens:** Proto repeated field sends `[]` when client omits days.

**How to avoid:** In the handler, only pass days to Update when `len(req.Msg.Days) > 0`. The interface method should take a `bool replaceDays` flag, or check nil vs empty slice in the handler before calling a days-replacement path.

## Code Examples

Verified patterns from existing codebase:

### Interface Method Signature (to add)

```go
// Source: HeftyBack/internal/repository/interfaces.go (new addition)
// In ProgramRepositoryInterface:
Update(ctx context.Context, id, userID string,
    name *string,
    description *string,
    durationWeeks *int,
    durationDays *int,
    isArchived *bool,
    totalWorkoutDays *int,
    totalRestDays *int,
) (*Program, error)
```

Note: Days replacement is handled separately at the handler level using existing `CreateDay` — keeping `Update` focused on scalar fields only.

### SQL UPDATE Pattern (modelled on SetActive)

```go
// Source pattern: HeftyBack/internal/repository/program.go:207-224 (SetActive)
query := `
    UPDATE programs
    SET name        = COALESCE($3, name),
        description = COALESCE($4, description),
        duration_weeks  = COALESCE($5, duration_weeks),
        duration_days   = COALESCE($6, duration_days),
        is_archived     = COALESCE($7, is_archived),
        total_workout_days = COALESCE($8, total_workout_days),
        total_rest_days    = COALESCE($9, total_rest_days),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = $1 AND user_id = $2
    RETURNING id, user_id, name, description, duration_weeks, duration_days,
              total_workout_days, total_rest_days, is_active, is_archived, created_at, updated_at
`
```

### Handler Wire-Up (condensed)

```go
// Source pattern: HeftyBack/internal/handlers/program.go:191-213 (SetActiveProgram)
// After calling h.programRepo.Update(...):
if updatedProgram == nil {
    return nil, connect.NewError(connect.CodeNotFound, errors.New("program not found"))
}
// Reload with days
program, err = h.programRepo.GetByID(ctx, updatedProgram.ID, userID)
if err != nil {
    return nil, handleDBError(err)
}
return connect.NewResponse(&heftv1.UpdateProgramResponse{
    Program: programToProto(program),
}), nil
```

### Days Replacement in Handler (uses existing CreateDay)

```go
// Source pattern: HeftyBack/internal/handlers/program.go:119-134 (CreateProgram days loop)
if len(req.Msg.Days) > 0 {
    // delete existing days first (repository method needed or direct via DeleteDays)
    if err := h.programRepo.DeleteDays(ctx, req.Msg.Id, userID); err != nil {
        return nil, handleDBError(err)
    }
    for _, d := range req.Msg.Days {
        dayType := programDayTypeToString(d.DayType)
        _, err := h.programRepo.CreateDay(ctx, req.Msg.Id, int(d.DayNumber), dayType,
            d.WorkoutTemplateId, d.CustomName)
        if err != nil {
            return nil, handleDBError(err)
        }
    }
}
```

This means `ProgramRepositoryInterface` also needs `DeleteDays(ctx, programID, userID string) error` — or the handler can call a single `ReplaceDays` method. The simplest approach aligned with existing code is a `DeleteDays` method scoped by `programID` and `userID`.

### Mock Addition (to add in mocks.go)

```go
// Source pattern: HeftyBack/internal/testutil/mocks.go:291-348 (MockProgramRepository)
// Add to MockProgramRepository struct:
UpdateFunc    func(ctx context.Context, id, userID string, name *string, ...) (*repository.Program, error)
DeleteDaysFunc func(ctx context.Context, programID, userID string) error

// Add method implementations:
func (m *MockProgramRepository) Update(...) (*repository.Program, error) {
    if m.UpdateFunc != nil {
        return m.UpdateFunc(...)
    }
    return nil, nil
}
func (m *MockProgramRepository) DeleteDays(ctx context.Context, programID, userID string) error {
    if m.DeleteDaysFunc != nil {
        return m.DeleteDaysFunc(ctx, programID, userID)
    }
    return nil
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Stub returns unchanged program | Real UPDATE persists to DB | Phase 02 (this phase) | PROG-04 requirement met |

**No deprecated patterns affect this phase.** pgx v5, Connect-RPC v1.16.0, and the repository pattern are all current.

## Open Questions

1. **DeleteDays: separate interface method or inline SQL in Update?**
   - What we know: CreateDay is used by CreateProgram; no DeleteDays exists yet
   - What's unclear: whether it's cleaner to add `DeleteDays` to the interface or fold it into a combined `Update` that accepts days directly
   - Recommendation: Add `DeleteDays(ctx, programID, userID string) error` to the interface for testability and separation of concerns. The handler composes Delete + CreateDay loop just like CreateProgram does.

2. **COALESCE vs explicit field passing**
   - What we know: proto optional fields are Go `*string`/`*int32` — nil when not set
   - What's unclear: whether to use COALESCE in SQL or require the handler to always send the current value
   - Recommendation: Use COALESCE so callers only set fields they want to change. Simpler handler logic.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Go testing + testify (already configured) |
| Config file | none — driven by Makefile |
| Quick run command | `cd HeftyBack && make test-unit` |
| Full suite command | `cd HeftyBack && make test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PROG-04 | UpdateProgram handler calls Update (not read-only path) | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestProgramHandler_UpdateProgram -v` | Partial (file exists, cases cover stub only — must be rewritten) |
| PROG-04 | UpdateProgram changes persist: name after update equals new name | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestProgramHandler_UpdateProgram/success_-_updates_name` | Wave 0 gap |
| PROG-04 | ProgramRepositoryInterface declares Update — compile-time check passes | compile | `cd HeftyBack && go build ./...` | Wave 0 gap |
| PROG-04 | Updating with days replaces existing days | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestProgramHandler_UpdateProgram/success_-_replaces_days` | Wave 0 gap |
| PROG-04 | Omitting days in request leaves days unchanged | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestProgramHandler_UpdateProgram/success_-_no_days_unchanged` | Wave 0 gap |

### Sampling Rate

- **Per task commit:** `cd HeftyBack && make test-unit`
- **Per wave merge:** `cd HeftyBack && make test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `HeftyBack/internal/handlers/program_test.go` — replace stub success case, add: "updates name", "replaces days", "no days unchanged", "Update DB error" cases
- [ ] `HeftyBack/internal/testutil/mocks.go` — add `UpdateFunc` and `DeleteDaysFunc` fields + method stubs to `MockProgramRepository`

*(Existing test file and mock file already exist; they need additions, not creation from scratch.)*

## Sources

### Primary (HIGH confidence)

- Direct code read: `HeftyBack/internal/repository/interfaces.go` — current ProgramRepositoryInterface (lines 70-79, 101)
- Direct code read: `HeftyBack/internal/handlers/program.go` — UpdateProgram stub (lines 147-168), SetActive reload pattern (lines 205-213)
- Direct code read: `HeftyBack/internal/repository/program.go` — SetActive UPDATE+RETURNING pattern (lines 199-224), loadDays helper (lines 126-156)
- Direct code read: `HeftyBack/internal/testutil/mocks.go` — MockProgramRepository struct (lines 291-348)
- Direct code read: `HeftyBack/migrations/00001_initial_schema.sql` — programs table columns, program_days UNIQUE constraint
- Direct code read: `HeftyBack/proto/heft/v1/program.proto` — UpdateProgramRequest optional fields (lines 118-126)
- Project CLAUDE.md — Golden Principles, architecture layers

### Secondary (MEDIUM confidence)

- Direct code read: `HeftyBack/internal/handlers/program_test.go` — existing UpdateProgram test structure (lines 821-919); confirms stub-only coverage
- Direct code read: `docs/testing.md` — test commands, infrastructure patterns

### Tertiary (LOW confidence)

None — all findings are from direct code inspection.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all libraries already in use; no new dependencies
- Architecture: HIGH — patterns copied directly from SetActive and CreateProgram in same file
- Pitfalls: HIGH — derived from direct reading of existing tests and SQL schema
- SQL strategy (COALESCE): MEDIUM — functional choice; alternative (full replacement) also valid

**Research date:** 2026-03-10
**Valid until:** Stable — no external dependencies; valid until schema changes
