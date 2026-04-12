package handlers

import (
	"context"
	"errors"

	"connectrpc.com/connect"
	"github.com/google/uuid"
	"google.golang.org/protobuf/types/known/timestamppb"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/convert"
	"github.com/heftyback/internal/repository"
)

// SessionHandler implements the SessionService
type SessionHandler struct {
	sessionRepo repository.SessionRepositoryInterface
	workoutRepo repository.WorkoutRepositoryInterface
	programRepo repository.ProgramRepositoryInterface
}

// NewSessionHandler creates a new SessionHandler
func NewSessionHandler(sessionRepo repository.SessionRepositoryInterface, workoutRepo repository.WorkoutRepositoryInterface, programRepo repository.ProgramRepositoryInterface) *SessionHandler {
	return &SessionHandler{
		sessionRepo: sessionRepo,
		workoutRepo: workoutRepo,
		programRepo: programRepo,
	}
}

// StartSession starts a new workout session
func (h *SessionHandler) StartSession(ctx context.Context, req *connect.Request[heftv1.StartSessionRequest]) (*connect.Response[heftv1.StartSessionResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
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

	// If based on template, get workout to use its name and exercises
	var workout *repository.WorkoutTemplate
	if workoutTemplateID != nil {
		workout, err = h.workoutRepo.GetByID(ctx, *workoutTemplateID, userID)
		if err != nil {
			return nil, handleDBError(err)
		}
		if workout == nil {
			return nil, connect.NewError(connect.CodeNotFound, errors.New("workout template not found"))
		}
		// Use workout name if not provided in request
		if name == nil {
			name = &workout.Name
		}
	}

	// Create session
	session, err := h.sessionRepo.Create(ctx, userID, workoutTemplateID, programID, programDayNumber, name)
	if err != nil {
		return nil, handleDBError(err)
	}

	// If based on template, populate exercises from template
	if workout != nil {
		for _, section := range workout.Sections {
			// Generate a superset ID if section is a superset
			var supersetID *string
			if section.IsSuperset {
				id := uuid.New().String()
				supersetID = &id
			}

			for _, item := range section.Items {
				if item.ItemType == "exercise" && item.ExerciseID != nil {
					exercise, err := h.sessionRepo.AddExercise(ctx, session.ID, *item.ExerciseID, item.DisplayOrder, &section.Name, supersetID)
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
						_, err := h.sessionRepo.AddSet(ctx, exercise.ID, ts.SetNumber, ts.TargetWeightKg, targetReps, targetTime, ts.RestDurationSeconds, ts.IsBodyweight)
						if err != nil {
							return nil, handleDBError(err)
						}
					}
				} else if item.ItemType == "rest" && item.RestDurationSeconds != nil && *item.RestDurationSeconds > 0 {
					// Add rest item from template
					_, err := h.sessionRepo.AddRestItem(ctx, session.ID, item.DisplayOrder, &section.Name, *item.RestDurationSeconds)
					if err != nil {
						return nil, handleDBError(err)
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
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
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
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.SessionId, "session_id"); err != nil {
		return nil, err
	}

	// Verify session belongs to user
	session, err := h.sessionRepo.GetByID(ctx, req.Msg.SessionId, userID)
	if err != nil {
		return nil, handleDBError(err)
	}
	if session == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("session not found"))
	}

	// Process exercises: new exercises first, then updates
	for _, exerciseData := range req.Msg.Exercises {
		if newEx := exerciseData.GetNewExercise(); newEx != nil {
			var sectionName *string
			if newEx.SectionName != "" {
				sectionName = &newEx.SectionName
			}

			var supersetID *string
			if newEx.SupersetId != nil && *newEx.SupersetId != "" {
				supersetID = newEx.SupersetId
			}

			exercise, err := h.sessionRepo.AddExercise(ctx, req.Msg.SessionId, newEx.ExerciseId, int(newEx.DisplayOrder), sectionName, supersetID)
			if err != nil {
				return nil, handleDBError(err)
			}

			// Create N empty sets for the new exercise
			numSets := int(newEx.NumSets)
			if numSets <= 0 {
				numSets = 3 // Default to 3 sets
			}
			for i := 1; i <= numSets; i++ {
				_, err := h.sessionRepo.AddSet(ctx, exercise.ID, i, nil, nil, nil, nil, false)
				if err != nil {
					return nil, handleDBError(err)
				}
			}
		} else if updateEx := exerciseData.GetUpdateExercise(); updateEx != nil {
			// Process exercise updates (section_name, display_order, superset_id)
			params := repository.UpdateExerciseParams{}

			if updateEx.SectionName != nil {
				params.SectionName = updateEx.SectionName
			}
			if updateEx.DisplayOrder != nil {
				v := int(*updateEx.DisplayOrder)
				params.DisplayOrder = &v
			}
			if updateEx.SupersetId != nil {
				params.SupersetID = updateEx.SupersetId
			}

			err := h.sessionRepo.UpdateExercise(ctx, req.Msg.SessionId, updateEx.Id, params)
			if err != nil {
				return nil, handleDBError(err)
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

	// Process deletions first (before sync to avoid conflicts)
	if len(req.Msg.DeletedSetIds) > 0 {
		err = h.sessionRepo.DeleteSets(ctx, req.Msg.SessionId, req.Msg.DeletedSetIds)
		if err != nil {
			return nil, handleDBError(err)
		}
	}
	if len(req.Msg.DeletedExerciseIds) > 0 {
		err = h.sessionRepo.DeleteExercises(ctx, req.Msg.SessionId, req.Msg.DeletedExerciseIds)
		if err != nil {
			return nil, handleDBError(err)
		}
	}

	// Perform sync
	err = h.sessionRepo.SyncSets(ctx, req.Msg.SessionId, sets)
	if err != nil {
		return nil, handleDBError(err)
	}

	// Sync rest items if any
	if len(req.Msg.RestItems) > 0 {
		restItems := make([]repository.SyncRestItemInput, len(req.Msg.RestItems))
		for i, ri := range req.Msg.RestItems {
			restItems[i] = repository.SyncRestItemInput{
				ID:          ri.Id,
				IsCompleted: ri.IsCompleted,
			}
		}
		err = h.sessionRepo.SyncRestItems(ctx, req.Msg.SessionId, restItems)
		if err != nil {
			return nil, handleDBError(err)
		}
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
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
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

	// Archive program if this was the last day
	if session.ProgramID != nil && session.ProgramDayNumber != nil {
		program, err := h.programRepo.GetByID(ctx, *session.ProgramID, userID)
		if err == nil && program != nil {
			totalDays := program.DurationWeeks*7 + program.DurationDays
			if totalDays > 0 && *session.ProgramDayNumber >= totalDays {
				_ = h.programRepo.Archive(ctx, program.ID, userID)
			}
		}
	}

	return connect.NewResponse(&heftv1.FinishSessionResponse{
		Session: sessionToProto(session),
	}), nil
}

// AbandonSession marks the session as abandoned
func (h *SessionHandler) AbandonSession(ctx context.Context, req *connect.Request[heftv1.AbandonSessionRequest]) (*connect.Response[heftv1.AbandonSessionResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
	}

	err = h.sessionRepo.AbandonSession(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.AbandonSessionResponse{
		Success: true,
	}), nil
}

// ListSessions lists sessions for a user
func (h *SessionHandler) ListSessions(ctx context.Context, req *connect.Request[heftv1.ListSessionsRequest]) (*connect.Response[heftv1.ListSessionsResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}

	var status *string
	if req.Msg.Status != nil && *req.Msg.Status != heftv1.WorkoutStatus_WORKOUT_STATUS_UNSPECIFIED {
		s := convert.WorkoutStatusToString(*req.Msg.Status)
		status = &s
	}
	startDate := parseOptionalDate(req.Msg.StartDate)
	endDate := parseOptionalDate(req.Msg.EndDate)

	page, pageSize, offset := extractPagination(req.Msg.Pagination, 20)
	sessions, totalCount, err := h.sessionRepo.List(ctx, userID, status, startDate, endDate, int(pageSize), int(offset))
	if err != nil {
		return nil, handleDBError(err)
	}

	protoSessions := mapSlice(sessions, func(s *repository.WorkoutSession) *heftv1.SessionSummary {
		return sessionSummaryToProto(s)
	})

	return connect.NewResponse(&heftv1.ListSessionsResponse{
		Sessions:   protoSessions,
		Pagination: buildPaginationResponse(page, pageSize, totalCount),
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
		Status:        convert.StringToWorkoutStatus(s.Status),
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

	restItems := make([]*heftv1.SessionRestItem, len(s.RestItems))
	for i, ri := range s.RestItems {
		restItems[i] = sessionRestItemToProto(ri)
	}
	session.RestItems = restItems

	return session
}

func sessionSummaryToProto(s *repository.WorkoutSession) *heftv1.SessionSummary {
	ss := &heftv1.SessionSummary{
		Id:            s.ID,
		UserId:        s.UserID,
		Status:        convert.StringToWorkoutStatus(s.Status),
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
		ExerciseType: convert.StringToExerciseType(e.ExerciseType),
		DisplayOrder: int32(e.DisplayOrder),
	}
	if e.SectionName != nil {
		se.SectionName = *e.SectionName
	}
	if e.SupersetID != nil {
		se.SupersetId = e.SupersetID
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
	if s.RestDurationSeconds != nil {
		v := int32(*s.RestDurationSeconds)
		set.RestDurationSeconds = &v
	}
	if s.RPE != nil {
		set.Rpe = s.RPE
	}
	if s.Notes != nil {
		set.Notes = *s.Notes
	}
	return set
}

func sessionRestItemToProto(ri *repository.SessionRestItem) *heftv1.SessionRestItem {
	item := &heftv1.SessionRestItem{
		Id:                  ri.ID,
		SessionId:           ri.SessionID,
		DisplayOrder:        int32(ri.DisplayOrder),
		RestDurationSeconds: int32(ri.RestDurationSeconds),
		IsCompleted:         ri.IsCompleted,
	}
	if ri.SectionName != nil {
		item.SectionName = *ri.SectionName
	}
	if ri.CompletedAt != nil {
		item.CompletedAt = timestamppb.New(*ri.CompletedAt)
	}
	return item
}

