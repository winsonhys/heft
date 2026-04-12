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

	protoPrograms := mapSlice(programs, func(p *repository.Program) *heftv1.ProgramSummary {
		return programSummaryToProto(p)
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

// CreateProgram creates a new program
func (h *ProgramHandler) CreateProgram(ctx context.Context, req *connect.Request[heftv1.CreateProgramRequest]) (*connect.Response[heftv1.CreateProgramResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Name, "name"); err != nil {
		return nil, err
	}

	var description *string
	if req.Msg.Description != nil {
		description = req.Msg.Description
	}

	program, err := h.programRepo.Create(ctx, userID, req.Msg.Name, description, int(req.Msg.DurationWeeks), int(req.Msg.DurationDays))
	if err != nil {
		return nil, handleDBError(err)
	}

	// Create days if provided
	for _, d := range req.Msg.Days {
		dayType := convert.ProgramDayTypeToString(d.DayType)
		var workoutTemplateID, customName *string
		if d.WorkoutTemplateId != nil {
			workoutTemplateID = d.WorkoutTemplateId
		}
		if d.CustomName != nil {
			customName = d.CustomName
		}

		_, err := h.programRepo.CreateDay(ctx, program.ID, int(d.DayNumber), dayType, workoutTemplateID, customName)
		if err != nil {
			return nil, handleDBError(err)
		}
	}

	// Reload with all details
	program, err = h.programRepo.GetByID(ctx, program.ID, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.CreateProgramResponse{
		Program: programToProto(program),
	}), nil
}

// UpdateProgram updates a program
func (h *ProgramHandler) UpdateProgram(ctx context.Context, req *connect.Request[heftv1.UpdateProgramRequest]) (*connect.Response[heftv1.UpdateProgramResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
	}

	// Extract optional fields from request
	var name *string
	if req.Msg.Name != nil {
		name = req.Msg.Name
	}
	var description *string
	if req.Msg.Description != nil {
		description = req.Msg.Description
	}
	var durationWeeks *int
	if req.Msg.DurationWeeks != nil {
		dw := int(*req.Msg.DurationWeeks)
		durationWeeks = &dw
	}
	var durationDays *int
	if req.Msg.DurationDays != nil {
		dd := int(*req.Msg.DurationDays)
		durationDays = &dd
	}
	var isArchived *bool
	if req.Msg.IsArchived != nil {
		isArchived = req.Msg.IsArchived
	}

	// If days provided, compute totals for the UPDATE
	var totalWorkoutDays, totalRestDays *int
	if len(req.Msg.Days) > 0 {
		wd, rd := 0, 0
		for _, d := range req.Msg.Days {
			switch d.DayType {
			case heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT:
				wd++
			case heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST:
				rd++
			}
		}
		totalWorkoutDays = &wd
		totalRestDays = &rd
	}

	// Call Update
	updatedProgram, err := h.programRepo.Update(ctx, req.Msg.Id, userID,
		name, description, durationWeeks, durationDays, isArchived,
		totalWorkoutDays, totalRestDays)
	if err != nil {
		return nil, handleDBError(err)
	}
	if updatedProgram == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("program not found"))
	}

	// Replace days if provided
	if len(req.Msg.Days) > 0 {
		if err := h.programRepo.DeleteDays(ctx, req.Msg.Id, userID); err != nil {
			return nil, handleDBError(err)
		}
		for _, d := range req.Msg.Days {
			dayType := convert.ProgramDayTypeToString(d.DayType)
			var workoutTemplateID, customName *string
			if d.WorkoutTemplateId != nil {
				workoutTemplateID = d.WorkoutTemplateId
			}
			if d.CustomName != nil {
				customName = d.CustomName
			}
			_, err := h.programRepo.CreateDay(ctx, req.Msg.Id, int(d.DayNumber), dayType, workoutTemplateID, customName)
			if err != nil {
				return nil, handleDBError(err)
			}
		}
	}

	// Reload with days
	program, err := h.programRepo.GetByID(ctx, updatedProgram.ID, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.UpdateProgramResponse{
		Program: programToProto(program),
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

	err = h.programRepo.Delete(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.DeleteProgramResponse{
		Success: true,
	}), nil
}

// SetActiveProgram sets a program as active
func (h *ProgramHandler) SetActiveProgram(ctx context.Context, req *connect.Request[heftv1.SetActiveProgramRequest]) (*connect.Response[heftv1.SetActiveProgramResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
	}

	program, err := h.programRepo.SetActive(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	// Reload with days
	program, err = h.programRepo.GetByID(ctx, program.ID, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.SetActiveProgramResponse{
		Program: programToProto(program),
	}), nil
}

// GetTodayWorkout gets today's workout based on active program
func (h *ProgramHandler) GetTodayWorkout(ctx context.Context, req *connect.Request[heftv1.GetTodayWorkoutRequest]) (*connect.Response[heftv1.GetTodayWorkoutResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}

	program, err := h.programRepo.GetActiveProgram(ctx, userID)
	if err != nil {
		return nil, handleDBError(err)
	}

	if program == nil {
		return connect.NewResponse(&heftv1.GetTodayWorkoutResponse{
			HasWorkout: false,
		}), nil
	}

	// Calculate today's day number based on program start date
	dayNumber := 1
	if program.StartedAt != nil {
		dayNumber = int(time.Since(*program.StartedAt).Hours()/24) + 1
	}
	totalDays := program.DurationWeeks*7 + program.DurationDays
	if totalDays > 0 && dayNumber > totalDays {
		dayNumber = totalDays
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
		DayType:   convert.StringToProgramDayType(todayDay.DayType),
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
	if p.StartedAt != nil {
		ps.StartedAt = timestamppb.New(*p.StartedAt)
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
	if p.StartedAt != nil {
		program.StartedAt = timestamppb.New(*p.StartedAt)
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
		DayType:   convert.StringToProgramDayType(d.DayType),
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

