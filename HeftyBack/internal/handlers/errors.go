package handlers

import (
	"errors"
	"strings"

	"connectrpc.com/connect"
	"github.com/jackc/pgx/v5/pgconn"
)

// isUserFKViolation checks if the error is a foreign key violation on user_id
func isUserFKViolation(err error) bool {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		// PostgreSQL error code 23503 is foreign_key_violation
		if pgErr.Code == "23503" && strings.Contains(pgErr.ConstraintName, "user_id") {
			return true
		}
	}
	return false
}

// handleDBError converts database errors to appropriate Connect errors
// Returns 403 PermissionDenied for user-related FK violations (user doesn't exist)
// Returns 500 Internal for other errors
func handleDBError(err error) error {
	if isUserFKViolation(err) {
		return connect.NewError(connect.CodePermissionDenied, errors.New("user not found"))
	}
	return connect.NewError(connect.CodeInternal, err)
}
