---
phase: 4
slug: fix-rest-timer-off-by-one
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-10
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (built into Flutter SDK) |
| **Config file** | none — standard Flutter test discovery |
| **Quick run command** | `cd hefty_chest && flutter test test/widgets/rest_item_card_test.dart` |
| **Full suite command** | `cd hefty_chest && flutter test` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `cd hefty_chest && flutter test test/widgets/rest_item_card_test.dart`
- **After every plan wave:** Run `cd hefty_chest && flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 01 | 1 | REST-01 | widget | `cd hefty_chest && flutter test test/widgets/rest_item_card_test.dart` | ✅ (needs new test case) | ⬜ pending |
| 04-02-01 | 02 | 1 | REST-01 | widget | `cd hefty_chest && flutter test test/widgets/rest_item_card_test.dart` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/widgets/rest_item_card_test.dart` — add `shows 0:00 before calling onComplete` test case (file exists, new assertion needed)
- [ ] Verify `rest_timer_sheet.dart` uses `<= 0` (manual code review acceptable — no changes made to sheet)

*Existing infrastructure covers framework needs. Only new test cases required.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| `rest_timer_sheet.dart` uses `<= 0` | REST-01 | Read-only confirmation, no code change | Inspect line 47: confirm `timeRemaining.value <= 0` |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
