package handlers_test

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/gen/heft/v1/heftv1connect"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/repository"
	"github.com/heftyback/internal/testutil"
)

func setupProgramTest(t *testing.T, mockProgramRepo *testutil.MockProgramRepository, mockWorkoutRepo *testutil.MockWorkoutRepository) heftv1connect.ProgramServiceClient {
	t.Helper()

	handler := handlers.NewProgramHandler(mockProgramRepo, mockWorkoutRepo)
	mux := http.NewServeMux()
	path, h := heftv1connect.NewProgramServiceHandler(handler)
	mux.Handle(path, h)

	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)

	return heftv1connect.NewProgramServiceClient(server.Client(), server.URL)
}

func TestProgramHandler_ListPrograms(t *testing.T) {
	tests := []struct {
		name         string
		request      *heftv1.ListProgramsRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.ListProgramsResponse)
	}{
		{
			name: "success - returns programs with pagination",
			request: &heftv1.ListProgramsRequest{
				UserId: "user-123",
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
			name: "success - empty list",
			request: &heftv1.ListProgramsRequest{
				UserId: "user-123",
			},
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
			name: "success - includes archived",
			request: &heftv1.ListProgramsRequest{
				UserId:          "user-123",
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
			name: "error - missing user_id",
			request: &heftv1.ListProgramsRequest{
				UserId: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.ListProgramsRequest{
				UserId: "user-123",
			},
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

			client := setupProgramTest(t, mockProgramRepo, mockWorkoutRepo)
			resp, err := client.ListPrograms(context.Background(), connect.NewRequest(tt.request))

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
		request      *heftv1.GetProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetProgramResponse)
	}{
		{
			name: "success - returns program with days",
			request: &heftv1.GetProgramRequest{
				Id:     "program-123",
				UserId: "user-123",
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
			name: "error - program not found",
			request: &heftv1.GetProgramRequest{
				Id:     "nonexistent",
				UserId: "user-123",
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
			name: "error - missing id",
			request: &heftv1.GetProgramRequest{
				Id:     "",
				UserId: "user-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.GetProgramRequest{
				Id:     "program-123",
				UserId: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			client := setupProgramTest(t, mockProgramRepo, mockWorkoutRepo)
			resp, err := client.GetProgram(context.Background(), connect.NewRequest(tt.request))

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
		request      *heftv1.CreateProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.CreateProgramResponse)
	}{
		{
			name: "success - creates basic program",
			request: &heftv1.CreateProgramRequest{
				UserId:        "user-123",
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
			name: "success - creates program with days",
			request: &heftv1.CreateProgramRequest{
				UserId:        "user-123",
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
			name: "error - missing user_id",
			request: &heftv1.CreateProgramRequest{
				UserId: "",
				Name:   "Test",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing name",
			request: &heftv1.CreateProgramRequest{
				UserId: "user-123",
				Name:   "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - database error on create",
			request: &heftv1.CreateProgramRequest{
				UserId: "user-123",
				Name:   "Test",
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

			client := setupProgramTest(t, mockProgramRepo, mockWorkoutRepo)
			resp, err := client.CreateProgram(context.Background(), connect.NewRequest(tt.request))

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
		request      *heftv1.DeleteProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.DeleteProgramResponse)
	}{
		{
			name: "success - deletes program",
			request: &heftv1.DeleteProgramRequest{
				Id:     "program-123",
				UserId: "user-123",
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
			name: "error - missing id",
			request: &heftv1.DeleteProgramRequest{
				Id:     "",
				UserId: "user-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.DeleteProgramRequest{
				Id:     "program-123",
				UserId: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.DeleteProgramRequest{
				Id:     "program-123",
				UserId: "user-123",
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

			client := setupProgramTest(t, mockProgramRepo, mockWorkoutRepo)
			resp, err := client.DeleteProgram(context.Background(), connect.NewRequest(tt.request))

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
		request      *heftv1.SetActiveProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.SetActiveProgramResponse)
	}{
		{
			name: "success - sets program as active",
			request: &heftv1.SetActiveProgramRequest{
				Id:     "program-123",
				UserId: "user-123",
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
			name: "error - missing id",
			request: &heftv1.SetActiveProgramRequest{
				Id:     "",
				UserId: "user-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.SetActiveProgramRequest{
				Id:     "program-123",
				UserId: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.SetActiveProgramRequest{
				Id:     "program-123",
				UserId: "user-123",
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

			client := setupProgramTest(t, mockProgramRepo, mockWorkoutRepo)
			resp, err := client.SetActiveProgram(context.Background(), connect.NewRequest(tt.request))

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
		request      *heftv1.GetTodayWorkoutRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetTodayWorkoutResponse)
	}{
		{
			name: "success - has workout today",
			request: &heftv1.GetTodayWorkoutRequest{
				UserId: "user-123",
			},
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
			name: "success - rest day",
			request: &heftv1.GetTodayWorkoutRequest{
				UserId: "user-123",
			},
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
			name: "success - no active program",
			request: &heftv1.GetTodayWorkoutRequest{
				UserId: "user-123",
			},
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
			name: "error - missing user_id",
			request: &heftv1.GetTodayWorkoutRequest{
				UserId: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.GetTodayWorkoutRequest{
				UserId: "user-123",
			},
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

			client := setupProgramTest(t, mockProgramRepo, mockWorkoutRepo)
			resp, err := client.GetTodayWorkout(context.Background(), connect.NewRequest(tt.request))

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

func TestProgramHandler_UpdateProgram(t *testing.T) {
	tests := []struct {
		name         string
		request      *heftv1.UpdateProgramRequest
		setupMock    func(*testutil.MockProgramRepository, *testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.UpdateProgramResponse)
	}{
		{
			name: "success - returns existing program",
			request: &heftv1.UpdateProgramRequest{
				Id:     "program-123",
				UserId: "user-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {
				mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
					return &repository.Program{
						ID:        id,
						UserID:    userID,
						Name:      "Existing Program",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.UpdateProgramResponse) {
				assert.Equal(t, "program-123", resp.Program.Id)
				assert.Equal(t, "Existing Program", resp.Program.Name)
			},
		},
		{
			name: "error - program not found",
			request: &heftv1.UpdateProgramRequest{
				Id:     "nonexistent",
				UserId: "user-123",
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
			name: "error - missing id",
			request: &heftv1.UpdateProgramRequest{
				Id:     "",
				UserId: "user-123",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.UpdateProgramRequest{
				Id:     "program-123",
				UserId: "",
			},
			setupMock: func(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockProgramRepo := &testutil.MockProgramRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockProgramRepo, mockWorkoutRepo)

			client := setupProgramTest(t, mockProgramRepo, mockWorkoutRepo)
			resp, err := client.UpdateProgram(context.Background(), connect.NewRequest(tt.request))

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
