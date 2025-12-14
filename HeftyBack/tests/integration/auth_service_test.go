package integration_test

import (
	"context"
	"fmt"
	"testing"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/testutil"
)

func TestAuthService_Integration_Login_CreatesNewUser(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	ctx := context.Background()
	// Use unique email to avoid conflicts with other tests
	email := fmt.Sprintf("newuser-%s@example.com", uuid.New().String()[:8])

	// Login with a new email - should create user
	resp, err := ts.AuthClient.Login(ctx, connect.NewRequest(&heftv1.LoginRequest{
		Email: email,
	}))

	require.NoError(t, err)
	assert.NotEmpty(t, resp.Msg.Token)
	assert.NotEmpty(t, resp.Msg.UserId)
	assert.True(t, resp.Msg.IsNewUser)
	assert.Greater(t, resp.Msg.ExpiresAt, int64(0))

	// Verify user was created in database
	var count int
	err = pool.QueryRow(ctx, "SELECT COUNT(*) FROM users WHERE email = $1", email).Scan(&count)
	require.NoError(t, err)
	assert.Equal(t, 1, count)
}

func TestAuthService_Integration_Login_ReturnsExistingUser(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	ctx := context.Background()

	// Create existing user
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	// Login with existing email
	resp, err := ts.AuthClient.Login(ctx, connect.NewRequest(&heftv1.LoginRequest{
		Email: testUser.Email,
	}))

	require.NoError(t, err)
	assert.NotEmpty(t, resp.Msg.Token)
	assert.Equal(t, userID, resp.Msg.UserId)
	assert.False(t, resp.Msg.IsNewUser)
}

func TestAuthService_Integration_TokenAuthenticatesRequests(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	ctx := context.Background()

	// Create existing user
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	// Login to get token
	loginResp, err := ts.AuthClient.Login(ctx, connect.NewRequest(&heftv1.LoginRequest{
		Email: testUser.Email,
	}))
	require.NoError(t, err)

	// Use token to call authenticated endpoint
	req := connect.NewRequest(&heftv1.GetProfileRequest{})
	req.Header().Set("Authorization", "Bearer "+loginResp.Msg.Token)

	profileResp, err := ts.UserClient.GetProfile(ctx, req)

	require.NoError(t, err)
	assert.Equal(t, userID, profileResp.Msg.User.Id)
	assert.Equal(t, testUser.Email, profileResp.Msg.User.Email)
}

func TestAuthService_Integration_InvalidTokenRejected(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	ctx := context.Background()

	tests := []struct {
		name       string
		authHeader string
	}{
		{"no auth header", ""},
		{"invalid token", "Bearer invalid-token"},
		{"malformed header", "Token abc123"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := connect.NewRequest(&heftv1.GetProfileRequest{})
			if tt.authHeader != "" {
				req.Header().Set("Authorization", tt.authHeader)
			}

			_, err := ts.UserClient.GetProfile(ctx, req)

			require.Error(t, err)
			assert.Equal(t, connect.CodeUnauthenticated, connect.CodeOf(err))
		})
	}
}

func TestAuthService_Integration_LoginCaseInsensitive(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	ctx := context.Background()

	// Create user with lowercase email (unique email for this test)
	uniqueID := uuid.New().String()[:8]
	testUser := testutil.DefaultTestUser()
	testUser.Email = fmt.Sprintf("casetest-%s@example.com", uniqueID)
	userID := testutil.SeedTestUser(t, pool, testUser)

	// Login with uppercase email - should find the same user
	resp, err := ts.AuthClient.Login(ctx, connect.NewRequest(&heftv1.LoginRequest{
		Email: fmt.Sprintf("CASETEST-%s@EXAMPLE.COM", uniqueID),
	}))

	require.NoError(t, err)
	assert.Equal(t, userID, resp.Msg.UserId)
	assert.False(t, resp.Msg.IsNewUser)
}

func TestAuthService_Integration_InvalidEmail(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	ctx := context.Background()

	tests := []struct {
		name  string
		email string
	}{
		{"empty email", ""},
		{"invalid format", "not-an-email"},
		{"no domain", "user@"},
		{"only spaces", "   "},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := ts.AuthClient.Login(ctx, connect.NewRequest(&heftv1.LoginRequest{
				Email: tt.email,
			}))

			require.Error(t, err)
			assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		})
	}
}
