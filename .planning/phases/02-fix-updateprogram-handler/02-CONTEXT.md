# Phase 2: Fix UpdateProgram Handler - Context

**Gathered:** 2026-03-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Wire the UpdateProgram handler to actually persist changes to the database. Currently it fetches the program and returns it unchanged — a no-op stub. Needs: interface method, SQL implementation, handler wiring.

</domain>

<decisions>
## Implementation Decisions

### Claude's Discretion
- Which fields are updatable (name, description, duration_weeks, duration_days, and/or days)
- Whether updating a program also replaces its days or just updates metadata
- SQL update strategy (partial update vs full replacement)
- Whether to add UpdateDay/DeleteDay methods or keep scope to program metadata only

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ProgramRepositoryInterface` in `interfaces.go` — needs `Update` method added
- `programToProto()` converter already exists in `program.go`
- `UpdateProgramRequest` proto message defines the updatable fields

### Established Patterns
- Repository pattern: interface first → implement → compile-time check
- User scoping: all queries WHERE user_id = $N
- Not found: nil, nil (not an error)
- Handler sequence: auth → validate → business logic → not-found check → return

### Integration Points
- `handlers/program.go:148-168` — UpdateProgram handler (currently a stub)
- `repository/interfaces.go:71-79` — ProgramRepositoryInterface (missing Update)
- `repository/program.go` — implementation file

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

*Phase: 02-fix-updateprogram-handler*
*Context gathered: 2026-03-10*
