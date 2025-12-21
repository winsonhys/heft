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
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	// Check if user already has an in-progress session
	inProgressStatus := "in_progress"
	existingSessions, _, err := h.sessionRepo.List(ctx, userID, &inProgressStatus, nil, nil, 1, 0)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, errors.New("failed to check existing sessions"))
	}
	if len(existingSessions) > 0 {
		return nil, connect.NewError(connect.CodeAlreadyExists, errors.New("user already has an active session"))
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
	session, err := h.sessionRepo.Create(ctx, userID, workoutTemplateID, programID, programDayNumber, name)
	if err != nil {
		return nil, handleDBError(err)
	}

	// If based on template, populate exercises from template
	if workoutTemplateID != nil {
		workout, err := h.workoutRepo.GetByID(ctx, *workoutTemplateID, userID)
		if err == nil && workout != nil {
			displayOrder := 0
			for _, section := range workout.Sections {
				for _, item := range section.Items {
					if item.ItemType == "exercise" && item.ExerciseID != nil {
						exercise, err := h.sessionRepo.AddExercise(ctx, session.ID, *item.ExerciseID, displayOrder, &section.Name)
						if err != nil {
							return nil, handleDBError(err)
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
								return nil, handleDBError(err)
							}
						}
						displayOrder++
					}
				}
			}
		}
	}

	// Reload session with all details
	session, err = h.sessionRepo.GetByID(ctx, session.ID, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.StartSessionResponse{
		Session: sessionToProto(session),
	}), nil
}

// GetSession retrieves a session with full details
func (h *SessionHandler) GetSession(ctx context.Context, req *connect.Request[heftv1.GetSessionRequest]) (*connect.Response[heftv1.GetSessionResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	session, err := h.sessionRepo.GetByID(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, handleDBError(err)
	}
	if session == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("session not found"))
	}

	return connect.NewResponse(&heftv1.GetSessionResponse{
		Session: sessionToProto(session),
	}), nil
}

// SyncSession syncs the full session state from the client
func (h *SessionHandler) SyncSession(ctx context.Context, req *connect.Request[heftv1.SyncSessionRequest]) (*connect.Response[heftv1.SyncSessionResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.SessionId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("session_id is required"))
	}

	// Verify session belongs to user
	session, err := h.sessionRepo.GetByID(ctx, req.Msg.SessionId, userID)
	if err != nil {
		return nil, handleDBError(err)
	}
	if session == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("session not found"))
	}

	// Process new exercises first (so sets can reference them)
	for _, exerciseData := range req.Msg.Exercises {
		if newEx := exerciseData.GetNewExercise(); newEx != nil {
			var sectionName *string
			if newEx.SectionName != "" {
				sectionName = &newEx.SectionName
			}

			exercise, err := h.sessionRepo.AddExercise(ctx, req.Msg.SessionId, newEx.ExerciseId, int(newEx.DisplayOrder), sectionName)
			if err != nil {
				return nil, handleDBError(err)
			}

			// Create N empty sets for the new exercise
			numSets := int(newEx.NumSets)
			if numSets <= 0 {
				numSets = 3 // Default to 3 sets
			}
			for i := 1; i <= numSets; i++ {
				_, err := h.sessionRepo.AddSet(ctx, exercise.ID, i, nil, nil, nil, false)
				if err != nil {
					return nil, handleDBError(err)
				}
			}
		}
	}

	// Convert proto sets to repository input
	sets := make([]repository.SyncSetInput, len(req.Msg.Sets))
	for i, s := range req.Msg.Sets {
		var weightKg, distanceM, rpe *float64
		var reps, timeSeconds *int
		var notes *string
		var setID, sessionExerciseID *string

		if s.WeightKg != nil {
			weightKg = s.WeightKg
		}
		if s.Reps != nil {
			v := int(*s.Reps)
			reps = &v
		}
		if s.TimeSeconds != nil {
			v := int(*s.TimeSeconds)
			timeSeconds = &v
		}
		if s.DistanceM != nil {
			distanceM = s.DistanceM
		}
		if s.Rpe != nil {
			rpe = s.Rpe
		}
		if s.Notes != nil {
			notes = s.Notes
		}

		// Handle oneof: either existing set ID or session_exercise_id for new sets
		if id := s.GetId(); id != "" {
			setID = &id
		}
		if seID := s.GetSessionExerciseId(); seID != "" {
			sessionExerciseID = &seID
		}

		sets[i] = repository.SyncSetInput{
			SetID:             setID,
			SessionExerciseID: sessionExerciseID,
			WeightKg:          weightKg,
			Reps:              reps,
			TimeSeconds:       timeSeconds,
			DistanceM:         distanceM,
			IsCompleted:       s.IsCompleted,
			RPE:               rpe,
			Notes:             notes,
		}
	}

	// Perform sync
	err = h.sessionRepo.SyncSets(ctx, req.Msg.SessionId, sets)
	if err != nil {
		return nil, handleDBError(err)
	}

	// Reload full session
	session, err = h.sessionRepo.GetByID(ctx, req.Msg.SessionId, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.SyncSessionResponse{
		Session: sessionToProto(session),
		Success: true,
	}), nil
}

// FinishSession completes the workout session
func (h *SessionHandler) FinishSession(ctx context.Context, req *connect.Request[heftv1.FinishSessionRequest]) (*connect.Response[heftv1.FinishSessionResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	var notes *string
	if req.Msg.Notes != nil {
		notes = req.Msg.Notes
	}

	session, err := h.sessionRepo.FinishSession(ctx, req.Msg.Id, userID, notes)
	if err != nil {
		return nil, handleDBError(err)
	}

	// Reload with all details
	session, err = h.sessionRepo.GetByID(ctx, session.ID, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.FinishSessionResponse{
		Session: sessionToProto(session),
	}), nil
}

// AbandonSession marks the session as abandoned
func (h *SessionHandler) AbandonSession(ctx context.Context, req *connect.Request[heftv1.AbandonSessionRequest]) (*connect.Response[heftv1.AbandonSessionResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	err := h.sessionRepo.AbandonSession(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.AbandonSessionResponse{
		Success: true,
	}), nil
}

// ListSessions lists sessions for a user
func (h *SessionHandler) ListSessions(ctx context.Context, req *connect.Request[heftv1.ListSessionsRequest]) (*connect.Response[heftv1.ListSessionsResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
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
	sessions, totalCount, err := h.sessionRepo.List(ctx, userID, status, startDate, endDate, int(pageSize), int(offset))
	if err != nil {
		return nil, handleDBError(err)
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
	// Compute total_sets from exercises
	var totalSets int32
	for _, e := range s.Exercises {
		totalSets += int32(len(e.Sets))
	}

	session := &heftv1.Session{
		Id:            s.ID,
		UserId:        s.UserID,
		Status:        stringToWorkoutStatus(s.Status),
		StartedAt:     timestamppb.New(s.StartedAt),
		TotalSets:     totalSets,
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
