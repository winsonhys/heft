package repository

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Program represents a training program: a start_date + duration_weeks block
// containing a set of ProgramWorkouts, each assigned to one or more weekdays.
type Program struct {
	ID            string
	UserID        string
	Name          string
	Description   *string
	StartDate     time.Time
	DurationWeeks int
	IsActive      bool
	IsArchived    bool
	CreatedAt     time.Time
	UpdatedAt     time.Time
	Workouts      []*ProgramWorkout
}

// ProgramWorkout is a workout scheduled within a program on 1..7 weekdays.
// DaysOfWeek values are ISO: Monday=1..Sunday=7.
type ProgramWorkout struct {
	ID                string
	ProgramID         string
	WorkoutTemplateID string
	WorkoutName       string
	DaysOfWeek        []int16
	DisplayOrder      int
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

const programColumns = `id, user_id, name, description, start_date, duration_weeks,
	is_active, is_archived, created_at, updated_at`

func scanProgram(row pgx.Row, p *Program) error {
	return row.Scan(&p.ID, &p.UserID, &p.Name, &p.Description, &p.StartDate, &p.DurationWeeks,
		&p.IsActive, &p.IsArchived, &p.CreatedAt, &p.UpdatedAt)
}

// List retrieves programs for a user (summaries — no workouts loaded)
func (r *ProgramRepository) List(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*Program, int, error) {
	var totalCount int
	err := r.pool.QueryRow(ctx, `
		SELECT COUNT(*) FROM programs
		WHERE user_id = $1 AND ($2 = TRUE OR is_archived = FALSE)
	`, userID, includeArchived).Scan(&totalCount)
	if err != nil {
		return nil, 0, err
	}

	rows, err := r.pool.Query(ctx, `
		SELECT `+programColumns+`
		FROM programs
		WHERE user_id = $1 AND ($2 = TRUE OR is_archived = FALSE)
		ORDER BY is_active DESC, updated_at DESC
		LIMIT $3 OFFSET $4
	`, userID, includeArchived, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var programs []*Program
	for rows.Next() {
		var p Program
		if err := scanProgram(rows, &p); err != nil {
			return nil, 0, err
		}
		programs = append(programs, &p)
	}

	return programs, totalCount, rows.Err()
}

// ListWorkoutCounts returns total workout counts keyed by program ID for the
// given programs. Used to populate ProgramSummary.total_workouts.
func (r *ProgramRepository) ListWorkoutCounts(ctx context.Context, programIDs []string) (map[string]int, error) {
	if len(programIDs) == 0 {
		return map[string]int{}, nil
	}
	rows, err := r.pool.Query(ctx, `
		SELECT program_id, COUNT(*) FROM program_workouts
		WHERE program_id = ANY($1)
		GROUP BY program_id
	`, programIDs)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	counts := make(map[string]int, len(programIDs))
	for rows.Next() {
		var id string
		var count int
		if err := rows.Scan(&id, &count); err != nil {
			return nil, err
		}
		counts[id] = count
	}
	return counts, rows.Err()
}

// GetByID retrieves a program with full details (workouts loaded)
func (r *ProgramRepository) GetByID(ctx context.Context, id, userID string) (*Program, error) {
	var p Program
	err := scanProgram(r.pool.QueryRow(ctx, `
		SELECT `+programColumns+`
		FROM programs
		WHERE id = $1 AND user_id = $2
	`, id, userID), &p)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	workouts, err := r.loadWorkouts(ctx, p.ID)
	if err != nil {
		return nil, err
	}
	p.Workouts = workouts
	return &p, nil
}

func (r *ProgramRepository) loadWorkouts(ctx context.Context, programID string) ([]*ProgramWorkout, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT pw.id, pw.program_id, pw.workout_template_id, wt.name,
		       pw.days_of_week, pw.display_order, pw.created_at
		FROM program_workouts pw
		JOIN workout_templates wt ON pw.workout_template_id = wt.id
		WHERE pw.program_id = $1
		ORDER BY pw.display_order
	`, programID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var workouts []*ProgramWorkout
	for rows.Next() {
		var w ProgramWorkout
		if err := rows.Scan(&w.ID, &w.ProgramID, &w.WorkoutTemplateID, &w.WorkoutName,
			&w.DaysOfWeek, &w.DisplayOrder, &w.CreatedAt); err != nil {
			return nil, err
		}
		workouts = append(workouts, &w)
	}
	return workouts, rows.Err()
}

// Create creates a new program
func (r *ProgramRepository) Create(ctx context.Context, userID, name string, description *string, startDate time.Time, durationWeeks int) (*Program, error) {
	var p Program
	err := scanProgram(r.pool.QueryRow(ctx, `
		INSERT INTO programs (user_id, name, description, start_date, duration_weeks)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING `+programColumns, userID, name, description, startDate, durationWeeks), &p)
	if err != nil {
		return nil, err
	}
	return &p, nil
}

// CreateWorkout inserts a workout assignment for a program
func (r *ProgramRepository) CreateWorkout(ctx context.Context, programID, workoutTemplateID string, daysOfWeek []int16, displayOrder int) (*ProgramWorkout, error) {
	var w ProgramWorkout
	err := r.pool.QueryRow(ctx, `
		INSERT INTO program_workouts (program_id, workout_template_id, days_of_week, display_order)
		VALUES ($1, $2, $3, $4)
		RETURNING id, program_id, workout_template_id, days_of_week, display_order, created_at
	`, programID, workoutTemplateID, daysOfWeek, displayOrder).Scan(
		&w.ID, &w.ProgramID, &w.WorkoutTemplateID, &w.DaysOfWeek, &w.DisplayOrder, &w.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &w, nil
}

// DeleteWorkouts removes all workout assignments for a program (user-scoped via programs)
func (r *ProgramRepository) DeleteWorkouts(ctx context.Context, programID, userID string) error {
	_, err := r.pool.Exec(ctx, `
		DELETE FROM program_workouts
		WHERE program_id = $1
		  AND EXISTS (SELECT 1 FROM programs WHERE id = $1 AND user_id = $2)
	`, programID, userID)
	return err
}

// SetActive activates the given program and deactivates all others for the user.
func (r *ProgramRepository) SetActive(ctx context.Context, id, userID string) (*Program, error) {
	if _, err := r.pool.Exec(ctx, `UPDATE programs SET is_active = FALSE WHERE user_id = $1`, userID); err != nil {
		return nil, err
	}
	var p Program
	err := scanProgram(r.pool.QueryRow(ctx, `
		UPDATE programs
		SET is_active = TRUE, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND user_id = $2
		RETURNING `+programColumns, id, userID), &p)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &p, nil
}

// Delete removes a program
func (r *ProgramRepository) Delete(ctx context.Context, id, userID string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM programs WHERE id = $1 AND user_id = $2`, id, userID)
	return err
}

// Update applies optional field updates to a program. COALESCE preserves existing
// values when the input is nil.
func (r *ProgramRepository) Update(ctx context.Context, id, userID string, name, description *string, startDate *time.Time, durationWeeks *int, isArchived *bool) (*Program, error) {
	var p Program
	err := scanProgram(r.pool.QueryRow(ctx, `
		UPDATE programs
		SET name = COALESCE($3, name),
		    description = COALESCE($4, description),
		    start_date = COALESCE($5, start_date),
		    duration_weeks = COALESCE($6, duration_weeks),
		    is_archived = COALESCE($7, is_archived),
		    updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND user_id = $2
		RETURNING `+programColumns,
		id, userID, name, description, startDate, durationWeeks, isArchived), &p)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &p, nil
}

// Archive marks a program archived and inactive
func (r *ProgramRepository) Archive(ctx context.Context, id, userID string) error {
	_, err := r.pool.Exec(ctx, `
		UPDATE programs
		SET is_archived = TRUE, is_active = FALSE, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND user_id = $2
	`, id, userID)
	return err
}

// GetActiveProgram returns the active program for a user (with workouts loaded), or nil.
func (r *ProgramRepository) GetActiveProgram(ctx context.Context, userID string) (*Program, error) {
	var p Program
	err := scanProgram(r.pool.QueryRow(ctx, `
		SELECT `+programColumns+`
		FROM programs
		WHERE user_id = $1 AND is_active = TRUE
		LIMIT 1
	`, userID), &p)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	workouts, err := r.loadWorkouts(ctx, p.ID)
	if err != nil {
		return nil, err
	}
	p.Workouts = workouts
	return &p, nil
}
