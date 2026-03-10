# Phase 4: Fix Rest Timer Off-by-One - Research

**Researched:** 2026-03-10
**Domain:** Flutter widget timer logic (HookWidget + Timer.periodic)
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- `rest_item_card.dart:33` uses `<= 1` — change to `<= 0` to match `rest_timer_sheet.dart`
- Timer should show 0:00 for ~1 tick (~1 second) before auto-completing, matching existing `rest_timer_sheet` behavior
- Auto-complete behavior is preserved — timer fires `onComplete()` at termination, no user tap required
- `rest_timer_sheet.dart:47` already uses `<= 0` — confirmed correct, no change needed
- Both widgets will share the same termination semantics after fix

### Claude's Discretion
- Whether to extract shared countdown logic into a custom hook (only if trivial; don't over-engineer for a one-line fix)
- Test structure and assertions for verifying 0:00 visibility

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| REST-01 | Rest timer counts down to 0 before dismissing (not 1) | Bug is in `rest_item_card.dart:33` — `<= 1` terminates one tick early; fix to `<= 0` makes timer decrement to 0 then fire `onComplete()` on the next tick, matching `rest_timer_sheet.dart:47` behavior |
</phase_requirements>

---

## Summary

Phase 4 is a single-line bug fix in one Flutter widget. The `RestItemCard` widget terminates its countdown at `timeRemaining <= 1`, which means `onComplete()` fires while the display still shows `0:01`. The correct condition is `<= 0`, which lets the timer decrement to 0 (displaying `0:00` for one tick) before firing. `RestTimerSheet` already uses `<= 0` and is the reference implementation.

The two timer widgets use identical structural patterns: `HookWidget` with `useState` for `timeRemaining`, `useEffect` with `Timer.periodic(Duration(seconds: 1), ...)`, and a termination condition that either cancels the timer and calls `onComplete()` or decrements the counter. The only difference is that `RestItemCard` guards the effect on `[isTimerRunning.value]` (manual start/stop), while `RestTimerSheet` starts on mount with `[]` dependencies.

The existing `rest_item_card_test.dart` test at line 159–185 (`calls onComplete when timer finishes`) pumps a 2-second timer and expects `onComplete` after 2 pumps. With the `<= 1` bug, `onComplete` fires after 1 pump. The test currently passes but for the wrong reason — after the fix the same test will correctly validate the full countdown. A new test for 0:00 visibility is needed in Claude's discretion scope.

**Primary recommendation:** Change `<= 1` to `<= 0` on line 33 of `rest_item_card.dart`. Do not extract a shared hook — the fix is one character and extraction would add complexity without value.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_hooks | project dep | `useState`, `useEffect` hooks | Both widgets already use it; established project pattern |
| dart:async | stdlib | `Timer.periodic` | Standard Dart; no dependency needed |
| flutter_test | dev dep | Widget pump tests with fake timers | Built-in Flutter testing framework |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| formatters.dart | project util | `formatDuration(int)` → MM:SS | Display countdown text; already imported in both widgets |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Inline `<= 0` in each widget | Extract `useCountdownTimer` custom hook | Hook extraction is cleaner long-term but overkill for a one-line fix in two files; CONTEXT.md says don't over-engineer |

**Installation:** No new packages required.

---

## Architecture Patterns

### Existing Timer Pattern (Both Widgets)

Both widgets follow the same structure. This is the reference pattern from `rest_timer_sheet.dart` (correct):

```dart
// Source: hefty_chest/lib/features/tracker/widgets/rest_timer_sheet.dart:45-55
useEffect(() {
  final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (timeRemaining.value <= 0) {  // <= 0 is correct
      timer.cancel();
      onComplete();
    } else {
      timeRemaining.value--;
    }
  });
  return () => timer.cancel();
}, []);
```

The buggy pattern from `rest_item_card.dart` (incorrect):

```dart
// Source: hefty_chest/lib/features/tracker/widgets/rest_item_card.dart:32-39
final timer = Timer.periodic(const Duration(seconds: 1), (_) {
  if (timeRemaining.value <= 1) {  // BUG: fires when display = 0:01
    isTimerRunning.value = false;
    onComplete();
  } else {
    timeRemaining.value = timeRemaining.value - 1;
  }
});
```

### Countdown Termination Semantics

With `<= 0` (correct behavior):

```
Tick 0 (start): timeRemaining = N, display = N:SS
Tick 1:         timeRemaining = N-1, display decremented
...
Tick N-1:       timeRemaining = 1, display = 0:01
Tick N:         timeRemaining = 0, display = 0:00  ← user sees 0:00
Tick N+1:       condition <= 0 fires → onComplete()
```

With `<= 1` (buggy behavior):

```
...
Tick N-1:       timeRemaining = 1 → condition <= 1 fires → onComplete()
                display never reaches 0:00  ← BUG
```

### Effect Dependency Difference

`RestItemCard` restarts the timer effect when `isTimerRunning.value` changes:
```dart
}, [isTimerRunning.value]);  // re-runs when timer starts/stops
```

`RestTimerSheet` runs once on mount:
```dart
}, []);  // auto-start on mount
```

This difference is intentional and unrelated to the bug fix. Do not change effect dependencies.

### Anti-Patterns to Avoid
- **Changing effect dependencies:** Do not touch `[isTimerRunning.value]` in `RestItemCard` — it is correct for manual start/stop behavior.
- **Extracting a shared hook:** The CONTEXT.md decision is explicit — only if trivial. A custom hook requires a new file, documentation, and adds an abstraction layer for a one-character fix.
- **Resetting `timeRemaining` to 0 on complete:** The widget receives a new `restItem` via props which triggers the reset effect at line 44-49. Do not add redundant state resets inside the timer callback.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| MM:SS display | Custom formatter | `formatDuration()` from `shared/utils/formatters.dart` | Already imported; handles edge cases (0:00, 10:00+) |
| Fake timers in tests | Manual time tracking | `tester.pump(Duration(seconds: N))` | Flutter test framework drives `Timer.periodic` deterministically |

**Key insight:** Flutter's widget test framework (`tester.pump`) advances the fake clock, making `Timer.periodic` callbacks fire deterministically without real elapsed time. Tests with fake timers are instant and deterministic.

---

## Common Pitfalls

### Pitfall 1: Test Expectation for `restDurationSeconds: 2` with `<= 1` bug

**What goes wrong:** The existing test `calls onComplete when timer finishes` uses `restDurationSeconds: 2` and pumps twice. With `<= 1`, `onComplete` fires at tick 1 (when `timeRemaining = 1`). After fixing to `<= 0`, the timer decrements to 1 at tick 1, then to 0 at tick 2 — but `onComplete` only fires at tick 3 (next periodic callback after value reaches 0). With `restDurationSeconds: 2`, the test may need an extra pump.

**Why it happens:** `Timer.periodic` fires the callback every tick. The decrement and the check happen in the same callback. With `<= 0`: tick 1 decrements 2→1, tick 2 decrements 1→0, tick 3 sees 0, fires `onComplete`. That is 3 ticks for a 2-second timer.

**How to avoid:** Verify the existing `calls onComplete when timer finishes` test still passes after the fix. If it fails, update the pump count to match the corrected behavior (3 pumps for a 2-second timer that shows 0:00 before completing).

**Warning signs:** Test failure on the `completeCalled` assertion after applying the fix.

### Pitfall 2: Forgetting `isTimerRunning.value = false` in RestItemCard

**What goes wrong:** In `RestTimerSheet`, the timer is cancelled via `timer.cancel()`. In `RestItemCard`, the cleanup is done by setting `isTimerRunning.value = false` which triggers the effect cleanup (`return timer.cancel`). If the fix accidentally removes `isTimerRunning.value = false` from the completion path, the effect loop may not clean up.

**Why it happens:** The two widgets use different timer lifecycle patterns.

**How to avoid:** The minimal fix is only changing `<= 1` to `<= 0`. Do not restructure the callback.

### Pitfall 3: 0:00 Visibility Is ~1 Second, Not Guaranteed

**What goes wrong:** The 0:00 display is visible for one timer period (~1 second), but it is not a "held" display — it disappears on the next tick when `onComplete()` is called. Tests that pump in very small increments may miss the 0:00 window.

**Why it happens:** The timer fires at fixed 1-second intervals. The sequence is: decrement to 0 (display updates), then next tick fires `onComplete()`.

**How to avoid:** In tests, pump exactly `Duration(seconds: 1)` after reaching the 0:00 state, then check. Do not pump in sub-second increments expecting to "catch" 0:00.

---

## Code Examples

### Corrected Timer Callback (rest_item_card.dart)

```dart
// Source: hefty_chest/lib/features/tracker/widgets/rest_item_card.dart — after fix
final timer = Timer.periodic(const Duration(seconds: 1), (_) {
  if (timeRemaining.value <= 0) {  // was: <= 1
    isTimerRunning.value = false;
    onComplete();
  } else {
    timeRemaining.value = timeRemaining.value - 1;
  }
});
```

### Test: Timer Shows 0:00 Before Completing

```dart
// New test for REST-01 — 0:00 visibility
testWidgets('shows 0:00 before calling onComplete', (tester) async {
  bool completeCalled = false;

  await tester.pumpWidget(
    createTestWidget(
      child: RestItemCard(
        restItem: createMockRestItem(restDurationSeconds: 2),
        onComplete: () => completeCalled = true,
        onSkip: () {},
      ),
    ),
  );

  await tester.tap(find.text('Start Timer'));
  await tester.pump();

  // Tick 1: 2 → 1
  await tester.pump(const Duration(seconds: 1));
  expect(completeCalled, isFalse);

  // Tick 2: 1 → 0, display shows 0:00
  await tester.pump(const Duration(seconds: 1));
  expect(find.text('0:00'), findsOneWidget);
  expect(completeCalled, isFalse);

  // Tick 3: <= 0 fires onComplete
  await tester.pump(const Duration(seconds: 1));
  expect(completeCalled, isTrue);
});
```

### Existing Test That Must Still Pass

```dart
// Source: hefty_chest/test/widgets/rest_item_card_test.dart:159-185
// After fix: restDurationSeconds: 2 needs 3 ticks total, not 2
// Verify this test is updated if it fails after the fix
testWidgets('calls onComplete when timer finishes', (tester) async {
  // ... pump twice currently — may need a third pump after fix
});
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `<= 1` in RestItemCard | `<= 0` (matching RestTimerSheet) | Phase 4 | Timer shows 0:00 before dismissing — correct UX |

**Deprecated/outdated:**
- `<= 1` termination condition: Fires `onComplete` one tick early; user never sees 0:00 display.

---

## Open Questions

1. **Existing test for `restDurationSeconds: 2` — will it pass or fail after fix?**
   - What we know: With `<= 1`, `onComplete` fires at tick 1 (pump 1 second). With `<= 0`, decrement happens at tick 2, check at tick 3.
   - What's unclear: Whether the existing test pumps enough times to still pass.
   - Recommendation: Run `flutter test test/widgets/rest_item_card_test.dart` after applying the fix. Update pump count if the test fails.

2. **Should the custom hook extraction happen?**
   - What we know: CONTEXT.md says "only if trivial; don't over-engineer for a one-line fix."
   - What's unclear: Whether a shared hook would be used by Phase 7 (RestTimerSheet trigger wiring) to reduce future drift.
   - Recommendation: Skip for Phase 4. Revisit in Phase 7 when both widgets are wired together.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (built into Flutter SDK) |
| Config file | none — standard Flutter test discovery |
| Quick run command | `cd /Users/winson.heng/heft/hefty_chest && flutter test test/widgets/rest_item_card_test.dart` |
| Full suite command | `cd /Users/winson.heng/heft/hefty_chest && flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| REST-01 | Timer shows 0:00 before `onComplete()` fires | widget | `flutter test test/widgets/rest_item_card_test.dart` | Partial — existing file covers timer start/stop, missing 0:00 visibility assertion |
| REST-01 | `rest_timer_sheet.dart` already uses `<= 0` (no regression) | widget | `flutter test test/widgets/` | No dedicated sheet test exists yet; manual verification or new test |

### Sampling Rate

- **Per task commit:** `cd /Users/winson.heng/heft/hefty_chest && flutter test test/widgets/rest_item_card_test.dart`
- **Per wave merge:** `cd /Users/winson.heng/heft/hefty_chest && flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `test/widgets/rest_item_card_test.dart` — add `shows 0:00 before calling onComplete` test case (file exists, new test case needed)
- [ ] `test/widgets/rest_timer_sheet_test.dart` — verify `<= 0` is correct (file does not exist; manual confirmation from code review acceptable for Phase 4 since no change is made to the sheet)

---

## Sources

### Primary (HIGH confidence)
- Direct code inspection: `hefty_chest/lib/features/tracker/widgets/rest_item_card.dart` — bug at line 33 confirmed
- Direct code inspection: `hefty_chest/lib/features/tracker/widgets/rest_timer_sheet.dart` — correct condition at line 47 confirmed
- Direct code inspection: `hefty_chest/test/widgets/rest_item_card_test.dart` — existing test coverage confirmed

### Secondary (MEDIUM confidence)
- Flutter HookWidget + Timer.periodic pattern verified from existing project code — both widgets use identical structure
- `formatters.dart` `formatDuration()` behavior verified — `formatDuration(0)` returns `"0:00"` (confirmed: `0 ~/ 60 = 0`, `0 % 60 = 0`, returns `"0:00"`)

### Tertiary (LOW confidence)
- None required — all findings come from direct source inspection

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — Flutter + flutter_hooks + dart:async, all already in use
- Architecture: HIGH — both widgets inspected directly, bug location confirmed
- Pitfalls: HIGH — timer tick semantics derived directly from `Timer.periodic` behavior and existing test structure

**Research date:** 2026-03-10
**Valid until:** Stable — no external dependencies; valid until source files change
