# Heft

Workout tracking platform: Go backend (HeftyBack) + Flutter mobile app (hefty_chest).
Users create workout templates, follow training programs, track live sessions, and monitor progress.

## Golden Principles

Mechanical rules. Violations are bugs, not style issues.

1. **Proto is the contract.** Change `.proto` in BOTH `HeftyBack/proto/` AND `hefty_chest/proto/`, then `buf generate` in both. Never hand-edit `gen/` files.
2. **User ID comes from JWT.** Backend extracts user ID from auth context, never from request body. Frontend never sends user_id in requests.
3. **All queries are user-scoped.** Every SQL query touching user data MUST include `WHERE user_id = $N`. No exceptions.
4. **Repository interfaces mediate all DB access.** Handlers never import `pgx` directly. Add interface method, implement, inject.
5. **Errors map to Connect codes.** Use `handleDBError()` for DB errors. See error code table in `docs/conventions.md`.
6. **State is immutable.** Frontend uses `copyWith()` for all state updates. No direct mutation.
7. **Features are self-contained.** Each frontend feature owns its screen, providers, and widgets. No cross-feature imports except via `shared/`.

## Architecture Layers

Dependencies flow DOWN only. Never import upward.

```
Backend:  Proto → Config → Repository → Handlers → Middleware → Server
Frontend: Gen → Core → Shared → Features → App
```

Boundary violations = bugs. If you need something from a higher layer, you have the wrong abstraction.

## Knowledge Base

| What you need | Where to find it |
|---|---|
| Architecture, data flow, layers | `docs/architecture.md` |
| Backend patterns, DB schema, services | `docs/backend.md` |
| Frontend patterns, state, routing, UI | `docs/frontend.md` |
| Code conventions, error codes, naming | `docs/conventions.md` |
| Testing infrastructure and patterns | `docs/testing.md` |
| Step-by-step task recipes | `docs/workflows.md` |
| Backend quick reference | `HeftyBack/CLAUDE.md` |
| Frontend quick reference | `hefty_chest/CLAUDE.md` |

## Quick Start

| Task | Command |
|---|---|
| Full dev environment | `./dev.sh` (backend + mobile) |
| Dev on web | `./dev.sh -w` |
| Clean DB + restart | `./dev.sh --clean` |
| Backend tests | See `HeftyBack/CLAUDE.md` |
| Frontend tests | See `hefty_chest/CLAUDE.md` |
| E2E tests | `./run_e2e_tests.sh` |
| Proto changes | See `docs/workflows.md` — MUST update both sides |

## Tech Stack

| | Backend | Frontend |
|--|---------|----------|
| Language | Go 1.25 | Dart/Flutter 3.10.3+ |
| API | Connect-RPC v1.16.0 | Connect-RPC v1.0.0 |
| DB | PostgreSQL (Supabase) | — |
| State | — | Riverpod 3.0 + Hooks |
| UI | — | forui 0.17.0 |
| Build | Makefile + Docker | Flutter CLI |

Boring technology wins. These are stable, well-documented, and well-represented in training data.

## Entropy Rules

When you encounter these patterns, fix them immediately — don't propagate:

- SQL query without user scoping → Add `WHERE user_id = $N`
- Handler accessing DB directly → Route through repository interface
- Frontend mutating state directly → Use `copyWith()`
- Cross-feature imports → Extract to `shared/`
- Hardcoded user ID → Use JWT auth context
- Generated code hand-edited → Regenerate with `buf generate`
- Hardcoded colors → Use `AppColors` constants
- Material widgets where forui exists → Use `FButton`, `FTextField`, etc.

## Feedback Loops

When an agent struggles with a task, treat it as a signal. The fix is not a better prompt — it's a better harness:

1. Missing documentation → Add to `docs/`
2. Repeated mistake → Add to Golden Principles or Entropy Rules
3. Architectural violation → Add mechanical check
4. Unclear pattern → Add example to `docs/conventions.md`

Every mistake an agent makes should result in a harness improvement so it never happens again.
