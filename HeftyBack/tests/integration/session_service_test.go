package integration_test

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/testutil"
)

func TestSessionService_Integration_StartSession(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("start empty session", func(t *testing.T) {
		ctx := context.Background()

		resp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.Session.UserId != userID {
			t.Errorf("expected user ID %s, got %s", userID, resp.Msg.Session.UserId)
		}

		if resp.Msg.Session.Status != heftv1.WorkoutStatus_WORKOUT_STATUS_IN_PROGRESS {
			t.Errorf("expected status IN_PROGRESS, got %v", resp.Msg.Session.Status)
		}

		if resp.Msg.Session.Id == "" {
			t.Error("expected session ID to be set")
		}
	})

	t.Run("start session with name", func(t *testing.T) {
		ctx := context.Background()
		sessionName := "Morning Workout"

		resp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
			Name:   &sessionName,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.Session.Name != sessionName {
			t.Errorf("expected name '%s', got '%s'", sessionName, resp.Msg.Session.Name)
		}
	})
}

func TestSessionService_Integration_GetSession(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get existing session", func(t *testing.T) {
		ctx := context.Background()

		// Start a session first
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		sessionID := startResp.Msg.Session.Id

		// Get the session
		getResp, err := ts.SessionClient.GetSession(ctx, connect.NewRequest(&heftv1.GetSessionRequest{
			Id:     sessionID,
			UserId: userID,
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if getResp.Msg.Session.Id != sessionID {
			t.Errorf("expected session ID %s, got %s", sessionID, getResp.Msg.Session.Id)
		}
	})

	t.Run("get non-existent session returns not found", func(t *testing.T) {
		ctx := context.Background()

		_, err := ts.SessionClient.GetSession(ctx, connect.NewRequest(&heftv1.GetSessionRequest{
			Id:     "00000000-0000-0000-0000-000000000000",
			UserId: userID,
		}))

		if err == nil {
			t.Fatal("expected error for non-existent session")
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

func TestSessionService_Integration_ListSessions(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("list sessions with pagination", func(t *testing.T) {
		ctx := context.Background()

		// Create a few sessions
		for i := 0; i < 3; i++ {
			_, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
				UserId: userID,
			}))
			if err != nil {
				t.Fatalf("failed to start session %d: %v", i, err)
			}
		}

		// List sessions
		resp, err := ts.SessionClient.ListSessions(ctx, connect.NewRequest(&heftv1.ListSessionsRequest{
			UserId: userID,
			Pagination: &heftv1.PaginationRequest{
				Page:     1,
				PageSize: 10,
			},
		}))

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if len(resp.Msg.Sessions) < 3 {
			t.Errorf("expected at least 3 sessions, got %d", len(resp.Msg.Sessions))
		}
	})
}

func TestSessionService_Integration_AddExerciseAndCompleteSets(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	// Get an exercise ID
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

	t.Run("add exercise to session and complete sets", func(t *testing.T) {
		ctx := context.Background()

		// Start a session
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Add an exercise with 1 set
		addExResp, err := ts.SessionClient.AddExercise(ctx, connect.NewRequest(&heftv1.AddExerciseRequest{
			SessionId:  sessionID,
			UserId:     userID,
			ExerciseId: exerciseID,
			NumSets:    1,
		}))
		if err != nil {
			t.Fatalf("failed to add exercise: %v", err)
		}

		if addExResp.Msg.Exercise.ExerciseId != exerciseID {
			t.Errorf("expected exercise ID %s, got %s", exerciseID, addExResp.Msg.Exercise.ExerciseId)
		}

		// Get the set ID from the exercise response
		if len(addExResp.Msg.Exercise.Sets) == 0 {
			t.Fatal("expected at least one set to be created")
		}
		setID := addExResp.Msg.Exercise.Sets[0].Id

		// Complete the set
		weight := 100.0
		reps := int32(10)
		completeResp, err := ts.SessionClient.CompleteSet(ctx, connect.NewRequest(&heftv1.CompleteSetRequest{
			SessionSetId: setID,
			UserId:       userID,
			WeightKg:     &weight,
			Reps:         &reps,
		}))
		if err != nil {
			t.Fatalf("failed to complete set: %v", err)
		}

		if completeResp.Msg.Set.WeightKg == nil || *completeResp.Msg.Set.WeightKg != weight {
			t.Errorf("expected weight %f, got %v", weight, completeResp.Msg.Set.WeightKg)
		}

		if completeResp.Msg.Set.Reps == nil || *completeResp.Msg.Set.Reps != reps {
			t.Errorf("expected reps %d, got %v", reps, completeResp.Msg.Set.Reps)
		}

		if !completeResp.Msg.Set.IsCompleted {
			t.Error("expected set to be marked as completed")
		}
	})
}

func TestSessionService_Integration_FinishSession(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("finish a session", func(t *testing.T) {
		ctx := context.Background()

		// Start a session
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Finish the session
		finishResp, err := ts.SessionClient.FinishSession(ctx, connect.NewRequest(&heftv1.FinishSessionRequest{
			Id:     sessionID,
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if finishResp.Msg.Session.Status != heftv1.WorkoutStatus_WORKOUT_STATUS_COMPLETED {
			t.Errorf("expected status COMPLETED, got %v", finishResp.Msg.Session.Status)
		}

		if finishResp.Msg.Session.CompletedAt == nil {
			t.Error("expected completed_at to be set")
		}
	})

	t.Run("finish session with notes", func(t *testing.T) {
		ctx := context.Background()

		// Start a session
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Finish the session with notes
		notes := "Great workout today!"
		finishResp, err := ts.SessionClient.FinishSession(ctx, connect.NewRequest(&heftv1.FinishSessionRequest{
			Id:     sessionID,
			UserId: userID,
			Notes:  &notes,
		}))
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if finishResp.Msg.Session.Notes != notes {
			t.Errorf("expected notes '%s', got '%s'", notes, finishResp.Msg.Session.Notes)
		}
	})
}

func TestSessionService_Integration_AbandonSession(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("abandon a session", func(t *testing.T) {
		ctx := context.Background()

		// Start a session
		startResp, err := ts.SessionClient.StartSession(ctx, connect.NewRequest(&heftv1.StartSessionRequest{
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Abandon the session
		_, err = ts.SessionClient.AbandonSession(ctx, connect.NewRequest(&heftv1.AbandonSessionRequest{
			Id:     sessionID,
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Verify session is abandoned by getting it
		getResp, err := ts.SessionClient.GetSession(ctx, connect.NewRequest(&heftv1.GetSessionRequest{
			Id:     sessionID,
			UserId: userID,
		}))
		if err != nil {
			t.Fatalf("failed to get session: %v", err)
		}

		if getResp.Msg.Session.Status != heftv1.WorkoutStatus_WORKOUT_STATUS_ABANDONED {
			t.Errorf("expected status ABANDONED, got %v", getResp.Msg.Session.Status)
		}
	})
}
