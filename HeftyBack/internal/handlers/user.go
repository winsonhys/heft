package handlers

import (
	"context"
	"errors"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/repository"
)

// UserHandler implements the UserService
type UserHandler struct {
	repo repository.UserRepositoryInterface
}

// NewUserHandler creates a new UserHandler
func NewUserHandler(repo repository.UserRepositoryInterface) *UserHandler {
	return &UserHandler{repo: repo}
}

// GetProfile retrieves a user's profile
func (h *UserHandler) GetProfile(ctx context.Context, req *connect.Request[heftv1.GetProfileRequest]) (*connect.Response[heftv1.GetProfileResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	user, err := h.repo.GetByID(ctx, userID)
	if err != nil {
		return nil, handleDBError(err)
	}
	if user == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("user not found"))
	}

	return connect.NewResponse(&heftv1.GetProfileResponse{
		User: userToProto(user),
	}), nil
}

// UpdateProfile updates a user's profile
func (h *UserHandler) UpdateProfile(ctx context.Context, req *connect.Request[heftv1.UpdateProfileRequest]) (*connect.Response[heftv1.UpdateProfileResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	var displayName, avatarURL *string
	if req.Msg.DisplayName != nil {
		displayName = req.Msg.DisplayName
	}
	if req.Msg.AvatarUrl != nil {
		avatarURL = req.Msg.AvatarUrl
	}

	user, err := h.repo.UpdateProfile(ctx, userID, displayName, avatarURL)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.UpdateProfileResponse{
		User: userToProto(user),
	}), nil
}

// UpdateSettings updates a user's settings
func (h *UserHandler) UpdateSettings(ctx context.Context, req *connect.Request[heftv1.UpdateSettingsRequest]) (*connect.Response[heftv1.UpdateSettingsResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	var usePounds *bool
	var restTimerSeconds *int
	if req.Msg.UsePounds != nil {
		usePounds = req.Msg.UsePounds
	}
	if req.Msg.RestTimerSeconds != nil {
		v := int(*req.Msg.RestTimerSeconds)
		restTimerSeconds = &v
	}

	user, err := h.repo.UpdateSettings(ctx, userID, usePounds, restTimerSeconds)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.UpdateSettingsResponse{
		User: userToProto(user),
	}), nil
}

// LogWeight logs a user's weight
func (h *UserHandler) LogWeight(ctx context.Context, req *connect.Request[heftv1.LogWeightRequest]) (*connect.Response[heftv1.LogWeightResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.WeightKg <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("weight_kg must be positive"))
	}

	loggedDate, err := time.Parse("2006-01-02", req.Msg.LoggedDate)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("logged_date must be in YYYY-MM-DD format"))
	}

	var notes *string
	if req.Msg.Notes != nil {
		notes = req.Msg.Notes
	}

	log, err := h.repo.LogWeight(ctx, userID, req.Msg.WeightKg, loggedDate, notes)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.LogWeightResponse{
		WeightLog: weightLogToProto(log),
	}), nil
}

// GetWeightHistory retrieves weight history
func (h *UserHandler) GetWeightHistory(ctx context.Context, req *connect.Request[heftv1.GetWeightHistoryRequest]) (*connect.Response[heftv1.GetWeightHistoryResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	var startDate, endDate *time.Time
	if req.Msg.StartDate != nil && *req.Msg.StartDate != "" {
		t, err := time.Parse("2006-01-02", *req.Msg.StartDate)
		if err == nil {
			startDate = &t
		}
	}
	if req.Msg.EndDate != nil && *req.Msg.EndDate != "" {
		t, err := time.Parse("2006-01-02", *req.Msg.EndDate)
		if err == nil {
			endDate = &t
		}
	}

	limit := 100
	if req.Msg.Limit != nil && *req.Msg.Limit > 0 {
		limit = int(*req.Msg.Limit)
	}

	logs, err := h.repo.GetWeightHistory(ctx, userID, startDate, endDate, limit)
	if err != nil {
		return nil, handleDBError(err)
	}

	protoLogs := make([]*heftv1.WeightLog, len(logs))
	for i, log := range logs {
		protoLogs[i] = weightLogToProto(log)
	}

	return connect.NewResponse(&heftv1.GetWeightHistoryResponse{
		WeightLogs: protoLogs,
	}), nil
}

// DeleteWeightLog deletes a weight log entry
func (h *UserHandler) DeleteWeightLog(ctx context.Context, req *connect.Request[heftv1.DeleteWeightLogRequest]) (*connect.Response[heftv1.DeleteWeightLogResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	err := h.repo.DeleteWeightLog(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.DeleteWeightLogResponse{
		Success: true,
	}), nil
}

// Helper functions
func userToProto(u *repository.User) *heftv1.User {
	user := &heftv1.User{
		Id:               u.ID,
		Email:            u.Email,
		UsePounds:        u.UsePounds,
		RestTimerSeconds: int32(u.RestTimerSeconds),
		MemberSince:      timestamppb.New(u.MemberSince),
		CreatedAt:        timestamppb.New(u.CreatedAt),
		UpdatedAt:        timestamppb.New(u.UpdatedAt),
	}
	if u.DisplayName != nil {
		user.DisplayName = *u.DisplayName
	}
	if u.AvatarURL != nil {
		user.AvatarUrl = *u.AvatarURL
	}
	return user
}

func weightLogToProto(log *repository.WeightLog) *heftv1.WeightLog {
	wl := &heftv1.WeightLog{
		Id:         log.ID,
		UserId:     log.UserID,
		WeightKg:   log.WeightKg,
		LoggedDate: log.LoggedDate.Format("2006-01-02"),
		CreatedAt:  timestamppb.New(log.CreatedAt),
	}
	if log.Notes != nil {
		wl.Notes = *log.Notes
	}
	return wl
}
