# Project Research Summary

**Project:** Heft — workout tracker bug fix milestone (rest timers + program scheduling)
**Domain:** Mobile workout tracking app (Go backend + Flutter frontend)
**Researched:** 2026-03-10
**Confidence:** HIGH

## Executive Summary

This is a correctness milestone for an existing, production-ready workout tracker. The full stack (Go 1.24 + Connect-RPC backend, Flutter/Dart + Riverpod frontend) is already in place and no new dependencies are required. Research was conducted via direct codebase inspection, yielding high-confidence, unambiguous findings. All 13 bugs identified in PROJECT.md are logic errors or missing schema elements — not architectural problems — and can be fixed with targeted, small changes to specific files.

The two subsystems under repair have a clear dependency ordering. The program scheduling system has a hard schema prerequisite: a `started_at` column must be added to the `programs` table before any day-calculation logic can be implemented. This migration must land first. The rest timer system has no schema dependencies, but its bugs have internal ordering constraints: template-to-session copy correctness must be verified before display order and overlay-trigger bugs can be properly tested. Both subsystems are otherwise independent of each other.

The primary risk in this milestone is treating individual bugs as fully isolated when they are not. Fixing `GetTodayWorkout` day calculation without first applying the `started_at` migration causes a runtime SQL error. Fixing the rest timer overlay trigger without verifying the rest items are correctly copied from templates means the fix cannot be tested end-to-end. The recommended mitigation is a strict dependency-ordered execution sequence, validated with integration tests at each step.

---

## Key Findings

### Recommended Stack

No new libraries are needed. Every bug is a logic error or missing database column. The existing stack handles all required patterns: `dart:async` Timer with `flutter_hooks` `useEffect` for countdown timers, `pgx` + goose migrations for the `started_at` schema addition, and standard Go time arithmetic for elapsed-day calculation.

**Core technologies relevant to fixes:**
- `dart:async` Timer + flutter_hooks 0.21.3: countdown timer pattern — fix `<= 1` to `<= 0` after decrement, consistent across both timer widgets
- pgx v5.7.1 + goose: database migration — `ALTER TABLE programs ADD COLUMN started_at TIMESTAMP` via `make migrate-create`
- Go 1.24 `time.Since()`: elapsed-day calculation — `int(elapsed.Hours() / 24)` gives correct floor division for program day number
- hooks_riverpod 3.0.3: session state — `completeRestItem()` notifier method; add `onTriggerRestTimer` callback wiring in `tracker_screen.dart`

**What NOT to use:**
- `time.Now().Day()` for day calculation (returns calendar day-of-month, not elapsed days)
- Storing `current_day_number` in DB and incrementing on session finish (creates second source of truth)
- `fmt.Fprintf` / `fmt.Fprintln` for logging (bypasses log level, leaks to stderr in production)

### Expected Features

All 13 bugs represent broken promised behavior. All are P1 — this is a correctness milestone.

**Must have (table stakes — currently broken):**
- Timer counts down to 0, then dismisses — `rest_item_card.dart` fires at 1 instead of 0
- Rest items from templates appear in sessions — nil-pointer check is overly restrictive
- Zero-duration rest items are not rendered — no guard exists in `tracker_screen.dart`
- Items display in template order — `displayOrder` must interleave exercises and rest items in a single sequence
- Standalone rest items trigger the rest timer overlay — `onTriggerRestTimer` callback not wired
- Program records `started_at` when activated — column missing from schema
- `GetTodayWorkout` returns correct day — hardcoded to day 1
- Completing a workout archives program on last day — no archival logic exists
- `UpdateProgram` handler persists changes — reads program, returns unchanged, never writes
- Today's Workout shown on home screen — no provider or widget calls `GetTodayWorkout`
- Debug `fmt.Fprintf` logging removed from production session handler

**Should have (competitive, post-bug-fix v1.x):**
- Rest timer audio/vibration alert — add once timer is correct
- Program progress bar on home screen — add once scheduling is correct

**Defer (v2+):**
- Adaptive rest duration suggestions (requires analytics pipeline)
- Program day makeup/skip UI (requires explicit completion tracking)
- Calendar month view (separate feature track)
- Program cycling/restart (makes day calculation ambiguous; cleaner model is archive + new activation)

### Architecture Approach

The architecture is layered and well-established. Bug fixes map precisely to existing files with no new abstractions required, except extending `ProgramRepositoryInterface` with `Update()`, `AdvanceDay()`, and `Archive()` methods. The two timer subsystems (per-set `RestTimerSheet` overlay and standalone `RestItemCard` inline timer) are intentionally independent — no coordination is needed. The `displayOrder` field is the single merge key for unified exercise + rest item rendering in `TrackerScreen`.

**Major components affected by fixes:**
1. `rest_item_card.dart` — timer off-by-one fix; `onTriggerRestTimer` callback wiring
2. `tracker_screen.dart` — zero-duration guard; display order sort correctness
3. `handlers/program.go` — `GetTodayWorkout` day calculation; `UpdateProgram` write wiring; program archival
4. `repository/program.go` + `interfaces.go` — add `Update()`, `Archive()`, `AdvanceDay()` methods
5. `migrations/00009_add_program_started_at.sql` — schema prerequisite for scheduling
6. `home_screen.dart` — wire `getTodayWorkout` provider, render "Today's Workout" card
7. `handlers/session.go` — remove `fmt.Fprintf`/`fmt.Fprintln` debug logging

### Critical Pitfalls

1. **Timer off-by-one exists in both timer widgets** — `rest_item_card.dart` has `<= 1` (wrong); `rest_timer_sheet.dart` has `<= 0` (correct). Fix must audit both widgets in the same pass, or the inconsistency survives.

2. **`started_at` migration must precede `GetTodayWorkout` handler fix** — implementing the handler calculation before the column exists causes a runtime SQL error that only surfaces at request time, not at startup. Create and apply the migration first, update `SetActive` to write `started_at`, update the `Program` struct and all `RETURNING` clauses, then implement the calculation.

3. **`UpdateProgram` is a 4-step fix, not a 1-step fix** — (1) add `Update` to `ProgramRepositoryInterface` in `interfaces.go`, (2) implement SQL in `repository/program.go` with `WHERE id = $1 AND user_id = $2`, (3) call it from the handler, (4) verify the compile-time interface check `var _ ProgramRepositoryInterface = (*ProgramRepository)(nil)` still passes. Stopping after step 3 compiles but will silently fail if the interface is not also updated.

4. **Program advance and archive must go through the repository interface** — handlers must never import `pgx` directly (Golden Principle 4). Add explicit `AdvanceDay()` and `Archive()` methods to `ProgramRepositoryInterface`. The compile-time check will fail until both interface and implementation are present, enforcing correctness.

5. **Zero-duration rest item filtering is bidirectional** — apply defense in depth: (a) backend `StartSession` should add guard `*item.RestDurationSeconds > 0` before inserting, and (b) frontend `tracker_screen.dart` should filter before building the display list. Either alone is insufficient if the other side creates or passes zero-duration items.

---

## Implications for Roadmap

Based on research, the bugs fall into two independent subsystems with internal dependency ordering. Suggested 3-phase structure:

### Phase 1: Foundation Fixes (No Dependencies)
**Rationale:** These bugs have no dependencies on each other or on schema changes. They are the safest to fix first and can be verified immediately.
**Delivers:** Correct program edit persistence; clean production logs; no more silent data loss on program edits
**Addresses:**
- `UpdateProgram` handler writes changes to DB
- Remove `fmt.Fprintf` / `fmt.Fprintln` debug logging from `handlers/session.go`
**Avoids:** Pitfall 2 (UpdateProgram 4-step chain); debug logging security pitfall

### Phase 2: Rest Timer System
**Rationale:** Rest timer bugs are all frontend-side (plus a backend nil-check) with internal ordering constraints: the template-copy fix must precede display order and overlay-trigger verification. No schema changes required.
**Delivers:** Correct countdown display (0:00 visible); rest items from templates appear correctly; items in correct order; standalone rest items trigger the overlay timer
**Addresses:**
- Timer counts to 0 (not 1) — `rest_item_card.dart` and `rest_timer_sheet.dart`
- Rest items from template copied correctly into sessions
- Zero-duration rest items not rendered (backend insert guard + frontend filter)
- Rest items and exercises in correct display order
- Standalone rest items trigger `RestTimerSheet` overlay
**Avoids:** Pitfall 1 (audit both timer widgets); Pitfall 4 (zero-duration bidirectional filter); Pitfall 6 (display order source of truth)

### Phase 3: Program Scheduling System
**Rationale:** Hard schema prerequisite (`started_at` migration) must land before any handler logic can be written. Once migration and `SetActive` are updated, the day calculation, archival, and home screen wiring follow in dependency order.
**Delivers:** Programs track start date; `GetTodayWorkout` returns correct day; programs archive on completion; Today's Workout shown on home screen
**Addresses:**
- `started_at` migration (prerequisite — must be first step in this phase)
- `SetActive` writes `started_at = CURRENT_TIMESTAMP`
- `GetTodayWorkout` calculates correct day from elapsed time
- `FinishSession` triggers program archival on last day
- Program archives to `is_archived = TRUE, is_active = FALSE`
- Home screen wired to `GetTodayWorkout` provider
**Avoids:** Pitfall 3 (migration before handler); Pitfall 5 (repository pattern for archive/advance)

### Phase Ordering Rationale

- Phase 1 first because it has zero dependencies and delivers immediate correctness wins
- Phase 2 before Phase 3 because rest timer fixes are frontend-heavy and validate the template data pipeline, which is useful context for Phase 3
- Phase 3 last because it has the hardest prerequisite (schema migration) and the most multi-step change chain
- Program cycling, day-skip UI, and audio alerts are explicitly out of scope — these would introduce architectural complexity that contradicts the "archive on completion" mental model

### Research Flags

Phases with well-documented patterns (no additional research needed):
- **Phase 1:** Both fixes are straightforward — one is a 4-step handler/repository chain, one is a grep-and-delete. Patterns are established in the codebase.
- **Phase 2:** All fixes map to identified lines of code. Timer pattern is standard `dart:async`. No unknowns.
- **Phase 3:** Migration + elapsed-day calculation are well-documented Go + SQL patterns. The home screen wiring follows the existing provider pattern used in other features.

No phase requires `/gsd:research-phase` during planning. All implementation paths are known from codebase inspection.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All findings from direct `go.mod` and `pubspec.yaml` inspection; no inference |
| Features | HIGH | Bugs confirmed at specific file:line locations; behavior contracts unambiguous |
| Architecture | HIGH | Component boundaries confirmed from source; data flow traced end-to-end |
| Pitfalls | HIGH | Pitfalls derived from actual bugs in actual code, not hypothetical risks |

**Overall confidence:** HIGH

### Gaps to Address

- **`started_at` for existing active programs:** Programs that were activated before the migration will have `NULL` for `started_at`. The `GetTodayWorkout` handler must handle the nil case gracefully (treat as day 1, or prompt re-activation). A data migration to backfill `started_at = created_at` for active programs is an option but may not be accurate.
- **`program_id` ownership in `StartSession`:** The handler accepts `program_id` from the client but does not validate it belongs to the authenticated user. This is a latent security issue noted in PITFALLS.md but not in the 13-bug list. Flagged for awareness; address in a follow-on security pass.
- **Rest item display order source of truth:** If the template builder does not guarantee a single monotonically increasing `display_order` sequence across exercise and rest items within a section, the sort will produce incorrect ordering. Verify the template editor assigns unified display orders, or add an integration test that covers the interleaved ordering case.

---

## Sources

### Primary (HIGH confidence — direct codebase inspection)
- `HeftyBack/internal/handlers/session.go` — debug logging location, rest item insertion nil check
- `HeftyBack/internal/handlers/program.go` — UpdateProgram stub, GetTodayWorkout hardcoded day 1
- `HeftyBack/internal/repository/program.go` — SetActive missing started_at, no Update/Archive/AdvanceDay
- `HeftyBack/internal/repository/interfaces.go` — ProgramRepositoryInterface gaps
- `HeftyBack/migrations/` (00001 through 00008) — schema reference; programs table has no started_at
- `hefty_chest/lib/features/tracker/widgets/rest_item_card.dart` — off-by-one at `<= 1`
- `hefty_chest/lib/features/tracker/widgets/rest_timer_sheet.dart` — correct `<= 0` for comparison
- `hefty_chest/lib/features/tracker/tracker_screen.dart` — display order merge logic, rest item rendering
- `hefty_chest/lib/features/tracker/providers/session_providers.dart` — sync pattern, rest item completion
- `hefty_chest/pubspec.yaml` — frontend dependency versions
- `HeftyBack/go.mod` — backend dependency versions
- `.planning/PROJECT.md` — 13 named bugs and scope decisions

### Secondary (MEDIUM confidence)
- Strong / Hevy app behavior patterns — calendar-based program day calculation, countdown-to-zero timer UX (industry norm confirmed)

---
*Research completed: 2026-03-10*
*Ready for roadmap: yes*
