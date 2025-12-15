package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// WorkoutTemplate represents a workout template
type WorkoutTemplate struct {
	ID                       string
	UserID                   string
	Name                     string
	Description              *string
	TotalExercises           int
	TotalSets                int
	EstimatedDurationMinutes *int
	IsArchived               bool
	CreatedAt                time.Time
	UpdatedAt                time.Time
	Sections                 []*WorkoutSection
}

// WorkoutSection represents a section within a workout
type WorkoutSection struct {
	ID                 string
	WorkoutTemplateID  string
	Name               string
	DisplayOrder       int
	IsSuperset         bool
	CreatedAt          time.Time
	Items              []*SectionItem
}

// SectionItem represents an item (exercise or rest) within a section
type SectionItem struct {
	ID                   string
	SectionID            string
	ItemType             string
	DisplayOrder         int
	ExerciseID           *string
	ExerciseName         *string
	ExerciseType         *string
	RestDurationSeconds  *int
	CreatedAt            time.Time
	TargetSets           []*ExerciseTargetSet
}

// ExerciseTargetSet represents a target set for an exercise
type ExerciseTargetSet struct {
	ID                  string
	SectionItemID       string
	SetNumber           int
	TargetWeightKg      *float64
	TargetReps          *int
	TargetTimeSeconds   *int
	TargetDistanceM     *float64
	IsBodyweight        bool
	Notes               *string
	RestDurationSeconds *int
	CreatedAt           time.Time
}

// WorkoutRepository handles workout template data access
type WorkoutRepository struct {
	pool *pgxpool.Pool
}

// NewWorkoutRepository creates a new WorkoutRepository
func NewWorkoutRepository(pool *pgxpool.Pool) *WorkoutRepository {
	return &WorkoutRepository{pool: pool}
}

// List retrieves workout templates for a user
func (r *WorkoutRepository) List(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*WorkoutTemplate, int, error) {
	countQuery := `
		SELECT COUNT(*)
		FROM workout_templates
		WHERE user_id = $1 AND ($2 = TRUE OR is_archived = FALSE)
	`

	var totalCount int
	err := r.pool.QueryRow(ctx, countQuery, userID, includeArchived).Scan(&totalCount)
	if err != nil {
		return nil, 0, err
	}

	query := `
		SELECT id, user_id, name, description, total_exercises, total_sets,
		       estimated_duration_minutes, is_archived, created_at, updated_at
		FROM workout_templates
		WHERE user_id = $1 AND ($2 = TRUE OR is_archived = FALSE)
		ORDER BY updated_at DESC
		LIMIT $3 OFFSET $4
	`

	rows, err := r.pool.Query(ctx, query, userID, includeArchived, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var workouts []*WorkoutTemplate
	for rows.Next() {
		var w WorkoutTemplate
		err := rows.Scan(
			&w.ID, &w.UserID, &w.Name, &w.Description, &w.TotalExercises, &w.TotalSets,
			&w.EstimatedDurationMinutes, &w.IsArchived, &w.CreatedAt, &w.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		workouts = append(workouts, &w)
	}

	return workouts, totalCount, rows.Err()
}

// GetByID retrieves a workout template with full details
func (r *WorkoutRepository) GetByID(ctx context.Context, id, userID string) (*WorkoutTemplate, error) {
	query := `
		SELECT id, user_id, name, description, total_exercises, total_sets,
		       estimated_duration_minutes, is_archived, created_at, updated_at
		FROM workout_templates
		WHERE id = $1 AND user_id = $2
	`

	var w WorkoutTemplate
	err := r.pool.QueryRow(ctx, query, id, userID).Scan(
		&w.ID, &w.UserID, &w.Name, &w.Description, &w.TotalExercises, &w.TotalSets,
		&w.EstimatedDurationMinutes, &w.IsArchived, &w.CreatedAt, &w.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	// Load sections
	sections, err := r.loadSections(ctx, id)
	if err != nil {
		return nil, err
	}
	w.Sections = sections

	return &w, nil
}

func (r *WorkoutRepository) loadSections(ctx context.Context, workoutID string) ([]*WorkoutSection, error) {
	query := `
		SELECT id, workout_template_id, name, display_order, is_superset, created_at
		FROM workout_sections
		WHERE workout_template_id = $1
		ORDER BY display_order
	`

	rows, err := r.pool.Query(ctx, query, workoutID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sections []*WorkoutSection
	for rows.Next() {
		var s WorkoutSection
		err := rows.Scan(&s.ID, &s.WorkoutTemplateID, &s.Name, &s.DisplayOrder, &s.IsSuperset, &s.CreatedAt)
		if err != nil {
			return nil, err
		}
		sections = append(sections, &s)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Load items for each section
	for _, s := range sections {
		items, err := r.loadSectionItems(ctx, s.ID)
		if err != nil {
			return nil, err
		}
		s.Items = items
	}

	return sections, nil
}

func (r *WorkoutRepository) loadSectionItems(ctx context.Context, sectionID string) ([]*SectionItem, error) {
	query := `
		SELECT si.id, si.section_id, si.item_type::text, si.display_order,
		       si.exercise_id, e.name as exercise_name, e.exercise_type::text as exercise_type,
		       si.rest_duration_seconds, si.created_at
		FROM section_items si
		LEFT JOIN exercises e ON si.exercise_id = e.id
		WHERE si.section_id = $1
		ORDER BY si.display_order
	`

	rows, err := r.pool.Query(ctx, query, sectionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []*SectionItem
	for rows.Next() {
		var i SectionItem
		err := rows.Scan(
			&i.ID, &i.SectionID, &i.ItemType, &i.DisplayOrder,
			&i.ExerciseID, &i.ExerciseName, &i.ExerciseType,
			&i.RestDurationSeconds, &i.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		items = append(items, &i)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Load target sets for exercise items
	for _, item := range items {
		if item.ItemType == "exercise" && item.ExerciseID != nil {
			sets, err := r.loadTargetSets(ctx, item.ID)
			if err != nil {
				return nil, err
			}
			item.TargetSets = sets
		}
	}

	return items, nil
}

func (r *WorkoutRepository) loadTargetSets(ctx context.Context, sectionItemID string) ([]*ExerciseTargetSet, error) {
	query := `
		SELECT id, section_item_id, set_number, target_weight_kg, target_reps,
		       target_time_seconds, target_distance_m, is_bodyweight, notes, rest_duration_seconds, created_at
		FROM exercise_target_sets
		WHERE section_item_id = $1
		ORDER BY set_number
	`

	rows, err := r.pool.Query(ctx, query, sectionItemID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sets []*ExerciseTargetSet
	for rows.Next() {
		var s ExerciseTargetSet
		err := rows.Scan(
			&s.ID, &s.SectionItemID, &s.SetNumber, &s.TargetWeightKg, &s.TargetReps,
			&s.TargetTimeSeconds, &s.TargetDistanceM, &s.IsBodyweight, &s.Notes, &s.RestDurationSeconds, &s.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		sets = append(sets, &s)
	}

	return sets, rows.Err()
}

// Create creates a new workout template
func (r *WorkoutRepository) Create(ctx context.Context, userID, name string, description *string) (*WorkoutTemplate, error) {
	query := `
		INSERT INTO workout_templates (user_id, name, description)
		VALUES ($1, $2, $3)
		RETURNING id, user_id, name, description, total_exercises, total_sets,
		          estimated_duration_minutes, is_archived, created_at, updated_at
	`

	var w WorkoutTemplate
	err := r.pool.QueryRow(ctx, query, userID, name, description).Scan(
		&w.ID, &w.UserID, &w.Name, &w.Description, &w.TotalExercises, &w.TotalSets,
		&w.EstimatedDurationMinutes, &w.IsArchived, &w.CreatedAt, &w.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &w, nil
}

// Delete deletes a workout template
func (r *WorkoutRepository) Delete(ctx context.Context, id, userID string) error {
	query := `DELETE FROM workout_templates WHERE id = $1 AND user_id = $2`
	_, err := r.pool.Exec(ctx, query, id, userID)
	return err
}

// CreateSection creates a new section in a workout
func (r *WorkoutRepository) CreateSection(ctx context.Context, workoutID, name string, displayOrder int, isSuperset bool) (*WorkoutSection, error) {
	query := `
		INSERT INTO workout_sections (workout_template_id, name, display_order, is_superset)
		VALUES ($1, $2, $3, $4)
		RETURNING id, workout_template_id, name, display_order, is_superset, created_at
	`

	var s WorkoutSection
	err := r.pool.QueryRow(ctx, query, workoutID, name, displayOrder, isSuperset).Scan(
		&s.ID, &s.WorkoutTemplateID, &s.Name, &s.DisplayOrder, &s.IsSuperset, &s.CreatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &s, nil
}

// CreateSectionItem creates a new item in a section
func (r *WorkoutRepository) CreateSectionItem(ctx context.Context, sectionID, itemType string, displayOrder int, exerciseID *string, restDurationSeconds *int) (*SectionItem, error) {
	query := `
		INSERT INTO section_items (section_id, item_type, display_order, exercise_id, rest_duration_seconds)
		VALUES ($1, $2::section_item_type, $3, $4, $5)
		RETURNING id, section_id, item_type::text, display_order, exercise_id, rest_duration_seconds, created_at
	`

	var i SectionItem
	err := r.pool.QueryRow(ctx, query, sectionID, itemType, displayOrder, exerciseID, restDurationSeconds).Scan(
		&i.ID, &i.SectionID, &i.ItemType, &i.DisplayOrder, &i.ExerciseID, &i.RestDurationSeconds, &i.CreatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &i, nil
}

// CreateTargetSet creates a new target set for an exercise item
func (r *WorkoutRepository) CreateTargetSet(ctx context.Context, sectionItemID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, targetDistanceM *float64, isBodyweight bool, notes *string, restDurationSeconds *int) (*ExerciseTargetSet, error) {
	query := `
		INSERT INTO exercise_target_sets (section_item_id, set_number, target_weight_kg, target_reps, target_time_seconds, target_distance_m, is_bodyweight, notes, rest_duration_seconds)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id, section_item_id, set_number, target_weight_kg, target_reps, target_time_seconds, target_distance_m, is_bodyweight, notes, rest_duration_seconds, created_at
	`

	var s ExerciseTargetSet
	err := r.pool.QueryRow(ctx, query, sectionItemID, setNumber, targetWeightKg, targetReps, targetTimeSeconds, targetDistanceM, isBodyweight, notes, restDurationSeconds).Scan(
		&s.ID, &s.SectionItemID, &s.SetNumber, &s.TargetWeightKg, &s.TargetReps, &s.TargetTimeSeconds, &s.TargetDistanceM, &s.IsBodyweight, &s.Notes, &s.RestDurationSeconds, &s.CreatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &s, nil
}

// DeleteSections deletes all sections (and cascading items/sets) for a workout
func (r *WorkoutRepository) DeleteSections(ctx context.Context, workoutID string) error {
	query := `DELETE FROM workout_sections WHERE workout_template_id = $1`
	_, err := r.pool.Exec(ctx, query, workoutID)
	return err
}

// UpdateWorkoutDetails updates the top-level details of a workout template
func (r *WorkoutRepository) UpdateWorkoutDetails(ctx context.Context, id, name string, description *string, isArchived bool) (*WorkoutTemplate, error) {
	query := `
		UPDATE workout_templates
		SET name = $2, description = $3, is_archived = $4, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
		RETURNING id, user_id, name, description, total_exercises, total_sets,
		          estimated_duration_minutes, is_archived, created_at, updated_at
	`

	var w WorkoutTemplate
	err := r.pool.QueryRow(ctx, query, id, name, description, isArchived).Scan(
		&w.ID, &w.UserID, &w.Name, &w.Description, &w.TotalExercises, &w.TotalSets,
		&w.EstimatedDurationMinutes, &w.IsArchived, &w.CreatedAt, &w.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &w, nil
}
