package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// WorkoutSession represents a workout session
type WorkoutSession struct {
	ID                 string
	UserID             string
	WorkoutTemplateID  *string
	ProgramID          *string
	ProgramDayNumber   *int
	Name               *string
	Status             string
	StartedAt          time.Time
	CompletedAt        *time.Time
	DurationSeconds    *int
	TotalSets          int
	CompletedSets      int
	Notes              *string
	CreatedAt          time.Time
	UpdatedAt          time.Time
	Exercises          []*SessionExercise
}

// SessionExercise represents an exercise in a session
type SessionExercise struct {
	ID            string
	SessionID     string
	ExerciseID    string
	ExerciseName  string
	ExerciseType  string
	SectionItemID *string
	DisplayOrder  int
	SectionName   *string
	Notes         *string
	CreatedAt     time.Time
	Sets          []*SessionSet
}

// SessionSet represents a set in a session exercise
type SessionSet struct {
	ID                  string
	SessionExerciseID   string
	SetNumber           int
	WeightKg            *float64
	Reps                *int
	TimeSeconds         *int
	DistanceM           *float64
	IsBodyweight        bool
	IsCompleted         bool
	CompletedAt         *time.Time
	TargetWeightKg      *float64
	TargetReps          *int
	TargetTimeSeconds   *int
	RPE                 *float64
	Notes               *string
	CreatedAt           time.Time
	UpdatedAt           time.Time
}

// SessionRepository handles workout session data access
type SessionRepository struct {
	pool *pgxpool.Pool
}

// NewSessionRepository creates a new SessionRepository
func NewSessionRepository(pool *pgxpool.Pool) *SessionRepository {
	return &SessionRepository{pool: pool}
}

// Create creates a new workout session
func (r *SessionRepository) Create(ctx context.Context, userID string, workoutTemplateID, programID *string, programDayNumber *int, name *string) (*WorkoutSession, error) {
	query := `
		INSERT INTO workout_sessions (user_id, workout_template_id, program_id, program_day_number, name)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, user_id, workout_template_id, program_id, program_day_number, name,
		          status::text, started_at, completed_at, duration_seconds, total_sets, completed_sets,
		          notes, created_at, updated_at
	`

	var s WorkoutSession
	err := r.pool.QueryRow(ctx, query, userID, workoutTemplateID, programID, programDayNumber, name).Scan(
		&s.ID, &s.UserID, &s.WorkoutTemplateID, &s.ProgramID, &s.ProgramDayNumber, &s.Name,
		&s.Status, &s.StartedAt, &s.CompletedAt, &s.DurationSeconds, &s.TotalSets, &s.CompletedSets,
		&s.Notes, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &s, nil
}

// GetByID retrieves a session with full details
func (r *SessionRepository) GetByID(ctx context.Context, id, userID string) (*WorkoutSession, error) {
	query := `
		SELECT id, user_id, workout_template_id, program_id, program_day_number, name,
		       status::text, started_at, completed_at, duration_seconds, total_sets, completed_sets,
		       notes, created_at, updated_at
		FROM workout_sessions
		WHERE id = $1 AND user_id = $2
	`

	var s WorkoutSession
	err := r.pool.QueryRow(ctx, query, id, userID).Scan(
		&s.ID, &s.UserID, &s.WorkoutTemplateID, &s.ProgramID, &s.ProgramDayNumber, &s.Name,
		&s.Status, &s.StartedAt, &s.CompletedAt, &s.DurationSeconds, &s.TotalSets, &s.CompletedSets,
		&s.Notes, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	// Load exercises
	exercises, err := r.loadExercises(ctx, id)
	if err != nil {
		return nil, err
	}
	s.Exercises = exercises

	return &s, nil
}

func (r *SessionRepository) loadExercises(ctx context.Context, sessionID string) ([]*SessionExercise, error) {
	query := `
		SELECT se.id, se.session_id, se.exercise_id, e.name as exercise_name,
		       e.exercise_type::text as exercise_type, se.section_item_id,
		       se.display_order, se.section_name, se.notes, se.created_at
		FROM session_exercises se
		JOIN exercises e ON se.exercise_id = e.id
		WHERE se.session_id = $1
		ORDER BY se.display_order
	`

	rows, err := r.pool.Query(ctx, query, sessionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var exercises []*SessionExercise
	for rows.Next() {
		var e SessionExercise
		err := rows.Scan(
			&e.ID, &e.SessionID, &e.ExerciseID, &e.ExerciseName,
			&e.ExerciseType, &e.SectionItemID,
			&e.DisplayOrder, &e.SectionName, &e.Notes, &e.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		exercises = append(exercises, &e)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Load sets for each exercise
	for _, e := range exercises {
		sets, err := r.loadSets(ctx, e.ID)
		if err != nil {
			return nil, err
		}
		e.Sets = sets
	}

	return exercises, nil
}

func (r *SessionRepository) loadSets(ctx context.Context, sessionExerciseID string) ([]*SessionSet, error) {
	query := `
		SELECT id, session_exercise_id, set_number, weight_kg, reps, time_seconds, distance_m,
		       is_bodyweight, is_completed, completed_at, target_weight_kg, target_reps,
		       target_time_seconds, rpe, notes, created_at, updated_at
		FROM session_sets
		WHERE session_exercise_id = $1
		ORDER BY set_number
	`

	rows, err := r.pool.Query(ctx, query, sessionExerciseID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sets []*SessionSet
	for rows.Next() {
		var s SessionSet
		err := rows.Scan(
			&s.ID, &s.SessionExerciseID, &s.SetNumber, &s.WeightKg, &s.Reps, &s.TimeSeconds, &s.DistanceM,
			&s.IsBodyweight, &s.IsCompleted, &s.CompletedAt, &s.TargetWeightKg, &s.TargetReps,
			&s.TargetTimeSeconds, &s.RPE, &s.Notes, &s.CreatedAt, &s.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		sets = append(sets, &s)
	}

	return sets, rows.Err()
}

// AddExercise adds an exercise to a session
func (r *SessionRepository) AddExercise(ctx context.Context, sessionID, exerciseID string, displayOrder int, sectionName *string) (*SessionExercise, error) {
	query := `
		INSERT INTO session_exercises (session_id, exercise_id, display_order, section_name)
		VALUES ($1, $2, $3, $4)
		RETURNING id, session_id, exercise_id, section_item_id, display_order, section_name, notes, created_at
	`

	var e SessionExercise
	err := r.pool.QueryRow(ctx, query, sessionID, exerciseID, displayOrder, sectionName).Scan(
		&e.ID, &e.SessionID, &e.ExerciseID, &e.SectionItemID, &e.DisplayOrder, &e.SectionName, &e.Notes, &e.CreatedAt,
	)
	if err != nil {
		return nil, err
	}

	// Get exercise details
	exQuery := `SELECT name, exercise_type::text FROM exercises WHERE id = $1`
	err = r.pool.QueryRow(ctx, exQuery, exerciseID).Scan(&e.ExerciseName, &e.ExerciseType)
	if err != nil {
		return nil, err
	}

	return &e, nil
}

// AddSet adds a set to a session exercise
func (r *SessionRepository) AddSet(ctx context.Context, sessionExerciseID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, isBodyweight bool) (*SessionSet, error) {
	query := `
		INSERT INTO session_sets (session_exercise_id, set_number, target_weight_kg, target_reps, target_time_seconds, is_bodyweight)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, session_exercise_id, set_number, weight_kg, reps, time_seconds, distance_m,
		          is_bodyweight, is_completed, completed_at, target_weight_kg, target_reps,
		          target_time_seconds, rpe, notes, created_at, updated_at
	`

	var s SessionSet
	err := r.pool.QueryRow(ctx, query, sessionExerciseID, setNumber, targetWeightKg, targetReps, targetTimeSeconds, isBodyweight).Scan(
		&s.ID, &s.SessionExerciseID, &s.SetNumber, &s.WeightKg, &s.Reps, &s.TimeSeconds, &s.DistanceM,
		&s.IsBodyweight, &s.IsCompleted, &s.CompletedAt, &s.TargetWeightKg, &s.TargetReps,
		&s.TargetTimeSeconds, &s.RPE, &s.Notes, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &s, nil
}

// CompleteSet marks a set as completed with actual values
func (r *SessionRepository) CompleteSet(ctx context.Context, setID string, weightKg *float64, reps, timeSeconds *int, distanceM, rpe *float64, notes *string) (*SessionSet, error) {
	query := `
		UPDATE session_sets
		SET weight_kg = COALESCE($2, weight_kg),
		    reps = COALESCE($3, reps),
		    time_seconds = COALESCE($4, time_seconds),
		    distance_m = COALESCE($5, distance_m),
		    rpe = COALESCE($6, rpe),
		    notes = COALESCE($7, notes),
		    is_completed = TRUE,
		    completed_at = CURRENT_TIMESTAMP,
		    updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
		RETURNING id, session_exercise_id, set_number, weight_kg, reps, time_seconds, distance_m,
		          is_bodyweight, is_completed, completed_at, target_weight_kg, target_reps,
		          target_time_seconds, rpe, notes, created_at, updated_at
	`

	var s SessionSet
	err := r.pool.QueryRow(ctx, query, setID, weightKg, reps, timeSeconds, distanceM, rpe, notes).Scan(
		&s.ID, &s.SessionExerciseID, &s.SetNumber, &s.WeightKg, &s.Reps, &s.TimeSeconds, &s.DistanceM,
		&s.IsBodyweight, &s.IsCompleted, &s.CompletedAt, &s.TargetWeightKg, &s.TargetReps,
		&s.TargetTimeSeconds, &s.RPE, &s.Notes, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &s, nil
}

// FinishSession marks a session as completed
func (r *SessionRepository) FinishSession(ctx context.Context, id, userID string, notes *string) (*WorkoutSession, error) {
	query := `
		UPDATE workout_sessions
		SET status = 'completed',
		    completed_at = CURRENT_TIMESTAMP,
		    duration_seconds = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - started_at))::INTEGER,
		    notes = COALESCE($3, notes),
		    updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND user_id = $2
		RETURNING id, user_id, workout_template_id, program_id, program_day_number, name,
		          status::text, started_at, completed_at, duration_seconds, total_sets, completed_sets,
		          notes, created_at, updated_at
	`

	var s WorkoutSession
	err := r.pool.QueryRow(ctx, query, id, userID, notes).Scan(
		&s.ID, &s.UserID, &s.WorkoutTemplateID, &s.ProgramID, &s.ProgramDayNumber, &s.Name,
		&s.Status, &s.StartedAt, &s.CompletedAt, &s.DurationSeconds, &s.TotalSets, &s.CompletedSets,
		&s.Notes, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &s, nil
}

// AbandonSession marks a session as abandoned
func (r *SessionRepository) AbandonSession(ctx context.Context, id, userID string) error {
	query := `
		UPDATE workout_sessions
		SET status = 'abandoned',
		    updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND user_id = $2
	`
	_, err := r.pool.Exec(ctx, query, id, userID)
	return err
}

// List retrieves sessions for a user
func (r *SessionRepository) List(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*WorkoutSession, int, error) {
	countQuery := `
		SELECT COUNT(*)
		FROM workout_sessions
		WHERE user_id = $1
		  AND ($2::text IS NULL OR status::text = $2)
		  AND ($3::timestamp IS NULL OR started_at >= $3)
		  AND ($4::timestamp IS NULL OR started_at <= $4)
	`

	var totalCount int
	err := r.pool.QueryRow(ctx, countQuery, userID, status, startDate, endDate).Scan(&totalCount)
	if err != nil {
		return nil, 0, err
	}

	query := `
		SELECT id, user_id, workout_template_id, program_id, program_day_number, name,
		       status::text, started_at, completed_at, duration_seconds, total_sets, completed_sets,
		       notes, created_at, updated_at
		FROM workout_sessions
		WHERE user_id = $1
		  AND ($2::text IS NULL OR status::text = $2)
		  AND ($3::timestamp IS NULL OR started_at >= $3)
		  AND ($4::timestamp IS NULL OR started_at <= $4)
		ORDER BY started_at DESC
		LIMIT $5 OFFSET $6
	`

	rows, err := r.pool.Query(ctx, query, userID, status, startDate, endDate, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var sessions []*WorkoutSession
	for rows.Next() {
		var s WorkoutSession
		err := rows.Scan(
			&s.ID, &s.UserID, &s.WorkoutTemplateID, &s.ProgramID, &s.ProgramDayNumber, &s.Name,
			&s.Status, &s.StartedAt, &s.CompletedAt, &s.DurationSeconds, &s.TotalSets, &s.CompletedSets,
			&s.Notes, &s.CreatedAt, &s.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		sessions = append(sessions, &s)
	}

	return sessions, totalCount, rows.Err()
}
