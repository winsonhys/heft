.PHONY: generate build run clean migrate-up migrate-down migrate-status test test-unit test-integration test-coverage

# Generate protobuf code
generate:
	buf generate

# Build the server
build:
	go build -o bin/server ./cmd/server

# Run the server
run:
	go run ./cmd/server

# Clean build artifacts
clean:
	rm -rf bin/
	rm -rf gen/

# Database migrations
migrate-up:
	goose -dir migrations postgres "$(DATABASE_URL)" up

migrate-down:
	goose -dir migrations postgres "$(DATABASE_URL)" down

migrate-status:
	goose -dir migrations postgres "$(DATABASE_URL)" status

migrate-create:
	@read -p "Migration name: " name; \
	goose -dir migrations create $$name sql

# Development helpers
deps:
	go mod tidy
	go mod download

lint:
	buf lint

# All-in-one setup
setup: deps generate build

# ============================================================================
# TESTING
# ============================================================================

# Run all tests
test:
	go test -v ./...

# Run only unit tests (fast, no database required)
test-unit:
	go test -v -short ./internal/handlers/...

# Run only integration tests (requires PostgreSQL)
test-integration:
	go test -v -run Integration ./tests/integration/...

# Run tests with coverage report
test-coverage:
	mkdir -p coverage
	go test -v -coverprofile=coverage/coverage.out ./...
	go tool cover -html=coverage/coverage.out -o coverage/coverage.html
	@echo "Coverage report: coverage/coverage.html"

# Run tests with race detection
test-race:
	go test -v -race ./...
