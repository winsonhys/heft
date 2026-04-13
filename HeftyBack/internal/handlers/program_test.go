package handlers_test

import (
	"context"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/auth"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/repository"
	"github.com/heftyback/internal/testutil"
)

const programDateLayout = "2006-01-02"

func makeProgramHandler(mp *testutil.MockProgramRepository, mw *testutil.MockWorkoutRepository) *handlers.ProgramHandler {
	return handlers.NewProgramHandler(mp, mw)
}

func TestProgramHandler_ListPrograms(t *testing.T) {
	mp := &testutil.MockProgramRepository{}
	mw := &testutil.MockWorkoutRepository{}

	mp.ListFunc = func(ctx context.Context, userID string, includeArchived bool, limit, offset int) ([]*repository.Program, int, error) {
		now := time.Now()
		return []*repository.Program{
			{ID: "p1", UserID: userID, Name: "PPL", StartDate: now, DurationWeeks: 4, CreatedAt: now, UpdatedAt: now},
			{ID: "p2", UserID: userID, Name: "GZCLP", StartDate: now, DurationWeeks: 8, CreatedAt: now, UpdatedAt: now},
		}, 2, nil
	}
	mp.ListWorkoutCountsFunc = func(ctx context.Context, ids []string) (map[string]int, error) {
		return map[string]int{"p1": 3, "p2": 4}, nil
	}

	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(mp, mw)

	resp, err := h.ListPrograms(ctx, connect.NewRequest(&heftv1.ListProgramsRequest{
		Pagination: &heftv1.PaginationRequest{Page: 1, PageSize: 10},
	}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Programs, 2)
	assert.Equal(t, "PPL", resp.Msg.Programs[0].Name)
	assert.Equal(t, int32(3), resp.Msg.Programs[0].TotalWorkouts)
	assert.Equal(t, int32(4), resp.Msg.Programs[1].TotalWorkouts)
}

func TestProgramHandler_ListPrograms_Unauthenticated(t *testing.T) {
	h := makeProgramHandler(&testutil.MockProgramRepository{}, &testutil.MockWorkoutRepository{})
	_, err := h.ListPrograms(context.Background(), connect.NewRequest(&heftv1.ListProgramsRequest{}))
	require.Error(t, err)
	var connectErr *connect.Error
	require.ErrorAs(t, err, &connectErr)
	assert.Equal(t, connect.CodeUnauthenticated, connectErr.Code())
}

func TestProgramHandler_GetProgram(t *testing.T) {
	mp := &testutil.MockProgramRepository{}
	now := time.Now()
	mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
		return &repository.Program{
			ID: id, UserID: userID, Name: "PPL",
			StartDate: now, DurationWeeks: 4,
			CreatedAt: now, UpdatedAt: now,
			Workouts: []*repository.ProgramWorkout{
				{ID: "pw1", ProgramID: id, WorkoutTemplateID: "wt1", WorkoutName: "Push", DaysOfWeek: []int16{1, 3, 5}, DisplayOrder: 0},
				{ID: "pw2", ProgramID: id, WorkoutTemplateID: "wt2", WorkoutName: "Pull", DaysOfWeek: []int16{2, 4}, DisplayOrder: 1},
			},
		}, nil
	}

	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(mp, &testutil.MockWorkoutRepository{})

	resp, err := h.GetProgram(ctx, connect.NewRequest(&heftv1.GetProgramRequest{Id: "p1"}))
	require.NoError(t, err)
	require.Len(t, resp.Msg.Program.Workouts, 2)
	assert.ElementsMatch(t, []heftv1.DayOfWeek{
		heftv1.DayOfWeek_DAY_OF_WEEK_MONDAY,
		heftv1.DayOfWeek_DAY_OF_WEEK_WEDNESDAY,
		heftv1.DayOfWeek_DAY_OF_WEEK_FRIDAY,
	}, resp.Msg.Program.Workouts[0].DaysOfWeek)
}

func TestProgramHandler_GetProgram_NotFound(t *testing.T) {
	mp := &testutil.MockProgramRepository{}
	mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
		return nil, nil
	}
	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(mp, &testutil.MockWorkoutRepository{})
	_, err := h.GetProgram(ctx, connect.NewRequest(&heftv1.GetProgramRequest{Id: "p1"}))
	require.Error(t, err)
	var connectErr *connect.Error
	require.ErrorAs(t, err, &connectErr)
	assert.Equal(t, connect.CodeNotFound, connectErr.Code())
}

func TestProgramHandler_CreateProgram(t *testing.T) {
	mp := &testutil.MockProgramRepository{}
	now := time.Date(2026, 4, 13, 0, 0, 0, 0, time.UTC)

	mp.CreateFunc = func(ctx context.Context, userID, name string, description *string, startDate time.Time, durationWeeks int) (*repository.Program, error) {
		assert.Equal(t, "PPL", name)
		assert.Equal(t, now, startDate)
		assert.Equal(t, 4, durationWeeks)
		return &repository.Program{ID: "new-id", UserID: userID, Name: name, StartDate: startDate, DurationWeeks: durationWeeks, CreatedAt: now, UpdatedAt: now}, nil
	}

	createdWorkouts := 0
	mp.CreateWorkoutFunc = func(ctx context.Context, programID, workoutTemplateID string, daysOfWeek []int16, displayOrder int) (*repository.ProgramWorkout, error) {
		createdWorkouts++
		return &repository.ProgramWorkout{ID: "pw", ProgramID: programID, WorkoutTemplateID: workoutTemplateID, DaysOfWeek: daysOfWeek, DisplayOrder: displayOrder}, nil
	}

	mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
		return &repository.Program{ID: id, UserID: userID, Name: "PPL", StartDate: now, DurationWeeks: 4, CreatedAt: now, UpdatedAt: now}, nil
	}

	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(mp, &testutil.MockWorkoutRepository{})

	resp, err := h.CreateProgram(ctx, connect.NewRequest(&heftv1.CreateProgramRequest{
		Name:          "PPL",
		StartDate:     now.Format(programDateLayout),
		DurationWeeks: 4,
		Workouts: []*heftv1.ProgramWorkoutInput{
			{WorkoutTemplateId: "wt1", DaysOfWeek: []heftv1.DayOfWeek{heftv1.DayOfWeek_DAY_OF_WEEK_MONDAY, heftv1.DayOfWeek_DAY_OF_WEEK_WEDNESDAY}},
			{WorkoutTemplateId: "wt2", DaysOfWeek: []heftv1.DayOfWeek{heftv1.DayOfWeek_DAY_OF_WEEK_TUESDAY}},
		},
	}))
	require.NoError(t, err)
	assert.Equal(t, "new-id", resp.Msg.Program.Id)
	assert.Equal(t, 2, createdWorkouts)
}

func TestProgramHandler_CreateProgram_ValidationErrors(t *testing.T) {
	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(&testutil.MockProgramRepository{}, &testutil.MockWorkoutRepository{})

	cases := []struct {
		name string
		req  *heftv1.CreateProgramRequest
	}{
		{"missing name", &heftv1.CreateProgramRequest{StartDate: "2026-04-13", DurationWeeks: 4}},
		{"missing start_date", &heftv1.CreateProgramRequest{Name: "x", DurationWeeks: 4}},
		{"bad start_date", &heftv1.CreateProgramRequest{Name: "x", StartDate: "nope", DurationWeeks: 4}},
		{"zero duration", &heftv1.CreateProgramRequest{Name: "x", StartDate: "2026-04-13", DurationWeeks: 0}},
		{"workout missing template", &heftv1.CreateProgramRequest{Name: "x", StartDate: "2026-04-13", DurationWeeks: 4, Workouts: []*heftv1.ProgramWorkoutInput{{DaysOfWeek: []heftv1.DayOfWeek{heftv1.DayOfWeek_DAY_OF_WEEK_MONDAY}}}}},
		{"workout missing days", &heftv1.CreateProgramRequest{Name: "x", StartDate: "2026-04-13", DurationWeeks: 4, Workouts: []*heftv1.ProgramWorkoutInput{{WorkoutTemplateId: "wt1"}}}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			_, err := h.CreateProgram(ctx, connect.NewRequest(tc.req))
			require.Error(t, err)
			var connectErr *connect.Error
			require.ErrorAs(t, err, &connectErr)
			assert.Equal(t, connect.CodeInvalidArgument, connectErr.Code())
		})
	}
}

func TestProgramHandler_UpdateProgram_ReplaceWorkouts(t *testing.T) {
	mp := &testutil.MockProgramRepository{}
	now := time.Now()

	updateCalled := false
	mp.UpdateFunc = func(ctx context.Context, id, userID string, name, description *string, startDate *time.Time, durationWeeks *int, isArchived *bool) (*repository.Program, error) {
		updateCalled = true
		return &repository.Program{ID: id, UserID: userID, Name: "PPL", StartDate: now, DurationWeeks: 4, CreatedAt: now, UpdatedAt: now}, nil
	}
	deleteCalled := false
	mp.DeleteWorkoutsFunc = func(ctx context.Context, programID, userID string) error {
		deleteCalled = true
		return nil
	}
	created := 0
	mp.CreateWorkoutFunc = func(ctx context.Context, programID, workoutTemplateID string, daysOfWeek []int16, displayOrder int) (*repository.ProgramWorkout, error) {
		created++
		return &repository.ProgramWorkout{ID: "pw", ProgramID: programID, WorkoutTemplateID: workoutTemplateID, DaysOfWeek: daysOfWeek, DisplayOrder: displayOrder}, nil
	}
	mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
		return &repository.Program{ID: id, UserID: userID, Name: "PPL", StartDate: now, DurationWeeks: 4, CreatedAt: now, UpdatedAt: now}, nil
	}

	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(mp, &testutil.MockWorkoutRepository{})

	_, err := h.UpdateProgram(ctx, connect.NewRequest(&heftv1.UpdateProgramRequest{
		Id:               "p1",
		ReplaceWorkouts:  true,
		Workouts: []*heftv1.ProgramWorkoutInput{
			{WorkoutTemplateId: "wt1", DaysOfWeek: []heftv1.DayOfWeek{heftv1.DayOfWeek_DAY_OF_WEEK_MONDAY}},
		},
	}))
	require.NoError(t, err)
	assert.True(t, updateCalled)
	assert.True(t, deleteCalled)
	assert.Equal(t, 1, created)
}

func TestProgramHandler_SetActiveProgram(t *testing.T) {
	mp := &testutil.MockProgramRepository{}
	now := time.Now()
	mp.SetActiveFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
		return &repository.Program{ID: id, UserID: userID, Name: "PPL", StartDate: now, DurationWeeks: 4, IsActive: true}, nil
	}
	mp.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.Program, error) {
		return &repository.Program{ID: id, UserID: userID, Name: "PPL", StartDate: now, DurationWeeks: 4, IsActive: true, CreatedAt: now, UpdatedAt: now}, nil
	}

	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(mp, &testutil.MockWorkoutRepository{})

	resp, err := h.SetActiveProgram(ctx, connect.NewRequest(&heftv1.SetActiveProgramRequest{Id: "p1"}))
	require.NoError(t, err)
	assert.True(t, resp.Msg.Program.IsActive)
}

func TestProgramHandler_GetTodayWorkout_NoActiveProgram(t *testing.T) {
	mp := &testutil.MockProgramRepository{}
	mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
		return nil, nil
	}

	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(mp, &testutil.MockWorkoutRepository{})

	resp, err := h.GetTodayWorkout(ctx, connect.NewRequest(&heftv1.GetTodayWorkoutRequest{}))
	require.NoError(t, err)
	assert.False(t, resp.Msg.InProgramWindow)
	assert.Empty(t, resp.Msg.Workouts)
	assert.NotEmpty(t, resp.Msg.Date)
}

func TestProgramHandler_GetTodayWorkout_MatchesWeekday(t *testing.T) {
	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	todayISO := int16(today.Weekday())
	if todayISO == 0 {
		todayISO = 7
	}

	mp := &testutil.MockProgramRepository{}
	mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
		return &repository.Program{
			ID: "p1", UserID: userID, Name: "PPL",
			StartDate: today.AddDate(0, 0, -7), DurationWeeks: 4,
			IsActive: true,
			Workouts: []*repository.ProgramWorkout{
				{ID: "pw1", ProgramID: "p1", WorkoutTemplateID: "wt-today", DaysOfWeek: []int16{todayISO}},
				{ID: "pw2", ProgramID: "p1", WorkoutTemplateID: "wt-other", DaysOfWeek: []int16{((todayISO % 7) + 1)}},
			},
		}, nil
	}

	mw := &testutil.MockWorkoutRepository{}
	mw.GetByIDFunc = func(ctx context.Context, id, userID string) (*repository.WorkoutTemplate, error) {
		return &repository.WorkoutTemplate{ID: id, UserID: userID, Name: "Workout " + id, CreatedAt: now, UpdatedAt: now}, nil
	}

	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(mp, mw)

	resp, err := h.GetTodayWorkout(ctx, connect.NewRequest(&heftv1.GetTodayWorkoutRequest{}))
	require.NoError(t, err)
	assert.True(t, resp.Msg.InProgramWindow)
	require.Len(t, resp.Msg.Workouts, 1)
	assert.Equal(t, "wt-today", resp.Msg.Workouts[0].Id)
}

func TestProgramHandler_GetTodayWorkout_OutsideProgramWindow(t *testing.T) {
	now := time.Now()
	mp := &testutil.MockProgramRepository{}
	mp.GetActiveProgramFunc = func(ctx context.Context, userID string) (*repository.Program, error) {
		return &repository.Program{
			ID: "p1", UserID: userID, Name: "PPL",
			StartDate: now.AddDate(0, 0, -100), DurationWeeks: 4,
			IsActive: true,
			Workouts: []*repository.ProgramWorkout{
				{ID: "pw1", ProgramID: "p1", WorkoutTemplateID: "wt", DaysOfWeek: []int16{1, 2, 3, 4, 5, 6, 7}},
			},
		}, nil
	}

	ctx := auth.ContextWithUserID(context.Background(), "user-123")
	h := makeProgramHandler(mp, &testutil.MockWorkoutRepository{})

	resp, err := h.GetTodayWorkout(ctx, connect.NewRequest(&heftv1.GetTodayWorkoutRequest{}))
	require.NoError(t, err)
	assert.False(t, resp.Msg.InProgramWindow)
	assert.Empty(t, resp.Msg.Workouts)
}
