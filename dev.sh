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
FLUTTER_DEVICE=""
CLEAN=false

usage() {
    echo "Usage: ./dev.sh [OPTIONS]"
    echo ""
    echo "Start Heft development environment (backend + frontend)."
    echo ""
    echo "Options:"
    echo "  -w, --web      Run Flutter on Chrome instead of mobile device"
    echo "  --clean         Wipe DB volumes before starting"
    echo "  -h, --help      Show this help message"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--web)    FLUTTER_DEVICE="-d chrome"; shift ;;
        --clean)     CLEAN=true; shift ;;
        -h|--help)   usage; exit 0 ;;
        *)           echo -e "${RED}Unknown option: $1${NC}"; usage; exit 1 ;;
    esac
done

cleanup() {
    echo ""
    echo -e "${YELLOW}Shutting down backend...${NC}"
    docker compose -f "$COMPOSE_FILE" down 2>/dev/null || true
    if $CLEAN; then
        echo -e "${YELLOW}Removing DB volumes...${NC}"
        docker compose -f "$COMPOSE_FILE" down -v 2>/dev/null || true
    fi
    echo -e "${GREEN}Cleanup complete.${NC}"
}

trap cleanup EXIT INT TERM

echo ""
echo -e "${BLUE}==================================="
echo "  Heft Dev Environment"
echo "===================================${NC}"
echo ""

# Port conflict warnings
if lsof -i :8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Port 8080 already in use${NC}"
fi
if lsof -i :5433 > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Port 5433 already in use${NC}"
fi

# Start backend
echo -e "${GREEN}Starting backend (docker compose up --build)...${NC}"
if $CLEAN; then
    docker compose -f "$COMPOSE_FILE" down -v 2>/dev/null || true
fi
docker compose -f "$COMPOSE_FILE" up -d --build

# Poll health endpoint
echo -n "Waiting for backend health check... "
for i in $(seq 1 60); do
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo -e "${GREEN}ready${NC}"
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo -e "${RED}failed${NC}"
        echo ""
        echo "Backend did not become healthy within 60s. Logs:"
        docker compose -f "$COMPOSE_FILE" logs --tail=30 server
        exit 1
    fi
    sleep 1
done

# Launch Flutter in foreground
echo ""
echo -e "${GREEN}Launching Flutter...${NC}"
if [ -n "$FLUTTER_DEVICE" ]; then
    echo -e "${BLUE}  Device: Chrome (web)${NC}"
else
    echo -e "${BLUE}  Device: default (mobile)${NC}"
fi
echo ""

cd "$FRONTEND_DIR"
# shellcheck disable=SC2086
flutter run $FLUTTER_DEVICE
