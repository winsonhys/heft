#!/bin/bash
# Claude Stop hook: run relevant tests when code files have uncommitted changes.
# Exit 0 = pass (Claude stops normally)
# Exit 2 = fail (Claude sees failures and can fix them)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKEND_DIR="$PROJECT_DIR/HeftyBack"
FRONTEND_DIR="$PROJECT_DIR/hefty_chest"

# Check for uncommitted changes in relevant files
GO_CHANGES=$(cd "$PROJECT_DIR" && git diff --name-only HEAD 2>/dev/null | grep '\.go$' || true)
DART_CHANGES=$(cd "$PROJECT_DIR" && git diff --name-only HEAD 2>/dev/null | grep '\.dart$' || true)

# Also check staged but uncommitted
GO_STAGED=$(cd "$PROJECT_DIR" && git diff --cached --name-only 2>/dev/null | grep '\.go$' || true)
DART_STAGED=$(cd "$PROJECT_DIR" && git diff --cached --name-only 2>/dev/null | grep '\.dart$' || true)

GO_CHANGES="${GO_CHANGES}${GO_STAGED}"
DART_CHANGES="${DART_CHANGES}${DART_STAGED}"

if [ -z "$GO_CHANGES" ] && [ -z "$DART_CHANGES" ]; then
    exit 0
fi

FAILED=0

# Backend tests
if [ -n "$GO_CHANGES" ]; then
    echo "Go changes detected — running backend tests..." >&2
    if ! (cd "$BACKEND_DIR" && make test-unit 2>&1); then
        echo "BACKEND TESTS FAILED" >&2
        FAILED=1
    fi
fi

# Frontend tests (unit + contract tests, no Docker needed)
# Excludes test/e2e/ which requires a running backend
if [ -n "$DART_CHANGES" ]; then
    echo "Dart changes detected — running frontend tests..." >&2

    if ! (cd "$FRONTEND_DIR" && flutter test --exclude-tags e2e 2>&1); then
        echo "FRONTEND TESTS FAILED" >&2
        FAILED=1
    fi
fi

if [ $FAILED -ne 0 ]; then
    echo "Tests failed — please fix before continuing." >&2
    exit 2
fi

exit 0
