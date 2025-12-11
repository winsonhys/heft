package middleware

import (
	"context"
	"log"
	"time"

	"connectrpc.com/connect"
)

// NewLoggingInterceptor creates a logging interceptor
func NewLoggingInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			start := time.Now()
			procedure := req.Spec().Procedure

			resp, err := next(ctx, req)

			duration := time.Since(start)
			if err != nil {
				log.Printf("[%s] %s - ERROR: %v (%v)", req.HTTPMethod(), procedure, err, duration)
			} else {
				log.Printf("[%s] %s - OK (%v)", req.HTTPMethod(), procedure, duration)
			}

			return resp, err
		}
	}
}
