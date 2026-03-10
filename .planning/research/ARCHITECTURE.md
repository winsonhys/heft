# Architecture Research

**Domain:** Workout tracker — rest timer system and program day scheduler
**Researched:** 2026-03-10
**Confidence:** HIGH (based on direct codebase inspection)

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    hefty_chest (Flutter)                             │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  TrackerScreen                                                │   │
│  │  ├── RestTimerSheet (overlay, auto-countdown)                 │   │
│  │  ├── RestItemCard (inline rest block, manual countdown)       │   │
│  │  └── TrackerSectionCard (exercise + sets)                     │   │
│  └──────────────────────┬───────────────────────────────────────┘   │
│                         │ ref.read(activeSessionProvider.notifier)   │
│  ┌──────────────────────▼───────────────────────────────────────┐   │
│  │  ActiveSession (Riverpod Notifier)                            │   │
│  │  ├── Freezed SessionModel (exercises + restItems)             │   │
│  │  ├── 2-second periodic sync timer (Timer.periodic)           │   │
│  │  ├── completeRestItem() → marks isCompleted, queues sync      │   │
│  │  └── getSetCompletionInfo() → drives RestTimerSheet trigger   │   │
│  └──────────────────────┬───────────────────────────────────────┘   │
│                         │ Connect-RPC (HTTP/2 + Protobuf)           │
├─────────────────────────┼───────────────────────────────────────────┤
│                    HeftyBack (Go)                                    │
│                         │                                            │
│  ┌──────────────────────▼───────────────────────────────────────┐   │
│  │  SessionHandler                                               │   │
│  │  ├── StartSession: copies section_items (exercise+rest) to    │   │
│  │  │    session_exercises + session_rest_items                  │   │
│  │  ├── SyncSession: upserts sets + updates rest_item completion │   │
│  │  └── FinishSession: marks completed, advances program day     │   │  ← BUG: not yet implemented
│  └──────────────────────┬───────────────────────────────────────┘   │
│                         │                                            │
│  ┌──────────────────────▼───────────────────────────────────────┐   │
│  │  SessionRepository                                            │   │
│  │  ├── AddRestItem() — INSERT into session_rest_items           │   │
│  │  ├── SyncRestItems() — UPDATE is_completed + completed_at     │   │
│  │  └── GetByID() — joins session_exercises + session_rest_items │   │
│  └──────────────────────┬───────────────────────────────────────┘   │
│                         │                                            │
│  ┌──────────────────────▼───────────────────────────────────────┐   │
│  │  PostgreSQL                                                   │   │
│  │  ├── session_rest_items (id, session_id, display_order,       │   │
│  │  │    section_name, rest_duration_seconds, is_completed)      │   │
│  │  └── programs (id, user_id, is_active, is_archived,           │   │
│  │       started_at MISSING — needs migration)                   │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### Program Day Scheduler Overview

```
┌──────────────────────────────────────────────────────────────────┐
│  HomeScreen                                                       │
│  └── (TODO: today's workout widget — not yet wired)              │
│                                                                   │
│  ProgramHandler.GetTodayWorkout()                                 │
│  ├── GetActiveProgram() — finds program WHERE is_active=TRUE      │
│  ├── Calculate dayNumber:                                         │
│  │    CURRENT: hardcoded to 1 — BUG: must use started_at         │
│  │    FIXED: dayNumber = daysSince(started_at) % totalDays + 1   │
│  ├── Find program_day WHERE day_number = dayNumber                │
│  └── Return workout template for that day                         │
│                                                                   │
│  ProgramHandler.SetActiveProgram()                                │
│  ├── Deactivate all programs for user                             │
│  ├── Activate requested program                                   │
│  └── BUG: Does not record started_at — needs migration           │
│                                                                   │
│  ProgramHandler.UpdateProgram()                                   │
│  └── BUG: Only reads program, does not call repo.Update()        │
│                                                                   │
│  FinishSession (after completion)                                 │
│  └── BUG: Does not advance program day — must add AdvanceDay()   │
└──────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Implementation |
|-----------|----------------|----------------|
| `RestTimerSheet` | Floating overlay timer triggered after set completion. Shows countdown, skip, +30s. Auto-starts on show. | `HookWidget` with `useState` + `useEffect`; `Timer.periodic` in effect; dismissed on skip/complete |
| `RestItemCard` | Inline rest block (from template). Manual start/stop. Skip toggles completion. | `HookWidget`; timer is local widget state; calls `onComplete`/`onSkip` callbacks |
| `ActiveSession` notifier | Single source of truth for session state. Owns periodic sync, local state mutations, local backup. | Riverpod `@riverpod` class; `Timer.periodic` every 2s; `SessionStorage` for offline backup |
| `getSetCompletionInfo()` | Derives rest duration and next set info from current session state to decide if `RestTimerSheet` should show. | Pure method on `ActiveSession`; inspects `restDurationSeconds` on `SessionSet` |
| `SessionHandler` | Business logic for session lifecycle. Copies template structure (exercises + rest items) into live session. | Go Connect-RPC handler; reads `section_items` of type `exercise` or `rest` from workout template |
| `SessionRepository` | SQL for session CRUD, set sync, rest item sync, exercise add/delete. | `pgx` queries; `AddRestItem` and `SyncRestItems` are the two rest-specific methods |
| `ProgramHandler` | Business logic for program activation, day calculation, today's workout lookup. | Go Connect-RPC handler; `GetTodayWorkout` is the key scheduling method |
| `ProgramRepository` | SQL for program CRUD, day loading, active program fetch, SetActive. | `pgx` queries; `SetActive` must be extended to record `started_at` |
| `programs` table | Stores program state including `is_active`, `is_archived`. Missing `started_at` column. | PostgreSQL; needs new migration for `started_at` |
| `session_rest_items` table | Stores rest blocks copied from template into a live session. | PostgreSQL; added in migration 00008 |

## Recommended Project Structure

The project structure is already well-established. Bug fixes map to specific files:

```
HeftyBack/
├── internal/
│   ├── handlers/
│   │   ├── session.go          # Fix: remove fmt.Fprintf debug logging
│   │   └── program.go          # Fix: UpdateProgram must call repo; GetTodayWorkout must use started_at;
│   │                           #      FinishSession must advance program day; SetActive must set started_at
│   └── repository/
│       ├── interfaces.go       # Add: Update() to ProgramRepositoryInterface; AdvanceProgramDay()
│       └── program.go          # Add: Update() implementation; AdvanceProgramDay(); SetActive records started_at
├── migrations/
│   └── 00009_add_program_started_at.sql  # New: ALTER TABLE programs ADD COLUMN started_at TIMESTAMP
└── proto/heft/v1/
    └── program.proto           # No changes needed — started_at is internal to backend logic

hefty_chest/
├── lib/features/tracker/
│   ├── widgets/
│   │   ├── rest_item_card.dart # Fix: timer counts to 0 (not 1); auto-trigger on standalone rest completion
│   │   └── rest_timer_sheet.dart  # Fix: timer boundary condition (counts to 0)
│   ├── providers/
│   │   └── session_providers.dart  # Fix: rest items display order; rest items from template added correctly
│   └── tracker_screen.dart    # Fix: display order sorting for unified exercise+rest item list
└── lib/features/home/
    └── home_screen.dart        # Add: Today's Workout section using getTodayWorkout provider
```

### Structure Rationale

- **No new files needed for rest timer fixes:** All timer logic is in `rest_item_card.dart` and `rest_timer_sheet.dart`. The bugs are in-place logic errors, not missing architecture.
- **New migration required:** `started_at` on `programs` is a schema gap — must be a new goose migration, never a hand-edit.
- **New repository methods required:** `ProgramRepositoryInterface` must be extended with `Update()` and `AdvanceProgramDay()` before handlers can use them.
- **Home screen wiring deferred from initial build:** `getTodayWorkout` RPC exists but no provider or widget calls it on the home screen yet.

## Architectural Patterns

### Pattern 1: Two-tier rest timer

**What:** The system has two separate rest timer mechanisms that serve different purposes.

**Tier 1 — RestTimerSheet (implicit, automatic):** Triggered automatically after a set is completed if the set has `rest_duration_seconds > 0`. This is the "rest between sets" timer. Lives as an overlay on `TrackerScreen`. User does not manually start it.

**Tier 2 — RestItemCard (explicit, manual):** Displayed inline in the exercise list for rest blocks that exist as `section_items` of type `rest` in a workout template. These are deliberate rest blocks between exercises. User manually starts them.

**When to use:** Tier 1 covers per-set rest timers (configured in workout builder per target set). Tier 2 covers template-level rest items (configured as a section item between exercises). Both can exist in the same session.

**Trade-offs:** Two timers can theoretically conflict (set completion triggers Tier 1, but current position is a rest item). The system currently handles this by keeping them independent. No coordination logic exists or is needed.

### Pattern 2: Local-first optimistic state with periodic server sync

**What:** `ActiveSession` notifier applies all mutations locally and immediately (via `copyWith()`), then syncs to server on a 2-second periodic timer. The server response updates local state with real IDs.

**When to use:** Already in use for exercises, sets, rest items. This is the correct pattern — do not introduce request/response cycles for individual set completions.

**Trade-offs:** Race condition handling is explicit: mutations during a sync are captured before the async call completes and persisted to a local backup. The sync captures a snapshot of pending changes, and only removes what was successfully synced.

### Pattern 3: displayOrder as merge key for unified rendering

**What:** `TrackerScreen._buildSessionContent()` creates a unified list of `_TrackerItem` (exercise or rest) per section, sorted by `displayOrder`. This allows exercises and rest blocks to interleave correctly based on their position in the template.

**When to use:** The sort is `items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder))`. The `_TrackerItem` wrapper provides `displayOrder` from either `SessionExerciseModel.displayOrder` or `SessionRestItemModel.displayOrder`.

**Critical:** `displayOrder` on `session_rest_items` must match the original `display_order` from `section_items` in the template. `StartSession` copies this correctly via `item.DisplayOrder` when calling `AddRestItem`. Bugs in order arise from incorrect `displayOrder` values being set at template copy time, not from the rendering logic itself.

## Data Flow

### Rest Timer Flow (per-set)

```
User taps "Complete" on a set row
    ↓
TrackerScreen._buildSectionItems calls onSetCompleted callback
    ↓
activeSessionProvider.notifier.completeSet() — local state update
    ↓
activeSessionProvider.notifier.getSetCompletionInfo(setId)
    returns {restDurationSeconds, nextExerciseName, nextSetNumber}
    ↓
if restDurationSeconds > 0: onTriggerRestTimer() called
    ↓
TrackerScreen sets showRestTimer.value = true, populates restTimeRemaining
    ↓
RestTimerSheet renders as Stack overlay (positioned above nav bar)
    counts down via Timer.periodic, auto-dismisses on 0 or skip
    ↓
(background) 2-second sync timer fires → _performSync()
    SyncSession RPC with updated set.isCompleted
```

### Rest Item Flow (standalone rest block)

```
Template has section_item of type 'rest' with rest_duration_seconds
    ↓
StartSession copies it: sessionRepo.AddRestItem(session.ID, displayOrder, ...)
    ↓
GetSession returns session with rest_items array
    ↓
SessionModel.fromProto() populates restItems: List<SessionRestItemModel>
    ↓
TrackerScreen builds unified _TrackerItem list, sorts by displayOrder
    ↓
RestItemCard renders inline for each rest item (not completed)
    user taps "Start Timer" → local countdown begins
    countdown reaches 0 → onComplete() fires
    ↓
activeSessionProvider.notifier.completeRestItem(restItemId)
    updates restItem.isCompleted = true, adds to _modifiedRestItemIds
    ↓
next sync cycle: SyncSession sends SyncRestItemData with is_completed = true
```

### Program Day Scheduling Flow

```
User activates a program (SetActiveProgram RPC)
    ↓
Backend: deactivates all programs, sets is_active = TRUE + started_at = NOW()
    (BUG: started_at not currently stored — needs migration + repo fix)
    ↓
User opens home screen or queries GetTodayWorkout
    ↓
Backend: GetActiveProgram finds is_active = TRUE program
    ↓
Calculate dayNumber:
    elapsedDays = floor(now - started_at)
    totalDays = duration_weeks*7 + duration_days
    dayNumber = (elapsedDays % totalDays) + 1
    (BUG: currently hardcoded to 1 — needs started_at fix first)
    ↓
Query program_days WHERE day_number = dayNumber
    ↓
Return day type (workout/rest/unassigned) + workout template if type=workout
    ↓
Home screen shows "Today's Workout" card with start button
    (BUG: home screen not yet wired to GetTodayWorkout provider)
    ↓
User finishes session
    ↓
FinishSession RPC: marks session completed, advances program
    (BUG: advancement not implemented — needs repo.AdvanceProgramDay or date-based calculation)
    ↓
If current day = last day: archive program
    (BUG: archiving not implemented)
```

### State Management (Frontend)

```
activeSessionProvider (AsyncValue<SessionModel?>)
    ↓ (subscribe via ref.watch)
TrackerScreen
    ↓ (calls)
activeSessionProvider.notifier.methods()
    → local state update via copyWith() → state = AsyncValue.data(updated)
    → _hasPendingChanges = true
    → SessionStorage.saveSession() (immediate local backup)
    ↓ (timer fires every 2s)
_performSync()
    → SyncSession RPC
    → state = AsyncValue.data(fromServer response)
    → SessionStorage.saveSession() (update backup with server IDs)
```

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Current (personal app) | Single process Go server, Supabase PostgreSQL, no queue. Correct for this scale. |
| 1k-100k users | No changes needed. Session sync is per-user (not shared), queries are indexed by user_id. |
| 100k+ users | Session sync volume may warrant WebSocket or SSE instead of polling. Not relevant to this milestone. |

### Scaling Priorities

1. **First bottleneck:** Session sync (2s polling). At high user counts this is constant write load. Solution: backoff when no changes, or use long-polling. Not relevant for this bug-fix milestone.
2. **Second bottleneck:** GetTodayWorkout is a read on an indexed column (is_active). Will not bottleneck.

## Anti-Patterns

### Anti-Pattern 1: Counting timer stops at 1, not 0

**What people do:** `if (timeRemaining.value <= 1) { onComplete(); }` — fires completion when value is 1, so user sees "0:01" then it disappears.

**Why it's wrong:** Timer never visually shows 0:00. Correct condition is `<= 0` and decrement should happen before the check, or the check should be after decrement.

**Do this instead:** The `Timer.periodic` callback should decrement first, then check: `timeRemaining.value--; if (timeRemaining.value <= 0) { timer.cancel(); onComplete(); }`. Or keep the decrement in the else branch and check `<= 0` before decrementing for the "show 0 briefly" UX.

### Anti-Pattern 2: Hardcoded day number in GetTodayWorkout

**What people do:** `dayNumber := 1` with a comment "real implementation would calculate based on program start date". This ships and the feature never works.

**Why it's wrong:** Always returns Day 1 regardless of when the program was started. Users can never advance through a program.

**Do this instead:** Store `started_at` when `SetActiveProgram` is called. Calculate `dayNumber = int(time.Since(startedAt).Hours()/24) % totalDays + 1`.

### Anti-Pattern 3: UpdateProgram handler that never updates

**What people do:** Handler fetches the program, returns it unchanged, without calling any repo mutation method. The handler body shows `GetByID` then `programToProto` — no `Update` call in between.

**Why it's wrong:** Any program edit from the frontend is silently dropped. The user sees no error but changes are not persisted.

**Do this instead:** Call `h.programRepo.Update(ctx, req.Msg.Id, userID, params)` with the fields from the request message.

### Anti-Pattern 4: Zero-duration rest items rendered in tracker

**What people do:** Template allows `rest_duration_seconds = 0` section items. These are copied into the session as `session_rest_items`. `RestItemCard` renders them as a visible card with a 0:00 timer.

**Why it's wrong:** A 0-second rest block is meaningless and clutters the tracker UI.

**Do this instead:** Filter in `TrackerScreen._buildSessionContent`: skip rendering `RestItemCard` if `restItem.restDurationSeconds == 0`. Alternatively filter at `StartSession` time in the backend before inserting.

### Anti-Pattern 5: Program archiving forgotten at program end

**What people do:** Mark sessions as complete but leave the program in `is_active = TRUE` indefinitely after the final day.

**Why it's wrong:** The active program keeps returning the last day forever. Users can never start a new program without manually deactivating the old one.

**Do this instead:** In `FinishSession` handler (or a separate RPC), check if the completed day number equals `totalDays`. If yes, set `is_active = FALSE, is_archived = TRUE` on the program.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| PostgreSQL (Supabase) | pgx connection pool, all queries via repository interfaces | No ORM; raw SQL via `pgx.Pool` |
| Connect-RPC | HTTP/2 + Protobuf, Buf-generated clients | Proto files must be kept in sync in both repos |
| SharedPreferences | Session backup via `SessionStorage` | Provides offline recovery for active sessions |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| TrackerScreen ↔ ActiveSession | `ref.read(activeSessionProvider.notifier).method()` for mutations; `ref.watch(activeSessionProvider)` for reads | No direct widget→server calls |
| ActiveSession ↔ SessionRepository | Connect-RPC via generated `sessionClient` singleton | All RPC calls go through `lib/core/client.dart` |
| SessionHandler ↔ WorkoutRepository | Handler injects both `sessionRepo` and `workoutRepo` — needed to read template sections during `StartSession` | Both are interface-typed; no direct pgx usage |
| ProgramHandler ↔ WorkoutRepository | Handler injects both `programRepo` and `workoutRepo` — needed to load workout template in `GetTodayWorkout` | Same pattern as session handler |
| HomeScreen ↔ ProgramService | Not yet wired — `GetTodayWorkout` RPC exists but no home provider calls it | Needs `todayWorkoutProvider` added to `home_providers.dart` |

## Sources

- Direct inspection of `HeftyBack/internal/handlers/session.go` and `program.go`
- Direct inspection of `HeftyBack/internal/repository/program.go` and `interfaces.go`
- Direct inspection of `hefty_chest/lib/features/tracker/` (providers, widgets, models)
- Migration files `00001_initial_schema.sql` through `00008_add_session_rest_items.sql`
- Proto definitions `session.proto` and `program.proto`
- No external sources consulted — all findings from codebase inspection (HIGH confidence)

---
*Architecture research for: Heft workout tracker — rest timer and program scheduling subsystems*
*Researched: 2026-03-10*
