package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// ExerciseCategory represents an exercise category
type ExerciseCategory struct {
	ID           string
	Name         string
	DisplayOrder int
	CreatedAt    time.Time
}

// Exercise represents an exercise in the database
type Exercise struct {
	ID           string
	Name         string
	CategoryID   *string
	CategoryName *string
	ExerciseType string
	Description  *string
	IsSystem     bool
	CreatedBy    *string
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

// ExerciseRepository handles exercise data access
type ExerciseRepository struct {
	pool *pgxpool.Pool
}

// NewExerciseRepository creates a new ExerciseRepository
func NewExerciseRepository(pool *pgxpool.Pool) *ExerciseRepository {
	return &ExerciseRepository{pool: pool}
}

// ListCategories retrieves all exercise categories
func (r *ExerciseRepository) ListCategories(ctx context.Context) ([]*ExerciseCategory, error) {
	query := `
		SELECT id, name, display_order, created_at
		FROM exercise_categories
		ORDER BY display_order
	`

	rows, err := r.pool.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var categories []*ExerciseCategory
	for rows.Next() {
		var cat ExerciseCategory
		err := rows.Scan(&cat.ID, &cat.Name, &cat.DisplayOrder, &cat.CreatedAt)
		if err != nil {
			return nil, err
		}
		categories = append(categories, &cat)
	}

	return categories, rows.Err()
}

// ListExercises retrieves exercises with optional filters
func (r *ExerciseRepository) ListExercises(ctx context.Context, categoryID, exerciseType *string, systemOnly bool, userID *string, limit, offset int) ([]*Exercise, int, error) {
	countQuery := `
		SELECT COUNT(*)
		FROM exercises e
		LEFT JOIN exercise_categories ec ON e.category_id = ec.id
		WHERE ($1::uuid IS NULL OR e.category_id = $1)
		  AND ($2::text IS NULL OR e.exercise_type::text = $2)
		  AND ($3 = FALSE OR e.is_system = TRUE)
		  AND (e.is_system = TRUE OR e.created_by = $4)
	`

	var totalCount int
	err := r.pool.QueryRow(ctx, countQuery, categoryID, exerciseType, systemOnly, userID).Scan(&totalCount)
	if err != nil {
		return nil, 0, err
	}

	query := `
		SELECT e.id, e.name, e.category_id, ec.name as category_name,
		       e.exercise_type::text, e.description, e.is_system, e.created_by,
		       e.created_at, e.updated_at
		FROM exercises e
		LEFT JOIN exercise_categories ec ON e.category_id = ec.id
		WHERE ($1::uuid IS NULL OR e.category_id = $1)
		  AND ($2::text IS NULL OR e.exercise_type::text = $2)
		  AND ($3 = FALSE OR e.is_system = TRUE)
		  AND (e.is_system = TRUE OR e.created_by = $4)
		ORDER BY ec.display_order, e.name
		LIMIT $5 OFFSET $6
	`

	rows, err := r.pool.Query(ctx, query, categoryID, exerciseType, systemOnly, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var exercises []*Exercise
	for rows.Next() {
		var ex Exercise
		err := rows.Scan(
			&ex.ID, &ex.Name, &ex.CategoryID, &ex.CategoryName,
			&ex.ExerciseType, &ex.Description, &ex.IsSystem, &ex.CreatedBy,
			&ex.CreatedAt, &ex.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		exercises = append(exercises, &ex)
	}

	return exercises, totalCount, rows.Err()
}

// GetByID retrieves an exercise by ID
func (r *ExerciseRepository) GetByID(ctx context.Context, id string) (*Exercise, error) {
	query := `
		SELECT e.id, e.name, e.category_id, ec.name as category_name,
		       e.exercise_type::text, e.description, e.is_system, e.created_by,
		       e.created_at, e.updated_at
		FROM exercises e
		LEFT JOIN exercise_categories ec ON e.category_id = ec.id
		WHERE e.id = $1
	`

	var ex Exercise
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&ex.ID, &ex.Name, &ex.CategoryID, &ex.CategoryName,
		&ex.ExerciseType, &ex.Description, &ex.IsSystem, &ex.CreatedBy,
		&ex.CreatedAt, &ex.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &ex, nil
}

// Create creates a new custom exercise
func (r *ExerciseRepository) Create(ctx context.Context, userID, name, categoryID, exerciseType string, description *string) (*Exercise, error) {
	query := `
		INSERT INTO exercises (name, category_id, exercise_type, description, is_system, created_by)
		VALUES ($1, $2, $3::exercise_type, $4, FALSE, $5)
		RETURNING id, created_at, updated_at
	`

	var ex Exercise
	ex.Name = name
	ex.CategoryID = &categoryID
	ex.ExerciseType = exerciseType
	ex.Description = description
	ex.IsSystem = false
	ex.CreatedBy = &userID

	err := r.pool.QueryRow(ctx, query, name, categoryID, exerciseType, description, userID).Scan(
		&ex.ID, &ex.CreatedAt, &ex.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	// Fetch category name
	fullEx, err := r.GetByID(ctx, ex.ID)
	if err != nil {
		return nil, err
	}

	return fullEx, nil
}

// Search searches exercises by name
func (r *ExerciseRepository) Search(ctx context.Context, query string, userID *string, limit int) ([]*Exercise, error) {
	sql := `
		SELECT e.id, e.name, e.category_id, ec.name as category_name,
		       e.exercise_type::text, e.description, e.is_system, e.created_by,
		       e.created_at, e.updated_at
		FROM exercises e
		LEFT JOIN exercise_categories ec ON e.category_id = ec.id
		WHERE e.name ILIKE '%' || $1 || '%'
		  AND (e.is_system = TRUE OR e.created_by = $2)
		ORDER BY
		  CASE WHEN e.name ILIKE $1 || '%' THEN 0 ELSE 1 END,
		  e.name
		LIMIT $3
	`

	rows, err := r.pool.Query(ctx, sql, query, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var exercises []*Exercise
	for rows.Next() {
		var ex Exercise
		err := rows.Scan(
			&ex.ID, &ex.Name, &ex.CategoryID, &ex.CategoryName,
			&ex.ExerciseType, &ex.Description, &ex.IsSystem, &ex.CreatedBy,
			&ex.CreatedAt, &ex.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		exercises = append(exercises, &ex)
	}

	return exercises, rows.Err()
}
