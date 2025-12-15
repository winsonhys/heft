package integration_test

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/testutil"
)

func TestWorkoutService_Integration_ListWorkouts(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("list empty workouts", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.ListWorkoutsRequest{
			UserId: userID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.WorkoutClient.ListWorkouts(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// User has no workouts yet
		if len(resp.Msg.Workouts) != 0 {
			t.Errorf("expected 0 workouts, got %d", len(resp.Msg.Workouts))
		}
	})

	t.Run("list workouts after creating some", func(t *testing.T) {
		ctx := context.Background()

		// Create a workout
		createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "Test Workout",
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err := ts.WorkoutClient.CreateWorkout(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create workout: %v", err)
		}

		// List workouts
		listReq := connect.NewRequest(&heftv1.ListWorkoutsRequest{
			UserId: userID,
		})
		listReq.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.WorkoutClient.ListWorkouts(ctx, listReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if len(resp.Msg.Workouts) < 1 {
			t.Errorf("expected at least 1 workout, got %d", len(resp.Msg.Workouts))
		}
	})
}

func TestWorkoutService_Integration_CreateWorkout(t *testing.T) {
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

	t.Run("create basic workout", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "Push Day",
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.WorkoutClient.CreateWorkout(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.Workout.Name != "Push Day" {
			t.Errorf("expected name 'Push Day', got '%s'", resp.Msg.Workout.Name)
		}

		if resp.Msg.Workout.UserId != userID {
			t.Errorf("expected user ID %s, got %s", userID, resp.Msg.Workout.UserId)
		}
	})

	t.Run("create workout with description", func(t *testing.T) {
		ctx := context.Background()
		description := "A pushing focused workout"

		req := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId:      userID,
			Name:        "Push Day v2",
			Description: &description,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.WorkoutClient.CreateWorkout(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.Workout.Description != description {
			t.Errorf("expected description '%s', got '%s'", description, resp.Msg.Workout.Description)
		}
	})

	t.Run("create workout with sections and exercises", func(t *testing.T) {
		ctx := context.Background()
		targetReps := int32(10)
		targetWeight := float64(100)

		req := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "Full Workout Template",
			Sections: []*heftv1.CreateWorkoutSection{
				{
					Name:         "Warmup",
					DisplayOrder: 1,
					IsSuperset:   false,
					Items: []*heftv1.CreateSectionItem{
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 1,
							ExerciseId:   &exerciseID,
							TargetSets: []*heftv1.CreateTargetSet{
								{
									SetNumber:      1,
									TargetReps:     &targetReps,
									TargetWeightKg: &targetWeight,
								},
								{
									SetNumber:      2,
									TargetReps:     &targetReps,
									TargetWeightKg: &targetWeight,
									RestDurationSeconds: func() *int32 { v := int32(60); return &v }(),
								},
							},
						},
					},
				},
			},
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.WorkoutClient.CreateWorkout(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if len(resp.Msg.Workout.Sections) != 1 {
			t.Errorf("expected 1 section, got %d", len(resp.Msg.Workout.Sections))
		}

		if len(resp.Msg.Workout.Sections) > 0 {
			section := resp.Msg.Workout.Sections[0]
			if section.Name != "Warmup" {
				t.Errorf("expected section name 'Warmup', got '%s'", section.Name)
			}

			if len(section.Items) != 1 {
				t.Errorf("expected 1 item, got %d", len(section.Items))
			}

			if len(section.Items) > 0 && len(section.Items[0].TargetSets) != 2 {
				t.Errorf("expected 2 target sets, got %d", len(section.Items[0].TargetSets))
			}
		}
	})
}

func TestWorkoutService_Integration_GetWorkout(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get existing workout", func(t *testing.T) {
		ctx := context.Background()

		// Create a workout first
		createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "Test Workout",
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.WorkoutClient.CreateWorkout(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create workout: %v", err)
		}

		workoutID := createResp.Msg.Workout.Id

		// Get the workout
		getReq := connect.NewRequest(&heftv1.GetWorkoutRequest{
			Id:     workoutID,
			UserId: userID,
		})
		getReq.Header().Set("Authorization", ts.AuthHeader(userID))
		getResp, err := ts.WorkoutClient.GetWorkout(ctx, getReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if getResp.Msg.Workout.Id != workoutID {
			t.Errorf("expected workout ID %s, got %s", workoutID, getResp.Msg.Workout.Id)
		}
	})

	t.Run("get non-existent workout returns not found", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.GetWorkoutRequest{
			Id:     "00000000-0000-0000-0000-000000000000",
			UserId: userID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err := ts.WorkoutClient.GetWorkout(ctx, req)

		if err == nil {
			t.Fatal("expected error for non-existent workout")
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

func TestWorkoutService_Integration_DeleteWorkout(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("delete existing workout", func(t *testing.T) {
		ctx := context.Background()

		// Create a workout first
		createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "To Be Deleted",
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.WorkoutClient.CreateWorkout(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create workout: %v", err)
		}

		workoutID := createResp.Msg.Workout.Id

		// Delete the workout
		deleteReq := connect.NewRequest(&heftv1.DeleteWorkoutRequest{
			Id:     workoutID,
			UserId: userID,
		})
		deleteReq.Header().Set("Authorization", ts.AuthHeader(userID))
		deleteResp, err := ts.WorkoutClient.DeleteWorkout(ctx, deleteReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if !deleteResp.Msg.Success {
			t.Error("expected success to be true")
		}

		// Verify workout is deleted
		verifyReq := connect.NewRequest(&heftv1.GetWorkoutRequest{
			Id:     workoutID,
			UserId: userID,
		})
		verifyReq.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err = ts.WorkoutClient.GetWorkout(ctx, verifyReq)

		if err == nil {
			t.Error("expected error when getting deleted workout")
		}

		var connectErr *connect.Error
		if errors.As(err, &connectErr) {
			if connectErr.Code() != connect.CodeNotFound {
				t.Errorf("expected NotFound error, got %v", connectErr.Code())
			}
		}
	})
}

func TestWorkoutService_Integration_DuplicateWorkout(t *testing.T) {
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

	t.Run("duplicate workout preserves structure", func(t *testing.T) {
		ctx := context.Background()
		targetReps := int32(8)

		// Create original workout with sections
		createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "Original Workout",
			Sections: []*heftv1.CreateWorkoutSection{
				{
					Name:         "Main Lifts",
					DisplayOrder: 1,
					Items: []*heftv1.CreateSectionItem{
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 1,
							ExerciseId:   &exerciseID,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: &targetReps},
								{SetNumber: 2, TargetReps: &targetReps},
								{SetNumber: 3, TargetReps: &targetReps, RestDurationSeconds: func() *int32 { v := int32(45); return &v }()},
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

		originalID := createResp.Msg.Workout.Id

		// Duplicate the workout
		dupReq := connect.NewRequest(&heftv1.DuplicateWorkoutRequest{
			Id:     originalID,
			UserId: userID,
		})
		dupReq.Header().Set("Authorization", ts.AuthHeader(userID))
		dupResp, err := ts.WorkoutClient.DuplicateWorkout(ctx, dupReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Verify the duplicate
		if dupResp.Msg.Workout.Id == originalID {
			t.Error("duplicate should have different ID than original")
		}

		if dupResp.Msg.Workout.Name != "Original Workout (Copy)" {
			t.Errorf("expected name 'Original Workout (Copy)', got '%s'", dupResp.Msg.Workout.Name)
		}

		if len(dupResp.Msg.Workout.Sections) != 1 {
			t.Errorf("expected 1 section in duplicate, got %d", len(dupResp.Msg.Workout.Sections))
		}

		if len(dupResp.Msg.Workout.Sections) > 0 && len(dupResp.Msg.Workout.Sections[0].Items) > 0 {
			if len(dupResp.Msg.Workout.Sections[0].Items[0].TargetSets) != 3 {
				t.Errorf("expected 3 target sets in duplicate, got %d", len(dupResp.Msg.Workout.Sections[0].Items[0].TargetSets))
			}
			// Check if rest timer was copied (Set 3)
			sets := dupResp.Msg.Workout.Sections[0].Items[0].TargetSets
			foundRest := false
			for _, s := range sets {
				if s.SetNumber == 3 {
					if s.RestDurationSeconds != nil && *s.RestDurationSeconds == 45 {
						foundRest = true
					}
				}
			}
			if !foundRest {
				t.Error("expected set 3 to have rest duration 45 in duplicated workout")
			}
		}
	})

	t.Run("duplicate with custom name", func(t *testing.T) {
		ctx := context.Background()

		// Create original workout
		createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "Template",
		})
		createReq.Header().Set("Authorization", ts.AuthHeader(userID))
		createResp, err := ts.WorkoutClient.CreateWorkout(ctx, createReq)
		if err != nil {
			t.Fatalf("failed to create workout: %v", err)
		}

		originalID := createResp.Msg.Workout.Id
		customName := "My Custom Copy"

		// Duplicate with custom name
		dupReq := connect.NewRequest(&heftv1.DuplicateWorkoutRequest{
			Id:      originalID,
			UserId:  userID,
			NewName: &customName,
		})
		dupReq.Header().Set("Authorization", ts.AuthHeader(userID))
		dupResp, err := ts.WorkoutClient.DuplicateWorkout(ctx, dupReq)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if dupResp.Msg.Workout.Name != customName {
			t.Errorf("expected name '%s', got '%s'", customName, dupResp.Msg.Workout.Name)
		}
	})
}

// TestWorkoutService_Integration_UpdateWorkout verifies the UpdateWorkout functionality
func TestWorkoutService_Integration_UpdateWorkout(t *testing.T) {
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
		Pagination: &heftv1.PaginationRequest{Page: 1, PageSize: 1},
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

	t.Run("update workout details and sections", func(t *testing.T) {
		ctx := context.Background()

		// 1. Create initial workout
		targetReps := int32(10)
		createReq := connect.NewRequest(&heftv1.CreateWorkoutRequest{
			UserId: userID,
			Name:   "Original Workout",
			Sections: []*heftv1.CreateWorkoutSection{
				{
					Name:         "Section 1",
					DisplayOrder: 1,
					Items: []*heftv1.CreateSectionItem{
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 1,
							ExerciseId:   &exerciseID,
							TargetSets: []*heftv1.CreateTargetSet{
								{SetNumber: 1, TargetReps: &targetReps},
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

		// 2. Update workout
		newName := "Updated Workout"
		newDesc := "Updated description"
		restDuration := int32(90)
		updateReq := connect.NewRequest(&heftv1.UpdateWorkoutRequest{
			Id:          workoutID,
			Name:        &newName,
			Description: &newDesc,
			UserId:      userID,
			Sections: []*heftv1.CreateWorkoutSection{
				{
					Name:         "Updated Section",
					DisplayOrder: 1,
					Items: []*heftv1.CreateSectionItem{
						{
							ItemType:     heftv1.SectionItemType_SECTION_ITEM_TYPE_EXERCISE,
							DisplayOrder: 1,
							ExerciseId:   &exerciseID,
							TargetSets: []*heftv1.CreateTargetSet{
								{
									SetNumber:           1,
									TargetReps:          &targetReps,
									RestDurationSeconds: &restDuration, // Check rest timer persistence
								},
							},
						},
					},
				},
			},
		})
		updateReq.Header().Set("Authorization", ts.AuthHeader(userID))
		updateResp, err := ts.WorkoutClient.UpdateWorkout(ctx, updateReq)
		if err != nil {
			t.Fatalf("failed to update workout: %v", err)
		}

		// 3. Verify updates
		if updateResp.Msg.Workout.Name != newName {
			t.Errorf("expected name '%s', got '%s'", newName, updateResp.Msg.Workout.Name)
		}
		if updateResp.Msg.Workout.Description != *updateReq.Msg.Description {
			t.Errorf("expected description '%s', got '%s'", *updateReq.Msg.Description, updateResp.Msg.Workout.Description)
		}

		if len(updateResp.Msg.Workout.Sections) != 1 {
			t.Fatalf("expected 1 section, got %d", len(updateResp.Msg.Workout.Sections))
		}
		section := updateResp.Msg.Workout.Sections[0]
		if section.Name != "Updated Section" {
			t.Errorf("expected section name 'Updated Section', got '%s'", section.Name)
		}

		if len(section.Items) != 1 {
			t.Fatalf("expected 1 item, got %d", len(section.Items))
		}
		item := section.Items[0]
		if len(item.TargetSets) != 1 {
			t.Fatalf("expected 1 set, got %d", len(item.TargetSets))
		}
		set := item.TargetSets[0]
		if set.RestDurationSeconds == nil || *set.RestDurationSeconds != restDuration {
			t.Errorf("expected rest duration %d, got %v", restDuration, set.RestDurationSeconds)
		}
	})
}
