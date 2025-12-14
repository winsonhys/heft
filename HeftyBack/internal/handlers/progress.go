package handlers

import (
	"context"
	"errors"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/repository"
)

// ProgressHandler implements the ProgressService
type ProgressHandler struct {
	repo         repository.ProgressRepositoryInterface
	exerciseRepo repository.ExerciseRepositoryInterface
}

// NewProgressHandler creates a new ProgressHandler
func NewProgressHandler(repo repository.ProgressRepositoryInterface, exerciseRepo repository.ExerciseRepositoryInterface) *ProgressHandler {
	return &ProgressHandler{
		repo:         repo,
		exerciseRepo: exerciseRepo,
	}
}

// GetDashboardStats retrieves dashboard statistics
func (h *ProgressHandler) GetDashboardStats(ctx context.Context, req *connect.Request[heftv1.GetDashboardStatsRequest]) (*connect.Response[heftv1.GetDashboardStatsResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	stats, err := h.repo.GetDashboardStats(ctx, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	return connect.NewResponse(&heftv1.GetDashboardStatsResponse{
		Stats: &heftv1.DashboardStats{
			TotalWorkouts:    int32(stats.TotalWorkouts),
			WorkoutsThisWeek: int32(stats.WorkoutsThisWeek),
			CurrentStreak:    int32(stats.CurrentStreak),
			TotalVolumeKg:    int32(stats.TotalVolumeKg),
			DaysActive:       int32(stats.DaysActive),
		},
	}), nil
}

// GetWeeklyActivity retrieves weekly activity data
func (h *ProgressHandler) GetWeeklyActivity(ctx context.Context, req *connect.Request[heftv1.GetWeeklyActivityRequest]) (*connect.Response[heftv1.GetWeeklyActivityResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	days, err := h.repo.GetWeeklyActivity(ctx, userID, nil)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	protoDays := make([]*heftv1.WeeklyActivityDay, len(days))
	totalWorkouts := int32(0)
	for i, d := range days {
		protoDays[i] = &heftv1.WeeklyActivityDay{
			Date:         d.Date.Format("2006-01-02"),
			DayOfWeek:    d.DayOfWeek,
			WorkoutCount: int32(d.WorkoutCount),
			IsToday:      d.IsToday,
		}
		totalWorkouts += int32(d.WorkoutCount)
	}

	return connect.NewResponse(&heftv1.GetWeeklyActivityResponse{
		Days:          protoDays,
		TotalWorkouts: totalWorkouts,
	}), nil
}

// GetPersonalRecords retrieves personal records
func (h *ProgressHandler) GetPersonalRecords(ctx context.Context, req *connect.Request[heftv1.GetPersonalRecordsRequest]) (*connect.Response[heftv1.GetPersonalRecordsResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	limit := 10
	if req.Msg.Limit != nil && *req.Msg.Limit > 0 {
		limit = int(*req.Msg.Limit)
	}

	var exerciseID *string
	if req.Msg.ExerciseId != nil && *req.Msg.ExerciseId != "" {
		exerciseID = req.Msg.ExerciseId
	}

	records, err := h.repo.GetPersonalRecords(ctx, userID, limit, exerciseID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	protoRecords := make([]*heftv1.PersonalRecord, len(records))
	for i, r := range records {
		pr := &heftv1.PersonalRecord{
			Id:           r.ID,
			UserId:       r.UserID,
			ExerciseId:   r.ExerciseID,
			ExerciseName: r.ExerciseName,
			AchievedAt:   r.AchievedAt.Format("2006-01-02"),
		}
		if r.WeightKg != nil {
			pr.WeightKg = *r.WeightKg
		}
		if r.Reps != nil {
			pr.Reps = int32(*r.Reps)
		}
		if r.TimeSeconds != nil {
			pr.TimeSeconds = int32(*r.TimeSeconds)
		}
		if r.OneRepMaxKg != nil {
			pr.OneRepMaxKg = *r.OneRepMaxKg
		}
		if r.Volume != nil {
			pr.Volume = *r.Volume
		}
		protoRecords[i] = pr
	}

	return connect.NewResponse(&heftv1.GetPersonalRecordsResponse{
		Records: protoRecords,
	}), nil
}

// GetExerciseProgress retrieves exercise progress over time
func (h *ProgressHandler) GetExerciseProgress(ctx context.Context, req *connect.Request[heftv1.GetExerciseProgressRequest]) (*connect.Response[heftv1.GetExerciseProgressResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}
	if req.Msg.ExerciseId == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("exercise_id is required"))
	}

	limit := 8
	if req.Msg.Limit != nil && *req.Msg.Limit > 0 {
		limit = int(*req.Msg.Limit)
	}

	points, err := h.repo.GetExerciseProgress(ctx, userID, req.Msg.ExerciseId, limit)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	// Get exercise info
	exercise, err := h.exerciseRepo.GetByID(ctx, req.Msg.ExerciseId)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	summary := &heftv1.ExerciseProgressSummary{
		ExerciseId:    req.Msg.ExerciseId,
		TotalSessions: int32(len(points)),
	}

	if exercise != nil {
		summary.ExerciseName = exercise.Name
		summary.ExerciseType = stringToExerciseType(exercise.ExerciseType)
	}

	protoPoints := make([]*heftv1.ExerciseProgressPoint, len(points))
	var startWeight, currentWeight, maxWeight float64
	for i, p := range points {
		protoPoints[i] = &heftv1.ExerciseProgressPoint{
			Date:      p.Date.Format("2006-01-02"),
			TotalSets: int32(p.TotalSets),
		}
		if p.BestWeightKg != nil {
			protoPoints[i].BestWeightKg = *p.BestWeightKg
			if i == len(points)-1 {
				startWeight = *p.BestWeightKg
			}
			if i == 0 {
				currentWeight = *p.BestWeightKg
			}
			if *p.BestWeightKg > maxWeight {
				maxWeight = *p.BestWeightKg
			}
		}
		if p.BestReps != nil {
			protoPoints[i].BestReps = int32(*p.BestReps)
		}
		if p.BestTimeSeconds != nil {
			protoPoints[i].BestTimeSeconds = int32(*p.BestTimeSeconds)
		}
		if p.TotalVolumeKg != nil {
			protoPoints[i].TotalVolumeKg = *p.TotalVolumeKg
		}
	}

	summary.DataPoints = protoPoints
	summary.StartingWeightKg = startWeight
	summary.CurrentWeightKg = currentWeight
	summary.MaxWeightKg = maxWeight
	if startWeight > 0 {
		summary.ImprovementPercent = ((currentWeight - startWeight) / startWeight) * 100
	}

	return connect.NewResponse(&heftv1.GetExerciseProgressResponse{
		Progress: summary,
	}), nil
}

// GetCalendarMonth retrieves calendar data for a month
func (h *ProgressHandler) GetCalendarMonth(ctx context.Context, req *connect.Request[heftv1.GetCalendarMonthRequest]) (*connect.Response[heftv1.GetCalendarMonthResponse], error) {
	_, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	// For now, return empty calendar data
	// Full implementation would query workout_sessions for the month
	return connect.NewResponse(&heftv1.GetCalendarMonthResponse{
		Days:          []*heftv1.CalendarDay{},
		TotalWorkouts: 0,
		TotalRestDays: 0,
	}), nil
}

// GetStreak retrieves streak information
func (h *ProgressHandler) GetStreak(ctx context.Context, req *connect.Request[heftv1.GetStreakRequest]) (*connect.Response[heftv1.GetStreakResponse], error) {
	userID, ok := auth.UserIDFromContext(ctx)
	if !ok {
		return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
	}

	currentStreak, longestStreak, lastWorkout, err := h.repo.GetStreak(ctx, userID)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	response := &heftv1.GetStreakResponse{
		CurrentStreak: int32(currentStreak),
		LongestStreak: int32(longestStreak),
	}
	if lastWorkout != nil {
		response.LastWorkoutDate = lastWorkout.Format("2006-01-02")
	}

	return connect.NewResponse(response), nil
}
