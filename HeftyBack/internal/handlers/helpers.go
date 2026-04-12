package handlers

import (
	"context"
	"errors"
	"fmt"
	"time"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/auth"
)

// getAuthenticatedUserID extracts the user ID from the context.
// Returns an Unauthenticated error if not authenticated.
func getAuthenticatedUserID(ctx context.Context) (string, error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return "", connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	return userID, nil
}

// requireString validates that a string field is not empty.
// Returns an InvalidArgument error if empty.
func requireString(value string, fieldName string) error {
	if value == "" {
		return connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("%s is required", fieldName))
	}
	return nil
}

// extractPagination parses pagination request parameters with defaults.
// Returns page (1-indexed), pageSize, and offset.
func extractPagination(p *heftv1.PaginationRequest, defaultPageSize int32) (page, pageSize, offset int32) {
	page = 1
	pageSize = defaultPageSize
	if p != nil {
		if p.Page > 0 {
			page = p.Page
		}
		if p.PageSize > 0 {
			pageSize = p.PageSize
		}
	}
	offset = (page - 1) * pageSize
	return
}

// buildPaginationResponse creates a pagination response from the given parameters.
func buildPaginationResponse(page, pageSize int32, totalCount int) *heftv1.PaginationResponse {
	totalPages := (int32(totalCount) + pageSize - 1) / pageSize
	return &heftv1.PaginationResponse{
		Page:       page,
		PageSize:   pageSize,
		TotalCount: int32(totalCount),
		TotalPages: totalPages,
	}
}

// parseOptionalDate parses an optional date string in "2006-01-02" format.
// Returns nil if the pointer is nil, empty, or unparseable.
func parseOptionalDate(value *string) *time.Time {
	if value == nil || *value == "" {
		return nil
	}
	t, err := time.Parse("2006-01-02", *value)
	if err != nil {
		return nil
	}
	return &t
}

// mapSlice transforms a slice of T into a slice of U using the given function.
func mapSlice[T any, U any](items []T, fn func(T) U) []U {
	result := make([]U, len(items))
	for i, item := range items {
		result[i] = fn(item)
	}
	return result
}
