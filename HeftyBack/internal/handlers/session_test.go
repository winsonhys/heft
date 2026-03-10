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
				// No existing in-progress sessions
				sr.ListFunc = func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
					return []*repository.WorkoutSession{}, 0, nil
				}
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
			name:     "error - user already has active session",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.StartSessionRequest{},
			mockSetup: func(sr *testutil.MockSessionRepository, wr *testutil.MockWorkoutRepository) {
				now := time.Now()
				// Return existing in-progress session
				sr.ListFunc = func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
					return []*repository.WorkoutSession{
						{
							ID:        "existing-session",
							UserID:    userID,
							Status:    "in_progress",
							StartedAt: now,
						},
					}, 1, nil
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeAlreadyExists,
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
			name:     "error - database error on create",
			userID:   "user-123",
			withAuth: true,
			request:  &heftv1.StartSessionRequest{},
			mockSetup: func(sr *testutil.MockSessionRepository, wr *testutil.MockWorkoutRepository) {
				// No existing sessions
				sr.ListFunc = func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
					return []*repository.WorkoutSession{}, 0, nil
				}
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

			mockProgramRepo := &testutil.MockProgramRepository{}
			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo, mockProgramRepo)

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

			mockProgramRepo := &testutil.MockProgramRepository{}
			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo, mockProgramRepo)

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

			mockProgramRepo := &testutil.MockProgramRepository{}
			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo, mockProgramRepo)

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

			mockProgramRepo := &testutil.MockProgramRepository{}
			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo, mockProgramRepo)

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

			mockProgramRepo := &testutil.MockProgramRepository{}
			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo, mockProgramRepo)

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

func TestSessionHandler_SyncSession(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	tests := []struct {
		name          string
		userID        string
		withAuth      bool
		request       *heftv1.SyncSessionRequest
		mockSetup     func(*testutil.MockSessionRepository)
		wantErr       bool
		wantErrCode   connect.Code
		checkResponse func(*testing.T, *heftv1.SyncSessionResponse)
	}{
		{
			name:     "success - sync session with sets",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.SyncSessionRequest{
				SessionId: "session-123",
				Sets: []*heftv1.SyncSetData{
					{
						SetIdentifier: &heftv1.SyncSetData_Id{Id: "set-1"},
						WeightKg:      ptrFloat64(100.0),
						Reps:          ptrInt32(10),
						IsCompleted:   true,
					},
					{
						SetIdentifier: &heftv1.SyncSetData_Id{Id: "set-2"},
						WeightKg:      ptrFloat64(105.0),
						Reps:          ptrInt32(8),
						IsCompleted:   true,
					},
				},
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				now := time.Now()
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					w1, w2 := 100.0, 105.0
					r1, r2 := 10, 8
					return &repository.WorkoutSession{
						ID:            id,
						UserID:        userID,
						Status:        "in_progress",
						StartedAt:     now,
						CompletedSets: 2,
						TotalSets:     3,
						CreatedAt:     now,
						UpdatedAt:     now,
						Exercises: []*repository.SessionExercise{
							{
								ID:           "se-1",
								SessionID:    id,
								ExerciseName: "Bench Press",
								ExerciseType: "weight_reps",
								Sets: []*repository.SessionSet{
									{ID: "set-1", SetNumber: 1, WeightKg: &w1, Reps: &r1, IsCompleted: true},
									{ID: "set-2", SetNumber: 2, WeightKg: &w2, Reps: &r2, IsCompleted: true},
									{ID: "set-3", SetNumber: 3, IsCompleted: false},
								},
							},
						},
					}, nil
				}
				sr.SyncSetsFunc = func(ctx context.Context, sessionID string, sets []repository.SyncSetInput) error {
					return nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.SyncSessionResponse) {
				if !resp.Success {
					t.Error("expected success to be true")
				}
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if resp.Session.CompletedSets != 2 {
					t.Errorf("expected 2 completed sets, got %d", resp.Session.CompletedSets)
				}
			},
		},
		{
			name:     "error - missing session_id",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.SyncSessionRequest{
				SessionId: "",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:     "error - not authenticated",
			userID:   "",
			withAuth: false,
			request: &heftv1.SyncSessionRequest{
				SessionId: "session-123",
			},
			mockSetup:   func(sr *testutil.MockSessionRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
		{
			name:     "error - session not found",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.SyncSessionRequest{
				SessionId: "nonexistent",
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

			mockProgramRepo := &testutil.MockProgramRepository{}
			handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo, mockProgramRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			resp, err := handler.SyncSession(ctx, connect.NewRequest(tt.request))

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

func TestSessionHandler_FinishSession_ArchivesProgram(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	t.Run("archives program on last day", func(t *testing.T) {
		mockSessionRepo := &testutil.MockSessionRepository{}
		mockWorkoutRepo := &testutil.MockWorkoutRepository{}
		mockProgramRepo := &testutil.MockProgramRepository{}

		now := time.Now()
		programID := "program-1"
		dayNumber := 7

		mockSessionRepo.FinishSessionFunc = func(ctx context.Context, id, userID string, notes *string) (*repository.WorkoutSession, error) {
			return &repository.WorkoutSession{
				ID:        id,
				UserID:    userID,
				Status:    "completed",
				StartedAt: now.Add(-time.Hour),
				CreatedAt: now.Add(-time.Hour),
				UpdatedAt: now,
			}, nil
		}
		mockSessionRepo.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
			return &repository.WorkoutSession{
				ID:               id,
				UserID:           userID,
				Status:           "completed",
				StartedAt:        now.Add(-time.Hour),
				CompletedAt:      &now,
				CreatedAt:        now.Add(-time.Hour),
				UpdatedAt:        now,
				ProgramID:        &programID,
				ProgramDayNumber: &dayNumber,
				Exercises:        []*repository.SessionExercise{},
			}, nil
		}
		mockProgramRepo.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
			return &repository.Program{
				ID:            id,
				UserID:        userID,
				DurationWeeks: 1,
				DurationDays:  0,
				IsActive:      true,
			}, nil
		}

		archiveCalled := false
		mockProgramRepo.ArchiveFunc = func(ctx context.Context, id, userID string) error {
			archiveCalled = true
			if id != programID {
				t.Errorf("expected program ID %s, got %s", programID, id)
			}
			return nil
		}

		handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo, mockProgramRepo)
		ctx := auth.ContextWithUserID(context.Background(), "user-123")

		_, err := handler.FinishSession(ctx, connect.NewRequest(&heftv1.FinishSessionRequest{Id: "session-123"}))
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if !archiveCalled {
			t.Error("expected Archive to be called for last program day")
		}
	})

	t.Run("does not archive program when not last day", func(t *testing.T) {
		mockSessionRepo := &testutil.MockSessionRepository{}
		mockWorkoutRepo := &testutil.MockWorkoutRepository{}
		mockProgramRepo := &testutil.MockProgramRepository{}

		now := time.Now()
		programID := "program-1"
		dayNumber := 3

		mockSessionRepo.FinishSessionFunc = func(ctx context.Context, id, userID string, notes *string) (*repository.WorkoutSession, error) {
			return &repository.WorkoutSession{
				ID:        id,
				UserID:    userID,
				Status:    "completed",
				StartedAt: now.Add(-time.Hour),
				CreatedAt: now.Add(-time.Hour),
				UpdatedAt: now,
			}, nil
		}
		mockSessionRepo.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
			return &repository.WorkoutSession{
				ID:               id,
				UserID:           userID,
				Status:           "completed",
				StartedAt:        now.Add(-time.Hour),
				CompletedAt:      &now,
				CreatedAt:        now.Add(-time.Hour),
				UpdatedAt:        now,
				ProgramID:        &programID,
				ProgramDayNumber: &dayNumber,
				Exercises:        []*repository.SessionExercise{},
			}, nil
		}
		mockProgramRepo.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
			return &repository.Program{
				ID:            id,
				UserID:        userID,
				DurationWeeks: 1,
				DurationDays:  0,
				IsActive:      true,
			}, nil
		}

		archiveCalled := false
		mockProgramRepo.ArchiveFunc = func(ctx context.Context, id, userID string) error {
			archiveCalled = true
			return nil
		}

		handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo, mockProgramRepo)
		ctx := auth.ContextWithUserID(context.Background(), "user-123")

		_, err := handler.FinishSession(ctx, connect.NewRequest(&heftv1.FinishSessionRequest{Id: "session-123"}))
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if archiveCalled {
			t.Error("expected Archive NOT to be called when not on last program day")
		}
	})
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

func TestSessionHandler_StartSession_WithRestItems(t *testing.T) {
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
			name:     "success - creates rest items from workout template",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.StartSessionRequest{
				WorkoutTemplateId: ptrString("workout-123"),
			},
			mockSetup: func(sr *testutil.MockSessionRepository, wr *testutil.MockWorkoutRepository) {
				now := time.Now()
				// No existing in-progress sessions
				sr.ListFunc = func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
					return []*repository.WorkoutSession{}, 0, nil
				}
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
				// Workout template with rest item
				restDuration := 90
				wr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:     id,
						UserID: userID,
						Name:   "Test Workout",
						Sections: []*repository.WorkoutSection{
							{
								ID:                "section-1",
								WorkoutTemplateID: id,
								Name:              "Section A",
								DisplayOrder:      1,
								Items: []*repository.SectionItem{
									{
										ID:           "item-1",
										SectionID:    "section-1",
										ItemType:     "exercise",
										DisplayOrder: 1,
										ExerciseID:   ptrString("exercise-1"),
									},
									{
										ID:                  "item-2",
										SectionID:           "section-1",
										ItemType:            "rest",
										DisplayOrder:        2,
										RestDurationSeconds: &restDuration,
									},
								},
							},
						},
					}, nil
				}
				sr.AddExerciseFunc = func(ctx context.Context, sessionID, exerciseID string, displayOrder int, sectionName, supersetID *string) (*repository.SessionExercise, error) {
					return &repository.SessionExercise{
						ID:           "se-1",
						SessionID:    sessionID,
						ExerciseID:   exerciseID,
						ExerciseName: "Bench Press",
						DisplayOrder: displayOrder,
					}, nil
				}
				sr.AddRestItemFunc = func(ctx context.Context, sessionID string, displayOrder int, sectionName *string, restDurationSeconds int) (*repository.SessionRestItem, error) {
					return &repository.SessionRestItem{
						ID:                  "rest-item-1",
						SessionID:           sessionID,
						DisplayOrder:        displayOrder,
						SectionName:         sectionName,
						RestDurationSeconds: restDurationSeconds,
						IsCompleted:         false,
					}, nil
				}
				sectionName := "Section A"
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:        id,
						UserID:    userID,
						Status:    "in_progress",
						StartedAt: now,
						CreatedAt: now,
						UpdatedAt: now,
						Exercises: []*repository.SessionExercise{
							{
								ID:           "se-1",
								SessionID:    id,
								ExerciseName: "Bench Press",
								DisplayOrder: 1,
								SectionName:  &sectionName,
							},
						},
						RestItems: []*repository.SessionRestItem{
							{
								ID:                  "rest-item-1",
								SessionID:           id,
								DisplayOrder:        2,
								SectionName:         &sectionName,
								RestDurationSeconds: 90,
								IsCompleted:         false,
							},
						},
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.StartSessionResponse) {
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if len(resp.Session.RestItems) != 1 {
					t.Errorf("expected 1 rest item, got %d", len(resp.Session.RestItems))
					return
				}
				restItem := resp.Session.RestItems[0]
				if restItem.RestDurationSeconds != 90 {
					t.Errorf("expected rest duration 90, got %d", restItem.RestDurationSeconds)
				}
				if restItem.SectionName != "Section A" {
					t.Errorf("expected section name 'Section A', got '%s'", restItem.SectionName)
				}
				if restItem.IsCompleted {
					t.Error("expected rest item to not be completed")
				}
			},
		},
		{
			name:     "skips rest item with nil RestDurationSeconds",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.StartSessionRequest{
				WorkoutTemplateId: ptrString("workout-nil-rest"),
			},
			mockSetup: func(sr *testutil.MockSessionRepository, wr *testutil.MockWorkoutRepository) {
				now := time.Now()
				sr.ListFunc = func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
					return []*repository.WorkoutSession{}, 0, nil
				}
				sr.CreateFunc = func(ctx context.Context, userID string, workoutTemplateID, programID *string, programDayNumber *int, name *string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:        "session-nil-rest",
						UserID:    userID,
						Status:    "in_progress",
						StartedAt: now,
						CreatedAt: now,
						UpdatedAt: now,
					}, nil
				}
				// Workout template with a rest item where RestDurationSeconds is nil (DB NULL)
				wr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:     id,
						UserID: userID,
						Name:   "Nil Rest Workout",
						Sections: []*repository.WorkoutSection{
							{
								ID:                "section-nil",
								WorkoutTemplateID: id,
								Name:              "Section B",
								DisplayOrder:      1,
								Items: []*repository.SectionItem{
									{
										ID:                  "item-nil-rest",
										SectionID:           "section-nil",
										ItemType:            "rest",
										DisplayOrder:        1,
										RestDurationSeconds: nil, // DB NULL — must be skipped
									},
								},
							},
						},
					}, nil
				}
				// AddRestItem must NOT be called for a nil-duration rest item
				sr.AddRestItemFunc = func(ctx context.Context, sessionID string, displayOrder int, sectionName *string, restDurationSeconds int) (*repository.SessionRestItem, error) {
					t.Error("AddRestItem should not be called for nil RestDurationSeconds")
					return nil, errors.New("unexpected call")
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
						RestItems: []*repository.SessionRestItem{},
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.StartSessionResponse) {
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if len(resp.Session.RestItems) != 0 {
					t.Errorf("expected 0 rest items (nil duration skipped), got %d", len(resp.Session.RestItems))
				}
			},
		},
		{
			name:     "skips rest item with zero duration",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.StartSessionRequest{
				WorkoutTemplateId: ptrString("workout-zero-rest"),
			},
			mockSetup: func(sr *testutil.MockSessionRepository, wr *testutil.MockWorkoutRepository) {
				now := time.Now()
				sr.ListFunc = func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
					return []*repository.WorkoutSession{}, 0, nil
				}
				sr.CreateFunc = func(ctx context.Context, userID string, workoutTemplateID, programID *string, programDayNumber *int, name *string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:        "session-zero-rest",
						UserID:    userID,
						Status:    "in_progress",
						StartedAt: now,
						CreatedAt: now,
						UpdatedAt: now,
					}, nil
				}
				// Workout template with a rest item where RestDurationSeconds is &0 (explicit zero — NOT nil)
				zeroDuration := 0
				wr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
					return &repository.WorkoutTemplate{
						ID:     id,
						UserID: userID,
						Name:   "Zero Rest Workout",
						Sections: []*repository.WorkoutSection{
							{
								ID:                "section-zero",
								WorkoutTemplateID: id,
								Name:              "Section C",
								DisplayOrder:      1,
								Items: []*repository.SectionItem{
									{
										ID:                  "item-zero-rest",
										SectionID:           "section-zero",
										ItemType:            "rest",
										DisplayOrder:        1,
										RestDurationSeconds: &zeroDuration, // &0 — must be skipped
									},
								},
							},
						},
					}, nil
				}
				// AddRestItem must NOT be called for a zero-duration rest item
				sr.AddRestItemFunc = func(ctx context.Context, sessionID string, displayOrder int, sectionName *string, restDurationSeconds int) (*repository.SessionRestItem, error) {
					t.Error("AddRestItem should not be called for zero duration")
					return nil, errors.New("unexpected call")
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
						RestItems: []*repository.SessionRestItem{},
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.StartSessionResponse) {
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if len(resp.Session.RestItems) != 0 {
					t.Errorf("expected 0 rest items (zero duration skipped), got %d", len(resp.Session.RestItems))
				}
			},
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

func TestSessionHandler_SyncSession_RestItems(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	tests := []struct {
		name          string
		userID        string
		withAuth      bool
		request       *heftv1.SyncSessionRequest
		mockSetup     func(*testutil.MockSessionRepository)
		wantErr       bool
		wantErrCode   connect.Code
		checkResponse func(*testing.T, *heftv1.SyncSessionResponse)
	}{
		{
			name:     "success - sync rest item completion",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.SyncSessionRequest{
				SessionId: "session-123",
				RestItems: []*heftv1.SyncRestItemData{
					{
						Id:          "rest-item-1",
						IsCompleted: true,
					},
				},
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				now := time.Now()
				sectionName := "Section A"
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:        id,
						UserID:    userID,
						Status:    "in_progress",
						StartedAt: now,
						CreatedAt: now,
						UpdatedAt: now,
						Exercises: []*repository.SessionExercise{},
						RestItems: []*repository.SessionRestItem{
							{
								ID:                  "rest-item-1",
								SessionID:           id,
								DisplayOrder:        1,
								SectionName:         &sectionName,
								RestDurationSeconds: 90,
								IsCompleted:         true,
								CompletedAt:         &now,
							},
						},
					}, nil
				}
				sr.SyncSetsFunc = func(ctx context.Context, sessionID string, sets []repository.SyncSetInput) error {
					return nil
				}
				sr.SyncRestItemsFunc = func(ctx context.Context, sessionID string, items []repository.SyncRestItemInput) error {
					if len(items) != 1 {
						t.Errorf("expected 1 rest item to sync, got %d", len(items))
					}
					if items[0].ID != "rest-item-1" {
						t.Errorf("expected rest item ID 'rest-item-1', got '%s'", items[0].ID)
					}
					if !items[0].IsCompleted {
						t.Error("expected rest item to be completed")
					}
					return nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.SyncSessionResponse) {
				if !resp.Success {
					t.Error("expected success to be true")
				}
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if len(resp.Session.RestItems) != 1 {
					t.Errorf("expected 1 rest item, got %d", len(resp.Session.RestItems))
					return
				}
				if !resp.Session.RestItems[0].IsCompleted {
					t.Error("expected rest item to be completed")
				}
			},
		},
		{
			name:     "success - sync multiple rest items",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.SyncSessionRequest{
				SessionId: "session-123",
				RestItems: []*heftv1.SyncRestItemData{
					{
						Id:          "rest-item-1",
						IsCompleted: true,
					},
					{
						Id:          "rest-item-2",
						IsCompleted: false,
					},
				},
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				now := time.Now()
				sectionName := "Section A"
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:        id,
						UserID:    userID,
						Status:    "in_progress",
						StartedAt: now,
						CreatedAt: now,
						UpdatedAt: now,
						Exercises: []*repository.SessionExercise{},
						RestItems: []*repository.SessionRestItem{
							{
								ID:                  "rest-item-1",
								SessionID:           id,
								DisplayOrder:        1,
								SectionName:         &sectionName,
								RestDurationSeconds: 60,
								IsCompleted:         true,
								CompletedAt:         &now,
							},
							{
								ID:                  "rest-item-2",
								SessionID:           id,
								DisplayOrder:        2,
								SectionName:         &sectionName,
								RestDurationSeconds: 90,
								IsCompleted:         false,
							},
						},
					}, nil
				}
				sr.SyncSetsFunc = func(ctx context.Context, sessionID string, sets []repository.SyncSetInput) error {
					return nil
				}
				sr.SyncRestItemsFunc = func(ctx context.Context, sessionID string, items []repository.SyncRestItemInput) error {
					if len(items) != 2 {
						t.Errorf("expected 2 rest items to sync, got %d", len(items))
					}
					return nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.SyncSessionResponse) {
				if !resp.Success {
					t.Error("expected success to be true")
				}
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if len(resp.Session.RestItems) != 2 {
					t.Errorf("expected 2 rest items, got %d", len(resp.Session.RestItems))
				}
			},
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

			resp, err := handler.SyncSession(ctx, connect.NewRequest(tt.request))

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

func TestSessionHandler_GetSession_IncludesRestItems(t *testing.T) {
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
			name:     "success - session includes rest items",
			userID:   "user-123",
			withAuth: true,
			request: &heftv1.GetSessionRequest{
				Id: "session-123",
			},
			mockSetup: func(sr *testutil.MockSessionRepository) {
				now := time.Now()
				sectionName := "Section A"
				sr.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
					return &repository.WorkoutSession{
						ID:        id,
						UserID:    userID,
						Status:    "in_progress",
						StartedAt: now,
						CreatedAt: now,
						UpdatedAt: now,
						Exercises: []*repository.SessionExercise{
							{
								ID:           "se-1",
								SessionID:    id,
								ExerciseName: "Bench Press",
								DisplayOrder: 1,
								SectionName:  &sectionName,
							},
						},
						RestItems: []*repository.SessionRestItem{
							{
								ID:                  "rest-item-1",
								SessionID:           id,
								DisplayOrder:        2,
								SectionName:         &sectionName,
								RestDurationSeconds: 90,
								IsCompleted:         false,
							},
							{
								ID:                  "rest-item-2",
								SessionID:           id,
								DisplayOrder:        4,
								SectionName:         &sectionName,
								RestDurationSeconds: 120,
								IsCompleted:         true,
								CompletedAt:         &now,
							},
						},
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.GetSessionResponse) {
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if len(resp.Session.RestItems) != 2 {
					t.Errorf("expected 2 rest items, got %d", len(resp.Session.RestItems))
					return
				}
				// Check first rest item
				restItem1 := resp.Session.RestItems[0]
				if restItem1.Id != "rest-item-1" {
					t.Errorf("expected rest item ID 'rest-item-1', got '%s'", restItem1.Id)
				}
				if restItem1.DisplayOrder != 2 {
					t.Errorf("expected display order 2, got %d", restItem1.DisplayOrder)
				}
				if restItem1.RestDurationSeconds != 90 {
					t.Errorf("expected rest duration 90, got %d", restItem1.RestDurationSeconds)
				}
				if restItem1.IsCompleted {
					t.Error("expected first rest item to not be completed")
				}
				// Check second rest item
				restItem2 := resp.Session.RestItems[1]
				if restItem2.Id != "rest-item-2" {
					t.Errorf("expected rest item ID 'rest-item-2', got '%s'", restItem2.Id)
				}
				if restItem2.RestDurationSeconds != 120 {
					t.Errorf("expected rest duration 120, got %d", restItem2.RestDurationSeconds)
				}
				if !restItem2.IsCompleted {
					t.Error("expected second rest item to be completed")
				}
				if restItem2.CompletedAt == nil {
					t.Error("expected completed_at to be set for completed rest item")
				}
			},
		},
		{
			name:     "success - session with no rest items",
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
						RestItems: []*repository.SessionRestItem{},
					}, nil
				}
			},
			checkResponse: func(t *testing.T, resp *heftv1.GetSessionResponse) {
				if resp.Session == nil {
					t.Error("expected session in response")
					return
				}
				if len(resp.Session.RestItems) != 0 {
					t.Errorf("expected 0 rest items, got %d", len(resp.Session.RestItems))
				}
			},
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

func TestSessionHandler_StartSession_DisplayOrder(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping unit test in short mode")
	}

	// This test verifies that StartSession copies exercises from the template
	// in display_order sequence, and that interleaved rest items (which don't
	// become session_exercises) don't break the ordering.
	//
	// Template layout (single section):
	//   display_order=1: exercise (Bench Press)
	//   display_order=2: rest (60s)
	//   display_order=3: exercise (Squat)
	//
	// Expected session exercises (display_order preserved from template):
	//   display_order=1: Bench Press
	//   display_order=3: Squat (rest item at 2 is separate)

	exerciseID1 := "exercise-bench"
	exerciseID2 := "exercise-squat"
	sectionName := "Main"
	restDuration := 60

	// Track the display orders passed to AddExercise
	type addExerciseCall struct {
		exerciseID   string
		displayOrder int
	}
	var addExerciseCalls []addExerciseCall

	mockSessionRepo := &testutil.MockSessionRepository{}
	mockWorkoutRepo := &testutil.MockWorkoutRepository{}

	now := time.Now()

	// Mock: no existing in-progress sessions
	mockSessionRepo.ListFunc = func(ctx context.Context, userID string, status *string, startDate, endDate *time.Time, limit, offset int) ([]*repository.WorkoutSession, int, error) {
		return []*repository.WorkoutSession{}, 0, nil
	}

	// Mock: create session
	mockSessionRepo.CreateFunc = func(ctx context.Context, userID string, workoutTemplateID, programID *string, programDayNumber *int, name *string) (*repository.WorkoutSession, error) {
		return &repository.WorkoutSession{
			ID:        "session-new",
			UserID:    userID,
			Status:    "in_progress",
			StartedAt: now,
			CreatedAt: now,
			UpdatedAt: now,
		}, nil
	}

	// Mock: AddExercise captures calls
	mockSessionRepo.AddExerciseFunc = func(ctx context.Context, sessionID, exerciseID string, displayOrder int, sectionName, supersetID *string) (*repository.SessionExercise, error) {
		addExerciseCalls = append(addExerciseCalls, addExerciseCall{
			exerciseID:   exerciseID,
			displayOrder: displayOrder,
		})
		return &repository.SessionExercise{
			ID:           "se-" + exerciseID,
			SessionID:    sessionID,
			ExerciseID:   exerciseID,
			ExerciseName: exerciseID, // simplified
			ExerciseType: "weight_reps",
			DisplayOrder: displayOrder,
			CreatedAt:    now,
		}, nil
	}

	// Mock: AddSet (for target sets)
	mockSessionRepo.AddSetFunc = func(ctx context.Context, sessionExerciseID string, setNumber int, targetWeightKg *float64, targetReps, targetTimeSeconds, restDurationSeconds *int, isBodyweight bool) (*repository.SessionSet, error) {
		return &repository.SessionSet{
			ID:                "set-" + sessionExerciseID,
			SessionExerciseID: sessionExerciseID,
			SetNumber:         setNumber,
			CreatedAt:         now,
			UpdatedAt:         now,
		}, nil
	}

	// Mock: GetByID returns session with exercises in order
	mockSessionRepo.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutSession, error) {
		return &repository.WorkoutSession{
			ID:        id,
			UserID:    userID,
			Status:    "in_progress",
			StartedAt: now,
			CreatedAt: now,
			UpdatedAt: now,
			Exercises: []*repository.SessionExercise{
				{
					ID:           "se-" + exerciseID1,
					SessionID:    id,
					ExerciseID:   exerciseID1,
					ExerciseName: "Bench Press",
					ExerciseType: "weight_reps",
					DisplayOrder: 1,
					SectionName:  &sectionName,
					CreatedAt:    now,
					Sets:         []*repository.SessionSet{},
				},
				{
					ID:           "se-" + exerciseID2,
					SessionID:    id,
					ExerciseID:   exerciseID2,
					ExerciseName: "Squat",
					ExerciseType: "weight_reps",
					DisplayOrder: 3,
					SectionName:  &sectionName,
					CreatedAt:    now,
					Sets:         []*repository.SessionSet{},
				},
			},
		}, nil
	}

	// Mock: workout template with interleaved exercises and rest
	templateID := "template-123"
	mockWorkoutRepo.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
		return &repository.WorkoutTemplate{
			ID:     id,
			UserID: userID,
			Name:   "Test Workout",
			Sections: []*repository.WorkoutSection{
				{
					ID:                "section-1",
					WorkoutTemplateID: id,
					Name:              sectionName,
					DisplayOrder:      0,
					IsSuperset:        false,
					Items: []*repository.SectionItem{
						{
							ID:           "item-1",
							SectionID:    "section-1",
							ItemType:     "exercise",
							DisplayOrder: 1,
							ExerciseID:   &exerciseID1,
							ExerciseName: ptrString("Bench Press"),
							ExerciseType: ptrString("weight_reps"),
							TargetSets:   []*repository.ExerciseTargetSet{},
						},
						{
							ID:                  "item-2",
							SectionID:           "section-1",
							ItemType:            "rest",
							DisplayOrder:        2,
							RestDurationSeconds: &restDuration,
						},
						{
							ID:           "item-3",
							SectionID:    "section-1",
							ItemType:     "exercise",
							DisplayOrder: 3,
							ExerciseID:   &exerciseID2,
							ExerciseName: ptrString("Squat"),
							ExerciseType: ptrString("weight_reps"),
							TargetSets:   []*repository.ExerciseTargetSet{},
						},
					},
				},
			},
		}, nil
	}

	handler := handlers.NewSessionHandler(mockSessionRepo, mockWorkoutRepo)

	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	resp, err := handler.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
		WorkoutTemplateId: &templateID,
	}))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	// Verify AddExercise was called exactly twice (rest item skipped)
	if len(addExerciseCalls) != 2 {
		t.Fatalf("expected 2 AddExercise calls, got %d", len(addExerciseCalls))
	}

	// Verify first exercise: Bench Press at display_order 1 (preserved from template)
	if addExerciseCalls[0].exerciseID != exerciseID1 {
		t.Errorf("first exercise: expected %s, got %s", exerciseID1, addExerciseCalls[0].exerciseID)
	}
	if addExerciseCalls[0].displayOrder != 1 {
		t.Errorf("first exercise display_order: expected 1, got %d", addExerciseCalls[0].displayOrder)
	}

	// Verify second exercise: Squat at display_order 3 (preserved from template, rest item at 2 skipped)
	if addExerciseCalls[1].exerciseID != exerciseID2 {
		t.Errorf("second exercise: expected %s, got %s", exerciseID2, addExerciseCalls[1].exerciseID)
	}
	if addExerciseCalls[1].displayOrder != 3 {
		t.Errorf("second exercise display_order: expected 3, got %d", addExerciseCalls[1].displayOrder)
	}

	// Verify response session has exercises in correct order
	if resp.Msg.Session == nil {
		t.Fatal("expected session in response")
	}
	if len(resp.Msg.Session.Exercises) != 2 {
		t.Fatalf("expected 2 exercises in response, got %d", len(resp.Msg.Session.Exercises))
	}
	if resp.Msg.Session.Exercises[0].DisplayOrder != 1 {
		t.Errorf("response exercise[0] display_order: expected 1, got %d", resp.Msg.Session.Exercises[0].DisplayOrder)
	}
	if resp.Msg.Session.Exercises[1].DisplayOrder != 3 {
		t.Errorf("response exercise[1] display_order: expected 3, got %d", resp.Msg.Session.Exercises[1].DisplayOrder)
	}
	if resp.Msg.Session.Exercises[0].ExerciseId != exerciseID1 {
		t.Errorf("response exercise[0] ID: expected %s, got %s", exerciseID1, resp.Msg.Session.Exercises[0].ExerciseId)
	}
	if resp.Msg.Session.Exercises[1].ExerciseId != exerciseID2 {
		t.Errorf("response exercise[1] ID: expected %s, got %s", exerciseID2, resp.Msg.Session.Exercises[1].ExerciseId)
	}
}
