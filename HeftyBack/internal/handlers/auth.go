package handlers

import (
	"context"
	"errors"
	"regexp"
	"strings"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/repository"
)

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

// AuthHandler implements the AuthService
type AuthHandler struct {
	repo       repository.AuthRepositoryInterface
	jwtManager *auth.JWTManager
}

// NewAuthHandler creates a new AuthHandler
func NewAuthHandler(repo repository.AuthRepositoryInterface, jwtManager *auth.JWTManager) *AuthHandler {
	return &AuthHandler{
		repo:       repo,
		jwtManager: jwtManager,
	}
}

// Login authenticates a user by email, creating a new account if needed
func (h *AuthHandler) Login(ctx context.Context, req *connect.Request[heftv1.LoginRequest]) (*connect.Response[heftv1.LoginResponse], error) {
	email := strings.TrimSpace(req.Msg.Email)

	// Validate email format
	if email == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("email is required"))
	}
	if !emailRegex.MatchString(email) {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("invalid email format"))
	}

	// Check if user exists
	user, err := h.repo.GetByEmail(ctx, email)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	isNewUser := false
	if user == nil {
		// Create new user
		user, err = h.repo.Create(ctx, email)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		isNewUser = true
	}

	// Generate JWT token
	token, expiresAt, err := h.jwtManager.GenerateToken(user.ID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.LoginResponse{
		Token:     token,
		UserId:    user.ID,
		IsNewUser: isNewUser,
		ExpiresAt: expiresAt,
	}), nil
}
