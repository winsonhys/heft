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

func TestUserService_Integration_GetProfile(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("get existing user profile", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.GetProfileRequest{})
		req.Header().Set("Authorization", ts.AuthHeader(userID))

		resp, err := ts.UserClient.GetProfile(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.User == nil {
			t.Fatal("expected user in response")
		}

		if resp.Msg.User.Id != userID {
			t.Errorf("expected user ID %s, got %s", userID, resp.Msg.User.Id)
		}

		if resp.Msg.User.Email != testUser.Email {
			t.Errorf("expected email %s, got %s", testUser.Email, resp.Msg.User.Email)
		}

		if resp.Msg.User.DisplayName != *testUser.DisplayName {
			t.Errorf("expected display name %s, got %s", *testUser.DisplayName, resp.Msg.User.DisplayName)
		}
	})

	t.Run("get non-existent user returns not found", func(t *testing.T) {
		ctx := context.Background()
		nonExistentUserID := "00000000-0000-0000-0000-000000000000"

		req := connect.NewRequest(&heftv1.GetProfileRequest{})
		req.Header().Set("Authorization", ts.AuthHeader(nonExistentUserID))

		_, err := ts.UserClient.GetProfile(ctx, req)

		if err == nil {
			t.Fatal("expected error for non-existent user")
		}

		var connectErr *connect.Error
		if !errors.As(err, &connectErr) {
			t.Fatalf("expected connect error, got %T", err)
		}

		if connectErr.Code() != connect.CodeNotFound {
			t.Errorf("expected NotFound error, got %v", connectErr.Code())
		}
	})

	t.Run("unauthenticated request returns error", func(t *testing.T) {
		ctx := context.Background()

		req := connect.NewRequest(&heftv1.GetProfileRequest{})

		_, err := ts.UserClient.GetProfile(ctx, req)

		if err == nil {
			t.Fatal("expected error for unauthenticated request")
		}

		var connectErr *connect.Error
		if !errors.As(err, &connectErr) {
			t.Fatalf("expected connect error, got %T", err)
		}

		if connectErr.Code() != connect.CodeUnauthenticated {
			t.Errorf("expected Unauthenticated error, got %v", connectErr.Code())
		}
	})
}

func TestUserService_Integration_UpdateProfile(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("update display name", func(t *testing.T) {
		ctx := context.Background()
		newDisplayName := "Updated Name"

		req := connect.NewRequest(&heftv1.UpdateProfileRequest{
			DisplayName: &newDisplayName,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))

		resp, err := ts.UserClient.UpdateProfile(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.User.DisplayName != newDisplayName {
			t.Errorf("expected display name %s, got %s", newDisplayName, resp.Msg.User.DisplayName)
		}
	})

	t.Run("update avatar URL", func(t *testing.T) {
		ctx := context.Background()
		newAvatarURL := "https://example.com/avatar.png"

		req := connect.NewRequest(&heftv1.UpdateProfileRequest{
			AvatarUrl: &newAvatarURL,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))

		resp, err := ts.UserClient.UpdateProfile(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.User.AvatarUrl != newAvatarURL {
			t.Errorf("expected avatar URL %s, got %s", newAvatarURL, resp.Msg.User.AvatarUrl)
		}
	})
}

func TestUserService_Integration_UpdateSettings(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("update use_pounds setting", func(t *testing.T) {
		ctx := context.Background()
		usePounds := true

		req := connect.NewRequest(&heftv1.UpdateSettingsRequest{
			UsePounds: &usePounds,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))

		resp, err := ts.UserClient.UpdateSettings(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if !resp.Msg.User.UsePounds {
			t.Error("expected use_pounds to be true")
		}
	})

	t.Run("update rest_timer_seconds setting", func(t *testing.T) {
		ctx := context.Background()
		restTimer := int32(90)

		req := connect.NewRequest(&heftv1.UpdateSettingsRequest{
			RestTimerSeconds: &restTimer,
		})
		req.Header().Set("Authorization", ts.AuthHeader(userID))

		resp, err := ts.UserClient.UpdateSettings(ctx, req)

		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if resp.Msg.User.RestTimerSeconds != restTimer {
			t.Errorf("expected rest_timer_seconds %d, got %d", restTimer, resp.Msg.User.RestTimerSeconds)
		}
	})
}

func TestUserService_Integration_WeightLogging(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping integration test in short mode")
	}

	pool := testutil.NewTestPool(t)
	ts := testutil.NewTestServer(t, pool)

	testUser := testutil.DefaultTestUser()
	userID := testutil.SeedTestUser(t, pool, testUser)

	t.Run("log weight and retrieve history", func(t *testing.T) {
		ctx := context.Background()

		// Log weight for today
		today := time.Now().Format("2006-01-02")
		logReq := connect.NewRequest(&heftv1.LogWeightRequest{
			WeightKg:   75.5,
			LoggedDate: today,
		})
		logReq.Header().Set("Authorization", ts.AuthHeader(userID))

		logResp, err := ts.UserClient.LogWeight(ctx, logReq)

		if err != nil {
			t.Fatalf("failed to log weight: %v", err)
		}

		if logResp.Msg.WeightLog.WeightKg != 75.5 {
			t.Errorf("expected weight 75.5, got %f", logResp.Msg.WeightLog.WeightKg)
		}

		// Retrieve history
		historyReq := connect.NewRequest(&heftv1.GetWeightHistoryRequest{})
		historyReq.Header().Set("Authorization", ts.AuthHeader(userID))

		historyResp, err := ts.UserClient.GetWeightHistory(ctx, historyReq)

		if err != nil {
			t.Fatalf("failed to get weight history: %v", err)
		}

		if len(historyResp.Msg.WeightLogs) != 1 {
			t.Errorf("expected 1 weight log, got %d", len(historyResp.Msg.WeightLogs))
		}
	})

	t.Run("update weight for same day (upsert)", func(t *testing.T) {
		ctx := context.Background()
		today := time.Now().Format("2006-01-02")

		// Log updated weight for same day
		logReq := connect.NewRequest(&heftv1.LogWeightRequest{
			WeightKg:   76.0,
			LoggedDate: today,
		})
		logReq.Header().Set("Authorization", ts.AuthHeader(userID))

		_, err := ts.UserClient.LogWeight(ctx, logReq)

		if err != nil {
			t.Fatalf("failed to update weight: %v", err)
		}

		// Verify only one entry exists for today
		historyReq := connect.NewRequest(&heftv1.GetWeightHistoryRequest{})
		historyReq.Header().Set("Authorization", ts.AuthHeader(userID))

		historyResp, err := ts.UserClient.GetWeightHistory(ctx, historyReq)

		if err != nil {
			t.Fatalf("failed to get weight history: %v", err)
		}

		// Should still be 1 (upsert on same date)
		if len(historyResp.Msg.WeightLogs) != 1 {
			t.Errorf("expected 1 weight log after upsert, got %d", len(historyResp.Msg.WeightLogs))
		}

		if historyResp.Msg.WeightLogs[0].WeightKg != 76.0 {
			t.Errorf("expected updated weight 76.0, got %f", historyResp.Msg.WeightLogs[0].WeightKg)
		}
	})

	t.Run("delete weight log", func(t *testing.T) {
		ctx := context.Background()

		// Get the weight log ID
		historyReq := connect.NewRequest(&heftv1.GetWeightHistoryRequest{})
		historyReq.Header().Set("Authorization", ts.AuthHeader(userID))

		historyResp, _ := ts.UserClient.GetWeightHistory(ctx, historyReq)

		if len(historyResp.Msg.WeightLogs) == 0 {
			t.Fatal("no weight logs to delete")
		}

		logID := historyResp.Msg.WeightLogs[0].Id

		// Delete the weight log
		deleteReq := connect.NewRequest(&heftv1.DeleteWeightLogRequest{
			Id: logID,
		})
		deleteReq.Header().Set("Authorization", ts.AuthHeader(userID))

		deleteResp, err := ts.UserClient.DeleteWeightLog(ctx, deleteReq)

		if err != nil {
			t.Fatalf("failed to delete weight log: %v", err)
		}

		if !deleteResp.Msg.Success {
			t.Error("expected success to be true")
		}

		// Verify deletion
		historyReq2 := connect.NewRequest(&heftv1.GetWeightHistoryRequest{})
		historyReq2.Header().Set("Authorization", ts.AuthHeader(userID))

		historyResp, _ = ts.UserClient.GetWeightHistory(ctx, historyReq2)

		if len(historyResp.Msg.WeightLogs) != 0 {
			t.Errorf("expected 0 weight logs after deletion, got %d", len(historyResp.Msg.WeightLogs))
		}
	})
}
