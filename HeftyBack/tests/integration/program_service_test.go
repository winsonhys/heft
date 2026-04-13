package integration_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/testutil"
)

const isoDate = "2006-01-02"

func todayDate() string { return time.Now().Format(isoDate) }

func TestProgramService_Integration_CreateAndList(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	user := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, user)
	ctx := context.Background()

	authReq := func(msg any) func(req any) {
		return func(req any) {}
	}
	_ = authReq

	createReq := connect.NewRequest(&heftv1.CreateProgramRequest{
		Name:          "PPL",
		StartDate:     todayDate(),
		DurationWeeks: 4,
	})
	createReq.Header().Set("Authorization", ts.AuthHeader(userID))
	createResp, err := ts.ProgramClient.CreateProgram(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateProgram: %v", err)
	}
	if createResp.Msg.Program.Id == "" {
		t.Fatal("expected program id to be set")
	}
	if createResp.Msg.Program.StartDate != todayDate() {
		t.Errorf("start_date mismatch: %s", createResp.Msg.Program.StartDate)
	}

	listReq := connect.NewRequest(&heftv1.ListProgramsRequest{})
	listReq.Header().Set("Authorization", ts.AuthHeader(userID))
	listResp, err := ts.ProgramClient.ListPrograms(ctx, listReq)
	if err != nil {
		t.Fatalf("ListPrograms: %v", err)
	}
	if len(listResp.Msg.Programs) != 1 {
		t.Fatalf("expected 1 program, got %d", len(listResp.Msg.Programs))
	}
	if listResp.Msg.Programs[0].TotalWorkouts != 0 {
		t.Errorf("expected 0 workouts, got %d", listResp.Msg.Programs[0].TotalWorkouts)
	}
}

func TestProgramService_Integration_CreateProgram_Validation(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	user := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, user)
	ctx := context.Background()

	cases := []struct {
		name string
		req  *heftv1.CreateProgramRequest
	}{
		{"missing name", &heftv1.CreateProgramRequest{StartDate: todayDate(), DurationWeeks: 4}},
		{"missing start_date", &heftv1.CreateProgramRequest{Name: "x", DurationWeeks: 4}},
		{"bad start_date", &heftv1.CreateProgramRequest{Name: "x", StartDate: "nope", DurationWeeks: 4}},
		{"zero duration", &heftv1.CreateProgramRequest{Name: "x", StartDate: todayDate(), DurationWeeks: 0}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			req := connect.NewRequest(tc.req)
			req.Header().Set("Authorization", ts.AuthHeader(userID))
			_, err := ts.ProgramClient.CreateProgram(ctx, req)
			if err == nil {
				t.Fatal("expected error")
			}
			var connectErr *connect.Error
			if !errors.As(err, &connectErr) || connectErr.Code() != connect.CodeInvalidArgument {
				t.Fatalf("expected InvalidArgument, got %v", err)
			}
		})
	}
}

func TestProgramService_Integration_SetActiveAndGetTodayWorkout(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	user := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, user)
	ctx := context.Background()

	// Need a workout template to assign
	wtReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{Name: "Push"})
	wtReq.Header().Set("Authorization", ts.AuthHeader(userID))
	wtResp, err := ts.WorkoutClient.CreateWorkout(ctx, wtReq)
	if err != nil {
		t.Fatalf("CreateWorkout: %v", err)
	}
	wtID := wtResp.Msg.Workout.Id

	// Build a program scheduled on every weekday so today is always in window
	allDays := []heftv1.DayOfWeek{
		heftv1.DayOfWeek_DAY_OF_WEEK_MONDAY,
		heftv1.DayOfWeek_DAY_OF_WEEK_TUESDAY,
		heftv1.DayOfWeek_DAY_OF_WEEK_WEDNESDAY,
		heftv1.DayOfWeek_DAY_OF_WEEK_THURSDAY,
		heftv1.DayOfWeek_DAY_OF_WEEK_FRIDAY,
		heftv1.DayOfWeek_DAY_OF_WEEK_SATURDAY,
		heftv1.DayOfWeek_DAY_OF_WEEK_SUNDAY,
	}
	createReq := connect.NewRequest(&heftv1.CreateProgramRequest{
		Name:          "Daily",
		StartDate:     todayDate(),
		DurationWeeks: 4,
		Workouts: []*heftv1.ProgramWorkoutInput{
			{WorkoutTemplateId: wtID, DaysOfWeek: allDays},
		},
	})
	createReq.Header().Set("Authorization", ts.AuthHeader(userID))
	createResp, err := ts.ProgramClient.CreateProgram(ctx, createReq)
	if err != nil {
		t.Fatalf("CreateProgram: %v", err)
	}
	pid := createResp.Msg.Program.Id

	setReq := connect.NewRequest(&heftv1.SetActiveProgramRequest{Id: pid})
	setReq.Header().Set("Authorization", ts.AuthHeader(userID))
	if _, err := ts.ProgramClient.SetActiveProgram(ctx, setReq); err != nil {
		t.Fatalf("SetActiveProgram: %v", err)
	}

	todayReq := connect.NewRequest(&heftv1.GetTodayWorkoutRequest{})
	todayReq.Header().Set("Authorization", ts.AuthHeader(userID))
	todayResp, err := ts.ProgramClient.GetTodayWorkout(ctx, todayReq)
	if err != nil {
		t.Fatalf("GetTodayWorkout: %v", err)
	}
	if !todayResp.Msg.InProgramWindow {
		t.Fatal("expected in_program_window=true")
	}
	if len(todayResp.Msg.Workouts) != 1 || todayResp.Msg.Workouts[0].Id != wtID {
		t.Fatalf("expected today's workout=%s, got %+v", wtID, todayResp.Msg.Workouts)
	}
}
