# Roadmap: Heft Bug Fix Milestone

## Overview

This milestone fixes 13 known bugs across the rest timer system and program scheduling system. The two subsystems are independent of each other but each has internal dependency ordering. Program scheduling has a hard schema prerequisite (started_at migration) that must land before any day-calculation logic. Rest timer bugs have an internal ordering constraint: the template-to-session copy fix must precede display order and overlay-trigger verification. Phases are ordered to respect these dependencies and deliver verifiable correctness at each step.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Remove Debug Logging** - Clean production session handler of fmt.Fprintf/fmt.Fprintln debug output (completed 2026-03-10)
- [ ] **Phase 2: Fix UpdateProgram Handler** - Wire UpdateProgram to actually persist changes to the database
- [x] **Phase 3: Fix Template-to-Session Rest Item Copy** - Correct nil-check logic so rest items from templates are added to sessions (completed 2026-03-10)
- [x] **Phase 4: Fix Rest Timer Off-by-One** - Timer counts down to 0:00 before dismissing (not 0:01) (completed 2026-03-10)
- [ ] **Phase 5: Guard Zero-Duration Rest Items** - Prevent zero-duration rest items from being inserted or rendered
- [ ] **Phase 6: Fix Rest Item Display Order** - Rest items and exercises render in correct, consistent template order
- [ ] **Phase 7: Wire Rest Timer Overlay Trigger** - Standalone rest items trigger the RestTimerSheet overlay on completion
- [ ] **Phase 8: Add Program Start Date Migration** - Schema prerequisite: programs table gains started_at column
- [ ] **Phase 9: Fix Today's Workout Day Calculation** - GetTodayWorkout returns correct day number from elapsed calendar time
- [ ] **Phase 10: Program Archival on Completion** - Programs end and archive after the last day is completed
- [ ] **Phase 11: Home Screen Today's Workout** - Active program's today workout is displayed on the home screen

## Phase Details

### Phase 1: Remove Debug Logging
**Goal**: Production session handler emits no raw fmt.Fprintf/fmt.Fprintln output
**Depends on**: Nothing (first phase)
**Requirements**: CLEN-01
**Success Criteria** (what must be TRUE):
  1. Starting a session produces no debug output on the server's stderr stream
  2. The session handler source contains no fmt.Fprintf or fmt.Fprintln calls
  3. All existing session handler tests pass after the change
**Plans:** 1/1 plans complete

Plans:
- [ ] 01-01-PLAN.md — Remove all debug logging (fmt + log) from session handler and clean imports

### Phase 2: Fix UpdateProgram Handler
**Goal**: Editing a program's name, days, or exercises persists correctly to the database
**Depends on**: Phase 1
**Requirements**: PROG-04
**Success Criteria** (what must be TRUE):
  1. Calling UpdateProgram with a new name causes the program to reflect that name on the next GetProgram call
  2. The UpdateProgram handler calls the repository Update method (not a read-only path)
  3. ProgramRepositoryInterface declares Update, and the compile-time interface check passes
**Plans:** 1 plan

Plans:
- [ ] 02-01-PLAN.md — Add Update + DeleteDays to repo interface/impl/mock, wire handler, rewrite tests

### Phase 3: Fix Template-to-Session Rest Item Copy
**Goal**: Starting a session from a template that contains rest items produces a session with those rest items included
**Depends on**: Phase 2
**Requirements**: REST-02
**Success Criteria** (what must be TRUE):
  1. A session started from a template with rest items contains those rest items in the session data
  2. A session started from a template with no rest items is unaffected
  3. The nil-check in StartSession no longer filters out valid rest items
**Plans:** 1/1 plans complete

Plans:
- [ ] 03-01-PLAN.md — Audit loading path, add nil-skip and zero-duration unit tests, fix handler condition if needed

### Phase 4: Fix Rest Timer Off-by-One
**Goal**: The rest timer counts down to 0:00 and is visible at 0:00 before dismissing
**Depends on**: Phase 3
**Requirements**: REST-01
**Success Criteria** (what must be TRUE):
  1. The countdown displays 0:00 before the timer dismisses
  2. Both rest_item_card.dart and rest_timer_sheet.dart use the same correct countdown termination condition
  3. The timer does not disappear while still showing 0:01
**Plans:** 1/1 plans complete

Plans:
- [ ] 04-01-PLAN.md — Fix <= 1 to <= 0 in rest_item_card.dart, update and add tests for 0:00 visibility, confirm rest_timer_sheet.dart already correct

### Phase 5: Guard Zero-Duration Rest Items
**Goal**: Zero-duration rest items are never inserted into sessions and never rendered in the tracker UI
**Depends on**: Phase 3
**Requirements**: REST-03
**Success Criteria** (what must be TRUE):
  1. A template with a zero-duration rest item starts a session that does not contain that rest item
  2. If a zero-duration rest item somehow reaches the frontend, the tracker screen does not render it
  3. No empty rest item cards appear in the tracker during any session
**Plans**: TBD

Plans:
- [ ] 05-01: Add backend guard in StartSession: only insert rest items where rest_duration_seconds > 0
- [ ] 05-02: Add frontend filter in tracker_screen.dart before building the display list

### Phase 6: Fix Rest Item Display Order
**Goal**: Rest items and exercises render in the same order as defined in the template, and that order remains consistent throughout the session
**Depends on**: Phase 3
**Requirements**: REST-05, REST-06, CLEN-02
**Success Criteria** (what must be TRUE):
  1. Opening the tracker shows exercises and rest items interleaved exactly as ordered in the template
  2. The order does not change after syncing sets or completing exercises
  3. display_order values in the session items match the template section item order at session creation time
**Plans**: TBD

Plans:
- [ ] 06-01: Verify that the template builder assigns a single monotonically increasing display_order across exercises and rest items within a section
- [ ] 06-02: Fix StartSession to copy display_order from template section items into session items (CLEN-02)
- [ ] 06-03: Fix tracker_screen.dart sort to use display_order as the single sort key for the merged exercise+rest list

### Phase 7: Wire Rest Timer Overlay Trigger
**Goal**: Completing a standalone rest item causes the RestTimerSheet overlay to appear and begin counting down
**Depends on**: Phase 4, Phase 6
**Requirements**: REST-04
**Success Criteria** (what must be TRUE):
  1. Marking a standalone rest item as complete causes the full-screen RestTimerSheet overlay to appear
  2. The overlay counts down for the correct duration from the rest item
  3. Completing a non-rest exercise item does not trigger the rest timer overlay
**Plans**: TBD

Plans:
- [ ] 07-01: Add onTriggerRestTimer callback parameter to RestItemCard widget
- [ ] 07-02: Wire the callback in tracker_screen.dart to open RestTimerSheet with the correct duration

### Phase 8: Add Program Start Date Migration
**Goal**: The programs table has a started_at column, and activating a program records its start timestamp
**Depends on**: Phase 2
**Requirements**: PROG-01
**Success Criteria** (what must be TRUE):
  1. The programs table has a started_at column after migration runs
  2. Calling SetActiveProgram sets started_at to the current timestamp for the activated program
  3. The Program struct and all RETURNING clauses include started_at
**Plans**: TBD

Plans:
- [ ] 08-01: Create goose migration 00009_add_program_started_at.sql adding started_at TIMESTAMP column
- [ ] 08-02: Update SetActive in repository/program.go to write started_at = CURRENT_TIMESTAMP
- [ ] 08-03: Update Program struct and all RETURNING * clauses to include started_at

### Phase 9: Fix Today's Workout Day Calculation
**Goal**: GetTodayWorkout returns the correct program day based on how many calendar days have elapsed since activation
**Depends on**: Phase 8
**Requirements**: PROG-02
**Success Criteria** (what must be TRUE):
  1. Activating a program and calling GetTodayWorkout on day 0 returns day 1
  2. Calling GetTodayWorkout after N calendar days have elapsed returns day N+1 (or the last day if past end)
  3. GetTodayWorkout handles NULL started_at gracefully (treats as day 1)
**Plans**: TBD

Plans:
- [ ] 09-01: Replace hardcoded day 1 in handlers/program.go GetTodayWorkout with elapsed-day calculation using time.Since(startedAt) / 24h
- [ ] 09-02: Add nil/NULL started_at guard that falls back to day 1

### Phase 10: Program Archival on Completion
**Goal**: Completing the last workout in a program marks it as archived and inactive
**Depends on**: Phase 9
**Requirements**: PROG-03
**Success Criteria** (what must be TRUE):
  1. Completing the final day's session causes the program to appear as archived and inactive on the next load
  2. An archived program no longer appears as the active program
  3. AdvanceDay and Archive methods on ProgramRepositoryInterface are implemented and the compile-time check passes
**Plans**: TBD

Plans:
- [ ] 10-01: Add AdvanceDay and Archive methods to ProgramRepositoryInterface and implement in repository/program.go
- [ ] 10-02: Wire FinishSession in handlers/session.go to call AdvanceDay; if day exceeds last day, call Archive

### Phase 11: Home Screen Today's Workout
**Goal**: The home screen shows the current day's workout from the active program when one exists
**Depends on**: Phase 9
**Requirements**: PROG-05
**Success Criteria** (what must be TRUE):
  1. Opening the app with an active program shows a "Today's Workout" card on the home screen
  2. The card shows the correct workout name for today's program day
  3. Opening the app with no active program shows no "Today's Workout" card
**Plans**: TBD

Plans:
- [ ] 11-01: Create a getTodayWorkout Riverpod provider that calls the backend GetTodayWorkout RPC
- [ ] 11-02: Wire the provider to home_screen.dart and render the Today's Workout card

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9 -> 10 -> 11

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Remove Debug Logging | 1/1 | Complete   | 2026-03-10 |
| 2. Fix UpdateProgram Handler | 0/1 | Not started | - |
| 3. Fix Template-to-Session Rest Item Copy | 1/1 | Complete   | 2026-03-10 |
| 4. Fix Rest Timer Off-by-One | 1/1 | Complete   | 2026-03-10 |
| 5. Guard Zero-Duration Rest Items | 0/2 | Not started | - |
| 6. Fix Rest Item Display Order | 0/3 | Not started | - |
| 7. Wire Rest Timer Overlay Trigger | 0/2 | Not started | - |
| 8. Add Program Start Date Migration | 0/3 | Not started | - |
| 9. Fix Today's Workout Day Calculation | 0/2 | Not started | - |
| 10. Program Archival on Completion | 0/2 | Not started | - |
| 11. Home Screen Today's Workout | 0/2 | Not started | - |
