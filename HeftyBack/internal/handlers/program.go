package handlers

import (
	"context"
	"errors"
	"time"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/convert"
	"github.com/heftyback/internal/repository"
)

// dateLayout is the YYYY-MM-DD format used across the ProgramService wire API.
const dateLayout = "2006-01-02"

// ProgramHandler implements the ProgramService
type ProgramHandler struct {
	programRepo repository.ProgramRepositoryInterface
	workoutRepo repository.WorkoutRepositoryInterface
}

// NewProgramHandler creates a new ProgramHandler
func NewProgramHandler(programRepo repository.ProgramRepositoryInterface, workoutRepo repository.WorkoutRepositoryInterface) *ProgramHandler {
	return &ProgramHandler{programRepo: programRepo, workoutRepo: workoutRepo}
}

// ListPrograms lists programs for a user
func (h *ProgramHandler) ListPrograms(ctx context.Context, req *connect.Request[heftv1.ListProgramsRequest]) (*connect.Response[heftv1.ListProgramsResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}

	includeArchived := false
	if req.Msg.IncludeArchived != nil {
		includeArchived = *req.Msg.IncludeArchived
	}

	page, pageSize, offset := extractPagination(req.Msg.Pagination, 20)
	programs, totalCount, err := h.programRepo.List(ctx, userID, includeArchived, int(pageSize), int(offset))
	if err != nil {
		return nil, handleDBError(err)
	}

	// Batch-load workout counts for summary display.
	ids := make([]string, len(programs))
	for i, p := range programs {
		ids[i] = p.ID
	}
	counts, err := h.programRepo.ListWorkoutCounts(ctx, ids)
	if err != nil {
		return nil, handleDBError(err)
	}

	protoPrograms := mapSlice(programs, func(p *repository.Program) *heftv1.ProgramSummary {
		return programSummaryToProto(p, counts[p.ID])
	})

	return connect.NewResponse(&heftv1.ListProgramsResponse{
		Programs:   protoPrograms,
		Pagination: buildPaginationResponse(page, pageSize, totalCount),
	}), nil
}

// GetProgram retrieves a program with full details
func (h *ProgramHandler) GetProgram(ctx context.Context, req *connect.Request[heftv1.GetProgramRequest]) (*connect.Response[heftv1.GetProgramResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
	}

	program, err := h.programRepo.GetByID(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, handleDBError(err)
	}
	if program == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("program not found"))
	}

	return connect.NewResponse(&heftv1.GetProgramResponse{
		Program: programToProto(program),
	}), nil
}

// CreateProgram creates a new program and its initial workout assignments.
func (h *ProgramHandler) CreateProgram(ctx context.Context, req *connect.Request[heftv1.CreateProgramRequest]) (*connect.Response[heftv1.CreateProgramResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Name, "name"); err != nil {
		return nil, err
	}

	startDate, err := parseDate(req.Msg.StartDate)
	if err != nil {
		return nil, err
	}
	if req.Msg.DurationWeeks <= 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("duration_weeks must be >= 1"))
	}
	if err := validateWorkoutInputs(req.Msg.Workouts); err != nil {
		return nil, err
	}

	var description *string
	if req.Msg.Description != nil {
		description = req.Msg.Description
	}

	program, err := h.programRepo.Create(ctx, userID, req.Msg.Name, description, startDate, int(req.Msg.DurationWeeks))
	if err != nil {
		return nil, handleDBError(err)
	}

	for i, w := range req.Msg.Workouts {
		if _, err := h.programRepo.CreateWorkout(ctx, program.ID, w.WorkoutTemplateId,
			daysOfWeekFromProto(w.DaysOfWeek), int(resolveDisplayOrder(w.DisplayOrder, i))); err != nil {
			return nil, handleDBError(err)
		}
	}

	reloaded, err := h.programRepo.GetByID(ctx, program.ID, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.CreateProgramResponse{
		Program: programToProto(reloaded),
	}), nil
}

// UpdateProgram updates a program. If replace_workouts is true, the program's
// workouts are atomically replaced with the given list (empty list clears all).
func (h *ProgramHandler) UpdateProgram(ctx context.Context, req *connect.Request[heftv1.UpdateProgramRequest]) (*connect.Response[heftv1.UpdateProgramResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
	}

	var name, description *string
	if req.Msg.Name != nil {
		name = req.Msg.Name
	}
	if req.Msg.Description != nil {
		description = req.Msg.Description
	}

	var startDate *time.Time
	if req.Msg.StartDate != nil {
		d, err := parseDate(*req.Msg.StartDate)
		if err != nil {
			return nil, err
		}
		startDate = &d
	}

	var durationWeeks *int
	if req.Msg.DurationWeeks != nil {
		if *req.Msg.DurationWeeks <= 0 {
			return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("duration_weeks must be >= 1"))
		}
		dw := int(*req.Msg.DurationWeeks)
		durationWeeks = &dw
	}

	var isArchived *bool
	if req.Msg.IsArchived != nil {
		isArchived = req.Msg.IsArchived
	}

	if req.Msg.ReplaceWorkouts {
		if err := validateWorkoutInputs(req.Msg.Workouts); err != nil {
			return nil, err
		}
	}

	updated, err := h.programRepo.Update(ctx, req.Msg.Id, userID, name, description, startDate, durationWeeks, isArchived)
	if err != nil {
		return nil, handleDBError(err)
	}
	if updated == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("program not found"))
	}

	if req.Msg.ReplaceWorkouts {
		if err := h.programRepo.DeleteWorkouts(ctx, req.Msg.Id, userID); err != nil {
			return nil, handleDBError(err)
		}
		for i, w := range req.Msg.Workouts {
			if _, err := h.programRepo.CreateWorkout(ctx, req.Msg.Id, w.WorkoutTemplateId,
				daysOfWeekFromProto(w.DaysOfWeek), int(resolveDisplayOrder(w.DisplayOrder, i))); err != nil {
				return nil, handleDBError(err)
			}
		}
	}

	reloaded, err := h.programRepo.GetByID(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.UpdateProgramResponse{
		Program: programToProto(reloaded),
	}), nil
}

// DeleteProgram deletes a program
func (h *ProgramHandler) DeleteProgram(ctx context.Context, req *connect.Request[heftv1.DeleteProgramRequest]) (*connect.Response[heftv1.DeleteProgramResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
	}

	if err := h.programRepo.Delete(ctx, req.Msg.Id, userID); err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.DeleteProgramResponse{Success: true}), nil
}

// SetActiveProgram activates a program and deactivates all others for the user.
func (h *ProgramHandler) SetActiveProgram(ctx context.Context, req *connect.Request[heftv1.SetActiveProgramRequest]) (*connect.Response[heftv1.SetActiveProgramResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
	}

	p, err := h.programRepo.SetActive(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, handleDBError(err)
	}
	if p == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("program not found"))
	}

	reloaded, err := h.programRepo.GetByID(ctx, p.ID, userID)
	if err != nil {
		return nil, handleDBError(err)
	}
	return connect.NewResponse(&heftv1.SetActiveProgramResponse{
		Program: programToProto(reloaded),
	}), nil
}

// GetTodayWorkout returns the workouts scheduled for the user's local "today"
// based on their active program. Empty workouts list = rest day or no program.
func (h *ProgramHandler) GetTodayWorkout(ctx context.Context, req *connect.Request[heftv1.GetTodayWorkoutRequest]) (*connect.Response[heftv1.GetTodayWorkoutResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)
	todayISO := convert.TimeWeekdayToISO(int(today.Weekday()))

	resp := &heftv1.GetTodayWorkoutResponse{
		Date:      today.Format(dateLayout),
		DayOfWeek: convert.IntToDayOfWeek(todayISO),
	}

	program, err := h.programRepo.GetActiveProgram(ctx, userID)
	if err != nil {
		return nil, handleDBError(err)
	}
	if program == nil {
		return connect.NewResponse(resp), nil
	}
	resp.Program = programToProto(program)

	// Normalize to UTC midnight so DB DATE values (always UTC midnight in pgx)
	// compare cleanly with the synthesized "today".
	start := time.Date(program.StartDate.Year(), program.StartDate.Month(),
		program.StartDate.Day(), 0, 0, 0, 0, time.UTC)
	end := start.AddDate(0, 0, program.DurationWeeks*7)
	if today.Before(start) || !today.Before(end) {
		return connect.NewResponse(resp), nil
	}
	resp.InProgramWindow = true

	for _, pw := range program.Workouts {
		if !containsISO(pw.DaysOfWeek, todayISO) {
			continue
		}
		workout, err := h.workoutRepo.GetByID(ctx, pw.WorkoutTemplateID, userID)
		if err != nil {
			return nil, handleDBError(err)
		}
		if workout != nil {
			resp.Workouts = append(resp.Workouts, workoutToProto(workout))
		}
	}

	return connect.NewResponse(resp), nil
}

// Helper functions

func parseDate(s string) (time.Time, error) {
	if s == "" {
		return time.Time{}, connect.NewError(connect.CodeInvalidArgument, errors.New("start_date is required"))
	}
	t, err := time.Parse(dateLayout, s)
	if err != nil {
		return time.Time{}, connect.NewError(connect.CodeInvalidArgument, errors.New("start_date must be YYYY-MM-DD"))
	}
	return t, nil
}

func validateWorkoutInputs(inputs []*heftv1.ProgramWorkoutInput) error {
	for i, w := range inputs {
		if w.WorkoutTemplateId == "" {
			return connect.NewError(connect.CodeInvalidArgument, errors.New("workouts[].workout_template_id is required"))
		}
		if len(w.DaysOfWeek) == 0 {
			return connect.NewError(connect.CodeInvalidArgument, errors.New("workouts[].days_of_week must have at least one day"))
		}
		for _, d := range w.DaysOfWeek {
			if convert.DayOfWeekToInt(d) == 0 {
				return connect.NewError(connect.CodeInvalidArgument, errors.New("workouts[].days_of_week contains unspecified day"))
			}
		}
		_ = i
	}
	return nil
}

func daysOfWeekFromProto(days []heftv1.DayOfWeek) []int16 {
	out := make([]int16, 0, len(days))
	seen := make(map[int16]struct{}, len(days))
	for _, d := range days {
		v := convert.DayOfWeekToInt(d)
		if v == 0 {
			continue
		}
		if _, ok := seen[v]; ok {
			continue
		}
		seen[v] = struct{}{}
		out = append(out, v)
	}
	return out
}

func daysOfWeekToProto(days []int16) []heftv1.DayOfWeek {
	out := make([]heftv1.DayOfWeek, len(days))
	for i, d := range days {
		out[i] = convert.IntToDayOfWeek(d)
	}
	return out
}

func resolveDisplayOrder(requested int32, fallback int) int32 {
	if requested > 0 {
		return requested
	}
	return int32(fallback)
}

func containsISO(days []int16, target int16) bool {
	for _, d := range days {
		if d == target {
			return true
		}
	}
	return false
}

func programSummaryToProto(p *repository.Program, totalWorkouts int) *heftv1.ProgramSummary {
	ps := &heftv1.ProgramSummary{
		Id:             p.ID,
		UserId:         p.UserID,
		Name:           p.Name,
		StartDate:      p.StartDate.Format(dateLayout),
		DurationWeeks:  int32(p.DurationWeeks),
		TotalWorkouts:  int32(totalWorkouts),
		IsActive:       p.IsActive,
		IsArchived:     p.IsArchived,
		CreatedAt:      timestamppb.New(p.CreatedAt),
		UpdatedAt:      timestamppb.New(p.UpdatedAt),
	}
	if p.Description != nil {
		ps.Description = *p.Description
	}
	return ps
}

func programToProto(p *repository.Program) *heftv1.Program {
	program := &heftv1.Program{
		Id:            p.ID,
		UserId:        p.UserID,
		Name:          p.Name,
		StartDate:     p.StartDate.Format(dateLayout),
		DurationWeeks: int32(p.DurationWeeks),
		IsActive:      p.IsActive,
		IsArchived:    p.IsArchived,
		CreatedAt:     timestamppb.New(p.CreatedAt),
		UpdatedAt:     timestamppb.New(p.UpdatedAt),
	}
	if p.Description != nil {
		program.Description = *p.Description
	}

	workouts := make([]*heftv1.ProgramWorkout, len(p.Workouts))
	for i, w := range p.Workouts {
		workouts[i] = programWorkoutToProto(w)
	}
	program.Workouts = workouts
	return program
}

func programWorkoutToProto(w *repository.ProgramWorkout) *heftv1.ProgramWorkout {
	return &heftv1.ProgramWorkout{
		Id:                w.ID,
		ProgramId:         w.ProgramID,
		WorkoutTemplateId: w.WorkoutTemplateID,
		WorkoutName:       w.WorkoutName,
		DaysOfWeek:        daysOfWeekToProto(w.DaysOfWeek),
		DisplayOrder:      int32(w.DisplayOrder),
	}
}
