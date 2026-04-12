package handlers

import (
	"context"
	"errors"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/timestamppb"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/repository"
)

// ExerciseHandler implements the ExerciseService
type ExerciseHandler struct {
	repo repository.ExerciseRepositoryInterface
}

// NewExerciseHandler creates a new ExerciseHandler
func NewExerciseHandler(repo repository.ExerciseRepositoryInterface) *ExerciseHandler {
	return &ExerciseHandler{repo: repo}
}

// ListExercises lists exercises with optional filters
func (h *ExerciseHandler) ListExercises(ctx context.Context, req *connect.Request[heftv1.ListExercisesRequest]) (*connect.Response[heftv1.ListExercisesResponse], error) {
	var categoryID, exerciseType, userID *string
	systemOnly := false

	if req.Msg.CategoryId != nil && *req.Msg.CategoryId != "" {
		categoryID = req.Msg.CategoryId
	}
	if req.Msg.ExerciseType != nil && *req.Msg.ExerciseType != heftv1.ExerciseType_EXERCISE_TYPE_UNSPECIFIED {
		t := exerciseTypeToString(*req.Msg.ExerciseType)
		exerciseType = &t
	}
	if req.Msg.SystemOnly != nil {
		systemOnly = *req.Msg.SystemOnly
	}
	if req.Msg.UserId != nil && *req.Msg.UserId != "" {
		userID = req.Msg.UserId
	}

	page, pageSize, offset := extractPagination(req.Msg.Pagination, 50)
	exercises, totalCount, err := h.repo.ListExercises(ctx, categoryID, exerciseType, systemOnly, userID, int(pageSize), int(offset))
	if err != nil {
		return nil, handleDBError(err)
	}

	protoExercises := mapSlice(exercises, func(ex *repository.Exercise) *heftv1.Exercise {
		return exerciseToProto(ex)
	})

	return connect.NewResponse(&heftv1.ListExercisesResponse{
		Exercises:  protoExercises,
		Pagination: buildPaginationResponse(page, pageSize, totalCount),
	}), nil
}

// GetExercise retrieves a single exercise
func (h *ExerciseHandler) GetExercise(ctx context.Context, req *connect.Request[heftv1.GetExerciseRequest]) (*connect.Response[heftv1.GetExerciseResponse], error) {
	if err := requireString(req.Msg.Id, "id"); err != nil {
		return nil, err
	}

	exercise, err := h.repo.GetByID(ctx, req.Msg.Id)
	if err != nil {
		return nil, handleDBError(err)
	}
	if exercise == nil {
		return nil, connect.NewError(connect.CodeNotFound, errors.New("exercise not found"))
	}

	return connect.NewResponse(&heftv1.GetExerciseResponse{
		Exercise: exerciseToProto(exercise),
	}), nil
}

// CreateExercise creates a custom exercise
func (h *ExerciseHandler) CreateExercise(ctx context.Context, req *connect.Request[heftv1.CreateExerciseRequest]) (*connect.Response[heftv1.CreateExerciseResponse], error) {
	userID, err := getAuthenticatedUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.Name, "name"); err != nil {
		return nil, err
	}
	if err := requireString(req.Msg.CategoryId, "category_id"); err != nil {
		return nil, err
	}

	exerciseType := exerciseTypeToString(req.Msg.ExerciseType)
	if exerciseType == "" {
		exerciseType = "weight_reps"
	}

	var description *string
	if req.Msg.Description != nil {
		description = req.Msg.Description
	}

	exercise, err := h.repo.Create(ctx, userID, req.Msg.Name, req.Msg.CategoryId, exerciseType, description)
	if err != nil {
		return nil, handleDBError(err)
	}

	return connect.NewResponse(&heftv1.CreateExerciseResponse{
		Exercise: exerciseToProto(exercise),
	}), nil
}

// ListCategories lists all exercise categories
func (h *ExerciseHandler) ListCategories(ctx context.Context, req *connect.Request[heftv1.ListCategoriesRequest]) (*connect.Response[heftv1.ListCategoriesResponse], error) {
	categories, err := h.repo.ListCategories(ctx)
	if err != nil {
		return nil, handleDBError(err)
	}

	protoCategories := mapSlice(categories, func(cat *repository.ExerciseCategory) *heftv1.ExerciseCategory {
		return &heftv1.ExerciseCategory{
			Id:           cat.ID,
			Name:         cat.Name,
			DisplayOrder: int32(cat.DisplayOrder),
		}
	})

	return connect.NewResponse(&heftv1.ListCategoriesResponse{
		Categories: protoCategories,
	}), nil
}

// SearchExercises searches exercises by name
func (h *ExerciseHandler) SearchExercises(ctx context.Context, req *connect.Request[heftv1.SearchExercisesRequest]) (*connect.Response[heftv1.SearchExercisesResponse], error) {
	if err := requireString(req.Msg.Query, "query"); err != nil {
		return nil, err
	}

	var userID *string
	if req.Msg.UserId != nil && *req.Msg.UserId != "" {
		userID = req.Msg.UserId
	}

	limit := 20
	if req.Msg.Limit != nil && *req.Msg.Limit > 0 {
		limit = int(*req.Msg.Limit)
	}

	exercises, err := h.repo.Search(ctx, req.Msg.Query, userID, limit)
	if err != nil {
		return nil, handleDBError(err)
	}

	protoExercises := mapSlice(exercises, func(ex *repository.Exercise) *heftv1.Exercise {
		return exerciseToProto(ex)
	})

	return connect.NewResponse(&heftv1.SearchExercisesResponse{
		Exercises: protoExercises,
	}), nil
}

// Helper functions
func exerciseToProto(ex *repository.Exercise) *heftv1.Exercise {
	e := &heftv1.Exercise{
		Id:           ex.ID,
		Name:         ex.Name,
		ExerciseType: stringToExerciseType(ex.ExerciseType),
		IsSystem:     ex.IsSystem,
		CreatedAt:    timestamppb.New(ex.CreatedAt),
		UpdatedAt:    timestamppb.New(ex.UpdatedAt),
	}
	if ex.CategoryID != nil {
		e.CategoryId = *ex.CategoryID
	}
	if ex.CategoryName != nil {
		e.CategoryName = *ex.CategoryName
	}
	if ex.Description != nil {
		e.Description = *ex.Description
	}
	if ex.CreatedBy != nil {
		e.CreatedBy = *ex.CreatedBy
	}
	return e
}

func exerciseTypeToString(et heftv1.ExerciseType) string {
	switch et {
	case heftv1.ExerciseType_EXERCISE_TYPE_WEIGHT_REPS:
		return "weight_reps"
	case heftv1.ExerciseType_EXERCISE_TYPE_BODYWEIGHT_REPS:
		return "bodyweight_reps"
	case heftv1.ExerciseType_EXERCISE_TYPE_TIME:
		return "time"
	case heftv1.ExerciseType_EXERCISE_TYPE_DISTANCE:
		return "distance"
	case heftv1.ExerciseType_EXERCISE_TYPE_CARDIO:
		return "cardio"
	default:
		return ""
	}
}

func stringToExerciseType(s string) heftv1.ExerciseType {
	switch s {
	case "weight_reps":
		return heftv1.ExerciseType_EXERCISE_TYPE_WEIGHT_REPS
	case "bodyweight_reps":
		return heftv1.ExerciseType_EXERCISE_TYPE_BODYWEIGHT_REPS
	case "time":
		return heftv1.ExerciseType_EXERCISE_TYPE_TIME
	case "distance":
		return heftv1.ExerciseType_EXERCISE_TYPE_DISTANCE
	case "cardio":
		return heftv1.ExerciseType_EXERCISE_TYPE_CARDIO
	default:
		return heftv1.ExerciseType_EXERCISE_TYPE_UNSPECIFIED
	}
}
