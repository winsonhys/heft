package testutil

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/heftyback/gen/heft/v1/heftv1connect"
	"github.com/heftyback/internal/handlers"
	"github.com/heftyback/internal/repository"
)

// TestServer wraps an httptest.Server with Connect-RPC clients
type TestServer struct {
	Server         *httptest.Server
	UserClient     heftv1connect.UserServiceClient
	ExerciseClient heftv1connect.ExerciseServiceClient
	SessionClient  heftv1connect.SessionServiceClient
	WorkoutClient  heftv1connect.WorkoutServiceClient
	ProgramClient  heftv1connect.ProgramServiceClient
	ProgressClient heftv1connect.ProgressServiceClient
	Pool           *pgxpool.Pool
}

// NewTestServer creates a test HTTP server with all services wired up
func NewTestServer(t *testing.T, pool *pgxpool.Pool) *TestServer {
	t.Helper()

	// Initialize repositories
	userRepo := repository.NewUserRepository(pool)
	exerciseRepo := repository.NewExerciseRepository(pool)
	sessionRepo := repository.NewSessionRepository(pool)
	workoutRepo := repository.NewWorkoutRepository(pool)
	programRepo := repository.NewProgramRepository(pool)
	progressRepo := repository.NewProgressRepository(pool)

	// Initialize handlers
	userHandler := handlers.NewUserHandler(userRepo)
	exerciseHandler := handlers.NewExerciseHandler(exerciseRepo)
	sessionHandler := handlers.NewSessionHandler(sessionRepo, workoutRepo)
	workoutHandler := handlers.NewWorkoutHandler(workoutRepo)
	programHandler := handlers.NewProgramHandler(programRepo, workoutRepo)
	progressHandler := handlers.NewProgressHandler(progressRepo, exerciseRepo)

	// Create HTTP mux
	mux := http.NewServeMux()

	// Register Connect services
	userPath, userHTTPHandler := heftv1connect.NewUserServiceHandler(userHandler)
	exercisePath, exerciseHTTPHandler := heftv1connect.NewExerciseServiceHandler(exerciseHandler)
	sessionPath, sessionHTTPHandler := heftv1connect.NewSessionServiceHandler(sessionHandler)
	workoutPath, workoutHTTPHandler := heftv1connect.NewWorkoutServiceHandler(workoutHandler)
	programPath, programHTTPHandler := heftv1connect.NewProgramServiceHandler(programHandler)
	progressPath, progressHTTPHandler := heftv1connect.NewProgressServiceHandler(progressHandler)

	mux.Handle(userPath, userHTTPHandler)
	mux.Handle(exercisePath, exerciseHTTPHandler)
	mux.Handle(sessionPath, sessionHTTPHandler)
	mux.Handle(workoutPath, workoutHTTPHandler)
	mux.Handle(programPath, programHTTPHandler)
	mux.Handle(progressPath, progressHTTPHandler)

	// Create test server
	server := httptest.NewServer(mux)
	t.Cleanup(func() {
		server.Close()
	})

	// Create clients
	httpClient := server.Client()
	userClient := heftv1connect.NewUserServiceClient(httpClient, server.URL)
	exerciseClient := heftv1connect.NewExerciseServiceClient(httpClient, server.URL)
	sessionClient := heftv1connect.NewSessionServiceClient(httpClient, server.URL)
	workoutClient := heftv1connect.NewWorkoutServiceClient(httpClient, server.URL)
	programClient := heftv1connect.NewProgramServiceClient(httpClient, server.URL)
	progressClient := heftv1connect.NewProgressServiceClient(httpClient, server.URL)

	return &TestServer{
		Server:         server,
		UserClient:     userClient,
		ExerciseClient: exerciseClient,
		SessionClient:  sessionClient,
		WorkoutClient:  workoutClient,
		ProgramClient:  programClient,
		ProgressClient: progressClient,
		Pool:           pool,
	}
}

// NewTestServerWithMocks creates a test server with injectable mock repositories
func NewTestServerWithMocks(
	t *testing.T,
	userRepo repository.UserRepositoryInterface,
	exerciseRepo repository.ExerciseRepositoryInterface,
) *TestServer {
	t.Helper()

	// Initialize handlers with mocks
	userHandler := handlers.NewUserHandler(userRepo)
	exerciseHandler := handlers.NewExerciseHandler(exerciseRepo)

	// Create HTTP mux
	mux := http.NewServeMux()

	// Register Connect services
	userPath, userHTTPHandler := heftv1connect.NewUserServiceHandler(userHandler)
	exercisePath, exerciseHTTPHandler := heftv1connect.NewExerciseServiceHandler(exerciseHandler)

	mux.Handle(userPath, userHTTPHandler)
	mux.Handle(exercisePath, exerciseHTTPHandler)

	// Create test server
	server := httptest.NewServer(mux)
	t.Cleanup(func() {
		server.Close()
	})

	// Create clients
	httpClient := server.Client()
	userClient := heftv1connect.NewUserServiceClient(httpClient, server.URL)
	exerciseClient := heftv1connect.NewExerciseServiceClient(httpClient, server.URL)

	return &TestServer{
		Server:         server,
		UserClient:     userClient,
		ExerciseClient: exerciseClient,
	}
}
