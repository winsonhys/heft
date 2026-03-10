---
phase: 2
slug: fix-updateprogram-handler
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-10
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Go testing + testify (already configured) |
| **Config file** | none — driven by Makefile |
| **Quick run command** | `cd HeftyBack && make test-unit` |
| **Full suite command** | `cd HeftyBack && make test` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `cd HeftyBack && make test-unit`
- **After every plan wave:** Run `cd HeftyBack && make test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | PROG-04 | compile | `cd HeftyBack && go build ./...` | ❌ W0 | ⬜ pending |
| 02-02-01 | 02 | 1 | PROG-04 | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestProgramHandler_UpdateProgram/success_-_updates_name -v` | ❌ W0 | ⬜ pending |
| 02-02-02 | 02 | 1 | PROG-04 | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestProgramHandler_UpdateProgram/success_-_replaces_days -v` | ❌ W0 | ⬜ pending |
| 02-02-03 | 02 | 1 | PROG-04 | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestProgramHandler_UpdateProgram/success_-_no_days_unchanged -v` | ❌ W0 | ⬜ pending |
| 02-03-01 | 03 | 1 | PROG-04 | unit | `cd HeftyBack && go test ./internal/handlers/ -run TestProgramHandler_UpdateProgram -v` | ✅ (partial — stub cases exist) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `HeftyBack/internal/testutil/mocks.go` — add `UpdateFunc` and `DeleteDaysFunc` fields + method stubs to `MockProgramRepository`
- [ ] `HeftyBack/internal/handlers/program_test.go` — replace stub success case, add: "updates name", "replaces days", "no days unchanged", "Update DB error" cases

*Existing test file and mock file already exist; they need additions, not creation from scratch.*

---

## Manual-Only Verifications

*All phase behaviors have automated verification.*

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending