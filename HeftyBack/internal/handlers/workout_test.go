package handlers_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/repository"
	"github.com/heftyback/internal/testutil"
)


func TestWorkoutHandler_ListWorkouts(t *testing.T) {
	tests := []struct {
		name          string
		userID        string
		withAuth      bool
		request       *heftv1.ListWorkoutsRequest
		setupMock     func(*testutil.MockWorkoutRepository)
		wantErr       bool
		wantCode      connect.Code
		validateResp  func(*testing.T, *heftv1.ListWorkoutsResponse)
	}{
		{
			name:     "success - returns workouts with pagination",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.ListWorkoutsRequest{
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
				if len(resp.Workouts) != 2 {
					t.Errorf("expected 2 workouts, got %d", len(resp.Workouts))
				}
				if resp.Workouts[0].Name != "Push Day" {
					t.Errorf("expected first workout name 'Push Day', got %s", resp.Workouts[0].Name)
				}
				if resp.Workouts[1].Name != "Pull Day" {
					t.Errorf("expected second workout name 'Pull Day', got %s", resp.Workouts[1].Name)
				}
				if resp.Pagination.TotalCount != 2 {
					t.Errorf("expected total count 2, got %d", resp.Pagination.TotalCount)
				}
				if resp.Pagination.TotalPages != 1 {
					t.Errorf("expected total pages 1, got %d", resp.Pagination.TotalPages)
				}
			},
		},
		{
			name:     "success - empty list",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.ListWorkoutsRequest{},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.WorkoutTemplate, int, error) {
					return []*repository.WorkoutTemplate{}, 0, nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.ListWorkoutsResponse) {
				if len(resp.Workouts) != 0 {
					t.Errorf("expected empty workouts list, got %d", len(resp.Workouts))
				}
				if resp.Pagination.TotalCount != 0 {
					t.Errorf("expected total count 0, got %d", resp.Pagination.TotalCount)
				}
			},
		},
		{
			name:     "success - includes archived",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.ListWorkoutsRequest{
				IncludeArchived: ptrBool(true),
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.WorkoutTemplate, int, error) {
					if !includeArchived {
						t.Error("expected includeArchived to be true")
					}
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
				if len(resp.Workouts) != 1 {
					t.Errorf("expected 1 workout, got %d", len(resp.Workouts))
				}
				if !resp.Workouts[0].IsArchived {
					t.Error("expected workout to be archived")
				}
			},
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.ListWorkoutsRequest{},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.ListWorkoutsRequest{},
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

			handler := handlers.NewWorkoutHandler(mockRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.ListWorkouts(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantCode {
						t.Errorf("expected error code %v, got %v", tt.wantCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestWorkoutHandler_GetWorkout(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.GetWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.GetWorkoutResponse)
	}{
		{
			name:     "success - returns workout with sections",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetWorkoutRequest{
				Id: "workout-123",
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
				if resp.Workout.Id != "workout-123" {
					t.Errorf("expected workout ID 'workout-123', got %s", resp.Workout.Id)
				}
				if resp.Workout.Name != "Push Day" {
					t.Errorf("expected workout name 'Push Day', got %s", resp.Workout.Name)
				}
				if len(resp.Workout.Sections) != 1 {
					t.Errorf("expected 1 section, got %d", len(resp.Workout.Sections))
				}
				if resp.Workout.Sections[0].Name != "Main Lifts" {
					t.Errorf("expected section name 'Main Lifts', got %s", resp.Workout.Sections[0].Name)
				}
			},
		},
		{
			name:     "error - workout not found",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetWorkoutRequest{
				Id: "nonexistent",
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
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetWorkoutRequest{
				Id: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.GetWorkoutRequest{Id: "workout-123"},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetWorkoutRequest{
				Id: "workout-123",
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

			handler := handlers.NewWorkoutHandler(mockRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.GetWorkout(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantCode {
						t.Errorf("expected error code %v, got %v", tt.wantCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestWorkoutHandler_CreateWorkout(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.CreateWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.CreateWorkoutResponse)
	}{
		{
			name:     "success - creates basic workout",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CreateWorkoutRequest{
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
				if resp.Workout.Id != "workout-new" {
					t.Errorf("expected workout ID 'workout-new', got %s", resp.Workout.Id)
				}
				if resp.Workout.Name != "New Workout" {
					t.Errorf("expected workout name 'New Workout', got %s", resp.Workout.Name)
				}
			},
		},
		{
			name:     "success - creates workout with sections",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CreateWorkoutRequest{
				Name: "Full Workout",
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
				m.CreateTargetSetFunc = func(ctx context.Context, sectionItemID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, targetDistanceM *float64, isBodyweight bool, notes *string, restDurationSeconds *int) (*repository.ExerciseTargetSet, error) {
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
				if resp.Workout.Name != "Full Workout" {
					t.Errorf("expected workout name 'Full Workout', got %s", resp.Workout.Name)
				}
				if len(resp.Workout.Sections) != 1 {
					t.Errorf("expected 1 section, got %d", len(resp.Workout.Sections))
				}
				if resp.Workout.Sections[0].Name != "Warmup" {
					t.Errorf("expected section name 'Warmup', got %s", resp.Workout.Sections[0].Name)
				}
			},
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.CreateWorkoutRequest{Name: "Test"},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - missing name",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CreateWorkoutRequest{
				Name: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:     "error - database error on create",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CreateWorkoutRequest{
				Name: "Test",
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

			handler := handlers.NewWorkoutHandler(mockRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.CreateWorkout(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantCode {
						t.Errorf("expected error code %v, got %v", tt.wantCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestWorkoutHandler_DeleteWorkout(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.DeleteWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.DeleteWorkoutResponse)
	}{
		{
			name:     "success - deletes workout",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DeleteWorkoutRequest{
				Id: "workout-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.DeleteFunc = func(ctx context.Context, id, userID string) error {
					return nil
				}
			},
			validateResp: func(t *testing.T, resp *heftv1.DeleteWorkoutResponse) {
				if !resp.Success {
					t.Error("expected success to be true")
				}
			},
		},
		{
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DeleteWorkoutRequest{
				Id: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.DeleteWorkoutRequest{Id: "workout-123"},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DeleteWorkoutRequest{
				Id: "workout-123",
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

			handler := handlers.NewWorkoutHandler(mockRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.DeleteWorkout(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantCode {
						t.Errorf("expected error code %v, got %v", tt.wantCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestWorkoutHandler_DuplicateWorkout(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.DuplicateWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.DuplicateWorkoutResponse)
	}{
		{
			name:     "success - duplicates workout with default name",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DuplicateWorkoutRequest{
				Id: "workout-123",
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
				if resp.Workout.Id != "workout-copy" {
					t.Errorf("expected workout ID 'workout-copy', got %s", resp.Workout.Id)
				}
				if resp.Workout.Name != "Original Workout (Copy)" {
					t.Errorf("expected workout name 'Original Workout (Copy)', got %s", resp.Workout.Name)
				}
			},
		},
		{
			name:     "success - duplicates workout with custom name",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DuplicateWorkoutRequest{
				Id:      "workout-123",
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
					if name != "My Custom Name" {
						t.Errorf("expected name 'My Custom Name', got %s", name)
					}
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
				if resp.Workout.Name != "My Custom Name" {
					t.Errorf("expected workout name 'My Custom Name', got %s", resp.Workout.Name)
				}
			},
		},
		{
			name:     "error - workout not found",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DuplicateWorkoutRequest{
				Id: "nonexistent",
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
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.DuplicateWorkoutRequest{
				Id: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.DuplicateWorkoutRequest{Id: "workout-123"},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockRepo)

			handler := handlers.NewWorkoutHandler(mockRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.DuplicateWorkout(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantCode {
						t.Errorf("expected error code %v, got %v", tt.wantCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}
			tt.validateResp(t, resp.Msg)
		})
	}
}

func TestWorkoutHandler_UpdateWorkout(t *testing.T) {
	tests := []struct {
		name         string
		userID       string
		withAuth     bool
		request      *heftv1.UpdateWorkoutRequest
		setupMock    func(*testutil.MockWorkoutRepository)
		wantErr      bool
		wantCode     connect.Code
		validateResp func(*testing.T, *heftv1.UpdateWorkoutResponse)
	}{
		{
			name:     "success - returns existing workout",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.UpdateWorkoutRequest{
				Id: "workout-123",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {
				m.UpdateWorkoutDetailsFunc = func(ctx context.Context, id, name string, description *string, isArchived bool) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:          id,
						UserID:      "user-123",
						Name:        name,
						Description: description,
						IsArchived:  isArchived,
						CreatedAt:   time.Now(),
						UpdatedAt:   time.Now(),
					}, nil
				}
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
				if resp.Workout.Id != "workout-123" {
					t.Errorf("expected workout ID 'workout-123', got %s", resp.Workout.Id)
				}
				if resp.Workout.Name != "Existing Workout" {
					t.Errorf("expected workout name 'Existing Workout', got %s", resp.Workout.Name)
				}
			},
		},
		{
			name:     "error - workout not found",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.UpdateWorkoutRequest{
				Id: "nonexistent",
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
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.UpdateWorkoutRequest{
				Id: "",
			},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeInvalidArgument,
		},
		{
			name:      "error - not authenticated",
			userID:    "",
			withAuth:  false,
			request:   &heftv1.UpdateWorkoutRequest{Id: "workout-123"},
			setupMock: func(m *testutil.MockWorkoutRepository) {},
			wantErr:   true,
			wantCode:  connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockWorkoutRepository{}
			tt.setupMock(mockRepo)

			handler := handlers.NewWorkoutHandler(mockRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.UpdateWorkout(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantCode {
						t.Errorf("expected error code %v, got %v", tt.wantCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}
			tt.validateResp(t, resp.Msg)
		})
	}
}
