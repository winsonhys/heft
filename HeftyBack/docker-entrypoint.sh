#!/bin/bash
set -e

echo "Running database migrations..."
goose -dir ./migrations postgres "$DATABASE_URL" up

echo "Starting server..."
exec ./server
