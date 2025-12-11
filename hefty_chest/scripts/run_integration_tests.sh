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
echo "  Integration Test Runner"
echo "===================================${NC}"
echo ""

# Check for running containers on our ports
if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Port 8080 is in use. Stopping existing containers...${NC}"
    docker compose -f "$PROJECT_DIR/docker-compose.test.yml" down -v 2>/dev/null || true
    sleep 2
fi

if lsof -i :5433 > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Port 5433 is in use. Stopping existing containers...${NC}"
    docker compose -f "$PROJECT_DIR/docker-compose.test.yml" down -v 2>/dev/null || true
    sleep 2
fi

echo -e "${GREEN}Starting Docker containers (ephemeral database)...${NC}"
docker compose -f "$PROJECT_DIR/docker-compose.test.yml" up -d --build

echo ""
echo "Waiting for services to be healthy..."

# Wait for PostgreSQL
echo -n "  PostgreSQL: "
for i in {1..30}; do
    if docker compose -f "$PROJECT_DIR/docker-compose.test.yml" exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}ready${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}failed${NC}"
        echo "ERROR: PostgreSQL failed to start!"
        exit 1
    fi
    sleep 1
done

# Wait for backend health check
echo -n "  Backend:    "
for i in {1..60}; do
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo -e "${GREEN}ready${NC}"
        break
    fi
    if [ $i -eq 60 ]; then
        echo -e "${RED}failed${NC}"
        echo "ERROR: Backend failed to start!"
        echo ""
        echo "Docker logs:"
        docker compose -f "$PROJECT_DIR/docker-compose.test.yml" logs backend
        exit 1
    fi
    sleep 1
done

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
echo "  Running Integration Tests"
echo "===================================${NC}"
echo ""

cd "$PROJECT_DIR"

# Run Flutter integration tests sequentially to avoid race conditions
# The --concurrency=1 flag ensures tests run one at a time
flutter test test/integration/providers/ --concurrency=1 --reporter expanded
TEST_EXIT_CODE=$?

echo ""
echo -e "${GREEN}==================================="
echo "  Test Results"
echo "===================================${NC}"
echo ""

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
else
    echo -e "${RED}✗ Some tests failed. Exit code: $TEST_EXIT_CODE${NC}"
fi

exit $TEST_EXIT_CODE
