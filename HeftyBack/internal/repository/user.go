package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// User represents a user in the database
type User struct {
	ID               string
	Email            string
	PasswordHash     string
	DisplayName      *string
	AvatarURL        *string
	UsePounds        bool
	RestTimerSeconds int
	MemberSince      time.Time
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

// WeightLog represents a weight log entry
type WeightLog struct {
	ID         string
	UserID     string
	WeightKg   float64
	LoggedDate time.Time
	Notes      *string
	CreatedAt  time.Time
}

// UserRepository handles user data access
type UserRepository struct {
	pool *pgxpool.Pool
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(pool *pgxpool.Pool) *UserRepository {
	return &UserRepository{pool: pool}
}

// GetByID retrieves a user by ID
func (r *UserRepository) GetByID(ctx context.Context, id string) (*User, error) {
	query := `
		SELECT id, email, password_hash, display_name, avatar_url,
		       use_pounds, rest_timer_seconds, member_since, created_at, updated_at
		FROM users
		WHERE id = $1
	`

	var user User
	err := r.pool.QueryRow(ctx, query, id).Scan(
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

// UpdateProfile updates user profile fields
func (r *UserRepository) UpdateProfile(ctx context.Context, id string, displayName, avatarURL *string) (*User, error) {
	query := `
		UPDATE users
		SET display_name = COALESCE($2, display_name),
		    avatar_url = COALESCE($3, avatar_url),
		    updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
		RETURNING id, email, password_hash, display_name, avatar_url,
		          use_pounds, rest_timer_seconds, member_since, created_at, updated_at
	`

	var user User
	err := r.pool.QueryRow(ctx, query, id, displayName, avatarURL).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.DisplayName, &user.AvatarURL,
		&user.UsePounds, &user.RestTimerSeconds, &user.MemberSince, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &user, nil
}

// UpdateSettings updates user settings
func (r *UserRepository) UpdateSettings(ctx context.Context, id string, usePounds *bool, restTimerSeconds *int) (*User, error) {
	query := `
		UPDATE users
		SET use_pounds = COALESCE($2, use_pounds),
		    rest_timer_seconds = COALESCE($3, rest_timer_seconds),
		    updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
		RETURNING id, email, password_hash, display_name, avatar_url,
		          use_pounds, rest_timer_seconds, member_since, created_at, updated_at
	`

	var user User
	err := r.pool.QueryRow(ctx, query, id, usePounds, restTimerSeconds).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.DisplayName, &user.AvatarURL,
		&user.UsePounds, &user.RestTimerSeconds, &user.MemberSince, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &user, nil
}

// LogWeight creates a weight log entry
func (r *UserRepository) LogWeight(ctx context.Context, userID string, weightKg float64, loggedDate time.Time, notes *string) (*WeightLog, error) {
	query := `
		INSERT INTO weight_logs (user_id, weight_kg, logged_date, notes)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, logged_date) DO UPDATE
		SET weight_kg = EXCLUDED.weight_kg, notes = EXCLUDED.notes
		RETURNING id, user_id, weight_kg, logged_date, notes, created_at
	`

	var log WeightLog
	err := r.pool.QueryRow(ctx, query, userID, weightKg, loggedDate, notes).Scan(
		&log.ID, &log.UserID, &log.WeightKg, &log.LoggedDate, &log.Notes, &log.CreatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &log, nil
}

// GetWeightHistory retrieves weight history for a user
func (r *UserRepository) GetWeightHistory(ctx context.Context, userID string, startDate, endDate *time.Time, limit int) ([]*WeightLog, error) {
	query := `
		SELECT id, user_id, weight_kg, logged_date, notes, created_at
		FROM weight_logs
		WHERE user_id = $1
		  AND ($2::date IS NULL OR logged_date >= $2)
		  AND ($3::date IS NULL OR logged_date <= $3)
		ORDER BY logged_date DESC
		LIMIT $4
	`

	rows, err := r.pool.Query(ctx, query, userID, startDate, endDate, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var logs []*WeightLog
	for rows.Next() {
		var log WeightLog
		err := rows.Scan(&log.ID, &log.UserID, &log.WeightKg, &log.LoggedDate, &log.Notes, &log.CreatedAt)
		if err != nil {
			return nil, err
		}
		logs = append(logs, &log)
	}

	return logs, rows.Err()
}

// DeleteWeightLog deletes a weight log entry
func (r *UserRepository) DeleteWeightLog(ctx context.Context, id, userID string) error {
	query := `DELETE FROM weight_logs WHERE id = $1 AND user_id = $2`
	_, err := r.pool.Exec(ctx, query, id, userID)
	return err
}
