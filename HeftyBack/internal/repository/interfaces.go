package repository

import (
	"context"
	"time"
)

// UserRepositoryInterface defines the contract for user data access
type UserRepositoryInterface interface {
	GetByID(ctx context.Context, id string) (*User, error)
	UpdateProfile(ctx context.Context, id string, displayName, avatarURL *string) (*User, error)
	UpdateSettings(ctx context.Context, id string, usePounds *bool, restTimerSeconds *int) (*User, error)
	LogWeight(ctx context.Context, userID string, weightKg float64, loggedDate time.Time, notes *string) (*WeightLog, error)
	GetWeightHistory(ctx context.Context, userID string, startDate, endDate *time.Time, limit int) ([]*WeightLog, error)
	DeleteWeightLog(ctx context.Context, id, userID string) error
}

// ExerciseRepositoryInterface defines the contract for exercise data access
type ExerciseRepositoryInterface interface {
	ListCategories(ctx context.Context) ([]*ExerciseCategory, error)
	ListExercises(ctx context.Context, categoryID, exerciseType *string, systemOnly bool, userID *string, limit, offset int) ([]*Exercise, int, error)
	GetByID(ctx context.Context, id string) (*Exercise, error)
	Create(ctx context.Context, userID, name, categoryID, exerciseType string, description *string) (*Exercise, error)
	Search(ctx context.Context, query string, userID *string, limit int) ([]*Exercise, error)
}

// SyncSetInput represents input data for syncing a set
type SyncSetInput struct {
	SetID             *string  // nil/empty = new set
	SessionExerciseID *string  // Required for new sets
	WeightKg          *float64
	Reps              *int
	TimeSeconds       *int
	DistanceM         *float64
	IsCompleted       bool
	RPE               *float64
	Notes             *string
}

// SessionRepositoryInterface defines the contract for session data access
type SessionRepositoryInterface interface {
	Create(ctx context.Context, userID string, workoutTemplateID, programID *string, programDayNumber *int, name *string) (*WorkoutSession, error)
	GetByID(ctx context.Context, id, userID string) (*WorkoutSession, error)
	AddExercise(ctx context.Context, sessionID, exerciseID string, displayOrder int, sectionName, supersetID *string) (*SessionExercise, error)
	AddSet(ctx context.Context, sessionExerciseID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, isBodyweight bool) (*SessionSet, error)
	SyncSets(ctx context.Context, sessionID string, sets []SyncSetInput) error
	DeleteSets(ctx context.Context, sessionID string, setIDs []string) error
	DeleteExercises(ctx context.Context, sessionID string, exerciseIDs []string) error
	UpdateExercise(ctx context.Context, sessionID, exerciseID string, params UpdateExerciseParams) error
	FinishSession(ctx context.Context, id, userID string, notes *string) (*WorkoutSession, error)
	AbandonSession(ctx context.Context, id, userID string) error
	List(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*WorkoutSession, int, error)
}

// WorkoutRepositoryInterface defines the contract for workout template data access
type WorkoutRepositoryInterface interface {
	List(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*WorkoutTemplate, int, error)
	GetByID(ctx context.Context, id, userID string) (*WorkoutTemplate, error)
	Create(ctx context.Context, userID, name string, description *string) (*WorkoutTemplate, error)
	Delete(ctx context.Context, id, userID string) error
	UpdateWorkoutDetails(ctx context.Context, id, name string, description *string, isArchived bool) (*WorkoutTemplate, error)
	DeleteSections(ctx context.Context, workoutID string) error
	CreateSection(ctx context.Context, workoutID, name string, displayOrder int, isSuperset bool) (*WorkoutSection, error)
	CreateSectionItem(ctx context.Context, sectionID, itemType string, displayOrder int, exerciseID *string, restDurationSeconds *int) (*SectionItem, error)
	CreateTargetSet(ctx context.Context, sectionItemID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, targetDistanceM *float64, isBodyweight bool, notes *string, restDurationSeconds *int) (*ExerciseTargetSet, error)
}

// ProgramRepositoryInterface defines the contract for program data access
type ProgramRepositoryInterface interface {
	List(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*Program, int, error)
	GetByID(ctx context.Context, id, userID string) (*Program, error)
	Create(ctx context.Context, userID, name string, description *string, durationWeeks, durationDays int) (*Program, error)
	CreateDay(ctx context.Context, programID string, dayNumber int, dayType string, workoutTemplateID, customName *string) (*ProgramDay, error)
	SetActive(ctx context.Context, id, userID string) (*Program, error)
	Delete(ctx context.Context, id, userID string) error
	GetActiveProgram(ctx context.Context, userID string) (*Program, error)
}

// ProgressRepositoryInterface defines the contract for progress data access
type ProgressRepositoryInterface interface {
	GetDashboardStats(ctx context.Context, userID string) (*DashboardStats, error)
	GetWeeklyActivity(ctx context.Context, userID string, weekStart *time.Time) ([]*WeeklyActivityDay, error)
	GetPersonalRecords(ctx context.Context, userID string, limit int, exerciseID *string) ([]*PersonalRecord, error)
	GetExerciseProgress(ctx context.Context, userID, exerciseID string, limit int) ([]*ExerciseProgressPoint, error)
	GetStreak(ctx context.Context, userID string) (int, int, *time.Time, error)
}

// AuthRepositoryInterface defines the contract for auth data access
type AuthRepositoryInterface interface {
	GetByEmail(ctx context.Context, email string) (*User, error)
	Create(ctx context.Context, email string) (*User, error)
}

// Compile-time interface compliance checks
var _ UserRepositoryInterface = (*UserRepository)(nil)
var _ ExerciseRepositoryInterface = (*ExerciseRepository)(nil)
var _ SessionRepositoryInterface = (*SessionRepository)(nil)
var _ WorkoutRepositoryInterface = (*WorkoutRepository)(nil)
var _ ProgramRepositoryInterface = (*ProgramRepository)(nil)
var _ ProgressRepositoryInterface = (*ProgressRepository)(nil)
var _ AuthRepositoryInterface = (*AuthRepository)(nil)
