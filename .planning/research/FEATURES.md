# Feature Research

**Domain:** Workout tracker — rest timers and program scheduling (bug fix milestone)
**Researched:** 2026-03-10
**Confidence:** HIGH (based on direct codebase analysis and first-principles workout app behavior)

---

## Context

This is a bug-fix milestone for an existing product. Features are not being added — broken behaviors
are being corrected. The research question is: "what should these features do correctly?" That
defines what a fix looks like and what a regression would look like.

The two subsystems under repair:

1. **Rest timer system** — Countdown timer triggered after a set is completed, plus standalone rest
   items (sections of the session that are purely rest, not exercises with sets).

2. **Program scheduling system** — A training program is a sequence of days (workout or rest). When
   activated it needs to track elapsed calendar time and surface "today's workout" correctly.

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing or wrong = product feels broken.

#### Rest Timer Subsystem

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Timer counts down to 0, then dismisses | Every countdown timer in existence reaches 0 before stopping. Stopping at 1 is visually jarring. | LOW | Current bug: `rest_item_card.dart` fires `onComplete` when `timeRemaining.value <= 1`, leaving "0:01" as the last visible value. Fix: fire when `<= 0` or after decrement hits 0. |
| Rest items from template appear in session | Starting a session from a template should copy all items — exercises and rest items alike. | LOW | Current bug: `session.go` skips rest items when `RestDurationSeconds == nil` (pointer check). Template items may have duration without the pointer being set, or the condition may be inverted. |
| Zero-duration rest items are not rendered | A rest item with 0 seconds provides no user value and creates confusing empty cards. | LOW | Current bug: `rest_item_card.dart` (or its parent) renders regardless of duration. Fix: guard in `tracker_screen.dart` before pushing to item list. |
| Standalone rest items trigger the rest timer overlay | A user tapping "Start Timer" on a rest item card should show the `RestTimerSheet` overlay, not just run a local timer silently. The overlay is the canonical "you are resting" UX. | MEDIUM | Current bug: `rest_item_card.dart` runs its own local timer but never calls `onTriggerRestTimer` in `tracker_screen.dart`. The callback path exists; it just is not wired to rest items. |
| Items display in template order | When a template has exercises interleaved with rest items at specific positions, the session must preserve that order. | LOW | Current bug: items are collected into two separate lists (exercises, then rest items) before being sorted by `displayOrder`. If `displayOrder` values are correct this works, but they may not be set correctly when sessions are created from templates. |
| Display order remains consistent throughout session | Reordering exercises should not scramble rest item positions relative to exercises. | LOW | Same root cause as above — rest items need correctly-assigned `displayOrder` from the start. |

#### Program Scheduling Subsystem

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Program records start date when activated | Without a start date there is no reference point to calculate "which day am I on". | LOW | Current bug: `SetActive` in `repository/program.go` does not write a `started_at` value. Requires a new `started_at` column (migration) and update to `SetActive`. |
| GetTodayWorkout returns correct day based on elapsed calendar time | "Today's workout" means the day that corresponds to how many calendar days have passed since the program started. If you start a 7-day program on Monday, Wednesday is day 3. | LOW | Current bug: `GetTodayWorkout` in `handlers/program.go` has a comment "For simplicity, use day 1 for now" and hard-codes `dayNumber := 1`. Fix: compute `floor((now - started_at) / 24h) + 1`, clamp to total days. |
| Completing a workout advances program to the next day | If the user finishes a session that belongs to day N, the program should advance so tomorrow shows day N+1. | MEDIUM | Current bug: `FinishSession` does not call any program-advancing logic. Need a `AdvanceProgram` or `CompleteDay` method in the program repository, called when a session with a `program_id` and `program_day_number` is finished. The elapsed-time calculation makes this implicit — if `started_at` is set and the day advances by calendar, no explicit "advance" is needed. But explicit completion-triggered advancement is a cleaner model. |
| Programs end and archive after the last day | When the program has been running for its full duration, it should transition to `is_archived = true`, `is_active = false`. The user should not be stuck on "day 8 of 7". | LOW | Current bug: no archival logic exists. When `GetTodayWorkout` calculates a day number beyond `totalDays`, it should archive the program and return `has_workout = false`. |
| UpdateProgram handler applies changes to the database | An update endpoint that reads and returns the current state without writing changes is not an update. | LOW | Current bug: `UpdateProgram` in `handlers/program.go` calls `GetByID` but never calls a repository `Update` method. The `Update` method either does not exist or is never called. |
| Today's Workout is surfaced on home screen | The home screen exists to orient the user. If there is an active program, "here is what you do today" is the most important information to show. | LOW | Current bug: the home screen does not display the active program's today workout. This requires calling `GetTodayWorkout` from the home feature and rendering the result. |
| Debug logging removed from production code | `fmt.Fprintf(os.Stderr, ...)` calls in `handlers/session.go` are test scaffolding, not production logging. They pollute stderr in production. | LOW | Current bug: multiple `fmt.Fprintln` and `fmt.Fprintf` calls exist in `StartSession`. Replace with `log.Printf` or remove entirely. |

### Differentiators (Competitive Advantage)

Features that go beyond "correct behavior" and provide compounding value. None of these are in
scope for this bug-fix milestone, but they define the upper bound of the feature space so the
roadmap does not accidentally build in the wrong direction.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Rest timer audio/vibration alert | Users often set their phone down during rest. An alert means they don't miss their cue. | LOW | Flutter `vibration` or `flutter_local_notifications` packages. Out of scope for this milestone. |
| Adaptive rest duration suggestion | App learns your typical rest time from history and suggests it. | HIGH | Requires analytics pipeline. Far future. |
| Program day-skipping / makeup days | User misses a day; app shows "you missed day 3, do you want to do it now or skip to day 4?" | MEDIUM | Requires explicit day-completion tracking beyond started_at math. Out of scope. |
| Program progress visualization | "You are on day 12 of 28" with a progress bar. | LOW | Purely additive UI over the data the bug fixes expose. Natural follow-on after scheduling bugs are fixed. |
| Rest timer screen lock prevention | Keep screen on during rest. | LOW | `wakelock_plus` package. Out of scope. |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Rest duration editing mid-session | "I want 90s instead of 60s for this set" | SyncSession only tracks `is_completed` on rest items. Adding duration edits to sync is a schema change and adds significant complexity to both sync protocol and server validation. | Addressed in PROJECT.md out-of-scope. Users can skip the timer and rest as long as they want. |
| Program cycling (restart at day 1 on completion) | "I want to run this program again" | Cycling makes "which day am I on" calculation ambiguous — did `started_at` reset? Requires cycle tracking. | Programs end and archive. User creates a new activation manually. Clean mental model. |
| Calendar month view | "Show me a full month of my program" | Separate feature, not related to the scheduler correctness bugs. Would require significant UI work. | Phase separately after scheduling is correct. |
| Automatic rest item creation between every set | "Auto-insert rest after each completed set" | Conflates two rest models: per-set rest (triggered by the rest timer overlay after tapping a set complete) and standalone rest items (explicit rest blocks in the template). Merging them creates ambiguity about what gets synced. | Keep the two models distinct. Per-set rest is driven by `restDurationSeconds` on `SessionSet`. Standalone rest is driven by `SessionRestItem`. |

---

## Feature Dependencies

```
[Program scheduling correct]
    └──requires──> [started_at column migration]
                       └──required by──> [GetTodayWorkout day calculation]
                       └──required by──> [Program archival on completion]

[Program day advancement]
    └──requires──> [GetTodayWorkout day calculation]  (must know current day to advance)
    └──enhances──> [Today's Workout on home screen]  (home screen reflects real day)

[Rest items render correctly]
    └──requires──> [Rest items copied from template on session start]
    └──requires──> [Display order set correctly at session creation]

[Rest item triggers overlay]
    └──requires──> [Rest items render correctly]  (can't trigger timer on item that isn't shown)
    └──requires──> [Timer counts down to 0]  (overlay timer must also be correct)

[Today's Workout on home screen]
    └──requires──> [GetTodayWorkout day calculation]
    └──requires──> [Program records start date]

[UpdateProgram persists changes]
    └──independent]  (no other bugs depend on it)

[Debug logging removed]
    └──independent]  (no dependencies)
```

### Dependency Notes

- **started_at migration must land before GetTodayWorkout fix:** The calculation `floor((now - started_at) / 24h)` reads a column that doesn't exist yet. The migration is a hard prerequisite.
- **Template rest item copy must work before display order bugs can be verified:** If items never arrive in the session, display order is irrelevant.
- **Rest item overlay trigger requires the item to render:** Zero-duration guard and template copy must work first, or the overlay trigger fix cannot be properly tested.

---

## MVP Definition

### This Milestone (Bug Fix v1)

The 13 bugs from PROJECT.md, ordered by dependency:

- [x] Add `started_at` column to programs table (migration prerequisite)
- [ ] `UpdateProgram` handler writes changes to DB — no dependencies, fix first
- [ ] Remove `fmt.Fprintf` debug logging from session handler — no dependencies, fix first
- [ ] Rest items from templates copied into sessions correctly
- [ ] Zero-duration rest items not rendered in tracker
- [ ] Rest items and exercises in correct order (depends on copy fix)
- [ ] Rest timer counts down to 0 (not 1) — fix `<= 1` to `<= 0`
- [ ] Standalone rest items trigger the rest timer overlay on completion
- [ ] Program records start date when activated (depends on migration)
- [ ] `GetTodayWorkout` calculates correct day from `started_at` (depends on above)
- [ ] Completing a workout advances program to the next day (depends on above)
- [ ] Programs end and archive after the last day (depends on above)
- [ ] Today's Workout shown on home screen (depends on GetTodayWorkout fix)

### Add After Validation (v1.x)

- [ ] Rest timer audio/vibration alert — add once timer is correct
- [ ] Program progress bar on home screen — add once scheduling is correct

### Future Consideration (v2+)

- [ ] Adaptive rest duration suggestions — requires analytics
- [ ] Program day makeup / skip UI — requires explicit completion tracking
- [ ] Calendar month view — separate feature track

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Timer counts down to 0 | HIGH | LOW | P1 |
| Rest items from template | HIGH | LOW | P1 |
| Correct display order | HIGH | LOW | P1 |
| Rest item triggers overlay | HIGH | LOW | P1 |
| Zero-duration guard | MEDIUM | LOW | P1 |
| Program start date tracking | HIGH | LOW (migration + 1 SQL update) | P1 |
| GetTodayWorkout day math | HIGH | LOW | P1 |
| Today's Workout on home screen | HIGH | LOW | P1 |
| Program archival | MEDIUM | LOW | P1 |
| Workout advances program day | MEDIUM | MEDIUM | P1 |
| UpdateProgram persists | MEDIUM | LOW | P1 |
| Remove debug logging | LOW | LOW | P1 (production hygiene) |

All bugs are P1 because this is a correctness milestone — each item represents broken promised behavior.

---

## Competitor Feature Analysis

Based on standard workout tracker behavior (Strong, Hevy, JEFIT, Nike Training Club):

| Feature | Strong / Hevy | Our Approach |
|---------|---------------|--------------|
| Per-set rest timer | Auto-starts after set completion, counts to 0, dismisses automatically | Same model — `RestTimerSheet` overlay, triggered on set complete |
| Standalone rest blocks | Not a standard feature — Strong uses only per-set timers | Heft has standalone `SessionRestItem` which is more flexible |
| Program day calculation | Calendar-based elapsed days from activation date | Same model — `started_at` + elapsed days |
| Program completion | Strong: programs loop or expire with notification | Heft: archive on completion (simpler, no cycling) |
| Today's workout | Prominent home screen card | Heft home screen should show this — matches industry norm |

---

## Specific Bug Behavior Contracts

This section documents the expected correct behavior for each bug, so implementors have a
unambiguous pass/fail criterion.

### Rest Timer Off-By-One

**Current:** Timer fires `onComplete` when `timeRemaining.value <= 1`, so the last displayed value
is `0:01` before the card disappears.

**Correct:** The timer should decrement to 0 and display `0:00` (or `formatDuration(0)`) for one
tick before calling `onComplete`. The periodic callback should decrement first, then check:
```
timeRemaining.value--;
if (timeRemaining.value <= 0) { onComplete(); }
```

### Rest Items Not Added to Sessions from Templates

**Current:** `session.go` condition is `item.ItemType == "rest" && item.RestDurationSeconds != nil`.
If `RestDurationSeconds` is stored as a non-pointer int with value 0 in the template, this check
passes. If it is stored as a pointer that is nil for zero-duration items, the `!= nil` guard
skips them. The bug is that some valid rest items are skipped.

**Correct:** Add rest item to session if `item.ItemType == "rest"`. A zero-duration rest item
should still be added (the frontend will guard against rendering it). The nil check is overly
restrictive.

### Zero-Duration Rest Items Not Rendered

**Current:** `RestItemCard` is rendered for all rest items regardless of duration.

**Correct:** In `tracker_screen.dart`, when building the unified item list, filter out rest items
where `restDurationSeconds == 0` before adding them to `itemsBySection`.

### Standalone Rest Item Triggers Timer Overlay

**Current:** `rest_item_card.dart` runs a local timer inside the card but never calls the
`onTriggerRestTimer` callback up to `tracker_screen.dart`.

**Correct:** When the user taps "Start Timer" on a rest item card, it should call a callback
(passed from `tracker_screen.dart`) that triggers `RestTimerSheet` with the item's duration.
The rest item card's local timer should either be removed (delegating fully to the overlay) or
kept as a fallback. The overlay is the authoritative rest UX.

### Display Order Consistency

**Current:** Items are sorted by `displayOrder` within sections, but `displayOrder` values for
rest items may not be assigned correctly when the session is created from a template.

**Correct:** When `StartSession` copies items from the template's `section.Items`, each item's
`DisplayOrder` must be passed through to `AddRestItem` just as it is passed to `AddExercise`.
The existing `displayOrder` field on section items is the source of truth.

### Program Start Date

**Current:** `SetActive` writes `is_active = TRUE` but no `started_at` column exists.

**Correct:**
1. Migration adds `started_at TIMESTAMP` to `programs` table.
2. `SetActive` sets `started_at = CURRENT_TIMESTAMP` when activating.
3. Proto adds `started_at` timestamp field to `Program` message.

### GetTodayWorkout Day Calculation

**Current:** Hard-coded `dayNumber := 1`.

**Correct:**
```go
elapsed := time.Since(*program.StartedAt)
dayNumber := int(elapsed.Hours()/24) + 1
totalDays := program.DurationWeeks*7 + program.DurationDays
if dayNumber > totalDays {
    // Archive program, return has_workout = false
}
```
Day 1 = activation day. Day 2 = the next calendar day.

### Program Advances After Workout Completion

**Current:** `FinishSession` completes the session but does not advance any program state.

**Correct:** Because day calculation is calendar-based (elapsed days from `started_at`), no
explicit "advance" is needed for the day number — it advances automatically as time passes.
However, the program needs to be archived when the final day's session is completed. The
`FinishSession` handler should check: if the session has a `program_id` and the completed
`program_day_number` equals `totalDays`, archive the program.

### Program Archival on Last Day

**Current:** No archival logic exists.

**Correct:** When `GetTodayWorkout` calculates `dayNumber > totalDays`, call
`programRepo.Archive(ctx, programID, userID)` and return `has_workout = false`. Also triggered
from `FinishSession` when the last day's session is completed.

### UpdateProgram Handler Persists Changes

**Current:** `UpdateProgram` in `handlers/program.go` calls `GetByID` but never calls an update
method on the repository. The request fields (`name`, `description`, `duration_weeks`, etc.) are
read but ignored.

**Correct:** Add `Update(ctx, id, userID string, params UpdateProgramParams) (*Program, error)` to
`ProgramRepositoryInterface`. Implement it. Call it from the handler before reloading the
program.

### Today's Workout on Home Screen

**Current:** Home screen does not call `GetTodayWorkout` or display program information.

**Correct:** Add a provider in the home feature that calls `programClient.getTodayWorkout()`. If
`has_workout = true`, render a "Today's Workout" card on the home screen that navigates to the
tracker with the correct template ID and program context.

### Debug Logging Removed

**Current:** `fmt.Fprintln` and `fmt.Fprintf` calls in `StartSession` write to stderr.

**Correct:** Remove all `fmt.Fprintf(os.Stderr, ...)` calls from `session.go`. Keep the
structured `log.Printf` calls that use the standard logger. The `fmt` import should be removed
from the handler file if no other usage remains.

---

## Sources

- Direct codebase analysis: `HeftyBack/internal/handlers/session.go`, `program.go`
- Direct codebase analysis: `HeftyBack/internal/repository/program.go`
- Direct codebase analysis: `hefty_chest/lib/features/tracker/widgets/rest_item_card.dart`
- Direct codebase analysis: `hefty_chest/lib/features/tracker/widgets/rest_timer_sheet.dart`
- Direct codebase analysis: `hefty_chest/lib/features/tracker/tracker_screen.dart`
- Direct codebase analysis: `hefty_chest/lib/features/tracker/providers/session_providers.dart`
- Project requirements: `.planning/PROJECT.md`
- Industry pattern reference: Strong, Hevy app behavior (standard countdown-to-zero, calendar-based program day)

---
*Feature research for: Workout tracker rest timers and program scheduling*
*Researched: 2026-03-10*
