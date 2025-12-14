package middleware

import (
	"context"
	"strings"

	"connectrpc.com/connect"

	"github.com/heftyback/internal/auth"
)

// Procedures that don't require authentication
var publicProcedures = map[string]bool{
	"/heft.v1.AuthService/Login": true,
}

// NewAuthInterceptor creates an authentication interceptor
func NewAuthInterceptor(jwtManager *auth.JWTManager) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			procedure := req.Spec().Procedure

			// Skip auth for public procedures
			if publicProcedures[procedure] {
				return next(ctx, req)
			}

			// Get authorization header
			authHeader := req.Header().Get("Authorization")
			if authHeader == "" {
				return nil, connect.NewError(connect.CodeUnauthenticated, auth.ErrInvalidToken)
			}

			// Extract Bearer token
			parts := strings.SplitN(authHeader, " ", 2)
			if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
				return nil, connect.NewError(connect.CodeUnauthenticated, auth.ErrInvalidToken)
			}

			token := parts[1]

			// Validate token
			claims, err := jwtManager.ValidateToken(token)
			if err != nil {
				if err == auth.ErrExpiredToken {
					return nil, connect.NewError(connect.CodeUnauthenticated, err)
				}
				return nil, connect.NewError(connect.CodeUnauthenticated, auth.ErrInvalidToken)
			}

			// Add user ID to context
			ctx = auth.ContextWithUserID(ctx, claims.UserID)

			return next(ctx, req)
		}
	}
}
