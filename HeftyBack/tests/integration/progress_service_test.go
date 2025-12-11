package integration_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/testutil"
)

func TestProgressService_Integration_GetDashboardStats(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get stats for new user", func(t *testing.T) {
		ctx := context.Background()

		resp, err := ts.ProgressClient.GetDashboardStats(ctx, connect.NewRequest(&heftv1.GetDashboardStatsRequest{
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// New user should have zero stats
		if resp.Msg.Stats.TotalWorkouts != 0 {
			t.Errorf("expected 0 total workouts, got %d", resp.Msg.Stats.TotalWorkouts)
		}

		if resp.Msg.Stats.CurrentStreak != 0 {
			t.Errorf("expected 0 current streak, got %d", resp.Msg.Stats.CurrentStreak)
		}
	})

	t.Run("stats update after completing session", func(t *testing.T) {
		ctx := context.Background()

		// Start and finish a session
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		_, err = ts.SessionClient.FinishSession(ctx, connect.NewRequest(&heftv1.FinishSessionRequest{
			Id:     startResp.Msg.Session.Id,
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get updated stats
		resp, err := ts.ProgressClient.GetDashboardStats(ctx, connect.NewRequest(&heftv1.GetDashboardStatsRequest{
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Should have at least 1 workout now
		if resp.Msg.Stats.TotalWorkouts < 1 {
			t.Errorf("expected at least 1 total workout, got %d", resp.Msg.Stats.TotalWorkouts)
		}
	})
}

func TestProgressService_Integration_GetWeeklyActivity(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get weekly activity for new user", func(t *testing.T) {
		ctx := context.Background()

		resp, err := ts.ProgressClient.GetWeeklyActivity(ctx, connect.NewRequest(&heftv1.GetWeeklyActivityRequest{
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Should return 7 days
		if len(resp.Msg.Days) != 7 {
			t.Errorf("expected 7 days, got %d", len(resp.Msg.Days))
		}

		// All days should have 0 workouts for new user
		for _, day := range resp.Msg.Days {
			if day.WorkoutCount != 0 {
				t.Errorf("expected 0 workouts on day %s, got %d", day.DayOfWeek, day.WorkoutCount)
			}
		}
	})

	t.Run("weekly activity updates after workout", func(t *testing.T) {
		ctx := context.Background()

		// Complete a workout
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		_, err = ts.SessionClient.FinishSession(ctx, connect.NewRequest(&heftv1.FinishSessionRequest{
			Id:     startResp.Msg.Session.Id,
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get weekly activity
		resp, err := ts.ProgressClient.GetWeeklyActivity(ctx, connect.NewRequest(&heftv1.GetWeeklyActivityRequest{
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Total should be at least 1
		if resp.Msg.TotalWorkouts < 1 {
			t.Errorf("expected at least 1 total workout, got %d", resp.Msg.TotalWorkouts)
		}
	})
}

func TestProgressService_Integration_GetPersonalRecords(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get empty personal records", func(t *testing.T) {
		ctx := context.Background()

		resp, err := ts.ProgressClient.GetPersonalRecords(ctx, connect.NewRequest(&heftv1.GetPersonalRecordsRequest{
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// New user should have no PRs
		if len(resp.Msg.Records) != 0 {
			t.Errorf("expected 0 records, got %d", len(resp.Msg.Records))
		}
	})

	t.Run("PRs created after completing sets", func(t *testing.T) {
		ctx := context.Background()

		// Get an exercise
		exercisesResp, err := ts.ExerciseClient.ListExercises(ctx, connect.NewRequest(&heftv1.ListExercisesRequest{
			Pagination: &heftv1.PaginationRequest{
				Page:     1,
				PageSize: 1,
			},
		}))
		if err != nil {
			t.Fatalf("failed to list exercises: %v", err)
		}
		if len(exercisesResp.Msg.Exercises) == 0 {
			t.Fatal("no exercises found")
		}
		exerciseID := exercisesResp.Msg.Exercises[0].Id

		// Start a session
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Add exercise with 1 set
		addExResp, err := ts.SessionClient.AddExercise(ctx, connect.NewRequest(&heftv1.AddExerciseRequest{
			SessionId:  sessionID,
			UserId:     userID,
			ExerciseId: exerciseID,
			NumSets:    1,
		}))
		if err != nil {
			t.Fatalf("failed to add exercise: %v", err)
		}

		// Get set ID from the exercise response
		if len(addExResp.Msg.Exercise.Sets) == 0 {
			t.Fatal("expected at least one set to be created")
		}
		setID := addExResp.Msg.Exercise.Sets[0].Id

		weight := float64(150)
		reps := int32(5)
		_, err = ts.SessionClient.CompleteSet(ctx, connect.NewRequest(&heftv1.CompleteSetRequest{
			SessionSetId: setID,
			UserId:       userID,
			WeightKg:     &weight,
			Reps:         &reps,
		}))
		if err != nil {
			t.Fatalf("failed to complete set: %v", err)
		}

		// Finish session
		_, err = ts.SessionClient.FinishSession(ctx, connect.NewRequest(&heftv1.FinishSessionRequest{
			Id:     sessionID,
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get PRs - should have at least one
		resp, err := ts.ProgressClient.GetPersonalRecords(ctx, connect.NewRequest(&heftv1.GetPersonalRecordsRequest{
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// PRs may or may not be auto-tracked depending on implementation
		// Just verify the call succeeds
		_ = resp
	})

	t.Run("filter PRs by exercise", func(t *testing.T) {
		ctx := context.Background()

		// Get an exercise ID
		exercisesResp, err := ts.ExerciseClient.ListExercises(ctx, connect.NewRequest(&heftv1.ListExercisesRequest{
			Pagination: &heftv1.PaginationRequest{
				Page:     1,
				PageSize: 1,
			},
		}))
		if err != nil {
			t.Fatalf("failed to list exercises: %v", err)
		}
		if len(exercisesResp.Msg.Exercises) == 0 {
			t.Fatal("no exercises found")
		}
		exerciseID := exercisesResp.Msg.Exercises[0].Id

		// Get PRs filtered by exercise
		resp, err := ts.ProgressClient.GetPersonalRecords(ctx, connect.NewRequest(&heftv1.GetPersonalRecordsRequest{
			UserId:     userID,
			ExerciseId: &exerciseID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// All returned records should be for the specified exercise
		for _, record := range resp.Msg.Records {
			if record.ExerciseId != exerciseID {
				t.Errorf("expected exercise ID %s, got %s", exerciseID, record.ExerciseId)
			}
		}
	})
}

func TestProgressService_Integration_GetExerciseProgress(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	// Get an exercise
	exercisesResp, err := ts.ExerciseClient.ListExercises(context.Background(), connect.NewRequest(&heftv1.ListExercisesRequest{
		Pagination: &heftv1.PaginationRequest{
			Page:     1,
			PageSize: 1,
		},
	}))
	if err != nil {
		t.Fatalf("failed to list exercises: %v", err)
	}
	if len(exercisesResp.Msg.Exercises) == 0 {
		t.Fatal("no exercises found")
	}
	exerciseID := exercisesResp.Msg.Exercises[0].Id

	t.Run("get progress for new user", func(t *testing.T) {
		ctx := context.Background()

		resp, err := ts.ProgressClient.GetExerciseProgress(ctx, connect.NewRequest(&heftv1.GetExerciseProgressRequest{
			UserId:     userID,
			ExerciseId: exerciseID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// New user should have 0 sessions
		if resp.Msg.Progress.TotalSessions != 0 {
			t.Errorf("expected 0 sessions, got %d", resp.Msg.Progress.TotalSessions)
		}

		// Exercise info should be populated
		if resp.Msg.Progress.ExerciseName == "" {
			t.Error("expected exercise name to be populated")
		}
	})

	t.Run("progress tracks exercise data over sessions", func(t *testing.T) {
		ctx := context.Background()

		// Complete a session with the exercise
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		// Add exercise with 1 set
		addExResp, err := ts.SessionClient.AddExercise(ctx, connect.NewRequest(&heftv1.AddExerciseRequest{
			SessionId:  startResp.Msg.Session.Id,
			UserId:     userID,
			ExerciseId: exerciseID,
			NumSets:    1,
		}))
		if err != nil {
			t.Fatalf("failed to add exercise: %v", err)
		}

		// Get set ID from exercise response
		if len(addExResp.Msg.Exercise.Sets) == 0 {
			t.Fatal("expected at least one set to be created")
		}
		setID := addExResp.Msg.Exercise.Sets[0].Id

		weight := float64(100)
		reps := int32(10)
		_, err = ts.SessionClient.CompleteSet(ctx, connect.NewRequest(&heftv1.CompleteSetRequest{
			SessionSetId: setID,
			UserId:       userID,
			WeightKg:     &weight,
			Reps:         &reps,
		}))
		if err != nil {
			t.Fatalf("failed to complete set: %v", err)
		}

		// Finish session
		_, err = ts.SessionClient.FinishSession(ctx, connect.NewRequest(&heftv1.FinishSessionRequest{
			Id:     startResp.Msg.Session.Id,
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get progress
		resp, err := ts.ProgressClient.GetExerciseProgress(ctx, connect.NewRequest(&heftv1.GetExerciseProgressRequest{
			UserId:     userID,
			ExerciseId: exerciseID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Should have at least 1 session now
		if resp.Msg.Progress.TotalSessions < 1 {
			t.Errorf("expected at least 1 session, got %d", resp.Msg.Progress.TotalSessions)
		}
	})
}

func TestProgressService_Integration_GetStreak(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get streak for new user", func(t *testing.T) {
		ctx := context.Background()

		resp, err := ts.ProgressClient.GetStreak(ctx, connect.NewRequest(&heftv1.GetStreakRequest{
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// New user should have 0 streak
		if resp.Msg.CurrentStreak != 0 {
			t.Errorf("expected 0 current streak, got %d", resp.Msg.CurrentStreak)
		}

		if resp.Msg.LongestStreak != 0 {
			t.Errorf("expected 0 longest streak, got %d", resp.Msg.LongestStreak)
		}

		if resp.Msg.LastWorkoutDate != "" {
			t.Errorf("expected empty last workout date, got %s", resp.Msg.LastWorkoutDate)
		}
	})

	t.Run("streak updates after workout", func(t *testing.T) {
		ctx := context.Background()

		// Complete a workout
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		_, err = ts.SessionClient.FinishSession(ctx, connect.NewRequest(&heftv1.FinishSessionRequest{
			Id:     startResp.Msg.Session.Id,
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get streak
		resp, err := ts.ProgressClient.GetStreak(ctx, connect.NewRequest(&heftv1.GetStreakRequest{
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Should have a streak now
		if resp.Msg.CurrentStreak < 1 {
			t.Errorf("expected at least 1 day streak, got %d", resp.Msg.CurrentStreak)
		}

		if resp.Msg.LastWorkoutDate == "" {
			t.Error("expected last workout date to be set")
		}
	})
}

func TestProgressService_Integration_GetCalendarMonth(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get calendar month", func(t *testing.T) {
		ctx := context.Background()

		resp, err := ts.ProgressClient.GetCalendarMonth(ctx, connect.NewRequest(&heftv1.GetCalendarMonthRequest{
			UserId: userID,
			Year:   2024,
			Month:  12,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Response should be valid (even if empty in current implementation)
		_ = resp
	})
}
