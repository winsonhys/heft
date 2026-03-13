#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/HeftyBack"
FRONTEND_DIR="$SCRIPT_DIR/hefty_chest"
COMPOSE_FILE="$BACKEND_DIR/docker-compose.yml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
RUN_BACKEND=true
RUN_FRONTEND=true
UNIT_ONLY=false

# Track failures
FAILED=0

usage() {
    echo "Usage: ./test.sh [OPTIONS]"
    echo ""
    echo "Run backend and frontend tests (unit + integration)."
    echo ""
    echo "Options:"
    echo "  --backend-only   Skip frontend tests"
    echo "  --frontend-only  Skip backend tests"
    echo "  --unit           Unit tests only (no Docker/integration)"
    echo "  -h, --help       Show this help message"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --backend-only)   RUN_FRONTEND=false; shift ;;
        --frontend-only)  RUN_BACKEND=false; shift ;;
        --unit)           UNIT_ONLY=true; shift ;;
        -h|--help)        usage; exit 0 ;;
        *)                echo -e "${RED}Unknown option: $1${NC}"; usage; exit 1 ;;
    esac
done

cleanup() {
    echo ""
    echo -e "${YELLOW}Stopping Docker containers...${NC}"
    docker compose -f "$COMPOSE_FILE" down 2>/dev/null || true
    echo -e "${GREEN}Cleanup complete.${NC}"
}

trap cleanup EXIT INT TERM

echo ""
echo -e "${BLUE}==================================="
echo "  Heft Test Suite"
echo "===================================${NC}"
echo ""

if $UNIT_ONLY; then
    echo -e "${BLUE}Mode: unit tests only${NC}"
else
    echo -e "${BLUE}Mode: unit + integration tests${NC}"
fi
echo ""

# ============================================================================
# BACKEND TESTS
# ============================================================================

if $RUN_BACKEND; then
    echo -e "${BLUE}-----------------------------------"
    echo "  Backend Tests"
    echo "-----------------------------------${NC}"
    echo ""

    if $UNIT_ONLY; then
        echo -e "${GREEN}Running backend unit tests...${NC}"
        if (cd "$BACKEND_DIR" && make test-unit); then
            echo -e "${GREEN}Backend unit tests passed.${NC}"
        else
            echo -e "${RED}Backend unit tests FAILED.${NC}"
            FAILED=1
        fi
    else
        # Start Docker for backend integration tests
        echo -e "${GREEN}Starting Docker for backend tests...${NC}"
        docker compose -f "$COMPOSE_FILE" up -d --build

        echo -n "Waiting for backend health check... "
        for i in $(seq 1 60); do
            if curl -s http://localhost:8080/health > /dev/null 2>&1; then
                echo -e "${GREEN}ready${NC}"
                break
            fi
            if [ "$i" -eq 60 ]; then
                echo -e "${RED}failed${NC}"
                docker compose -f "$COMPOSE_FILE" logs --tail=30 server
                FAILED=1
            fi
            sleep 1
        done

        echo -e "${GREEN}Running backend tests (unit + integration)...${NC}"
        if (cd "$BACKEND_DIR" && make test); then
            echo -e "${GREEN}Backend tests passed.${NC}"
        else
            echo -e "${RED}Backend tests FAILED.${NC}"
            FAILED=1
        fi

        # Stop Docker before frontend tests (port conflict)
        echo -e "${YELLOW}Stopping backend Docker containers...${NC}"
        docker compose -f "$COMPOSE_FILE" down 2>/dev/null || true
    fi
    echo ""
fi

# ============================================================================
# FRONTEND TESTS
# ============================================================================

if $RUN_FRONTEND; then
    echo -e "${BLUE}-----------------------------------"
    echo "  Frontend Tests"
    echo "-----------------------------------${NC}"
    echo ""

    # Unit tests (always run)
    echo -e "${GREEN}Running frontend unit tests...${NC}"
    if (cd "$FRONTEND_DIR" && flutter test); then
        echo -e "${GREEN}Frontend unit tests passed.${NC}"
    else
        echo -e "${RED}Frontend unit tests FAILED.${NC}"
        FAILED=1
    fi

    # Integration tests (skip if --unit)
    if ! $UNIT_ONLY; then
        echo ""
        echo -e "${GREEN}Running frontend integration tests...${NC}"
        if (cd "$FRONTEND_DIR" && ./scripts/run_integration_tests.sh); then
            echo -e "${GREEN}Frontend integration tests passed.${NC}"
        else
            echo -e "${RED}Frontend integration tests FAILED.${NC}"
            FAILED=1
        fi
    fi
    echo ""
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo -e "${BLUE}==================================="
echo "  Results"
echo "===================================${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed.${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
