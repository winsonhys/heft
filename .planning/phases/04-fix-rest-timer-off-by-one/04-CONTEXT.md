# Phase 4: Fix Rest Timer Off-by-One - Context

**Gathered:** 2026-03-10
**Status:** Ready for planning

<domain>
## Phase Boundary

The rest timer counts down to 0:00 and is visible at 0:00 before dismissing (not 0:01). Both `rest_item_card.dart` and `rest_timer_sheet.dart` must use the same correct countdown termination condition.

</domain>

<decisions>
## Implementation Decisions

### Termination condition fix
- `rest_item_card.dart:33` uses `<= 1` — change to `<= 0` to match `rest_timer_sheet.dart`
- Timer should show 0:00 for ~1 tick (~1 second) before auto-completing, matching existing `rest_timer_sheet` behavior
- Auto-complete behavior is preserved — timer fires `onComplete()` at termination, no user tap required

### rest_timer_sheet.dart verification
- `rest_timer_sheet.dart:47` already uses `<= 0` — confirmed correct, no change needed
- Both widgets will share the same termination semantics after fix

### Claude's Discretion
- Whether to extract shared countdown logic into a custom hook (only if trivial; don't over-engineer for a one-line fix)
- Test structure and assertions for verifying 0:00 visibility

</decisions>

<code_context>
## Existing Code Insights

### Bug Location
- `rest_item_card.dart:33` — `if (timeRemaining.value <= 1)` fires `onComplete()` at 1 second remaining, never displaying 0:00
- `rest_timer_sheet.dart:47` — `if (timeRemaining.value <= 0)` correctly waits until 0, shows 0:00 for ~1 second

### Established Patterns
- Both widgets use `HookWidget` with `useState` + `useEffect` + `Timer.periodic`
- `rest_item_card` has manual start/stop via `isTimerRunning` state; `rest_timer_sheet` auto-starts on mount
- `formatDuration()` from `shared/utils/formatters.dart` handles display formatting

### Integration Points
- `rest_item_card.dart` is used in tracker screen for inline rest items
- `rest_timer_sheet.dart` is used as an overlay (Phase 7 wires the trigger)
- `onComplete` callback marks the rest item as completed in session state

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

*Phase: 04-fix-rest-timer-off-by-one*
*Context gathered: 2026-03-10*
