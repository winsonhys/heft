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

func TestUserHandler_GetProfile(t *testing.T) {
	tests := []struct {
		name        string
		userID      string
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name:   "success - user found",
			userID: "user-123",
			mockSetup: func(m *testutil.MockUserRepository) {
				m.GetByIDFunc = func(ctx context.Context, id string) (*repository.User, error) {
					displayName := "Test User"
					return &repository.User{
						ID:               id,
						Email:            "test@example.com",
						DisplayName:      &displayName,
						UsePounds:        false,
						RestTimerSeconds: 120,
						MemberSince:      time.Now(),
						CreatedAt:        time.Now(),
						UpdatedAt:        time.Now(),
					}, nil
				}
			},
			wantErr: false,
		},
		{
			name:   "error - empty user_id",
			userID: "",
			mockSetup: func(m *testutil.MockUserRepository) {
				// No mock needed - validation happens before repo call
			},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:   "error - user not found",
			userID: "nonexistent",
			mockSetup: func(m *testutil.MockUserRepository) {
				m.GetByIDFunc = func(ctx context.Context, id string) (*repository.User, error) {
					return nil, nil // Not found returns nil, nil
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeNotFound,
		},
		{
			name:   "error - database error",
			userID: "user-123",
			mockSetup: func(m *testutil.MockUserRepository) {
				m.GetByIDFunc = func(ctx context.Context, id string) (*repository.User, error) {
					return nil, errors.New("database connection failed")
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockUserRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewUserHandler(mockRepo)

			req := connect.NewRequest(&heftv1.GetProfileRequest{
				UserId: tt.userID,
			})

			resp, err := handler.GetProfile(context.Background(), req)

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
				if resp.Msg.User == nil {
					t.Error("expected user in response")
				}
				if resp.Msg.User.Id != tt.userID {
					t.Errorf("expected user ID %s, got %s", tt.userID, resp.Msg.User.Id)
				}
			}
		})
	}
}

func TestUserHandler_UpdateProfile(t *testing.T) {
	tests := []struct {
		name        string
		request     *heftv1.UpdateProfileRequest
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name: "success - update display name",
			request: func() *heftv1.UpdateProfileRequest {
				displayName := "New Name"
				return &heftv1.UpdateProfileRequest{
					UserId:      "user-123",
					DisplayName: &displayName,
				}
			}(),
			mockSetup: func(m *testutil.MockUserRepository) {
				m.UpdateProfileFunc = func(ctx context.Context, id string, displayName, avatarURL *string) (*repository.User, error) {
					return &repository.User{
						ID:               id,
						Email:            "test@example.com",
						DisplayName:      displayName,
						UsePounds:        false,
						RestTimerSeconds: 120,
						CreatedAt:        time.Now(),
						UpdatedAt:        time.Now(),
					}, nil
				}
			},
			wantErr: false,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.UpdateProfileRequest{
				UserId: "",
			},
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockUserRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewUserHandler(mockRepo)

			req := connect.NewRequest(tt.request)
			resp, err := handler.UpdateProfile(context.Background(), req)

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
				if resp.Msg.User == nil {
					t.Error("expected user in response")
				}
			}
		})
	}
}

func TestUserHandler_UpdateSettings(t *testing.T) {
	tests := []struct {
		name        string
		request     *heftv1.UpdateSettingsRequest
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name: "success - update use_pounds",
			request: func() *heftv1.UpdateSettingsRequest {
				usePounds := true
				return &heftv1.UpdateSettingsRequest{
					UserId:    "user-123",
					UsePounds: &usePounds,
				}
			}(),
			mockSetup: func(m *testutil.MockUserRepository) {
				m.UpdateSettingsFunc = func(ctx context.Context, id string, usePounds *bool, restTimerSeconds *int) (*repository.User, error) {
					return &repository.User{
						ID:               id,
						Email:            "test@example.com",
						UsePounds:        *usePounds,
						RestTimerSeconds: 120,
						CreatedAt:        time.Now(),
						UpdatedAt:        time.Now(),
					}, nil
				}
			},
			wantErr: false,
		},
		{
			name: "success - update rest_timer_seconds",
			request: func() *heftv1.UpdateSettingsRequest {
				restTimer := int32(90)
				return &heftv1.UpdateSettingsRequest{
					UserId:           "user-123",
					RestTimerSeconds: &restTimer,
				}
			}(),
			mockSetup: func(m *testutil.MockUserRepository) {
				m.UpdateSettingsFunc = func(ctx context.Context, id string, usePounds *bool, restTimerSeconds *int) (*repository.User, error) {
					return &repository.User{
						ID:               id,
						Email:            "test@example.com",
						UsePounds:        false,
						RestTimerSeconds: *restTimerSeconds,
						CreatedAt:        time.Now(),
						UpdatedAt:        time.Now(),
					}, nil
				}
			},
			wantErr: false,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.UpdateSettingsRequest{
				UserId: "",
			},
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockUserRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewUserHandler(mockRepo)

			req := connect.NewRequest(tt.request)
			resp, err := handler.UpdateSettings(context.Background(), req)

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
				if resp.Msg.User == nil {
					t.Error("expected user in response")
				}
			}
		})
	}
}

func TestUserHandler_LogWeight(t *testing.T) {
	tests := []struct {
		name        string
		request     *heftv1.LogWeightRequest
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name: "success - weight logged",
			request: &heftv1.LogWeightRequest{
				UserId:     "user-123",
				WeightKg:   75.5,
				LoggedDate: "2024-01-15",
			},
			mockSetup: func(m *testutil.MockUserRepository) {
				m.LogWeightFunc = func(ctx context.Context, userID string, weightKg float64, loggedDate time.Time, notes *string) (*repository.WeightLog, error) {
					return &repository.WeightLog{
						ID:         "log-123",
						UserID:     userID,
						WeightKg:   weightKg,
						LoggedDate: loggedDate,
						CreatedAt:  time.Now(),
					}, nil
				}
			},
			wantErr: false,
		},
		{
			name: "success - weight logged with notes",
			request: func() *heftv1.LogWeightRequest {
				notes := "Morning weight"
				return &heftv1.LogWeightRequest{
					UserId:     "user-123",
					WeightKg:   75.5,
					LoggedDate: "2024-01-15",
					Notes:      &notes,
				}
			}(),
			mockSetup: func(m *testutil.MockUserRepository) {
				m.LogWeightFunc = func(ctx context.Context, userID string, weightKg float64, loggedDate time.Time, notes *string) (*repository.WeightLog, error) {
					return &repository.WeightLog{
						ID:         "log-123",
						UserID:     userID,
						WeightKg:   weightKg,
						LoggedDate: loggedDate,
						Notes:      notes,
						CreatedAt:  time.Now(),
					}, nil
				}
			},
			wantErr: false,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.LogWeightRequest{
				UserId:     "",
				WeightKg:   75.5,
				LoggedDate: "2024-01-15",
			},
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name: "error - invalid weight (zero)",
			request: &heftv1.LogWeightRequest{
				UserId:     "user-123",
				WeightKg:   0,
				LoggedDate: "2024-01-15",
			},
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name: "error - negative weight",
			request: &heftv1.LogWeightRequest{
				UserId:     "user-123",
				WeightKg:   -5.0,
				LoggedDate: "2024-01-15",
			},
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name: "error - invalid date format",
			request: &heftv1.LogWeightRequest{
				UserId:     "user-123",
				WeightKg:   75.5,
				LoggedDate: "01-15-2024", // Wrong format
			},
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockUserRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewUserHandler(mockRepo)

			req := connect.NewRequest(tt.request)
			resp, err := handler.LogWeight(context.Background(), req)

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
				if resp.Msg.WeightLog == nil {
					t.Error("expected weight log in response")
				}
			}
		})
	}
}

func TestUserHandler_GetWeightHistory(t *testing.T) {
	tests := []struct {
		name        string
		request     *heftv1.GetWeightHistoryRequest
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
		wantCount   int
	}{
		{
			name: "success - returns weight history",
			request: &heftv1.GetWeightHistoryRequest{
				UserId: "user-123",
			},
			mockSetup: func(m *testutil.MockUserRepository) {
				m.GetWeightHistoryFunc = func(ctx context.Context, userID string, startDate, endDate *time.Time, limit int) ([]*repository.WeightLog, error) {
					return []*repository.WeightLog{
						{ID: "log-1", UserID: userID, WeightKg: 75.0, LoggedDate: time.Now().AddDate(0, 0, -1), CreatedAt: time.Now()},
						{ID: "log-2", UserID: userID, WeightKg: 74.5, LoggedDate: time.Now().AddDate(0, 0, -2), CreatedAt: time.Now()},
					}, nil
				}
			},
			wantErr:   false,
			wantCount: 2,
		},
		{
			name: "success - empty history",
			request: &heftv1.GetWeightHistoryRequest{
				UserId: "user-123",
			},
			mockSetup: func(m *testutil.MockUserRepository) {
				m.GetWeightHistoryFunc = func(ctx context.Context, userID string, startDate, endDate *time.Time, limit int) ([]*repository.WeightLog, error) {
					return []*repository.WeightLog{}, nil
				}
			},
			wantErr:   false,
			wantCount: 0,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.GetWeightHistoryRequest{
				UserId: "",
			},
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockUserRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewUserHandler(mockRepo)

			req := connect.NewRequest(tt.request)
			resp, err := handler.GetWeightHistory(context.Background(), req)

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
				if len(resp.Msg.WeightLogs) != tt.wantCount {
					t.Errorf("expected %d weight logs, got %d", tt.wantCount, len(resp.Msg.WeightLogs))
				}
			}
		})
	}
}

func TestUserHandler_DeleteWeightLog(t *testing.T) {
	tests := []struct {
		name        string
		request     *heftv1.DeleteWeightLogRequest
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name: "success - weight log deleted",
			request: &heftv1.DeleteWeightLogRequest{
				Id:     "log-123",
				UserId: "user-123",
			},
			mockSetup: func(m *testutil.MockUserRepository) {
				m.DeleteWeightLogFunc = func(ctx context.Context, id, userID string) error {
					return nil
				}
			},
			wantErr: false,
		},
		{
			name: "error - missing id",
			request: &heftv1.DeleteWeightLogRequest{
				Id:     "",
				UserId: "user-123",
			},
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name: "error - missing user_id",
			request: &heftv1.DeleteWeightLogRequest{
				Id:     "log-123",
				UserId: "",
			},
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name: "error - database error",
			request: &heftv1.DeleteWeightLogRequest{
				Id:     "log-123",
				UserId: "user-123",
			},
			mockSetup: func(m *testutil.MockUserRepository) {
				m.DeleteWeightLogFunc = func(ctx context.Context, id, userID string) error {
					return errors.New("database error")
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeInternal,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockUserRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewUserHandler(mockRepo)

			req := connect.NewRequest(tt.request)
			resp, err := handler.DeleteWeightLog(context.Background(), req)

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
				if !resp.Msg.Success {
					t.Error("expected success to be true")
				}
			}
		})
	}
}
