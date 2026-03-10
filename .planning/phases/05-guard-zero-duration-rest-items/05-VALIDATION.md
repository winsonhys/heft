---
phase: 5
slug: guard-zero-duration-rest-items
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-10
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Go testing stdlib (backend) + flutter_test (frontend) |
| **Config file** | `HeftyBack/Makefile` (backend) / none (frontend) |
| **Quick run command** | Backend: `cd HeftyBack && go test -v -short ./internal/handlers/ -run TestSessionHandler_StartSession_WithRestItems` / Frontend: `cd hefty_chest && flutter test test/widgets/tracker_screen_test.dart` |
| **Full suite command** | `cd HeftyBack && make test-unit` AND `cd hefty_chest && flutter test` |
| **Estimated runtime** | ~15 seconds (backend) + ~10 seconds (frontend) |

---

## Sampling Rate

- **After every task commit:** Run quick run command for the relevant subsystem (backend or frontend)
- **After every plan wave:** Run full suite for both subsystems
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | REST-03 | unit | `cd HeftyBack && go test -v -short ./internal/handlers/ -run TestSessionHandler_StartSession_WithRestItems` | ✅ (update existing case) | ⬜ pending |
| 05-02-01 | 02 | 1 | REST-03 | widget | `cd hefty_chest && flutter test test/widgets/tracker_screen_test.dart` | ✅ (add new case) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `HeftyBack/internal/handlers/session_test.go` — update "copies rest item with zero duration" case to "skips rest item with zero duration"
- [ ] `hefty_chest/test/widgets/tracker_screen_test.dart` — add "does not render rest item with zero duration" test case

*Both files exist; only new/updated test cases needed, not new files.*

---

## Manual-Only Verifications

*All phase behaviors have automated verification.*

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
