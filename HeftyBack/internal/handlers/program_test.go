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


func TestProgramHandler_ListPrograms(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.ListProgramsRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.ListProgramsResponse)
	}{
		{
			name:     "success - returns programs with pagination",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.ListProgramsRequest{
				Pagination: &heftv1.PaginationRequest{
					Page:     1,
					PageSize: 10,
				},
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.Program, int, error) {
					return []*repository.Program{
						{
							ID:               "program-1",
							UserID:           userID,
							Name:             "5x5 Strength",
							DurationWeeks:    12,
							DurationDays:     0,
							TotalWorkoutDays: 36,
							TotalRestDays:    48,
							CreatedAt:        time.Now(),
							UpdatedAt:        time.Now(),
						},
						{
							ID:               "program-2",
							UserID:           userID,
							Name:             "PPL Split",
							DurationWeeks:    8,
							TotalWorkoutDays: 24,
							CreatedAt:        time.Now(),
							UpdatedAt:        time.Now(),
						},
					}, 2, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.ListProgramsResponse) {
				assert.Len(t, resp.Programs, 2)
				assert.Equal(t, "5x5 Strength", resp.Programs[0].Name)
				assert.Equal(t, "PPL Split", resp.Programs[1].Name)
				assert.Equal(t, int32(2), resp.Pagination.TotalCount)
			},
		},
		{
			name:     "success - empty list",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.ListProgramsRequest{},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.Program, int, error) {
					return []*repository.Program{}, 0, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.ListProgramsResponse) {
				assert.Empty(t, resp.Programs)
				assert.Equal(t, int32(0), resp.Pagination.TotalCount)
			},
		},
		{
			name:     "success - includes archived",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.ListProgramsRequest{
				IncludeArchived: ptrBool(true),
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.Program, int, error) {
					assert.True(t, includeArchived)
					return []*repository.Program{
						{
							ID:         "program-1",
							UserID:     userID,
							Name:       "Archived Program",
							IsArchived: true,
							CreatedAt:  time.Now(),
							UpdatedAt:  time.Now(),
						},
					}, 1, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.ListProgramsResponse) {
				assert.Len(t, resp.Programs, 1)
				assert.True(t, resp.Programs[0].IsArchived)
			},
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.ListProgramsRequest{},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.ListProgramsRequest{},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.Program, int, error) {
					return nil, 0, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			handler := handlers.NewProgramHandler(mockProgramRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.ListPrograms(ctx, connect.NewRequest(tt.request))

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

func TestProgramHandler_GetProgram(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.GetProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetProgramResponse)
	}{
		{
			name:     "success - returns program with days",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetProgramRequest{
				Id: "program-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					workoutID := "workout-1"
					return &repository.Program{
						ID:               id,
						UserID:           userID,
						Name:             "5x5 Strength",
						DurationWeeks:    12,
						TotalWorkoutDays: 36,
						CreatedAt:        time.Now(),
						UpdatedAt:        time.Now(),
						Days: []*repository.ProgramDay{
							{
								ID:                "day-1",
								ProgramID:         id,
								DayNumber:         1,
								DayType:           "workout",
								WorkoutTemplateID: &workoutID,
								WorkoutName:       ptrString("Push Day"),
							},
							{
								ID:        "day-2",
								ProgramID: id,
								DayNumber: 2,
								DayType:   "rest",
							},
						},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetProgramResponse) {
				assert.Equal(t, "program-123", resp.Program.Id)
				assert.Equal(t, "5x5 Strength", resp.Program.Name)
				assert.Len(t, resp.Program.Days, 2)
				assert.Equal(t, heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT, resp.Program.Days[0].DayType)
				assert.Equal(t, heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST, resp.Program.Days[1].DayType)
			},
		},
		{
			name:     "error - program not found",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetProgramRequest{
				Id: "nonexistent",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					return nil, nil
				}
			},
			wantErr:  true,
			wantCode: connect.CodeNotFound,
		},
		{
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetProgramRequest{
				Id: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.GetProgramRequest{Id: "program-123"},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			handler := handlers.NewProgramHandler(mockProgramRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.GetProgram(ctx, connect.NewRequest(tt.request))

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

func TestProgramHandler_CreateProgram(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.CreateProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.CreateProgramResponse)
	}{
		{
			name:     "success - creates basic program",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CreateProgramRequest{
				Name:          "New Program",
				Description:   ptrString("A test program"),
				DurationWeeks: 4,
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.CreateFunc = func(ctx context.Context, userID, name string, description *string, durationWeeks, durationDays int) (*repository.Program, error) {
					return &repository.Program{
						ID:            "program-new",
						UserID:        userID,
						Name:          name,
						Description:   description,
						DurationWeeks: durationWeeks,
						DurationDays:  durationDays,
						CreatedAt:     time.Now(),
						UpdatedAt:     time.Now(),
					}, nil
				}
				mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:            id,
						UserID:        userID,
						Name:          "New Program",
						DurationWeeks: 4,
						CreatedAt:     time.Now(),
						UpdatedAt:     time.Now(),
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.CreateProgramResponse) {
				assert.Equal(t, "program-new", resp.Program.Id)
				assert.Equal(t, "New Program", resp.Program.Name)
				assert.Equal(t, int32(4), resp.Program.DurationWeeks)
			},
		},
		{
			name:     "success - creates program with days",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CreateProgramRequest{
				Name:          "Weekly Program",
				DurationWeeks: 1,
				Days: []*heftv1.CreateProgramDay{
					{
						DayNumber:         1,
						DayType:           heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT,
						WorkoutTemplateId: ptrString("workout-1"),
					},
					{
						DayNumber: 2,
						DayType:   heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST,
					},
				},
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.CreateFunc = func(ctx context.Context, userID, name string, description *string, durationWeeks, durationDays int) (*repository.Program, error) {
					return &repository.Program{
						ID:            "program-weekly",
						UserID:        userID,
						Name:          name,
						DurationWeeks: durationWeeks,
						CreatedAt:     time.Now(),
						UpdatedAt:     time.Now(),
					}, nil
				}
				mp.CreateDayFunc = func(ctx context.Context, programID string, dayNumber int, dayType string, workoutTemplateID, customName *string) (*repository.ProgramDay, error) {
					return &repository.ProgramDay{
						ID:                "day-" + string(rune(dayNumber)),
						ProgramID:         programID,
						DayNumber:         dayNumber,
						DayType:           dayType,
						WorkoutTemplateID: workoutTemplateID,
					}, nil
				}
				mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					workoutID := "workout-1"
					return &repository.Program{
						ID:            id,
						UserID:        userID,
						Name:          "Weekly Program",
						DurationWeeks: 1,
						CreatedAt:     time.Now(),
						UpdatedAt:     time.Now(),
						Days: []*repository.ProgramDay{
							{ID: "day-1", DayNumber: 1, DayType: "workout", WorkoutTemplateID: &workoutID},
							{ID: "day-2", DayNumber: 2, DayType: "rest"},
						},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.CreateProgramResponse) {
				assert.Equal(t, "Weekly Program", resp.Program.Name)
				assert.Len(t, resp.Program.Days, 2)
			},
		},
		{
			name:     "error - not authenticated",
			userID:   "",
			withAuth: false,
			request: &heftv1.CreateProgramRequest{
				Name: "Test",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - missing name",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CreateProgramRequest{
				Name: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:     "error - database error on create",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CreateProgramRequest{
				Name: "Test",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.CreateFunc = func(ctx context.Context, userID, name string, description *string, durationWeeks, durationDays int) (*repository.Program, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			handler := handlers.NewProgramHandler(mockProgramRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.CreateProgram(ctx, connect.NewRequest(tt.request))

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

func TestProgramHandler_DeleteProgram(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.DeleteProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.DeleteProgramResponse)
	}{
		{
			name:     "success - deletes program",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DeleteProgramRequest{
				Id: "program-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.DeleteFunc = func(ctx context.Context, id, userID string) error {
					return nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.DeleteProgramResponse) {
				assert.True(t, resp.Success)
			},
		},
		{
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DeleteProgramRequest{
				Id: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.DeleteProgramRequest{Id: "program-123"},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DeleteProgramRequest{
				Id: "program-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.DeleteFunc = func(ctx context.Context, id, userID string) error {
					return errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			handler := handlers.NewProgramHandler(mockProgramRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.DeleteProgram(ctx, connect.NewRequest(tt.request))

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

func TestProgramHandler_SetActiveProgram(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.SetActiveProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.SetActiveProgramResponse)
	}{
		{
			name:     "success - sets program as active",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.SetActiveProgramRequest{
				Id: "program-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.SetActiveFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:       id,
						UserID:   userID,
						Name:     "Active Program",
						IsActive: true,
					}, nil
				}
				mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:        id,
						UserID:    userID,
						Name:      "Active Program",
						IsActive:  true,
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.SetActiveProgramResponse) {
				assert.Equal(t, "program-123", resp.Program.Id)
				assert.True(t, resp.Program.IsActive)
			},
		},
		{
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.SetActiveProgramRequest{
				Id: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.SetActiveProgramRequest{Id: "program-123"},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.SetActiveProgramRequest{
				Id: "program-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.SetActiveFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			handler := handlers.NewProgramHandler(mockProgramRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.SetActiveProgram(ctx, connect.NewRequest(tt.request))

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

func TestProgramHandler_GetTodayWorkout(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.GetTodayWorkoutRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetTodayWorkoutResponse)
	}{
		{
			name:     "success - has workout today",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.GetTodayWorkoutRequest{},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				workoutID := "workout-1"
				mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:            "program-1",
						UserID:        userID,
						Name:          "Active Program",
						DurationWeeks: 1,
						DurationDays:  0,
						IsActive:      true,
						Days: []*repository.ProgramDay{
							{
								ID:                "day-1",
								ProgramID:         "program-1",
								DayNumber:         1,
								DayType:           "workout",
								WorkoutTemplateID: &workoutID,
								WorkoutName:       ptrString("Push Day"),
							},
						},
					}, nil
				}
				mw.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:     id,
						UserID: userID,
						Name:   "Push Day",
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetTodayWorkoutResponse) {
				assert.True(t, resp.HasWorkout)
				assert.Equal(t, int32(1), resp.DayNumber)
				assert.Equal(t, heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT, resp.DayType)
				assert.NotNil(t, resp.Workout)
			},
		},
		{
			name:     "success - rest day",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.GetTodayWorkoutRequest{},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:            "program-1",
						UserID:        userID,
						Name:          "Active Program",
						DurationWeeks: 1,
						IsActive:      true,
						Days: []*repository.ProgramDay{
							{
								ID:        "day-1",
								ProgramID: "program-1",
								DayNumber: 1,
								DayType:   "rest",
							},
						},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetTodayWorkoutResponse) {
				assert.False(t, resp.HasWorkout)
				assert.Equal(t, heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST, resp.DayType)
			},
		},
		{
			name:     "success - no active program",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.GetTodayWorkoutRequest{},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
					return nil, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetTodayWorkoutResponse) {
				assert.False(t, resp.HasWorkout)
			},
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.GetTodayWorkoutRequest{},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.GetTodayWorkoutRequest{},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			handler := handlers.NewProgramHandler(mockProgramRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.GetTodayWorkout(ctx, connect.NewRequest(tt.request))

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

func TestProgramHandler_GetTodayWorkout_DayCalculation(t *testing.T) {
	tests := []struct {
		name          string
		setupMock     func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantDayNumber int32
	}{
		{
			name: "started today returns day 1",
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				now := time.Now()
				mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:            "program-1",
						UserID:        userID,
						Name:          "Test Program",
						DurationWeeks: 1,
						DurationDays:  0,
						IsActive:      true,
						StartedAt:     &now,
						CreatedAt:     now,
						UpdatedAt:     now,
						Days: []*repository.ProgramDay{
							{
								ID:        "day-1",
								ProgramID: "program-1",
								DayNumber: 1,
								DayType:   "rest",
								CreatedAt: now,
							},
						},
					}, nil
				}
			},
			wantDayNumber: 1,
		},
		{
			name: "started 3 days ago returns day 4",
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				now := time.Now()
				startedAt := now.Add(-3 * 24 * time.Hour)
				workoutTemplateID := "workout-1"
				mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:            "program-1",
						UserID:        userID,
						Name:          "Test Program",
						DurationWeeks: 1,
						DurationDays:  0,
						IsActive:      true,
						StartedAt:     &startedAt,
						CreatedAt:     now,
						UpdatedAt:     now,
						Days: []*repository.ProgramDay{
							{
								ID:                "day-4",
								ProgramID:         "program-1",
								DayNumber:         4,
								DayType:           "workout",
								WorkoutTemplateID: &workoutTemplateID,
								CreatedAt:         now,
							},
						},
					}, nil
				}
				mw.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:     id,
						UserID: userID,
						Name:   "Push Day",
					}, nil
				}
			},
			wantDayNumber: 4,
		},
		{
			name: "nil started_at returns day 1",
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				now := time.Now()
				mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:            "program-1",
						UserID:        userID,
						Name:          "Test Program",
						DurationWeeks: 1,
						DurationDays:  0,
						IsActive:      true,
						StartedAt:     nil,
						CreatedAt:     now,
						UpdatedAt:     now,
						Days: []*repository.ProgramDay{
							{
								ID:        "day-1",
								ProgramID: "program-1",
								DayNumber: 1,
								DayType:   "rest",
								CreatedAt: now,
							},
						},
					}, nil
				}
			},
			wantDayNumber: 1,
		},
		{
			name: "past program duration clamps to last day",
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				now := time.Now()
				startedAt := now.Add(-10 * 24 * time.Hour)
				mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:            "program-1",
						UserID:        userID,
						Name:          "Test Program",
						DurationWeeks: 1,
						DurationDays:  0,
						IsActive:      true,
						StartedAt:     &startedAt,
						CreatedAt:     now,
						UpdatedAt:     now,
						Days: []*repository.ProgramDay{
							{
								ID:        "day-7",
								ProgramID: "program-1",
								DayNumber: 7,
								DayType:   "rest",
								CreatedAt: now,
							},
						},
					}, nil
				}
			},
			wantDayNumber: 7,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			handler := handlers.NewProgramHandler(mockProgramRepo, mockWorkoutRepo)

			ctx := auth.ContextWithUserID(context.Background(), "user-123")

			resp, err := handler.GetTodayWorkout(ctx, connect.NewRequest(&heftv1.GetTodayWorkoutRequest{}))

			require.NoError(t, err)
			assert.Equal(t, tt.wantDayNumber, resp.Msg.DayNumber)
		})
	}
}

func TestProgramHandler_UpdateProgram(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.UpdateProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.UpdateProgramResponse)
	}{
		{
			name:     "success - updates name",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.UpdateProgramRequest{
				Id:   "program-123",
				Name: ptrString("New Name"),
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.UpdateFunc = func(ctx context.Context, id, userID string, name *string, description *string, durationWeeks *int, durationDays *int, isArchived *bool, totalWorkoutDays *int, totalRestDays *int) (*repository.Program, error) {
					require.NotNil(t, name)
					assert.Equal(t, "New Name", *name)
					return &repository.Program{
						ID:        id,
						UserID:    userID,
						Name:      "New Name",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
				mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:        id,
						UserID:    userID,
						Name:      "New Name",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
						Days:      []*repository.ProgramDay{},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.UpdateProgramResponse) {
				assert.Equal(t, "program-123", resp.Program.Id)
				assert.Equal(t, "New Name", resp.Program.Name)
			},
		},
		{
			name:     "success - replaces days",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.UpdateProgramRequest{
				Id: "program-123",
				Days: []*heftv1.CreateProgramDay{
					{DayNumber: 1, DayType: heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT},
					{DayNumber: 2, DayType: heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST},
				},
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.UpdateFunc = func(ctx context.Context, id, userID string, name *string, description *string, durationWeeks *int, durationDays *int, isArchived *bool, totalWorkoutDays *int, totalRestDays *int) (*repository.Program, error) {
					require.NotNil(t, totalWorkoutDays)
					require.NotNil(t, totalRestDays)
					assert.Equal(t, 1, *totalWorkoutDays)
					assert.Equal(t, 1, *totalRestDays)
					return &repository.Program{
						ID:        id,
						UserID:    userID,
						Name:      "Program",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
				mp.DeleteDaysFunc = func(ctx context.Context, programID, userID string) error {
					return nil
				}
				mp.CreateDayFunc = func(ctx context.Context, programID string, dayNumber int, dayType string, workoutTemplateID, customName *string) (*repository.ProgramDay, error) {
					return &repository.ProgramDay{
						ID:        "day-" + string(rune(dayNumber)),
						ProgramID: programID,
						DayNumber: dayNumber,
						DayType:   dayType,
					}, nil
				}
				mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:        id,
						UserID:    userID,
						Name:      "Program",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
						Days: []*repository.ProgramDay{
							{ID: "day-1", DayNumber: 1, DayType: "workout"},
							{ID: "day-2", DayNumber: 2, DayType: "rest"},
						},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.UpdateProgramResponse) {
				assert.Len(t, resp.Program.Days, 2)
			},
		},
		{
			name:     "success - no days in request, days unchanged",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.UpdateProgramRequest{
				Id:   "program-123",
				Name: ptrString("Same Days"),
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				deleteDaysCalled := false
				mp.UpdateFunc = func(ctx context.Context, id, userID string, name *string, description *string, durationWeeks *int, durationDays *int, isArchived *bool, totalWorkoutDays *int, totalRestDays *int) (*repository.Program, error) {
					assert.Nil(t, totalWorkoutDays, "totalWorkoutDays should be nil when no days in request")
					assert.Nil(t, totalRestDays, "totalRestDays should be nil when no days in request")
					return &repository.Program{
						ID:        id,
						UserID:    userID,
						Name:      "Same Days",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
				mp.DeleteDaysFunc = func(ctx context.Context, programID, userID string) error {
					deleteDaysCalled = true
					return nil
				}
				mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					assert.False(t, deleteDaysCalled, "DeleteDays should NOT be called when no days in request")
					return &repository.Program{
						ID:        id,
						UserID:    userID,
						Name:      "Same Days",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
						Days: []*repository.ProgramDay{
							{ID: "day-1", DayNumber: 1, DayType: "workout"},
							{ID: "day-2", DayNumber: 2, DayType: "rest"},
							{ID: "day-3", DayNumber: 3, DayType: "rest"},
						},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.UpdateProgramResponse) {
				assert.Len(t, resp.Program.Days, 3)
			},
		},
		{
			name:     "error - Update DB error",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.UpdateProgramRequest{
				Id:   "program-123",
				Name: ptrString("New Name"),
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.UpdateFunc = func(ctx context.Context, id, userID string, name *string, description *string, durationWeeks *int, durationDays *int, isArchived *bool, totalWorkoutDays *int, totalRestDays *int) (*repository.Program, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
		{
			name:     "error - program not found",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.UpdateProgramRequest{
				Id: "nonexistent",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.UpdateFunc = func(ctx context.Context, id, userID string, name *string, description *string, durationWeeks *int, durationDays *int, isArchived *bool, totalWorkoutDays *int, totalRestDays *int) (*repository.Program, error) {
					return nil, nil
				}
			},
			wantErr:  true,
			wantCode: connect.CodeNotFound,
		},
		{
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.UpdateProgramRequest{
				Id: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.UpdateProgramRequest{Id: "program-123"},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			handler := handlers.NewProgramHandler(mockProgramRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.UpdateProgram(ctx, connect.NewRequest(tt.request))

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
