package integration_test

import (
	"context"
	"errors"
	"strings"
	"testing"

	"connectrpc.com/connect"

	heftv1 "github.com/heftyback/gen/heft/v1"
	"github.com/heftyback/internal/testutil"
)

func TestExerciseService_Integration_ListCategories(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create test user for auth
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("list all seeded categories", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.ListCategoriesRequest{})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.ListCategories(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// From seed data, we expect 8 categories
		if len(resp.Msg.Categories) != 8 {
			t.Errorf("expected 8 categories, got %d", len(resp.Msg.Categories))
		}

		// Verify first category (Chest should be first by display_order)
		if len(resp.Msg.Categories) > 0 {
			if resp.Msg.Categories[0].Name != "Chest" {
				t.Errorf("expected first category to be 'Chest', got '%s'", resp.Msg.Categories[0].Name)
			}
		}
	})
}

func TestExerciseService_Integration_ListExercises(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create test user for auth
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("list all system exercises", func(t *testing.T) {
		ctx := context.Background()
		systemOnly := true

		req := connect.NewRequest(&heftv1.ListExercisesRequest{
			SystemOnly: &systemOnly,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.ListExercises(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Seed data includes 37 system exercises
		if resp.Msg.Pagination.TotalCount < 30 {
			t.Errorf("expected at least 30 system exercises, got %d", resp.Msg.Pagination.TotalCount)
		}
	})

	t.Run("filter by category", func(t *testing.T) {
		ctx := context.Background()
		chestCategoryID := testutil.GetChestCategoryID()

		req := connect.NewRequest(&heftv1.ListExercisesRequest{
			CategoryId: &chestCategoryID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.ListExercises(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// All returned exercises should be in Chest category
		for _, ex := range resp.Msg.Exercises {
			if ex.CategoryId != chestCategoryID {
				t.Errorf("expected category ID %s, got %s", chestCategoryID, ex.CategoryId)
			}
		}
	})

	t.Run("pagination works", func(t *testing.T) {
		ctx := context.Background()

		// Get first page
		page1Req := connect.NewRequest(&heftv1.ListExercisesRequest{
			Pagination: &heftv1.PaginationRequest{
				Page:     1,
				PageSize: 5,
			},
		})
		page1Req.Header().Set("Authorization", ts.AuthHeader(userID))
		page1Resp, err := ts.ExerciseClient.ListExercises(ctx, page1Req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if len(page1Resp.Msg.Exercises) != 5 {
			t.Errorf("expected 5 exercises on page 1, got %d", len(page1Resp.Msg.Exercises))
		}

		// Get second page
		page2Req := connect.NewRequest(&heftv1.ListExercisesRequest{
			Pagination: &heftv1.PaginationRequest{
				Page:     2,
				PageSize: 5,
			},
		})
		page2Req.Header().Set("Authorization", ts.AuthHeader(userID))
		page2Resp, err := ts.ExerciseClient.ListExercises(ctx, page2Req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Ensure pages have different exercises
		if len(page2Resp.Msg.Exercises) > 0 && len(page1Resp.Msg.Exercises) > 0 {
			if page1Resp.Msg.Exercises[0].Id == page2Resp.Msg.Exercises[0].Id {
				t.Error("page 1 and page 2 should have different exercises")
			}
		}
	})
}

func TestExerciseService_Integration_GetExercise(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create test user for auth
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get system exercise by ID", func(t *testing.T) {
		ctx := context.Background()

		// First, list exercises to get a valid ID
		listReq := connect.NewRequest(&heftv1.ListExercisesRequest{
			Pagination: &heftv1.PaginationRequest{
				Page:     1,
				PageSize: 1,
			},
		})
		listReq.Header().Set("Authorization", ts.AuthHeader(userID))
		listResp, err := ts.ExerciseClient.ListExercises(ctx, listReq)

		if err != nil {
			t.Fatalf("failed to list exercises: %v", err)
		}

		if len(listResp.Msg.Exercises) == 0 {
			t.Fatal("no exercises found")
		}

		exerciseID := listResp.Msg.Exercises[0].Id

		// Get the exercise
		req := connect.NewRequest(&heftv1.GetExerciseRequest{
			Id: exerciseID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.GetExercise(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.Exercise.Id != exerciseID {
			t.Errorf("expected exercise ID %s, got %s", exerciseID, resp.Msg.Exercise.Id)
		}
	})

	t.Run("get non-existent exercise returns not found", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.GetExerciseRequest{
			Id: "00000000-0000-0000-0000-000000000000",
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		_, err := ts.ExerciseClient.GetExercise(ctx, req)

		if err == nil {
			t.Fatal("expected error for non-existent exercise")
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

func TestExerciseService_Integration_CreateExercise(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create a test user first
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("create custom exercise", func(t *testing.T) {
		ctx := context.Background()
		chestCategoryID := testutil.GetChestCategoryID()

		req := connect.NewRequest(&heftv1.CreateExerciseRequest{
			UserId:       userID,
			Name:         "My Custom Bench Press",
			CategoryId:   chestCategoryID,
			ExerciseType: heftv1.ExerciseType_EXERCISE_TYPE_WEIGHT_REPS,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.CreateExercise(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.Exercise.Name != "My Custom Bench Press" {
			t.Errorf("expected name 'My Custom Bench Press', got '%s'", resp.Msg.Exercise.Name)
		}

		if resp.Msg.Exercise.IsSystem {
			t.Error("expected IsSystem to be false for custom exercise")
		}

		if resp.Msg.Exercise.CreatedBy != userID {
			t.Errorf("expected CreatedBy %s, got %s", userID, resp.Msg.Exercise.CreatedBy)
		}
	})

	t.Run("create exercise with description", func(t *testing.T) {
		ctx := context.Background()
		chestCategoryID := testutil.GetChestCategoryID()
		description := "A modified version of bench press"

		req := connect.NewRequest(&heftv1.CreateExerciseRequest{
			UserId:       userID,
			Name:         "Modified Bench Press",
			CategoryId:   chestCategoryID,
			ExerciseType: heftv1.ExerciseType_EXERCISE_TYPE_WEIGHT_REPS,
			Description:  &description,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.CreateExercise(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.Exercise.Description != description {
			t.Errorf("expected description '%s', got '%s'", description, resp.Msg.Exercise.Description)
		}
	})

	t.Run("custom exercise appears in user's exercise list", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.ListExercisesRequest{
			UserId: &userID,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.ListExercises(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Should include both system exercises and custom ones
		foundCustom := false
		for _, ex := range resp.Msg.Exercises {
			if ex.Name == "My Custom Bench Press" {
				foundCustom = true
				break
			}
		}

		if !foundCustom {
			t.Error("expected to find custom exercise in list")
		}
	})
}

func TestExerciseService_Integration_SearchExercises(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	// Create test user for auth
	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("search for 'press' exercises", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.SearchExercisesRequest{
			Query: "press",
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.SearchExercises(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		// Should find Bench Press, Overhead Press, Arnold Press, etc.
		if len(resp.Msg.Exercises) == 0 {
			t.Error("expected to find exercises matching 'press'")
		}

		// Verify all results contain 'press' in the name (case-insensitive)
		for _, ex := range resp.Msg.Exercises {
			if !strings.Contains(strings.ToLower(ex.Name), "press") {
				t.Errorf("expected exercise name to contain 'press', got '%s'", ex.Name)
			}
		}
	})

	t.Run("search with limit", func(t *testing.T) {
		ctx := context.Background()
		limit := int32(2)

		req := connect.NewRequest(&heftv1.SearchExercisesRequest{
			Query: "press",
			Limit: &limit,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.SearchExercises(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if len(resp.Msg.Exercises) > 2 {
			t.Errorf("expected at most 2 exercises, got %d", len(resp.Msg.Exercises))
		}
	})

	t.Run("search for non-existent exercise", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.SearchExercisesRequest{
			Query: "zzznonexistent",
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))
		resp, err := ts.ExerciseClient.SearchExercises(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if len(resp.Msg.Exercises) != 0 {
			t.Errorf("expected 0 exercises, got %d", len(resp.Msg.Exercises))
		}
	})
}
