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

	page := int32(1)
	pageSize := int32(50)
	if req.Msg.Pagination != nil {
		if req.Msg.Pagination.Page > 0 {
			page = req.Msg.Pagination.Page
		}
		if req.Msg.Pagination.PageSize > 0 {
			pageSize = req.Msg.Pagination.PageSize
		}
	}

	offset := (page - 1) * pageSize
	exercises, totalCount, err := h.repo.ListExercises(ctx, categoryID, exerciseType, systemOnly, userID, int(pageSize), int(offset))
	if err != nil {
		return nil, handleDBError(err)
	}

	protoExercises := make([]*heftv1.Exercise, len(exercises))
	for i, ex := range exercises {
		protoExercises[i] = exerciseToProto(ex)
	}

	totalPages := (int32(totalCount) + pageSize - 1) / pageSize

	return connect.NewResponse(&heftv1.ListExercisesResponse{
		Exercises: protoExercises,
		Pagination: &heftv1.PaginationResponse{
			Page:       page,
			PageSize:   pageSize,
			TotalCount: int32(totalCount),
			TotalPages: totalPages,
		},
	}), nil
}

// GetExercise retrieves a single exercise
func (h *ExerciseHandler) GetExercise(ctx context.Context, req *connect.Request[heftv1.GetExerciseRequest]) (*connect.Response[heftv1.GetExerciseResponse], error) {
	if req.Msg.Id == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("id is required"))
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
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.Name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("name is required"))
	}
	if req.Msg.CategoryId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("category_id is required"))
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

	protoCategories := make([]*heftv1.ExerciseCategory, len(categories))
	for i, cat := range categories {
		protoCategories[i] = &heftv1.ExerciseCategory{
			Id:           cat.ID,
			Name:         cat.Name,
			DisplayOrder: int32(cat.DisplayOrder),
		}
	}

	return connect.NewResponse(&heftv1.ListCategoriesResponse{
		Categories: protoCategories,
	}), nil
}

// SearchExercises searches exercises by name
func (h *ExerciseHandler) SearchExercises(ctx context.Context, req *connect.Request[heftv1.SearchExercisesRequest]) (*connect.Response[heftv1.SearchExercisesResponse], error) {
	if req.Msg.Query == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("query is required"))
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

	protoExercises := make([]*heftv1.Exercise, len(exercises))
	for i, ex := range exercises {
		protoExercises[i] = exerciseToProto(ex)
	}

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
