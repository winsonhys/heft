# Codebase Concerns

**Analysis Date:** 2026-03-10

## Tech Debt

### Debug Logging Left in Production Code

**Issue:** Multiple `fmt.Fprintf` and `fmt.Fprintln` debug statements to `os.Stderr` in session handler
- Files: `HeftyBack/internal/handlers/session.go` (lines 36-37, 110-147)
- Impact: Pollutes server logs with debug output, makes production logs hard to read, could expose internal details
- Fix approach: Replace with structured logging using Go's `log` package or remove completely now that session sync is stable
  - Session startup: Lines 36-37 (unused, remove)
  - Item processing: Lines 110-147 (used for debugging rest items, can be replaced with `log.Printf` at Debug level or removed)

### Incomplete Frontend Features Marked as TODO

**Issue:** 3 feature stubs remain in workout card context menu and 1 in calendar
- Files:
  - `hefty_chest/lib/features/home/widgets/workout_card.dart` (lines 144, 152, 160)
  - `hefty_chest/lib/features/calendar/calendar_screen.dart` (line 114)
- Impact: UI shows action buttons that don't work, poor user experience
- Fix approach: Either implement the features (rename workout, duplicate workout, view history, day detail modal) or remove the menu items

## Security Considerations

### Overly Permissive CORS Configuration

**Issue:** CORS allows all origins (`AllowedOrigins: []string{"*"}`)
- Files: `HeftyBack/cmd/server/main.go` (line 150)
- Current mitigation: `AllowCredentials: false` prevents credential exposure, but doesn't prevent unauthorized clients from making requests
- Risk: Any website can make requests to the API on behalf of users, increasing CSRF attack surface
- Recommendations:
  1. Limit `AllowedOrigins` to known frontend URLs: `["https://heft-frontend.example.com", "http://localhost:3000"]`
  2. Document the CORS policy change when deploying to production
  3. Update config to allow CORS origins via environment variable for multi-environment support

### Default JWT Secret in Development

**Issue:** JWT secret has a hardcoded default value used if `JWT_SECRET` env var is not set
- Files: `HeftyBack/internal/config/config.go` (line 31)
- Impact: If deployed without setting `JWT_SECRET`, tokens use predictable secret `"heft-dev-secret-change-in-production"`
- Current mitigation: Only affects development; production deployment requires explicit env var setup
- Recommendations:
  1. Remove the default value and make JWT_SECRET required
  2. Add validation in `config.Load()` to fail fast if critical secrets are missing
  3. Add startup warning if `TestMode == true` in production config

### Test User Credentials in Migrations

**Issue:** Test user password hash in committed migration file
- Files: `HeftyBack/migrations/00003_test_user.sql` (line 7)
- Impact: Password hash is public, though bcrypt hash is not reversible
- Mitigation: Hash is for development/testing only; migration includes explicit test data
- Recommendations:
  1. Document that this migration should only run in TEST_MODE
  2. Create separate migration file for integration test setup vs. production
  3. Add guard in migration to prevent accidental production insertion

## Performance Bottlenecks

### Session Sync Handler Rebuilds Full Session After Sync

**Issue:** `SyncSession` handler reloads entire session from database after syncing sets/exercises
- Files: `HeftyBack/internal/handlers/session.go` (lines 327-351)
- Problem: Causes unnecessary DB query after sync; for large sessions with many exercises/sets, this is expensive
- Current scale: Works fine for typical <20 exercises with <10 sets each
- Scaling path: Add incremental reload option to proto, or return synced entities directly from sync operation

### Debug Logging with Printf Creates Allocations

**Issue:** Multiple `fmt.Fprintf` calls in session processing loop
- Files: `HeftyBack/internal/handlers/session.go` (lines 110-148)
- Problem: Each `fmt.Fprintf` allocates strings and buffers; in loops with many items, this adds up
- Current impact: Minor for typical workouts (5-20 items), but grows with superset workouts
- Improvement: Switch to structured logging or remove debug logs entirely

### Calendar and Progress Screens Missing Pagination

**Issue:** Calendar and progress screens fetch all data without pagination support
- Files:
  - `hefty_chest/lib/features/calendar/calendar_screen.dart`
  - `hefty_chest/lib/features/progress/progress_screen.dart`
- Current capacity: Works for <100 sessions/data points
- Scaling limit: Performance degrades significantly with >500 session records
- Scaling path: Add pagination or lazy loading to proto contracts and implement in Riverpod providers

## Fragile Areas

### Proto Files Manually Duplicated Across Projects

**Issue:** Proto schema duplicated in two locations, must be manually kept in sync
- Files:
  - `HeftyBack/proto/heft/v1/*.proto`
  - `hefty_chest/proto/*.proto`
- Why fragile: Human error can cause schema mismatch; easy to update one side but not the other
- Safe modification: **CRITICAL PROCESS**: When changing any `.proto` file:
  1. Update BOTH locations
  2. Run `buf generate` in BOTH projects
  3. Test both frontend and backend changes together
  4. Consider shared proto monorepo or git submodule for future refactor
- Risk: API versioning mismatch between client and server; silently dropped fields
- Test coverage: Only caught by integration tests (not by unit tests)

### Session Sync Logic Complex with Multiple Oneof Patterns

**Issue:** `SyncSession` request uses oneof pattern for identifying sets (existing ID vs. new set with temp ID)
- Files:
  - `HeftyBack/internal/handlers/session.go` (lines 206-255, 286-305)
  - `hefty_chest/lib/features/tracker/models/session_models.dart`
- Why fragile: Oneof pattern is error-prone; missing edge cases in condition checks
- Safe modification: When updating sync logic:
  1. Add comprehensive test cases for each oneof combination
  2. Log both old and new values in integration tests
  3. Consider breaking into separate API calls (CreateSet, UpdateSet, DeleteSet) instead of combined sync
- Example edge case: What happens if both `id` and `sessionExerciseId` are provided? (Current behavior: prefers `id`)

### REST Item Processing Has Conditional Branches

**Issue:** REST items added via template must match `itemType == "rest"` and have `RestDurationSeconds` set
- Files: `HeftyBack/internal/handlers/session.go` (lines 138-148)
- Why fragile: Silent skip if type/duration mismatch occurs (debug logs appear but no error returned)
- Safe modification: Add validation and error return if expected fields missing
- Test coverage: Gap in `session_test.go` - missing test for malformed rest items

### Workout Section to Session Item Mapping Has Manual Validation

**Issue:** Session creation from template manually iterates workout sections and items, validating types
- Files: `HeftyBack/internal/handlers/session.go` (lines 93-151)
- Why fragile: Type checking is string-based (`item.ItemType == "exercise"` vs `"rest"`); easy to add new type and forget to update handler
- Safe modification: Consider enum type in proto instead of string; create handler helper function for type mapping
- Risk: New item types added to proto won't work until handler is updated

## Missing Critical Features

### Feature Gaps in Frontend UI

**Issue:** 3 UI actions are stubbed but not implemented
- Affects: Workout management, history viewing
- Blocks: Users cannot rename or duplicate workouts via UI; cannot view workout history
- Priority: Medium - Users can still manage workouts via database/backend directly
- Recommendations:
  1. `TODO: Rename workout` → Implement `WorkoutService.UpdateWorkout` call
  2. `TODO: Duplicate workout` → Implement `WorkoutService.DuplicateWorkout` call
  3. `TODO: View history` → Implement navigation to history screen or session list
  4. `TODO: Implement day detail modal` → Add modal showing calendar day's sessions

## Test Coverage Gaps

### Session Handler Rest Item Processing Not Fully Tested

**Issue:** REST item creation from template lacks edge case coverage
- Files:
  - `HeftyBack/internal/handlers/session.go` (lines 138-148)
  - `HeftyBack/internal/handlers/session_test.go`
- What's not tested:
  - Rest item with no duration specified (silent skip currently)
  - Rest item with duration = 0
  - Mixed exercise and rest items in same section
  - Rest item without section name
- Risk: Bug in rest item handling could silently break trainer's workout structure
- Priority: High - Critical for trainer feature

### Calendar Day Detail Modal Not Implemented

**Issue:** Day detail view is stubbed but not functional
- Files: `hefty_chest/lib/features/calendar/calendar_screen.dart` (line 114)
- Blocks: Users cannot see details of sessions on a specific calendar day
- Risk: Users can see workouts happened but cannot review details
- Priority: Medium

### Missing Integration Tests for Sync Deletions

**Issue:** `SyncSession` supports deleting sets and exercises, but deletion edge cases lack test coverage
- Files: `HeftyBack/internal/handlers/session_test.go`
- What's missing:
  - Delete set that doesn't belong to session (should be no-op or error)
  - Delete exercise with sets still present
  - Sync with deletes followed by re-adds of same exercise
- Risk: Data inconsistency if deletion logic has bugs
- Priority: High - Critical for data integrity

## Known Issues

### Debug Output in Session Startup

**Issue:** Production code contains debug fmt.Fprintf statements in critical path
- Symptoms: Server logs show `[StartSession] Processing item` and similar debug messages on every session start
- Files: `HeftyBack/internal/handlers/session.go` (lines 36-37, 97-98, 110-148)
- Workaround: This is harmless but noisy; messages go to stderr
- Root cause: Left over from development debugging of rest items feature
- Status: Shipping as-is; plan cleanup in next refactor phase

## Deployment & Configuration Issues

### Environment-Specific Backend URL in Frontend

**Issue:** Frontend backend URL is hardcoded per build (dev vs. release)
- Files: `hefty_chest/lib/core/config.dart` (line 8)
- Current:
  - Debug: `http://localhost:8080`
  - Release: `https://heft-751339253558.asia-southeast1.run.app`
- Risk: Cannot easily switch environments in released app; URL baked into binary
- Recommendations:
  1. Add ability to override backend URL at app startup (settings screen)
  2. Store selected URL in SharedPreferences/secure storage
  3. Add QA environment URL alongside production
  4. Consider API discovery endpoint for future multi-region support

### Test Mode Disabled in Production Safe Way

**Issue:** TEST_MODE enables `/test/reset` endpoint that clears all user data
- Files: `HeftyBack/cmd/server/main.go` (lines 84-129)
- Current mitigation: Only enabled if `TEST_MODE=true` env var explicitly set
- Risk: Accidental data loss if TEST_MODE accidentally set in production
- Recommendations:
  1. Add warning on startup if TEST_MODE is enabled
  2. Require additional confirmation via header to call `/test/reset` (e.g., signature)
  3. Add audit logging of reset calls
  4. Document that TEST_MODE should never be true in production

### JWT Expiration Not Enforced Uniformly

**Issue:** JWT expiration hours configurable but frontend has no refresh token logic
- Files:
  - `HeftyBack/internal/config/config.go` (line 32)
  - `hefty_chest/lib/features/auth/providers/auth_providers.dart`
- Current: Default 168 hours (7 days); token stored in SharedPreferences
- Risk: If token expires during app session, user stuck in logged-in state but requests fail
- Recommendations:
  1. Implement refresh token endpoint in backend
  2. Add token expiration handler in frontend that silently refreshes or re-prompts login
  3. Monitor token expiration on app resume (e.g., in app lifecycle)

---

*Concerns audit: 2026-03-10*
