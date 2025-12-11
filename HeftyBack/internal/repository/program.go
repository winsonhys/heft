package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Program represents a training program
type Program struct {
	ID               string
	UserID           string
	Name             string
	Description      *string
	DurationWeeks    int
	DurationDays     int
	TotalWorkoutDays int
	TotalRestDays    int
	IsActive         bool
	IsArchived       bool
	CreatedAt        time.Time
	UpdatedAt        time.Time
	Days             []*ProgramDay
}

// ProgramDay represents a day in a program
type ProgramDay struct {
	ID                string
	ProgramID         string
	DayNumber         int
	DayType           string
	WorkoutTemplateID *string
	WorkoutName       *string
	CustomName        *string
	CreatedAt         time.Time
}

// ProgramRepository handles program data access
type ProgramRepository struct {
	pool *pgxpool.Pool
}

// NewProgramRepository creates a new ProgramRepository
func NewProgramRepository(pool *pgxpool.Pool) *ProgramRepository {
	return &ProgramRepository{pool: pool}
}

// List retrieves programs for a user
func (r *ProgramRepository) List(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*Program, int, error) {
	countQuery := `
		SELECT COUNT(*)
		FROM programs
		WHERE user_id = $1 AND ($2 = TRUE OR is_archived = FALSE)
	`

	var totalCount int
	err := r.pool.QueryRow(ctx, countQuery, userID, includeArchived).Scan(&totalCount)
	if err != nil {
		return nil, 0, err
	}

	query := `
		SELECT id, user_id, name, description, duration_weeks, duration_days,
		       total_workout_days, total_rest_days, is_active, is_archived, created_at, updated_at
		FROM programs
		WHERE user_id = $1 AND ($2 = TRUE OR is_archived = FALSE)
		ORDER BY is_active DESC, updated_at DESC
		LIMIT $3 OFFSET $4
	`

	rows, err := r.pool.Query(ctx, query, userID, includeArchived, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var programs []*Program
	for rows.Next() {
		var p Program
		err := rows.Scan(
			&p.ID, &p.UserID, &p.Name, &p.Description, &p.DurationWeeks, &p.DurationDays,
			&p.TotalWorkoutDays, &p.TotalRestDays, &p.IsActive, &p.IsArchived, &p.CreatedAt, &p.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		programs = append(programs, &p)
	}

	return programs, totalCount, rows.Err()
}

// GetByID retrieves a program with full details
func (r *ProgramRepository) GetByID(ctx context.Context, id, userID string) (*Program, error) {
	query := `
		SELECT id, user_id, name, description, duration_weeks, duration_days,
		       total_workout_days, total_rest_days, is_active, is_archived, created_at, updated_at
		FROM programs
		WHERE id = $1 AND user_id = $2
	`

	var p Program
	err := r.pool.QueryRow(ctx, query, id, userID).Scan(
		&p.ID, &p.UserID, &p.Name, &p.Description, &p.DurationWeeks, &p.DurationDays,
		&p.TotalWorkoutDays, &p.TotalRestDays, &p.IsActive, &p.IsArchived, &p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	// Load days
	days, err := r.loadDays(ctx, id)
	if err != nil {
		return nil, err
	}
	p.Days = days

	return &p, nil
}

func (r *ProgramRepository) loadDays(ctx context.Context, programID string) ([]*ProgramDay, error) {
	query := `
		SELECT pd.id, pd.program_id, pd.day_number, pd.day_type::text,
		       pd.workout_template_id, wt.name as workout_name, pd.custom_name, pd.created_at
		FROM program_days pd
		LEFT JOIN workout_templates wt ON pd.workout_template_id = wt.id
		WHERE pd.program_id = $1
		ORDER BY pd.day_number
	`

	rows, err := r.pool.Query(ctx, query, programID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var days []*ProgramDay
	for rows.Next() {
		var d ProgramDay
		err := rows.Scan(
			&d.ID, &d.ProgramID, &d.DayNumber, &d.DayType,
			&d.WorkoutTemplateID, &d.WorkoutName, &d.CustomName, &d.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		days = append(days, &d)
	}

	return days, rows.Err()
}

// Create creates a new program
func (r *ProgramRepository) Create(ctx context.Context, userID, name string, description *string, durationWeeks, durationDays int) (*Program, error) {
	query := `
		INSERT INTO programs (user_id, name, description, duration_weeks, duration_days)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, user_id, name, description, duration_weeks, duration_days,
		          total_workout_days, total_rest_days, is_active, is_archived, created_at, updated_at
	`

	var p Program
	err := r.pool.QueryRow(ctx, query, userID, name, description, durationWeeks, durationDays).Scan(
		&p.ID, &p.UserID, &p.Name, &p.Description, &p.DurationWeeks, &p.DurationDays,
		&p.TotalWorkoutDays, &p.TotalRestDays, &p.IsActive, &p.IsArchived, &p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &p, nil
}

// CreateDay creates a day in a program
func (r *ProgramRepository) CreateDay(ctx context.Context, programID string, dayNumber int, dayType string, workoutTemplateID, customName *string) (*ProgramDay, error) {
	query := `
		INSERT INTO program_days (program_id, day_number, day_type, workout_template_id, custom_name)
		VALUES ($1, $2, $3::program_day_type, $4, $5)
		RETURNING id, program_id, day_number, day_type::text, workout_template_id, custom_name, created_at
	`

	var d ProgramDay
	err := r.pool.QueryRow(ctx, query, programID, dayNumber, dayType, workoutTemplateID, customName).Scan(
		&d.ID, &d.ProgramID, &d.DayNumber, &d.DayType, &d.WorkoutTemplateID, &d.CustomName, &d.CreatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &d, nil
}

// SetActive sets a program as active and deactivates others
func (r *ProgramRepository) SetActive(ctx context.Context, id, userID string) (*Program, error) {
	// Deactivate all programs for user
	_, err := r.pool.Exec(ctx, `UPDATE programs SET is_active = FALSE WHERE user_id = $1`, userID)
	if err != nil {
		return nil, err
	}

	// Activate the specified program
	query := `
		UPDATE programs
		SET is_active = TRUE, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND user_id = $2
		RETURNING id, user_id, name, description, duration_weeks, duration_days,
		          total_workout_days, total_rest_days, is_active, is_archived, created_at, updated_at
	`

	var p Program
	err = r.pool.QueryRow(ctx, query, id, userID).Scan(
		&p.ID, &p.UserID, &p.Name, &p.Description, &p.DurationWeeks, &p.DurationDays,
		&p.TotalWorkoutDays, &p.TotalRestDays, &p.IsActive, &p.IsArchived, &p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &p, nil
}

// Delete deletes a program
func (r *ProgramRepository) Delete(ctx context.Context, id, userID string) error {
	query := `DELETE FROM programs WHERE id = $1 AND user_id = $2`
	_, err := r.pool.Exec(ctx, query, id, userID)
	return err
}

// GetActiveProgram retrieves the active program for a user
func (r *ProgramRepository) GetActiveProgram(ctx context.Context, userID string) (*Program, error) {
	query := `
		SELECT id, user_id, name, description, duration_weeks, duration_days,
		       total_workout_days, total_rest_days, is_active, is_archived, created_at, updated_at
		FROM programs
		WHERE user_id = $1 AND is_active = TRUE
		LIMIT 1
	`

	var p Program
	err := r.pool.QueryRow(ctx, query, userID).Scan(
		&p.ID, &p.UserID, &p.Name, &p.Description, &p.DurationWeeks, &p.DurationDays,
		&p.TotalWorkoutDays, &p.TotalRestDays, &p.IsActive, &p.IsArchived, &p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	// Load days
	days, err := r.loadDays(ctx, p.ID)
	if err != nil {
		return nil, err
	}
	p.Days = days

	return &p, nil
}
