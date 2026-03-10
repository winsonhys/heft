---
phase: 3
slug: fix-template-to-session-rest-item-copy
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-10
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Go testing standard library + testify |
| **Config file** | `HeftyBack/Makefile` |
| **Quick run command** | `cd HeftyBack && make test-unit` |
| **Full suite command** | `cd HeftyBack && make test-integration` |
| **Estimated runtime** | ~15 seconds (unit), ~30 seconds (integration) |

---

## Sampling Rate

- **After every task commit:** Run `cd HeftyBack && make test-unit`
- **After every plan wave:** Run `cd HeftyBack && make test-integration`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | REST-02 | integration | `cd HeftyBack && go test ./tests/integration/ -run TestSessionService_Integration_StartSession_CreatesRestItems -v` | ✅ | ⬜ pending |
| 03-01-02 | 01 | 1 | REST-02 | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestSessionHandler_StartSession_WithRestItems -v` | ✅ (partial — nil-skip case missing) | ⬜ pending |
| 03-02-01 | 02 | 1 | REST-02 | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestSessionHandler_StartSession_WithRestItems/nil_duration_skipped -v` | ❌ W0 | ⬜ pending |
| 03-02-02 | 02 | 1 | REST-02 | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestSessionHandler_StartSession_WithRestItems/zero_duration_copied -v` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `HeftyBack/internal/handlers/session_test.go` — add unit test case: "rest item with nil RestDurationSeconds is skipped"
- [ ] `HeftyBack/internal/handlers/session_test.go` — add unit test case: "rest item with zero duration is copied"

*Integration test infrastructure already covers all phase requirements — no new files needed for integration tests.*

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