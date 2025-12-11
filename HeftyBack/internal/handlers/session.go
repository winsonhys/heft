package handlers

import (
	"context"
	"errors"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/repository"
)

// SessionHandler implements the SessionService
type SessionHandler struct {
	sessionRepo repository.SessionRepositoryInterface
	workoutRepo repository.WorkoutRepositoryInterface
}

// NewSessionHandler creates a new SessionHandler
func NewSessionHandler(sessionRepo repository.SessionRepositoryInterface, workoutRepo repository.WorkoutRepositoryInterface) *SessionHandler {
	return &SessionHandler{
		sessionRepo: sessionRepo,
		workoutRepo: workoutRepo,
	}
}

// StartSession starts a new workout session
func (h *SessionHandler) StartSession(ctx context.Context, req *connect.Request[heftv1.StartSessionRequest]) (*connect.Response[heftv1.StartSessionResponse], error) {
	if req.Msg.UserId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("user_id is required"))
	}

	var workoutTemplateID, programID, name *string
	var programDayNumber *int
	if req.Msg.WorkoutTemplateId != nil {
		workoutTemplateID = req.Msg.WorkoutTemplateId
	}
	if req.Msg.ProgramId != nil {
		programID = req.Msg.ProgramId
	}
	if req.Msg.ProgramDayNumber != nil {
		v := int(*req.Msg.ProgramDayNumber)
		programDayNumber = &v
	}
	if req.Msg.Name != nil {
		name = req.Msg.Name
	}

	// Create session
	session, err := h.sessionRepo.Create(ctx, req.Msg.UserId, workoutTemplateID, programID, programDayNumber, name)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// If based on template, populate exercises from template
	if workoutTemplateID != nil {
		workout, err := h.workoutRepo.GetByID(ctx, *workoutTemplateID, req.Msg.UserId)
		if err == nil && workout != nil {
			displayOrder := 0
			for _, section := range workout.Sections {
				for _, item := range section.Items {
					if item.ItemType == "exercise" && item.ExerciseID != nil {
						exercise, err := h.sessionRepo.AddExercise(ctx, session.ID, *item.ExerciseID, displayOrder, &section.Name)
						if err != nil {
							return nil, connect.NewError(connect.CodeInternal, err)
						}

						// Add sets from template
						for _, ts := range item.TargetSets {
							var targetReps, targetTime *int
							if ts.TargetReps != nil {
								targetReps = ts.TargetReps
							}
							if ts.TargetTimeSeconds != nil {
								targetTime = ts.TargetTimeSeconds
							}
							_, err := h.sessionRepo.AddSet(ctx, exercise.ID, ts.SetNumber, ts.TargetWeightKg, targetReps, targetTime, ts.IsBodyweight)
							if err != nil {
								return nil, connect.NewError(connect.CodeInternal, err)
							}
						}
						displayOrder++
					}
				}
			}
		}
	}

	// Reload session with all details
	session, err = h.sessionRepo.GetByID(ctx, session.ID, req.Msg.UserId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.StartSessionResponse{
		Session: sessionToProto(session),
	}), nil
}

// GetSession retrieves a session with full details
func (h *SessionHandler) GetSession(ctx context.Context, req *connect.Request[heftv1.GetSessionRequest]) (*connect.Response[heftv1.GetSessionResponse], error) {
	if req.Msg.Id == "" || req.Msg.UserId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id and user_id are required"))
	}

	session, err := h.sessionRepo.GetByID(ctx, req.Msg.Id, req.Msg.UserId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if session == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("session not found"))
	}

	return connect.NewResponse(&heftv1.GetSessionResponse{
		Session: sessionToProto(session),
	}), nil
}

// CompleteSet marks a set as completed
func (h *SessionHandler) CompleteSet(ctx context.Context, req *connect.Request[heftv1.CompleteSetRequest]) (*connect.Response[heftv1.CompleteSetResponse], error) {
	if req.Msg.SessionSetId == "" || req.Msg.UserId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("session_set_id and user_id are required"))
	}

	var weightKg, distanceM, rpe *float64
	var reps, timeSeconds *int
	var notes *string

	if req.Msg.WeightKg != nil {
		weightKg = req.Msg.WeightKg
	}
	if req.Msg.Reps != nil {
		v := int(*req.Msg.Reps)
		reps = &v
	}
	if req.Msg.TimeSeconds != nil {
		v := int(*req.Msg.TimeSeconds)
		timeSeconds = &v
	}
	if req.Msg.DistanceM != nil {
		distanceM = req.Msg.DistanceM
	}
	if req.Msg.Rpe != nil {
		rpe = req.Msg.Rpe
	}
	if req.Msg.Notes != nil {
		notes = req.Msg.Notes
	}

	set, err := h.sessionRepo.CompleteSet(ctx, req.Msg.SessionSetId, weightKg, reps, timeSeconds, distanceM, rpe, notes)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// TODO: Check for personal record
	isPR := false

	return connect.NewResponse(&heftv1.CompleteSetResponse{
		Set:              sessionSetToProto(set),
		IsPersonalRecord: isPR,
	}), nil
}

// UpdateSet updates set values
func (h *SessionHandler) UpdateSet(ctx context.Context, req *connect.Request[heftv1.UpdateSetRequest]) (*connect.Response[heftv1.UpdateSetResponse], error) {
	if req.Msg.SessionSetId == "" || req.Msg.UserId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("session_set_id and user_id are required"))
	}

	// For now, use CompleteSet logic
	var weightKg, distanceM, rpe *float64
	var reps, timeSeconds *int
	var notes *string

	if req.Msg.WeightKg != nil {
		weightKg = req.Msg.WeightKg
	}
	if req.Msg.Reps != nil {
		v := int(*req.Msg.Reps)
		reps = &v
	}
	if req.Msg.TimeSeconds != nil {
		v := int(*req.Msg.TimeSeconds)
		timeSeconds = &v
	}
	if req.Msg.DistanceM != nil {
		distanceM = req.Msg.DistanceM
	}
	if req.Msg.Rpe != nil {
		rpe = req.Msg.Rpe
	}
	if req.Msg.Notes != nil {
		notes = req.Msg.Notes
	}

	set, err := h.sessionRepo.CompleteSet(ctx, req.Msg.SessionSetId, weightKg, reps, timeSeconds, distanceM, rpe, notes)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.UpdateSetResponse{
		Set: sessionSetToProto(set),
	}), nil
}

// AddExercise adds an exercise to the session
func (h *SessionHandler) AddExercise(ctx context.Context, req *connect.Request[heftv1.AddExerciseRequest]) (*connect.Response[heftv1.AddExerciseResponse], error) {
	if req.Msg.SessionId == "" || req.Msg.UserId == "" || req.Msg.ExerciseId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("session_id, user_id, and exercise_id are required"))
	}

	var sectionName *string
	if req.Msg.SectionName != nil {
		sectionName = req.Msg.SectionName
	}

	exercise, err := h.sessionRepo.AddExercise(ctx, req.Msg.SessionId, req.Msg.ExerciseId, int(req.Msg.DisplayOrder), sectionName)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Add sets
	numSets := int(req.Msg.NumSets)
	if numSets <= 0 {
		numSets = 3
	}
	for i := 1; i <= numSets; i++ {
		_, err := h.sessionRepo.AddSet(ctx, exercise.ID, i, nil, nil, nil, false)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
	}

	// Reload exercise with sets
	session, err := h.sessionRepo.GetByID(ctx, req.Msg.SessionId, req.Msg.UserId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	var reloadedExercise *repository.SessionExercise
	for _, e := range session.Exercises {
		if e.ID == exercise.ID {
			reloadedExercise = e
			break
		}
	}

	if reloadedExercise == nil {
		return nil, connect.NewError(connect.CodeInternal, errors.New("failed to reload exercise"))
	}

	return connect.NewResponse(&heftv1.AddExerciseResponse{
		Exercise: sessionExerciseToProto(reloadedExercise),
	}), nil
}

// FinishSession completes the workout session
func (h *SessionHandler) FinishSession(ctx context.Context, req *connect.Request[heftv1.FinishSessionRequest]) (*connect.Response[heftv1.FinishSessionResponse], error) {
	if req.Msg.Id == "" || req.Msg.UserId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id and user_id are required"))
	}

	var notes *string
	if req.Msg.Notes != nil {
		notes = req.Msg.Notes
	}

	session, err := h.sessionRepo.FinishSession(ctx, req.Msg.Id, req.Msg.UserId, notes)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Reload with all details
	session, err = h.sessionRepo.GetByID(ctx, session.ID, req.Msg.UserId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.FinishSessionResponse{
		Session: sessionToProto(session),
	}), nil
}

// AbandonSession marks the session as abandoned
func (h *SessionHandler) AbandonSession(ctx context.Context, req *connect.Request[heftv1.AbandonSessionRequest]) (*connect.Response[heftv1.AbandonSessionResponse], error) {
	if req.Msg.Id == "" || req.Msg.UserId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id and user_id are required"))
	}

	err := h.sessionRepo.AbandonSession(ctx, req.Msg.Id, req.Msg.UserId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.AbandonSessionResponse{
		Success: true,
	}), nil
}

// ListSessions lists sessions for a user
func (h *SessionHandler) ListSessions(ctx context.Context, req *connect.Request[heftv1.ListSessionsRequest]) (*connect.Response[heftv1.ListSessionsResponse], error) {
	if req.Msg.UserId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("user_id is required"))
	}

	var status *string
	var startDate, endDate *time.Time

	if req.Msg.Status != nil && *req.Msg.Status != heftv1.WorkoutStatus_WORKOUT_STATUS_UNSPECIFIED {
		s := workoutStatusToString(*req.Msg.Status)
		status = &s
	}
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

	page := int32(1)
	pageSize := int32(20)
	if req.Msg.Pagination != nil {
		if req.Msg.Pagination.Page > 0 {
			page = req.Msg.Pagination.Page
		}
		if req.Msg.Pagination.PageSize > 0 {
			pageSize = req.Msg.Pagination.PageSize
		}
	}

	offset := (page - 1) * pageSize
	sessions, totalCount, err := h.sessionRepo.List(ctx, req.Msg.UserId, status, startDate, endDate, int(pageSize), int(offset))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	protoSessions := make([]*heftv1.SessionSummary, len(sessions))
	for i, s := range sessions {
		protoSessions[i] = sessionSummaryToProto(s)
	}

	totalPages := (int32(totalCount) + pageSize - 1) / pageSize

	return connect.NewResponse(&heftv1.ListSessionsResponse{
		Sessions: protoSessions,
		Pagination: &heftv1.PaginationResponse{
			Page:       page,
			PageSize:   pageSize,
			TotalCount: int32(totalCount),
			TotalPages: totalPages,
		},
	}), nil
}

// Helper functions
func sessionToProto(s *repository.WorkoutSession) *heftv1.Session {
	session := &heftv1.Session{
		Id:            s.ID,
		UserId:        s.UserID,
		Status:        stringToWorkoutStatus(s.Status),
		StartedAt:     timestamppb.New(s.StartedAt),
		TotalSets:     int32(s.TotalSets),
		CompletedSets: int32(s.CompletedSets),
		CreatedAt:     timestamppb.New(s.CreatedAt),
		UpdatedAt:     timestamppb.New(s.UpdatedAt),
	}
	if s.WorkoutTemplateID != nil {
		session.WorkoutTemplateId = *s.WorkoutTemplateID
	}
	if s.ProgramID != nil {
		session.ProgramId = *s.ProgramID
	}
	if s.ProgramDayNumber != nil {
		session.ProgramDayNumber = int32(*s.ProgramDayNumber)
	}
	if s.Name != nil {
		session.Name = *s.Name
	}
	if s.CompletedAt != nil {
		session.CompletedAt = timestamppb.New(*s.CompletedAt)
	}
	if s.DurationSeconds != nil {
		session.DurationSeconds = int32(*s.DurationSeconds)
	}
	if s.Notes != nil {
		session.Notes = *s.Notes
	}

	exercises := make([]*heftv1.SessionExercise, len(s.Exercises))
	for i, e := range s.Exercises {
		exercises[i] = sessionExerciseToProto(e)
	}
	session.Exercises = exercises

	return session
}

func sessionSummaryToProto(s *repository.WorkoutSession) *heftv1.SessionSummary {
	ss := &heftv1.SessionSummary{
		Id:            s.ID,
		UserId:        s.UserID,
		Status:        stringToWorkoutStatus(s.Status),
		StartedAt:     timestamppb.New(s.StartedAt),
		TotalSets:     int32(s.TotalSets),
		CompletedSets: int32(s.CompletedSets),
	}
	if s.Name != nil {
		ss.Name = *s.Name
	}
	if s.CompletedAt != nil {
		ss.CompletedAt = timestamppb.New(*s.CompletedAt)
	}
	if s.DurationSeconds != nil {
		ss.DurationSeconds = int32(*s.DurationSeconds)
	}
	return ss
}

func sessionExerciseToProto(e *repository.SessionExercise) *heftv1.SessionExercise {
	se := &heftv1.SessionExercise{
		Id:           e.ID,
		SessionId:    e.SessionID,
		ExerciseId:   e.ExerciseID,
		ExerciseName: e.ExerciseName,
		ExerciseType: stringToExerciseType(e.ExerciseType),
		DisplayOrder: int32(e.DisplayOrder),
	}
	if e.SectionName != nil {
		se.SectionName = *e.SectionName
	}
	if e.Notes != nil {
		se.Notes = *e.Notes
	}

	sets := make([]*heftv1.SessionSet, len(e.Sets))
	for i, s := range e.Sets {
		sets[i] = sessionSetToProto(s)
	}
	se.Sets = sets

	return se
}

func sessionSetToProto(s *repository.SessionSet) *heftv1.SessionSet {
	set := &heftv1.SessionSet{
		Id:                s.ID,
		SessionExerciseId: s.SessionExerciseID,
		SetNumber:         int32(s.SetNumber),
		IsBodyweight:      s.IsBodyweight,
		IsCompleted:       s.IsCompleted,
	}
	if s.WeightKg != nil {
		set.WeightKg = s.WeightKg
	}
	if s.Reps != nil {
		v := int32(*s.Reps)
		set.Reps = &v
	}
	if s.TimeSeconds != nil {
		v := int32(*s.TimeSeconds)
		set.TimeSeconds = &v
	}
	if s.DistanceM != nil {
		set.DistanceM = s.DistanceM
	}
	if s.CompletedAt != nil {
		set.CompletedAt = timestamppb.New(*s.CompletedAt)
	}
	if s.TargetWeightKg != nil {
		set.TargetWeightKg = s.TargetWeightKg
	}
	if s.TargetReps != nil {
		v := int32(*s.TargetReps)
		set.TargetReps = &v
	}
	if s.TargetTimeSeconds != nil {
		v := int32(*s.TargetTimeSeconds)
		set.TargetTimeSeconds = &v
	}
	if s.RPE != nil {
		set.Rpe = s.RPE
	}
	if s.Notes != nil {
		set.Notes = *s.Notes
	}
	return set
}

func workoutStatusToString(s heftv1.WorkoutStatus) string {
	switch s {
	case heftv1.WorkoutStatus_WORKOUT_STATUS_IN_PROGRESS:
		return "in_progress"
	case heftv1.WorkoutStatus_WORKOUT_STATUS_COMPLETED:
		return "completed"
	case heftv1.WorkoutStatus_WORKOUT_STATUS_ABANDONED:
		return "abandoned"
	default:
		return ""
	}
}

func stringToWorkoutStatus(s string) heftv1.WorkoutStatus {
	switch s {
	case "in_progress":
		return heftv1.WorkoutStatus_WORKOUT_STATUS_IN_PROGRESS
	case "completed":
		return heftv1.WorkoutStatus_WORKOUT_STATUS_COMPLETED
	case "abandoned":
		return heftv1.WorkoutStatus_WORKOUT_STATUS_ABANDONED
	default:
		return heftv1.WorkoutStatus_WORKOUT_STATUS_UNSPECIFIED
	}
}
