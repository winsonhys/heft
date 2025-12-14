package handlers_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/repository"
	"github.com/heftyback/internal/testutil"
)

func TestProgressHandler_GetDashboardStats(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		setupMock    func(*testutil.MockProgressRepository, *testutil.MockExerciseRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetDashboardStatsResponse)
	}{
		{
			name:     "success - returns dashboard stats",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetDashboardStatsFunc = func(ctx context.Context, userID string) (*repository.DashboardStats, error) {
					return &repository.DashboardStats{
						TotalWorkouts:    50,
						WorkoutsThisWeek: 3,
						CurrentStreak:    5,
						TotalVolumeKg:    25000,
						DaysActive:       45,
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetDashboardStatsResponse) {
				assert.Equal(t, int32(50), resp.Stats.TotalWorkouts)
				assert.Equal(t, int32(3), resp.Stats.WorkoutsThisWeek)
				assert.Equal(t, int32(5), resp.Stats.CurrentStreak)
				assert.Equal(t, int32(25000), resp.Stats.TotalVolumeKg)
				assert.Equal(t, int32(45), resp.Stats.DaysActive)
			},
		},
		{
			name:     "success - zero stats for new user",
			userID:   "user-new",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetDashboardStatsFunc = func(ctx context.Context, userID string) (*repository.DashboardStats, error) {
					return &repository.DashboardStats{
						TotalWorkouts:    0,
						WorkoutsThisWeek: 0,
						CurrentStreak:    0,
						TotalVolumeKg:    0,
						DaysActive:       0,
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetDashboardStatsResponse) {
				assert.Equal(t, int32(0), resp.Stats.TotalWorkouts)
				assert.Equal(t, int32(0), resp.Stats.CurrentStreak)
			},
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetDashboardStatsFunc = func(ctx context.Context, userID string) (*repository.DashboardStats, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgressRepo := &testutil.MockProgressRepository{}
			mockExerciseRepo := &testutil.MockExerciseRepository{}
			tt.setupMock(mockProgressRepo, mockExerciseRepo)

			handler := handlers.NewProgressHandler(mockProgressRepo, mockExerciseRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.GetDashboardStatsRequest{})
			resp, err := handler.GetDashboardStats(ctx, req)

			if tt.wantErr {
				require.Error(t, err)
				var connectErr *connect.Error
				require.True(t, errors.As(err, &connectErr))
				assert.Equal(t, tt.wantCode, connectErr.Code())
				return
			}

			require.NoError(t, err)
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestProgressHandler_GetWeeklyActivity(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		setupMock    func(*testutil.MockProgressRepository, *testutil.MockExerciseRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetWeeklyActivityResponse)
	}{
		{
			name:     "success - returns weekly activity",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetWeeklyActivityFunc = func(ctx context.Context, userID string, weekStart *time.Time) ([]*repository.WeeklyActivityDay, error) {
					now := time.Now()
					return []*repository.WeeklyActivityDay{
						{Date: now.AddDate(0, 0, -6), DayOfWeek: "Mon", WorkoutCount: 1, IsToday: false},
						{Date: now.AddDate(0, 0, -5), DayOfWeek: "Tue", WorkoutCount: 0, IsToday: false},
						{Date: now.AddDate(0, 0, -4), DayOfWeek: "Wed", WorkoutCount: 1, IsToday: false},
						{Date: now.AddDate(0, 0, -3), DayOfWeek: "Thu", WorkoutCount: 0, IsToday: false},
						{Date: now.AddDate(0, 0, -2), DayOfWeek: "Fri", WorkoutCount: 1, IsToday: false},
						{Date: now.AddDate(0, 0, -1), DayOfWeek: "Sat", WorkoutCount: 0, IsToday: false},
						{Date: now, DayOfWeek: "Sun", WorkoutCount: 0, IsToday: true},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetWeeklyActivityResponse) {
				assert.Len(t, resp.Days, 7)
				assert.Equal(t, int32(3), resp.TotalWorkouts)
				// Check that one day is marked as today
				var todayFound bool
				for _, day := range resp.Days {
					if day.IsToday {
						todayFound = true
						break
					}
				}
				assert.True(t, todayFound)
			},
		},
		{
			name:     "success - empty week",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetWeeklyActivityFunc = func(ctx context.Context, userID string, weekStart *time.Time) ([]*repository.WeeklyActivityDay, error) {
					return []*repository.WeeklyActivityDay{}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetWeeklyActivityResponse) {
				assert.Empty(t, resp.Days)
				assert.Equal(t, int32(0), resp.TotalWorkouts)
			},
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetWeeklyActivityFunc = func(ctx context.Context, userID string, weekStart *time.Time) ([]*repository.WeeklyActivityDay, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgressRepo := &testutil.MockProgressRepository{}
			mockExerciseRepo := &testutil.MockExerciseRepository{}
			tt.setupMock(mockProgressRepo, mockExerciseRepo)

			handler := handlers.NewProgressHandler(mockProgressRepo, mockExerciseRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.GetWeeklyActivityRequest{})
			resp, err := handler.GetWeeklyActivity(ctx, req)

			if tt.wantErr {
				require.Error(t, err)
				var connectErr *connect.Error
				require.True(t, errors.As(err, &connectErr))
				assert.Equal(t, tt.wantCode, connectErr.Code())
				return
			}

			require.NoError(t, err)
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestProgressHandler_GetPersonalRecords(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		exerciseID   *string
		limit        *int32
		setupMock    func(*testutil.MockProgressRepository, *testutil.MockExerciseRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetPersonalRecordsResponse)
	}{
		{
			name:     "success - returns personal records",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				weight := 100.0
				reps := 5
				oneRepMax := 112.5
				mp.GetPersonalRecordsFunc = func(ctx context.Context, userID string, limit int, exerciseID *string) ([]*repository.PersonalRecord, error) {
					return []*repository.PersonalRecord{
						{
							ID:           "pr-1",
							UserID:       userID,
							ExerciseID:   "exercise-1",
							ExerciseName: "Bench Press",
							WeightKg:     &weight,
							Reps:         &reps,
							OneRepMaxKg:  &oneRepMax,
							AchievedAt:   time.Now(),
						},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetPersonalRecordsResponse) {
				assert.Len(t, resp.Records, 1)
				assert.Equal(t, "Bench Press", resp.Records[0].ExerciseName)
				assert.Equal(t, float64(100), resp.Records[0].WeightKg)
				assert.Equal(t, int32(5), resp.Records[0].Reps)
			},
		},
		{
			name:       "success - with exercise filter",
			userID:     "user-123",
			withAuth:   true,
			exerciseID: ptrString("exercise-1"),
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				weight := 140.0
				mp.GetPersonalRecordsFunc = func(ctx context.Context, userID string, limit int, exerciseID *string) ([]*repository.PersonalRecord, error) {
					assert.NotNil(t, exerciseID)
					assert.Equal(t, "exercise-1", *exerciseID)
					return []*repository.PersonalRecord{
						{
							ID:           "pr-1",
							UserID:       userID,
							ExerciseID:   "exercise-1",
							ExerciseName: "Squat",
							WeightKg:     &weight,
							AchievedAt:   time.Now(),
						},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetPersonalRecordsResponse) {
				assert.Len(t, resp.Records, 1)
				assert.Equal(t, "Squat", resp.Records[0].ExerciseName)
			},
		},
		{
			name:     "success - with custom limit",
			userID:   "user-123",
			withAuth: true,
			limit:    ptrInt32(5),
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetPersonalRecordsFunc = func(ctx context.Context, userID string, limit int, exerciseID *string) ([]*repository.PersonalRecord, error) {
					assert.Equal(t, 5, limit)
					return []*repository.PersonalRecord{}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetPersonalRecordsResponse) {
				assert.Empty(t, resp.Records)
			},
		},
		{
			name:     "success - empty records",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetPersonalRecordsFunc = func(ctx context.Context, userID string, limit int, exerciseID *string) ([]*repository.PersonalRecord, error) {
					return []*repository.PersonalRecord{}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetPersonalRecordsResponse) {
				assert.Empty(t, resp.Records)
			},
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetPersonalRecordsFunc = func(ctx context.Context, userID string, limit int, exerciseID *string) ([]*repository.PersonalRecord, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgressRepo := &testutil.MockProgressRepository{}
			mockExerciseRepo := &testutil.MockExerciseRepository{}
			tt.setupMock(mockProgressRepo, mockExerciseRepo)

			handler := handlers.NewProgressHandler(mockProgressRepo, mockExerciseRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.GetPersonalRecordsRequest{
				ExerciseId: tt.exerciseID,
				Limit:      tt.limit,
			})
			resp, err := handler.GetPersonalRecords(ctx, req)

			if tt.wantErr {
				require.Error(t, err)
				var connectErr *connect.Error
				require.True(t, errors.As(err, &connectErr))
				assert.Equal(t, tt.wantCode, connectErr.Code())
				return
			}

			require.NoError(t, err)
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestProgressHandler_GetExerciseProgress(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		exerciseID   string
		limit        *int32
		setupMock    func(*testutil.MockProgressRepository, *testutil.MockExerciseRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetExerciseProgressResponse)
	}{
		{
			name:       "success - returns exercise progress",
			userID:     "user-123",
			withAuth:   true,
			exerciseID: "exercise-1",
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				weight1 := 80.0
				weight2 := 85.0
				weight3 := 90.0
				mp.GetExerciseProgressFunc = func(ctx context.Context, userID, exerciseID string, limit int) ([]*repository.ExerciseProgressPoint, error) {
					return []*repository.ExerciseProgressPoint{
						{Date: time.Now(), BestWeightKg: &weight3, TotalSets: 3},
						{Date: time.Now().AddDate(0, 0, -7), BestWeightKg: &weight2, TotalSets: 3},
						{Date: time.Now().AddDate(0, 0, -14), BestWeightKg: &weight1, TotalSets: 3},
					}, nil
				}
				me.GetByIDFunc = func(ctx context.Context, id string) (*repository.Exercise, error) {
					return &repository.Exercise{
						ID:           id,
						Name:         "Bench Press",
						ExerciseType: "weight_reps",
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetExerciseProgressResponse) {
				assert.Equal(t, "Bench Press", resp.Progress.ExerciseName)
				assert.Equal(t, int32(3), resp.Progress.TotalSessions)
				assert.Equal(t, float64(80), resp.Progress.StartingWeightKg)
				assert.Equal(t, float64(90), resp.Progress.CurrentWeightKg)
				assert.Equal(t, float64(90), resp.Progress.MaxWeightKg)
				assert.Greater(t, resp.Progress.ImprovementPercent, float64(0))
			},
		},
		{
			name:       "success - with custom limit",
			userID:     "user-123",
			withAuth:   true,
			exerciseID: "exercise-1",
			limit:      ptrInt32(4),
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetExerciseProgressFunc = func(ctx context.Context, userID, exerciseID string, limit int) ([]*repository.ExerciseProgressPoint, error) {
					assert.Equal(t, 4, limit)
					return []*repository.ExerciseProgressPoint{}, nil
				}
				me.GetByIDFunc = func(ctx context.Context, id string) (*repository.Exercise, error) {
					return &repository.Exercise{ID: id, Name: "Test"}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetExerciseProgressResponse) {
				assert.Equal(t, int32(0), resp.Progress.TotalSessions)
			},
		},
		{
			name:       "success - no data points",
			userID:     "user-123",
			withAuth:   true,
			exerciseID: "exercise-1",
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetExerciseProgressFunc = func(ctx context.Context, userID, exerciseID string, limit int) ([]*repository.ExerciseProgressPoint, error) {
					return []*repository.ExerciseProgressPoint{}, nil
				}
				me.GetByIDFunc = func(ctx context.Context, id string) (*repository.Exercise, error) {
					return &repository.Exercise{ID: id, Name: "Squat"}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetExerciseProgressResponse) {
				assert.Equal(t, "Squat", resp.Progress.ExerciseName)
				assert.Equal(t, int32(0), resp.Progress.TotalSessions)
			},
		},
		{
			name:       "error - not authenticated",
			userID:     "",
			withAuth:   false,
			exerciseID: "exercise-1",
			setupMock:  func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {},
			wantErr:    true,
			wantCode:   connect.CodeUnauthenticated,
		},
		{
			name:       "error - missing exercise_id",
			userID:     "user-123",
			withAuth:   true,
			exerciseID: "",
			setupMock:  func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {},
			wantErr:    true,
			wantCode:   connect.CodeInvalidArgument,
		},
		{
			name:       "error - database error on progress",
			userID:     "user-123",
			withAuth:   true,
			exerciseID: "exercise-1",
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetExerciseProgressFunc = func(ctx context.Context, userID, exerciseID string, limit int) ([]*repository.ExerciseProgressPoint, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
		{
			name:       "error - database error on exercise lookup",
			userID:     "user-123",
			withAuth:   true,
			exerciseID: "exercise-1",
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetExerciseProgressFunc = func(ctx context.Context, userID, exerciseID string, limit int) ([]*repository.ExerciseProgressPoint, error) {
					return []*repository.ExerciseProgressPoint{}, nil
				}
				me.GetByIDFunc = func(ctx context.Context, id string) (*repository.Exercise, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgressRepo := &testutil.MockProgressRepository{}
			mockExerciseRepo := &testutil.MockExerciseRepository{}
			tt.setupMock(mockProgressRepo, mockExerciseRepo)

			handler := handlers.NewProgressHandler(mockProgressRepo, mockExerciseRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.GetExerciseProgressRequest{
				ExerciseId: tt.exerciseID,
				Limit:      tt.limit,
			})
			resp, err := handler.GetExerciseProgress(ctx, req)

			if tt.wantErr {
				require.Error(t, err)
				var connectErr *connect.Error
				require.True(t, errors.As(err, &connectErr))
				assert.Equal(t, tt.wantCode, connectErr.Code())
				return
			}

			require.NoError(t, err)
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestProgressHandler_GetStreak(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		setupMock    func(*testutil.MockProgressRepository, *testutil.MockExerciseRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetStreakResponse)
	}{
		{
			name:     "success - has active streak",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				lastWorkout := time.Now().AddDate(0, 0, -1)
				mp.GetStreakFunc = func(ctx context.Context, userID string) (int, int, *time.Time, error) {
					return 5, 10, &lastWorkout, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetStreakResponse) {
				assert.Equal(t, int32(5), resp.CurrentStreak)
				assert.Equal(t, int32(10), resp.LongestStreak)
				assert.NotEmpty(t, resp.LastWorkoutDate)
			},
		},
		{
			name:     "success - no workouts yet",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetStreakFunc = func(ctx context.Context, userID string) (int, int, *time.Time, error) {
					return 0, 0, nil, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetStreakResponse) {
				assert.Equal(t, int32(0), resp.CurrentStreak)
				assert.Equal(t, int32(0), resp.LongestStreak)
				assert.Empty(t, resp.LastWorkoutDate)
			},
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {
				mp.GetStreakFunc = func(ctx context.Context, userID string) (int, int, *time.Time, error) {
					return 0, 0, nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgressRepo := &testutil.MockProgressRepository{}
			mockExerciseRepo := &testutil.MockExerciseRepository{}
			tt.setupMock(mockProgressRepo, mockExerciseRepo)

			handler := handlers.NewProgressHandler(mockProgressRepo, mockExerciseRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.GetStreakRequest{})
			resp, err := handler.GetStreak(ctx, req)

			if tt.wantErr {
				require.Error(t, err)
				var connectErr *connect.Error
				require.True(t, errors.As(err, &connectErr))
				assert.Equal(t, tt.wantCode, connectErr.Code())
				return
			}

			require.NoError(t, err)
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestProgressHandler_GetCalendarMonth(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		year         int32
		month        int32
		setupMock    func(*testutil.MockProgressRepository, *testutil.MockExerciseRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetCalendarMonthResponse)
	}{
		{
			name:     "success - returns empty calendar (current implementation)",
			userID:   "user-123",
			withAuth: true,
			year:     2024,
			month:    12,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {},
			validateResp: func(t *testing.T, resp *heftv1.GetCalendarMonthResponse) {
				// Current implementation returns empty
				assert.Empty(t, resp.Days)
				assert.Equal(t, int32(0), resp.TotalWorkouts)
				assert.Equal(t, int32(0), resp.TotalRestDays)
			},
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			year:      2024,
			month:     12,
			setupMock: func(mp *testutil.MockProgressRepository, me *testutil.MockExerciseRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgressRepo := &testutil.MockProgressRepository{}
			mockExerciseRepo := &testutil.MockExerciseRepository{}
			tt.setupMock(mockProgressRepo, mockExerciseRepo)

			handler := handlers.NewProgressHandler(mockProgressRepo, mockExerciseRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.GetCalendarMonthRequest{
				Year:  tt.year,
				Month: tt.month,
			})
			resp, err := handler.GetCalendarMonth(ctx, req)

			if tt.wantErr {
				require.Error(t, err)
				var connectErr *connect.Error
				require.True(t, errors.As(err, &connectErr))
				assert.Equal(t, tt.wantCode, connectErr.Code())
				return
			}

			require.NoError(t, err)
			tt.validateResp(t, resp.Msg)
		})
	}
}
