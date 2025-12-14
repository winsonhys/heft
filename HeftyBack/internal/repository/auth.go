package repository

import (
	"context"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// AuthRepository handles auth-related data access
type AuthRepository struct {
	pool *pgxpool.Pool
}

// NewAuthRepository creates a new AuthRepository
func NewAuthRepository(pool *pgxpool.Pool) *AuthRepository {
	return &AuthRepository{pool: pool}
}

// GetByEmail retrieves a user by email (case-insensitive)
func (r *AuthRepository) GetByEmail(ctx context.Context, email string) (*User, error) {
	query := `
		SELECT id, email, password_hash, display_name, avatar_url,
		       use_pounds, rest_timer_seconds, member_since, created_at, updated_at
		FROM users
		WHERE LOWER(email) = LOWER($1)
	`

	var user User
	err := r.pool.QueryRow(ctx, query, strings.TrimSpace(email)).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.DisplayName, &user.AvatarURL,
		&user.UsePounds, &user.RestTimerSeconds, &user.MemberSince, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &user, nil
}

// Create creates a new user with the given email
func (r *AuthRepository) Create(ctx context.Context, email string) (*User, error) {
	query := `
		INSERT INTO users (email, password_hash)
		VALUES ($1, '')
		RETURNING id, email, password_hash, display_name, avatar_url,
		          use_pounds, rest_timer_seconds, member_since, created_at, updated_at
	`

	var user User
	err := r.pool.QueryRow(ctx, query, strings.TrimSpace(email)).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.DisplayName, &user.AvatarURL,
		&user.UsePounds, &user.RestTimerSeconds, &user.MemberSince, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &user, nil
}
