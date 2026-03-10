# Pitfalls Research

**Domain:** Workout tracker — rest timer and program scheduling bug fixes
**Researched:** 2026-03-10
**Confidence:** HIGH (derived from direct code inspection of the actual codebase)

---

## Critical Pitfalls

### Pitfall 1: Timer Off-By-One — Counting to 1, Not 0

**What goes wrong:**
The `RestItemCard` timer fires `onComplete()` when `timeRemaining.value <= 1` (line 33 in `rest_item_card.dart`), which means the timer completes at 1 second remaining, never displaying 0:00. The `RestTimerSheet` widget has the opposite behavior: it fires `onComplete()` when `timeRemaining.value <= 0` after decrementing first, which is correct. Fixing one widget without auditing the other leaves the inconsistency.

**Why it happens:**
Two separate timer widgets implement the countdown independently. When the fix is applied to one widget it is easy to forget that the other widget exists and has the same bug with different code.

**How to avoid:**
Fix the condition in `RestItemCard.useEffect` to `if (timeRemaining.value <= 0)` (matching `RestTimerSheet`). After fixing, manually verify both widgets display "0:00" before auto-completing. Audit all timer callbacks in the same pass.

**Warning signs:**
- Timer disappears or transitions to "completed" state while still displaying "0:01"
- Integration test that asserts `onComplete` fires after N ticks, not N-1 ticks, fails

**Phase to address:**
Rest timer bug fixes — any phase that touches `rest_item_card.dart`

---

### Pitfall 2: UpdateProgram Handler That Does Nothing

**What goes wrong:**
`UpdateProgram` in `handlers/program.go` (lines 148–168) fetches the program, then immediately returns it without calling any repository update method. The bug is structural: the handler is a stub that was never wired to the repository. Treating this as a "small fix" and only adding `programRepo.Update()` without also defining the interface method, implementing the SQL, and adding the migration will leave a compile error or runtime panic.

**Why it happens:**
The handler skeleton was written before the repository method existed. The missing pieces (interface method, SQL implementation, DB migration if schema change needed) are easy to overlook when the handler already compiles and returns a response — it just silently ignores the request body.

**How to avoid:**
Follow the full 4-step chain: (1) add `Update` to `ProgramRepositoryInterface` in `interfaces.go`, (2) implement it in `repository/program.go` with `WHERE id = $1 AND user_id = $2`, (3) call it from the handler, (4) reload and return. Verify the compile-time interface check `var _ ProgramRepositoryInterface = (*ProgramRepository)(nil)` still passes.

**Warning signs:**
- Handler returns without ever calling a write method on the repository
- Changes made via `UpdateProgram` are not persisted after reload
- The compile-time interface compliance check at the bottom of `interfaces.go` would fail if you add the interface method without the implementation

**Phase to address:**
Program scheduling bug fixes — any phase that touches `handlers/program.go`

---

### Pitfall 3: Missing `started_at` Column Breaks Day Calculation Entirely

**What goes wrong:**
`GetTodayWorkout` in `handlers/program.go` (lines 234–239) contains a hardcoded comment: "For simplicity, use day 1 for now — real implementation would calculate based on program start date". It always returns day 1 regardless of how long the program has been running. Adding elapsed-day calculation in the handler without also adding the `started_at` column to the `programs` table and a corresponding migration will either fail at runtime (column does not exist) or silently use `created_at` as a proxy (which resets whenever the program record is updated).

**Why it happens:**
The day calculation logic requires a timestamp that does not exist in the schema yet. Implementing the handler logic in isolation, before the DB migration, causes a runtime SQL error that only appears when `GetTodayWorkout` is called — not at startup.

**How to avoid:**
Create the migration first (`make migrate-create name=add_program_started_at`), add `started_at TIMESTAMP` to the `programs` table, update `SetActive` repository method to `SET started_at = CURRENT_TIMESTAMP`, update `Program` struct and all `RETURNING` clauses to include `started_at`, then implement the handler calculation. Migration must be applied before any handler code that reads the column.

**Warning signs:**
- `GetTodayWorkout` always returns day 1 no matter how many days have elapsed
- Handler SQL query references `started_at` but migration has not been applied — runtime error `column programs.started_at does not exist`
- `SetActive` does not set `started_at`, so the field is NULL for previously activated programs

**Phase to address:**
Program scheduling bug fixes — migration phase must precede handler implementation

---

### Pitfall 4: Program Advance / Archive Logic Bypasses the Repository Pattern

**What goes wrong:**
Completing a workout and advancing the program day, or archiving the program on the final day, requires writing to the `programs` table. Because no `AdvanceDay` or `Archive` repository methods currently exist on `ProgramRepositoryInterface`, developers under time pressure may be tempted to either (a) call raw SQL from the handler directly (violating the Golden Principle that handlers never import pgx), or (b) reuse `SetActive` or `Delete` with wrong semantics.

**Why it happens:**
The interface only defines what was needed when originally written. New behavior requires extending the interface, which is a multi-file change (interface + implementation + handler wiring), and shortcuts are tempting.

**How to avoid:**
Add explicit methods to the interface: `AdvanceDay(ctx, id, userID string) (*Program, error)` and `Archive(ctx, id, userID string) error`. Implement each in `repository/program.go`. The compile-time check `var _ ProgramRepositoryInterface = (*ProgramRepository)(nil)` will fail to compile until both are implemented, enforcing the pattern.

**Warning signs:**
- Handler file imports `pgx` or `pgxpool` directly
- SQL `UPDATE programs SET ...` appears inside an `internal/handlers/` file
- `SetActive` is called with logic to advance the day as a side effect

**Phase to address:**
Program scheduling bug fixes — any phase adding program completion behavior

---

### Pitfall 5: Zero-Duration Rest Items Rendered but Skipped Silently

**What goes wrong:**
The `StartSession` handler (lines 138–144 in `handlers/session.go`) adds rest items from the template via `AddRestItem` only when `item.RestDurationSeconds != nil`. A rest item with `RestDurationSeconds = 0` has a non-nil pointer pointing to `0`, so the condition is true and the item is inserted. On the frontend, `RestItemCard` renders all rest items without filtering, so a zero-duration rest appears as a card but immediately auto-completes when its timer reaches 0. Users see a flashing card. The fix (filter out zero-duration items before rendering) must be applied on the frontend display path, not just in the backend insert path.

**Why it happens:**
The nil check (`!= nil`) was intended to skip rest items that have no duration at all, but a `*int` pointing to `0` is not nil. A zero-duration rest item represents "no rest" in the template editor but still gets persisted as a session rest item.

**How to avoid:**
Apply the filter in two places: (1) `handlers/session.go` — change the condition to `item.RestDurationSeconds != nil && *item.RestDurationSeconds > 0`; (2) `tracker_screen.dart` — filter `session.restItems` to exclude items where `restDurationSeconds == 0` before building the display list.

**Warning signs:**
- Rest item card appears briefly then vanishes at session start
- `session_rest_items` table has rows with `rest_duration_seconds = 0`
- `RestItemCard` timer fires `onComplete()` immediately on mount for zero-duration items

**Phase to address:**
Rest timer bug fixes — same phase as rest item rendering fixes

---

### Pitfall 6: Rest Item Display Order Is Independent of Exercise Display Order

**What goes wrong:**
In `tracker_screen.dart` (lines 316–335), exercises and rest items are put into separate loops and then merged into `itemsBySection` by display order. The `displayOrder` for rest items comes from the session template copy. If the template stored rest items with display orders that do not interleave correctly with exercise display orders (e.g., all exercises have orders 0, 1, 2 and the rest item has order 1 but was added after all exercises), the rest item ends up in the wrong position after the sort. The sort only works correctly if display orders were assigned in a single monotonically increasing sequence during `StartSession`.

**Why it happens:**
`AddExercise` and `AddRestItem` are called in separate loops in `StartSession` (the outer loop iterates sections, the inner loop iterates items), but the `DisplayOrder` is taken directly from `item.DisplayOrder` in the template. If the template builder assigned display orders correctly, this works. If there is any offset or reset between exercises and rest items, the session display order is broken.

**How to avoid:**
Verify that the template's `section_items` table assigns `display_order` as a single sequence across all item types within a section (not separately for exercises and rest items). Add an integration test that starts a session from a template with interleaved rest items and asserts the returned session's exercises and rest items have correct relative ordering.

**Warning signs:**
- Rest item card appears before the exercise it should follow
- All rest items appear at the bottom of the section regardless of template order
- `display_order` values in `session_rest_items` do not interleave with `session_exercises.display_order`

**Phase to address:**
Rest timer bug fixes — same phase as rest item ordering fix

---

### Pitfall 7: Standalone Rest Item Completion Does Not Trigger the Rest Timer

**What goes wrong:**
In `tracker_screen.dart`, the `onComplete` callback for `RestItemCard` calls `completeRestItem()` on the provider (line 612). This marks the item as completed and syncs to the server, but it does not trigger the `RestTimerSheet` overlay. The `RestTimerSheet` is only triggered from `onTriggerRestTimer` inside `onSetCompleted` (line 579), which only fires when a set is completed. A standalone rest item between sections is never connected to the rest timer overlay.

**Why it happens:**
The rest timer overlay (`RestTimerSheet`) was built for the per-set rest flow. The `RestItemCard` is a separate widget with its own built-in timer display. The two timer mechanisms were designed independently. It is easy to assume that "RestItemCard already has a timer" and skip wiring it to the overlay, but the requirements state that completing a standalone rest item should also trigger the overlay timer (or start the inline timer automatically on completion).

**How to avoid:**
Decide which behavior is intended: (a) `RestItemCard` already has an inline timer — "Start Timer" button starts it, "Done" button calls `onComplete`; OR (b) completing the previous exercise auto-starts the rest item inline timer. The current requirement is that clicking "Start Timer" on the `RestItemCard` starts the countdown and clicking "Done" marks it complete. Verify this is wired by testing the actual tap flow rather than assuming it works.

**Warning signs:**
- Tapping "Start Timer" on a rest item does not visually start the countdown
- `isTimerRunning` state in `RestItemCard` is never set to `true` by any tap handler — confirmed to be working in current code, `onTap` on the "Start Timer" button sets `isTimerRunning.value = true`
- `onComplete` fires but `isCompleted` is not reflected in the session state

**Phase to address:**
Rest timer bug fixes — verify tap-to-start behavior is end-to-end wired

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| `fmt.Fprintf(os.Stderr, ...)` debug logging in `handlers/session.go` | Visible during development | Leaks implementation details in production logs, not structured, hard to filter | Never — remove before shipping |
| Hardcoded `dayNumber = 1` in `GetTodayWorkout` | Handler compiles and returns something | Always shows wrong day — program scheduling is entirely broken | Never — must be replaced with real calculation |
| Handler stub `UpdateProgram` returns without writing | Compiles cleanly | All program edits are silently ignored | Never — must wire to repository |
| Two independent timer implementations (`RestTimerSheet`, `RestItemCard`) | Each widget self-contained | Different bug patterns, divergent behavior, harder to reason about consistency | Acceptable for now — same fix pattern applies to both |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Proto + Go + Dart codegen | Fix `.proto`, regenerate only in one project | Edit proto in BOTH `HeftyBack/proto/` AND `hefty_chest/proto/`, then run `buf generate` in both |
| `started_at` column migration | Apply migration in dev but forget to include it in the migration file for CI/prod | Use `make migrate-create`, commit the `.sql` file, verify `make migrate-up` runs cleanly in Docker test environment |
| `programs.SetActive` + `started_at` | Set `is_active = TRUE` but forget to set `started_at` | `SetActive` SQL must include `SET started_at = CURRENT_TIMESTAMP` in the same UPDATE |
| Repository interface extension | Add method to implementation but not to interface (or vice versa) | The compile-time check `var _ ProgramRepositoryInterface = (*ProgramRepository)(nil)` catches this — let the compiler enforce it |
| Riverpod provider invalidation after session finish | Finish session, navigate home, home screen shows stale data | `ref.invalidate(workoutListProvider)` and relevant providers must be called after `finishSession` — pattern already exists for progress providers |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Loading full session on every sync response | Each 2-second sync triggers `GetByID` which loads all exercises + sets + rest items | Acceptable at current scale; only matters with very large sessions | Sessions with 50+ exercises, 200+ sets |
| `getSetCompletionInfo` scans all sets linearly on every set completion | Brief freeze on large sessions | N/A at current scale | Sessions with 100+ sets |
| 2-second sync timer firing even when there are no pending changes | Wasted network call every 2s | Already guarded by `if session == null \|\| !_hasPendingChanges` | Not a current problem |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Missing `user_id` scope on new program queries (`AdvanceDay`, `Archive`) | User A could archive User B's program by guessing UUID | Every new SQL query touching `programs` must include `WHERE user_id = $N` — enforced by Golden Principle 3 |
| `fmt.Fprintf(os.Stderr, ...)` logging request parameters in `StartSession` | Log injection if workout template IDs contain special characters; leaks user activity | Remove all `fmt.Fprintf` and `fmt.Fprintln` debug lines from `handlers/session.go` |
| Accepting `program_id` and `program_day_number` from client in `StartSession` | Client could set arbitrary program ownership | Already correct — handler does not validate that `program_id` belongs to the user before writing it to the session. This is a latent issue worth noting, though not in the active bug list |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Timer displays 0:01 then disappears | User feels timer skipped the last second, jarring | Fix `<= 1` to `<= 0` so 0:00 is displayed before completion fires |
| Program always shows Day 1 even after 5 days | User cannot trust the home screen "Today's Workout" — workaround is manually tracking their day | Implement `started_at`-based elapsed day calculation in `GetTodayWorkout` |
| Zero-duration rest items appear as cards | Confusing card flashes and immediately goes to "completed" | Filter `restDurationSeconds == 0` items from rendering |
| UpdateProgram silently ignores edits | User edits a program, sees success, refreshes — changes are gone | Fix handler to actually persist changes |

---

## "Looks Done But Isn't" Checklist

- [ ] **Rest timer countdown:** Timer fix touches `rest_item_card.dart` AND `rest_timer_sheet.dart` — verify both widgets display 0:00 before completing
- [ ] **Program day calculation:** `GetTodayWorkout` returns day > 1 for a program that was activated yesterday — verify with a real elapsed-time test
- [ ] **UpdateProgram persistence:** After calling UpdateProgram, call GetProgram and confirm changed fields are returned — not just that the handler returns 200
- [ ] **Migration applied to both environments:** `started_at` migration runs in the Docker test DB used for integration tests, not only in local dev
- [ ] **Proto sync:** If `started_at` is exposed via proto, both `HeftyBack/proto/` and `hefty_chest/proto/` are updated and `buf generate` has been run in both
- [ ] **Zero-duration filter is bidirectional:** Backend does not insert zero-duration rest items AND frontend does not render them (defense in depth)
- [ ] **Debug logging removed:** No `fmt.Fprintf` or `fmt.Fprintln` calls remain in `handlers/session.go`
- [ ] **Rest item order verified:** Start a session from a template with interleaved rest items; confirm the order matches the template's section item order

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Timer off-by-one | LOW | One-line fix in `rest_item_card.dart`, one verification pass on `rest_timer_sheet.dart` |
| UpdateProgram stub | MEDIUM | Add interface method, implement SQL, wire handler, write test to verify persistence |
| Missing `started_at` migration | MEDIUM | Create migration, update struct, update all RETURNING clauses, update SetActive, update GetTodayWorkout calculation |
| Program advance/archive bypassed repository | MEDIUM | Add methods to interface, implement SQL, wire in handler, compile-time check enforces correctness |
| Debug logging in production | LOW | grep for `fmt.Fprintf\|fmt.Fprintln` in handlers/, remove all occurrences |
| Zero-duration rest item rendering | LOW | Add `> 0` guard to backend insert + frontend filter |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Timer counts to 1 not 0 | Rest timer fixes | Automated: timer fires `onComplete` after exactly N ticks; manual: watch timer display 0:00 |
| `UpdateProgram` is a no-op stub | Program scheduling fixes | Integration test: edit program name, refetch, assert name changed |
| Missing `started_at` column | Program scheduling fixes — migration first | Integration test: activate program, call `GetTodayWorkout` after 1+ days elapsed |
| Program advance/archive lacks repository methods | Program scheduling fixes | Compile-time: interface check fails without implementation; integration test: finish day 1, assert day 2 returned |
| Zero-duration rest items rendered | Rest timer fixes | Session started from template with 0-second rest — assert no rest item card appears |
| Rest item display order wrong | Rest timer fixes | Session with interleaved rest items — assert exercise/rest ordering matches template |
| Standalone rest item timer not triggered | Rest timer fixes | Tap "Start Timer" on `RestItemCard` — assert countdown begins |
| Debug `fmt.Fprintf` logging | Any phase touching `handlers/session.go` | grep: `fmt.Fprintf\|fmt.Fprintln` in `HeftyBack/internal/handlers/session.go` returns no matches |

---

## Sources

- Direct inspection: `HeftyBack/internal/handlers/session.go` (debug logging, rest item insertion logic)
- Direct inspection: `HeftyBack/internal/handlers/program.go` (UpdateProgram stub, GetTodayWorkout hardcoded day 1)
- Direct inspection: `HeftyBack/internal/repository/program.go` (SetActive missing started_at, no Update/Archive/AdvanceDay methods)
- Direct inspection: `HeftyBack/internal/repository/interfaces.go` (ProgramRepositoryInterface gaps)
- Direct inspection: `hefty_chest/lib/features/tracker/widgets/rest_item_card.dart` (off-by-one: `<= 1` condition)
- Direct inspection: `hefty_chest/lib/features/tracker/widgets/rest_timer_sheet.dart` (correct `<= 0` condition for comparison)
- Direct inspection: `hefty_chest/lib/features/tracker/tracker_screen.dart` (rest item rendering, display order merge logic)
- Direct inspection: `hefty_chest/lib/features/tracker/providers/session_providers.dart` (sync pattern, rest item completion flow)
- Direct inspection: `HeftyBack/migrations/00008_add_session_rest_items.sql` (schema reference)
- Project requirements: `.planning/PROJECT.md` (13 named bugs)

---
*Pitfalls research for: Heft workout tracker — rest timer and program scheduling bug fixes*
*Researched: 2026-03-10*
