package auth

import "context"

type contextKey string

const userIDKey contextKey = "user_id"

// ContextWithUserID adds the user ID to the context
func ContextWithUserID(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, userIDKey, userID)
}

// UserIDFromContext retrieves the user ID from the context
func UserIDFromContext(ctx context.Context) (string, bool) {
	userID, ok := ctx.Value(userIDKey).(string)
	return userID, ok
}
