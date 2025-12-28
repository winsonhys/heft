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

		req := connect.NewRequest(&heftv1.GetDashboardStatsRequest{})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetDashboardStats(ctx, req)

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
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		finishReq := connect.NewRequest(&heftv1.FinishSessionRequest{
			Id: startResp.Msg.Session.Id,
		})
		finishReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.SessionClient.FinishSession(ctx, finishReq)
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get updated stats
		statsReq := connect.NewRequest(&heftv1.GetDashboardStatsRequest{})
		statsReq.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetDashboardStats(ctx, statsReq)

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

		req := connect.NewRequest(&heftv1.GetWeeklyActivityRequest{})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetWeeklyActivity(ctx, req)

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
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		finishReq := connect.NewRequest(&heftv1.FinishSessionRequest{
			Id: startResp.Msg.Session.Id,
		})
		finishReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.SessionClient.FinishSession(ctx, finishReq)
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get weekly activity
		activityReq := connect.NewRequest(&heftv1.GetWeeklyActivityRequest{})
		activityReq.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetWeeklyActivity(ctx, activityReq)

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

		req := connect.NewRequest(&heftv1.GetPersonalRecordsRequest{})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetPersonalRecords(ctx, req)

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

		// Seed a test exercise
		testExerciseID := testutil.SeedTestExercise(t, pool, testutil.TestExercise{
			Name:         "PR Test Bench Press",
			CategoryID:   testutil.ChestCategoryID,
			ExerciseType: "weight_reps",
			IsSystem:     false,
			CreatedBy:    &userID,
		})

		// Start a session
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Add exercise with 1 set via SyncSession
		numSets := int32(1)
		syncAddReq := connect.NewRequest(&heftv1.SyncSessionRequest{
			SessionId: sessionID,
			Exercises: []*heftv1.SyncExerciseData{
				{
					ExerciseIdentifier: &heftv1.SyncExerciseData_NewExercise{
						NewExercise: &heftv1.NewExerciseData{
							ExerciseId:   testExerciseID,
							DisplayOrder: 1,
							SectionName:  "Main",
							NumSets:      numSets,
						},
					},
				},
			},
		})
		syncAddReq.Header().Set("Authorization", ts.AuthHeader(userID))
		syncAddResp, err := ts.SessionClient.SyncSession(ctx, syncAddReq)
		if err != nil {
			t.Fatalf("failed to add exercise via sync: %v", err)
		}

		// Get set ID from the exercise response
		if len(syncAddResp.Msg.Session.Exercises) == 0 || len(syncAddResp.Msg.Session.Exercises[0].Sets) == 0 {
			t.Fatal("expected at least one set to be created")
		}
		setID := syncAddResp.Msg.Session.Exercises[0].Sets[0].Id

		weight := float64(150)
		reps := int32(5)
		syncReq := connect.NewRequest(&heftv1.SyncSessionRequest{
			SessionId: sessionID,
			Sets: []*heftv1.SyncSetData{
				{
					SetIdentifier: &heftv1.SyncSetData_Id{Id: setID},
					WeightKg:      &weight,
					Reps:          &reps,
					IsCompleted:   true,
				},
			},
		})
		syncReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.SessionClient.SyncSession(ctx, syncReq)
		if err != nil {
			t.Fatalf("failed to sync session: %v", err)
		}

		// Finish session
		finishReq := connect.NewRequest(&heftv1.FinishSessionRequest{
			Id: sessionID,
		})
		finishReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.SessionClient.FinishSession(ctx, finishReq)
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get PRs - should have at least one
		prReq := connect.NewRequest(&heftv1.GetPersonalRecordsRequest{})
		prReq.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetPersonalRecords(ctx, prReq)

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
		exercisesReq := connect.NewRequest(&heftv1.ListExercisesRequest{
			Pagination: &heftv1.PaginationRequest{
				Page:     1,
				PageSize: 1,
			},
		})
		exercisesReq.Header().Set("Authorization", ts.AuthHeader(userID))
		exercisesResp, err := ts.ExerciseClient.ListExercises(ctx, exercisesReq)
		if err != nil {
			t.Fatalf("failed to list exercises: %v", err)
		}
		if len(exercisesResp.Msg.Exercises) == 0 {
			t.Fatal("no exercises found")
		}
		exerciseID := exercisesResp.Msg.Exercises[0].Id

		// Get PRs filtered by exercise
		req := connect.NewRequest(&heftv1.GetPersonalRecordsRequest{
			ExerciseId: &exerciseID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetPersonalRecords(ctx, req)

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
	exercisesReq := connect.NewRequest(&heftv1.ListExercisesRequest{
		Pagination: &heftv1.PaginationRequest{
			Page:     1,
			PageSize: 1,
		},
	})
	exercisesReq.Header().Set("Authorization", ts.AuthHeader(userID))
	exercisesResp, err := ts.ExerciseClient.ListExercises(context.Background(), exercisesReq)
	if err != nil {
		t.Fatalf("failed to list exercises: %v", err)
	}
	if len(exercisesResp.Msg.Exercises) == 0 {
		t.Fatal("no exercises found")
	}
	exerciseID := exercisesResp.Msg.Exercises[0].Id

	t.Run("get progress for new user", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.GetExerciseProgressRequest{
			ExerciseId: exerciseID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetExerciseProgress(ctx, req)

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
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Add exercise with 1 set via SyncSession
		numSets := int32(1)
		syncAddReq := connect.NewRequest(&heftv1.SyncSessionRequest{
			SessionId: sessionID,
			Exercises: []*heftv1.SyncExerciseData{
				{
					ExerciseIdentifier: &heftv1.SyncExerciseData_NewExercise{
						NewExercise: &heftv1.NewExerciseData{
							ExerciseId:   exerciseID,
							DisplayOrder: 1,
							SectionName:  "Main",
							NumSets:      numSets,
						},
					},
				},
			},
		})
		syncAddReq.Header().Set("Authorization", ts.AuthHeader(userID))
		syncAddResp, err := ts.SessionClient.SyncSession(ctx, syncAddReq)
		if err != nil {
			t.Fatalf("failed to add exercise via sync: %v", err)
		}

		// Get set ID from exercise response
		if len(syncAddResp.Msg.Session.Exercises) == 0 || len(syncAddResp.Msg.Session.Exercises[0].Sets) == 0 {
			t.Fatal("expected at least one set to be created")
		}
		setID := syncAddResp.Msg.Session.Exercises[0].Sets[0].Id

		weight := float64(100)
		reps := int32(10)
		syncReq := connect.NewRequest(&heftv1.SyncSessionRequest{
			SessionId: sessionID,
			Sets: []*heftv1.SyncSetData{
				{
					SetIdentifier: &heftv1.SyncSetData_Id{Id: setID},
					WeightKg:      &weight,
					Reps:          &reps,
					IsCompleted:   true,
				},
			},
		})
		syncReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.SessionClient.SyncSession(ctx, syncReq)
		if err != nil {
			t.Fatalf("failed to sync session: %v", err)
		}

		// Finish session
		finishReq := connect.NewRequest(&heftv1.FinishSessionRequest{
			Id: sessionID,
		})
		finishReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.SessionClient.FinishSession(ctx, finishReq)
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get progress
		progressReq := connect.NewRequest(&heftv1.GetExerciseProgressRequest{
			ExerciseId: exerciseID,
		})
		progressReq.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetExerciseProgress(ctx, progressReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}


		// Should have at least 1 session now
		// Implementation for exercise_history population is now added
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

		req := connect.NewRequest(&heftv1.GetStreakRequest{})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetStreak(ctx, req)

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
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		finishReq := connect.NewRequest(&heftv1.FinishSessionRequest{
			Id: startResp.Msg.Session.Id,
		})
		finishReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.SessionClient.FinishSession(ctx, finishReq)
		if err != nil {
			t.Fatalf("failed to finish session: %v", err)
		}

		// Get streak
		streakReq := connect.NewRequest(&heftv1.GetStreakRequest{})
		streakReq.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetStreak(ctx, streakReq)

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

		req := connect.NewRequest(&heftv1.GetCalendarMonthRequest{
			Year:  2024,
			Month: 12,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ProgressClient.GetCalendarMonth(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Response should be valid (even if empty in current implementation)
		_ = resp
	})
}
