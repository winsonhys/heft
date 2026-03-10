# Phase 1: Remove Debug Logging - Context

**Gathered:** 2026-03-10
**Status:** Ready for planning

<domain>
## Phase Boundary

Remove all debug `fmt.Fprintf`/`fmt.Fprintln` calls from `handlers/session.go`. This is a cleanup phase — no behavior changes, just removing debug output from production code.

</domain>

<decisions>
## Implementation Decisions

### Claude's Discretion
- Whether to also remove the 7 `log.Printf` debug lines (lines 97, 308, 309, 316, 323, 354, 356) in addition to the required 5 `fmt.Fprintf`/`fmt.Fprintln` lines
- Whether to replace any useful debug lines with proper structured logging or just delete them outright
- Whether the `fmt` import can be fully removed after cleanup

</decisions>

<code_context>
## Existing Code Insights

### Targets
- `session.go:36` — `fmt.Fprintln(os.Stderr, "[StartSession] HANDLER CALLED VIA FMT...")`
- `session.go:37` — `fmt.Fprintf(os.Stderr, "[StartSession] Request: workoutTemplateId=%s\n", ...)`
- `session.go:110` — `fmt.Fprintf(os.Stderr, "[StartSession] Processing item: type=%q...")`
- `session.go:139` — `fmt.Fprintf(os.Stderr, "[StartSession] Adding rest item with duration %d\n", ...)`
- `session.go:146` — `fmt.Fprintf(os.Stderr, "[StartSession] SKIPPED item: type=%q...")`

### Also Present
- 7 `log.Printf` debug statements in the same file (SyncSession handler)
- Other handlers do not have debug logging

### Established Patterns
- No other handler uses `fmt.Fprintf` for logging — this is session.go-specific debug scaffolding
- The codebase uses `log.Printf` elsewhere for operational logging

### Integration Points
- No integration needed — this is a pure deletion/cleanup task

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

*Phase: 01-remove-debug-logging*
*Context gathered: 2026-03-10*
