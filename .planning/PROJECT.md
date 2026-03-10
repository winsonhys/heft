# Heft — Bug Fix Milestone

## What This Is

A bug-fixing milestone for Heft, a workout tracking platform with a Go backend (HeftyBack) and Flutter mobile app (hefty_chest). This milestone addresses 13 known bugs across the live session rest timer system and the training program scheduling system.

## Core Value

Rest timers and program scheduling must work correctly so users can follow their training plans day-to-day without manual workarounds.

## Requirements

### Validated

<!-- Existing capabilities confirmed working. -->

- ✓ Workout template CRUD (create, edit, duplicate, delete) — existing
- ✓ Exercise library with custom exercises — existing
- ✓ Live session tracking (start, sync, complete) — existing
- ✓ Superset grouping in sessions — existing
- ✓ Progress dashboard (stats, PRs, streaks) — existing
- ✓ Training program creation with day assignments — existing
- ✓ JWT authentication and user-scoped queries — existing
- ✓ Weight logging — existing

### Active

<!-- Bug fixes for this milestone. -->

- [ ] Rest timer counts down to 0 (not 1)
- [ ] Rest items from templates are added to sessions correctly
- [ ] Zero-duration rest items are not rendered in tracker
- [ ] Standalone rest items trigger the rest timer on completion
- [ ] Rest items and exercises display in correct order
- [ ] Program tracks start date when activated
- [ ] GetTodayWorkout returns the correct day based on elapsed time
- [ ] Completing a workout advances the program to the next day
- [ ] Programs end and archive after the last day
- [ ] UpdateProgram handler applies changes to the database
- [ ] Today's Workout shown on home screen from active program
- [ ] Debug fmt.Fprintf logging removed from session handler
- [ ] Rest item display order stays consistent with template order

### Out of Scope

- Program cycling (restart at day 1) — programs end and archive instead
- Rest duration editing mid-session — sync only tracks completion status
- Calendar month implementation — separate feature, not a bug
- New features or UI redesigns — bug fixes only

## Context

The codebase follows Clean Architecture with strict layer separation. Backend uses Connect-RPC with protobuf, PostgreSQL via Supabase. Frontend uses Flutter with Riverpod state management and Freezed immutable models.

Key files for this milestone:
- Backend: `handlers/session.go`, `handlers/program.go`, `repository/session.go`, `repository/program.go`
- Frontend: `tracker/providers/session_providers.dart`, `tracker/widgets/rest_item_card.dart`, `tracker/tracker_screen.dart`
- Proto: `session.proto`, `program.proto`, `workout.proto`
- Migrations: will need new migration for `programs.started_at` column

## Constraints

- **Proto contract**: Changes to `.proto` must be made in BOTH `HeftyBack/proto/` and `hefty_chest/proto/`, then `buf generate` in both
- **User scoping**: All new queries must include `WHERE user_id = $N`
- **Repository pattern**: No direct DB access from handlers
- **State immutability**: Frontend uses `copyWith()` for all state updates

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Programs end and archive (no cycling) | Simpler mental model; user can manually restart | — Pending |
| Fix rest timer off-by-one (count to 0) | Timer showing 0:01 then disappearing is confusing UX | — Pending |
| Add `started_at` column to programs table | Required to calculate current program day | — Pending |
| Remove debug logging from session handler | Production code should use structured logging | — Pending |

---
*Last updated: 2026-03-10 after initialization*
