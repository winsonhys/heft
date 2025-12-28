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

	// Seed a test exercise
	exerciseID := testutil.SeedTestExercise(t, pool, testutil.TestExercise{
		Name:         "Test Bench Press",
		CategoryID:   testutil.ChestCategoryID,
		ExerciseType: "weight_reps",
		IsSystem:     false,
		CreatedBy:    &userID,
	})

	t.Run("add exercise to session via SyncSession and complete sets", func(t *testing.T) {
		ctx := context.Background()

		// Start an empty session
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}
		sessionID := startResp.Msg.Session.Id

		// Add an exercise with 1 set via SyncSession
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

		if !syncAddResp.Msg.Success {
			t.Fatal("expected sync to succeed")
		}

		if len(syncAddResp.Msg.Session.Exercises) == 0 {
			t.Fatal("expected at least one exercise to be added")
		}

		// Get the set ID from the exercise response
		addedExercise := syncAddResp.Msg.Session.Exercises[0]
		if addedExercise.ExerciseId != exerciseID {
			t.Errorf("expected exercise ID %s, got %s", exerciseID, addedExercise.ExerciseId)
		}

		if len(addedExercise.Sets) == 0 {
			t.Fatal("expected at least one set to be created")
		}
		setID := addedExercise.Sets[0].Id

		// Complete the set using SyncSession with the oneof pattern
		weight := 100.0
		reps := int32(10)
		syncCompleteReq := connect.NewRequest(&heftv1.SyncSessionRequest{
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
		syncCompleteReq.Header().Set("Authorization", ts.AuthHeader(userID))
		syncCompleteResp, err := ts.SessionClient.SyncSession(ctx, syncCompleteReq)
		if err != nil {
			t.Fatalf("failed to sync session: %v", err)
		}

		// Verify the set was updated
		if !syncCompleteResp.Msg.Success {
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

		// Clean up
		abandonReq := connect.NewRequest(&heftv1.AbandonSessionRequest{Id: sessionID})
		abandonReq.Header().Set("Authorization", ts.AuthHeader(userID))
		ts.SessionClient.AbandonSession(ctx, abandonReq)
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

func TestSessionService_Integration_SupersetTracking(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	// Seed test exercises
	exercise1 := testutil.SeedTestExercise(t, pool, testutil.TestExercise{
		Name:         "Bench Press",
		CategoryID:   testutil.ChestCategoryID,
		ExerciseType: "weight_reps",
		IsSystem:     false,
		CreatedBy:    &userID,
	})
	exercise2 := testutil.SeedTestExercise(t, pool, testutil.TestExercise{
		Name:         "Dumbbell Fly",
		CategoryID:   testutil.ChestCategoryID,
		ExerciseType: "weight_reps",
		IsSystem:     false,
		CreatedBy:    &userID,
	})

	t.Run("exercises in superset section share same superset_id", func(t *testing.T) {
		ctx := context.Background()

		// Create workout with superset section containing two exercises
		createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			Name: "Superset Test Workout",
			Sections: []*heftv1.CreateWorkoutSection{
				{
					Name:        "Chest Superset",
					DisplayOrder: 1,
					IsSuperset:  true,
					Items: []*heftv1.CreateSectionItem{
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 1,
							ExerciseId:   &exercise1,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: intPtr(10)},
							},
						},
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 2,
							ExerciseId:   &exercise2,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: intPtr(10)},
							},
						},
					},
				},
			},
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.WorkoutClient.CreateWorkout(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create workout: %v", err)
		}
		workoutID := createResp.Msg.Workout.Id

		// Start session from workout
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{
			WorkoutTemplateId: &workoutID,
		})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		session := startResp.Msg.Session
		if len(session.Exercises) != 2 {
			t.Fatalf("expected 2 exercises, got %d", len(session.Exercises))
		}

		// Verify both exercises have same non-nil superset_id
		ex1 := session.Exercises[0]
		ex2 := session.Exercises[1]

		if ex1.SupersetId == nil {
			t.Error("exercise 1 should have superset_id")
		}
		if ex2.SupersetId == nil {
			t.Error("exercise 2 should have superset_id")
		}
		if ex1.SupersetId != nil && ex2.SupersetId != nil {
			if *ex1.SupersetId != *ex2.SupersetId {
				t.Errorf("exercises in same superset section should share same superset_id, got %s vs %s",
					*ex1.SupersetId, *ex2.SupersetId)
			}
			if *ex1.SupersetId == "" {
				t.Error("superset_id should not be empty")
			}
		}

		// Clean up - abandon session
		abandonReq := connect.NewRequest(&heftv1.AbandonSessionRequest{Id: session.Id})
		abandonReq.Header().Set("Authorization", ts.AuthHeader(userID))
		ts.SessionClient.AbandonSession(ctx, abandonReq)
	})

	t.Run("exercises in non-superset section have no superset_id", func(t *testing.T) {
		ctx := context.Background()

		// Create workout with normal section (not superset)
		createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			Name: "Normal Workout",
			Sections: []*heftv1.CreateWorkoutSection{
				{
					Name:        "Main Workout",
					DisplayOrder: 1,
					IsSuperset:  false, // Not a superset
					Items: []*heftv1.CreateSectionItem{
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 1,
							ExerciseId:   &exercise1,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: intPtr(10)},
							},
						},
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 2,
							ExerciseId:   &exercise2,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: intPtr(10)},
							},
						},
					},
				},
			},
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.WorkoutClient.CreateWorkout(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create workout: %v", err)
		}
		workoutID := createResp.Msg.Workout.Id

		// Start session from workout
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{
			WorkoutTemplateId: &workoutID,
		})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		session := startResp.Msg.Session
		if len(session.Exercises) != 2 {
			t.Fatalf("expected 2 exercises, got %d", len(session.Exercises))
		}

		// Verify exercises have no superset_id
		for i, ex := range session.Exercises {
			if ex.SupersetId != nil && *ex.SupersetId != "" {
				t.Errorf("exercise %d should not have superset_id, got %s", i+1, *ex.SupersetId)
			}
		}

		// Clean up
		abandonReq := connect.NewRequest(&heftv1.AbandonSessionRequest{Id: session.Id})
		abandonReq.Header().Set("Authorization", ts.AuthHeader(userID))
		ts.SessionClient.AbandonSession(ctx, abandonReq)
	})

	t.Run("multiple superset sections have different superset_ids", func(t *testing.T) {
		ctx := context.Background()

		// Seed additional exercises for second superset
		exercise3 := testutil.SeedTestExercise(t, pool, testutil.TestExercise{
			Name:         "Tricep Pushdown",
			CategoryID:   testutil.ArmsCategoryID,
			ExerciseType: "weight_reps",
			IsSystem:     false,
			CreatedBy:    &userID,
		})
		exercise4 := testutil.SeedTestExercise(t, pool, testutil.TestExercise{
			Name:         "Skull Crusher",
			CategoryID:   testutil.ArmsCategoryID,
			ExerciseType: "weight_reps",
			IsSystem:     false,
			CreatedBy:    &userID,
		})

		// Create workout with two superset sections
		createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			Name: "Multi Superset Workout",
			Sections: []*heftv1.CreateWorkoutSection{
				{
					Name:        "Chest Superset",
					DisplayOrder: 1,
					IsSuperset:  true,
					Items: []*heftv1.CreateSectionItem{
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 1,
							ExerciseId:   &exercise1,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: intPtr(10)},
							},
						},
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 2,
							ExerciseId:   &exercise2,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: intPtr(10)},
							},
						},
					},
				},
				{
					Name:        "Tricep Superset",
					DisplayOrder: 2,
					IsSuperset:  true,
					Items: []*heftv1.CreateSectionItem{
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 1,
							ExerciseId:   &exercise3,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: intPtr(12)},
							},
						},
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 2,
							ExerciseId:   &exercise4,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: intPtr(12)},
							},
						},
					},
				},
			},
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.WorkoutClient.CreateWorkout(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create workout: %v", err)
		}
		workoutID := createResp.Msg.Workout.Id

		// Start session from workout
		startReq := connect.NewRequest(&heftv1.StartSessionRequest{
			WorkoutTemplateId: &workoutID,
		})
		startReq.Header().Set("Authorization", ts.AuthHeader(userID))
		startResp, err := ts.SessionClient.StartSession(ctx, startReq)
		if err != nil {
			t.Fatalf("failed to start session: %v", err)
		}

		session := startResp.Msg.Session
		if len(session.Exercises) != 4 {
			t.Fatalf("expected 4 exercises, got %d", len(session.Exercises))
		}

		// Group exercises by section name
		chestExercises := []*heftv1.SessionExercise{}
		tricepExercises := []*heftv1.SessionExercise{}
		for _, ex := range session.Exercises {
			if ex.SectionName == "Chest Superset" {
				chestExercises = append(chestExercises, ex)
			} else if ex.SectionName == "Tricep Superset" {
				tricepExercises = append(tricepExercises, ex)
			}
		}

		if len(chestExercises) != 2 {
			t.Fatalf("expected 2 chest exercises, got %d", len(chestExercises))
		}
		if len(tricepExercises) != 2 {
			t.Fatalf("expected 2 tricep exercises, got %d", len(tricepExercises))
		}

		// Verify each superset section has matching superset_ids
		if chestExercises[0].SupersetId == nil || chestExercises[1].SupersetId == nil {
			t.Error("chest exercises should have superset_id")
		} else if *chestExercises[0].SupersetId != *chestExercises[1].SupersetId {
			t.Error("chest exercises should share same superset_id")
		}

		if tricepExercises[0].SupersetId == nil || tricepExercises[1].SupersetId == nil {
			t.Error("tricep exercises should have superset_id")
		} else if *tricepExercises[0].SupersetId != *tricepExercises[1].SupersetId {
			t.Error("tricep exercises should share same superset_id")
		}

		// Verify the two superset sections have DIFFERENT superset_ids
		if chestExercises[0].SupersetId != nil && tricepExercises[0].SupersetId != nil {
			if *chestExercises[0].SupersetId == *tricepExercises[0].SupersetId {
				t.Errorf("different superset sections should have different superset_ids, both got %s",
					*chestExercises[0].SupersetId)
			}
		}

		// Clean up
		abandonReq := connect.NewRequest(&heftv1.AbandonSessionRequest{Id: session.Id})
		abandonReq.Header().Set("Authorization", ts.AuthHeader(userID))
		ts.SessionClient.AbandonSession(ctx, abandonReq)
	})
}

// Helper function for optional int32 values
func intPtr(i int32) *int32 {
	return &i
}
