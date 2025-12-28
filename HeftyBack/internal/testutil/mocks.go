package testutil

import (
	"context"
	"time"

	"github.com/heftyback/internal/repository"
)

// MockUserRepository is a mock implementation of UserRepositoryInterface
type MockUserRepository struct {
	GetByIDFunc          func(ctx context.Context, id string) (*repository.User, error)
	UpdateProfileFunc    func(ctx context.Context, id string, displayName, avatarURL *string) (*repository.User, error)
	UpdateSettingsFunc   func(ctx context.Context, id string, usePounds *bool, restTimerSeconds *int) (*repository.User, error)
	LogWeightFunc        func(ctx context.Context, userID string, weightKg float64, loggedDate time.Time, notes *string) (*repository.WeightLog, error)
	GetWeightHistoryFunc func(ctx context.Context, userID string, startDate, endDate *time.Time, limit int) ([]*repository.WeightLog, error)
	DeleteWeightLogFunc  func(ctx context.Context, id, userID string) error
}

func (m *MockUserRepository) GetByID(ctx context.Context, id string) (*repository.User, error) {
	if m.GetByIDFunc != nil {
		return m.GetByIDFunc(ctx, id)
	}
	return nil, nil
}

func (m *MockUserRepository) UpdateProfile(ctx context.Context, id string, displayName, avatarURL *string) (*repository.User, error) {
	if m.UpdateProfileFunc != nil {
		return m.UpdateProfileFunc(ctx, id, displayName, avatarURL)
	}
	return nil, nil
}

func (m *MockUserRepository) UpdateSettings(ctx context.Context, id string, usePounds *bool, restTimerSeconds *int) (*repository.User, error) {
	if m.UpdateSettingsFunc != nil {
		return m.UpdateSettingsFunc(ctx, id, usePounds, restTimerSeconds)
	}
	return nil, nil
}

func (m *MockUserRepository) LogWeight(ctx context.Context, userID string, weightKg float64, loggedDate time.Time, notes *string) (*repository.WeightLog, error) {
	if m.LogWeightFunc != nil {
		return m.LogWeightFunc(ctx, userID, weightKg, loggedDate, notes)
	}
	return nil, nil
}

func (m *MockUserRepository) GetWeightHistory(ctx context.Context, userID string, startDate, endDate *time.Time, limit int) ([]*repository.WeightLog, error) {
	if m.GetWeightHistoryFunc != nil {
		return m.GetWeightHistoryFunc(ctx, userID, startDate, endDate, limit)
	}
	return nil, nil
}

func (m *MockUserRepository) DeleteWeightLog(ctx context.Context, id, userID string) error {
	if m.DeleteWeightLogFunc != nil {
		return m.DeleteWeightLogFunc(ctx, id, userID)
	}
	return nil
}

// MockExerciseRepository is a mock implementation of ExerciseRepositoryInterface
type MockExerciseRepository struct {
	ListCategoriesFunc func(ctx context.Context) ([]*repository.ExerciseCategory, error)
	ListExercisesFunc  func(ctx context.Context, categoryID, exerciseType *string, systemOnly bool, userID *string, limit, offset int) ([]*repository.Exercise, int, error)
	GetByIDFunc        func(ctx context.Context, id string) (*repository.Exercise, error)
	CreateFunc         func(ctx context.Context, userID, name, categoryID, exerciseType string, description *string) (*repository.Exercise, error)
	SearchFunc         func(ctx context.Context, query string, userID *string, limit int) ([]*repository.Exercise, error)
}

func (m *MockExerciseRepository) ListCategories(ctx context.Context) ([]*repository.ExerciseCategory, error) {
	if m.ListCategoriesFunc != nil {
		return m.ListCategoriesFunc(ctx)
	}
	return nil, nil
}

func (m *MockExerciseRepository) ListExercises(ctx context.Context, categoryID, exerciseType *string, systemOnly bool, userID *string, limit, offset int) ([]*repository.Exercise, int, error) {
	if m.ListExercisesFunc != nil {
		return m.ListExercisesFunc(ctx, categoryID, exerciseType, systemOnly, userID, limit, offset)
	}
	return nil, 0, nil
}

func (m *MockExerciseRepository) GetByID(ctx context.Context, id string) (*repository.Exercise, error) {
	if m.GetByIDFunc != nil {
		return m.GetByIDFunc(ctx, id)
	}
	return nil, nil
}

func (m *MockExerciseRepository) Create(ctx context.Context, userID, name, categoryID, exerciseType string, description *string) (*repository.Exercise, error) {
	if m.CreateFunc != nil {
		return m.CreateFunc(ctx, userID, name, categoryID, exerciseType, description)
	}
	return nil, nil
}

func (m *MockExerciseRepository) Search(ctx context.Context, query string, userID *string, limit int) ([]*repository.Exercise, error) {
	if m.SearchFunc != nil {
		return m.SearchFunc(ctx, query, userID, limit)
	}
	return nil, nil
}

// MockSessionRepository is a mock implementation of SessionRepositoryInterface
type MockSessionRepository struct {
	CreateFunc          func(ctx context.Context, userID string, workoutTemplateID, programID *string, programDayNumber *int, name *string) (*repository.WorkoutSession, error)
	GetByIDFunc         func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error)
	AddExerciseFunc     func(ctx context.Context, sessionID, exerciseID string, displayOrder int, sectionName, supersetID *string) (*repository.SessionExercise, error)
	AddSetFunc          func(ctx context.Context, sessionExerciseID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, isBodyweight bool) (*repository.SessionSet, error)
	SyncSetsFunc        func(ctx context.Context, sessionID string, sets []repository.SyncSetInput) error
	DeleteSetsFunc      func(ctx context.Context, sessionID string, setIDs []string) error
	DeleteExercisesFunc func(ctx context.Context, sessionID string, exerciseIDs []string) error
	FinishSessionFunc   func(ctx context.Context, id, userID string, notes *string) (*repository.WorkoutSession, error)
	AbandonSessionFunc  func(ctx context.Context, id, userID string) error
	ListFunc            func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error)
}

func (m *MockSessionRepository) Create(ctx context.Context, userID string, workoutTemplateID, programID *string, programDayNumber *int, name *string) (*repository.WorkoutSession, error) {
	if m.CreateFunc != nil {
		return m.CreateFunc(ctx, userID, workoutTemplateID, programID, programDayNumber, name)
	}
	return nil, nil
}

func (m *MockSessionRepository) GetByID(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
	if m.GetByIDFunc != nil {
		return m.GetByIDFunc(ctx, id, userID)
	}
	return nil, nil
}

func (m *MockSessionRepository) AddExercise(ctx context.Context, sessionID, exerciseID string, displayOrder int, sectionName, supersetID *string) (*repository.SessionExercise, error) {
	if m.AddExerciseFunc != nil {
		return m.AddExerciseFunc(ctx, sessionID, exerciseID, displayOrder, sectionName, supersetID)
	}
	return nil, nil
}

func (m *MockSessionRepository) AddSet(ctx context.Context, sessionExerciseID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, isBodyweight bool) (*repository.SessionSet, error) {
	if m.AddSetFunc != nil {
		return m.AddSetFunc(ctx, sessionExerciseID, setNumber, targetWeightKg, targetReps, targetTimeSeconds, isBodyweight)
	}
	return nil, nil
}

func (m *MockSessionRepository) SyncSets(ctx context.Context, sessionID string, sets []repository.SyncSetInput) error {
	if m.SyncSetsFunc != nil {
		return m.SyncSetsFunc(ctx, sessionID, sets)
	}
	return nil
}

func (m *MockSessionRepository) DeleteSets(ctx context.Context, sessionID string, setIDs []string) error {
	if m.DeleteSetsFunc != nil {
		return m.DeleteSetsFunc(ctx, sessionID, setIDs)
	}
	return nil
}

func (m *MockSessionRepository) DeleteExercises(ctx context.Context, sessionID string, exerciseIDs []string) error {
	if m.DeleteExercisesFunc != nil {
		return m.DeleteExercisesFunc(ctx, sessionID, exerciseIDs)
	}
	return nil
}

func (m *MockSessionRepository) FinishSession(ctx context.Context, id, userID string, notes *string) (*repository.WorkoutSession, error) {
	if m.FinishSessionFunc != nil {
		return m.FinishSessionFunc(ctx, id, userID, notes)
	}
	return nil, nil
}

func (m *MockSessionRepository) AbandonSession(ctx context.Context, id, userID string) error {
	if m.AbandonSessionFunc != nil {
		return m.AbandonSessionFunc(ctx, id, userID)
	}
	return nil
}

func (m *MockSessionRepository) List(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
	if m.ListFunc != nil {
		return m.ListFunc(ctx, userID, status, startDate, endDate, limit, offset)
	}
	return nil, 0, nil
}

// MockWorkoutRepository is a mock implementation of WorkoutRepositoryInterface
type MockWorkoutRepository struct {
	ListFunc                 func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.WorkoutTemplate, int, error)
	GetByIDFunc              func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error)
	CreateFunc               func(ctx context.Context, userID, name string, description *string) (*repository.WorkoutTemplate, error)
	DeleteFunc               func(ctx context.Context, id, userID string) error
	UpdateWorkoutDetailsFunc func(ctx context.Context, id, name string, description *string, isArchived bool) (*repository.WorkoutTemplate, error)
	DeleteSectionsFunc       func(ctx context.Context, workoutID string) error
	CreateSectionFunc        func(ctx context.Context, workoutID, name string, displayOrder int, isSuperset bool) (*repository.WorkoutSection, error)
	CreateSectionItemFunc    func(ctx context.Context, sectionID, itemType string, displayOrder int, exerciseID *string, restDurationSeconds *int) (*repository.SectionItem, error)
	CreateTargetSetFunc      func(ctx context.Context, sectionItemID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, targetDistanceM *float64, isBodyweight bool, notes *string, restDurationSeconds *int) (*repository.ExerciseTargetSet, error)
}

func (m *MockWorkoutRepository) List(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.WorkoutTemplate, int, error) {
	if m.ListFunc != nil {
		return m.ListFunc(ctx, userID, includeArchived, limit, offset)
	}
	return nil, 0, nil
}

func (m *MockWorkoutRepository) GetByID(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
	if m.GetByIDFunc != nil {
		return m.GetByIDFunc(ctx, id, userID)
	}
	return nil, nil
}

func (m *MockWorkoutRepository) Create(ctx context.Context, userID, name string, description *string) (*repository.WorkoutTemplate, error) {
	if m.CreateFunc != nil {
		return m.CreateFunc(ctx, userID, name, description)
	}
	return nil, nil
}

func (m *MockWorkoutRepository) Delete(ctx context.Context, id, userID string) error {
	if m.DeleteFunc != nil {
		return m.DeleteFunc(ctx, id, userID)
	}
	return nil
}

func (m *MockWorkoutRepository) UpdateWorkoutDetails(ctx context.Context, id, name string, description *string, isArchived bool) (*repository.WorkoutTemplate, error) {
	if m.UpdateWorkoutDetailsFunc != nil {
		return m.UpdateWorkoutDetailsFunc(ctx, id, name, description, isArchived)
	}
	return nil, nil
}

func (m *MockWorkoutRepository) DeleteSections(ctx context.Context, workoutID string) error {
	if m.DeleteSectionsFunc != nil {
		return m.DeleteSectionsFunc(ctx, workoutID)
	}
	return nil
}

func (m *MockWorkoutRepository) CreateSection(ctx context.Context, workoutID, name string, displayOrder int, isSuperset bool) (*repository.WorkoutSection, error) {
	if m.CreateSectionFunc != nil {
		return m.CreateSectionFunc(ctx, workoutID, name, displayOrder, isSuperset)
	}
	return nil, nil
}

func (m *MockWorkoutRepository) CreateSectionItem(ctx context.Context, sectionID, itemType string, displayOrder int, exerciseID *string, restDurationSeconds *int) (*repository.SectionItem, error) {
	if m.CreateSectionItemFunc != nil {
		return m.CreateSectionItemFunc(ctx, sectionID, itemType, displayOrder, exerciseID, restDurationSeconds)
	}
	return nil, nil
}

func (m *MockWorkoutRepository) CreateTargetSet(ctx context.Context, sectionItemID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, targetDistanceM *float64, isBodyweight bool, notes *string, restDurationSeconds *int) (*repository.ExerciseTargetSet, error) {
	if m.CreateTargetSetFunc != nil {
		return m.CreateTargetSetFunc(ctx, sectionItemID, setNumber, targetWeightKg, targetReps, targetTimeSeconds, targetDistanceM, isBodyweight, notes, restDurationSeconds)
	}
	return nil, nil
}

// MockProgramRepository is a mock implementation of ProgramRepositoryInterface
type MockProgramRepository struct {
	ListFunc             func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.Program, int, error)
	GetByIDFunc          func(ctx context.Context, id, userID string) (*repository.Program, error)
	CreateFunc           func(ctx context.Context, userID, name string, description *string, durationWeeks, durationDays int) (*repository.Program, error)
	CreateDayFunc        func(ctx context.Context, programID string, dayNumber int, dayType string, workoutTemplateID, customName *string) (*repository.ProgramDay, error)
	SetActiveFunc        func(ctx context.Context, id, userID string) (*repository.Program, error)
	DeleteFunc           func(ctx context.Context, id, userID string) error
	GetActiveProgramFunc func(ctx context.Context, userID string) (*repository.Program, error)
}

func (m *MockProgramRepository) List(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.Program, int, error) {
	if m.ListFunc != nil {
		return m.ListFunc(ctx, userID, includeArchived, limit, offset)
	}
	return nil, 0, nil
}

func (m *MockProgramRepository) GetByID(ctx context.Context, id, userID string) (*repository.Program, error) {
	if m.GetByIDFunc != nil {
		return m.GetByIDFunc(ctx, id, userID)
	}
	return nil, nil
}

func (m *MockProgramRepository) Create(ctx context.Context, userID, name string, description *string, durationWeeks, durationDays int) (*repository.Program, error) {
	if m.CreateFunc != nil {
		return m.CreateFunc(ctx, userID, name, description, durationWeeks, durationDays)
	}
	return nil, nil
}

func (m *MockProgramRepository) CreateDay(ctx context.Context, programID string, dayNumber int, dayType string, workoutTemplateID, customName *string) (*repository.ProgramDay, error) {
	if m.CreateDayFunc != nil {
		return m.CreateDayFunc(ctx, programID, dayNumber, dayType, workoutTemplateID, customName)
	}
	return nil, nil
}

func (m *MockProgramRepository) SetActive(ctx context.Context, id, userID string) (*repository.Program, error) {
	if m.SetActiveFunc != nil {
		return m.SetActiveFunc(ctx, id, userID)
	}
	return nil, nil
}

func (m *MockProgramRepository) Delete(ctx context.Context, id, userID string) error {
	if m.DeleteFunc != nil {
		return m.DeleteFunc(ctx, id, userID)
	}
	return nil
}

func (m *MockProgramRepository) GetActiveProgram(ctx context.Context, userID string) (*repository.Program, error) {
	if m.GetActiveProgramFunc != nil {
		return m.GetActiveProgramFunc(ctx, userID)
	}
	return nil, nil
}

// MockProgressRepository is a mock implementation of ProgressRepositoryInterface
type MockProgressRepository struct {
	GetDashboardStatsFunc   func(ctx context.Context, userID string) (*repository.DashboardStats, error)
	GetWeeklyActivityFunc   func(ctx context.Context, userID string, weekStart *time.Time) ([]*repository.WeeklyActivityDay, error)
	GetPersonalRecordsFunc  func(ctx context.Context, userID string, limit int, exerciseID *string) ([]*repository.PersonalRecord, error)
	GetExerciseProgressFunc func(ctx context.Context, userID, exerciseID string, limit int) ([]*repository.ExerciseProgressPoint, error)
	GetStreakFunc           func(ctx context.Context, userID string) (int, int, *time.Time, error)
}

func (m *MockProgressRepository) GetDashboardStats(ctx context.Context, userID string) (*repository.DashboardStats, error) {
	if m.GetDashboardStatsFunc != nil {
		return m.GetDashboardStatsFunc(ctx, userID)
	}
	return nil, nil
}

func (m *MockProgressRepository) GetWeeklyActivity(ctx context.Context, userID string, weekStart *time.Time) ([]*repository.WeeklyActivityDay, error) {
	if m.GetWeeklyActivityFunc != nil {
		return m.GetWeeklyActivityFunc(ctx, userID, weekStart)
	}
	return nil, nil
}

func (m *MockProgressRepository) GetPersonalRecords(ctx context.Context, userID string, limit int, exerciseID *string) ([]*repository.PersonalRecord, error) {
	if m.GetPersonalRecordsFunc != nil {
		return m.GetPersonalRecordsFunc(ctx, userID, limit, exerciseID)
	}
	return nil, nil
}

func (m *MockProgressRepository) GetExerciseProgress(ctx context.Context, userID, exerciseID string, limit int) ([]*repository.ExerciseProgressPoint, error) {
	if m.GetExerciseProgressFunc != nil {
		return m.GetExerciseProgressFunc(ctx, userID, exerciseID, limit)
	}
	return nil, nil
}

func (m *MockProgressRepository) GetStreak(ctx context.Context, userID string) (int, int, *time.Time, error) {
	if m.GetStreakFunc != nil {
		return m.GetStreakFunc(ctx, userID)
	}
	return 0, 0, nil, nil
}

// MockAuthRepository is a mock implementation of AuthRepositoryInterface
type MockAuthRepository struct {
	GetByEmailFunc func(ctx context.Context, email string) (*repository.User, error)
	CreateFunc     func(ctx context.Context, email string) (*repository.User, error)
}

func (m *MockAuthRepository) GetByEmail(ctx context.Context, email string) (*repository.User, error) {
	if m.GetByEmailFunc != nil {
		return m.GetByEmailFunc(ctx, email)
	}
	return nil, nil
}

func (m *MockAuthRepository) Create(ctx context.Context, email string) (*repository.User, error) {
	if m.CreateFunc != nil {
		return m.CreateFunc(ctx, email)
	}
	return nil, nil
}

// Compile-time interface compliance checks
var _ repository.UserRepositoryInterface = (*MockUserRepository)(nil)
var _ repository.ExerciseRepositoryInterface = (*MockExerciseRepository)(nil)
var _ repository.SessionRepositoryInterface = (*MockSessionRepository)(nil)
var _ repository.WorkoutRepositoryInterface = (*MockWorkoutRepository)(nil)
var _ repository.ProgramRepositoryInterface = (*MockProgramRepository)(nil)
var _ repository.ProgressRepositoryInterface = (*MockProgressRepository)(nil)
var _ repository.AuthRepositoryInterface = (*MockAuthRepository)(nil)
