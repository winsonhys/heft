FROM golang:1.24-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy go mod files first for better caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the server
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server

# Build goose for migrations
RUN go install github.com/pressly/goose/v3/cmd/goose@latest

# Runtime image
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache ca-certificates wget bash

WORKDIR /app

# Copy binary, migrations and goose
COPY --from=builder /app/server .
COPY --from=builder /app/migrations ./migrations
COPY --from=builder /go/bin/goose /usr/local/bin/goose

# Copy startup script
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Expose port
EXPOSE 8080

# Run the entrypoint script
ENTRYPOINT ["/app/docker-entrypoint.sh"]
