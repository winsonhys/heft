# Requirements: Heft Bug Fix Milestone

**Defined:** 2026-03-10
**Core Value:** Rest timers and program scheduling must work correctly so users can follow their training plans day-to-day without manual workarounds

## v1 Requirements

Requirements for this milestone. Each maps to roadmap phases.

### Rest Timer

- [ ] **REST-01**: Rest timer counts down to 0 before dismissing (not 1)
- [ ] **REST-02**: Rest items from workout templates are correctly added to sessions on start
- [ ] **REST-03**: Zero-duration rest items are not rendered in the tracker UI
- [ ] **REST-04**: Standalone rest items trigger the rest timer overlay on completion
- [ ] **REST-05**: Rest items and exercises display in correct template order within sections
- [ ] **REST-06**: Rest item display order remains consistent throughout the session

### Program Scheduling

- [ ] **PROG-01**: Program records start date when activated via SetActiveProgram
- [ ] **PROG-02**: GetTodayWorkout returns the correct day number based on elapsed calendar time
- [ ] **PROG-03**: Programs end and archive after the last day is reached
- [x] **PROG-04**: UpdateProgram handler applies changes to the database
- [ ] **PROG-05**: Today's Workout from active program is displayed on the home screen

### Cleanup

- [x] **CLEN-01**: Debug fmt.Fprintf/fmt.Fprintln logging removed from session handler
- [ ] **CLEN-02**: Rest item display order is correctly copied from template section item order during session creation

## v2 Requirements

Deferred to future milestones. Tracked but not in current roadmap.

### Rest Timer Enhancements

- **REST-V2-01**: Rest timer audio/vibration alert when timer completes
- **REST-V2-02**: Screen stays awake during rest timer countdown
- **REST-V2-03**: Adaptive rest duration suggestions based on history

### Program Enhancements

- **PROG-V2-01**: Program progress visualization (day X of Y with progress bar)
- **PROG-V2-02**: Missed day handling (skip or makeup)
- **PROG-V2-03**: Calendar month view showing program schedule

## Out of Scope

| Feature | Reason |
|---------|--------|
| Rest duration editing mid-session | SyncSession only tracks is_completed; adding duration edits is a schema change with significant complexity |
| Program cycling (restart at day 1) | Programs end and archive; user can manually restart for a clean mental model |
| Calendar month implementation | Separate feature, not a bug fix |
| Automatic rest item creation between sets | Conflates two rest models (per-set rest vs standalone rest items) |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| REST-01 | Phase 4 | Pending |
| REST-02 | Phase 3 | Pending |
| REST-03 | Phase 5 | Pending |
| REST-04 | Phase 7 | Pending |
| REST-05 | Phase 6 | Pending |
| REST-06 | Phase 6 | Pending |
| PROG-01 | Phase 8 | Pending |
| PROG-02 | Phase 9 | Pending |
| PROG-03 | Phase 10 | Pending |
| PROG-04 | Phase 2 | Complete |
| PROG-05 | Phase 11 | Pending |
| CLEN-01 | Phase 1 | Complete |
| CLEN-02 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 13 total
- Mapped to phases: 13
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-10*
*Last updated: 2026-03-10 after roadmap creation*
