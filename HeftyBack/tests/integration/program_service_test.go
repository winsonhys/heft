package integration_test

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/testutil"
)

func TestProgramService_Integration_ListPrograms(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("list empty programs", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.ListProgramsRequest{
			UserId: userID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgramClient.ListPrograms(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// User has no programs yet
		if len(resp.Msg.Programs) != 0 {
			t.Errorf("expected 0 programs, got %d", len(resp.Msg.Programs))
		}
	})

	t.Run("list programs after creating some", func(t *testing.T) {
		ctx := context.Background()

		// Create a program
		createReq := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "Test Program",
			DurationWeeks: 4,
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err := ts.ProgramClient.CreateProgram(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create program: %v", err)
		}

		// List programs
		listReq := connect.NewRequest(&heftv1.ListProgramsRequest{
			UserId: userID,
		})
		listReq.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgramClient.ListPrograms(ctx, listReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if len(resp.Msg.Programs) < 1 {
			t.Errorf("expected at least 1 program, got %d", len(resp.Msg.Programs))
		}
	})
}

func TestProgramService_Integration_CreateProgram(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("create basic program", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "5x5 Strength",
			DurationWeeks: 12,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgramClient.CreateProgram(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.Program.Name != "5x5 Strength" {
			t.Errorf("expected name '5x5 Strength', got '%s'", resp.Msg.Program.Name)
		}

		if resp.Msg.Program.DurationWeeks != 12 {
			t.Errorf("expected duration 12 weeks, got %d", resp.Msg.Program.DurationWeeks)
		}

		if resp.Msg.Program.UserId != userID {
			t.Errorf("expected user ID %s, got %s", userID, resp.Msg.Program.UserId)
		}
	})

	t.Run("create program with description", func(t *testing.T) {
		ctx := context.Background()
		description := "A classic strength building program"

		req := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "StrongLifts 5x5",
			Description:   &description,
			DurationWeeks: 12,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgramClient.CreateProgram(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.Program.Description != description {
			t.Errorf("expected description '%s', got '%s'", description, resp.Msg.Program.Description)
		}
	})

	t.Run("create program with days", func(t *testing.T) {
		ctx := context.Background()

		// First create a workout template
		workoutReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "Push Day",
		})
		workoutReq.Header().Set("Authorization", ts.AuthHeader(userID))
		workoutResp, err := ts.WorkoutClient.CreateWorkout(ctx, workoutReq)
		if err != nil {
			t.Fatalf("failed to create workout: %v", err)
		}
		workoutID := workoutResp.Msg.Workout.Id

		req := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "Weekly Program",
			DurationWeeks: 1,
			Days: []*heftv1.CreateProgramDay{
				{
					DayNumber:         1,
					DayType:           heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT,
					WorkoutTemplateId: &workoutID,
				},
				{
					DayNumber: 2,
					DayType:   heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST,
				},
				{
					DayNumber:         3,
					DayType:           heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT,
					WorkoutTemplateId: &workoutID,
				},
			},
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgramClient.CreateProgram(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if len(resp.Msg.Program.Days) != 3 {
			t.Errorf("expected 3 days, got %d", len(resp.Msg.Program.Days))
		}

		// Verify day types
		if len(resp.Msg.Program.Days) >= 2 {
			if resp.Msg.Program.Days[0].DayType != heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT {
				t.Errorf("expected day 1 to be workout, got %v", resp.Msg.Program.Days[0].DayType)
			}
			if resp.Msg.Program.Days[1].DayType != heftv1.ProgramDayType_PROGRAM_DAY_TYPE_REST {
				t.Errorf("expected day 2 to be rest, got %v", resp.Msg.Program.Days[1].DayType)
			}
		}
	})
}

func TestProgramService_Integration_GetProgram(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get existing program", func(t *testing.T) {
		ctx := context.Background()

		// Create a program first
		createReq := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "Test Program",
			DurationWeeks: 4,
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.ProgramClient.CreateProgram(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create program: %v", err)
		}

		programID := createResp.Msg.Program.Id

		// Get the program
		getReq := connect.NewRequest(&heftv1.GetProgramRequest{
			Id:     programID,
			UserId: userID,
		})
		getReq.Header().Set("Authorization", ts.AuthHeader(userID))
		getResp, err := ts.ProgramClient.GetProgram(ctx, getReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if getResp.Msg.Program.Id != programID {
			t.Errorf("expected program ID %s, got %s", programID, getResp.Msg.Program.Id)
		}
	})

	t.Run("get non-existent program returns not found", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.GetProgramRequest{
			Id:     "00000000-0000-0000-0000-000000000000",
			UserId: userID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err := ts.ProgramClient.GetProgram(ctx, req)

		if err == nil {
			t.Fatal("expected error for non-existent program")
		}

		var connectErr *connect.Error
		if !errors.As(err, &connectErr) {
			t.Fatalf("expected connect error, got %T", err)
		}

		if connectErr.Code() != connect.CodeNotFound {
			t.Errorf("expected NotFound error, got %v", connectErr.Code())
		}
	})
}

func TestProgramService_Integration_DeleteProgram(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("delete existing program", func(t *testing.T) {
		ctx := context.Background()

		// Create a program first
		createReq := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "To Be Deleted",
			DurationWeeks: 4,
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.ProgramClient.CreateProgram(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create program: %v", err)
		}

		programID := createResp.Msg.Program.Id

		// Delete the program
		deleteReq := connect.NewRequest(&heftv1.DeleteProgramRequest{
			Id:     programID,
			UserId: userID,
		})
		deleteReq.Header().Set("Authorization", ts.AuthHeader(userID))
		deleteResp, err := ts.ProgramClient.DeleteProgram(ctx, deleteReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if !deleteResp.Msg.Success {
			t.Error("expected success to be true")
		}

		// Verify program is deleted
		verifyReq := connect.NewRequest(&heftv1.GetProgramRequest{
			Id:     programID,
			UserId: userID,
		})
		verifyReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.ProgramClient.GetProgram(ctx, verifyReq)

		if err == nil {
			t.Error("expected error when getting deleted program")
		}

		var connectErr *connect.Error
		if errors.As(err, &connectErr) {
			if connectErr.Code() != connect.CodeNotFound {
				t.Errorf("expected NotFound error, got %v", connectErr.Code())
			}
		}
	})
}

func TestProgramService_Integration_SetActiveProgram(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("set program as active", func(t *testing.T) {
		ctx := context.Background()

		// Create a program
		createReq := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "Active Program",
			DurationWeeks: 4,
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.ProgramClient.CreateProgram(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create program: %v", err)
		}

		programID := createResp.Msg.Program.Id

		// Set as active
		setActiveReq := connect.NewRequest(&heftv1.SetActiveProgramRequest{
			Id:     programID,
			UserId: userID,
		})
		setActiveReq.Header().Set("Authorization", ts.AuthHeader(userID))
		setActiveResp, err := ts.ProgramClient.SetActiveProgram(ctx, setActiveReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if !setActiveResp.Msg.Program.IsActive {
			t.Error("expected program to be active")
		}
	})

	t.Run("only one program can be active", func(t *testing.T) {
		ctx := context.Background()

		// Create two programs
		create1Req := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "Program One",
			DurationWeeks: 4,
		})
		create1Req.Header().Set("Authorization", ts.AuthHeader(userID))
		create1Resp, err := ts.ProgramClient.CreateProgram(ctx, create1Req)
		if err != nil {
			t.Fatalf("failed to create program 1: %v", err)
		}
		program1ID := create1Resp.Msg.Program.Id

		create2Req := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "Program Two",
			DurationWeeks: 4,
		})
		create2Req.Header().Set("Authorization", ts.AuthHeader(userID))
		create2Resp, err := ts.ProgramClient.CreateProgram(ctx, create2Req)
		if err != nil {
			t.Fatalf("failed to create program 2: %v", err)
		}
		program2ID := create2Resp.Msg.Program.Id

		// Set program 1 as active
		setActive1Req := connect.NewRequest(&heftv1.SetActiveProgramRequest{
			Id:     program1ID,
			UserId: userID,
		})
		setActive1Req.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.ProgramClient.SetActiveProgram(ctx, setActive1Req)
		if err != nil {
			t.Fatalf("failed to set program 1 active: %v", err)
		}

		// Set program 2 as active
		setActive2Req := connect.NewRequest(&heftv1.SetActiveProgramRequest{
			Id:     program2ID,
			UserId: userID,
		})
		setActive2Req.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.ProgramClient.SetActiveProgram(ctx, setActive2Req)
		if err != nil {
			t.Fatalf("failed to set program 2 active: %v", err)
		}

		// Verify program 1 is no longer active
		get1Req := connect.NewRequest(&heftv1.GetProgramRequest{
			Id:     program1ID,
			UserId: userID,
		})
		get1Req.Header().Set("Authorization", ts.AuthHeader(userID))
		get1Resp, err := ts.ProgramClient.GetProgram(ctx, get1Req)
		if err != nil {
			t.Fatalf("failed to get program 1: %v", err)
		}

		if get1Resp.Msg.Program.IsActive {
			t.Error("expected program 1 to no longer be active")
		}

		// Verify program 2 is active
		get2Req := connect.NewRequest(&heftv1.GetProgramRequest{
			Id:     program2ID,
			UserId: userID,
		})
		get2Req.Header().Set("Authorization", ts.AuthHeader(userID))
		get2Resp, err := ts.ProgramClient.GetProgram(ctx, get2Req)
		if err != nil {
			t.Fatalf("failed to get program 2: %v", err)
		}

		if !get2Resp.Msg.Program.IsActive {
			t.Error("expected program 2 to be active")
		}
	})
}

func TestProgramService_Integration_GetTodayWorkout(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("no active program returns no workout", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.GetTodayWorkoutRequest{
			UserId: userID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgramClient.GetTodayWorkout(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.HasWorkout {
			t.Error("expected HasWorkout to be false when no active program")
		}
	})

	t.Run("active program with workout day", func(t *testing.T) {
		ctx := context.Background()

		// Create a workout template
		workoutReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "Day 1 Workout",
		})
		workoutReq.Header().Set("Authorization", ts.AuthHeader(userID))
		workoutResp, err := ts.WorkoutClient.CreateWorkout(ctx, workoutReq)
		if err != nil {
			t.Fatalf("failed to create workout: %v", err)
		}
		workoutID := workoutResp.Msg.Workout.Id

		// Create a program with day 1 as workout
		createReq := connect.NewRequest(&heftv1.CreateProgramRequest{
			UserId:        userID,
			Name:          "Test Program",
			DurationWeeks: 1,
			Days: []*heftv1.CreateProgramDay{
				{
					DayNumber:         1,
					DayType:           heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT,
					WorkoutTemplateId: &workoutID,
				},
			},
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.ProgramClient.CreateProgram(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create program: %v", err)
		}
		programID := createResp.Msg.Program.Id

		// Set as active
		setActiveReq := connect.NewRequest(&heftv1.SetActiveProgramRequest{
			Id:     programID,
			UserId: userID,
		})
		setActiveReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.ProgramClient.SetActiveProgram(ctx, setActiveReq)
		if err != nil {
			t.Fatalf("failed to set active: %v", err)
		}

		// Get today's workout
		getTodayReq := connect.NewRequest(&heftv1.GetTodayWorkoutRequest{
			UserId: userID,
		})
		getTodayReq.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgramClient.GetTodayWorkout(ctx, getTodayReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if !resp.Msg.HasWorkout {
			t.Error("expected HasWorkout to be true")
		}

		if resp.Msg.DayType != heftv1.ProgramDayType_PROGRAM_DAY_TYPE_WORKOUT {
			t.Errorf("expected day type WORKOUT, got %v", resp.Msg.DayType)
		}

		if resp.Msg.Workout == nil {
			t.Error("expected workout to be returned")
		}

		if resp.Msg.Program == nil {
			t.Error("expected program to be returned")
		}
	})
}
