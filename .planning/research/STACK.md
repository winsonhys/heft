# Stack Research

**Domain:** Workout tracker bug fix — rest timer (Flutter) and program day scheduling (Go + PostgreSQL)
**Researched:** 2026-03-10
**Confidence:** HIGH (all findings drawn from direct codebase inspection; no training-data guesses)

---

## Context

This is not a greenfield project. The full stack is already chosen and in production:

- **Backend:** Go 1.24, Connect-RPC v1.16.0, pgx v5.7.1, PostgreSQL (goose migrations)
- **Frontend:** Flutter / Dart SDK ^3.10.3, Riverpod 3.0.3, flutter_hooks 0.21.3, freezed 3.2.3, forui 0.17.0

No new libraries are needed for these bug fixes. Every bug is a logic error or missing database column, not a missing dependency.

---

## Recommended Stack

### Core Technologies (already in place)

| Technology | Version | Purpose | Why It Handles These Bugs |
|------------|---------|---------|--------------------------|
| Flutter / Dart | SDK ^3.10.3 | Mobile UI and timer logic | `dart:async` Timer + flutter_hooks `useEffect` is the correct pattern for countdown timers in this codebase |
| flutter_hooks | 0.21.3 | Stateful hook lifecycle in widgets | `RestItemCard` already uses `HookWidget` with `useState` and `useEffect`; the off-by-one fix lives entirely here |
| hooks_riverpod | 3.0.3 | Session state management | `ActiveSession` notifier owns rest item completion; the standalone rest trigger is a provider method addition |
| freezed_annotation | 3.1.0 | Immutable models with `copyWith()` | `SessionRestItemModel` already frozen; no model changes needed for timer bugs |
| Go 1.24 | — | Backend program scheduling logic | `GetTodayWorkout` day-calculation and `UpdateProgram` save are pure Go business logic fixes |
| pgx v5.7.1 | — | PostgreSQL queries | `SetActive` needs one new `started_at` write; `UpdateProgram` needs actual UPDATE SQL |
| goose (via pgtestdb/goosemigrator) | pressly/goose v3.22.1 | Database migrations | New migration required: `ALTER TABLE programs ADD COLUMN started_at TIMESTAMP` |

### Supporting Libraries (already in place, confirming usage)

| Library | Version | Purpose | When Used in This Milestone |
|---------|---------|---------|----------------------------|
| `dart:async` Timer | built-in | Periodic countdown | `RestItemCard.useEffect` timer loop — fixes countdown-to-0 |
| `connectrpc.com/connect` | v1.16.0 | RPC error codes | No change needed; existing error mapping is correct |
| `riverpod_annotation` | 3.0.3 | Code-gen providers | `@riverpod` on `ActiveSession` — no new providers required |
| `build_runner` | 2.10.4 | Provider codegen | Run after any provider annotation change |
| `google.golang.org/protobuf` | v1.33.0 | Proto serialization | `started_at` timestamp field needs adding to `Program`/`ProgramSummary` protos |
| `timestamppb` | (bundled with protobuf) | Go ↔ proto timestamp conversion | Used in `programToProto` when serializing `started_at` |

### Development Tools (already configured)

| Tool | Purpose | Notes |
|------|---------|-------|
| `make migrate-create name=xxx` | Create new goose migration | Use for `started_at` column addition |
| `make generate` + `buf generate` | Regenerate proto code in both projects | Required if adding `started_at` to proto |
| `flutter pub run build_runner build --delete-conflicting-outputs` | Regenerate Riverpod/router code | Run after any `@riverpod` annotation change |
| `make test-unit` | Backend unit tests (no DB, fast) | Use to verify handler logic changes |
| `make test-integration` | Backend integration tests (needs Docker) | Use to verify migration + scheduling queries |
| `flutter test` | Frontend widget/provider tests | Use to verify timer countdown logic |

---

## Installation

No new dependencies. All packages are already declared in `pubspec.yaml` and `go.mod`.

```bash
# Backend (verify environment is current)
cd HeftyBack && go mod download

# Frontend (verify environment is current)
cd hefty_chest && flutter pub get
```

---

## Patterns by Bug Area

### Flutter Rest Timer Off-By-One

**File:** `hefty_chest/lib/features/tracker/widgets/rest_item_card.dart`

**Current code:**
```dart
if (timeRemaining.value <= 1) {
  isTimerRunning.value = false;
  onComplete();   // fires at 1, never shows 0
} else {
  timeRemaining.value = timeRemaining.value - 1;
}
```

**Fix pattern:** Fire `onComplete` when `timeRemaining.value <= 0`, decrement unconditionally first:
```dart
timeRemaining.value = timeRemaining.value - 1;
if (timeRemaining.value <= 0) {
  isTimerRunning.value = false;
  onComplete();
}
```

This is the standard `dart:async` countdown pattern: decrement then check. Timer fires at exactly 0 before completing. Confidence: HIGH — this is core Dart semantics.

### Zero-Duration Rest Items — Not Rendering

**Fix pattern:** Filter out `restDurationSeconds == 0` before building `_TrackerItem` lists in `tracker_screen.dart`. Zero-duration rest items have no UX value and should not enter the `itemsBySection` map.

```dart
for (final restItem in session.restItems) {
  if (restItem.restDurationSeconds == 0) continue;  // skip zero-duration
  ...
}
```

### Standalone Rest Item — Triggering Rest Timer on Completion

**File:** `hefty_chest/lib/features/tracker/tracker_screen.dart`

`RestItemCard.onComplete` currently calls `completeRestItem` (marks the item done) but does NOT trigger the modal `RestTimerSheet`. The `onTriggerRestTimer` callback must also be invoked from the rest item's `onComplete` handler in `_buildSectionItems`:

```dart
onComplete: () {
  ref.read(activeSessionProvider.notifier).completeRestItem(
    restItemId: restItem.id,
  );
  // Trigger the overlay rest timer
  onTriggerRestTimer(
    restItem.restDurationSeconds,
    '',   // no "next exercise" context for standalone rest
    0,
  );
},
```

### Rest Items Display Order

**File:** `hefty_chest/lib/features/tracker/tracker_screen.dart`

`_buildSessionContent` already sorts `_TrackerItem` by `displayOrder` within each section. The issue is exercises and rest items are added to `itemsBySection` in separate loops — exercises first, then rest items. Both loops use `putIfAbsent` which is correct, but because sorting happens after, the section sort will interleave them correctly as long as `displayOrder` values from the backend are consistent.

**Backend fix required:** `StartSession` in `session.go` assigns `item.DisplayOrder` from the template's `section_items.display_order` for both exercise and rest items. Verify the `AddRestItem` repository method stores `display_order` from the template correctly (not a computed index).

### Program `started_at` — New Migration Required

The `programs` table has no `started_at` column. It is needed to calculate which program day is "today."

**Migration pattern (goose):**
```sql
-- +goose Up
ALTER TABLE programs ADD COLUMN started_at TIMESTAMP;

-- +goose Down
ALTER TABLE programs DROP COLUMN IF EXISTS started_at;
```

The `SetActive` repository method must set `started_at = CURRENT_TIMESTAMP` when activating a program. The column is nullable because programs that have never been activated have no start date.

### GetTodayWorkout Day Calculation

**File:** `HeftyBack/internal/handlers/program.go`

The current implementation hardcodes `dayNumber = 1`. The correct calculation:

```go
// After fetching program with started_at populated:
if program.StartedAt == nil {
    // Program activated but started_at missing — treat as day 1
    dayNumber = 1
} else {
    elapsed := time.Since(*program.StartedAt)
    daysSinceStart := int(elapsed.Hours() / 24)  // floor division
    totalDays := program.DurationWeeks*7 + program.DurationDays
    if totalDays > 0 {
        dayNumber = (daysSinceStart % totalDays) + 1
    } else {
        dayNumber = 1
    }
}
```

**Important:** `time.Since()` returns wall clock duration. For day-based scheduling, use floor division of hours to avoid partial-day boundary errors. Confidence: HIGH — this is standard Go time arithmetic.

### UpdateProgram Handler — Missing Actual Update

**File:** `HeftyBack/internal/handlers/program.go`

`UpdateProgram` currently reads the program, then returns it unchanged — the update fields from `req.Msg` are never applied. The handler must call a `repository.Update()` method passing the optional fields:

```go
// Must add to ProgramRepositoryInterface and implement:
err = h.programRepo.Update(ctx, req.Msg.Id, userID, repository.UpdateProgramParams{
    Name:          req.Msg.Name,
    Description:   req.Msg.Description,
    DurationWeeks: req.Msg.DurationWeeks,
    DurationDays:  req.Msg.DurationDays,
    IsArchived:    req.Msg.IsArchived,
})
```

The `Update` SQL must also delete and recreate `program_days` when `req.Msg.Days` is non-empty (existing pattern from workout template updates).

### Completing a Workout Advances Program Day

**Behavior:** When `FinishSession` is called with a `program_day_number`, the program's current day advances. Implementation options:

1. Store `current_day_number` in the `programs` table (simplest, single source of truth)
2. Calculate from `started_at` + elapsed calendar days (no extra state, but requires accurate `started_at`)

Option 2 is preferred because it survives server restarts and avoids write-on-every-session. The `FinishSession` handler does not need to write to `programs` at all — `GetTodayWorkout` recalculates dynamically from `started_at`.

### Program Archiving After Last Day

`GetTodayWorkout` should check if `daysSinceStart >= totalDays`. If the program has no cycling (per PROJECT.md decision), set `is_archived = TRUE` and `is_active = FALSE` for that program at that point:

```go
if daysSinceStart >= totalDays {
    h.programRepo.Archive(ctx, program.ID, userID)
    return connect.NewResponse(&heftv1.GetTodayWorkoutResponse{HasWorkout: false}), nil
}
```

### Remove Debug fmt.Fprintf Logging

**File:** `HeftyBack/internal/handlers/session.go`

Lines 36-37 and 110-117 and 139-148 use `fmt.Fprintln(os.Stderr, ...)` and `fmt.Fprintf(os.Stderr, ...)`. Replace with nothing or with `log.Printf` only if the logging is genuinely useful. The existing `log.Printf` calls (lines 308-323, 354-357) using the standard `log` package are acceptable. The `fmt` variants must be removed entirely — they bypass the structured logger and always emit to stderr regardless of log level.

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Adding a timer library (e.g., `just_audio`, `awesome_notifications`) | The countdown timer is 20 lines of `dart:async`; a library adds dependency weight for a trivial fix | `dart:async` Timer + flutter_hooks `useEffect` (already in codebase) |
| `time.Now().Day()` for program day scheduling | Returns calendar day-of-month, not days-elapsed since program start | `time.Since(startedAt).Hours() / 24` for elapsed days |
| Storing `current_day_number` in the DB and incrementing on session finish | Creates a second source of truth that can desync from `started_at`; also requires a write on every session completion | Calculate dynamically in `GetTodayWorkout` from `started_at` |
| `fmt.Fprintf` / `fmt.Fprintln` for logging | Bypasses log level, always emits, leaks debug info in production | `log.Printf` (standard library, already used in other handlers) |
| Hand-editing `gen/` or `lib/gen/` files | Regenerated by `buf generate`; edits will be overwritten | Edit `.proto` files, then `buf generate` in both projects |

---

## Version Compatibility

| Package | Version | Compatibility Note |
|---------|---------|-------------------|
| `freezed_annotation` 3.1.0 | `freezed` 3.2.3 | These must be kept in lockstep; annotation and generator versions must match major version |
| `riverpod_annotation` 3.0.3 | `riverpod_generator` 3.0.3 | Same pairing rule — mismatched major versions cause codegen failures |
| `flutter_hooks` 0.21.3 | `hooks_riverpod` 3.0.3 | hooks_riverpod 3.x requires flutter_hooks 0.21.x |
| `go` 1.24 | `connectrpc.com/connect` 1.16.0 | No known incompatibilities |
| `pgx` v5.7.1 | PostgreSQL (Supabase) | pgx v5 uses `pgx.ErrNoRows` (not `sql.ErrNoRows`); all existing queries use the correct sentinel |

---

## Proto Changes Required

If `started_at` is exposed to the frontend (needed to show "program start date" on home screen), add to both proto files:

```proto
// In Program and ProgramSummary messages:
google.protobuf.Timestamp started_at = 14;
```

Then run `buf generate` in `HeftyBack/` and `hefty_chest/`.

If `started_at` is only used backend-side for day calculation, no proto changes are needed. The home screen only needs the `GetTodayWorkout` response (day number + workout), not the raw `started_at` timestamp.

**Recommendation:** Do not add `started_at` to proto unless the frontend needs to display it. Fewer proto changes = fewer regeneration steps = smaller diff.

---

## Sources

- Direct code inspection of `hefty_chest/lib/features/tracker/widgets/rest_item_card.dart` — timer off-by-one confirmed at line 33
- Direct code inspection of `HeftyBack/internal/handlers/program.go` — hardcoded `dayNumber = 1` confirmed at line 236, `UpdateProgram` no-op confirmed at lines 148-168
- Direct code inspection of `HeftyBack/internal/handlers/session.go` — `fmt.Fprintf` debug logging confirmed at lines 36-37, 110-117, 139-148
- Direct code inspection of `HeftyBack/migrations/00001_initial_schema.sql` — `programs` table has no `started_at` column confirmed
- Direct code inspection of `HeftyBack/internal/repository/program.go` — `SetActive` does not write `started_at` confirmed
- `hefty_chest/pubspec.yaml` — all frontend dependency versions verified
- `HeftyBack/go.mod` — all backend dependency versions verified

---
*Stack research for: workout tracker rest timer and program scheduling bug fixes*
*Researched: 2026-03-10*
