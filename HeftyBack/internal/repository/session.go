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
	TotalSets          int // Computed from session_sets, not stored in DB
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
		          status::text, started_at, completed_at, duration_seconds, completed_sets,
		          notes, created_at, updated_at
	`

	var s WorkoutSession
	err := r.pool.QueryRow(ctx, query, userID, workoutTemplateID, programID, programDayNumber, name).Scan(
		&s.ID, &s.UserID, &s.WorkoutTemplateID, &s.ProgramID, &s.ProgramDayNumber, &s.Name,
		&s.Status, &s.StartedAt, &s.CompletedAt, &s.DurationSeconds, &s.CompletedSets,
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
		       status::text, started_at, completed_at, duration_seconds, completed_sets,
		       notes, created_at, updated_at
		FROM workout_sessions
		WHERE id = $1 AND user_id = $2
	`

	var s WorkoutSession
	err := r.pool.QueryRow(ctx, query, id, userID).Scan(
		&s.ID, &s.UserID, &s.WorkoutTemplateID, &s.ProgramID, &s.ProgramDayNumber, &s.Name,
		&s.Status, &s.StartedAt, &s.CompletedAt, &s.DurationSeconds, &s.CompletedSets,
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

// SyncSets batch updates existing sets and creates new sets in a session
func (r *SessionRepository) SyncSets(ctx context.Context, sessionID string, sets []SyncSetInput) error {
	if len(sets) == 0 {
		return nil
	}

	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	for _, set := range sets {
		if set.SetID != nil && *set.SetID != "" {
			// Update existing set
			query := `
				UPDATE session_sets
				SET weight_kg = COALESCE($2, weight_kg),
				    reps = COALESCE($3, reps),
				    time_seconds = COALESCE($4, time_seconds),
				    distance_m = COALESCE($5, distance_m),
				    is_completed = $6,
				    completed_at = CASE
				        WHEN $6 AND NOT is_completed THEN CURRENT_TIMESTAMP
				        WHEN NOT $6 THEN NULL
				        ELSE completed_at
				    END,
				    rpe = COALESCE($7, rpe),
				    notes = COALESCE($8, notes),
				    updated_at = CURRENT_TIMESTAMP
				WHERE id = $1
			`
			_, err := tx.Exec(ctx, query,
				*set.SetID, set.WeightKg, set.Reps, set.TimeSeconds,
				set.DistanceM, set.IsCompleted, set.RPE, set.Notes)
			if err != nil {
				return err
			}
		} else if set.SessionExerciseID != nil && *set.SessionExerciseID != "" {
			// Create new set - get max set_number and add 1
			var maxSetNumber int
			err := tx.QueryRow(ctx, `
				SELECT COALESCE(MAX(set_number), 0) FROM session_sets WHERE session_exercise_id = $1
			`, *set.SessionExerciseID).Scan(&maxSetNumber)
			if err != nil {
				return err
			}

			query := `
				INSERT INTO session_sets (session_exercise_id, set_number, weight_kg, reps, time_seconds, distance_m, is_completed, rpe, notes)
				VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
			`
			_, err = tx.Exec(ctx, query,
				*set.SessionExerciseID, maxSetNumber+1, set.WeightKg, set.Reps, set.TimeSeconds,
				set.DistanceM, set.IsCompleted, set.RPE, set.Notes)
			if err != nil {
				return err
			}
		}
	}

	// Update session completed_sets count
	updateCountQuery := `
		UPDATE workout_sessions ws
		SET completed_sets = (
			SELECT COUNT(*) FROM session_sets ss
			JOIN session_exercises se ON ss.session_exercise_id = se.id
			WHERE se.session_id = ws.id AND ss.is_completed = true
		),
		updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`
	_, err = tx.Exec(ctx, updateCountQuery, sessionID)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

// FinishSession marks a session as completed
func (r *SessionRepository) FinishSession(ctx context.Context, id, userID string, notes *string) (*WorkoutSession, error) {
	// Start a transaction as we're doing multiple operations
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)

	// Update session status
	query := `
		UPDATE workout_sessions
		SET status = 'completed',
		    completed_at = CURRENT_TIMESTAMP,
		    duration_seconds = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - started_at))::INTEGER,
		    notes = COALESCE($3, notes),
		    updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND user_id = $2
		RETURNING id, user_id, workout_template_id, program_id, program_day_number, name,
		          status::text, started_at, completed_at, duration_seconds, completed_sets,
		          notes, created_at, updated_at
	`

	var s WorkoutSession
	err = tx.QueryRow(ctx, query, id, userID, notes).Scan(
		&s.ID, &s.UserID, &s.WorkoutTemplateID, &s.ProgramID, &s.ProgramDayNumber, &s.Name,
		&s.Status, &s.StartedAt, &s.CompletedAt, &s.DurationSeconds, &s.CompletedSets,
		&s.Notes, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	// Calculate and save exercise history
	// This aggregates stats for each exercise in the session and saves to exercise_history table
	err = r.calculateAndSaveStats(ctx, tx, id, userID, s.StartedAt)
	if err != nil {
		// Log error but don't fail session completion if stats fail?
		// Ideally we should fail to ensure data consistency
		return nil, err
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}

	return &s, nil
}

func (r *SessionRepository) calculateAndSaveStats(ctx context.Context, tx pgx.Tx, sessionID, userID string, sessionDate time.Time) error {
	// 1. Get all sets for this session that are completed
	query := `
		SELECT se.exercise_id, ss.weight_kg, ss.reps, ss.time_seconds, ss.distance_m
		FROM session_sets ss
		JOIN session_exercises se ON ss.session_exercise_id = se.id
		WHERE se.session_id = $1 AND ss.is_completed = TRUE
	`

	rows, err := tx.Query(ctx, query, sessionID)
	if err != nil {
		return err
	}
	defer rows.Close()

	// 2. Aggregate stats per exercise
	type exStats struct {
		ExerciseID    string
		BestWeight    float64
		BestReps      int
		BestTime      int
		TotalSets     int
		TotalReps     int
		TotalVolume   float64
	}

	statsMap := make(map[string]*exStats)

	for rows.Next() {
		var (
			exID      string
			weight    *float64
			reps      *int
			timeSec   *int
			distance  *float64
		)
		if err := rows.Scan(&exID, &weight, &reps, &timeSec, &distance); err != nil {
			return err
		}

		stats, exists := statsMap[exID]
		if !exists {
			stats = &exStats{ExerciseID: exID}
			statsMap[exID] = stats
		}

		stats.TotalSets++

		// Calculate volume (Weight * Reps) for weight exercises
		w := 0.0
		if weight != nil {
			w = *weight
		}
		r := 0
		if reps != nil {
			r = *reps
		}

		if weight != nil && reps != nil {
			stats.TotalVolume += w * float64(r)
			stats.TotalReps += r
		}

		// Update bests
		if w > stats.BestWeight {
			stats.BestWeight = w
			// If identical weight, could check reps, but basic max weight is primary
		}
		if r > stats.BestReps {
			stats.BestReps = r
		}
		if timeSec != nil && *timeSec > stats.BestTime {
			stats.BestTime = *timeSec
		}
	}
	if err := rows.Err(); err != nil {
		return err
	}

	// 3. Insert into exercise_history
	insertQuery := `
		INSERT INTO exercise_history (
			user_id, exercise_id, session_id, session_date,
			best_weight_kg, best_reps, best_time_seconds,
			total_sets, total_reps, total_volume_kg, created_at
		) VALUES (
			$1, $2, $3, $4,
			NULLIF($5, 0.0), NULLIF($6, 0), NULLIF($7, 0),
			$8, NULLIF($9, 0), NULLIF($10, 0.0), CURRENT_TIMESTAMP
		)
		ON CONFLICT (session_id, exercise_id) DO UPDATE SET
			best_weight_kg = EXCLUDED.best_weight_kg,
			best_reps = EXCLUDED.best_reps,
			best_time_seconds = EXCLUDED.best_time_seconds,
			total_sets = EXCLUDED.total_sets,
			total_reps = EXCLUDED.total_reps,
			total_volume_kg = EXCLUDED.total_volume_kg
	`

	// Note: Schema in 00001_initial_schema.sql doesn't show updated_at for exercise_history,
	// checking if it exists. Based on view, it has created_at.
	// We'll skip updated_at in ON UPDATE for now unless schema check reveals it.
	// Actually ON CONFLICT DO UPDATE is good to have if we ever re-process a session.

	for _, stats := range statsMap {
		_, err := tx.Exec(ctx, insertQuery,
			userID, stats.ExerciseID, sessionID, sessionDate,
			stats.BestWeight, stats.BestReps, stats.BestTime,
			stats.TotalSets, stats.TotalReps, stats.TotalVolume,
		)
		if err != nil {
			return err
		}
	}

	return nil
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
		SELECT ws.id, ws.user_id, ws.workout_template_id, ws.program_id, ws.program_day_number, ws.name,
		       ws.status::text, ws.started_at, ws.completed_at, ws.duration_seconds,
		       COALESCE((
		           SELECT COUNT(ss.id)
		           FROM session_sets ss
		           JOIN session_exercises se ON ss.session_exercise_id = se.id
		           WHERE se.session_id = ws.id
		       ), 0) as total_sets,
		       ws.completed_sets, ws.notes, ws.created_at, ws.updated_at
		FROM workout_sessions ws
		WHERE ws.user_id = $1
		  AND ($2::text IS NULL OR ws.status::text = $2)
		  AND ($3::timestamp IS NULL OR ws.started_at >= $3)
		  AND ($4::timestamp IS NULL OR ws.started_at <= $4)
		ORDER BY ws.started_at DESC
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
