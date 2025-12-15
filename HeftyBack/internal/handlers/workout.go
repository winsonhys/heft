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

// WorkoutHandler implements the WorkoutService
type WorkoutHandler struct {
	repo repository.WorkoutRepositoryInterface
}

// NewWorkoutHandler creates a new WorkoutHandler
func NewWorkoutHandler(repo repository.WorkoutRepositoryInterface) *WorkoutHandler {
	return &WorkoutHandler{repo: repo}
}

// ListWorkouts lists workout templates
func (h *WorkoutHandler) ListWorkouts(ctx context.Context, req *connect.Request[heftv1.ListWorkoutsRequest]) (*connect.Response[heftv1.ListWorkoutsResponse], error) {
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
	workouts, totalCount, err := h.repo.List(ctx, userID, includeArchived, int(pageSize), int(offset))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	protoWorkouts := make([]*heftv1.WorkoutSummary, len(workouts))
	for i, w := range workouts {
		protoWorkouts[i] = workoutSummaryToProto(w)
	}

	totalPages := (int32(totalCount) + pageSize - 1) / pageSize

	return connect.NewResponse(&heftv1.ListWorkoutsResponse{
		Workouts: protoWorkouts,
		Pagination: &heftv1.PaginationResponse{
			Page:       page,
			PageSize:   pageSize,
			TotalCount: int32(totalCount),
			TotalPages: totalPages,
		},
	}), nil
}

// GetWorkout retrieves a workout with full details
func (h *WorkoutHandler) GetWorkout(ctx context.Context, req *connect.Request[heftv1.GetWorkoutRequest]) (*connect.Response[heftv1.GetWorkoutResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	workout, err := h.repo.GetByID(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if workout == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("workout not found"))
	}

	return connect.NewResponse(&heftv1.GetWorkoutResponse{
		Workout: workoutToProto(workout),
	}), nil
}

// CreateWorkout creates a new workout template
func (h *WorkoutHandler) CreateWorkout(ctx context.Context, req *connect.Request[heftv1.CreateWorkoutRequest]) (*connect.Response[heftv1.CreateWorkoutResponse], error) {
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

	// Create workout template
	workout, err := h.repo.Create(ctx, userID, req.Msg.Name, description)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Create sections if provided
	for _, s := range req.Msg.Sections {
		section, err := h.repo.CreateSection(ctx, workout.ID, s.Name, int(s.DisplayOrder), s.IsSuperset)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}

		// Create items in section
		for _, item := range s.Items {
			itemType := sectionItemTypeToString(item.ItemType)
			var exerciseID *string
			var restDuration *int
			if item.ExerciseId != nil {
				exerciseID = item.ExerciseId
			}
			if item.RestDurationSeconds != nil {
				v := int(*item.RestDurationSeconds)
				restDuration = &v
			}

			sectionItem, err := h.repo.CreateSectionItem(ctx, section.ID, itemType, int(item.DisplayOrder), exerciseID, restDuration)
			if err != nil {
				return nil, connect.NewError(connect.CodeInternal, err)
			}

			// Create target sets
			for _, ts := range item.TargetSets {
				var targetWeight *float64
				var targetReps, targetTime, targetRest *int
				var targetDistance *float64
				if ts.TargetWeightKg != nil {
					targetWeight = ts.TargetWeightKg
				}
				if ts.TargetReps != nil {
					v := int(*ts.TargetReps)
					targetReps = &v
				}
				if ts.TargetTimeSeconds != nil {
					v := int(*ts.TargetTimeSeconds)
					targetTime = &v
				}
				if ts.TargetDistanceM != nil {
					targetDistance = ts.TargetDistanceM
				}
				var notes *string
				if ts.Notes != nil {
					notes = ts.Notes
				}
				if ts.RestDurationSeconds != nil {
					v := int(*ts.RestDurationSeconds)
					targetRest = &v
				}

				_, err := h.repo.CreateTargetSet(ctx, sectionItem.ID, int(ts.SetNumber), targetWeight, targetReps, targetTime, targetDistance, ts.IsBodyweight, notes, targetRest)
				if err != nil {
					return nil, connect.NewError(connect.CodeInternal, err)
				}
			}
		}
	}

	// Reload workout with all details
	workout, err = h.repo.GetByID(ctx, workout.ID, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.CreateWorkoutResponse{
		Workout: workoutToProto(workout),
	}), nil
}

// UpdateWorkout updates a workout template
func (h *WorkoutHandler) UpdateWorkout(ctx context.Context, req *connect.Request[heftv1.UpdateWorkoutRequest]) (*connect.Response[heftv1.UpdateWorkoutResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	// Verify ownership and existence
	existing, err := h.repo.GetByID(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if existing == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("workout not found"))
	}

	// Prepare fields for update
	name := existing.Name
	if req.Msg.Name != nil {
		name = *req.Msg.Name
	}
	description := existing.Description
	if req.Msg.Description != nil {
		description = req.Msg.Description
	}
	isArchived := existing.IsArchived
	if req.Msg.IsArchived != nil {
		isArchived = *req.Msg.IsArchived
	}

	// Update top-level details
	workout, err := h.repo.UpdateWorkoutDetails(ctx, req.Msg.Id, name, description, isArchived)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// If sections are provided, we do a full replacement
	if len(req.Msg.Sections) > 0 {
		// Delete existing sections
		err = h.repo.DeleteSections(ctx, workout.ID)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}

		// Recreate sections
		for _, s := range req.Msg.Sections {
			section, err := h.repo.CreateSection(ctx, workout.ID, s.Name, int(s.DisplayOrder), s.IsSuperset)
			if err != nil {
				return nil, connect.NewError(connect.CodeInternal, err)
			}

			// Create items in section
			for _, item := range s.Items {
				itemType := sectionItemTypeToString(item.ItemType)
				var exerciseID *string
				var restDuration *int
				if item.ExerciseId != nil {
					exerciseID = item.ExerciseId
				}
				if item.RestDurationSeconds != nil {
					v := int(*item.RestDurationSeconds)
					restDuration = &v
				}

				sectionItem, err := h.repo.CreateSectionItem(ctx, section.ID, itemType, int(item.DisplayOrder), exerciseID, restDuration)
				if err != nil {
					return nil, connect.NewError(connect.CodeInternal, err)
				}

				// Create target sets
				for _, ts := range item.TargetSets {
					var targetWeight *float64
					var targetReps, targetTime, targetRest *int
					var targetDistance *float64
					if ts.TargetWeightKg != nil {
						targetWeight = ts.TargetWeightKg
					}
					if ts.TargetReps != nil {
						v := int(*ts.TargetReps)
						targetReps = &v
					}
					if ts.TargetTimeSeconds != nil {
						v := int(*ts.TargetTimeSeconds)
						targetTime = &v
					}
					if ts.TargetDistanceM != nil {
						targetDistance = ts.TargetDistanceM
					}
					var notes *string
					if ts.Notes != nil {
						notes = ts.Notes
					}
					if ts.RestDurationSeconds != nil {
						v := int(*ts.RestDurationSeconds)
						targetRest = &v
					}

					_, err := h.repo.CreateTargetSet(ctx, sectionItem.ID, int(ts.SetNumber), targetWeight, targetReps, targetTime, targetDistance, ts.IsBodyweight, notes, targetRest)
					if err != nil {
						return nil, connect.NewError(connect.CodeInternal, err)
					}
				}
			}
		}
	}

	// Reload workout with all details
	workout, err = h.repo.GetByID(ctx, workout.ID, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.UpdateWorkoutResponse{
		Workout: workoutToProto(workout),
	}), nil
}

// DeleteWorkout deletes a workout template
func (h *WorkoutHandler) DeleteWorkout(ctx context.Context, req *connect.Request[heftv1.DeleteWorkoutRequest]) (*connect.Response[heftv1.DeleteWorkoutResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	err := h.repo.Delete(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.DeleteWorkoutResponse{
		Success: true,
	}), nil
}

// DuplicateWorkout duplicates a workout template
func (h *WorkoutHandler) DuplicateWorkout(ctx context.Context, req *connect.Request[heftv1.DuplicateWorkoutRequest]) (*connect.Response[heftv1.DuplicateWorkoutResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
	}

	// Get original workout
	original, err := h.repo.GetByID(ctx, req.Msg.Id, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if original == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("workout not found"))
	}

	// Create new name
	newName := original.Name + " (Copy)"
	if req.Msg.NewName != nil {
		newName = *req.Msg.NewName
	}

	// Create duplicate
	duplicate, err := h.repo.Create(ctx, userID, newName, original.Description)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Copy sections
	for _, s := range original.Sections {
		section, err := h.repo.CreateSection(ctx, duplicate.ID, s.Name, s.DisplayOrder, s.IsSuperset)
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}

		for _, item := range s.Items {
			sectionItem, err := h.repo.CreateSectionItem(ctx, section.ID, item.ItemType, item.DisplayOrder, item.ExerciseID, item.RestDurationSeconds)
			if err != nil {
				return nil, connect.NewError(connect.CodeInternal, err)
			}

			for _, ts := range item.TargetSets {
				var targetReps, targetTime, targetRest *int
				if ts.TargetReps != nil {
					targetReps = ts.TargetReps
				}
				if ts.TargetTimeSeconds != nil {
					targetTime = ts.TargetTimeSeconds
				}
				if ts.RestDurationSeconds != nil {
					targetRest = ts.RestDurationSeconds
				}
				_, err := h.repo.CreateTargetSet(ctx, sectionItem.ID, ts.SetNumber, ts.TargetWeightKg, targetReps, targetTime, ts.TargetDistanceM, ts.IsBodyweight, ts.Notes, targetRest)
				if err != nil {
					return nil, connect.NewError(connect.CodeInternal, err)
				}
			}
		}
	}

	// Reload with all details
	duplicate, err = h.repo.GetByID(ctx, duplicate.ID, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.DuplicateWorkoutResponse{
		Workout: workoutToProto(duplicate),
	}), nil
}

// Helper functions
func workoutSummaryToProto(w *repository.WorkoutTemplate) *heftv1.WorkoutSummary {
	ws := &heftv1.WorkoutSummary{
		Id:             w.ID,
		UserId:         w.UserID,
		Name:           w.Name,
		TotalExercises: int32(w.TotalExercises),
		TotalSets:      int32(w.TotalSets),
		IsArchived:     w.IsArchived,
		CreatedAt:      timestamppb.New(w.CreatedAt),
		UpdatedAt:      timestamppb.New(w.UpdatedAt),
	}
	if w.Description != nil {
		ws.Description = *w.Description
	}
	if w.EstimatedDurationMinutes != nil {
		ws.EstimatedDurationMinutes = int32(*w.EstimatedDurationMinutes)
	}
	return ws
}

func workoutToProto(w *repository.WorkoutTemplate) *heftv1.Workout {
	workout := &heftv1.Workout{
		Id:             w.ID,
		UserId:         w.UserID,
		Name:           w.Name,
		TotalExercises: int32(w.TotalExercises),
		TotalSets:      int32(w.TotalSets),
		IsArchived:     w.IsArchived,
		CreatedAt:      timestamppb.New(w.CreatedAt),
		UpdatedAt:      timestamppb.New(w.UpdatedAt),
	}
	if w.Description != nil {
		workout.Description = *w.Description
	}
	if w.EstimatedDurationMinutes != nil {
		workout.EstimatedDurationMinutes = int32(*w.EstimatedDurationMinutes)
	}

	// Convert sections
	sections := make([]*heftv1.WorkoutSection, len(w.Sections))
	for i, s := range w.Sections {
		sections[i] = workoutSectionToProto(s)
	}
	workout.Sections = sections

	return workout
}

func workoutSectionToProto(s *repository.WorkoutSection) *heftv1.WorkoutSection {
	section := &heftv1.WorkoutSection{
		Id:                s.ID,
		WorkoutTemplateId: s.WorkoutTemplateID,
		Name:              s.Name,
		DisplayOrder:      int32(s.DisplayOrder),
		IsSuperset:        s.IsSuperset,
	}

	items := make([]*heftv1.SectionItem, len(s.Items))
	for i, item := range s.Items {
		items[i] = sectionItemToProto(item)
	}
	section.Items = items

	return section
}

func sectionItemToProto(item *repository.SectionItem) *heftv1.SectionItem {
	si := &heftv1.SectionItem{
		Id:           item.ID,
		SectionId:    item.SectionID,
		ItemType:     stringToSectionItemType(item.ItemType),
		DisplayOrder: int32(item.DisplayOrder),
	}
	if item.ExerciseID != nil {
		si.ExerciseId = *item.ExerciseID
	}
	if item.ExerciseName != nil {
		si.ExerciseName = *item.ExerciseName
	}
	if item.ExerciseType != nil {
		si.ExerciseType = stringToExerciseType(*item.ExerciseType)
	}
	if item.RestDurationSeconds != nil {
		si.RestDurationSeconds = int32(*item.RestDurationSeconds)
	}

	sets := make([]*heftv1.TargetSet, len(item.TargetSets))
	for i, ts := range item.TargetSets {
		sets[i] = targetSetToProto(ts)
	}
	si.TargetSets = sets

	return si
}

func targetSetToProto(ts *repository.ExerciseTargetSet) *heftv1.TargetSet {
	set := &heftv1.TargetSet{
		Id:            ts.ID,
		SectionItemId: ts.SectionItemID,
		SetNumber:     int32(ts.SetNumber),
		IsBodyweight:  ts.IsBodyweight,
	}
	if ts.TargetWeightKg != nil {
		set.TargetWeightKg = ts.TargetWeightKg
	}
	if ts.TargetReps != nil {
		v := int32(*ts.TargetReps)
		set.TargetReps = &v
	}
	if ts.TargetTimeSeconds != nil {
		v := int32(*ts.TargetTimeSeconds)
		set.TargetTimeSeconds = &v
	}
	if ts.TargetDistanceM != nil {
		set.TargetDistanceM = ts.TargetDistanceM
	}
	if ts.Notes != nil {
		set.Notes = *ts.Notes
	}
	if ts.RestDurationSeconds != nil {
		v := int32(*ts.RestDurationSeconds)
		set.RestDurationSeconds = &v
	}
	return set
}

func sectionItemTypeToString(t heftv1.SectionItemType) string {
	switch t {
	case heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE:
		return "exercise"
	case heftv1.SectionItemType_SECTION_ITEM_TYPE_REST:
		return "rest"
	default:
		return "exercise"
	}
}

func stringToSectionItemType(s string) heftv1.SectionItemType {
	switch s {
	case "exercise":
		return heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE
	case "rest":
		return heftv1.SectionItemType_SECTION_ITEM_TYPE_REST
	default:
		return heftv1.SectionItemType_SECTION_ITEM_TYPE_UNSPECIFIED
	}
}
