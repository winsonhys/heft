# Phase 3: Fix Template-to-Session Rest Item Copy - Context

**Gathered:** 2026-03-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Fix the nil-check in `StartSession` that silently drops valid rest items when copying from a workout template to a session. Audit the full loading path (SQL → Scan → struct → handler condition) and fix at the root cause.

</domain>

<decisions>
## Implementation Decisions

### Zero-duration handling
- Rest items with NULL duration in the database should be SKIPPED (not copied to session)
- Rest items with explicit duration (including 0) should be copied
- Phase 5 (REST-03) handles hiding zero-duration items in the UI — the data layer should faithfully copy what's in the template

### Fix depth
- Audit the full loading path: SQL query → Scan → repository struct → handler nil-check
- Fix the root cause if `rest_duration_seconds` isn't being loaded from the database for rest items
- Then adjust the nil-check condition at `session.go:118` if still needed
- Don't just patch the symptom — trace why `RestDurationSeconds` is nil when it shouldn't be

### Test coverage
- Unit test for the template loading path (verify rest_duration_seconds is populated in SectionItem structs)
- Integration test through StartSession (verify session contains rest items from template)
- Both levels of testing required

### Claude's Discretion
- Whether to use a default value for NULL durations or skip entirely (decision: skip NULL, copy everything else)
- Exact SQL fix if the loading query is the root cause
- How to structure the test fixtures (template with rest items, template without)

</decisions>

<code_context>
## Existing Code Insights

### Bug Location
- `handlers/session.go:118` — `item.ItemType == "rest" && item.RestDurationSeconds != nil` — the nil-check that filters out rest items
- `handlers/session.go:120` — `AddRestItem` call that only runs if nil-check passes
- `repository/workout.go:38-48` — `SectionItem` struct with `RestDurationSeconds *int`

### Potential Root Cause
- The SQL query that loads `SectionItem` data may not include `rest_duration_seconds` in SELECT/Scan
- The repository loading path for workout template sections needs auditing

### Established Patterns
- Repository returns `*int` for optional DB fields (nil = NULL in DB)
- Handler nil-checks before dereferencing pointers
- Integration tests in `tests/integration/session_service_test.go` already test rest items

### Integration Points
- `repository/workout.go` — template section item loading (potential SQL fix)
- `handlers/session.go:97-124` — StartSession template-to-session copy loop
- `tests/integration/session_service_test.go` — existing rest item test infrastructure

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-fix-template-to-session-rest-item-copy*
*Context gathered: 2026-03-10*