---
phase: 02-fix-updateprogram-handler
plan: 01
subsystem: backend
tags: [go, repository, handlers, program, update, tdd]
dependency_graph:
  requires: []
  provides: [Update and DeleteDays on ProgramRepositoryInterface, wired UpdateProgram handler]
  affects: [HeftyBack/internal/repository, HeftyBack/internal/handlers, HeftyBack/internal/testutil]
tech_stack:
  added: []
  patterns: [COALESCE SQL for partial updates, EXISTS subquery for user-scoped deletes, TDD red-green cycle, reload-after-update pattern]
key_files:
  created: []
  modified:
    - HeftyBack/internal/repository/interfaces.go
    - HeftyBack/internal/repository/program.go
    - HeftyBack/internal/testutil/mocks.go
    - HeftyBack/internal/handlers/program.go
    - HeftyBack/internal/handlers/program_test.go
decisions:
  - COALESCE used in UPDATE SQL so only provided fields are changed, nil args leave existing values unchanged
  - totalWorkoutDays and totalRestDays computed in handler when days are provided, not in repository
  - Days replacement is delete-then-insert (DeleteDays + CreateDay loop), matching existing CreateProgram pattern
  - Reload via GetByID after Update is necessary because Update RETURNING does not include days
  - User-scoping for DeleteDays uses EXISTS subquery to avoid joining program_days to programs on every row
metrics:
  duration: 2 min
  completed: "2026-03-10"
  tasks_completed: 2
  files_changed: 5
---

# Phase 2 Plan 1: Wire UpdateProgram Handler Summary

**One-liner:** UpdateProgram handler now calls repo.Update with COALESCE SQL for partial field updates and delete-then-insert day replacement.

## What Was Built

The UpdateProgram handler was a stub that called GetByID and returned the program unchanged. This plan wired the full implementation:

1. `ProgramRepositoryInterface` gained two new methods: `Update` and `DeleteDays`.
2. `ProgramRepository` implements both with user-scoped SQL.
3. `MockProgramRepository` gained `UpdateFunc` and `DeleteDaysFunc` fields and method stubs.
4. The `UpdateProgram` handler was rewritten to call `Update` with optional fields via COALESCE, replace days when provided, then reload via `GetByID`.
5. Unit tests were rewritten to assert real update behavior: name changes, day replacement, days-unchanged path, and error paths.

## Decisions Made

- **COALESCE in UPDATE SQL**: Allows partial updates — passing nil for a field leaves the existing DB value. Matches the optional proto fields pattern.
- **totalWorkoutDays/totalRestDays computed in handler**: The handler counts WORKOUT and REST days from the request before calling Update, so the DB stays consistent. These are nil when no days are in the request.
- **Delete-then-insert for days**: DeleteDays removes all days for the program (user-scoped via EXISTS), then CreateDay is called per new day. Same pattern as CreateProgram.
- **Reload via GetByID after Update**: The UPDATE RETURNING clause only returns scalar columns. GetByID is needed to load the days for the response. Matches the SetActiveProgram pattern.

## Tasks Completed

| Task | Name | Commit | Key Files |
|------|------|--------|-----------|
| 1 | Add Update and DeleteDays to repository interface, implementation, and mock | 78d1ba4 | interfaces.go, program.go, mocks.go |
| 2 | Wire UpdateProgram handler and rewrite unit tests | 4685d33 | program.go, program_test.go |

## Verification Results

- `go build ./...` compiles cleanly
- `go test ./internal/handlers/ -run TestProgramHandler_UpdateProgram -v` — all 7 cases pass
- `make test-unit` — no regressions (all handler unit tests pass)
- `h.programRepo.Update(` present in handlers/program.go line 198
- `h.programRepo.DeleteDays(` present in handlers/program.go line 210
- `h.programRepo.GetByID(` reload present in handlers/program.go line 230

## Deviations from Plan

None — plan executed exactly as written.

## Self-Check: PASSED

Files exist:
- HeftyBack/internal/repository/interfaces.go — FOUND
- HeftyBack/internal/repository/program.go — FOUND
- HeftyBack/internal/testutil/mocks.go — FOUND
- HeftyBack/internal/handlers/program.go — FOUND
- HeftyBack/internal/handlers/program_test.go — FOUND

Commits exist:
- 78d1ba4 — FOUND (feat(02-01): add Update and DeleteDays to repository interface, implementation, and mock)
- 4685d33 — FOUND (feat(02-01): wire UpdateProgram handler and rewrite unit tests)
