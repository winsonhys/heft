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

func TestSessionHandler_StartSession(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	tests := []struct {
		name          string
		userID        string
		withAuth      bool
		request       *heftv1.StartSessionRequest
		mockSetup     func(*testutil.MockSessionRepository, *testutil.MockWorkoutRepository)
		wantErr       bool
		wantErrCode   connect.Code
		checkResponse func(*testing.T, *heftv1.StartSessionResponse)
	}{
		{
			name:     "success - create empty session",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.StartSessionRequest{},
			mockSetup: func(sr *testutil.MockSessionRepository, wr *testutil.MockWorkoutRepository) {
				now := time.Now()
				sr.CreateFunc = func(ctx context.Context, userID string, workoutTemplateID, programID *string, programDayNumber *int, name *string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:        "session-123",
						UserID:    userID,
						Status:    "in_progress",
						StartedAt: now,
						CreatedAt: now,
						UpdatedAt: now,
					}, nil
				}
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:        id,
						UserID:    userID,
						Status:    "in_progress",
						StartedAt: now,
						CreatedAt: now,
						UpdatedAt: now,
						Exercises: []*repository.SessionExercise{},
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.StartSessionResponse) {
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if resp.Session.Id != "session-123" {
					t.Errorf("expected session ID 'session-123', got '%s'", resp.Session.Id)
				}
				if resp.Session.Status != heftv1.WorkoutStatus_WORKOUT_STATUS_IN_PROGRESS {
					t.Errorf("expected status IN_PROGRESS, got %v", resp.Session.Status)
				}
			},
		},
		{
			name:        "error - not authenticated",
			userID:      "",
			withAuth:    false,
			request:     &heftv1.StartSessionRequest{},
			mockSetup:   func(sr *testutil.MockSessionRepository, wr *testutil.MockWorkoutRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.StartSessionRequest{},
			mockSetup: func(sr *testutil.MockSessionRepository, wr *testutil.MockWorkoutRepository) {
				sr.CreateFunc = func(ctx context.Context, userID string, workoutTemplateID, programID *string, programDayNumber *int, name *string) (*repository.WorkoutSession, error) {
					return nil, errors.New("database error")
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockSessionRepo := &testutil.MockSessionRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.mockSetup(mockSessionRepo, mockWorkoutRepo)

			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.StartSession(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Fatal("expected error, got nil")
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if tt.checkResponse != nil {
				tt.checkResponse(t, resp.Msg)
			}
		})
	}
}

func TestSessionHandler_GetSession(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	tests := []struct {
		name          string
		userID        string
		withAuth      bool
		request       *heftv1.GetSessionRequest
		mockSetup     func(*testutil.MockSessionRepository)
		wantErr       bool
		wantErrCode   connect.Code
		checkResponse func(*testing.T, *heftv1.GetSessionResponse)
	}{
		{
			name:     "success - session found",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetSessionRequest{
				Id: "session-123",
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				now := time.Now()
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:        id,
						UserID:    userID,
						Status:    "in_progress",
						StartedAt: now,
						CreatedAt: now,
						UpdatedAt: now,
						Exercises: []*repository.SessionExercise{},
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.GetSessionResponse) {
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if resp.Session.Id != "session-123" {
					t.Errorf("expected session ID 'session-123', got '%s'", resp.Session.Id)
				}
			},
		},
		{
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetSessionRequest{
				Id: "",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:     "error - not authenticated",
			userID:   "",
			withAuth: false,
			request: &heftv1.GetSessionRequest{
				Id: "session-123",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
		{
			name:     "error - session not found",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetSessionRequest{
				Id: "nonexistent",
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					return nil, nil
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockSessionRepo := &testutil.MockSessionRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.mockSetup(mockSessionRepo)

			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.GetSession(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Fatal("expected error, got nil")
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if tt.checkResponse != nil {
				tt.checkResponse(t, resp.Msg)
			}
		})
	}
}

func TestSessionHandler_FinishSession(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	tests := []struct {
		name          string
		userID        string
		withAuth      bool
		request       *heftv1.FinishSessionRequest
		mockSetup     func(*testutil.MockSessionRepository)
		wantErr       bool
		wantErrCode   connect.Code
		checkResponse func(*testing.T, *heftv1.FinishSessionResponse)
	}{
		{
			name:     "success - session finished",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.FinishSessionRequest{
				Id: "session-123",
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				now := time.Now()
				sr.FinishSessionFunc = func(ctx context.Context, id, userID string, notes *string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:          id,
						UserID:      userID,
						Status:      "completed",
						StartedAt:   now.Add(-time.Hour),
						CompletedAt: &now,
						CreatedAt:   now.Add(-time.Hour),
						UpdatedAt:   now,
					}, nil
				}
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:          id,
						UserID:      userID,
						Status:      "completed",
						StartedAt:   now.Add(-time.Hour),
						CompletedAt: &now,
						CreatedAt:   now.Add(-time.Hour),
						UpdatedAt:   now,
						Exercises:   []*repository.SessionExercise{},
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.FinishSessionResponse) {
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if resp.Session.Status != heftv1.WorkoutStatus_WORKOUT_STATUS_COMPLETED {
					t.Errorf("expected status COMPLETED, got %v", resp.Session.Status)
				}
			},
		},
		{
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.FinishSessionRequest{
				Id: "",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:     "error - not authenticated",
			userID:   "",
			withAuth: false,
			request: &heftv1.FinishSessionRequest{
				Id: "session-123",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockSessionRepo := &testutil.MockSessionRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.mockSetup(mockSessionRepo)

			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.FinishSession(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Fatal("expected error, got nil")
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if tt.checkResponse != nil {
				tt.checkResponse(t, resp.Msg)
			}
		})
	}
}

func TestSessionHandler_AbandonSession(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	tests := []struct {
		name        string
		userID      string
		withAuth    bool
		request     *heftv1.AbandonSessionRequest
		mockSetup   func(*testutil.MockSessionRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name:     "success - session abandoned",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.AbandonSessionRequest{
				Id: "session-123",
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				sr.AbandonSessionFunc = func(ctx context.Context, id, userID string) error {
					return nil
				}
			},
		},
		{
			name:     "error - missing id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.AbandonSessionRequest{
				Id: "",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:     "error - not authenticated",
			userID:   "",
			withAuth: false,
			request: &heftv1.AbandonSessionRequest{
				Id: "session-123",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.AbandonSessionRequest{
				Id: "session-123",
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				sr.AbandonSessionFunc = func(ctx context.Context, id, userID string) error {
					return errors.New("database error")
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockSessionRepo := &testutil.MockSessionRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.mockSetup(mockSessionRepo)

			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.AbandonSession(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Fatal("expected error, got nil")
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if !resp.Msg.Success {
				t.Error("expected success to be true")
			}
		})
	}
}

func TestSessionHandler_ListSessions(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	tests := []struct {
		name          string
		userID        string
		withAuth      bool
		request       *heftv1.ListSessionsRequest
		mockSetup     func(*testutil.MockSessionRepository)
		wantErr       bool
		wantErrCode   connect.Code
		checkResponse func(*testing.T, *heftv1.ListSessionsResponse)
	}{
		{
			name:     "success - list sessions",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.ListSessionsRequest{},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				now := time.Now()
				sr.ListFunc = func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
					return []*repository.WorkoutSession{
						{
							ID:        "session-1",
							UserID:    userID,
							Status:    "completed",
							StartedAt: now.Add(-time.Hour),
						},
						{
							ID:        "session-2",
							UserID:    userID,
							Status:    "in_progress",
							StartedAt: now,
						},
					}, 2, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.ListSessionsResponse) {
				if len(resp.Sessions) != 2 {
					t.Errorf("expected 2 sessions, got %d", len(resp.Sessions))
				}
				if resp.Pagination.TotalCount != 2 {
					t.Errorf("expected total count 2, got %d", resp.Pagination.TotalCount)
				}
			},
		},
		{
			name:     "success - empty list",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.ListSessionsRequest{},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				sr.ListFunc = func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
					return []*repository.WorkoutSession{}, 0, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.ListSessionsResponse) {
				if len(resp.Sessions) != 0 {
					t.Errorf("expected 0 sessions, got %d", len(resp.Sessions))
				}
			},
		},
		{
			name:        "error - not authenticated",
			userID:      "",
			withAuth:    false,
			request:     &heftv1.ListSessionsRequest{},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockSessionRepo := &testutil.MockSessionRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.mockSetup(mockSessionRepo)

			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.ListSessions(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Fatal("expected error, got nil")
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if tt.checkResponse != nil {
				tt.checkResponse(t, resp.Msg)
			}
		})
	}
}

func TestSessionHandler_CompleteSet(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	tests := []struct {
		name          string
		userID        string
		withAuth      bool
		request       *heftv1.CompleteSetRequest
		mockSetup     func(*testutil.MockSessionRepository)
		wantErr       bool
		wantErrCode   connect.Code
		checkResponse func(*testing.T, *heftv1.CompleteSetResponse)
	}{
		{
			name:     "success - complete set with weight and reps",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CompleteSetRequest{
				SessionSetId: "set-123",
				WeightKg:     ptrFloat64(100.0),
				Reps:         ptrInt32(10),
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				sr.CompleteSetFunc = func(ctx context.Context, setID string, weightKg *float64, reps, timeSeconds *int, distanceM, rpe *float64, notes *string) (*repository.SessionSet, error) {
					w := 100.0
					r := 10
					return &repository.SessionSet{
						ID:          setID,
						SetNumber:   1,
						WeightKg:    &w,
						Reps:        &r,
						IsCompleted: true,
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.CompleteSetResponse) {
				if resp.Set == nil {
					t.Error("expected set in response")
					return
				}
				if !resp.Set.IsCompleted {
					t.Error("expected set to be completed")
				}
				if resp.Set.WeightKg == nil || *resp.Set.WeightKg != 100.0 {
					t.Errorf("expected weight 100.0, got %v", resp.Set.WeightKg)
				}
			},
		},
		{
			name:     "error - missing session_set_id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.CompleteSetRequest{
				SessionSetId: "",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:     "error - not authenticated",
			userID:   "",
			withAuth: false,
			request: &heftv1.CompleteSetRequest{
				SessionSetId: "set-123",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockSessionRepo := &testutil.MockSessionRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.mockSetup(mockSessionRepo)

			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.CompleteSet(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Fatal("expected error, got nil")
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if tt.checkResponse != nil {
				tt.checkResponse(t, resp.Msg)
			}
		})
	}
}

func TestSessionHandler_AddExercise(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	tests := []struct {
		name          string
		userID        string
		withAuth      bool
		request       *heftv1.AddExerciseRequest
		mockSetup     func(*testutil.MockSessionRepository)
		wantErr       bool
		wantErrCode   connect.Code
		checkResponse func(*testing.T, *heftv1.AddExerciseResponse)
	}{
		{
			name:     "success - add exercise",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.AddExerciseRequest{
				SessionId:  "session-123",
				ExerciseId: "exercise-456",
				NumSets:    3,
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				sr.AddExerciseFunc = func(ctx context.Context, sessionID, exerciseID string, displayOrder int, sectionName *string) (*repository.SessionExercise, error) {
					return &repository.SessionExercise{
						ID:           "se-123",
						SessionID:    sessionID,
						ExerciseID:   exerciseID,
						ExerciseName: "Bench Press",
						ExerciseType: "weight_reps",
						DisplayOrder: displayOrder,
					}, nil
				}
				sr.AddSetFunc = func(ctx context.Context, sessionExerciseID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds *int, isBodyweight bool) (*repository.SessionSet, error) {
					return &repository.SessionSet{
						ID:                "set-" + string(rune(setNumber)),
						SessionExerciseID: sessionExerciseID,
						SetNumber:         setNumber,
					}, nil
				}
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:     id,
						UserID: userID,
						Exercises: []*repository.SessionExercise{
							{
								ID:           "se-123",
								SessionID:    id,
								ExerciseID:   "exercise-456",
								ExerciseName: "Bench Press",
								ExerciseType: "weight_reps",
								Sets: []*repository.SessionSet{
									{ID: "set-1", SetNumber: 1},
									{ID: "set-2", SetNumber: 2},
									{ID: "set-3", SetNumber: 3},
								},
							},
						},
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.AddExerciseResponse) {
				if resp.Exercise == nil {
					t.Error("expected exercise in response")
					return
				}
				if resp.Exercise.ExerciseName != "Bench Press" {
					t.Errorf("expected exercise name 'Bench Press', got '%s'", resp.Exercise.ExerciseName)
				}
				if len(resp.Exercise.Sets) != 3 {
					t.Errorf("expected 3 sets, got %d", len(resp.Exercise.Sets))
				}
			},
		},
		{
			name:     "error - missing session_id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.AddExerciseRequest{
				SessionId:  "",
				ExerciseId: "exercise-456",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:     "error - missing exercise_id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.AddExerciseRequest{
				SessionId:  "session-123",
				ExerciseId: "",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:     "error - not authenticated",
			userID:   "",
			withAuth: false,
			request: &heftv1.AddExerciseRequest{
				SessionId:  "session-123",
				ExerciseId: "exercise-456",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockSessionRepo := &testutil.MockSessionRepository{}
			mockWorkoutRepo := &testutil.MockWorkoutRepository{}
			tt.mockSetup(mockSessionRepo)

			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.AddExercise(ctx, connect.NewRequest(tt.request))

			if tt.wantErr {
				if err == nil {
					t.Fatal("expected error, got nil")
				}
				var connectErr *connect.Error
				if errors.As(err, &connectErr) {
					if connectErr.Code() != tt.wantErrCode {
						t.Errorf("expected error code %v, got %v", tt.wantErrCode, connectErr.Code())
					}
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if tt.checkResponse != nil {
				tt.checkResponse(t, resp.Msg)
			}
		})
	}
}

// Helper functions for creating pointers
func ptrString(v string) *string {
	return &v
}

func ptrBool(v bool) *bool {
	return &v
}

func ptrInt(v int) *int {
	return &v
}

func ptrFloat64(v float64) *float64 {
	return &v
}

func ptrInt32(v int32) *int32 {
	return &v
}
