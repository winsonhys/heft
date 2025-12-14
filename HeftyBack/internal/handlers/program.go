package handlers

import (
	"context"
	"errors"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/repository"
)

// ProgramHandler implements the ProgramService
type ProgramHandler struct {
	programRepo repository.ProgramRepositoryInterface
	workoutRepo repository.WorkoutRepositoryInterface
}

// NewProgramHandler creates a new ProgramHandler
func NewProgramHandler(programRepo repository.ProgramRepositoryInterface, workoutRepo repository.WorkoutRepositoryInterface) *ProgramHandler {
	return &ProgramHandler{
		programRepo: programRepo,
		workoutRepo: workoutRepo,
	}
}

// ListPrograms lists programs for a user
func (h *ProgramHandler) ListPrograms(ctx context.Context, req *connect.Request[heftv1.ListProgramsRequest]) (*connect.Response[heftv1.ListProgramsResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	includeArchived := false
	if req.Msg.IncludeArchived != nil {
		includeArchived = *req.Msg.IncludeArchived
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
	programs, totalCount, err := h.programRepo.List(ctx, userID, includeArchived, int(pageSize), int(offset))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	protoPrograms := make([]*heftv1.ProgramSummary, len(programs))
	for i, p := range programs {
		protoPrograms[i] = programSummaryToProto(p)
	}

	totalPages := (int32(totalCount) + pageSize - 1) / pageSize

	return connect.NewResponse(&heftv1.ListProgramsResponse{
		Programs: protoPrograms,
		Pagination: &heftv1.PaginationResponse{
			Page:       page,
			PageSize:   pageSize,
			TotalCount: int32(totalCount),
			TotalPages: totalPages,
		},
	}), nil
}

// GetProgram retrieves a program with full details
func (h *ProgramHandler) GetProgram(ctx context.Context, req *connect.Request[heftv1.GetProgramRequest]) (*connect.Response[heftv1.GetProgramResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	program, err := h.programRepo.GetByID(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if program == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("program not found"))
	}

	return connect.NewResponse(&heftv1.GetProgramResponse{
		Program: programToProto(program),
	}), nil
}

// CreateProgram creates a new program
func (h *ProgramHandler) CreateProgram(ctx context.Context, req *connect.Request[heftv1.CreateProgramRequest]) (*connect.Response[heftv1.CreateProgramResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("name is required"))
	}

	var description *string
	if req.Msg.Description != nil {
		description = req.Msg.Description
	}

	program, err := h.programRepo.Create(ctx, userID, req.Msg.Name, description, int(req.Msg.DurationWeeks), int(req.Msg.DurationDays))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Create days if provided
	for _, d := range req.Msg.Days {
		dayType := programDayTypeToString(d.DayType)
		var workoutTemplateID, customName *string
		if d.WorkoutTemplateId != nil {
			workoutTemplateID = d.WorkoutTemplateId
		}
		if d.CustomName != nil {
			customName = d.CustomName
		}

		_, err := h.programRepo.CreateDay(ctx, program.ID, int(d.DayNumber), dayType, workoutTemplateID, customName)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
	}

	// Reload with all details
	program, err = h.programRepo.GetByID(ctx, program.ID, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.CreateProgramResponse{
		Program: programToProto(program),
	}), nil
}

// UpdateProgram updates a program
func (h *ProgramHandler) UpdateProgram(ctx context.Context, req *connect.Request[heftv1.UpdateProgramRequest]) (*connect.Response[heftv1.UpdateProgramResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	program, err := h.programRepo.GetByID(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if program == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("program not found"))
	}

	return connect.NewResponse(&heftv1.UpdateProgramResponse{
		Program: programToProto(program),
	}), nil
}

// DeleteProgram deletes a program
func (h *ProgramHandler) DeleteProgram(ctx context.Context, req *connect.Request[heftv1.DeleteProgramRequest]) (*connect.Response[heftv1.DeleteProgramResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	err := h.programRepo.Delete(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.DeleteProgramResponse{
		Success: true,
	}), nil
}

// SetActiveProgram sets a program as active
func (h *ProgramHandler) SetActiveProgram(ctx context.Context, req *connect.Request[heftv1.SetActiveProgramRequest]) (*connect.Response[heftv1.SetActiveProgramResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	program, err := h.programRepo.SetActive(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Reload with days
	program, err = h.programRepo.GetByID(ctx, program.ID, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.SetActiveProgramResponse{
		Program: programToProto(program),
	}), nil
}

// GetTodayWorkout gets today's workout based on active program
func (h *ProgramHandler) GetTodayWorkout(ctx context.Context, req *connect.Request[heftv1.GetTodayWorkoutRequest]) (*connect.Response[heftv1.GetTodayWorkoutResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	program, err := h.programRepo.GetActiveProgram(ctx, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	if program == nil {
		return connect.NewResponse(&heftv1.GetTodayWorkoutResponse{
			HasWorkout: false,
		}), nil
	}

	// Calculate today's day number in the program
	// For simplicity, use day 1 for now - real implementation would calculate based on program start date
	dayNumber := 1
	totalDays := program.DurationWeeks*7 + program.DurationDays
	if totalDays > 0 {
		dayNumber = (dayNumber-1)%totalDays + 1
	}

	// Find today's day
	var todayDay *repository.ProgramDay
	for _, d := range program.Days {
		if d.DayNumber == dayNumber {
			todayDay = d
			break
		}
	}

	if todayDay == nil {
		return connect.NewResponse(&heftv1.GetTodayWorkoutResponse{
			HasWorkout: false,
			DayNumber:  int32(dayNumber),
			DayType:    heftv1.ProgramDayType_PROGRAM_DAY_TYPE_UNASSIGNED,
			Program:    programToProto(program),
		}), nil
	}

	response := &heftv1.GetTodayWorkoutResponse{
		DayNumber: int32(dayNumber),
		DayType:   stringToProgramDayType(todayDay.DayType),
		Program:   programToProto(program),
	}

	if todayDay.DayType == "workout" && todayDay.WorkoutTemplateID != nil {
		workout, err := h.workoutRepo.GetByID(ctx, *todayDay.WorkoutTemplateID, userID)
		if err == nil && workout != nil {
			response.HasWorkout = true
			response.Workout = workoutToProto(workout)
		}
	}

	return connect.NewResponse(response), nil
}

// Helper functions
func programSummaryToProto(p *repository.Program) *heftv1.ProgramSummary {
	ps := &heftv1.ProgramSummary{
		Id:               p.ID,
		UserId:           p.UserID,
		Name:             p.Name,
		DurationWeeks:    int32(p.DurationWeeks),
		DurationDays:     int32(p.DurationDays),
		TotalWorkoutDays: int32(p.TotalWorkoutDays),
		TotalRestDays:    int32(p.TotalRestDays),
		IsActive:         p.IsActive,
		IsArchived:       p.IsArchived,
		CreatedAt:        timestamppb.New(p.CreatedAt),
		UpdatedAt:        timestamppb.New(p.UpdatedAt),
	}
	if p.Description != nil {
		ps.Description = *p.Description
	}
	return ps
}

func programToProto(p *repository.Program) *heftv1.Program {
	program := &heftv1.Program{
		Id:               p.ID,
		UserId:           p.UserID,
		Name:             p.Name,
		DurationWeeks:    int32(p.DurationWeeks),
		DurationDays:     int32(p.DurationDays),
		TotalWorkoutDays: int32(p.TotalWorkoutDays),
		TotalRestDays:    int32(p.TotalRestDays),
		IsActive:         p.IsActive,
		IsArchived:       p.IsArchived,
		CreatedAt:        timestamppb.New(p.CreatedAt),
		UpdatedAt:        timestamppb.New(p.UpdatedAt),
	}
	if p.Description != nil {
		program.Description = *p.Description
	}

	days := make([]*heftv1.ProgramDay, len(p.Days))
	for i, d := range p.Days {
		days[i] = programDayToProto(d)
	}
	program.Days = days

	return program
}

func programDayToProto(d *repository.ProgramDay) *heftv1.ProgramDay {
	day := &heftv1.ProgramDay{
		Id:        d.ID,
		ProgramId: d.ProgramID,
		DayNumber: int32(d.DayNumber),
		DayType:   stringToProgramDayType(d.DayType),
	}
	if d.WorkoutTemplateID != nil {
		day.WorkoutTemplateId = *d.WorkoutTemplateID
	}
	if d.WorkoutName != nil {
		day.WorkoutName = *d.WorkoutName
	}
	if d.CustomName != nil {
		day.CustomName = *d.CustomName
	}
	return day
}

func programDayTypeToString(t heftv1.ProgramDayType) string {
	switch t {
	case heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT:
		return "workout"
	case heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST:
		return "rest"
	case heftv1.ProgramDayType_PROGRAM_DAY_TYPE_UNASSIGNED:
		return "unassigned"
	default:
		return "unassigned"
	}
}

func stringToProgramDayType(s string) heftv1.ProgramDayType {
	switch s {
	case "workout":
		return heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT
	case "rest":
		return heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST
	case "unassigned":
		return heftv1.ProgramDayType_PROGRAM_DAY_TYPE_UNASSIGNED
	default:
		return heftv1.ProgramDayType_PROGRAM_DAY_TYPE_UNSPECIFIED
	}
}
