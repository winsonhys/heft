# Phase 5: Guard Zero-Duration Rest Items - Research

**Researched:** 2026-03-10
**Domain:** Go backend (StartSession handler) + Flutter frontend (tracker_screen.dart / RestItemCard)
**Confidence:** HIGH

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| REST-03 | Zero-duration rest items are not rendered in the tracker UI | Backend guard at `session.go:118` (nil-check) passes zero-duration items through; frontend `tracker_screen.dart` iterates `session.restItems` without filtering; both guards are missing and must be added |
</phase_requirements>

## Summary

Phase 5 adds two defensive guards to prevent zero-duration rest items from reaching the user. The first guard is in the backend `StartSession` handler (`HeftyBack/internal/handlers/session.go:118`): the existing condition `item.RestDurationSeconds != nil` copies all non-NULL rest items — including those with explicit `rest_duration_seconds = 0` — into the session. This is intentional behavior per Phase 3, but REST-03 now says zero-duration items should also be excluded. The fix is to strengthen the condition to `item.RestDurationSeconds != nil && *item.RestDurationSeconds > 0`.

The second guard is in the Flutter tracker screen (`hefty_chest/lib/features/tracker/tracker_screen.dart`). In `_buildSessionContent` at lines 325-330, `session.restItems` is iterated without any filter and unconditionally added to `itemsBySection`. If a zero-duration rest item reaches the frontend (e.g. via a direct `GetSession` call or a bug in data), it will be rendered as a `RestItemCard` with a 0:00 timer — an empty, broken card. The fix is to filter `session.restItems` before building `itemsBySection`, keeping only items where `restDurationSeconds > 0`.

The two guards are defense-in-depth: the backend guard prevents zero-duration items from being stored in the session at all; the frontend guard ensures they are never displayed even if one somehow reaches the client. The guards are independent and can be implemented as separate plans (05-01 for backend, 05-02 for frontend).

**Primary recommendation:** Add `&& *item.RestDurationSeconds > 0` to the backend guard at `session.go:118`, and add `.where((r) => r.restDurationSeconds > 0).toList()` before the `itemsBySection` loop in `tracker_screen.dart`. Both changes are single-line additions.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Go | 1.25 | Backend language | Project standard |
| connectrpc.com/connect | v1.16.0 | RPC handler pattern | Project standard |
| Flutter/Dart | 3.10.3+ | Frontend language | Project standard |
| flutter_hooks / hooks_riverpod | current | State + widget hooks in tracker | Project standard for HookConsumerWidget |
| freezed | current | Immutable session models | Project standard; `SessionRestItemModel.restDurationSeconds` is `int` (non-nullable) |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| testutil (internal) | internal | MockSessionRepository, MockWorkoutRepository | Backend unit tests |
| flutter_test | SDK | Flutter widget tests | Frontend widget tests |

### Alternatives Considered
None relevant — no new libraries required. Both changes are logic guards inside existing code.

## Architecture Patterns

### Relevant Project Structure
```
HeftyBack/
└── internal/
    └── handlers/
        ├── session.go              # Line 118: backend guard (StartSession copy loop)
        └── session_test.go         # TestSessionHandler_StartSession_WithRestItems — 3 cases already exist

hefty_chest/
└── lib/
    └── features/
        └── tracker/
            ├── tracker_screen.dart        # _buildSessionContent lines 325-330: frontend filter
            ├── models/
            │   └── session_models.dart    # SessionRestItemModel.restDurationSeconds: int
            ├── providers/
            │   └── session_providers.dart # activeSessionProvider
            └── widgets/
                └── rest_item_card.dart    # RestItemCard — renders any restItem handed to it
test/
└── widgets/
    └── tracker_screen_test.dart   # Existing tests use wrapWithThemeAndProvider + MockActiveSession
```

### Pattern 1: Backend Guard — Strengthened Nil-and-Zero Check
**What:** Current condition at `session.go:118` copies rest items where `RestDurationSeconds != nil`. Must also exclude zero.
**Fix:** Single condition change.
**Current:**
```go
// session.go:118
} else if item.ItemType == "rest" && item.RestDurationSeconds != nil {
```
**After fix:**
```go
} else if item.ItemType == "rest" && item.RestDurationSeconds != nil && *item.RestDurationSeconds > 0 {
```
**Why safe:** Nil check is still first — no panic risk. `*item.RestDurationSeconds > 0` only evaluates after nil is confirmed.

### Pattern 2: Frontend Filter — Pre-Loop Where Clause
**What:** In `_buildSessionContent`, `session.restItems` is iterated and added to `itemsBySection`. Filter before the loop.
**Current (tracker_screen.dart:325-330):**
```dart
for (final restItem in session.restItems) {
  final sectionName = restItem.sectionName.isEmpty ? 'Exercises' : restItem.sectionName;
  itemsBySection.putIfAbsent(sectionName, () => []).add(
    _TrackerItem.rest(restItem),
  );
}
```
**After fix:**
```dart
for (final restItem in session.restItems.where((r) => r.restDurationSeconds > 0)) {
  final sectionName = restItem.sectionName.isEmpty ? 'Exercises' : restItem.sectionName;
  itemsBySection.putIfAbsent(sectionName, () => []).add(
    _TrackerItem.rest(restItem),
  );
}
```
**Alternative approach (extract filtered list first):**
```dart
final visibleRestItems = session.restItems.where((r) => r.restDurationSeconds > 0).toList();
for (final restItem in visibleRestItems) { ... }
```
Both are equally correct. The inline `.where()` is more concise; the extracted variable is slightly more readable for tests.

### Pattern 3: Table-Driven Backend Unit Test Extension
**What:** The existing `TestSessionHandler_StartSession_WithRestItems` in `session_test.go` already has 3 cases: (1) success with 90s, (2) nil skipped, (3) zero copied. Phase 5 requires adding a new case: "rest item with zero duration is NOT inserted (zero is now excluded)". This changes the assertion for case (3) from "zero is copied" to "zero is skipped".
**Impact:** The existing "copies rest item with zero duration" test case (lines 1030-1131) directly conflicts with the Phase 5 requirement. Phase 5 changes the semantics: zero duration must be excluded just like NULL. The test must be updated from "copied" to "skipped".

### Pattern 4: Flutter Widget Test with MockActiveSession
**What:** `tracker_screen_test.dart` uses `MockActiveSession` (overrides `activeSessionProvider`) + `wrapWithThemeAndProvider`. The test verifies rendered widgets.
**How to test the filter:** Provide a `SessionModel` with a zero-duration rest item in `restItems`; verify `find.byType(RestItemCard)` finds nothing (or zero matching items).
**Existing infrastructure:**
```dart
class MockActiveSession extends ActiveSession {
  final SessionModel? _mockSession;
  MockActiveSession(this._mockSession);
  @override
  AsyncValue<SessionModel?> build() => AsyncValue.data(_mockSession);
}
```
`wrapWithThemeAndProvider(child, mockSession: session)` injects the mock.

### Anti-Patterns to Avoid
- **Filtering in RestItemCard:** Do NOT add a guard inside `RestItemCard.build()` that renders nothing when `restDurationSeconds == 0`. The card widget must not know about this invariant — the filter belongs at the data preparation level in `_buildSessionContent`.
- **Filtering in SessionModel.fromProto:** Do NOT filter in the model constructor or `fromProto`. The model should faithfully represent what the backend returns. The tracker screen is the correct filter boundary for display logic.
- **Changing AddRestItem interface:** `AddRestItem` takes `int` (not `*int`). The fix is at the call site guard, not the interface.
- **Removing the nil check:** Keep `item.RestDurationSeconds != nil` — it prevents a nil-pointer dereference. The zero check is additive.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Nil-safe int comparison | Custom nullable helper | `item.RestDurationSeconds != nil && *item.RestDurationSeconds > 0` | Go idiomatic two-part guard; safe and clear |
| Test mock injection | New mock system | Existing `testutil.MockSessionRepository` + `MockWorkoutRepository` | Already has `AddRestItemFunc` field for call interception |
| Widget test setup | New test harness | `wrapWithThemeAndProvider(child, mockSession: ...)` + `MockActiveSession` | Existing pattern in `tracker_screen_test.dart` |

## Common Pitfalls

### Pitfall 1: Updating "zero is copied" test to "zero is skipped" — test conflict
**What goes wrong:** Phase 3 established unit tests asserting "zero duration is copied". Phase 5 reverses this: zero duration must now be skipped. If the Phase 3 test is not updated, it will fail.
**Why it happens:** Phase 3 locked the decision "nil=skip, &0=copy". Phase 5 tightens this to "nil=skip, &0=skip, >0=copy". The Phase 3 test case name is "copies rest item with zero duration" and its assertion `len(resp.Session.RestItems) == 1` will now be wrong.
**How to avoid:** In Plan 05-01, explicitly update the existing "copies rest item with zero duration" test case in `session_test.go` to assert `len(resp.Session.RestItems) == 0` and rename it to "skips rest item with zero duration". Do NOT leave the old assertion in place.
**Warning sign:** `TestSessionHandler_StartSession_WithRestItems` fails after the backend fix is applied.

### Pitfall 2: Backend fix not covering the "already in session" path
**What goes wrong:** Developer adds the guard in `StartSession` but forgets that `SyncSession` or `GetSession` responses can also return rest items with zero duration if they were already inserted in the DB before this fix.
**Why it happens:** Phase 5 goal states "if a zero-duration rest item somehow reaches the frontend" — this is what the frontend filter handles.
**How to avoid:** The frontend filter (Plan 05-02) is the safety net for items already stored. Both guards are required. Do not assume the backend fix alone is sufficient.

### Pitfall 3: Frontend filter placed after `_TrackerItem` list is built
**What goes wrong:** Developer adds `if (item.restDurationSeconds == 0) continue;` inside `_buildSectionItems` instead of filtering `session.restItems` before the loop.
**Why it happens:** `_buildSectionItems` is where `RestItemCard` widgets are built, so it seems like the right place.
**How to avoid:** Filter at the source data level (`session.restItems`) before the outer loop in `_buildSessionContent`. This prevents zero-duration items from entering `itemsBySection` entirely, keeping `_buildSectionItems` simple.

### Pitfall 4: go_router and navigation in tracker widget tests
**What goes wrong:** `TrackerScreen` uses `context.go('/')` for finish/discard actions. Tests without a `GoRouter` will crash when those paths are exercised.
**How to avoid:** The zero-duration filter test does not need to navigate — it only verifies the display list. Use `wrapWithThemeAndProvider` which wraps with `MaterialApp` (no GoRouter needed for render-only tests). For tests that involve navigation, the existing test file already handles this pattern.

## Code Examples

Verified patterns from actual source files:

### Backend Guard — Current (session.go:118)
```go
// Source: HeftyBack/internal/handlers/session.go:118
} else if item.ItemType == "rest" && item.RestDurationSeconds != nil {
    _, err := h.sessionRepo.AddRestItem(ctx, session.ID, item.DisplayOrder, &section.Name, *item.RestDurationSeconds)
    if err != nil {
        return nil, handleDBError(err)
    }
}
```

### Backend Guard — After Fix
```go
// Source: HeftyBack/internal/handlers/session.go:118 (Phase 5 target)
} else if item.ItemType == "rest" && item.RestDurationSeconds != nil && *item.RestDurationSeconds > 0 {
    _, err := h.sessionRepo.AddRestItem(ctx, session.ID, item.DisplayOrder, &section.Name, *item.RestDurationSeconds)
    if err != nil {
        return nil, handleDBError(err)
    }
}
```

### Frontend Filter — Current (tracker_screen.dart:325-330)
```dart
// Source: hefty_chest/lib/features/tracker/tracker_screen.dart:325
for (final restItem in session.restItems) {
  final sectionName = restItem.sectionName.isEmpty ? 'Exercises' : restItem.sectionName;
  itemsBySection.putIfAbsent(sectionName, () => []).add(
    _TrackerItem.rest(restItem),
  );
}
```

### Frontend Filter — After Fix
```dart
// Source: hefty_chest/lib/features/tracker/tracker_screen.dart:325 (Phase 5 target)
for (final restItem in session.restItems.where((r) => r.restDurationSeconds > 0)) {
  final sectionName = restItem.sectionName.isEmpty ? 'Exercises' : restItem.sectionName;
  itemsBySection.putIfAbsent(sectionName, () => []).add(
    _TrackerItem.rest(restItem),
  );
}
```

### Backend Unit Test — New Case for Zero Skipped
```go
// To add to TestSessionHandler_StartSession_WithRestItems in session_test.go
// UPDATE existing "copies rest item with zero duration" case OR add new "skips zero duration" case
{
    name:     "skips rest item with zero duration",
    // ...
    mockSetup: func(sr *testutil.MockSessionRepository, wr *testutil.MockWorkoutRepository) {
        zeroDuration := 0
        // RestDurationSeconds: &zeroDuration — must be skipped (same as nil per Phase 5)
        sr.AddRestItemFunc = func(...) (*repository.SessionRestItem, error) {
            t.Error("AddRestItem should not be called for zero duration")
            return nil, errors.New("unexpected call")
        }
        // GetByID returns session with 0 rest items
    },
    checkResponse: func(t *testing.T, resp *heftv1.StartSessionResponse) {
        if len(resp.Session.RestItems) != 0 {
            t.Errorf("expected 0 rest items (zero duration skipped), got %d", len(resp.Session.RestItems))
        }
    },
},
```

### Frontend Widget Test — New Case for Zero-Duration Filter
```dart
// To add to tracker_screen_test.dart (new group or within TrackerScreen group)
testWidgets('does not render rest item with zero duration', (tester) async {
  final sessionWithZeroRest = SessionModel(
    id: 'test-session',
    workoutTemplateId: 'test-workout',
    name: 'Test',
    exercises: [],
    restItems: [
      const SessionRestItemModel(
        id: 'rest-zero',
        displayOrder: 1,
        sectionName: 'Main',
        restDurationSeconds: 0,  // zero — must be filtered
      ),
    ],
  );

  await tester.pumpWidget(
    wrapWithThemeAndProvider(
      const TrackerScreen(),
      mockSession: sessionWithZeroRest,
    ),
  );
  await tester.pumpAndSettle();

  // No RestItemCard should be rendered
  expect(find.byType(RestItemCard), findsNothing);
});
```

**Note:** The `TrackerScreen` tests that actually render the full screen need a `GoRouter` or careful scope. The `_buildSessionContent` logic can also be tested by unit-testing `_TrackerItem` construction — but since `_buildSessionContent` and `_buildSectionItems` are private methods, the cleanest approach is a widget test through `wrapWithThemeAndProvider` as shown above. Check existing tracker_screen_test.dart for the correct full scaffold wrapping pattern used for `TrackerScreen` vs `TrackerSectionCard` tests.

### SessionRestItemModel (session_models.dart)
```dart
// Source: hefty_chest/lib/features/tracker/models/session_models.dart:126
@freezed
sealed class SessionRestItemModel with _$SessionRestItemModel {
  const factory SessionRestItemModel({
    required String id,
    required int displayOrder,
    required String sectionName,
    required int restDurationSeconds,   // non-nullable int — 0 is a valid Dart int
    @Default(false) bool isCompleted,
    DateTime? completedAt,
  }) = _SessionRestItemModel;
```
`restDurationSeconds` is a non-nullable `int` in Dart (from protobuf `int32`). The backend sends `int32(ri.RestDurationSeconds)` in `sessionRestItemToProto`. If a zero-duration rest item is stored, it arrives as `restDurationSeconds: 0`. The filter `r.restDurationSeconds > 0` is correct.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| nil=skip, &0=copy (Phase 3 semantics) | nil=skip, &0=skip, >0=copy (Phase 5) | Phase 5 | Backend only inserts meaningful rest items; frontend also filters defensively |

**Semantics change from Phase 3:** Phase 3 locked "nil=skip, &0=copy" because a zero-duration rest item with an *explicit* duration was considered valid. Phase 5 redefines this: zero duration is meaningless from the user's perspective (a rest timer showing 0:00 is confusing/broken). The Phase 3 test case "copies rest item with zero duration" must be updated to "skips rest item with zero duration".

## Open Questions

1. **Are zero-duration rest items already in the database?**
   - What we know: Phase 3 confirmed the copy condition is `!= nil`, so any rest item with `rest_duration_seconds = 0` stored in the DB would have been copied to sessions created after Phase 3.
   - What's unclear: Whether any production sessions currently have zero-duration rest items in `session_rest_items` table.
   - Recommendation: Out of scope for this phase. The frontend filter (Plan 05-02) provides protection for any pre-existing data.

2. **Should `_buildSectionItems` also guard (defense-in-depth within frontend)?**
   - What we know: The filter in `_buildSessionContent` (outer loop) is sufficient to prevent `RestItemCard` rendering.
   - What's unclear: Whether an additional check inside `_buildSectionItems` would be cleaner.
   - Recommendation: Filter once at `_buildSessionContent`. No need to add redundant checks deeper — keep `_buildSectionItems` unchanged.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Go testing stdlib (backend) + flutter_test (frontend) |
| Config file | `HeftyBack/Makefile` (backend) / no config file (frontend) |
| Quick run command | `cd /Users/winson.heng/heft/HeftyBack && go test -v -short ./internal/handlers/ -run TestSessionHandler_StartSession_WithRestItems` |
| Full suite command | `cd /Users/winson.heng/heft/HeftyBack && make test-unit` AND `cd /Users/winson.heng/heft/hefty_chest && flutter test test/widgets/tracker_screen_test.dart` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| REST-03 | Backend: zero-duration rest item is not inserted into session | unit | `cd /Users/winson.heng/heft/HeftyBack && go test -v -short ./internal/handlers/ -run TestSessionHandler_StartSession_WithRestItems` | Partial — existing "copies zero" case must be updated to "skips zero" |
| REST-03 | Frontend: zero-duration rest item is not rendered in tracker | widget | `cd /Users/winson.heng/heft/hefty_chest && flutter test test/widgets/tracker_screen_test.dart` | No — new test case needed |

### Sampling Rate
- **Per task commit:** Backend: `cd /Users/winson.heng/heft/HeftyBack && go test -v -short ./internal/handlers/ -run TestSessionHandler_StartSession_WithRestItems`; Frontend: `cd /Users/winson.heng/heft/hefty_chest && flutter test test/widgets/tracker_screen_test.dart`
- **Per wave merge:** `cd /Users/winson.heng/heft/HeftyBack && make test-unit` + `cd /Users/winson.heng/heft/hefty_chest && flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `HeftyBack/internal/handlers/session_test.go` — update "copies rest item with zero duration" case: change assertion from "1 rest item" to "0 rest items", rename to "skips rest item with zero duration", change `AddRestItemFunc` to fail if called
- [ ] `hefty_chest/test/widgets/tracker_screen_test.dart` — add new test case: "does not render rest item with zero duration" using `MockActiveSession` with `restItems: [SessionRestItemModel(restDurationSeconds: 0)]` and asserting `find.byType(RestItemCard)` finds nothing

*(Both files exist; only new test cases are needed, not new files)*

## Sources

### Primary (HIGH confidence)
- Direct source read: `HeftyBack/internal/handlers/session.go` — StartSession handler, lines 88-127, exact guard at line 118 confirmed
- Direct source read: `hefty_chest/lib/features/tracker/tracker_screen.dart` — `_buildSessionContent` lines 315-335, no filter on `session.restItems` confirmed
- Direct source read: `hefty_chest/lib/features/tracker/models/session_models.dart` — `SessionRestItemModel.restDurationSeconds` is non-nullable `int`
- Direct source read: `HeftyBack/internal/handlers/session_test.go` — existing 3-case test at line 813, "copies rest item with zero duration" case at line 1030 confirmed
- Direct source read: `hefty_chest/test/widgets/tracker_screen_test.dart` — `MockActiveSession`, `wrapWithThemeAndProvider` patterns confirmed
- Direct source read: `hefty_chest/lib/features/tracker/widgets/rest_item_card.dart` — widget renders any `SessionRestItemModel` unconditionally

### Secondary (MEDIUM confidence)
- `.planning/phases/03-fix-template-to-session-rest-item-copy/03-RESEARCH.md` — Phase 3 locked decisions confirmed; zero-copy semantics now superseded by Phase 5 requirement
- `.planning/STATE.md` — Phase 3 decision "item.RestDurationSeconds != nil is correct" was per Phase 3 scope; Phase 5 extends the guard

## Metadata

**Confidence breakdown:**
- Bug location (backend): HIGH — exact line confirmed by direct source read
- Bug location (frontend): HIGH — exact loop confirmed by direct source read, no filter present
- Fix approach (both): HIGH — single-line additions, no interface changes, no new files
- Test impact: HIGH — Phase 3 "zero is copied" test directly conflicts; must update before running tests
- Regression risk: LOW — backend change only affects zero-duration rest items (rare edge case); frontend change only affects the display loop

**Research date:** 2026-03-10
**Valid until:** N/A — codebase analysis, not ecosystem survey
