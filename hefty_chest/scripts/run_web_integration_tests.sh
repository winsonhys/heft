#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cleanup() {
    echo ""
    echo -e "${YELLOW}Stopping test environment...${NC}"
    docker compose -f "$PROJECT_DIR/docker-compose.test.yml" down -v 2>/dev/null || true
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

echo ""
echo -e "${GREEN}==================================="
echo "  Web Integration Test Runner"
echo "===================================${NC}"
echo ""

# Check for running containers on our ports
if lsof -i :8080 > /dev/null 2>&1 || lsof -i :5433 > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Test ports in use. Stopping existing containers...${NC}"
    docker compose -f "$PROJECT_DIR/docker-compose.test.yml" down -v 2>/dev/null || true
    sleep 2
fi

echo -e "${GREEN}Starting Docker containers and waiting for health...${NC}"
docker compose -f "$PROJECT_DIR/docker-compose.test.yml" up -d --build --wait

# Verify test mode is enabled
echo -n "  Test Mode:  "
if curl -s -X POST http://localhost:8080/test/reset | grep -q "reset_complete"; then
    echo -e "${GREEN}enabled${NC}"
else
    echo -e "${RED}disabled${NC}"
    echo "ERROR: TEST_MODE not enabled on backend!"
    exit 1
fi

echo ""
echo -e "${GREEN}==================================="
echo "  Running Web Integration Tests"
echo "===================================${NC}"
echo ""

cd "$PROJECT_DIR"

# Parse optional test file argument
TEST_TARGET="${1:-integration_test/}"

# Run Flutter web integration tests in Chrome
# --concurrency=1 ensures tests run sequentially to avoid race conditions
flutter test "$TEST_TARGET" -d chrome --concurrency=1
TEST_EXIT_CODE=$?

echo ""
echo -e "${GREEN}==================================="
echo "  Test Results"
echo "===================================${NC}"
echo ""

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Some tests failed. Exit code: $TEST_EXIT_CODE${NC}"
fi

exit $TEST_EXIT_CODE
