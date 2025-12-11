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

func setupWorkoutTest(t *testing.T, mockRepo *testutil.MockWorkoutRepository) heftv1connect.WorkoutServiceClient {
	t.Helper()

	handler := handlers.NewWorkoutHandler(mockRepo)
	mux := http.NewServeMux()
	path, h := heftv1connect.NewWorkoutServiceHandler(handler)
	mux.Handle(path, h)

	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)

	return heftv1connect.NewWorkoutServiceClient(server.Client(), server.URL)
}

func TestWorkoutHandler_ListWorkouts(t *testing.T) {
	tests := []struct {
		name          string
		request       *heftv1.ListWorkoutsRequest
		setupMock     func(*testutil.MockWorkoutRepository)
		wantErr       bool
		wantCode      connect.Code
		validateResp  func(*testing.T, *heftv1.ListWorkoutsResponse)
	}{
		{
			name: "success - returns workouts with pagination",
			request: &heftv1.ListWorkoutsRequest{
				UserId: "user-123",
				Pagination: &heftv1.PaginationRequest{
					Page:     1,
					PageSize: 10,
				},
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.WorkoutTemplate, int, error) {
					return []*repository.WorkoutTemplate{
						{
							ID:             "workout-1",
							UserID:         userID,
							Name:           "Push Day",
							TotalExercises: 5,
							TotalSets:      15,
							CreatedAt:      time.Now(),
							UpdatedAt:      time.Now(),
						},
						{
							ID:             "workout-2",
							UserID:         userID,
							Name:           "Pull Day",
							TotalExercises: 4,
							TotalSets:      12,
							CreatedAt:      time.Now(),
							UpdatedAt:      time.Now(),
						},
					}, 2, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.ListWorkoutsResponse) {
				assert.Len(t, resp.Workouts, 2)
				assert.Equal(t, "Push Day", resp.Workouts[0].Name)
				assert.Equal(t, "Pull Day", resp.Workouts[1].Name)
				assert.Equal(t, int32(2), resp.Pagination.TotalCount)
				assert.Equal(t, int32(1), resp.Pagination.TotalPages)
			},
		},
		{
			name: "success - empty list",
			request: &heftv1.ListWorkoutsRequest{
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.WorkoutTemplate, int, error) {
					return []*repository.WorkoutTemplate{}, 0, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.ListWorkoutsResponse) {
				assert.Empty(t, resp.Workouts)
				assert.Equal(t, int32(0), resp.Pagination.TotalCount)
			},
		},
		{
			name: "success - includes archived",
			request: &heftv1.ListWorkoutsRequest{
				UserId:          "user-123",
				IncludeArchived: ptrBool(true),
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.WorkoutTemplate, int, error) {
					assert.True(t, includeArchived)
					return []*repository.WorkoutTemplate{
						{
							ID:         "workout-1",
							UserID:     userID,
							Name:       "Archived Workout",
							IsArchived: true,
							CreatedAt:  time.Now(),
							UpdatedAt:  time.Now(),
						},
					}, 1, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.ListWorkoutsResponse) {
				assert.Len(t, resp.Workouts, 1)
				assert.True(t, resp.Workouts[0].IsArchived)
			},
		},
		{
			name: "error - missing user_id",
			request: &heftv1.ListWorkoutsRequest{
				UserId: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.ListWorkoutsRequest{
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.WorkoutTemplate, int, error) {
					return nil, 0, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockRepo)

			client := setupWorkoutTest(t, mockRepo)
			resp, err := client.ListWorkouts(context.Background(), connect.NewRequest(tt.request))

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

func TestWorkoutHandler_GetWorkout(t *testing.T) {
	tests := []struct {
		name         string
		request      *heftv1.GetWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetWorkoutResponse)
	}{
		{
			name: "success - returns workout with sections",
			request: &heftv1.GetWorkoutRequest{
				Id:     "workout-123",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:             id,
						UserID:         userID,
						Name:           "Push Day",
						TotalExercises: 3,
						TotalSets:      9,
						CreatedAt:      time.Now(),
						UpdatedAt:      time.Now(),
						Sections: []*repository.WorkoutSection{
							{
								ID:                "section-1",
								WorkoutTemplateID: id,
								Name:              "Main Lifts",
								DisplayOrder:      1,
								Items: []*repository.SectionItem{
									{
										ID:           "item-1",
										SectionID:    "section-1",
										ItemType:     "exercise",
										DisplayOrder: 1,
									},
								},
							},
						},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.GetWorkoutResponse) {
				assert.Equal(t, "workout-123", resp.Workout.Id)
				assert.Equal(t, "Push Day", resp.Workout.Name)
				assert.Len(t, resp.Workout.Sections, 1)
				assert.Equal(t, "Main Lifts", resp.Workout.Sections[0].Name)
			},
		},
		{
			name: "error - workout not found",
			request: &heftv1.GetWorkoutRequest{
				Id:     "nonexistent",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return nil, nil
				}
			},
			wantErr:  true,
			wantCode: connect.CodeNotFound,
		},
		{
			name: "error - missing id",
			request: &heftv1.GetWorkoutRequest{
				Id:     "",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.GetWorkoutRequest{
				Id:     "workout-123",
				UserId: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.GetWorkoutRequest{
				Id:     "workout-123",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockRepo)

			client := setupWorkoutTest(t, mockRepo)
			resp, err := client.GetWorkout(context.Background(), connect.NewRequest(tt.request))

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

func TestWorkoutHandler_CreateWorkout(t *testing.T) {
	tests := []struct {
		name         string
		request      *heftv1.CreateWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.CreateWorkoutResponse)
	}{
		{
			name: "success - creates basic workout",
			request: &heftv1.CreateWorkoutRequest{
				UserId:      "user-123",
				Name:        "New Workout",
				Description: ptrString("A test workout"),
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.CreateFunc = func(ctx context.Context, userID, name string, description *string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:          "workout-new",
						UserID:      userID,
						Name:        name,
						Description: description,
						CreatedAt:   time.Now(),
						UpdatedAt:   time.Now(),
					}, nil
				}
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:        id,
						UserID:    userID,
						Name:      "New Workout",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.CreateWorkoutResponse) {
				assert.Equal(t, "workout-new", resp.Workout.Id)
				assert.Equal(t, "New Workout", resp.Workout.Name)
			},
		},
		{
			name: "success - creates workout with sections",
			request: &heftv1.CreateWorkoutRequest{
				UserId: "user-123",
				Name:   "Full Workout",
				Sections: []*heftv1.CreateWorkoutSection{
					{
						Name:         "Warmup",
						DisplayOrder: 1,
						Items: []*heftv1.CreateSectionItem{
							{
								ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
								DisplayOrder: 1,
								ExerciseId:   ptrString("exercise-1"),
								TargetSets: []*heftv1.CreateTargetSet{
									{
										SetNumber:  1,
										TargetReps: ptrInt32(10),
									},
								},
							},
						},
					},
				},
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.CreateFunc = func(ctx context.Context, userID, name string, description *string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:        "workout-full",
						UserID:    userID,
						Name:      name,
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
				m.CreateSectionFunc = func(ctx context.Context, workoutID, name string, displayOrder int, isSuperset bool) (*repository.WorkoutSection, error) {
					return &repository.WorkoutSection{
						ID:                "section-1",
						WorkoutTemplateID: workoutID,
						Name:              name,
						DisplayOrder:      displayOrder,
					}, nil
				}
				m.CreateSectionItemFunc = func(ctx context.Context, sectionID, itemType string, displayOrder int, exerciseID *string, restDurationSeconds *int) (*repository.SectionItem, error) {
					return &repository.SectionItem{
						ID:           "item-1",
						SectionID:    sectionID,
						ItemType:     itemType,
						DisplayOrder: displayOrder,
						ExerciseID:   exerciseID,
					}, nil
				}
				m.CreateTargetSetFunc = func(ctx context.Context, sectionItemID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, targetDistanceM *float64, isBodyweight bool, notes *string) (*repository.ExerciseTargetSet, error) {
					return &repository.ExerciseTargetSet{
						ID:            "set-1",
						SectionItemID: sectionItemID,
						SetNumber:     setNumber,
						TargetReps:    targetReps,
					}, nil
				}
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:             id,
						UserID:         userID,
						Name:           "Full Workout",
						TotalExercises: 1,
						TotalSets:      1,
						CreatedAt:      time.Now(),
						UpdatedAt:      time.Now(),
						Sections: []*repository.WorkoutSection{
							{
								ID:           "section-1",
								Name:         "Warmup",
								DisplayOrder: 1,
								Items: []*repository.SectionItem{
									{
										ID:         "item-1",
										ItemType:   "exercise",
										ExerciseID: ptrString("exercise-1"),
										TargetSets: []*repository.ExerciseTargetSet{
											{ID: "set-1", SetNumber: 1, TargetReps: ptrInt(10)},
										},
									},
								},
							},
						},
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.CreateWorkoutResponse) {
				assert.Equal(t, "Full Workout", resp.Workout.Name)
				assert.Len(t, resp.Workout.Sections, 1)
				assert.Equal(t, "Warmup", resp.Workout.Sections[0].Name)
			},
		},
		{
			name: "error - missing user_id",
			request: &heftv1.CreateWorkoutRequest{
				UserId: "",
				Name:   "Test",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing name",
			request: &heftv1.CreateWorkoutRequest{
				UserId: "user-123",
				Name:   "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - database error on create",
			request: &heftv1.CreateWorkoutRequest{
				UserId: "user-123",
				Name:   "Test",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.CreateFunc = func(ctx context.Context, userID, name string, description *string) (*repository.WorkoutTemplate, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockRepo)

			client := setupWorkoutTest(t, mockRepo)
			resp, err := client.CreateWorkout(context.Background(), connect.NewRequest(tt.request))

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

func TestWorkoutHandler_DeleteWorkout(t *testing.T) {
	tests := []struct {
		name         string
		request      *heftv1.DeleteWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.DeleteWorkoutResponse)
	}{
		{
			name: "success - deletes workout",
			request: &heftv1.DeleteWorkoutRequest{
				Id:     "workout-123",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.DeleteFunc = func(ctx context.Context, id, userID string) error {
					return nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.DeleteWorkoutResponse) {
				assert.True(t, resp.Success)
			},
		},
		{
			name: "error - missing id",
			request: &heftv1.DeleteWorkoutRequest{
				Id:     "",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.DeleteWorkoutRequest{
				Id:     "workout-123",
				UserId: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.DeleteWorkoutRequest{
				Id:     "workout-123",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.DeleteFunc = func(ctx context.Context, id, userID string) error {
					return errors.New("database error")
				}
			},
			wantErr:  true,
			wantCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockRepo)

			client := setupWorkoutTest(t, mockRepo)
			resp, err := client.DeleteWorkout(context.Background(), connect.NewRequest(tt.request))

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

func TestWorkoutHandler_DuplicateWorkout(t *testing.T) {
	tests := []struct {
		name         string
		request      *heftv1.DuplicateWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.DuplicateWorkoutResponse)
	}{
		{
			name: "success - duplicates workout with default name",
			request: &heftv1.DuplicateWorkoutRequest{
				Id:     "workout-123",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					if id == "workout-123" {
						return &repository.WorkoutTemplate{
							ID:        id,
							UserID:    userID,
							Name:      "Original Workout",
							CreatedAt: time.Now(),
							UpdatedAt: time.Now(),
							Sections:  []*repository.WorkoutSection{},
						}, nil
					}
					// Return the duplicate
					return &repository.WorkoutTemplate{
						ID:        "workout-copy",
						UserID:    userID,
						Name:      "Original Workout (Copy)",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
				m.CreateFunc = func(ctx context.Context, userID, name string, description *string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:        "workout-copy",
						UserID:    userID,
						Name:      name,
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.DuplicateWorkoutResponse) {
				assert.Equal(t, "workout-copy", resp.Workout.Id)
				assert.Equal(t, "Original Workout (Copy)", resp.Workout.Name)
			},
		},
		{
			name: "success - duplicates workout with custom name",
			request: &heftv1.DuplicateWorkoutRequest{
				Id:      "workout-123",
				UserId:  "user-123",
				NewName: ptrString("My Custom Name"),
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					if id == "workout-123" {
						return &repository.WorkoutTemplate{
							ID:        id,
							UserID:    userID,
							Name:      "Original",
							CreatedAt: time.Now(),
							UpdatedAt: time.Now(),
							Sections:  []*repository.WorkoutSection{},
						}, nil
					}
					return &repository.WorkoutTemplate{
						ID:        "workout-copy",
						UserID:    userID,
						Name:      "My Custom Name",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
				m.CreateFunc = func(ctx context.Context, userID, name string, description *string) (*repository.WorkoutTemplate, error) {
					assert.Equal(t, "My Custom Name", name)
					return &repository.WorkoutTemplate{
						ID:        "workout-copy",
						UserID:    userID,
						Name:      name,
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.DuplicateWorkoutResponse) {
				assert.Equal(t, "My Custom Name", resp.Workout.Name)
			},
		},
		{
			name: "error - workout not found",
			request: &heftv1.DuplicateWorkoutRequest{
				Id:     "nonexistent",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return nil, nil
				}
			},
			wantErr:  true,
			wantCode: connect.CodeNotFound,
		},
		{
			name: "error - missing id",
			request: &heftv1.DuplicateWorkoutRequest{
				Id:     "",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.DuplicateWorkoutRequest{
				Id:     "workout-123",
				UserId: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockRepo)

			client := setupWorkoutTest(t, mockRepo)
			resp, err := client.DuplicateWorkout(context.Background(), connect.NewRequest(tt.request))

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

func TestWorkoutHandler_UpdateWorkout(t *testing.T) {
	tests := []struct {
		name         string
		request      *heftv1.UpdateWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.UpdateWorkoutResponse)
	}{
		{
			name: "success - returns existing workout",
			request: &heftv1.UpdateWorkoutRequest{
				Id:     "workout-123",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:        id,
						UserID:    userID,
						Name:      "Existing Workout",
						CreatedAt: time.Now(),
						UpdatedAt: time.Now(),
					}, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.UpdateWorkoutResponse) {
				assert.Equal(t, "workout-123", resp.Workout.Id)
				assert.Equal(t, "Existing Workout", resp.Workout.Name)
			},
		},
		{
			name: "error - workout not found",
			request: &heftv1.UpdateWorkoutRequest{
				Id:     "nonexistent",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return nil, nil
				}
			},
			wantErr:  true,
			wantCode: connect.CodeNotFound,
		},
		{
			name: "error - missing id",
			request: &heftv1.UpdateWorkoutRequest{
				Id:     "",
				UserId: "user-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.UpdateWorkoutRequest{
				Id:     "workout-123",
				UserId: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockRepo)

			client := setupWorkoutTest(t, mockRepo)
			resp, err := client.UpdateWorkout(context.Background(), connect.NewRequest(tt.request))

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

