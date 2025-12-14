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

func TestUserHandler_GetProfile(t *testing.T) {
	tests := []struct {
		name        string
		userID      string
		withAuth    bool
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name:     "success - user found",
			userID:   "user-123",
			withAuth: true,
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
			name:     "error - not authenticated",
			userID:   "",
			withAuth: false,
			mockSetup: func(m *testutil.MockUserRepository) {
				// No mock needed - authentication check happens first
			},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
		{
			name:     "error - user not found",
			userID:   "nonexistent",
			withAuth: true,
			mockSetup: func(m *testutil.MockUserRepository) {
				m.GetByIDFunc = func(ctx context.Context, id string) (*repository.User, error) {
					return nil, nil // Not found returns nil, nil
				}
			},
			wantErr:     true,
			wantErrCode: connect.CodeNotFound,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
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

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.GetProfileRequest{})

			resp, err := handler.GetProfile(ctx, req)

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
		userID      string
		withAuth    bool
		displayName *string
		avatarURL   *string
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name:     "success - update display name",
			userID:   "user-123",
			withAuth: true,
			displayName: func() *string {
				s := "New Name"
				return &s
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
			name:        "error - not authenticated",
			userID:      "",
			withAuth:    false,
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockUserRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewUserHandler(mockRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.UpdateProfileRequest{
				DisplayName: tt.displayName,
				AvatarUrl:   tt.avatarURL,
			})
			resp, err := handler.UpdateProfile(ctx, req)

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
		name             string
		userID           string
		withAuth         bool
		usePounds        *bool
		restTimerSeconds *int32
		mockSetup        func(*testutil.MockUserRepository)
		wantErr          bool
		wantErrCode      connect.Code
	}{
		{
			name:     "success - update use_pounds",
			userID:   "user-123",
			withAuth: true,
			usePounds: func() *bool {
				b := true
				return &b
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
			name:     "success - update rest_timer_seconds",
			userID:   "user-123",
			withAuth: true,
			restTimerSeconds: func() *int32 {
				i := int32(90)
				return &i
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
			name:        "error - not authenticated",
			userID:      "",
			withAuth:    false,
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockUserRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewUserHandler(mockRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.UpdateSettingsRequest{
				UsePounds:        tt.usePounds,
				RestTimerSeconds: tt.restTimerSeconds,
			})
			resp, err := handler.UpdateSettings(ctx, req)

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
		userID      string
		withAuth    bool
		weightKg    float64
		loggedDate  string
		notes       *string
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name:       "success - weight logged",
			userID:     "user-123",
			withAuth:   true,
			weightKg:   75.5,
			loggedDate: "2024-01-15",
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
			name:     "success - weight logged with notes",
			userID:   "user-123",
			withAuth: true,
			weightKg: 75.5,
			notes: func() *string {
				s := "Morning weight"
				return &s
			}(),
			loggedDate: "2024-01-15",
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
			name:        "error - not authenticated",
			userID:      "",
			withAuth:    false,
			weightKg:    75.5,
			loggedDate:  "2024-01-15",
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
		{
			name:        "error - invalid weight (zero)",
			userID:      "user-123",
			withAuth:    true,
			weightKg:    0,
			loggedDate:  "2024-01-15",
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:        "error - negative weight",
			userID:      "user-123",
			withAuth:    true,
			weightKg:    -5.0,
			loggedDate:  "2024-01-15",
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:        "error - invalid date format",
			userID:      "user-123",
			withAuth:    true,
			weightKg:    75.5,
			loggedDate:  "01-15-2024", // Wrong format
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

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.LogWeightRequest{
				WeightKg:   tt.weightKg,
				LoggedDate: tt.loggedDate,
				Notes:      tt.notes,
			})
			resp, err := handler.LogWeight(ctx, req)

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
		userID      string
		withAuth    bool
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
		wantCount   int
	}{
		{
			name:     "success - returns weight history",
			userID:   "user-123",
			withAuth: true,
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
			name:     "success - empty history",
			userID:   "user-123",
			withAuth: true,
			mockSetup: func(m *testutil.MockUserRepository) {
				m.GetWeightHistoryFunc = func(ctx context.Context, userID string, startDate, endDate *time.Time, limit int) ([]*repository.WeightLog, error) {
					return []*repository.WeightLog{}, nil
				}
			},
			wantErr:   false,
			wantCount: 0,
		},
		{
			name:        "error - not authenticated",
			userID:      "",
			withAuth:    false,
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockRepo := &testutil.MockUserRepository{}
			tt.mockSetup(mockRepo)

			handler := handlers.NewUserHandler(mockRepo)

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.GetWeightHistoryRequest{})
			resp, err := handler.GetWeightHistory(ctx, req)

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
		userID      string
		withAuth    bool
		logID       string
		mockSetup   func(*testutil.MockUserRepository)
		wantErr     bool
		wantErrCode connect.Code
	}{
		{
			name:     "success - weight log deleted",
			userID:   "user-123",
			withAuth: true,
			logID:    "log-123",
			mockSetup: func(m *testutil.MockUserRepository) {
				m.DeleteWeightLogFunc = func(ctx context.Context, id, userID string) error {
					return nil
				}
			},
			wantErr: false,
		},
		{
			name:        "error - missing id",
			userID:      "user-123",
			withAuth:    true,
			logID:       "",
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeInvalidArgument,
		},
		{
			name:        "error - not authenticated",
			userID:      "",
			withAuth:    false,
			logID:       "log-123",
			mockSetup:   func(m *testutil.MockUserRepository) {},
			wantErr:     true,
			wantErrCode: connect.CodeUnauthenticated,
		},
		{
			name:     "error - database error",
			userID:   "user-123",
			withAuth: true,
			logID:    "log-123",
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

			ctx := context.Background()
			if tt.withAuth {
				ctx = auth.ContextWithUserID(ctx, tt.userID)
			}

			req := connect.NewRequest(&heftv1.DeleteWeightLogRequest{
				Id: tt.logID,
			})
			resp, err := handler.DeleteWeightLog(ctx, req)

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
