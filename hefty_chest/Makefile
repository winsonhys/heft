.PHONY: help test test-unit test-integration test-e2e test-all test-env-up test-env-down deps generate build clean

# Default target
help:
	@echo "Hefty Chest - Flutter Frontend"
	@echo ""
	@echo "Available targets:"
	@echo "  deps              - Install Flutter dependencies"
	@echo "  generate          - Generate code (router, proto)"
	@echo "  build             - Build the app"
	@echo "  clean             - Clean build artifacts"
	@echo ""
	@echo "Testing:"
	@echo "  test              - Run all tests (unit + integration)"
	@echo "  test-unit         - Run unit tests only (fast, no backend)"
	@echo "  test-integration  - Run integration tests (with Docker)"
	@echo "  test-e2e          - Run E2E widget tests (with Docker)"
	@echo "  test-providers    - Run provider integration tests only"
	@echo ""
	@echo "Test Environment:"
	@echo "  test-env-up       - Start test environment (Docker)"
	@echo "  test-env-down     - Stop test environment"
	@echo "  test-quick        - Run tests against already-running environment"

# Dependencies
deps:
	flutter pub get

# Code generation
generate:
	buf generate
	flutter pub run build_runner build --delete-conflicting-outputs

# Build
build:
	flutter build apk

# Clean
clean:
	flutter clean
	rm -rf build/

# ============================================================
# Testing
# ============================================================

# Run unit tests only (fast, no backend required)
test-unit:
	flutter test test/widget_test.dart

# Run all integration tests with Docker automation
test-integration:
	./scripts/run_integration_tests.sh

# Run provider integration tests only (with Docker)
test-providers: test-env-up
	@echo "Running provider integration tests..."
	flutter test test/integration/providers/ --reporter expanded || (make test-env-down && exit 1)
	@echo "Tests complete."

# Run E2E widget tests only (with Docker)
test-e2e: test-env-up
	@echo "Running E2E integration tests..."
	flutter test test/integration/e2e/ --reporter expanded || (make test-env-down && exit 1)
	@echo "Tests complete."

# Run all tests
test: test-unit test-integration

# Alias for all tests
test-all: test

# ============================================================
# Test Environment Management
# ============================================================

# Start test environment manually (for debugging)
test-env-up:
	@echo "Starting test environment..."
	docker compose -f docker-compose.test.yml up -d --build
	@echo "Waiting for services..."
	@for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do \
		if curl -s http://localhost:8080/health > /dev/null 2>&1; then \
			echo "Backend is ready!"; \
			break; \
		fi; \
		echo "  Waiting for backend... ($$i/30)"; \
		sleep 2; \
	done
	@echo "Test environment is up."

# Stop test environment
test-env-down:
	@echo "Stopping test environment..."
	docker compose -f docker-compose.test.yml down -v
	@echo "Test environment stopped."

# Run tests against already-running environment (faster iteration)
test-quick:
	@echo "Running integration tests (assumes environment is running)..."
	flutter test test/integration/ --reporter expanded

# Run specific test file against running environment
test-file:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make test-file FILE=test/integration/providers/user_provider_test.dart"; \
		exit 1; \
	fi
	flutter test $(FILE) --reporter expanded

# ============================================================
# Development
# ============================================================

# Run the app
run:
	flutter run

# Run on web
run-web:
	flutter run -d chrome

# Run on macOS
run-macos:
	flutter run -d macos

# Analyze code
analyze:
	flutter analyze

# Format code
format:
	dart format lib/ test/
