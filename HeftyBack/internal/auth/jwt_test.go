package auth

import (
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func TestJWTManager_GenerateToken_Success(t *testing.T) {
	manager := NewJWTManager("test-secret-key", 24)
	userID := "user-123"

	token, expiresAt, err := manager.GenerateToken(userID)

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if token == "" {
		t.Error("expected non-empty token")
	}

	// Verify expiration is roughly 24 hours from now
	expectedExpiry := time.Now().Add(24 * time.Hour).Unix()
	if expiresAt < expectedExpiry-60 || expiresAt > expectedExpiry+60 {
		t.Errorf("expiration %d not within 60 seconds of expected %d", expiresAt, expectedExpiry)
	}
}

func TestJWTManager_ValidateToken_Success(t *testing.T) {
	manager := NewJWTManager("test-secret-key", 24)
	userID := "user-123"

	token, _, err := manager.GenerateToken(userID)
	if err != nil {
		t.Fatalf("failed to generate token: %v", err)
	}

	claims, err := manager.ValidateToken(token)

	if err != nil {
		t.Fatalf("unexpected error validating token: %v", err)
	}

	if claims.UserID != userID {
		t.Errorf("expected user ID %s, got %s", userID, claims.UserID)
	}

	if claims.Issuer != "heft" {
		t.Errorf("expected issuer 'heft', got %s", claims.Issuer)
	}
}

func TestJWTManager_ValidateToken_Expired(t *testing.T) {
	// Create manager with 0 hour expiration to test expired tokens
	manager := NewJWTManager("test-secret-key", 0)

	// Manually create an expired token
	expiresAt := time.Now().Add(-1 * time.Hour)
	claims := &Claims{
		UserID: "user-123",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(time.Now().Add(-2 * time.Hour)),
			Issuer:    "heft",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, _ := token.SignedString([]byte("test-secret-key"))

	_, err := manager.ValidateToken(tokenString)

	if err != ErrExpiredToken {
		t.Errorf("expected ErrExpiredToken, got %v", err)
	}
}

func TestJWTManager_ValidateToken_InvalidSignature(t *testing.T) {
	// Generate token with one secret
	manager1 := NewJWTManager("secret-key-1", 24)
	token, _, err := manager1.GenerateToken("user-123")
	if err != nil {
		t.Fatalf("failed to generate token: %v", err)
	}

	// Try to validate with different secret
	manager2 := NewJWTManager("secret-key-2", 24)
	_, err = manager2.ValidateToken(token)

	if err != ErrInvalidToken {
		t.Errorf("expected ErrInvalidToken, got %v", err)
	}
}

func TestJWTManager_ValidateToken_Malformed(t *testing.T) {
	manager := NewJWTManager("test-secret-key", 24)

	tests := []struct {
		name  string
		token string
	}{
		{"garbage input", "not-a-jwt-token"},
		{"empty string", ""},
		{"incomplete JWT", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"},
		{"random base64", "dGVzdA.dGVzdA.dGVzdA"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := manager.ValidateToken(tt.token)

			if err != ErrInvalidToken {
				t.Errorf("expected ErrInvalidToken for %s, got %v", tt.name, err)
			}
		})
	}
}

func TestJWTManager_GenerateToken_DifferentUserIDs(t *testing.T) {
	manager := NewJWTManager("test-secret-key", 24)

	userIDs := []string{"user-1", "user-2", "user-3"}
	tokens := make([]string, len(userIDs))

	for i, userID := range userIDs {
		token, _, err := manager.GenerateToken(userID)
		if err != nil {
			t.Fatalf("failed to generate token for %s: %v", userID, err)
		}
		tokens[i] = token
	}

	// All tokens should be different
	for i := 0; i < len(tokens); i++ {
		for j := i + 1; j < len(tokens); j++ {
			if tokens[i] == tokens[j] {
				t.Errorf("tokens for %s and %s should be different", userIDs[i], userIDs[j])
			}
		}
	}

	// Each token should validate to correct user
	for i, token := range tokens {
		claims, err := manager.ValidateToken(token)
		if err != nil {
			t.Fatalf("failed to validate token: %v", err)
		}
		if claims.UserID != userIDs[i] {
			t.Errorf("expected user ID %s, got %s", userIDs[i], claims.UserID)
		}
	}
}
