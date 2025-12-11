package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// DashboardStats represents dashboard statistics
type DashboardStats struct {
	TotalWorkouts    int
	WorkoutsThisWeek int
	CurrentStreak    int
	TotalVolumeKg    int
	DaysActive       int
}

// WeeklyActivityDay represents a day's activity
type WeeklyActivityDay struct {
	Date         time.Time
	DayOfWeek    string
	WorkoutCount int
	IsToday      bool
}

// PersonalRecord represents a PR
type PersonalRecord struct {
	ID           string
	UserID       string
	ExerciseID   string
	ExerciseName string
	WeightKg     *float64
	Reps         *int
	TimeSeconds  *int
	OneRepMaxKg  *float64
	Volume       *float64
	AchievedAt   time.Time
}

// ExerciseProgressPoint represents a data point for progress charts
type ExerciseProgressPoint struct {
	Date            time.Time
	BestWeightKg    *float64
	BestReps        *int
	BestTimeSeconds *int
	TotalVolumeKg   *float64
	TotalSets       int
}

// ProgressRepository handles progress and analytics data access
type ProgressRepository struct {
	pool *pgxpool.Pool
}

// NewProgressRepository creates a new ProgressRepository
func NewProgressRepository(pool *pgxpool.Pool) *ProgressRepository {
	return &ProgressRepository{pool: pool}
}

// GetDashboardStats retrieves dashboard statistics
func (r *ProgressRepository) GetDashboardStats(ctx context.Context, userID string) (*DashboardStats, error) {
	query := `
		SELECT
			(SELECT COUNT(*) FROM workout_sessions WHERE user_id = $1 AND status = 'completed') as total_workouts,
			(SELECT COUNT(*) FROM workout_sessions WHERE user_id = $1 AND status = 'completed' AND started_at >= DATE_TRUNC('week', CURRENT_DATE)) as workouts_this_week,
			(SELECT COUNT(DISTINCT DATE(started_at)) FROM workout_sessions WHERE user_id = $1 AND status = 'completed') as days_active,
			COALESCE((SELECT SUM(total_volume_kg) FROM exercise_history WHERE user_id = $1), 0)::integer as total_volume_kg
	`

	var stats DashboardStats
	err := r.pool.QueryRow(ctx, query, userID).Scan(
		&stats.TotalWorkouts,
		&stats.WorkoutsThisWeek,
		&stats.DaysActive,
		&stats.TotalVolumeKg,
	)
	if err != nil {
		return nil, err
	}

	// Calculate streak separately (more complex query)
	stats.CurrentStreak, err = r.calculateStreak(ctx, userID)
	if err != nil {
		return nil, err
	}

	return &stats, nil
}

func (r *ProgressRepository) calculateStreak(ctx context.Context, userID string) (int, error) {
	query := `
		WITH daily_workouts AS (
			SELECT DISTINCT DATE(started_at) as workout_date
			FROM workout_sessions
			WHERE user_id = $1 AND status = 'completed'
		),
		streak AS (
			SELECT workout_date,
			       workout_date - (ROW_NUMBER() OVER (ORDER BY workout_date))::int as grp
			FROM daily_workouts
			WHERE workout_date >= CURRENT_DATE - 365
		)
		SELECT COALESCE(MAX(cnt), 0)
		FROM (
			SELECT grp, COUNT(*) as cnt
			FROM streak
			WHERE grp = (SELECT grp FROM streak WHERE workout_date = CURRENT_DATE OR workout_date = CURRENT_DATE - 1 ORDER BY workout_date DESC LIMIT 1)
			GROUP BY grp
		) sub
	`

	var streak int
	err := r.pool.QueryRow(ctx, query, userID).Scan(&streak)
	if err != nil {
		return 0, err
	}

	return streak, nil
}

// GetWeeklyActivity retrieves weekly activity data
func (r *ProgressRepository) GetWeeklyActivity(ctx context.Context, userID string, weekStart *time.Time) ([]*WeeklyActivityDay, error) {
	var startDate time.Time
	if weekStart != nil {
		startDate = *weekStart
	} else {
		// Get Monday of current week
		now := time.Now()
		offset := int(now.Weekday())
		if offset == 0 {
			offset = 7
		}
		startDate = now.AddDate(0, 0, -offset+1).Truncate(24 * time.Hour)
	}

	query := `
		WITH week_days AS (
			SELECT generate_series($2::date, $2::date + 6, '1 day'::interval)::date as day
		)
		SELECT
			wd.day,
			TO_CHAR(wd.day, 'Dy') as day_of_week,
			COUNT(ws.id)::integer as workout_count,
			wd.day = CURRENT_DATE as is_today
		FROM week_days wd
		LEFT JOIN workout_sessions ws ON DATE(ws.started_at) = wd.day
			AND ws.user_id = $1
			AND ws.status = 'completed'
		GROUP BY wd.day
		ORDER BY wd.day
	`

	rows, err := r.pool.Query(ctx, query, userID, startDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var days []*WeeklyActivityDay
	for rows.Next() {
		var d WeeklyActivityDay
		err := rows.Scan(&d.Date, &d.DayOfWeek, &d.WorkoutCount, &d.IsToday)
		if err != nil {
			return nil, err
		}
		days = append(days, &d)
	}

	return days, rows.Err()
}

// GetPersonalRecords retrieves personal records
func (r *ProgressRepository) GetPersonalRecords(ctx context.Context, userID string, limit int, exerciseID *string) ([]*PersonalRecord, error) {
	query := `
		SELECT pr.id, pr.user_id, pr.exercise_id, e.name as exercise_name,
		       pr.weight_kg, pr.reps, pr.time_seconds, pr.one_rep_max_kg, pr.volume, pr.achieved_at
		FROM personal_records pr
		JOIN exercises e ON pr.exercise_id = e.id
		WHERE pr.user_id = $1
		  AND ($3::uuid IS NULL OR pr.exercise_id = $3)
		ORDER BY pr.achieved_at DESC
		LIMIT $2
	`

	rows, err := r.pool.Query(ctx, query, userID, limit, exerciseID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var records []*PersonalRecord
	for rows.Next() {
		var pr PersonalRecord
		err := rows.Scan(
			&pr.ID, &pr.UserID, &pr.ExerciseID, &pr.ExerciseName,
			&pr.WeightKg, &pr.Reps, &pr.TimeSeconds, &pr.OneRepMaxKg, &pr.Volume, &pr.AchievedAt,
		)
		if err != nil {
			return nil, err
		}
		records = append(records, &pr)
	}

	return records, rows.Err()
}

// GetExerciseProgress retrieves progress data for an exercise
func (r *ProgressRepository) GetExerciseProgress(ctx context.Context, userID, exerciseID string, limit int) ([]*ExerciseProgressPoint, error) {
	query := `
		SELECT session_date, best_weight_kg, best_reps, best_time_seconds, total_volume_kg, total_sets
		FROM exercise_history
		WHERE user_id = $1 AND exercise_id = $2
		ORDER BY session_date DESC
		LIMIT $3
	`

	rows, err := r.pool.Query(ctx, query, userID, exerciseID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var points []*ExerciseProgressPoint
	for rows.Next() {
		var p ExerciseProgressPoint
		err := rows.Scan(&p.Date, &p.BestWeightKg, &p.BestReps, &p.BestTimeSeconds, &p.TotalVolumeKg, &p.TotalSets)
		if err != nil {
			return nil, err
		}
		points = append(points, &p)
	}

	return points, rows.Err()
}

// GetStreak retrieves current and longest streak
func (r *ProgressRepository) GetStreak(ctx context.Context, userID string) (int, int, *time.Time, error) {
	currentStreak, err := r.calculateStreak(ctx, userID)
	if err != nil {
		return 0, 0, nil, err
	}

	// Get longest streak
	longestQuery := `
		WITH daily_workouts AS (
			SELECT DISTINCT DATE(started_at) as workout_date
			FROM workout_sessions
			WHERE user_id = $1 AND status = 'completed'
		),
		streak AS (
			SELECT workout_date,
			       workout_date - (ROW_NUMBER() OVER (ORDER BY workout_date))::int as grp
			FROM daily_workouts
		)
		SELECT COALESCE(MAX(cnt), 0)
		FROM (
			SELECT grp, COUNT(*) as cnt
			FROM streak
			GROUP BY grp
		) sub
	`

	var longestStreak int
	err = r.pool.QueryRow(ctx, longestQuery, userID).Scan(&longestStreak)
	if err != nil {
		return 0, 0, nil, err
	}

	// Get last workout date
	lastQuery := `
		SELECT MAX(DATE(started_at))
		FROM workout_sessions
		WHERE user_id = $1 AND status = 'completed'
	`

	var lastWorkout *time.Time
	err = r.pool.QueryRow(ctx, lastQuery, userID).Scan(&lastWorkout)
	if err != nil {
		return 0, 0, nil, err
	}

	return currentStreak, longestStreak, lastWorkout, nil
}
