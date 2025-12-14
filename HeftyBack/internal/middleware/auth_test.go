package middleware_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/gen/heft/v1/heftv1connect"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/middleware"
	"github.com/heftyback/internal/repository"
	"github.com/heftyback/internal/testutil"
)

// createTestAuthServer creates a test server with the auth interceptor enabled
func createTestAuthServer(t *testing.T) (*httptest.Server, *auth.JWTManager) {
	t.Helper()

	jwtManager := auth.NewJWTManager("test-secret-for-middleware-tests", 24)

	// Use a mock user repo that returns a fixed user
	mockUserRepo := &testutil.MockUserRepository{
		GetByIDFunc: func(ctx context.Context, id string) (*repository.User, error) {
			return &repository.User{
				ID:    id,
				Email: "test@example.com",
			}, nil
		},
	}

	userHandler := handlers.NewUserHandler(mockUserRepo)

	// Create auth interceptor
	authInterceptor := middleware.NewAuthInterceptor(jwtManager)
	interceptors := connect.WithInterceptors(authInterceptor)

	// Create HTTP mux
	mux := http.NewServeMux()
	userPath, userHTTPHandler := heftv1connect.NewUserServiceHandler(userHandler, interceptors)
	mux.Handle(userPath, userHTTPHandler)

	server := httptest.NewServer(mux)
	t.Cleanup(func() {
		server.Close()
	})

	return server, jwtManager
}

func TestAuthInterceptor_MissingAuthHeader(t *testing.T) {
	server, _ := createTestAuthServer(t)
	client := heftv1connect.NewUserServiceClient(server.Client(), server.URL)

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.GetProfileRequest{})

	// No auth header set
	_, err := client.GetProfile(ctx, req)

	if err == nil {
		t.Fatal("expected error for missing auth header")
	}

	if connect.CodeOf(err) != connect.CodeUnauthenticated {
		t.Errorf("expected CodeUnauthenticated, got %v", connect.CodeOf(err))
	}
}

func TestAuthInterceptor_InvalidBearerFormat(t *testing.T) {
	server, _ := createTestAuthServer(t)
	client := heftv1connect.NewUserServiceClient(server.Client(), server.URL)

	tests := []struct {
		name       string
		authHeader string
	}{
		{"no Bearer prefix", "some-token"},
		{"wrong prefix", "Token abc123"},
		{"Basic auth", "Basic dXNlcjpwYXNz"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ctx := context.Background()
			req := connect.NewRequest(&heftv1.GetProfileRequest{})
			req.Header().Set("Authorization", tt.authHeader)

			_, err := client.GetProfile(ctx, req)

			if err == nil {
				t.Errorf("expected error for %s", tt.name)
				return
			}

			if connect.CodeOf(err) != connect.CodeUnauthenticated {
				t.Errorf("expected CodeUnauthenticated, got %v", connect.CodeOf(err))
			}
		})
	}
}

func TestAuthInterceptor_InvalidToken(t *testing.T) {
	server, _ := createTestAuthServer(t)
	client := heftv1connect.NewUserServiceClient(server.Client(), server.URL)

	tests := []struct {
		name  string
		token string
	}{
		{"garbage token", "not-a-jwt"},
		{"malformed JWT", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"},
		{"wrong signature", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTIzIn0.wrongsignature"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ctx := context.Background()
			req := connect.NewRequest(&heftv1.GetProfileRequest{})
			req.Header().Set("Authorization", "Bearer "+tt.token)

			_, err := client.GetProfile(ctx, req)

			if err == nil {
				t.Errorf("expected error for %s", tt.name)
				return
			}

			if connect.CodeOf(err) != connect.CodeUnauthenticated {
				t.Errorf("expected CodeUnauthenticated, got %v", connect.CodeOf(err))
			}
		})
	}
}

func TestAuthInterceptor_ValidToken(t *testing.T) {
	server, jwtManager := createTestAuthServer(t)
	client := heftv1connect.NewUserServiceClient(server.Client(), server.URL)

	userID := "user-123"
	token, _, _ := jwtManager.GenerateToken(userID)

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.GetProfileRequest{})
	req.Header().Set("Authorization", "Bearer "+token)

	resp, err := client.GetProfile(ctx, req)

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if resp.Msg.User.Id != userID {
		t.Errorf("expected user ID %s, got %s", userID, resp.Msg.User.Id)
	}
}

func TestAuthInterceptor_CaseInsensitiveBearer(t *testing.T) {
	server, jwtManager := createTestAuthServer(t)
	client := heftv1connect.NewUserServiceClient(server.Client(), server.URL)

	userID := "user-123"
	token, _, _ := jwtManager.GenerateToken(userID)

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.GetProfileRequest{})
	// Use lowercase "bearer"
	req.Header().Set("Authorization", "bearer "+token)

	resp, err := client.GetProfile(ctx, req)

	if err != nil {
		t.Fatalf("unexpected error with lowercase bearer: %v", err)
	}

	if resp.Msg.User.Id != userID {
		t.Errorf("expected user ID %s, got %s", userID, resp.Msg.User.Id)
	}
}

func TestAuthInterceptor_TokenExtractsCorrectUserID(t *testing.T) {
	server, jwtManager := createTestAuthServer(t)
	client := heftv1connect.NewUserServiceClient(server.Client(), server.URL)

	// Test with multiple different user IDs
	userIDs := []string{"user-1", "user-2", "uuid-like-12345678"}

	for _, userID := range userIDs {
		t.Run(userID, func(t *testing.T) {
			token, _, _ := jwtManager.GenerateToken(userID)

			ctx := context.Background()
			req := connect.NewRequest(&heftv1.GetProfileRequest{})
			req.Header().Set("Authorization", "Bearer "+token)

			resp, err := client.GetProfile(ctx, req)

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if resp.Msg.User.Id != userID {
				t.Errorf("expected user ID %s, got %s", userID, resp.Msg.User.Id)
			}
		})
	}
}

func TestAuthInterceptor_WrongSecret(t *testing.T) {
	server, _ := createTestAuthServer(t)
	client := heftv1connect.NewUserServiceClient(server.Client(), server.URL)

	// Create token with a different secret
	differentJWTManager := auth.NewJWTManager("different-secret-key", 24)
	token, _, _ := differentJWTManager.GenerateToken("user-123")

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.GetProfileRequest{})
	req.Header().Set("Authorization", "Bearer "+token)

	_, err := client.GetProfile(ctx, req)

	if err == nil {
		t.Fatal("expected error for token signed with wrong secret")
	}

	if connect.CodeOf(err) != connect.CodeUnauthenticated {
		t.Errorf("expected CodeUnauthenticated, got %v", connect.CodeOf(err))
	}
}
