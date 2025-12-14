package testutil

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

// TestUser represents a user for testing
type TestUser struct {
	ID               string
	Email            string
	PasswordHash     string
	DisplayName      *string
	AvatarURL        *string
	UsePounds        bool
	RestTimerSeconds int
}

// TestExercise represents an exercise for testing
type TestExercise struct {
	ID           string
	Name         string
	CategoryID   string
	ExerciseType string
	IsSystem     bool
	CreatedBy    *string
	Description  *string
}

// DefaultTestUser returns a default test user configuration with a unique email
func DefaultTestUser() TestUser {
	displayName := "Test User"
	// Generate unique email to avoid conflicts across tests
	uniqueID := uuid.New().String()[:8]
	return TestUser{
		Email:            fmt.Sprintf("test-%s@example.com", uniqueID),
		PasswordHash:     "$2a$10$abcdefghijklmnopqrstuv",
		DisplayName:      &displayName,
		UsePounds:        false,
		RestTimerSeconds: 120,
	}
}

// SeedTestUser inserts a test user into the database
func SeedTestUser(t *testing.T, pool *pgxpool.Pool, user TestUser) string {
	t.Helper()

	query := `
		INSERT INTO users (id, email, password_hash, display_name, avatar_url, use_pounds, rest_timer_seconds)
		VALUES (COALESCE(NULLIF($1, '')::uuid, gen_random_uuid()), $2, $3, $4, $5, $6, $7)
		RETURNING id
	`

	var id string
	err := pool.QueryRow(context.Background(), query,
		user.ID,
		user.Email,
		user.PasswordHash,
		user.DisplayName,
		user.AvatarURL,
		user.UsePounds,
		user.RestTimerSeconds,
	).Scan(&id)

	if err != nil {
		t.Fatalf("failed to seed test user: %v", err)
	}

	return id
}

// SeedTestWeightLog inserts a test weight log entry
func SeedTestWeightLog(t *testing.T, pool *pgxpool.Pool, userID string, weightKg float64, loggedDate time.Time) string {
	t.Helper()

	query := `
		INSERT INTO weight_logs (user_id, weight_kg, logged_date)
		VALUES ($1, $2, $3)
		RETURNING id
	`

	var id string
	err := pool.QueryRow(context.Background(), query, userID, weightKg, loggedDate).Scan(&id)
	if err != nil {
		t.Fatalf("failed to seed weight log: %v", err)
	}

	return id
}

// SeedTestExercise inserts a test exercise
func SeedTestExercise(t *testing.T, pool *pgxpool.Pool, ex TestExercise) string {
	t.Helper()

	query := `
		INSERT INTO exercises (id, name, category_id, exercise_type, is_system, created_by, description)
		VALUES (COALESCE(NULLIF($1, '')::uuid, gen_random_uuid()), $2, $3::uuid, $4::exercise_type, $5, $6::uuid, $7)
		RETURNING id
	`

	var id string
	err := pool.QueryRow(context.Background(), query,
		ex.ID,
		ex.Name,
		ex.CategoryID,
		ex.ExerciseType,
		ex.IsSystem,
		ex.CreatedBy,
		ex.Description,
	).Scan(&id)

	if err != nil {
		t.Fatalf("failed to seed test exercise: %v", err)
	}

	return id
}

// Seeded category IDs from migrations/00002_seed_data.sql
const (
	ChestCategoryID     = "11111111-1111-1111-1111-111111111101"
	BackCategoryID      = "11111111-1111-1111-1111-111111111102"
	ShouldersCategoryID = "11111111-1111-1111-1111-111111111103"
	ArmsCategoryID      = "11111111-1111-1111-1111-111111111104"
	LegsCategoryID      = "11111111-1111-1111-1111-111111111105"
	CoreCategoryID      = "11111111-1111-1111-1111-111111111106"
	CardioCategoryID    = "11111111-1111-1111-1111-111111111107"
	FullBodyCategoryID  = "11111111-1111-1111-1111-111111111108"
)

// GetChestCategoryID returns the seeded Chest category ID from migrations
func GetChestCategoryID() string {
	return ChestCategoryID
}

// GetBackCategoryID returns the seeded Back category ID from migrations
func GetBackCategoryID() string {
	return BackCategoryID
}
