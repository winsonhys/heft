package handlers_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/repository"
	"github.com/heftyback/internal/testutil"
)

func TestExerciseHandler_GetExercise(t *testing.T) {
	tests := []struct {
		name        string
		exerciseID  string
		mockSetup   func(*testutil.MockExerciseRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name:       "success - exercise found",
			exerciseID: "exercise-123",
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.GetByIDFunc = func(ctx context.Context, id string) (*repository.Exercise, error) {
					categoryID := "category-123"
					categoryName := "Chest"
					return &repository.Exercise{
						ID:           id,
						Name:         "Bench Press",
						CategoryID:   &categoryID,
						CategoryName: &categoryName,
						ExerciseType: "weight_reps",
						IsSystem:     true,
						CreatedAt:    time.Now(),
						UpdatedAt:    time.Now(),
					}, nil
				}
			},
			wantErr: false,
		},
		{
			name:       "error - empty id",
			exerciseID: "",
			mockSetup:  func(m *testutil.MockExerciseRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:       "error - exercise not found",
			exerciseID: "nonexistent",
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.GetByIDFunc = func(ctx context.Context, id string) (*repository.Exercise, error) {
					return nil, nil
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeNotFound,
		},
		{
			name:       "error - database error",
			exerciseID: "exercise-123",
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.GetByIDFunc = func(ctx context.Context, id string) (*repository.Exercise, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockExerciseRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewExerciseHandler(mockRepo)

			req := connect.NewRequest(&heftv1.GetExerciseRequest{
				Id: tt.exerciseID,
			})

			resp, err := handler.GetExercise(context.Background(), req)

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				if resp.Msg.Exercise == nil {
					t.Error("expected exercise in response")
				}
				if resp.Msg.Exercise.Id != tt.exerciseID {
					t.Errorf("expected exercise ID %s, got %s", tt.exerciseID, resp.Msg.Exercise.Id)
				}
			}
		})
	}
}

func TestExerciseHandler_ListExercises(t *testing.T) {
	tests := []struct {
		name        string
		request     *heftv1.ListExercisesRequest
		mockSetup   func(*testutil.MockExerciseRepository)
		wantErr     bool
		wantErrCode connect.Code
		wantCount   int
	}{
		{
			name:    "success - list all exercises",
			request: &heftv1.ListExercisesRequest{},
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.ListExercisesFunc = func(ctx context.Context, categoryID, exerciseType *string, systemOnly bool, userID *string, limit, offset int) ([]*repository.Exercise, int, error) {
					return []*repository.Exercise{
						{ID: "1", Name: "Bench Press", ExerciseType: "weight_reps", IsSystem: true, CreatedAt: time.Now(), UpdatedAt: time.Now()},
						{ID: "2", Name: "Squat", ExerciseType: "weight_reps", IsSystem: true, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					}, 2, nil
				}
			},
			wantErr:   false,
			wantCount: 2,
		},
		{
			name: "success - filter by category",
			request: func() *heftv1.ListExercisesRequest {
				categoryID := "category-123"
				return &heftv1.ListExercisesRequest{
					CategoryId: &categoryID,
				}
			}(),
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.ListExercisesFunc = func(ctx context.Context, categoryID, exerciseType *string, systemOnly bool, userID *string, limit, offset int) ([]*repository.Exercise, int, error) {
					if categoryID == nil || *categoryID != "category-123" {
						t.Error("expected categoryID to be passed to repository")
					}
					return []*repository.Exercise{
						{ID: "1", Name: "Bench Press", ExerciseType: "weight_reps", IsSystem: true, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					}, 1, nil
				}
			},
			wantErr:   false,
			wantCount: 1,
		},
		{
			name: "success - system only",
			request: func() *heftv1.ListExercisesRequest {
				systemOnly := true
				return &heftv1.ListExercisesRequest{
					SystemOnly: &systemOnly,
				}
			}(),
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.ListExercisesFunc = func(ctx context.Context, categoryID, exerciseType *string, systemOnly bool, userID *string, limit, offset int) ([]*repository.Exercise, int, error) {
					if !systemOnly {
						t.Error("expected systemOnly to be true")
					}
					return []*repository.Exercise{
						{ID: "1", Name: "Bench Press", ExerciseType: "weight_reps", IsSystem: true, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					}, 1, nil
				}
			},
			wantErr:   false,
			wantCount: 1,
		},
		{
			name: "success - with pagination",
			request: &heftv1.ListExercisesRequest{
				Pagination: &heftv1.PaginationRequest{
					Page:     2,
					PageSize: 10,
				},
			},
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.ListExercisesFunc = func(ctx context.Context, categoryID, exerciseType *string, systemOnly bool, userID *string, limit, offset int) ([]*repository.Exercise, int, error) {
					if limit != 10 {
						t.Errorf("expected limit 10, got %d", limit)
					}
					if offset != 10 {
						t.Errorf("expected offset 10, got %d", offset)
					}
					return []*repository.Exercise{}, 0, nil
				}
			},
			wantErr:   false,
			wantCount: 0,
		},
		{
			name:    "error - database error",
			request: &heftv1.ListExercisesRequest{},
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.ListExercisesFunc = func(ctx context.Context, categoryID, exerciseType *string, systemOnly bool, userID *string, limit, offset int) ([]*repository.Exercise, int, error) {
					return nil, 0, errors.New("database error")
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockExerciseRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewExerciseHandler(mockRepo)

			req := connect.NewRequest(tt.request)
			resp, err := handler.ListExercises(context.Background(), req)

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				if len(resp.Msg.Exercises) != tt.wantCount {
					t.Errorf("expected %d exercises, got %d", tt.wantCount, len(resp.Msg.Exercises))
				}
			}
		})
	}
}

func TestExerciseHandler_CreateExercise(t *testing.T) {
	tests := []struct {
		name        string
		request     *heftv1.CreateExerciseRequest
		mockSetup   func(*testutil.MockExerciseRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name: "success - custom exercise created",
			request: &heftv1.CreateExerciseRequest{
				UserId:       "user-123",
				Name:         "My Custom Press",
				CategoryId:   "category-123",
				ExerciseType: heftv1.ExerciseType_EXERCISE_TYPE_WEIGHT_REPS,
			},
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.CreateFunc = func(ctx context.Context, userID, name, categoryID, exerciseType string, description *string) (*repository.Exercise, error) {
					return &repository.Exercise{
						ID:           "new-exercise-123",
						Name:         name,
						CategoryID:   &categoryID,
						ExerciseType: exerciseType,
						IsSystem:     false,
						CreatedBy:    &userID,
						CreatedAt:    time.Now(),
						UpdatedAt:    time.Now(),
					}, nil
				}
			},
			wantErr: false,
		},
		{
			name: "success - with description",
			request: func() *heftv1.CreateExerciseRequest {
				description := "A modified version of bench press"
				return &heftv1.CreateExerciseRequest{
					UserId:       "user-123",
					Name:         "Modified Bench Press",
					CategoryId:   "category-123",
					ExerciseType: heftv1.ExerciseType_EXERCISE_TYPE_WEIGHT_REPS,
					Description:  &description,
				}
			}(),
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.CreateFunc = func(ctx context.Context, userID, name, categoryID, exerciseType string, description *string) (*repository.Exercise, error) {
					if description == nil {
						t.Error("expected description to be passed")
					}
					return &repository.Exercise{
						ID:           "new-exercise-123",
						Name:         name,
						CategoryID:   &categoryID,
						ExerciseType: exerciseType,
						Description:  description,
						IsSystem:     false,
						CreatedBy:    &userID,
						CreatedAt:    time.Now(),
						UpdatedAt:    time.Now(),
					}, nil
				}
			},
			wantErr: false,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.CreateExerciseRequest{
				UserId:     "",
				Name:       "My Custom Press",
				CategoryId: "category-123",
			},
			mockSetup:   func(m *testutil.MockExerciseRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name: "error - missing name",
			request: &heftv1.CreateExerciseRequest{
				UserId:     "user-123",
				Name:       "",
				CategoryId: "category-123",
			},
			mockSetup:   func(m *testutil.MockExerciseRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name: "error - missing category_id",
			request: &heftv1.CreateExerciseRequest{
				UserId:     "user-123",
				Name:       "My Custom Press",
				CategoryId: "",
			},
			mockSetup:   func(m *testutil.MockExerciseRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.CreateExerciseRequest{
				UserId:       "user-123",
				Name:         "My Custom Press",
				CategoryId:   "category-123",
				ExerciseType: heftv1.ExerciseType_EXERCISE_TYPE_WEIGHT_REPS,
			},
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.CreateFunc = func(ctx context.Context, userID, name, categoryID, exerciseType string, description *string) (*repository.Exercise, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockExerciseRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewExerciseHandler(mockRepo)

			req := connect.NewRequest(tt.request)
			resp, err := handler.CreateExercise(context.Background(), req)

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				if resp.Msg.Exercise == nil {
					t.Error("expected exercise in response")
				}
			}
		})
	}
}

func TestExerciseHandler_ListCategories(t *testing.T) {
	tests := []struct {
		name        string
		mockSetup   func(*testutil.MockExerciseRepository)
		wantErr     bool
		wantErrCode connect.Code
		wantCount   int
	}{
		{
			name: "success - returns categories",
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.ListCategoriesFunc = func(ctx context.Context) ([]*repository.ExerciseCategory, error) {
					return []*repository.ExerciseCategory{
						{ID: "1", Name: "Chest", DisplayOrder: 1, CreatedAt: time.Now()},
						{ID: "2", Name: "Back", DisplayOrder: 2, CreatedAt: time.Now()},
						{ID: "3", Name: "Legs", DisplayOrder: 3, CreatedAt: time.Now()},
					}, nil
				}
			},
			wantErr:   false,
			wantCount: 3,
		},
		{
			name: "success - empty categories",
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.ListCategoriesFunc = func(ctx context.Context) ([]*repository.ExerciseCategory, error) {
					return []*repository.ExerciseCategory{}, nil
				}
			},
			wantErr:   false,
			wantCount: 0,
		},
		{
			name: "error - database error",
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.ListCategoriesFunc = func(ctx context.Context) ([]*repository.ExerciseCategory, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockExerciseRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewExerciseHandler(mockRepo)

			req := connect.NewRequest(&heftv1.ListCategoriesRequest{})
			resp, err := handler.ListCategories(context.Background(), req)

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				if len(resp.Msg.Categories) != tt.wantCount {
					t.Errorf("expected %d categories, got %d", tt.wantCount, len(resp.Msg.Categories))
				}
			}
		})
	}
}

func TestExerciseHandler_SearchExercises(t *testing.T) {
	tests := []struct {
		name        string
		request     *heftv1.SearchExercisesRequest
		mockSetup   func(*testutil.MockExerciseRepository)
		wantErr     bool
		wantErrCode connect.Code
		wantCount   int
	}{
		{
			name: "success - exercises found",
			request: &heftv1.SearchExercisesRequest{
				Query: "press",
			},
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.SearchFunc = func(ctx context.Context, query string, userID *string, limit int) ([]*repository.Exercise, error) {
					return []*repository.Exercise{
						{ID: "1", Name: "Bench Press", ExerciseType: "weight_reps", IsSystem: true, CreatedAt: time.Now(), UpdatedAt: time.Now()},
						{ID: "2", Name: "Overhead Press", ExerciseType: "weight_reps", IsSystem: true, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					}, nil
				}
			},
			wantErr:   false,
			wantCount: 2,
		},
		{
			name: "success - no results",
			request: &heftv1.SearchExercisesRequest{
				Query: "nonexistent",
			},
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.SearchFunc = func(ctx context.Context, query string, userID *string, limit int) ([]*repository.Exercise, error) {
					return []*repository.Exercise{}, nil
				}
			},
			wantErr:   false,
			wantCount: 0,
		},
		{
			name: "success - with limit",
			request: func() *heftv1.SearchExercisesRequest {
				limit := int32(5)
				return &heftv1.SearchExercisesRequest{
					Query: "press",
					Limit: &limit,
				}
			}(),
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.SearchFunc = func(ctx context.Context, query string, userID *string, limit int) ([]*repository.Exercise, error) {
					if limit != 5 {
						t.Errorf("expected limit 5, got %d", limit)
					}
					return []*repository.Exercise{
						{ID: "1", Name: "Bench Press", ExerciseType: "weight_reps", IsSystem: true, CreatedAt: time.Now(), UpdatedAt: time.Now()},
					}, nil
				}
			},
			wantErr:   false,
			wantCount: 1,
		},
		{
			name: "error - empty query",
			request: &heftv1.SearchExercisesRequest{
				Query: "",
			},
			mockSetup:   func(m *testutil.MockExerciseRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.SearchExercisesRequest{
				Query: "press",
			},
			mockSetup: func(m *testutil.MockExerciseRepository) {
				m.SearchFunc = func(ctx context.Context, query string, userID *string, limit int) ([]*repository.Exercise, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockExerciseRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewExerciseHandler(mockRepo)

			req := connect.NewRequest(tt.request)
			resp, err := handler.SearchExercises(context.Background(), req)

			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil")
					return
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
			} else {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
					return
				}
				if len(resp.Msg.Exercises) != tt.wantCount {
					t.Errorf("expected %d exercises, got %d", tt.wantCount, len(resp.Msg.Exercises))
				}
			}
		})
	}
}
