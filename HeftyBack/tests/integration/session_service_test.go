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

		req := connect.NewRequest(&heftv1.StartSessionRequest{})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.SessionClient.StartSession(ctx, req)

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

		// Clean up - abandon the session so next test can start a new one
		abandonReq := connect.NewRequest(&heftv1.AbandonSessionRequest{
			Id: resp.Msg.Session.Id,
		})
		abandonReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, _ = ts.SessionClient.AbandonSession(ctx, abandonReq)
	})

	t.Run("start session with name", func(t *testing.T) {
		ctx := context.Background()
		sessionName := "Morning Workout"

		req := connect.NewRequest(&heftv1.StartSessionRequest{
			Name:   &sessionName,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.SessionClient.StartSession(ctx, req)

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
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		sessionID := startResp.Msg.Session.Id

		// Get the session
		getReq := connect.NewRequest(&heftv1.GetSessionRequest{
			Id: sessionID,
		})
		getReq.Header().Set("Authorization", ts.AuthHeader(userID))
		getResp, err := ts.SessionClient.GetSession(ctx, getReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if getResp.Msg.Session.Id != sessionID {
			t.Errorf("expected session ID %s, got %s", sessionID, getResp.Msg.Session.Id)
		}
	})

	t.Run("get non-existent session returns not found", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.GetSessionRequest{
			Id: "00000000-0000-0000-0000-000000000000",
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err := ts.SessionClient.GetSession(ctx, req)

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

		// Create a few sessions - must finish each before starting the next
		for i := 0; i < 3; i++ {
			startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
			startReq.Header().Set("Authorization", ts.AuthHeader(userID))
			startResp, err := ts.SessionClient.StartSession(ctx, startReq)
			if err != nil {
				t.Fatalf("failed to start session %d: %v", i, err)
			}

			// Finish the session so we can start the next one
			finishReq := connect.NewRequest(&heftv1.FinishSessionRequest{
				Id: startResp.Msg.Session.Id,
			})
			finishReq.Header().Set("Authorization", ts.AuthHeader(userID))
			_, err = ts.SessionClient.FinishSession(ctx, finishReq)
			if err != nil {
				t.Fatalf("failed to finish session %d: %v", i, err)
			}
		}

		// List sessions
		listReq := connect.NewRequest(&heftv1.ListSessionsRequest{
			Pagination: &heftv1.PaginationRequest{
				Page:     1,
				PageSize: 10,
			},
		})
		listReq.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.SessionClient.ListSessions(ctx, listReq)

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

	t.Run("add exercise to session and complete sets", func(t *testing.T) {
		ctx := context.Background()

		// Start a session
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Add an exercise with 1 set
		addExReq := connect.NewRequest(&heftv1.AddExerciseRequest{
			SessionId:  sessionID,
			ExerciseId: exerciseID,
			NumSets:    1,
		})
		addExReq.Header().Set("Authorization", ts.AuthHeader(userID))
		addExResp, err := ts.SessionClient.AddExercise(ctx, addExReq)
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

		// Complete the set using SyncSession
		weight := 100.0
		reps := int32(10)
		syncReq := connect.NewRequest(&heftv1.SyncSessionRequest{
			SessionId: sessionID,
			Sets: []*heftv1.SyncSetData{
				{
					SetId:       setID,
					WeightKg:    &weight,
					Reps:        &reps,
					IsCompleted: true,
				},
			},
		})
		syncReq.Header().Set("Authorization", ts.AuthHeader(userID))
		syncResp, err := ts.SessionClient.SyncSession(ctx, syncReq)
		if err != nil {
			t.Fatalf("failed to sync session: %v", err)
		}

		// Verify the set was updated
		if !syncResp.Msg.Success {
			t.Error("expected sync to succeed")
		}

		// Get the session to verify set data
		getReq := connect.NewRequest(&heftv1.GetSessionRequest{
			Id: sessionID,
		})
		getReq.Header().Set("Authorization", ts.AuthHeader(userID))
		getResp, err := ts.SessionClient.GetSession(ctx, getReq)
		if err != nil {
			t.Fatalf("failed to get session: %v", err)
		}

		// Find the set and verify
		found := false
		for _, ex := range getResp.Msg.Session.Exercises {
			for _, set := range ex.Sets {
				if set.Id == setID {
					found = true
					if set.WeightKg == nil || *set.WeightKg != weight {
						t.Errorf("expected weight %f, got %v", weight, set.WeightKg)
					}
					if set.Reps == nil || *set.Reps != reps {
						t.Errorf("expected reps %d, got %v", reps, set.Reps)
					}
					if !set.IsCompleted {
						t.Error("expected set to be marked as completed")
					}
				}
			}
		}
		if !found {
			t.Error("could not find the set in the session")
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
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Finish the session
		finishReq := connect.NewRequest(&heftv1.FinishSessionRequest{
			Id: sessionID,
		})
		finishReq.Header().Set("Authorization", ts.AuthHeader(userID))
		finishResp, err := ts.SessionClient.FinishSession(ctx, finishReq)
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
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Finish the session with notes
		notes := "Great workout today!"
		finishReq := connect.NewRequest(&heftv1.FinishSessionRequest{
			Id:    sessionID,
			Notes:  &notes,
		})
		finishReq.Header().Set("Authorization", ts.AuthHeader(userID))
		finishResp, err := ts.SessionClient.FinishSession(ctx, finishReq)
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
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Abandon the session
		abandonReq := connect.NewRequest(&heftv1.AbandonSessionRequest{
			Id: sessionID,
		})
		abandonReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.SessionClient.AbandonSession(ctx, abandonReq)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Verify session is abandoned by getting it
		getReq := connect.NewRequest(&heftv1.GetSessionRequest{
			Id: sessionID,
		})
		getReq.Header().Set("Authorization", ts.AuthHeader(userID))
		getResp, err := ts.SessionClient.GetSession(ctx, getReq)
		if err != nil {
			t.Fatalf("failed to get session: %v", err)
		}

		if getResp.Msg.Session.Status != heftv1.WorkoutStatus_WORKOUT_STATUS_ABANDONED {
			t.Errorf("expected status ABANDONED, got %v", getResp.Msg.Session.Status)
		}
	})
}
