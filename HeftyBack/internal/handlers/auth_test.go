package handlers_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/repository"
	"github.com/heftyback/internal/testutil"
)

func TestAuthHandler_Login_NewUser(t *testing.T) {
	mockRepo := &testutil.MockAuthRepository{
		GetByEmailFunc: func(ctx context.Context, email string) (*repository.User, error) {
			return nil, nil // User not found
		},
		CreateFunc: func(ctx context.Context, email string) (*repository.User, error) {
			return &repository.User{
				ID:        "new-user-id",
				Email:     email,
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			}, nil
		},
	}

	jwtManager := auth.NewJWTManager("test-secret", 24)
	handler := handlers.NewAuthHandler(mockRepo, jwtManager)

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.LoginRequest{
		Email: "newuser@example.com",
	})

	resp, err := handler.Login(ctx, req)

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if resp.Msg.Token == "" {
		t.Error("expected non-empty token")
	}

	if resp.Msg.UserId != "new-user-id" {
		t.Errorf("expected user ID 'new-user-id', got %s", resp.Msg.UserId)
	}

	if !resp.Msg.IsNewUser {
		t.Error("expected IsNewUser to be true")
	}

	if resp.Msg.ExpiresAt <= 0 {
		t.Error("expected positive ExpiresAt")
	}
}

func TestAuthHandler_Login_ExistingUser(t *testing.T) {
	existingUser := &repository.User{
		ID:        "existing-user-id",
		Email:     "existing@example.com",
		CreatedAt: time.Now().Add(-24 * time.Hour),
		UpdatedAt: time.Now().Add(-24 * time.Hour),
	}

	mockRepo := &testutil.MockAuthRepository{
		GetByEmailFunc: func(ctx context.Context, email string) (*repository.User, error) {
			return existingUser, nil
		},
		// CreateFunc should not be called
		CreateFunc: func(ctx context.Context, email string) (*repository.User, error) {
			t.Error("CreateFunc should not be called for existing user")
			return nil, nil
		},
	}

	jwtManager := auth.NewJWTManager("test-secret", 24)
	handler := handlers.NewAuthHandler(mockRepo, jwtManager)

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.LoginRequest{
		Email: "existing@example.com",
	})

	resp, err := handler.Login(ctx, req)

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if resp.Msg.Token == "" {
		t.Error("expected non-empty token")
	}

	if resp.Msg.UserId != "existing-user-id" {
		t.Errorf("expected user ID 'existing-user-id', got %s", resp.Msg.UserId)
	}

	if resp.Msg.IsNewUser {
		t.Error("expected IsNewUser to be false")
	}
}

func TestAuthHandler_Login_InvalidEmail(t *testing.T) {
	mockRepo := &testutil.MockAuthRepository{}
	jwtManager := auth.NewJWTManager("test-secret", 24)
	handler := handlers.NewAuthHandler(mockRepo, jwtManager)

	tests := []struct {
		name  string
		email string
	}{
		{"no domain", "user@"},
		{"no at symbol", "useremail.com"},
		{"no tld", "user@example"},
		{"spaces only", "   "},
		{"special chars", "user@@example.com"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ctx := context.Background()
			req := connect.NewRequest(&heftv1.LoginRequest{
				Email: tt.email,
			})

			_, err := handler.Login(ctx, req)

			if err == nil {
				t.Errorf("expected error for invalid email %q", tt.email)
				return
			}

			var connectErr *connect.Error
			if !errors.As(err, &connectErr) {
				t.Fatalf("expected connect error, got %T", err)
			}

			if connectErr.Code() != connect.CodeInvalidArgument {
				t.Errorf("expected CodeInvalidArgument, got %v", connectErr.Code())
			}
		})
	}
}

func TestAuthHandler_Login_EmptyEmail(t *testing.T) {
	mockRepo := &testutil.MockAuthRepository{}
	jwtManager := auth.NewJWTManager("test-secret", 24)
	handler := handlers.NewAuthHandler(mockRepo, jwtManager)

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.LoginRequest{
		Email: "",
	})

	_, err := handler.Login(ctx, req)

	if err == nil {
		t.Error("expected error for empty email")
		return
	}

	var connectErr *connect.Error
	if !errors.As(err, &connectErr) {
		t.Fatalf("expected connect error, got %T", err)
	}

	if connectErr.Code() != connect.CodeInvalidArgument {
		t.Errorf("expected CodeInvalidArgument, got %v", connectErr.Code())
	}
}

func TestAuthHandler_Login_DatabaseError_GetByEmail(t *testing.T) {
	mockRepo := &testutil.MockAuthRepository{
		GetByEmailFunc: func(ctx context.Context, email string) (*repository.User, error) {
			return nil, errors.New("database connection failed")
		},
	}

	jwtManager := auth.NewJWTManager("test-secret", 24)
	handler := handlers.NewAuthHandler(mockRepo, jwtManager)

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.LoginRequest{
		Email: "test@example.com",
	})

	_, err := handler.Login(ctx, req)

	if err == nil {
		t.Error("expected error for database failure")
		return
	}

	var connectErr *connect.Error
	if !errors.As(err, &connectErr) {
		t.Fatalf("expected connect error, got %T", err)
	}

	if connectErr.Code() != connect.CodeInternal {
		t.Errorf("expected CodeInternal, got %v", connectErr.Code())
	}
}

func TestAuthHandler_Login_DatabaseError_Create(t *testing.T) {
	mockRepo := &testutil.MockAuthRepository{
		GetByEmailFunc: func(ctx context.Context, email string) (*repository.User, error) {
			return nil, nil // User not found
		},
		CreateFunc: func(ctx context.Context, email string) (*repository.User, error) {
			return nil, errors.New("failed to create user")
		},
	}

	jwtManager := auth.NewJWTManager("test-secret", 24)
	handler := handlers.NewAuthHandler(mockRepo, jwtManager)

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.LoginRequest{
		Email: "test@example.com",
	})

	_, err := handler.Login(ctx, req)

	if err == nil {
		t.Error("expected error for create failure")
		return
	}

	var connectErr *connect.Error
	if !errors.As(err, &connectErr) {
		t.Fatalf("expected connect error, got %T", err)
	}

	if connectErr.Code() != connect.CodeInternal {
		t.Errorf("expected CodeInternal, got %v", connectErr.Code())
	}
}

func TestAuthHandler_Login_EmailTrimmed(t *testing.T) {
	var capturedEmail string
	mockRepo := &testutil.MockAuthRepository{
		GetByEmailFunc: func(ctx context.Context, email string) (*repository.User, error) {
			capturedEmail = email
			return &repository.User{
				ID:        "user-id",
				Email:     email,
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			}, nil
		},
	}

	jwtManager := auth.NewJWTManager("test-secret", 24)
	handler := handlers.NewAuthHandler(mockRepo, jwtManager)

	ctx := context.Background()
	req := connect.NewRequest(&heftv1.LoginRequest{
		Email: "  test@example.com  ", // Email with leading/trailing spaces
	})

	_, err := handler.Login(ctx, req)

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if capturedEmail != "test@example.com" {
		t.Errorf("expected email to be trimmed, got %q", capturedEmail)
	}
}
